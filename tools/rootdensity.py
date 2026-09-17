#!/usr/bin/env python3
"""Are the 30 unusually rich in roots compared with the 772 that have no source?

[`rootreach.py`](rootreach.py) measures what fraction of a module's known code the
`cc370#383` root rule reaches, and it can only be measured on the 30 control
CSECTs, because real source is the only thing that can say which bytes are code.
It came out at **5.2 %**.

The cc370 session named the hazard in using that as a premise, and it is the one
neither instrument can see from inside itself: **the 30 are the modules that HAVE
source, and the population #383 exists for is the 772 that have none.** A figure
from the corpus that measures *truth* used as a claim about the corpus that
measures *reach* is one population answering for the other.

Root *density* is checkable on both without any source: `LR` entries the CESD
attributes to the section, plus RLD items whose R-pointer resolves into it,
divided by the section's length. It cannot say what fraction of code the roots
reach. It can say whether the 30 are unusually rich or unusually poor, and that
turns a transfer-by-assumption into a transfer with a bound.

    rootdensity.py

**Both populations are read from BOUND MEMBERS with the same extractor**, so the
deck/member asymmetry cannot leak into the comparison. That asymmetry is real and
is why the `END` entry is excluded from both sides here: a member has no entry
point in it at all -- two links differing in nothing but the entry point produce
byte-identical members, the difference being two bytes of the PDS directory.
"""
import collections, glob, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
sys.path.insert(0, HERE)
from ctlorder import records, B16                          # noqa: E402


def image(b, rs):
    """The member's text, laid out at its load addresses.

    Needed because a root is a distinct TARGET ADDRESS and not an RLD entry: a
    branch table of 119 relocations pointing at 25 places is 25 roots. Counting
    entries instead over-counts exactly where a module has a table, which is
    exactly where the roots matter.
    """
    buf = bytearray()
    for i, (o, ln, t) in enumerate(rs):
        if t < 0 or t & 0xF0 or not t & 0x01:
            continue
        adr = int.from_bytes(b[o + 9:o + 12], "big")
        cnt = B16(b, o + 14)
        nxt = rs[i + 1] if i + 1 < len(rs) else None
        if not nxt or nxt[2] != -1:
            continue
        if len(buf) < adr + cnt:
            buf.extend(b"\0" * (adr + cnt - len(buf)))
        buf[adr:adr + cnt] = b[nxt[0]:nxt[0] + min(cnt, nxt[1])]
    return bytes(buf)


def sections_and_roots(b):
    """{name: (esdid, origin, length, lr_roots, rld_roots)} for one member."""
    rs = records(b)
    if rs is None:
        return None
    img = image(b, rs)
    cesd = {}                                   # esdid -> (name, type, addr, f13)
    for o, ln, t in rs:
        if t not in (0x20, 0x28):
            continue
        first, n = B16(b, o + 4), B16(b, o + 6)
        for i in range(n // 16):
            e = o + 8 + i * 16
            cesd[first + i] = (b[e:e + 8].decode("cp037").rstrip(),
                               b[e + 8] & 0x0F,
                               int.from_bytes(b[e + 9:e + 12], "big"),
                               int.from_bytes(b[e + 13:e + 16], "big"),
                               B16(b, e + 14))
    lr = collections.Counter()
    for _, (name, typ, addr, f13, chid) in cesd.items():
        if typ == 3:                            # LR: owner ESDID at off 14
            lr[chid] += 1
    rld = collections.defaultdict(set)
    for o, ln, t in rs:
        if t < 0 or t & 0xF0:
            continue
        rl = B16(b, o + 6)
        if not rl:
            continue
        off, end, cont, R = o + 16, o + 16 + rl, False, None
        while off + 4 <= end:
            if not cont:
                if off + 8 > end:
                    break
                R = B16(b, off)
                off += 4
            fl = b[off]
            off += 4
            cont = bool(fl & 1)
            ad = int.from_bytes(b[off - 3:off], "big")
            if ((fl >> 2) & 3) + 1 == 4 and ad + 4 <= len(img):
                rld[R].add(int.from_bytes(img[ad:ad + 4], "big") & 0xFFFFFF)
    out = {}
    for esdid, (name, typ, addr, f13, chid) in cesd.items():
        if typ in (0, 4) and f13:
            out[name] = (esdid, addr, f13, lr.get(esdid, 0), len(rld.get(esdid, ())))
    return out


def population(rows, csect_col, member_glob):
    """[(csect, length, roots)] -- only sections the member actually names."""
    out, missing = [], 0
    for csect, pat in rows:
        g = glob.glob(pat)
        if not g:
            missing += 1
            continue
        s = sections_and_roots(open(g[0], "rb").read())
        if not s or csect not in s:
            missing += 1
            continue
        _, _, ln, nlr, nrld = s[csect]
        out.append((csect, ln, nlr + nrld))
    return out, missing


def report(label, rows):
    if not rows:
        print(f"{label}: nichts gemessen")
        return
    tl = sum(r[1] for r in rows)
    tr = sum(r[2] for r in rows)
    zero = sum(1 for r in rows if r[2] == 0)
    per = sorted(r[2] / r[1] * 1000 for r in rows)
    med = per[len(per) // 2]
    print(f"{label:34s} {len(rows):5d} Sektionen  {tl:9,} Bytes  {tr:6,} Wurzeln")
    print(f"{'':34s} {tr/tl*1000:8.3f} Wurzeln je 1000 Bytes gesamt, "
          f"Median je Sektion {med:.3f}")
    print(f"{'':34s} ohne jede Wurzel: {zero} von {len(rows)} = {zero/len(rows):.1%}")


def main():
    def rows(p):
        r = [l.rstrip("\n").split("\t") for l in open(p, encoding="utf-8")]
        return r[0], r[1:]

    h, rs = rows(os.path.join(ROOT, "work/measurements/dasm370-decoder-control.tsv"))
    i = {k: n for n, k in enumerate(h)}
    thirty = [(r[i["csect"]], os.path.join(ROOT, r[i["dlib_ref"]]))
              for r in rs if len(r) >= len(h)]

    h2, rs2 = rows(os.path.join(ROOT, "work/measurements/nosource-corpus.tsv"))
    j = {k: n for n, k in enumerate(h2)}
    dark = []
    for r in rs2:
        if len(r) < len(h2) or r[j["exclude"]]:
            continue
        lm = r[j["load_module"]] or r[j["csect"]]
        dark.append((r[j["csect"]],
                     os.path.join(ROOT, "work/measurements/*-bytes/tk5", "*", lm + ".bin")))

    a, ma = population(thirty, None, None)
    b, mb = population(dark, None, None)
    print()
    report("die 30 Kontroll-CSECTs (Quelle)", a)
    print()
    report("die 772 ohne Quelle", b)
    print(f"\nnicht auffindbar: {ma} von den 30, {mb} von den {len(dark)}")
    if a and b:
        da = sum(r[2] for r in a) / sum(r[1] for r in a)
        db = sum(r[2] for r in b) / sum(r[1] for r in b)
        print(f"\nDichteverhaeltnis 30 : ohne Quelle = {da/db:.2f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
