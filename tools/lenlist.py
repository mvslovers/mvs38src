#!/usr/bin/env python3
"""The length-differing modules, smallest gap first — the block the byte ranking cannot see.

`worklist.py` ranks by differing bytes, and for the biggest remaining population
that number does not exist: where a CSECT is a different *size*, `cmplmd370`
reports no clusters at all. A full `fillgaps.py` sweep over the 3,686 modules that
were still open on 2026-09-13 recovered four, and **2,613 of its refusals were
`nothing fillable` with no reason** — no clusters to work from, because the length
differs.

So this is the same idea applied to the quantity those modules do have: **how many
bytes is our CSECT away from IBM's**, signed. A module two bytes short is an
afternoon; one fifteen hundred bytes short is a missing function. The gap between
those two has never been the sort key.

    lenlist.py [--out FILE] [--max-bytes 64] [--prefix IKJ]

Columns: module, our length, IBM's, the signed difference, and the bound module the
comparison used. Sorted by absolute difference.

**The `delta` column is IBM's length minus ours, so a positive difference means
IBM's CSECT is longer** — IBM's object carries something our source does not,
which is maintenance. Negative means our source emits code the object never had,
usually a `DSKnnnn` patch of Dave's. The two directions are different problems and
the sign says which.

This paragraph read the other way round until 2026-09-14, against the tool's own
`fh.write(f"...{b - o:+d}...")` two screens below and against its own stdout line
`ours shorter than IBM's`. Nothing downstream had used it —
`docs/what-is-left.md` states the correct direction — but it is exactly the kind
of inverted sign that turns a maintenance module into a Dave patch on sight.
"""
import argparse, collections, json, os, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
CM = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
DLIB = os.path.join(ROOT, "work/measurements/dlib-bytes/tk5")
TGT = os.path.join(ROOT, "work/measurements/target-bytes/tk5")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")


def lengths(deck, ref, csect=None):
    """(ours, theirs) for the named section, or None."""
    cmd = [CM, "--json"] + (["--csect", csect] if csect else []) + [deck, ref]
    q = subprocess.run(cmd, capture_output=True, text=True)
    if not q.stdout.strip():
        return None
    try:
        d = json.loads(q.stdout)
    except json.JSONDecodeError:
        return None
    for s in d.get("sections") or []:
        if csect and s.get("name") != csect:
            continue
        a, b = s.get("length_new"), s.get("length_ref")
        if a is not None and b is not None:
            return int(a), int(b)
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--decks", default=os.path.join(ROOT, "obj_overlay12"))
    ap.add_argument("--out", default=os.path.join(GATE, "lenlist.tsv"))
    ap.add_argument("--max-bytes", type=int, default=64)
    ap.add_argument("--prefix", default=None)
    a = ap.parse_args()

    tx = collections.defaultdict(list)
    for line in open(os.path.join(GATE, "org-tgt.txt"), encoding="latin-1"):
        f = line.split()
        if len(f) >= 5 and f[2] == "INCLUDE":
            tx[f[3]].append((f[0], f[1]))
    dlibof = {}
    for lib in sorted(os.listdir(DLIB)):
        d = os.path.join(DLIB, lib)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith(".bin"):
                    dlibof.setdefault(f[:-4], os.path.join(d, f))

    rows = [l.rstrip("\n").split("\t") for l in open(os.path.join(GATE, "overlay-vs-both.tsv"))]
    i = {k: n for n, k in enumerate(rows[0])}
    out = []
    for r in rows[1:]:
        mod = r[i["module"]]
        if a.prefix and not mod.startswith(a.prefix):
            continue
        if r[i["tgt_c"]] not in ("len-differs",) and r[i["dlib_c"]] not in ("len-differs",):
            continue
        deck = os.path.join(a.decks, mod + ".obj")
        if not os.path.exists(deck):
            continue
        best = None
        for lib, lmod in tx.get(mod, []):
            p = os.path.join(TGT, lib, lmod + ".bin")
            if os.path.exists(p):
                L = lengths(deck, p, mod)
                if L and (best is None or abs(L[0] - L[1]) < abs(best[0] - best[1])):
                    best = L + (f"{lib}({lmod})",)
        if best is None and mod in dlibof:
            L = lengths(deck, dlibof[mod])
            if L:
                best = L + ("DLIB",)
        if best and 0 < abs(best[0] - best[1]) <= a.max_bytes:
            out.append((abs(best[0] - best[1]), mod, best[0], best[1], best[2]))
    out.sort()

    with open(a.out, "w") as fh:
        fh.write("module\tours\tibm\tdelta\tmember\n")
        for _, mod, o, b, lm in out:
            fh.write(f"{mod}\t{o}\t{b}\t{b - o:+d}\t{lm}\n")
    print(f"{len(out)} modules within {a.max_bytes} bytes of IBM's length -> {a.out}")
    short = sum(1 for d, *_rest in out if _rest[1] < _rest[2])
    print(f"   ours shorter than IBM's: {short}   ours longer: {len(out) - short}")
    for d, mod, o, b, lm in out[:30]:
        print(f"   {mod:10s} {o:6d} vs {b:6d}  {b - o:+5d}  {lm}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
