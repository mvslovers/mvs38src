#!/usr/bin/env python3
"""Pull MVSSRC.BLD.AMVSSRC off MVSTK5-BLD, member by member, resumably.

Dave Kreiss designed his tree as an SMP-maintained source library, so "Dave's
source" names a library *and* a SYSMOD state.  The archive copy in
`MVSSRC/Dave Kreiss - MVS from Source/MVSBLD/` is one state; this is the state
after his own DSK SYSMODs went in during the build on MVSTK5-BLD -- the state
that actually produced the 2,756 matching CSECTs.

Read as text: the members are FB/80 and mvsMF hands them over already
translated.  Column 73-80 is the sequence number and is dropped at comparison
time, not here.
"""
import base64, http.client, os, sys, time

HOST, PORT, CRED = "mvsdev.lan", 8085, b"HERC01:CUL8TR"
DS = "MVSSRC.BLD.AMVSSRC"
OUT = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/amvssrc-tk5")
conn = [None]


def get(path, tries=5):
    for a in range(tries):
        try:
            if conn[0] is None:
                conn[0] = http.client.HTTPConnection(HOST, PORT, timeout=90)
            conn[0].request("GET", path, headers={
                "Authorization": "Basic " + base64.b64encode(CRED).decode()})
            r = conn[0].getresponse()
            b = r.read()
            if r.status == 200:
                return b
            if r.status == 404:
                return None
            raise RuntimeError(f"HTTP {r.status}")
        except Exception:
            try:
                conn[0].close()
            except Exception:
                pass
            conn[0] = None
            if a == tries - 1:
                raise
            time.sleep(min(20, 3 * (a + 1)))


def main():
    os.makedirs(OUT, exist_ok=True)
    mods = [m for m in open(sys.argv[1]).read().split() if m]
    got = skip = miss = 0
    empty = []
    t0 = time.time()
    for i, m in enumerate(mods, 1):
        p = os.path.join(OUT, m)
        if os.path.exists(p):
            skip += 1
            continue
        b = get(f"/zosmf/restfiles/ds/{DS}({m})")
        if b is None:
            miss += 1
            continue
        if not b:
            # An empty 200 is not an empty member.  mvsMF answers a read error
            # with HTTP 200 and no body -- the console says MVSMF106E I/O ERROR
            # READING and the REST client sees success.  100 members came back
            # like this on 2026-09-10 and were written as empty files; FTP
            # answered `451 Read error on data set after 0 bytes` for the same
            # ones, and IEHLIST said the volume had zero free tracks.
            #
            # So: never store one.  A member that is genuinely empty is
            # indistinguishable here, and that is the right trade -- a wrongly
            # kept empty file is a silent hole in a corpus, a wrongly reported
            # one is a line in a log.
            empty.append(m)
            continue
        open(p, "wb").write(b)
        got += 1
        if i % 250 == 0:
            print(f"  {i}/{len(mods)} got={got} skip={skip} miss={miss} "
                  f"{time.time()-t0:.0f}s", flush=True)
    print(f"{got} read, {skip} cached, {miss} absent, "
          f"{len(empty)} EMPTY-200 ({time.time()-t0:.0f}s)")
    if empty:
        print("  empty 200 (read error, not an empty member): " + " ".join(empty[:20]))
        open("/tmp/srcpull-empty.txt", "w").write("\n".join(empty))
    return 0


if __name__ == "__main__":
    sys.exit(main())
