#!/usr/bin/env python3
"""Compare relocation dictionaries against IFOX00, keyed by name.

**Keyed by SYMBOL NAME, not by ESDID.** An ESDID is an index into that deck's own
ESD, and the two assemblers have numbered them differently (cc370#199/#200), so a
comparison on the raw number reports a difference wherever the numbering differs
and the relocations are identical in meaning. Keyed on the number this tool found
8 modules where the object image matches and the RLD does not; keyed on names, 1.

**An LD item carries no ESDID of its own** — its ESDID field names the containing
section — so it must not advance the counter while walking an ESD card. Skipping
the entry without also skipping the increment puts every later name one slot out,
which invented two more phantom modules on top of the eight. cc370 found this in
their own sweep and told me; I made it anyway, in the pass that was checking
their figures.

The continuation bit (0x01) is masked: it says the next item shares this item's
R and P, so it is a property of the encoding rather than of the relocation.

    rld_compare.py           # tree-wide summary
    rld_compare.py MODULE    # one module, entry by entry
"""
import collections, os, sys, importlib.util

_spec = importlib.util.spec_from_file_location(
    "rt", os.path.join(os.path.dirname(os.path.abspath(__file__)), "retest.py"))
rt = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(rt)
RUN = rt.RUN


def cards(p):
    d = open(p, "rb").read()
    return [d[i:i + 80] for i in range(0, len(d), 80)]


def esd(p):
    out = {}
    for c in cards(p):
        if c[1:4] != b"\xc5\xe2\xc4":
            continue
        n = int.from_bytes(c[10:12], "big")
        cur = int.from_bytes(c[14:16], "big")
        for k in range(n // 16):
            o = 16 + k * 16
            if c[o + 8] == 1:          # LD: no ESDID of its own, no increment
                continue
            out[cur] = c[o:o + 8].decode("cp037").rstrip()
            cur += 1
    return out


def entries(p):
    E = esd(p)
    out = []
    for c in cards(p):
        if c[1:4] != b"\xd9\xd3\xc4":
            continue
        n = int.from_bytes(c[10:12], "big")
        off, end, cont = 16, 16 + n, False
        while off + 4 <= end:
            if not cont:
                if off + 8 > end:
                    break
                R = int.from_bytes(c[off:off + 2], "big")
                P = int.from_bytes(c[off + 2:off + 4], "big")
                off += 4
            fl = c[off]
            ad = int.from_bytes(c[off + 1:off + 4], "big")
            off += 4
            cont = bool(fl & 1)
            out.append((E.get(R, f"?{R}"), E.get(P, f"?{P}"), fl & 0xFE, ad))
    return out


def main():
    if len(sys.argv) > 1:
        m = sys.argv[1]
        a, i = entries(f"{RUN}/as370/{m}.obj"), entries(f"{RUN}/decks/{m}.obj")
        sa, si = collections.Counter(a), collections.Counter(i)
        print(f"{m}: IFOX00 {len(i)} entries, as370 {len(a)}")
        for lbl, d in (("only IFOX00", si - sa), ("only as370", sa - si)):
            print(f"  {lbl}:")
            for k, n in d.items():
                print(f"    R={k[0]:<9} P={k[1]:<9} flag={k[2]:#04x} "
                      f"addr={k[3]:#07x}  x{n}")
        return

    mods = sorted(f[:-4] for f in os.listdir(rt.IFOX) if f.endswith(".obj"))
    ex_tot = ex_mods = ms_tot = ms_mods = unknown = 0
    imgident = []
    for m in mods:
        pa = f"{RUN}/as370/{m}.obj"
        if not os.path.exists(pa):
            continue
        a, i = entries(pa), entries(f"{RUN}/decks/{m}.obj")
        if any(x[0].startswith("?") or x[1].startswith("?") for x in a + i):
            unknown += 1
        sa, si = collections.Counter(a), collections.Counter(i)
        ex, ms = sum((sa - si).values()), sum((si - sa).values())
        if ex:
            ex_tot += ex; ex_mods += 1
        if ms:
            ms_tot += ms; ms_mods += 1
        if ex or ms:
            ia, ii = rt._image(pa), rt._image(f"{RUN}/decks/{m}.obj")
            if set(ia) == set(ii) and all(ia[s] == ii[s] for s in ia):
                imgident.append((m, ex, ms))
    print(f"modules with an unresolvable ESDID: {unknown}   (must be 0)")
    print(f"as370 emits, IFOX00 does not : {ex_tot} entries in {ex_mods} modules")
    print(f"IFOX00 emits, as370 does not : {ms_tot} entries in {ms_mods} modules")
    print(f"\nimage identical AND RLD different: {len(imgident)}")
    for m, ex, ms in imgident:
        print(f"  {m:9s} extra {ex}  missing {ms}")


if __name__ == "__main__":
    main()
