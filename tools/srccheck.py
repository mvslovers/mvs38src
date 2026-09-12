#!/usr/bin/env python3
"""`src/` holds FINISHED source: every module there assembles byte-identical to
its TK5 distribution-library member. This checks it, and fails if it does not.

The criterion is the project's only one -- `cmplmd370` exits 0 -- and it needs a
guard because `src/` had no reader at all until 2026-09-12. Three of its 37
modules did not meet it:

  IKJRBBCM  repaired against MVS/CE, the baseline superseded on 2026-09-10.
            Dave's archive text is IDENTICAL against TK5 and ours differs by 3
            bytes -- the repair made the module worse against the chosen object.
  IDA019S4  content correct against TK5 after the repair (0 differing text
            bytes) but a section length still differs.
  IKJEHREN  one differing text byte closed, six hole bytes left in two other
            CSECTs -- real ones, see docs/ds-holes.md.

The last two are progress and belong in work/src-pending/ until they finish.
A tree called "finished" that contains unfinished work is worse than no tree.

    srccheck.py            check, print a table, exit 1 on any failure
    srccheck.py --quiet    exit code only
"""
import argparse, csv, glob, json, os, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from macpath import flags

BIN = os.path.join(ROOT, "work/src-states/bin/as370-main")
CM = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
TK5 = os.path.join(ROOT, "work/measurements/dlib-bytes/tk5")
STAMP = dict(ASMDATE="09/07/26", ASMTIME="12.00")


def library_of(mod):
    for lib in sorted(os.listdir(TK5)):
        if os.path.exists(os.path.join(TK5, lib, mod + ".bin")):
            return lib
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--quiet", action="store_true")
    a = ap.parse_args()
    if not os.path.exists(BIN):
        sys.exit(f"{BIN}: no pinned as370 -- see work/src-states/bin/PROVENANCE.txt")

    tmp = os.path.join(ROOT, "work/measurements/srccheck")
    os.makedirs(tmp, exist_ok=True)
    bad, ok = [], 0
    for p in sorted(glob.glob(os.path.join(ROOT, "src", "*", "*.ASM"))):
        mod = os.path.basename(p)[:-4]
        lib = library_of(mod)
        if lib is None:
            bad.append((mod, "no TK5 member to compare against"))
            continue
        obj = os.path.join(tmp, mod + ".obj")
        subprocess.run([BIN] + flags() + ["-o", obj, p],
                       capture_output=True, env=dict(os.environ, **STAMP))
        if not os.path.exists(obj):
            bad.append((mod, "did not assemble"))
            continue
        q = subprocess.run([CM, "--json", obj,
                            os.path.join(TK5, lib, mod + ".bin")],
                           capture_output=True, text=True)
        try:
            d = json.loads(q.stdout)
        except json.JSONDecodeError:
            bad.append((mod, "cmplmd370 produced no verdict"))
            continue
        if d.get("identical"):
            ok += 1
            continue
        t = sum(s.get("diff_in_text") or 0 for s in d.get("sections") or [])
        h = sum(s.get("diff_in_holes") or 0 for s in d.get("sections") or [])
        ln = any(s.get("length_differs") for s in d.get("sections") or [])
        bad.append((mod, f"text={t} holes={h}" + (" length differs" if ln else "")))

    if not a.quiet:
        print(f"src/: {ok + len(bad)} modules, {ok} byte-identical to TK5")
        for m, why in bad:
            print(f"  FAILS  {m:10s} {why}")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
