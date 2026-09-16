#!/usr/bin/env python3
"""Every CSECT with an object and no source — the disassembler's input population.

Asked for by the `dasm370` session (cc370 #112) as stage 1's acceptance corpus.
A module with no source cannot be recovered by editing anything; it can only be
disassembled. This is the list, with what a stratified sample needs: where the
bytes are, how many there are, and how much of the CSECT reads as text.

**Exclusions are named, not filtered.** A corpus that quietly drops its awkward
rows is not a corpus. Every row is here and the `exclude` column says why a row
should stay out of an acceptance sample:

| `exclude` | |
|---|---|
| `` (empty) | usable |
| `zero-length` | length 0 — an alias or entry point, not a CSECT |
| `too-short` | under 16 bytes — a stub or an entry, not worth disassembling |
| `ambiguous-length` | the same name bound at two different sizes in different load modules: either two CSECTs sharing a name or one re-assembled between them, and nothing can tell which from here |

`text_frac` is the share of the CSECT's own bytes that are printable EBCDIC —
blank, A–Z, 0–9 and a few punctuation marks. It is a **proxy for "this is a table,
not code"** and nothing more: 74 of the target-only rows are above 0.60 and the
extremes are small and total (`IKJEFLE4`, 21 bytes, 1.00). Those are the case for
reachability analysis, because an opcode subset will not stop text decoding as
`L`, `LA`, `ST` or `BC`.

    nosource.py [--out FILE]

Two sources of bytes, and the columns differ between them. A `target` row names a
bound load module with an offset and a length, out of `org-tgt.txt`. A `dlib` row
is a whole extracted object deck with no offset, and its length is the file's.
"""
import argparse, collections, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
sys.path.insert(0, HERE)
import seclocate as SL

SRCDIR = os.path.join(ROOT, "work/src-states/overlay")
OUT = os.path.join(ROOT, "work/measurements/nosource-corpus.tsv")

# blank, A-I J-R S-Z 0-9, and . $ , ' * -- enough to spot a table, not a decoder
def text_frac(b):
    if not b:
        return 0.0
    ok = sum(1 for c in b if c == 0x40 or 0xC1 <= c <= 0xC9 or 0xD1 <= c <= 0xD9
             or 0xE2 <= c <= 0xE9 or 0xF0 <= c <= 0xF9 or c in (0x4B, 0x5B, 0x6B, 0x7D, 0x5C))
    return ok / len(b)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=OUT)
    a = ap.parse_args()

    src = {f[:-4] for f in os.listdir(SRCDIR) if f.endswith(".ASM")}

    tgt = collections.defaultdict(list)
    for line in open(os.path.join(SL.GATE, "org-tgt.txt"), encoding="latin-1"):
        f = line.split()
        if len(f) < 3 or f[2] != "INCLUDE":
            continue
        if len(f) == 6:
            # ONE row in 5,517 has a BLANK CSECT name -- an unnamed control
            # section in LPALIB(IGC0004{), offset 0x900, length 0x2304.
            # `split()` collapses the empty field and shifts every later column
            # left, so the length `000032` is read as the CSECT's NAME. That
            # phantom `000032` is in the maps of all eighteen tools here that
            # read this file with `split()`; it is inert because nothing matches
            # it, and it was caught only because this corpus printed it.
            continue
        tgt[f[3]].append((f[0], f[1], int(f[4], 16), int(f[5], 16)))

    dlib = {}
    for lib in sorted(os.listdir(SL.DLIB)):
        d = os.path.join(SL.DLIB, lib)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith(".bin"):
                    dlib.setdefault(f[:-4], (lib, os.path.join(d, f)))

    rows, cache = [], {}
    for mod in sorted(set(tgt) | set(dlib)):
        if mod in src:
            continue
        if mod in tgt:
            lib, lmod, ln, off = tgt[mod][0]
            p = os.path.join(SL.TGT, lib, lmod + ".bin")
            if p not in cache:
                cache[p] = open(p, "rb").read() if os.path.exists(p) else b""
            body = cache[p][off:off + ln]
            lens = {l for _, _, l, _ in tgt[mod]}
            ex = ("zero-length" if ln == 0 else
                  "ambiguous-length" if len(lens) > 1 else
                  "too-short" if ln < 16 else
                  "no-bytes" if len(body) < ln else "")
            rows.append(("target", lib, lmod, mod, f"{off:#08x}", ln,
                         f"{text_frac(body):.2f}", ex))
        else:
            lib, p = dlib[mod]
            body = open(p, "rb").read()
            ex = "too-short" if len(body) < 16 else ""
            rows.append(("dlib", lib, "", mod, "", len(body),
                         f"{text_frac(body):.2f}", ex))

    with open(a.out, "w") as fh:
        fh.write("origin\tlibrary\tload_module\tcsect\toffset\tlength\ttext_frac\texclude\n")
        for r in rows:
            fh.write("\t".join(str(x) for x in r) + "\n")

    c = collections.Counter(r[0] for r in rows)
    e = collections.Counter(r[7] for r in rows)
    usable = [r for r in rows if not r[7]]
    print(f"{len(rows)} CSECTs with an object and no source  -> {a.out}")
    print(f"   by origin: {dict(c)}")
    print(f"   excluded : {dict((k, v) for k, v in e.items() if k)}")
    print(f"   usable   : {len(usable)}")
    hi = [r for r in usable if float(r[6]) > 0.60]
    print(f"   of the usable, text_frac > 0.60: {len(hi)}  "
          f"{dict(collections.Counter(r[3][:3] for r in hi).most_common(6))}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
