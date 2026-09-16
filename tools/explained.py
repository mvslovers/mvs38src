#!/usr/bin/env python3
"""The second verdict, counted: how many modules are EXPLAINED.

The goal was reformulated on 2026-09-16 — *every module explained, as many as
possible byte-identical*. `scoreboard.py` counts the first verdict. This counts
the second, and the whole difficulty is keeping it a measurement rather than a
reading.

## What "explained" is allowed to mean

A module is explained when **every** differing byte is attributed to a named,
accepted class and **none** is left over. Four tiers, strictest first:

| | |
|---|---|
| `recovered` | `cmplmd370` exits 0 today |
| `reachable` | identical under a named macro reconstruction we can produce — proved by a tree-wide sweep, `reachable.tsv` |
| `blocked` | every differing byte owned by a **named wrong-level macro**, or by alignment fill — attributed, but no reconstruction exists so nothing can prove it |
| `unexplained` | anything left |

**`blocked` is the tier that could rot, so its rule is narrow on purpose.**

- *Equal length* (`macroattr.tsv`): every differing cluster must be owned by a
  macro on the named list, with **no open-code cluster at all**. One differing
  byte in open code and the module is unexplained, however obvious its cause
  looks.
- *Length differs* (`lenattr.tsv`): every **length-changing run** must be owned by
  a named macro. The displacement shifts that follow are then consequences of an
  attributed cause and are not counted separately — which is the one inference
  this tool makes, and it is stated here rather than buried.
- *Alignment fill* (`alignfill.tsv`): the 44 modules whose every difference sits
  in a `DC 0X` gap. Not a source defect; measured, cause still open.

**What is deliberately NOT a class**: "a displacement shifted and we can see why"
in an equal-length module. At equal length there is no net insertion, so a shift
means two compensating errors, and accepting it would let judgement in. Those
modules count as unexplained.

    explained.py [--out FILE]

It reads measurements and assembles nothing, so it cannot claim a module no run
produced. Where an input is missing it says so and stops rather than reporting a
smaller number as if it were the answer.
"""
import argparse, collections, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")

# The macros measured to exist at a level we do not have. A name is on this list
# only when a document says how it was measured -- macro-attribution.md for the
# first five, missing-macros.md for the rest.
WRONG_LEVEL = {"XCTL", "IHBINNRB", "SETFRR", "GETMAIN", "FREEMAIN",
               "ESTAE", "SCHEDULE", "IEAPMNIP", "TSCBD", "STAX"}


def need(path, what):
    if not os.path.exists(path):
        sys.exit(f"missing: {path}\n  ({what}) -- re-run it before quoting a figure")
    return path


def rows(path):
    r = [l.rstrip("\n").split("\t") for l in open(path, encoding="utf-8")]
    return r[0], r[1:]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(GATE, "explained.tsv"))
    a = ap.parse_args()

    # the population and today's verdict
    hdr, rs = rows(need(os.path.join(GATE, "overlay-vs-both.tsv"), "baseline_gate.py"))
    i = {k: n for n, k in enumerate(hdr)}
    pop, recovered = [], set()
    for r in rs:
        if len(r) < len(hdr):
            continue
        m = r[i["module"]]
        pop.append(m)
        t, dl = r[i["tgt_c"]], r[i["dlib_c"]]
        if t == "not-in-target":
            if dl == "identical":
                recovered.add(m)
        elif t in ("error", "unpaired", "no-ref"):
            pass
        elif t == "identical":
            recovered.add(m)

    reach = {l.split("\t")[0] for l in
             open(need(os.path.join(GATE, "reachable.tsv"), "tools/reachable.py"))} - {"module"}
    align = {l.split("\t")[0] for l in
             open(need(os.path.join(GATE, "alignfill.tsv"), "tools/alignfill.py"))} - {"module"}

    # equal-length attribution
    blocked_eq = set()
    hdr2, rs2 = rows(need(os.path.join(GATE, "macroattr.tsv"), "tools/macroattr.py"))
    for r in rs2:
        if len(r) < 5:
            continue
        mod, verdict, mac, opn, calls = r[0], r[1], r[2], r[3], r[4]
        if verdict != "all in macro expansions":
            continue
        names = {c.split(":")[0] for c in calls.split() if c}
        if names and names <= WRONG_LEVEL:
            blocked_eq.add(mod)

    # length-differing attribution: every length-changing run on the named list
    owners = collections.defaultdict(set)
    verd = {}
    hdr3, rs3 = rows(need(os.path.join(GATE, "lenattr.tsv"), "tools/lenattr.py"))
    for r in rs3:
        if len(r) < 6:
            continue
        verd[r[0]] = r[1]
        if r[2]:
            owners[r[0]].add(r[5])
    blocked_len = {m for m, o in owners.items()
                   if verd.get(m) == "all in macro expansions" and o and o <= WRONG_LEVEL}

    blocked = (blocked_eq | blocked_len | align) - recovered - reach
    explained = recovered | reach | blocked
    unexplained = set(pop) - explained

    tiers = [("recovered -- cmplmd370 exits 0", recovered),
             ("reachable -- identical under a named reconstruction", reach - recovered),
             ("blocked   -- attributed, no reconstruction exists", blocked),
             ("unexplained", unexplained)]
    n = len(pop)
    print(f"{n} CSECTs under the chosen baseline\n")
    for name, s in tiers:
        print(f"  {name:52s} {len(s):5d}   {len(s)/n:5.1%}")
    print(f"\n  {'EXPLAINED -- the second verdict':52s} {len(explained):5d}   "
          f"{len(explained)/n:5.1%}")

    with open(a.out, "w") as fh:
        fh.write("module\ttier\n")
        for name, s in tiers:
            tag = name.split()[0]
            for m in sorted(s):
                fh.write(f"{m}\t{tag}\n")
    print(f"\n-> {a.out}")
    print(f"\n  of the blocked: {len(align - recovered - reach)} alignment fill, "
          f"{len(blocked_eq - align - recovered - reach)} equal-length macro, "
          f"{len(blocked_len - align - blocked_eq - recovered - reach)} length macro")
    return 0


if __name__ == "__main__":
    sys.exit(main())
