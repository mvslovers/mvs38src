#!/usr/bin/env python3
"""Repair the one character Dave Kreiss' transfer got wrong: '^' for '¬'.

`MVSBLD` came off the mainframe through a transfer that read EBCDIC in **cp1047**,
where X'5F' is `^`. Everything downstream here reads **cp037**, where X'5F' is `¬`
and `^` is X'B0'. In a comment that is a curiosity; inside a character constant it
puts the wrong byte into the object.

Both assemblers get it wrong *identically* -- `as370` encodes cp037, and the
source reaches MVS through mvsMF, which encodes cp037 as well, so IFOX00 sees
X'B0' too. Measured: `DC C'^'` gives `B0` from both. That is why these modules sat
in the table as "the two assemblers agree, only IBM's object differs" -- the
comparison against IFOX00 could not see it, and only IBM's shipped object could.

The evidence that X'5F' is what belongs there is the strongest available: with the
substitution, **ten modules become byte-identical to the object IBM shipped**, and
not one module gets worse.

    caret_fix.py --check              count the occurrences, change nothing
    caret_fix.py --out DIR [module…]  write repaired copies

Found by the mvssrc-20 session, measured here. `!` is X'5A' in both code pages and
needs nothing. `[` and `]` do differ (X'BA'/X'BB' against X'AD'/X'BD'), but the two
modules carrying them in a constant do not improve, so that substitution is
**not** applied: it is unproven.
"""
import argparse, os, sys

SRC = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"


def repair(text):
    """Substitute inside character constants only. Column 73-80 is the sequence
    number and a card with '*' or '.' in column 1 is a comment; neither is
    touched."""
    out, n = [], 0
    for s in text.split("\r\n"):
        if s[:1] in ("*", ".") or not s.strip():
            out.append(s)
            continue
        body, seq = s[:72], s[72:]
        res, q = [], 0
        for ch in body:
            if ch == "'":
                q ^= 1
            if ch == "^" and q:
                res.append("¬")
                n += 1
            else:
                res.append(ch)
        out.append("".join(res) + seq)
    while out and out[-1].strip() == "":
        out.pop()
    return out, n


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("modules", nargs="*")
    ap.add_argument("--out")
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    mods = a.modules or sorted(f[:-4] for f in os.listdir(SRC) if f.endswith(".ASM"))
    total = 0
    for m in mods:
        text = open(f"{SRC}/{m}.ASM", "rb").read().decode("latin-1")
        lines, n = repair(text)
        if not n:
            continue
        total += n
        print(f"{m:9s} {n:3d}")
        if a.out and not a.check:
            os.makedirs(a.out, exist_ok=True)
            open(f"{a.out}/{m}.ASM", "wb").write(
                b"".join(l.ljust(80)[:80].encode("latin-1") + b"\r\n" for l in lines))
    print(f"{total} occurrences in character constants")


if __name__ == "__main__":
    main()
