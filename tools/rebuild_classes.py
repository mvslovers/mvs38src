#!/usr/bin/env python3
"""Re-derive every case-class list from the current assembler.

A class list is a snapshot of `as370`, not an inventory of the work
(`docs/regression-gate.md`). It goes stale at every merge, and the issues in the
cc370 repository link straight at these files — so this runs after each one,
beside `ifox_compare.py` and `module_table.py`.

It was written because they *did* go stale: `addressability.txt` still held 156
modules after two merges had taken the class to 42, and the file was linked from
cc370#154 the whole time.

**Class proper, not symptom.** A list holds the modules where `as370` flags and
IFOX00 is silent — the ones the class is actually about. Counting every module
whose output carries the message gives more than twice as many, because a module
dominated by another defect emits addressability errors downstream: `IFCE0115`
has 128 undefined-opcode and 100 undefined-symbol messages before its 53
addressability ones. The two numbers answer different questions and the files
answer the first.

    rebuild_classes.py <as370-binary>
"""
import os, subprocess, sys
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
SRC = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
M = os.path.expanduser("~/repos/mvs/mvs38src/work/macros")
MACS = sum([["-I", f"{M}/mvsce-2.1.4-dlib/{d}"] for d in
            ("AMACLIB", "AMODGEN", "AGENLIB", "ATSOMAC", "ATCAMMAC", "APVTMACS")],
           []) + ["-I", f"{M}/tape", "-I", f"{M}/mirror"]

KEYS = {"undefined-symbol": "Undefined symbol",
        "addressability": "Addressability error",
        "undefined-opcode": "Undefined operation code",
        "relocatable-displacement": "Relocatable displacement",
        "duplication-factor": "Duplication factor",
        "continuation-consumed": "consumed as a continuation",
        "symbol-over-8": "longer than 8 characters"}


def main():
    binary = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/.local/bin/as370")
    head = open(f"{RUN}/module-table.tsv").readline().strip().split("\t")
    H = {h: i for i, h in enumerate(head)}
    rows = [l.split("\t") for l in open(f"{RUN}/module-table.tsv").read().splitlines()[1:]]
    loud = [r[0] for r in rows if r[H["signal"]] == "as370 alone flags"]

    def run(m):
        p = subprocess.run(["perl", "-e", "alarm 60; exec @ARGV", binary] + MACS +
                           ["-o", "/dev/null", f"{SRC}/{m}.ASM"],
                           capture_output=True, text=True, errors="replace")
        return m, (p.stdout + p.stderr)

    b = defaultdict(set)
    with ThreadPoolExecutor(8) as ex:
        for m, t in ex.map(run, loud):
            for slug, key in KEYS.items():
                if key.lower() in t.lower():
                    b[slug].add(m)

    d = [l.split("\t") for l in open(f"{RUN}/tool-diffs.tsv").read().splitlines()[1:]]
    b["prologue"] = {r[0] for r in d if r[6] == "prologue"}
    b["section-one-side"] = {r[0] for r in d if r[6] == "section only on one side"}
    b["ifox-alone-flags"] = {r[0] for r in rows if r[H["signal"]] == "IFOX00 alone flags"}

    for slug, ms in sorted(b.items()):
        p = f"{RUN}/classes/{slug}.txt"
        was = len(open(p).read().split()) if os.path.exists(p) else 0
        open(p, "w").write("\n".join(sorted(ms)) + "\n")
        mark = "" if was == len(ms) else f"   was {was}"
        print(f"  {slug:26s} {len(ms):5d}{mark}")


if __name__ == "__main__":
    main()
