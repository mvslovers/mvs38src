#!/usr/bin/env python3
"""Copy job output off the JES2 spool onto disk, and optionally purge what was
copied.

`bldrun.py` forces `MSGCLASS=H` so its jobs stay readable through the REST API.
That is right for observability and costly on the spool: nothing is ever
printed and purged, so every job of every run accumulates. On 2026-09-10 the
build volume stood at 56 percent with 87 of 300 jobs run, two thirds of it the
output of a run we had already discarded.

Purging is off unless asked for, and never happens before the archive file is
on disk and non-empty -- the spool copy stops being the only copy first, then
it stops being a copy at all.

    spoolarch.py                              archive everything, remove nothing
    spoolarch.py --from JOB00319              only this run
    spoolarch.py --to JOB00319 --purge        archive and purge the older run
    spoolarch.py --from JOB00319 --purge --clean-only --loop 600

The last form is the one to leave running beside `bldrun.py`: every ten minutes
it copies whatever finished cleanly and gives the spool that space back, while
anything that ended with a verdict stays put to be looked at. The driver needs
no change and no restart for this.
"""
import argparse, base64, json, os, sys, time, urllib.request

SYSTEMS = {
    "lab": dict(host="mvsdev.lan", port=8082, cred="IBMUSER:SYS1"),
    "ref": dict(host="mvsdev.lan", port=8084, cred="HERC01:CUL8TR"),
    "bld": dict(host="mvsdev.lan", port=8085, cred="HERC01:CUL8TR"),
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--system", default="bld", choices=sorted(SYSTEMS))
    ap.add_argument("--out", default=os.path.expanduser("~/mvs-spool-archive"))
    ap.add_argument("--from", dest="lo", default="",
                    help="lowest jobid to take, e.g. JOB00319")
    ap.add_argument("--to", dest="hi", default="",
                    help="exclusive upper jobid, e.g. JOB00319")
    ap.add_argument("--purge", action="store_true",
                    help="remove from the spool once the archive file is there")
    ap.add_argument("--clean-only", action="store_true",
                    help="with --purge, keep anything that did not end 0000/0004")
    ap.add_argument("--loop", type=int, default=0, metavar="SEC",
                    help="keep running, one sweep every SEC seconds")
    a = ap.parse_args()

    s = SYSTEMS[a.system]
    host = f"http://{s['host']}:{s['port']}"
    auth = base64.b64encode(s["cred"].encode()).decode()
    out = os.path.join(a.out, a.system)
    os.makedirs(out, exist_ok=True)

    def req(path, method="GET", tries=4):
        for n in range(tries):
            try:
                r = urllib.request.Request(host + path, method=method)
                r.add_header("Authorization", "Basic " + auth)
                with urllib.request.urlopen(r, timeout=180) as f:
                    return f.read()
            except Exception:
                if n == tries - 1:
                    raise
                time.sleep(2 * (n + 1))

    def get(path, tries=4):
        return req(path, "GET", tries)

    def items(b):
        d = json.loads(b)
        return d.get("items", d.get("jobs", d)) if isinstance(d, dict) else d

    def purge(jn, ji, rc, path):
        """Remove one job from the spool. Returns 1 if it went.

        Three conditions, all of them checked here rather than at the call
        site, so no path into this function can skip one: purging was asked
        for, the archive file exists with content, and -- under --clean-only --
        the job ended without a verdict worth keeping.
        """
        if not a.purge:
            return 0
        if not (os.path.exists(path) and os.path.getsize(path) > 0):
            return 0
        if a.clean_only and rc not in ("CC 0000", "CC 0004"):
            print(f"  behalten {jn}/{ji}: {rc}")
            return 0
        try:
            req(f"/zosmf/restjobs/jobs/{jn}/{ji}", "DELETE")
            return 1
        except Exception as e:
            print(f"  PURGE FEHLGESCHLAGEN {jn}/{ji}: {e}")
            return 0

    def sweep():
        jobs = [j for j in items(get("/zosmf/restjobs/jobs?owner=*&prefix=*"))
                if j.get("status") == "OUTPUT"
                and (not a.lo or (j.get("jobid") or "") >= a.lo)
                and (not a.hi or (j.get("jobid") or "") < a.hi)]
        print(f"{len(jobs)} Jobs zu sichern von {a.system}"
              + (", danach purgen" if a.purge else ""))

        done = failed = skip = purged = 0
        total = 0
        for j in jobs:
            jn, ji, rc = j.get("jobname"), j.get("jobid"), j.get("retcode")
            path = os.path.join(out, f"{ji}-{jn}.txt")
            if os.path.exists(path) and os.path.getsize(path) > 0:
                total += os.path.getsize(path)
                skip += 1
                purged += purge(jn, ji, rc, path)
                continue
            try:
                buf = [f"* job {jn}/{ji}  rc={rc}\n"]
                for fi in items(get(f"/zosmf/restjobs/jobs/{jn}/{ji}/files")):
                    dd = fi.get("ddname") or fi.get("ddName") or "?"
                    key = fi.get("id") or fi.get("key")
                    buf.append(f"\n*** DD {dd} (id {key}) ***\n")
                    buf.append(get(f"/zosmf/restjobs/jobs/{jn}/{ji}"
                                   f"/files/{key}/records").decode("latin-1"))
                # Write once, complete. A half-written file would look like a good
                # archive to anything that checks for existence.
                tmp = path + ".part"
                with open(tmp, "w", encoding="latin-1") as f:
                    f.write("".join(buf))
                os.replace(tmp, path)
            except Exception as e:
                print(f"  FEHLER {jn}/{ji}: {e}")
                failed += 1
                continue
            total += os.path.getsize(path)
            done += 1
            purged += purge(jn, ji, rc, path)
            if done % 20 == 0:
                print(f"  {done} neu, {skip} schon da, {purged} gepurged, "
                      f"{total/1e6:.1f} MB")

        print(f"\nneu {done}, schon vorhanden {skip}, gepurged {purged}, "
              f"fehler {failed}")
        print(f"Archiv {out}: {total/1e6:.1f} MB")
        return failed

    # One sweep, or a sweep every --loop seconds for as long as the chain
    # runs. Sweeping repeatedly is cheap: a job already on disk costs one
    # stat call, and only what is new gets read.
    rc = sweep()
    while a.loop:
        time.sleep(a.loop)
        print(f"\n--- {time.strftime('%H:%M:%S')} ---", flush=True)
        rc = sweep()
    return 1 if rc else 0


if __name__ == "__main__":
    sys.exit(main())
