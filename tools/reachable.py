#!/usr/bin/env python3
"""How many modules a per-module macro choice would reach — the second number.

The goal was reformulated on 2026-09-16: **every module explained, as many as
possible byte-identical.** The first verdict has a tool (`cmplmd370`, and
`scoreboard.py` counts it). The second needs one, and this is its first half.

**The strongest possible definition of "explained" is a testable one**: a module
is explained when it becomes byte-identical **under a named macro level we can
actually produce.** Not "the differences look accounted for" — identical, with
`cmplmd370` exiting 0, under one of a small set of named alternatives.

Five macros are measured two-level, and three have a reconstruction read out of
IBM's own objects: `XCTL`/`IHBINNRB`, `SETFRR`, `GETMAIN`/`FREEMAIN`
(`work/measurements/macro-reconstruct/`). Each was swept tree-wide, so for every
module we know whether it is identical under our macro or under that
reconstruction. **The union of those identical sets is what a per-module macro
path would deliver** — decision 5's mechanism, costed before it is built.

    reachable.py [--out FILE]

It reads the `*-vs-both.tsv` files the trials already produced. It does not
assemble anything and cannot, by construction, claim a module that no run proved.

**What it does NOT count.** A module whose differences are attributed to
`ESTAE`, `SCHEDULE`, `TSCBD`, `IEAPMNIP` or `STAX` is *named* but not
*reachable*: no reconstruction exists for those, so nothing can prove it. Those
belong to the third tier, "explained but blocked", and that tier needs the
attribution roll-up rather than this tool.
"""
import argparse, collections, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")

# The three trial gates used to be read out of ONE SESSION'S SCRATCHPAD, by
# absolute path. That is the `decks.py` / `macpath.py` defect in its purest form:
# a tool in the repository whose input lives somewhere no clone has, that nothing
# re-cuts when the comparator moves, and that disappears without a word when the
# session ends. Moved into the repository on 2026-09-16, when the cmplmd370
# re-pin made all four have to be re-cut together.
#
# The decks they are scored from are `obj_xctltrial2`, `obj_setfrrtrial` and
# `obj_gmtrial`. Re-cut all four with one command each when the comparator moves:
#   python3 tools/baseline_gate.py --decks obj_<trial> --out <the path below>
RECON = os.path.join(ROOT, "work/measurements/macro-reconstruct")

RUNS = [
    ("our macros (live)", os.path.join(GATE, "overlay-vs-both.tsv")),
    ("XCTL/IHBINNRB reconstructed", os.path.join(RECON, "xctl/xctltrial2-vs-both.tsv")),
    ("SETFRR reconstructed", os.path.join(RECON, "setfrr/setfrr-vs-both.tsv")),
    ("GETMAIN/FREEMAIN reconstructed", os.path.join(RECON, "gmtrial-vs-both.tsv")),
]


def identical_set(path):
    """The chosen-baseline identical set, by `scoreboard.chosen_baseline`'s rule.

    Target decides; DLIB only where a CSECT has no target counterpart; a target
    member `cmplmd370` cannot read counts as NOT identical even when the DLIB
    calls it identical -- that is an instrument gap and the count carries it.
    """
    rows = [l.rstrip("\n").split("\t") for l in open(path, encoding="utf-8")]
    i = {k: n for n, k in enumerate(rows[0])}
    out = set()
    for r in rows[1:]:
        if len(r) < len(rows[0]):
            continue
        t, dl = r[i["tgt_c"]], r[i["dlib_c"]]
        if t == "not-in-target":
            if dl == "identical":
                out.add(r[i["module"]])
        elif t in ("error", "unpaired", "no-ref"):
            pass
        elif t == "identical":
            out.add(r[i["module"]])
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(GATE, "reachable.tsv"))
    a = ap.parse_args()

    sets, missing = {}, []
    for name, path in RUNS:
        if os.path.exists(path):
            sets[name] = identical_set(path)
        else:
            missing.append((name, path))
    if missing:
        for name, path in missing:
            print(f"  MISSING: {name} -- {path}")
        print("  A trial sweep's measurement is gone; re-run it before quoting a "
              "figure, and do not fall back on the runs that remain.")
        return 1

    live = sets["our macros (live)"]
    union = set().union(*sets.values())
    print(f"{'run':34s} {'identical':>9s} {'adds':>6s}")
    for name in sets:
        print(f"  {name:34s} {len(sets[name]):9d} {len(sets[name] - live):6d}")
    print(f"\n  {'UNION -- per-module macro choice':34s} {len(union):9d} "
          f"{len(union) - len(live):6d}")

    lost = live - union
    assert not lost, f"a module identical live is missing from the union: {sorted(lost)}"

    with open(a.out, "w") as fh:
        fh.write("module\treachable_under\n")
        for m in sorted(union):
            where = [n for n, s in sets.items() if m in s]
            fh.write(f"{m}\t{'|'.join(where)}\n")
    print(f"\n-> {a.out}")

    only = collections.Counter()
    for m in union - live:
        where = [n for n, s in sets.items() if m in s and n != "our macros (live)"]
        only[" + ".join(sorted(where))] += 1
    print("\nwhat the additions need:")
    for k, n in only.most_common():
        print(f"   {k:44s} {n}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
