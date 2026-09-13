#!/usr/bin/env python3
"""How far apart are TK5's two object baselines?  No source involved.

Dave Kreiss says the target libraries, not the DLIBs, are what the running
system uses and that the two are out of step because not all maintenance was
ACCEPTed.  Every host-side figure in this project was measured against the
DLIBs, so the size of that gap decides whether any of them has to be re-read.

This measures it without a deck, an assembler or a source tree in the way: the
CSECT lengths IBM's own libraries report, target side against distribution side,
out of `LMDXRF38`'s extracts.

**A length difference is a proof; a length match is not.**  Two CSECTs of equal
length can still hold different bytes -- that is `CSECTs don't match` in Dave's
report and it is the commonest class there.  So what comes out of this is a
LOWER BOUND on how far apart the baselines are, and `baseline_gate.py` is what
closes it by comparing the bytes.

**The control has a known answer.**  Dave's build APPLYs and ACCEPTs the same
object, so its own two sides -- `NEW.TGT` against `NEW.DLIB` -- must agree
almost everywhere.  Where they do not, the class shows up in the measurement
too and can be subtracted rather than argued about.  If that control ever
reports a large number, the instrument is reading library structure rather than
maintenance level and the measurement below means nothing.

    xref_distance.py [--tsv work/measurements/baseline-gate/distance.tsv]
"""
import argparse, collections, os, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")


def xref(name):
    """csect -> {(library, lmod, length)}; a name in several bound modules keeps
    all of them, because dropping one would hide a fan-out as a match."""
    m = collections.defaultdict(set)
    for line in open(os.path.join(GATE, name), encoding="latin-1"):
        f = line.split()
        if len(f) >= 5 and f[2] == "INCLUDE":
            m[f[3]].add((f[0], f[1], f[4]))
    if not m:
        sys.exit(f"{name}: no INCLUDE records")
    return m


def compare(tgt, dlib):
    """(same, differing, only_tgt, only_dlib, ambiguous) over the shared names."""
    same, diff, amb = [], [], []
    for c in sorted(set(tgt) & set(dlib)):
        tl = {x[2] for x in tgt[c]}
        dl = {x[2] for x in dlib[c]}
        if len(tl) > 1 or len(dl) > 1:
            amb.append(c)
        elif tl == dl:
            same.append(c)
        else:
            diff.append((c, sorted(tgt[c])[0][0], sorted(tgt[c])[0][1],
                         dl.pop(), tl.pop()))
    return same, diff, sorted(set(tgt) - set(dlib)), sorted(set(dlib) - set(tgt)), amb


def report(label, tgt, dlib):
    same, diff, ot, od, amb = compare(tgt, dlib)
    n = len(same) + len(diff) + len(amb)
    print(f"### {label}")
    print(f"  CSECT names, target side      {len(tgt)}")
    print(f"  CSECT names, distribution     {len(dlib)}")
    print(f"  in both, one length each      {len(same) + len(diff)}")
    print(f"    same length                 {len(same)}")
    print(f"    LENGTH DIFFERS              {len(diff)}"
          f"   ({100 * len(diff) / max(1, len(same) + len(diff)):.1f} %)")
    print(f"  in both, several lengths       {len(amb)}")
    print(f"  target side only              {len(ot)}")
    print(f"  distribution side only        {len(od)}")
    return diff


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tsv", default=os.path.join(GATE, "distance.tsv"))
    a = ap.parse_args()
    nt, nd = xref("new-tgt.txt"), xref("new-dlib.txt")
    ot, od = xref("org-tgt.txt"), xref("org-dlib.txt")
    ctl = report("CONTROL -- the build's own two sides (NEW target vs NEW DLIB)",
                 nt, nd)
    print()
    real = report("MEASURED -- TK5's own two sides (ORG target vs ORG DLIB)",
                  ot, od)
    known = {c for c, *_ in ctl}
    print(f"\n  of the {len(real)} differing, {sum(1 for c, *_ in real if c in known)} "
          f"also differ on the build's two sides -- structural, not maintenance")
    with open(a.tsv, "w") as fh:
        fh.write("csect\ttgt_lib\ttgt_lmod\tdlib_len\ttgt_len\tdelta\tin_control\n")
        for c, lib, lmod, dl, tl in sorted(real):
            fh.write(f"{c}\t{lib}\t{lmod}\t{dl}\t{tl}\t"
                     f"{int(tl, 16) - int(dl, 16):+d}\t{'Y' if c in known else 'N'}\n")
    print(f"  -> {a.tsv}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
