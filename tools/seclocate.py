#!/usr/bin/env python3
"""Where are the missing bytes? Align our section's text against IBM's, byte for byte.

`cmplmd370` reports nothing at all when a CSECT is a different SIZE, and that is
the largest remaining population: 1,295 modules within 64 bytes of IBM's length,
with a peak of 189 at exactly +8. Both the `+8` and `-8` cells were traced to a
point and then stalled, twice, because the one thing neither tool offers is **the
bound member's own bytes**.

This gets them without a load-module parser, by using our deck as the probe.

**Why that works.** A PL/S module's text begins `47 F0 F0 xx` — the branch around
the identifier — followed by `AL1(len)` and the module name in EBCDIC. That is
distinctive enough to locate in the member exactly once. From there the text runs
for the length `cmplmd370` already reports, so:

    find our first 16 bytes in the member  ->  text start
    take length_ref bytes                  ->  IBM's section
    difflib against our section            ->  where the insertion is

A sequence alignment says *where* the eight bytes sit and *what* they are, which
is what an offset comparison cannot: the bytes after an insertion are not wrong,
they are displaced.

    seclocate.py MODULE...  [--decks DIR] [--base tgt|tk5]

**The probe is checked, not assumed.** If our first bytes appear in the member zero
times or more than once, the module is reported as unlocatable rather than guessed
at -- the whole point is to stop guessing about this population.
"""
import argparse, collections, difflib, json, os, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
CM = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
DLIB = os.path.join(ROOT, "work/measurements/dlib-bytes/tk5")
TGT = os.path.join(ROOT, "work/measurements/target-bytes/tk5")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")


def deck_text(path, csect):
    """The TXT bytes of one section, out of an as370 object deck.

    Card images, 80 bytes each. A TXT card is X'02' 'TXT' with the address in
    bytes 5-7, the byte count in 10-11, the ESDID in 14-15 and the data at 16.
    Assembling the section means placing each card's data at its own address --
    cards are not necessarily contiguous or in order.
    """
    esdid, chunks, top = None, {}, 0
    raw = open(path, "rb").read()
    for i in range(0, len(raw) - 79, 80):
        c = raw[i:i + 80]
        if c[0] != 0x02:
            continue
        kind = c[1:4]
        if kind == b"\xc5\xe2\xc4":            # ESD
            # 16-byte items from byte 16; type X'00' is SD
            first = int.from_bytes(c[14:16], "big")
            n = int.from_bytes(c[10:12], "big")
            for k in range(n // 16):
                it = c[16 + k * 16:32 + k * 16]
                name = it[:8].decode("cp037").rstrip()
                if it[8] == 0x00 and name == csect:
                    esdid = first + k
        elif kind == b"\xe3\xe7\xe3":          # TXT
            if esdid is None or int.from_bytes(c[14:16], "big") != esdid:
                continue
            adr = int.from_bytes(c[5:8], "big")
            n = int.from_bytes(c[10:12], "big")
            chunks[adr] = c[16:16 + n]
            top = max(top, adr + n)
    if esdid is None or not chunks:
        return None
    buf = bytearray(top)
    for a, b in chunks.items():
        buf[a:a + len(b)] = b
    return bytes(buf)


def verdict(deck, ref, csect):
    cmd = [CM, "--json", "--csect", csect, deck, ref]
    q = subprocess.run(cmd, capture_output=True, text=True)
    if not q.stdout.strip():
        return None
    try:
        d = json.loads(q.stdout)
    except json.JSONDecodeError:
        return None
    for s in d.get("sections") or []:
        if s.get("name") == csect:
            return s
    return (d.get("sections") or [None])[0]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("modules", nargs="+")
    ap.add_argument("--decks", default=os.path.join(ROOT, "obj_overlay12"))
    ap.add_argument("--base", default="tgt", choices=("tgt", "tk5"))
    ap.add_argument("--probe", type=int, default=16)
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

    for mod in a.modules:
        deck = os.path.join(a.decks, mod + ".obj")
        if not os.path.exists(deck):
            print(f"{mod}: no deck")
            continue
        ours = deck_text(deck, mod)
        if not ours:
            print(f"{mod}: no TXT for that section in the deck")
            continue
        refs = ([(f"{l}({m})", os.path.join(TGT, l, m + ".bin")) for l, m in tx.get(mod, [])]
                if a.base == "tgt" else [])
        if not refs and mod in dlibof:
            refs = [("DLIB", dlibof[mod])]
        done = False
        for label, ref in refs:
            if not os.path.exists(ref):
                continue
            s = verdict(deck, ref, mod)
            if s is None:
                continue
            want = s.get("length_ref")
            blob = open(ref, "rb").read()
            probe = ours[:a.probe]
            hits = [i for i in range(len(blob) - len(probe))
                    if blob[i:i + len(probe)] == probe]
            if len(hits) != 1:
                print(f"{mod}: probe found {len(hits)} times in {label} -- unlocatable")
                continue
            theirs = blob[hits[0]:hits[0] + int(want)]
            print(f"=== {mod}  {label}  ours {len(ours)}  IBM {len(theirs)}  "
                  f"({len(theirs) - len(ours):+d})")
            sm = difflib.SequenceMatcher(None, ours, theirs, autojunk=False)
            for tag, i1, i2, j1, j2 in sm.get_opcodes():
                if tag == "equal":
                    continue
                print(f"   {tag:7s} ours[0x{i1:04x}:0x{i2:04x}] -> IBM[0x{j1:04x}:0x{j2:04x}]")
                if i2 > i1:
                    print(f"      ours: {ours[i1:i2][:24].hex(' ')}")
                if j2 > j1:
                    print(f"      IBM : {theirs[j1:j2][:24].hex(' ')}")
            done = True
            break
        if not done:
            print(f"{mod}: no usable {a.base} reference")
    return 0


if __name__ == "__main__":
    sys.exit(main())
