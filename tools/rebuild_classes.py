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
    binary = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/repos/mvs/cc370/as370/as370")
    head = open(f"{RUN}/module-table.tsv").readline().strip().split("\t")
    H = {h: i for i, h in enumerate(head)}
    rows = [l.split("\t") for l in open(f"{RUN}/module-table.tsv").read().splitlines()[1:]]
    loud = [r[0] for r in rows if r[H["signal"]] == "as370 alone flags"]

    def run(m):
        # The alarm is 400 s here for the same reason it is 400 s in gate-worker.sh,
        # and it was NOT raised with it -- 2026-09-09.  gate-worker.sh went 150 -> 400
        # when IFCEL155 turned out to assemble in 41 s alone; these three tools kept
        # their 40/40/60 s and nobody looked.  IFCEL155 therefore came out of the GATE
        # with rc 20 and a 43,200-byte deck, four gate runs in a row with the identical
        # sha256, and out of THIS tool with rc -14 (SIGALRM) -- so module-table.tsv, the
        # table cc370 actually reads, filed a module that finishes as `did not finish`.
        # One alarm was raised, three were not, and the pipeline disagreed with itself.
        # The rule from IFCEE155 needs the addition: an alarm belongs to the SLOWEST
        # module in the corpus, not to the tool, so every instrument that assembles gets
        # the same one.
        p = subprocess.run(["perl", "-e", "alarm 400; exec @ARGV", binary] + MACS +
                           ["-o", "/dev/null", f"{SRC}/{m}.ASM"],
                           capture_output=True, text=True, errors="replace")
        return m, (p.stdout + p.stderr)

    # Seeded with every class, so a class that EMPTIES is written as an empty
    # file instead of keeping its last non-empty contents. A defaultdict only
    # ever held the classes that still had a member, and the one file nobody
    # rewrote was the one a fix had just succeeded on completely: after cc370#182
    # emptied `relocatable-displacement`, its file still named the two modules
    # the fix had repaired. The stale-file failure this tool exists to prevent,
    # in the one case where the news is good.
    b = defaultdict(set)
    for slug in KEYS:
        b[slug] = set()
    with ThreadPoolExecutor(8) as ex:
        for m, t in ex.map(run, loud):
            for slug, key in KEYS.items():
                if key.lower() in t.lower():
                    b[slug].add(m)

    # Three of the ten classes below are NOT derived here -- they are copied out
    # of tool-diffs.tsv and module-table.tsv, which this tool does not produce.
    # On 2026-09-10 tool-diffs.tsv was a day and a dozen merges old while this
    # tool reported "0 changed", which reads as "stable": section-one-side still
    # named ISTNSC00, whose ESD entries had become identical on both sides, and
    # ifox-alone-flags was short one module. The tool written to prevent stale
    # class files was quietly serving three from a stale file.
    #
    # So: refuse, and say what to run. Same guard module_table.py already
    # carries for as370-messages.tsv, one level further down the chain.
    gate = os.path.getmtime(f"{RUN}/as370-gate.tsv")
    for f, how in (("tool-diffs.tsv", "python3 tools/ifox_cluster.py"),
                   ("module-table.tsv", "python3 tools/module_table.py")):
        if os.path.getmtime(f"{RUN}/{f}") < gate:
            sys.exit(f"STALE: {f} is older than as370-gate.tsv.\n"
                     f"  prologue, section-one-side and ifox-alone-flags are read "
                     f"straight out of it and would describe an older assembler.\n"
                     f"  Cut the chain first, in this order:\n"
                     f"    python3 tools/as370_messages.py <as370-binary>\n"
                     f"    python3 tools/ifox_compare.py   <as370-binary>\n"
                     f"    python3 tools/ifox_cluster.py\n"
                     f"    python3 tools/module_table.py\n"
                     f"  then this one again.  ({how} is the step that makes {f}.)")

    d = [l.split("\t") for l in open(f"{RUN}/tool-diffs.tsv").read().splitlines()[1:]]
    b["prologue"] = {r[0] for r in d if r[6] == "prologue"}
    b["section-one-side"] = {r[0] for r in d if r[6] == "section only on one side"}
    b["ifox-alone-flags"] = {r[0] for r in rows if r[H["signal"]] == "IFOX00 alone flags"}

    for slug, ms in sorted(b.items()):
        p = f"{RUN}/classes/{slug}.txt"
        was = len(open(p).read().split()) if os.path.exists(p) else 0
        open(p, "w").write("".join(f"{m}\n" for m in sorted(ms)))
        mark = "" if was == len(ms) else f"   was {was}"
        if not ms:
            mark += "   EMPTY -- close the issue by hand"
        print(f"  {slug:26s} {len(ms):5d}{mark}")


if __name__ == "__main__":
    main()
