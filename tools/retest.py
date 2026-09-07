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
`docs/ifox-tree.md`. That is not a discrepancy: `ifox_compare.py` re-assembles
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


def verdict(a, b):
    if not os.path.exists(a):
        return "no-as370-deck"
    if not os.path.exists(b):
        return "no-ifox-deck"
    x, y = body(a), body(b)
    if len(x) != len(y):
        return "cards"
    return "identical" if x == y else "bytes"


def measure(objdir, mods):
    return {m: verdict(f"{objdir}/{m}.obj", f"{IFOX}/{m}.obj") for m in mods}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("objdir")
    ap.add_argument("--baseline", default=f"{RUN}/as370",
                    help="the as370 decks the recorded figures come from")
    ap.add_argument("--out", default=None)
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

    out = a.out or f"{RUN}/retest-{os.path.basename(a.objdir)}.tsv"
    with open(out, "w") as f:
        f.write("module\tbefore\tafter\n")
        for m in mods:
            if new[m] != old[m]:
                f.write(f"{m}\t{old[m]}\t{new[m]}\n")
    print(f"\nevery module that moved: {out}")
    if lost:
        print("\nAn identity lost is a regression, whatever the total says.")


if __name__ == "__main__":
    main()
