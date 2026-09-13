#!/usr/bin/env python3
"""Bring Dave's `LMDXRF38` cross-references across from MVSTK5-BLD.

`baseline_gate.py` needs to know which bound module a CSECT lives in, because a
target-library member is named after the load module and not after its
contents -- `IKJEFD31` is inside `CMDLIB(ALLOCATE)`, and nothing in the member
name says so.

That map already exists and nobody here built it.  Dave's build runs `LMDXRF38`
over every library on both sides and leaves four sequential data sets behind:

    MVSSRC.BLD.ORG.LMDXRF.TGT    IBM's target libraries    -> org-tgt.txt
    MVSSRC.BLD.ORG.LMDXRF.DLIB   IBM's DLIBs               -> org-dlib.txt
    MVSSRC.BLD.NEW.LMDXRF.TGT    the build's targets       -> new-tgt.txt
    MVSSRC.BLD.NEW.LMDXRF.DLIB   the build's DLIBs         -> new-dlib.txt

One record per (library, LMOD, 'INCLUDE', CSECT, length, offset, decimal
offset), so `ORG.TGT` against `ORG.DLIB` is a source-independent measurement of
how far the two baselines are apart, and `NEW.TGT` against `NEW.DLIB` is its
control -- the build APPLYs and ACCEPTs the same object, so those two must
agree.

**Read from BLD, not from the oracle, and that is not laziness.**  These data
sets are output of Dave's build chain and only exist there.  The bytes that get
compared are pulled from `MVSTK5-REF` by `dlibpull.py`; this is the map, not the
evidence.  The `ORG` extracts were cut on 2026-09-11, before anything in this
project wrote to a SYS1 library on BLD -- `MAINT05Z` is the one job that would,
and it has not run.  If it ever does, re-cut these on a system whose SYS1
libraries are still IBM's.

    fetch_xref.py [--system MVSTK5-BLD]
"""
import argparse, base64, http.client, json, os, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from creds import cred

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
OUT = os.path.join(ROOT, "work/measurements/baseline-gate")
SETS = {"MVSSRC.BLD.ORG.LMDXRF.TGT": "org-tgt.txt",
        "MVSSRC.BLD.ORG.LMDXRF.DLIB": "org-dlib.txt",
        "MVSSRC.BLD.NEW.LMDXRF.TGT": "new-tgt.txt",
        "MVSSRC.BLD.NEW.LMDXRF.DLIB": "new-dlib.txt"}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--system", default="MVSTK5-BLD")
    a = ap.parse_args()
    sysj = json.load(open(os.path.join(os.path.dirname(
        os.path.abspath(__file__)), "systems.json")))["systems"]
    if a.system not in sysj:
        sys.exit(f"{a.system}: not in systems.json ({', '.join(sysj)})")
    cfg = sysj[a.system]
    auth = "Basic " + base64.b64encode(cred(a.system).encode()).decode()
    c = http.client.HTTPConnection(cfg["host"], cfg["mvsmf"], timeout=90)
    os.makedirs(OUT, exist_ok=True)
    man = {"system": a.system, "endpoint": f"http://{cfg['host']}:{cfg['mvsmf']}",
           "sets": {}}
    rc = 0
    for dsn, name in SETS.items():
        c.request("GET", f"/zosmf/restfiles/ds/{dsn}", headers={"Authorization": auth})
        r = c.getresponse()
        body = r.read()
        if r.status != 200:
            print(f"{dsn}: HTTP {r.status}")
            man["sets"][dsn] = {"status": r.status}
            rc = 1
            continue
        open(os.path.join(OUT, name), "wb").write(body)
        n = len(body.decode("latin-1").splitlines())
        print(f"{dsn} -> {name}  {n} records")
        man["sets"][dsn] = {"status": 200, "file": name, "records": n}
    json.dump(man, open(os.path.join(OUT, "xref-manifest.json"), "w"), indent=2)
    return rc


if __name__ == "__main__":
    sys.exit(main())
