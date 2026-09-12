#!/usr/bin/env python3
"""Turn a differing address into the statement that generated it.

`small_delta.py` says *module X, ESDID 1, address 00095D, IFOX 04, as370 05*.
That is not yet a case. This assembles the module with a listing, resolves the
ESDID to its control section through the external symbol dictionary, and prints
the statements around that address **in that section** -- macro expansions
included, which is where these constructs usually live.

The section step is the part that cannot be skipped. A listing's location
counter restarts at zero for every CSECT and DSECT, so "the last statement whose
LOC is below the address" picks a line out of whichever section happened to be
listed last. It gave me `IEEMB812 CSECT` for an address inside a macro-generated
ENQ list, which is true and useless.

    witness.py MODULE ADDR [ADDR...]        # addresses in hex, ESDID 1 assumed
    witness.py MODULE 2:0001ED             # or ESDID:ADDR
"""
import os, re, subprocess, sys

SRC = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
M = os.path.expanduser("~/repos/mvs/mvs38src/work/macros")
BIN = os.environ.get("AS370", os.path.expanduser("~/repos/mvs/cc370/as370/as370"))
import sys as _sys, os as _os
_sys.path.insert(0, _os.path.dirname(_os.path.abspath(__file__)))
from macpath import flags as _macflags
# The -I path comes from macpath.py, which reads it out of gate.sh. This file
# used to restate it and was two directories short -- erep-set and
# amaclib-live, which the gate gained on 2026-09-09. cc370 measured the reach:
# 33 decks differ between the two paths, all EREP, and the short path starves
# them (IFCE0115: 15 cards against a 107-card reference).
MACS = _macflags()


def listing(m):
    p = f"/tmp/witness-{m}.lst"
    if not os.path.exists(p):
        subprocess.run(["perl", "-e", "alarm 300; exec @ARGV", BIN, "-ae", f"-a=" + p]
                       + MACS + ["-o", "/dev/null", f"{SRC}/{m}.ASM"],
                       capture_output=True)
    return open(p, encoding="utf-8", errors="replace").read().splitlines()


def main():
    m, want = sys.argv[1], sys.argv[2:]
    lines = listing(m)

    esd, sects = {}, {}
    for l in lines:                      # SYMBOL TYPE ID ADDR LENGTH
        g = re.match(r"^(\S{1,8}) +(SD|CM|PC) +([0-9A-F]{4}) ", l)
        if g:
            esd[int(g.group(3), 16)] = g.group(1)

    cur = None
    for l in lines:                      # statement rows, tracked by section
        g = re.match(r"^([0-9A-F]{6}) .{16,}?\d+[ +] *(\S+)? +(\S+)", l)
        if not g:
            continue
        op = g.group(3).upper()
        if op in ("CSECT", "DSECT", "COM", "START"):
            cur = g.group(2) or cur
        sects.setdefault(cur, []).append((int(g.group(1), 16), l))

    for w in want:
        e, a = (w.split(":") + [None])[:2]
        e, a = (int(e), int(a, 16)) if a else (1, int(e, 16))
        name = esd.get(e)
        rows = sects.get(name, [])
        print(f"=== {m}  esdid {e} ({name or '?'})  @ {a:06X}")
        if not rows:
            print("    section not found in the listing -- ESD ids:", esd)
        for loc, l in rows:
            if a - 14 <= loc <= a:
                print("   ", l[:132].rstrip())
        print()


if __name__ == "__main__":
    main()
