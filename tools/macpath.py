#!/usr/bin/env python3
"""The macro `-I` path, in one place, parsed from the one place that decides it.

`gate.sh` is the authority: it produces the decks every other tool judges, so a
tool that assembles with a different path is not measuring the same thing. On
2026-09-12 eight tools disagreed with it — `gate.sh` passed ten directories and
all seven Python tools eight, every one of them missing `erep-set` and
`amaclib-live`. The gate gained those on 2026-09-09 when the six EREP macros
were uploaded to the oracle and 33 reference decks were re-cut against them
(`docs/erep-adoption.md`); none of the consumers followed.

cc370 measured the reach before this was fixed, and it is not cosmetic: over
5,528 modules, one binary, both paths, **33 decks differ and 0 return codes do**
— all of them EREP. The eight-directory decks are *short*, not subtly wrong:
`IFCE0115` comes out at 15 cards against a 107-card reference. `IFCE33XX` is
1 differing card of 97 on the gate's path and 61 on the starved one.

So this module exists because a rule restated in a second place is a rule that
will drift, and it had already drifted seven times.

    from macpath import flags        # list, ready for subprocess
"""
import os, re, sys

_GATE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "gate.sh")
_M = os.path.expanduser("~/repos/mvs/mvs38src/work/macros")


def flags(gate=None):
    """The `-I` list exactly as gate.sh passes it, EXTRA_MACS excluded."""
    src = open(gate or _GATE).read()
    m = re.search(r'^MACFLAGS="(.*)"$', src, re.M)
    if not m:
        sys.exit(f"{gate or _GATE}: no MACFLAGS line to read the -I path from")
    txt = m.group(1).replace("$M", _M)
    txt = re.sub(r"\$\{EXTRA_MACS:-\}", "", txt)
    out = txt.split()
    if not out or out[0] != "-I":
        sys.exit(f"MACFLAGS did not parse into a -I list: {out[:4]}")
    return out


def dirs(gate=None):
    """Just the directories, for reporting."""
    f = flags(gate)
    return f[1::2]


if __name__ == "__main__":
    d = dirs()
    print(f"{len(d)} directories from gate.sh:")
    for x in d:
        mark = "" if os.path.isdir(x) else "   <-- MISSING"
        print(f"  {x.replace(_M + '/', '')}{mark}")
