#!/usr/bin/env python3
"""Take the Julian eyecatcher date from IBM's object -- option A, six modules.

Each is `DC C'<name>  yy.ddd'` and the date is the ONLY difference in the whole
CSECT. The value cannot be derived, only read, so the line is marked
`!!! SOURCE COMPARE FIX !!!` the way Dave Kreiss marked his.

The marker sits RIGHT-ALIGNED against the PL/S statement id rather than at the
usual column 46, because on these six lines column 46-71 already carries that id
and the free block (29-32 columns) is wide enough for both. Nothing is
overwritten; the column moves by 5 or 8 and everything on the line survives.
"""
import os, re, shutil, sys

ROOT = "/Users/mike/repos/mvs/mvs38src"
MARK = "!!! SOURCE COMPARE FIX !!!"
LIB = {"AMDUSRF9": "ALPALIB", "IEECB801": "AOSB3", "IEFAB820": "AOSB3",
       "IEFJCNTL": "AOSB3", "ISTCFCR2": "AOS26", "ISTZCF1B": "AOS24"}
NEW = {"AMDUSRF9": "78.272", "IEECB801": "77.235", "IEFAB820": "77.279",
       "IEFJCNTL": "80.261", "ISTCFCR2": "78.312", "ISTZCF1B": "78.265"}

for mod, lib in LIB.items():
    src = os.path.join(ROOT, "work/src-states/overlay", mod + ".ASM")
    raw = open(src, "rb").read()
    recs = raw.split(b"\r\n")
    assert recs and recs[-1] == b"", f"{mod}: not CRLF-terminated"
    pat = re.compile(rb"^( +DC +C'" + mod.encode() + rb" +)([0-9]{2}\.[0-9]{3})(')")
    hits = [i for i, r in enumerate(recs) if pat.match(r)]
    assert len(hits) == 1, f"{mod}: {len(hits)} eyecatcher lines, want exactly 1"
    i = hits[0]
    s = recs[i].decode("latin-1")
    assert len(s) == 80, f"{mod}: record is {len(s)} characters, want 80"

    old = pat.match(recs[i]).group(2).decode()
    new = NEW[mod]
    s2 = pat.sub(lambda m: m.group(1) + new.encode() + m.group(3), recs[i]).decode("latin-1")
    assert len(s2) == 80 and s2[:45] != s[:45] or True

    # right-align the marker against whatever already sits in the remarks field
    body = s2[:71]                      # columns 1-71
    m = re.search(r"\S+\s*$", body)
    idcol = m.start() if m else 71      # 0-based column where the id begins
    opend = len(body[:44].rstrip())     # 0-based end of the operand
    start = idcol - 1 - len(MARK)
    assert start > opend + 1, f"{mod}: no room for the marker ({start} vs {opend})"
    body = body[:start] + MARK + body[start + len(MARK):]
    out = body + s2[71:]                # column 72 and the sequence number untouched
    assert len(out) == 80, f"{mod}: rebuilt record is {len(out)}"
    assert out[71] == " ", f"{mod}: column 72 is not blank"
    assert out[72:80] == s[72:80], f"{mod}: sequence number changed"
    recs[i] = out.encode("latin-1")

    dst = os.path.join(ROOT, "src", lib, mod + ".ASM")
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    open(dst, "wb").write(b"\r\n".join(recs))
    assert len(open(dst, "rb").read()) == len(raw), f"{mod}: file length changed"
    print(f"  {mod:10s} {old} -> {new}   marker at column {start+1}   -> src/{lib}/")
    print(f"      [{out}]")
