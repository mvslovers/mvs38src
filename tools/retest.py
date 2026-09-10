#!/usr/bin/env python3
"""Measure an as370 change against the stored IFOX00 decks. No MVS needed.

The 5,528 decks the real Assembler XF produced on 2026-09-07 are a fixed
reference: same source, same macro libraries, recorded once. So a change to
`as370` is measured by assembling the tree again here and comparing against
them -- ten minutes, entirely local.

    tools/gate.sh /path/to/new-as370 mylabel     # writes obj_mylabel/
    tools/retest.py obj_mylabel [--baseline DIR]

Reports what moved, in both directions. A change that gains ten agreements and
loses three has gained seven and broken three, and both halves have to be said.

The agreement figure here is **3,465**, one below the 3,466 in
That is not a discrepancy: `ifox_compare.py` re-assembles
every differing module with the date and time its IFOX run used, and exactly one
module of 1,334 needs that to match. This tool does not, because a gate wants a
figure it can compute in ten minutes.
"""
import argparse, os, sys

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
IFOX = f"{RUN}/decks"


def body(path):
    d = open(path, "rb").read()
    return [d[i:i + 72] for i in range(0, len(d), 80)
            if d[i + 1:i + 4] != b"\xc5\xd5\xc4"]          # END excluded


def _image(path):
    """{address: byte} per control section, rebuilt from the TXT cards.

    Keyed by address and by section name, not by card: a deck's cards are an
    encoding, not the object. Two decks can hold the same bytes in a different
    number of cards, and a hole is an absence rather than a zero.
    """
    import collections
    names, img = {}, collections.defaultdict(dict)
    d = open(path, "rb").read()
    for i in range(0, len(d), 80):
        c = d[i:i + 80]
        if c[1:4] == b"\xc5\xe2\xc4":                   # ESD
            esdid = int.from_bytes(c[14:16], "big")
            n = int.from_bytes(c[10:12], "big") or 16
            for k in range(16, 16 + n, 16):
                item = c[k:k + 16]
                if len(item) < 16:
                    break
                if item[8] == 0x01:                        # LD carries no ESDID
                    continue
                nm = item[:8].decode("cp037").strip()
                if nm:
                    names[esdid] = nm
                esdid += 1
        elif c[1:4] == b"\xe3\xe7\xe3":                  # TXT
            adr = int.from_bytes(c[5:8], "big")
            ln = int.from_bytes(c[10:12], "big")
            esdid = int.from_bytes(c[14:16], "big")
            for j in range(ln):
                img[esdid][adr + j] = c[16 + j]
    return {names.get(e, f"#{e}"): v for e, v in img.items()}


def distance(a, b):
    """How many bytes of the object are wrong, not merely whether any are.

    A verdict count cannot see a change that leaves a module non-identical and
    moves it closer to -- or further from -- IFOX00. cc370 measured exactly that
    on #168 and the idea is theirs.

    Measured on the section image, after their correction on #171: a card-based
    walk charges a whole card for a card-count difference, so a fix that gives a
    section its CORRECT length reads as a large regression. IFNX4S went 0x196 ->
    0x1ad, which is IFOX00's own length, and the card measure scored it +71 while
    the image shows 402 wrong bytes falling to 382.
    """
    if not (os.path.exists(a) and os.path.exists(b)):
        return None
    x, y = _image(a), _image(b)
    n = 0
    for sec in set(x) | set(y):
        p, q = x.get(sec, {}), y.get(sec, {})
        for off in set(p) | set(q):
            if p.get(off) != q.get(off):
                n += 1
    return n


def seclen(path):
    """{section name: declared length} from the ESD cards.

    The third instrument, and for some changes the only honest one. Widening a
    field changes macro expansion, expansion changes layout, and a block that is
    correct but displaced scores as entirely wrong when bytes are compared at a
    fixed address. A section's declared length cannot be faked by a shift.
    cc370 found this on #174, where the byte measures called 24 decks worse and
    the lengths called 136 of them right for the first time.
    """
    out, names = {}, {}
    d = open(path, "rb").read()
    for i in range(0, len(d), 80):
        c = d[i:i + 80]
        if c[1:4] != b"\xc5\xe2\xc4":
            continue
        esdid = int.from_bytes(c[14:16], "big")
        n = int.from_bytes(c[10:12], "big") or 16
        for k in range(16, 16 + n, 16):
            item = c[k:k + 16]
            if len(item) < 16:
                break
            if item[8] == 0x01:                       # LD: no ESDID, no length
                continue
            nm = item[:8].decode("cp037").strip()
            if item[8] in (0x00, 0x04, 0x05) and nm:  # SD / PC / CM
                out[nm] = int.from_bytes(item[13:16], "big")
            esdid += 1
    return out


def verdict(a, b):
    if not os.path.exists(a):
        return "no-as370-deck"
    if not os.path.exists(b):
        return "no-ifox-deck"
    x, y = body(a), body(b)
    if len(x) != len(y):
        return "cards"
    return "identical" if x == y else "bytes"


def rcmap(tsv):
    """{module: severity} from a gate run's tsv, or from IFOX00's state.tsv."""
    out = {}
    for line in open(tsv):
        f = line.rstrip("\n").split("\t")
        if len(f) < 2 or f[0] == "module":
            continue
        v = f[1].strip()
        if v.lstrip("-").isdigit():
            out[f[0]] = int(v)
    return out


def rcverdict(a, b):
    """Do the two assemblers agree about whether the module is clean?

    Not the exact number -- IFOX00 counts in multiples of four and a severity
    is a severity. `as370 == IFOX00` has always meant the deck; on 2026-09-09
    Mike pointed out that it has to mean the RETURN CODE too, and the measure
    below is why that is not a detail: 151 modules disagree and 124 of them
    have a byte-identical deck, so every deck-based figure in this repository
    calls them finished.
    """
    clean_a, clean_b = a is not None and a <= 4, b is not None and b <= 4
    if clean_a == clean_b:
        return "agree"
    return "as370 alone flags" if not clean_a else "IFOX00 alone flags"


def measure(objdir, mods):
    return {m: verdict(f"{objdir}/{m}.obj", f"{IFOX}/{m}.obj") for m in mods}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("objdir")
    ap.add_argument("--baseline", default=f"{RUN}/as370",
                    help="the as370 decks the recorded figures come from")
    ap.add_argument("--out", default=None)
    ap.add_argument("--rc", default=None, metavar="TSV",
                    help="the gate run's own tsv, to compare return codes as "
                         "well as decks (default: <objdir minus 'obj_'>.tsv)")
    a = ap.parse_args()

    mods = sorted(f[:-4] for f in os.listdir(IFOX) if f.endswith(".obj"))

    # An unfinished gate run is indistinguishable from a catastrophic
    # regression: read while gate.sh was still working, this tool once reported
    # 1,268 identities lost, and every one of them was a deck not yet written.
    have = sum(1 for m in mods if os.path.exists(f"{a.objdir}/{m}.obj"))
    base = sum(1 for m in mods if os.path.exists(f"{a.baseline}/{m}.obj"))
    if have < base - 5:
        sys.exit(f"{a.objdir} holds {have} decks against the baseline's {base}. "
                 f"Wait for gate.sh to finish -- a partial run reads as a "
                 f"regression and there is no way to tell from the numbers.")

    new = measure(a.objdir, mods)
    old = measure(a.baseline, mods)

    gained = [m for m in mods if new[m] == "identical" != old[m]]
    lost = [m for m in mods if old[m] == "identical" != new[m]]
    moved = [m for m in mods if old[m] == "cards" and new[m] == "bytes"]
    back = [m for m in mods if old[m] == "bytes" and new[m] == "cards"]

    dn = {m: distance(f"{a.objdir}/{m}.obj", f"{IFOX}/{m}.obj") for m in mods}
    do = {m: distance(f"{a.baseline}/{m}.obj", f"{IFOX}/{m}.obj") for m in mods}
    closer = [m for m in mods if dn[m] is not None and do[m] is not None and dn[m] < do[m]]
    further = [m for m in mods if dn[m] is not None and do[m] is not None and dn[m] > do[m]]

    n_new = sum(1 for m in mods if new[m] == "identical")
    n_old = sum(1 for m in mods if old[m] == "identical")
    print(f"as370 == IFOX00 : {n_old} -> {n_new}   ({n_new - n_old:+d})")
    print(f"  gained  : {len(gained)}  {' '.join(gained[:8])}")
    print(f"  LOST    : {len(lost)}  {' '.join(lost[:8])}")
    print(f"  length -> bytes : {len(moved)}   (the second number: a length "
          f"difference became a byte difference)")
    print(f"  bytes -> length : {len(back)}")
    print(f"  decks closer to IFOX00 : {len(closer)}")
    print(f"  decks FURTHER from it  : {len(further)}  "
          f"{' '.join(f'{m}(+{dn[m]-do[m]})' for m in further[:8])}")
    for k in ("bytes", "cards", "no-as370-deck"):
        print(f"  {k:14s}: {sum(1 for m in mods if old[m] == k)} -> "
              f"{sum(1 for m in mods if new[m] == k)}")

    # The other half of "as370 == IFOX00": the return code.
    tsv = a.rc or (os.path.basename(a.objdir).replace("obj_", "", 1) + ".tsv")
    if os.path.exists(tsv):
        ifox = {m: (int(v) if v.strip().lstrip("-").isdigit() else None)
                for m, v in ((l.split("\t")[0], l.split("\t")[1])
                             for l in open(f"{RUN}/state.tsv").read().splitlines()[1:]
                             if len(l.split("\t")) > 1)}
        now = rcmap(tsv)
        # The rc baseline must be the SAME run as the deck baseline.
        #
        # This read `{RUN}/as370-gate.tsv` unconditionally while the deck side
        # read `--baseline`.  With the default baseline the two are the same run
        # and nothing shows; override `--baseline` and every rc row silently
        # keeps comparing against the promoted state instead.  cc370 caught it
        # on 2026-09-09 gating #323 with `--baseline obj_g320`: the row printed
        # `5494 -> 5517  (+23)` where g320's own value is 5503 and the delta is
        # +14, and on the failed attempt it printed -69 where the truth was -78.
        #
        # Both errors were in the direction that flatters, which is the reason
        # this is worth a hard failure rather than a fallback: `rc CLEAN ->
        # FLAGGED` reads the same map, so a PR gated on a non-promoted baseline
        # could have missed a return-code regression outright -- the exact
        # failure the unconditional line was added for after #304.
        #
        # gate.sh writes `<label>.tsv` beside `obj_<label>`, so the companion is
        # derivable.  If it is not there, stop: a baseline nobody can name is
        # worse than no comparison.
        if os.path.abspath(a.baseline) == os.path.abspath(f"{RUN}/as370"):
            base_tsv = f"{RUN}/as370-gate.tsv"
        else:
            b = os.path.basename(a.baseline.rstrip("/"))
            base_tsv = os.path.join(os.path.dirname(os.path.abspath(a.baseline)),
                                    b.replace("obj_", "", 1) + ".tsv")
        if not os.path.exists(base_tsv):
            sys.exit(f"no return codes for the baseline: {base_tsv} not found.\n"
                     f"  --baseline {a.baseline} needs its gate .tsv beside it, "
                     f"or the rc rows would compare a different run than the "
                     f"deck rows do.")
        print(f"  (rc baseline: {os.path.basename(base_tsv)})")
        base = rcmap(base_tsv)
        vn = {m: rcverdict(now.get(m), ifox.get(m)) for m in mods}
        vo = {m: rcverdict(base.get(m), ifox.get(m)) for m in mods}
        an, ao = (sum(1 for m in mods if v[m] == "agree") for v in (vn, vo))
        print(f"\n  return code agrees : {ao} -> {an}   ({an - ao:+d})")
        for k in ("as370 alone flags", "IFOX00 alone flags"):
            print(f"    {k:18s}: {sum(1 for m in mods if vo[m] == k)} -> "
                  f"{sum(1 for m in mods if vn[m] == k)}")
        # A NET count cannot report a regression it is outnumbered by.
        # cc370#304 took three modules from rc 0 to rc 8 -- IFNX1K, IFNX3K,
        # IFNX5V -- in a run whose gate line read `LOST : 0` and
        # `as370 alone flags 23 -> 19`.  Both were true: the three decks were
        # already non-identical so the deck measure could not see them, and
        # seven other modules improved in the same run.  The net moved the
        # right way while three modules got worse, and I merged it.
        #
        # So this is unconditional and by NAME, next to LOST.  Two lines, off
        # two files that were already on disk.
        broke = [m for m in mods
                 if base.get(m) is not None and now.get(m) is not None
                 and base[m] <= 4 < now[m]]
        fixed = [m for m in mods
                 if base.get(m) is not None and now.get(m) is not None
                 and now[m] <= 4 < base[m]]
        print(f"  rc CLEAN -> FLAGGED: {len(broke)}  {' '.join(broke[:10])}")
        print(f"  rc flagged -> clean : {len(fixed)}  {' '.join(fixed[:8])}")
        both = [m for m in mods if vn[m] == "agree" and new[m] == "identical"]
        bo = [m for m in mods if vo[m] == "agree" and old[m] == "identical"]
        print(f"  DECK AND RC BOTH   : {len(bo)} -> {len(both)}   "
              f"({len(both) - len(bo):+d})")

        # The 0-versus-4 boundary, which every line above is blind to.
        #
        # `rcverdict` asks whether both assemblers call the module clean, and
        # counts 4 as clean.  That is right for its question and it hides a
        # class: on 2026-09-09, 26 modules disagreed about rc 0 against rc 4 --
        # 8 where as370 says 4 and IFOX00 says 0, 18 the other way -- and 25 of
        # the 26 have a BYTE-IDENTICAL deck.  So they are invisible twice over:
        # the deck measure calls them finished and the rc measure calls them
        # agreed.  cc370 found them from the inside, working ISTNSC00.
        #
        # This is an ADDITIONAL line, not a redefinition of the one above.
        # Changing `rcverdict` would silently move every figure recorded in
        # this repository since 2026-09-09 and leave no way to compare against
        # them.  A stricter measure earns its own row.
        exact_n = sum(1 for m in mods
                      if now.get(m) is not None and ifox.get(m) is not None
                      and (now[m] == 0) == (ifox[m] == 0))
        exact_o = sum(1 for m in mods
                      if base.get(m) is not None and ifox.get(m) is not None
                      and (base[m] == 0) == (ifox[m] == 0))
        print(f"  flagged-or-silent agrees : {exact_o} -> {exact_n}   "
              f"({exact_n - exact_o:+d})   <- counts rc 4 as flagged")
    else:
        print(f"\n  (no return-code comparison: {tsv} not found -- pass --rc)")

    # Named, both directions, because the count above cancels. On cc370#182
    # IFNX1A gained a deck and IFCEE155 lost one to a timeout race, so the line
    # read "10 -> 10" and this tool reported that nothing had moved -- while one
    # of the two was a module that had never terminated before and now
    # assembles in a second. `regression-gate.md` already said a count cannot
    # see two modules moving in opposite directions; it said it about verdicts,
    # and the deck count has exactly the same shape.
    gd = [m for m in mods if old[m] == "no-as370-deck" != new[m]]
    ld = [m for m in mods if new[m] == "no-as370-deck" != old[m]]
    if gd or ld:
        print(f"  deck now produced : {len(gd)}  {' '.join(gd)}")
        print(f"  deck NOW MISSING  : {len(ld)}  {' '.join(ld)}")
        print("  (a deck that comes and goes is usually the worker's alarm, "
              "not the code -- time the module alone before believing it)")

    out = a.out or f"{RUN}/retest-{os.path.basename(a.objdir)}.tsv"
    with open(out, "w") as f:
        f.write("module\tbefore\tafter\n")
        for m in mods:
            if new[m] != old[m]:
                f.write(f"{m}\t{old[m]}\t{new[m]}\n")
    print(f"\nevery module that moved: {out}")
    if lost:
        print("\nAn identity lost is a regression, whatever the total says.")
    # A deck that stops being produced is a regression the headline cannot show.
    # cc370#209's first gate read "+1 IEDCSA, LOST 0" while two modules had
    # stopped assembling entirely -- an infinite loop, not an alarm -- and the
    # figure being watched was fine. A lost deck is now as loud as a lost
    # identity, because it is worse: there is no object at all to compare.
    if ld:
        print(f"\nA DECK THAT WAS PRODUCED AND IS NOT IS A REGRESSION: "
              f"{' '.join(ld)}")
        print("Time each alone with a generous limit before believing the "
              "alarm. A module that assembles in 0 s on the baseline and never "
              "terminates on the candidate is a hang, and the headline line "
              "will not show it.")


if __name__ == "__main__":
    main()
