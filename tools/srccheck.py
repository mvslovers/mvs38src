#!/usr/bin/env python3
"""`src/` holds FINISHED source: every module there assembles byte-identical to
TK5's object. This checks it, and fails if it does not.

**2026-09-13: TK5 has two object baselines and they are not the same object.**
Mike chose *target primary, DLIB as the fallback*, after
[`docs/baseline-dlib-vs-target.md`](../docs/baseline-dlib-vs-target.md) measured
them 167 verdicts apart. So this guard now asks both, and the rule it enforces is:

    every module in src/ is byte-identical to AT LEAST ONE of TK5's two
    object baselines, and the table says which.

**It is deliberately not "identical to the target".** For six modules the two
baselines hold genuinely different object, so no single source can reach both --
`IKJEBEUN IKJEFD35 IKJEFE16 IKJEFF02 IKJEFF50 IKJEGMSG`, all six identical to
the DLIB member and none to the target. Failing them would delete work that is
correct against a real IBM object and put nothing in its place; the honest
place for that fact is the *count*, and `scoreboard.py` already reports it -- the
project figure under the chosen baseline is 1,197, and these six are not in it.
A guard that turns red for a module nobody can currently fix stops being read.

The criterion is still the project's only one -- `cmplmd370` exits 0 -- and it
needed a guard because `src/` had no reader at all until 2026-09-12. Three of its
37 modules did not meet it:

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
    srccheck.py --strict   require the CHOSEN baseline, not either one
"""
import argparse, collections, glob, json, os, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from macpath import flags

BIN = os.path.join(ROOT, "work/src-states/bin/as370-main")
CM = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
TK5 = os.path.join(ROOT, "work/measurements/dlib-bytes/tk5")
TGT = os.path.join(ROOT, "work/measurements/target-bytes/tk5")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")
STAMP = dict(ASMDATE="09/07/26", ASMTIME="12.00")


def library_of(mod):
    for lib in sorted(os.listdir(TK5)):
        if os.path.exists(os.path.join(TK5, lib, mod + ".bin")):
            return lib
    return None


def target_map():
    """csect -> [(library, lmod)], from LMDXRF38's extract of IBM's targets."""
    m = collections.defaultdict(list)
    p = os.path.join(GATE, "org-tgt.txt")
    if not os.path.exists(p):
        return m
    for line in open(p, encoding="latin-1"):
        f = line.split()
        if len(f) >= 5 and f[2] == "INCLUDE":
            m[f[3]].append((f[0], f[1]))
    return m


def identical(obj, ref, csect=None):
    """(True/False, why-not).  A missing reference is not a verdict."""
    if not os.path.exists(ref):
        return None, "no reference member"
    cmd = [CM, "--json"] + (["--csect", csect] if csect else []) + [obj, ref]
    q = subprocess.run(cmd, capture_output=True, text=True)
    try:
        d = json.loads(q.stdout)
    except json.JSONDecodeError:
        return None, "cmplmd370 produced no verdict"
    if d.get("identical"):
        return True, ""
    secs = d.get("sections") or []
    if not secs:
        return None, "no section paired"
    t = sum(s.get("diff_in_text") or 0 for s in secs)
    h = sum(s.get("diff_in_holes") or 0 for s in secs)
    ln = any(s.get("length_differs") for s in secs)
    return False, f"text={t} holes={h}" + (" length differs" if ln else "")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--quiet", action="store_true")
    ap.add_argument("--strict", action="store_true",
                    help="require the chosen baseline (target where one exists), "
                         "not merely one of the two")
    a = ap.parse_args()
    if not os.path.exists(BIN):
        sys.exit(f"{BIN}: no pinned as370 -- see work/src-states/bin/PROVENANCE.txt")

    tmap = target_map()
    tmp = os.path.join(ROOT, "work/measurements/srccheck")
    os.makedirs(tmp, exist_ok=True)
    bad, rows = [], []
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
        dok, dwhy = identical(obj, os.path.join(TK5, lib, mod + ".bin"))
        tok, twhy = None, "no target counterpart"
        for tlib, tlmod in tmap.get(mod, []):
            r, w = identical(obj, os.path.join(TGT, tlib, tlmod + ".bin"), mod)
            if r:
                tok, twhy = True, ""
                break
            if tok is None:
                tok, twhy = r, w
        rows.append((mod, dok, tok, dwhy, twhy))
        # The chosen baseline is the target where one exists, the DLIB otherwise.
        chosen = tok if mod in tmap else dok
        if a.strict:
            if chosen is not True:
                bad.append((mod, f"chosen baseline: {twhy if mod in tmap else dwhy}"))
        elif dok is not True and tok is not True:
            bad.append((mod, f"neither baseline -- dlib: {dwhy}; target: {twhy}"))

    if not a.quiet:
        both = sum(1 for _, d, t, *_ in rows if d and t)
        donly = sum(1 for m, d, t, *_ in rows if d and not t and m in tmap)
        notgt = sum(1 for m, d, t, *_ in rows if d and m not in tmap)
        tonly = sum(1 for _, d, t, *_ in rows if t and not d)
        print(f"src/: {len(rows) + len(bad)} modules")
        print(f"  identical to BOTH baselines                 {both}")
        print(f"  identical to the DLIB, no target counterpart {notgt}")
        print(f"  identical to the DLIB only, target differs   {donly}"
              f"   <- counted as not recovered under the chosen baseline")
        print(f"  identical to the target only                 {tonly}")
        for m, d, t, dw, tw in rows:
            if d and not t and m in tmap:
                print(f"    {m:10s} target: {tw}")
        for m, why in bad:
            print(f"  FAILS  {m:10s} {why}")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
