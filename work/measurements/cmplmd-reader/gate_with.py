#!/usr/bin/env python3
"""Run baseline_gate.py with a different cmplmd370, without editing it.

`baseline_gate.py` pins the comparator by path, which is right for the published
figure and wrong for a trial -- the same shape as `asmparams.py` before it
learned to read the environment: a trial could not be made without editing the
real thing. Patching the module attribute keeps the repo untouched, so the trial
and the published figure run the same code with one variable switched.

    gate_with.py <cmplmd370> --decks <dir> --out <tsv> [--jobs N]
"""
import os, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..")
sys.path.insert(0, os.path.join(ROOT, "tools"))
import baseline_gate as bg

binpath = os.path.abspath(sys.argv.pop(1))
if not os.path.exists(binpath):
    sys.exit(f"no such comparator: {binpath}")
bg.CMPLMD = binpath
print(f"comparator: {binpath}", file=sys.stderr)
sys.exit(bg.main())
