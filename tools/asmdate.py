#!/usr/bin/env python3
"""The assembly date IBM stamped, read out of IBM's own object, per module.

`gate.sh` pins `ASMDATE=09/07/26` so a run is reproducible. For most modules that
is invisible. For the ones whose eyecatcher carries the assembler's date -- PL/S
output does this routinely, `DC AL1(IDENTEND-IDENT)` and the identifier behind it
-- the pinned stamp is simply **the wrong date**, and the module is marked as
differing from IBM's object over a value that was never in its source.

`BLSUSTAE` is the clean example. Four differing bytes, all of them digits:

    ours  f9 . f7 . f2f6   ->  0 9 / 0 7 / 2 6
    IBM   f3 . f1 . f7f8   ->  0 3 / 0 1 / 7 8

Our source is right. `03/01/78` is when IBM assembled it.

So the date is not guessed and not searched for: **our deck contains the pinned
stamp at a known offset, and IBM's member contains its own stamp at the same
offset.** Read it there.

    asmdate.py [--decks DIR] [--out FILE] [--limit N]

Writes `module<TAB>date` for every module where the window holding our pinned
stamp holds a well-formed `mm/dd/yy` in IBM's object. Nothing is assembled or
deposited here -- that is `gate.sh`'s job, with this table in hand.

**This is not a source repair and must never be counted as one.** It corrects the
instrument, not the tree: the modules it touches were already right.
"""
import argparse, collections, os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DLIB = os.path.join(ROOT, "work/measurements/dlib-bytes/tk5")
TGT = os.path.join(ROOT, "work/measurements/target-bytes/tk5")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")
PINNED = "09/07/26"
E = {c: bytes([b]) for c, b in zip("0123456789/", b"\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\x61")}
PIN = b"".join(E[c] for c in PINNED)
DATE = re.compile(rb"^[\xf0-\xf9]{2}\x61[\xf0-\xf9]{2}\x61[\xf0-\xf9]{2}$")


def ebcdic_date(b):
    """b'\\xf0\\xf3\\x61...' -> '03/01/78', or None."""
    if not DATE.match(b):
        return None
    out = []
    for x in b:
        out.append("/" if x == 0x61 else chr(x - 0xF0 + ord("0")))
    s = "".join(out)
    mm, dd, _ = s.split("/")
    return s if 1 <= int(mm) <= 12 and 1 <= int(dd) <= 31 else None


def target_map():
    m = collections.defaultdict(list)
    p = os.path.join(GATE, "org-tgt.txt")
    if not os.path.exists(p):
        return m
    for line in open(p, encoding="latin-1"):
        f = line.split()
        if len(f) >= 5 and f[2] == "INCLUDE":
            m[f[3]].append((f[0], f[1]))
    return m


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--decks", default=os.path.join(ROOT, "obj_overlay7"))
    ap.add_argument("--out", default=os.path.join(GATE, "asmdate.tsv"))
    ap.add_argument("--limit", type=int, default=0)
    a = ap.parse_args()

    tx = target_map()
    refs = {}
    for lib in sorted(os.listdir(DLIB)):
        d = os.path.join(DLIB, lib)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith(".bin"):
                    refs.setdefault(f[:-4], os.path.join(d, f))

    found, nostamp, nodate, disagree = {}, 0, 0, []
    mods = sorted(m[:-4] for m in os.listdir(a.decks) if m.endswith(".obj"))
    for mod in (mods[:a.limit] if a.limit else mods):
        deck = open(os.path.join(a.decks, mod + ".obj"), "rb").read()
        i = deck.find(PIN)
        if i < 0:
            nostamp += 1
            continue
        # The deck is card images; the same byte offset in the bound member is
        # not the same place, so the stamp is located in the REFERENCE by looking
        # for a date-shaped window, not by reusing the deck's offset.
        cands = set()
        for src in ([refs[mod]] if mod in refs else []) + \
                   [os.path.join(TGT, l, m + ".bin") for l, m in tx.get(mod, [])]:
            if not os.path.exists(src):
                continue
            blob = open(src, "rb").read()
            for m2 in re.finditer(rb"[\xf0-\xf9]{2}\x61[\xf0-\xf9]{2}\x61[\xf0-\xf9]{2}", blob):
                d = ebcdic_date(m2.group(0))
                if d and d != PINNED:
                    cands.add(d)
        if not cands:
            nodate += 1
            continue
        if len(cands) > 1:
            disagree.append((mod, sorted(cands)))
            continue
        found[mod] = cands.pop()

    with open(a.out, "w") as fh:
        fh.write("module\tasmdate\n")
        for k, v in sorted(found.items()):
            fh.write(f"{k}\t{v}\n")
    print(f"decks scanned            {len(mods if not a.limit else mods[:a.limit])}")
    print(f"  carry the pinned stamp {len(found) + nodate + len(disagree)}")
    print(f"  one date in the object {len(found)}   -> {a.out}")
    print(f"  several dates          {len(disagree)}")
    print(f"  no date in the object  {nodate}")
    print(f"  no pinned stamp        {nostamp}")
    by = collections.Counter(found.values())
    print("\nmost common dates:", by.most_common(8))
    return 0


if __name__ == "__main__":
    sys.exit(main())
