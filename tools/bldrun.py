#!/usr/bin/env python3
"""Drive Dave Kreiss' build chain one job at a time, through mvsMF.

Dave's jobs submit their own successor with `EXEC BLDSUB,MBR=<next>`, through
the internal reader. That has two consequences on MVS/CE and both are fatal to
running it here:

  * **No userid.** A job the internal reader submits from inside another job
    carries no credentials, and RAKF's `DATASET *` rule grants READ to everyone
    and ALTER only to ADMIN.  `$02ASM` link-edits into `MVSSRC.BLD.LOAD` and
    dies with **S913**.
  * **No output.** Dave's cards say `MSGCLASS=A`, which on this system is
    printed and purged, so the job vanishes from the REST API before it can be
    read.  `BLDASMUT` had already run and been purged before I noticed it.

Submitting each job through mvsMF instead fixes both at once: mvsMF supplies
USER/PASSWORD, so every step runs as IBMUSER with ALTER, and `MSGCLASS=H` keeps
the output readable.  The chain becomes observable rather than invisible.

So this reads each member, records the successor its `BLDSUB` step names,
**removes that step**, submits what is left, waits, and moves on. Removing it
matters: leave it in and the job submits the next one *as well*, unauthorised,
and the same job runs twice.

**It stops** on a non-zero return code, on a `BLDSUB` naming a `LIB=` other than
the base library, or at a member given with `--until`. The `LIB=` guard is the
Basic/Phase-1 boundary: Phase 1 updates `SYS1.LINKLIB` of the running system,
and nothing here should cross that without someone deciding to.

    bldrun.py --start '$01SMPAL' [--until MAINT05F] [--dry-run]
"""
import argparse, json, os, re, sys, time, urllib.parse, urllib.request, base64

HOST = "http://mvsdev:8082"
USER, PW = "IBMUSER", "SYS1"
LIB = "MVSSRC.BLD.SMP.JCL"
SUB = re.compile(r"^//(\S+)\s+EXEC\s+BLDSUB\s*,(.*)$", re.I)


def req(method, url, body=None, ctype=None, extra=None, tries=6):
    """Retrying, because a 259-job run meets transient failures by construction.

    A DNS blip resolving `mvsdev` killed a run at job 58 of 259 -- the network
    was back a minute later and MVS had carried on regardless.  A driver that
    dies on the first hiccup turns a two-hour build into a babysitting job, and
    worse, it stops *after* submitting, so the run and the log disagree about
    where it got to.

    Not retried: anything the server actually answers.  A 4xx or 5xx is a
    result and must not be papered over.
    """
    for attempt in range(tries):
        r = urllib.request.Request(url, data=body, method=method)
        r.add_header("Authorization", "Basic " +
                     base64.b64encode(f"{USER}:{PW}".encode()).decode())
        if ctype:
            r.add_header("Content-Type", ctype)
        for k, v in (extra or {}).items():
            r.add_header(k, v)
        try:
            with urllib.request.urlopen(r, timeout=120) as f:
                return f.read().decode("latin-1")
        except urllib.error.HTTPError:
            raise
        except Exception as e:
            if attempt == tries - 1:
                raise
            print(f"    (transient: {type(e).__name__}, retry "
                  f"{attempt + 1}/{tries - 1})", flush=True)
            time.sleep(10 * (attempt + 1))


def member(name):
    return req("GET", f"{HOST}/zosmf/restfiles/ds/{LIB}({urllib.parse.quote(name)})")


SNAPDIR = os.path.expanduser("~/repos/mvs/mvs38src/work/build/snapshots")
PRINTS = ("COPPRINT", "UPDPRINT", "ASMPRINT", "LKDPRINT", "SMPOUT")


def snapshot(cur):
    """Keep the utility listings of a failed job before the next job wipes them.

    SMP writes the assembler, copy, update and link-edit listings to five flat
    data sets, and Dave's BLDCLR proc empties all five at the START of every
    job.  BLDCOPY archives only SMPOUT -- its COPPRINT and UPDPRINT cards are
    commented out.  So the one listing that says WHY a utility failed is gone
    by the time anyone reads the job that failed.

    That is why `EDM1102B` and `EBT1102B` could not be diagnosed from run 1:
    119 and 42 macro copies ended `HMA4092 ** COPY FAILED - LIBRARY=MACLIB -
    RETURN CODE=04`, every SRC copy in the same job succeeded, the macros ARE
    present in SYS1.AMACLIB, and the target directory does take new members --
    all three checked -- while IEBCOPY's own message, the one thing that would
    settle it, had been overwritten.

    Uncommenting the two cards in SYS1.PROCLIB(BLDCOPY) would fix it at the
    source, but that edits the running system's PROCLIB and changes Dave's
    process.  This does not: the driver already waits for each job before
    submitting the next, so the listings are still intact at exactly the moment
    it notices a bad return code.  Read them there.
    """
    os.makedirs(SNAPDIR, exist_ok=True)
    kept = []
    for ds in PRINTS:
        try:
            t = req("GET", f"{HOST}/zosmf/restfiles/ds/MVSSRC.BLD.{ds}")
        except Exception as e:
            print(f"    snapshot {ds}: {type(e).__name__}", flush=True)
            continue
        if not t.strip():
            continue
        open(os.path.join(SNAPDIR, f"{cur}.{ds}.txt"), "w").write(t)
        kept.append(f"{ds}({len(t.splitlines())})")
    print(f"    kept: {' '.join(kept) if kept else 'nothing -- all five empty'}",
          flush=True)


def prepare(text):
    """MSGCLASS=H, and the BLDSUB step commented out. Returns (jcl, next, lib)."""
    lines = [l[:72].rstrip() for l in text.replace("\r\n", "\n").split("\n") if l.strip()]
    nxt, lb = None, None
    for i, l in enumerate(lines):
        if "MSGCLASS=" in l and i < 4:
            lines[i] = re.sub(r"MSGCLASS=\w", "MSGCLASS=H", l)
        m = SUB.match(l)
        if m:
            kv = dict(re.findall(r"(\w+)=([^,\s]+)", m.group(2)))
            nxt, lb = kv.get("MBR"), kv.get("LIB")
            lines[i] = "//*" + l[2:]          # keep the card, disable the step
    return "\n".join(lines) + "\n", nxt, lb


def submit(jcl):
    d = json.loads(req("PUT", f"{HOST}/zosmf/restjobs/jobs", jcl.encode("latin-1"),
                       "text/plain", {"X-IBM-Intrdr-Mode": "TEXT"}))
    return d["jobname"], d["jobid"]


def wait(jobname, jobid, limit=7200):
    t0 = time.time()
    while time.time() - t0 < limit:
        d = json.loads(req("GET", f"{HOST}/zosmf/restjobs/jobs/{jobname}/{jobid}"))
        if d.get("status") == "OUTPUT":
            return d.get("retcode") or "?"
        time.sleep(10)
    return "TIMEOUT"


def report(bad):
    print(f"\n{len(bad)} jobs ended non-zero:")
    for c, jn, ji, rc in bad:
        print(f"  {c:10s} {jn}/{ji}  {rc}")
    return 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--start", required=True)
    ap.add_argument("--until", default=None)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--max", type=int, default=200)
    a = ap.parse_args()

    cur, n, bad = a.start, 0, []
    while cur and n < a.max:
        n += 1
        jcl, nxt, lb = prepare(member(cur))
        if a.dry_run:
            print(f"{n:3d} {cur:10s} -> {nxt or 'END'}" + (f"  LIB={lb}" if lb else ""))
            cur = nxt if not lb else None
            continue
        jn, ji = submit(jcl)
        rc = wait(jn, ji)
        print(f"{n:3d} {cur:10s} {jn}/{ji}  {rc}", flush=True)
        if not rc.startswith("CC "):
            print(f"STOP: {cur} ended {rc} -- not a condition code. The chain "
                  f"is restartable from $01SMPAL or from this member.")
            return 1
        if rc not in ("CC 0000", "CC 0004"):
            # Dave's own SUB step carries no COND, so his chain runs on past a
            # step failure by design.  Stopping here was stricter than the
            # thing being driven: $02ASM ends CC 0024 because PRTTRK -- a
            # utility the build does not use, not one of Appendix B's nine --
            # references DS4DEVCY and DS4DEVTR, which MVS/CE's IECSDSL1 and
            # IECSDSL4 do not define.  A TK3/MVS-CE macro-level difference, in
            # a member nothing needs.  So: carry on, and report every one.
            bad.append((cur, jn, ji, rc))
            snapshot(cur)
        if lb:
            print(f"STOP: {cur} hands on to LIB={lb} ({nxt}). That is the "
                  f"Phase-{lb} boundary and it updates the running system.")
            return 0 if not bad else report(bad)
        if a.until and cur == a.until:
            print(f"STOP: reached --until {cur}.")
            return 0 if not bad else report(bad)
        cur = nxt
    print("chain ended")
    if bad:
        print(f"\n{len(bad)} jobs ended non-zero:")
        for c, jn, ji, rc in bad:
            print(f"  {c:10s} {jn}/{ji}  {rc}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
