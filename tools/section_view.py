#!/usr/bin/env python3
"""Three views of one deck, and what each disagreement between them means.

Every instrument here reads the object at ONE layer, and five divergences on
2026-09-09 lived at another. cc370#280 had no wrong TXT byte at all -- the
highest was `X'0C42'` on both sides -- and cc370#281 had every byte right and
filed under the wrong ESDID, so a byte comparison keyed by section saw a section
with no content and 3,654 wrong bytes where nothing was wrong.

So compare three things and read the DISAGREEMENTS:

    cards          the deck as written
    by (esdid, address)   the image as filed
    by address alone      the image as laid out

| cards | esdid | address | what it is |
|---|---|---|---|
| differ | differ | **same** | a FILING defect -- right bytes, wrong section (cc370#281) |
| differ | same | same | card packing only; nothing is wrong |
| differ | differ | differ | ordinary wrong content |

and separately, the question none of the seven asks:

    which sections are EMPTY on one side and not the other

which is cc370#281 in one line.

    section_view.py [--all]     # default: only the modules that still differ
"""
import os, sys, collections

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
TXT, ESD, END = b"\xe3\xe7\xe3", b"\xc5\xe2\xc4", b"\xc5\xd5\xc4"


def read(p):
    d = open(p, "rb").read()
    sects, img, cards = {}, {}, []
    for i in range(0, len(d), 80):
        c = d[i:i + 80]
        if c[1:4] == END:
            continue
        cards.append(c[:72])
        if c[1:4] == ESD:
            n = int.from_bytes(c[10:12], "big")
            e = int.from_bytes(c[14:16], "big")
            for j in range(0, n, 16):
                nm = c[16 + j:24 + j].decode("cp037", errors="replace").strip()
                t = c[24 + j]
                if nm and t in (0x00, 0x04, 0x05):      # SD, PC, CM
                    sects[e + j // 16] = nm
        elif c[1:4] == TXT:
            a = int.from_bytes(c[5:8], "big")
            n = int.from_bytes(c[10:12], "big")
            e = int.from_bytes(c[14:16], "big")
            for k in range(n):
                img[(e, a + k)] = c[16 + k]
    return sects, img, cards


def main():
    head = open(f"{RUN}/module-table.tsv").readline().rstrip("\n").split("\t")
    H = {h: i for i, h in enumerate(head)}
    rows = [r.split("\t") for r in
            open(f"{RUN}/module-table.tsv").read().splitlines()[1:]]
    mods = [r[0] for r in rows if not r[H["excluded"]]
            and ("--all" in sys.argv or r[H["tool"]] != "identical")]

    verdict = collections.Counter()
    empty_side, sect_only = [], []
    for m in mods:
        pa, pi = f"{RUN}/as370/{m}.obj", f"{RUN}/decks/{m}.obj"
        if not (os.path.exists(pa) and os.path.exists(pi)):
            continue
        sa, ia, ca = read(pa)
        si, ii, ci = read(pi)

        cards_same = len(ca) == len(ci) and all(x == y for x, y in zip(ca, ci))
        esdid_same = ia == ii
        flat_a = {a: v for (_, a), v in ia.items()}
        flat_i = {a: v for (_, a), v in ii.items()}
        addr_same = flat_a == flat_i

        if not cards_same and not esdid_same and addr_same:
            verdict["FILING -- bytes right, section wrong"] += 1
            sect_only.append(m)
        elif not cards_same and esdid_same:
            verdict["card packing only"] += 1
        elif not cards_same:
            verdict["content differs"] += 1

        # which named sections carry text on one side and not the other
        for nm in set(sa.values()) | set(si.values()):
            ea = [e for e, v in sa.items() if v == nm]
            ei = [e for e, v in si.items() if v == nm]
            na = sum(1 for (e, _) in ia if e in ea)
            ni = sum(1 for (e, _) in ii if e in ei)
            if (na == 0) != (ni == 0):
                empty_side.append((m, nm, na, ni))

    print(f"{len(mods)} modules\n")
    for k, n in verdict.most_common():
        print(f"  {n:5d}  {k}")
    if sect_only:
        print(f"\nfiling only ({len(sect_only)}): {' '.join(sorted(sect_only))}")
    print(f"\nSECTIONS EMPTY ON ONE SIDE AND NOT THE OTHER: {len(empty_side)}")
    for m, nm, na, ni in sorted(empty_side)[:40]:
        print(f"  {m:10s} {nm:10s} as370 {na:6d} B   IFOX00 {ni:6d} B")


if __name__ == "__main__":
    main()
