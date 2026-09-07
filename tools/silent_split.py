#!/usr/bin/env python3
"""Rank the silent divergences by which assembler matches IBM's shipped object.

699 of the 1,242 modules handed to cc370 are *silent divergences*: both
assemblers assemble without a word and the decks differ anyway. No diagnostic
points at them, and they are the majority of the remaining work -- an assembler
is trustworthy where nothing complains, or it is not trustworthy.

Every one of them has an object in a distribution library, so there is a third
opinion available. Asking it splits the class four ways:

    IFOX00 matches, as370 does not   the sharpest cases. IFOX00's deck is
                                     confirmed correct by IBM independently, so
                                     the divergence is as370's and fixing it is
                                     an immediate recovery.
    neither matches                  still as370's case -- the hand-over rule is
                                     as370 != IFOX00 and at rc 0 IFOX00 remains
                                     the oracle -- but there is no recovery
                                     behind it. Lower rank, not removed.
    as370 matches, IFOX00 does not   an anomaly in the oracle. Read before acting.
    both match                       impossible while the decks differ; if it
                                     appears, the comparison is wrong.

**This ranks the list. It does not shrink it.** A figure that quietly loses rows
stops being checkable, and the modules where neither assembler reproduces IBM's
object are exactly the ones where a maintenance-level question hides behind a
tooling one.

    silent_split.py [--all]      # --all: every module, not just the 699
"""
import json, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
DLIB = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/dlib")
DECKS = f"{RUN}/decks"


def dlib_index():
    ix = {}
    for root, _, fs in os.walk(DLIB):
        for f in fs:
            if f.endswith(".dlib"):
                ix[f[:-5]] = os.path.join(root, f)
    return ix


def verdict(args):
    """cmplmd370's reading of one deck against one distribution member."""
    m, obj, ref = args
    p = subprocess.run(["cmplmd370", "--json", obj, ref],
                       capture_output=True, text=True)
    try:
        r = json.loads(p.stdout)
    except Exception:
        return m, "error"
    if p.returncode == 0 or r.get("identical"):
        return m, "identical"
    v = {s.get("verdict") for s in (r.get("sections") or [])}
    if not v:
        return m, "no-section"
    for k in ("length", "mixed", "text", "holes"):        # worst wins
        if k in v:
            return m, k
    return m, "|".join(sorted(v))


def main():
    every = "--all" in sys.argv
    head = open(f"{RUN}/module-table.tsv").readline().rstrip("\n").split("\t")
    H = {h: i for i, h in enumerate(head)}
    rows = [l.split("\t") for l in
            open(f"{RUN}/module-table.tsv").read().splitlines()[1:]]

    # as370's own verdict against the distribution libraries, already measured
    a370 = {}
    for l in open(f"{RUN}/verdicts.tsv").read().splitlines()[1:]:
        f = l.split("\t")
        a370[f[0]] = f[5]

    sel = [r for r in rows if every or
           (r[H["signal"]] == "silent divergence" and r[H["owner"]] == "cc370"
            and not r[H["excluded"]])]
    ix = dlib_index()
    work = [(r[0], f"{DECKS}/{r[0]}.obj", ix[r[0]]) for r in sel
            if r[0] in ix and os.path.exists(f"{DECKS}/{r[0]}.obj")]
    print(f"{len(sel)} modules selected, {len(work)} with both an IFOX00 deck "
          f"and a distribution member")

    iv = {}
    with ThreadPoolExecutor(8) as ex:
        for m, v in ex.map(verdict, work):
            iv[m] = v

    cells = {}
    out = f"{RUN}/silent-split.tsv"
    with open(out, "w") as f:
        f.write("module\tifox_vs_dlib\tas370_vs_dlib\tcell\tfirst_diff"
                "\tlen_ifox\tlen_as370\tas370_dlib_verdict\n")
        for r in sel:
            m = r[0]
            i, a = iv.get(m, "no-pair"), a370.get(m, "no-pair")
            if i == "identical" and a == "identical":
                c = "both match -- impossible, check the comparison"
            elif i == "identical":
                c = "IFOX00 matches IBM, as370 does not"
            elif a == "identical":
                c = "as370 matches IBM, IFOX00 does not"
            elif "no-pair" in (i, a):
                c = "no distribution member"
            else:
                c = "neither matches IBM"
            cells[c] = cells.get(c, 0) + 1
            f.write("\t".join([m, i, a, c, r[H["first_diff"]],
                               r[H["len_ifox"]], r[H["len_as370"]],
                               r[H["dlib"]]]) + "\n")

    for c, n in sorted(cells.items(), key=lambda x: -x[1]):
        print(f"  {n:5d}  {c}")
    print(f"\n{out}")


if __name__ == "__main__":
    main()
