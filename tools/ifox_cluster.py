#!/usr/bin/env python3
"""Localise every as370/IFOX00 difference in the generated code.

A card index says nothing to anyone: the two decks may break their TXT cards in
different places. What is wanted is the offset *inside the control section*
where the two assemblers first disagree, and how far apart the sections are in
length. That is a case cc370 can open a source file on.

TXT card, OS/360 object format:
    col 1     X'02'
    col 2-4   'TXT'
    col 6-8   address of the first byte, 24 bit
    col 11-12 number of bytes on the card
    col 15-16 ESDID of the section
    col 17-72 the bytes themselves

So the sections are rebuilt from both decks and compared byte by byte.
"""
import os, sys
from collections import defaultdict

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")


def sections(path):
    """{section name: bytes} -- the text of every section in a deck.

    Keyed by name, never by ESDID: the two assemblers number their symbols
    independently, and comparing by number pairs one module's section with
    another's. LD items carry no ID of their own and must not advance the
    counter, or every name after the first label is off by one."""
    names, img = {}, defaultdict(bytearray)
    d = open(path, "rb").read()
    for i in range(0, len(d), 80):
        c = d[i:i + 80]
        t = c[1:4]
        if t == b"\xc5\xe2\xc4":                       # ESD
            esdid = int.from_bytes(c[14:16], "big")
            n_bytes = int.from_bytes(c[10:12], "big") or 16
            for k in range(16, 16 + n_bytes, 16):
                item = c[k:k + 16]
                if len(item) < 16:
                    break
                nm = item[:8].decode("cp037").strip()
                typ = item[8]
                if typ == 0x01:                          # LD: no ESDID
                    continue
                if nm:
                    names[esdid] = nm
                esdid += 1
        elif t == b"\xe3\xe7\xe3":                     # TXT
            adr = int.from_bytes(c[5:8], "big")
            ln = int.from_bytes(c[10:12], "big")
            esdid = int.from_bytes(c[14:16], "big")
            b = img[esdid]
            if len(b) < adr + ln:
                b.extend(b"\x00" * (adr + ln - len(b)))
            b[adr:adr + ln] = c[16:16 + ln]
    out = {}
    for e, v in img.items():
        out[names.get(e, f"#{e}")] = bytes(v)
    return out


def diff(a, b):
    """(name, len_a, len_b, first differing offset, differing bytes)."""
    sa, sb = sections(a), sections(b)
    out = []
    for nm in sorted(set(sa) | set(sb)):
        ba, bb = sa.get(nm, b""), sb.get(nm, b"")
        na = nb = nm
        first, n = None, 0
        for i in range(min(len(ba), len(bb))):
            if ba[i] != bb[i]:
                n += 1
                if first is None:
                    first = i
        if len(ba) != len(bb) and first is None:
            first = min(len(ba), len(bb))
        if first is not None:
            out.append((na if na != "-" else nb, len(ba), len(bb), first, n))
    return out


def main():
    rows = [l.split("\t") for l in open(f"{RUN}/verdicts.tsv").read().splitlines()[1:]]
    bad = [r for r in rows if (r[4] or r[3]) in ("bytes", "cards")]
    out = open(f"{RUN}/tool-diffs.tsv", "w")
    out.write("module\tsection\tlen_ifox\tlen_as370\tfirst_diff\tdiff_bytes\tkind\n")
    kinds = defaultdict(list)
    for r in bad:
        m = r[0]
        pi = f"{RUN}/decks/{m}.obj"
        pa = f"{RUN}/restamp/{m}.obj"
        if not os.path.exists(pa):
            pa = f"{RUN}/as370/{m}.obj"
        if not (os.path.exists(pi) and os.path.exists(pa)):
            continue
        for name, li, la, first, n in diff(pi, pa):
            kind = ("length" if li != la else
                    "prologue" if first < 16 else "text")
            out.write(f"{m}\t{name}\t{li}\t{la}\t{first:#07x}\t{n}\t{kind}\n")
            kinds[kind].append((m, name, li, la, first, n))
    out.close()
    print(f"{len(bad)} modules where as370 and IFOX00 differ")
    for k in sorted(kinds, key=lambda x: -len(kinds[x])):
        v = kinds[k]
        print(f"  {k:9s}: {len(v):5d} sections")
        for m, name, li, la, first, n in sorted(v, key=lambda x: x[2])[:3]:
            print(f"      {m:9s} {name:9s} IFOX {li:6d} B, as370 {la:6d} B, "
                  f"erste Abweichung {first:#07x}, {n} Byte")


if __name__ == "__main__":
    main()
