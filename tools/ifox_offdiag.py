#!/usr/bin/env python3
"""The two cells where the assemblers disagree about whether anything is wrong.

The deck comparison sees only modules that produced a deck on both sides. It
cannot see the case where one assembler flags a statement the other accepts
without a word -- and that case is a defect just as surely, on whichever side it
falls.

  as370 rc>=8, IFOX00 rc 0    as370 rejects what Assembler XF accepts.
                              Its own messages name the construct, and they
                              carry the IFOX code they claim to implement.
  as370 rc 0, IFOX00 rc>=8    as370 is silent where XF flags. Only the listing
                              says what was flagged, so this half needs the
                              LIST pass (`ifox_run.py diag`).

Usage: ifox_offdiag.py <as370-binary>
"""
import os, re, subprocess, sys
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
SRC = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
M = os.path.expanduser("~/repos/mvs/mvs38src/work/macros")
MACS = sum([["-I", p] for p in [
    f"{M}/mvsce-2.1.4-dlib/AMACLIB", f"{M}/mvsce-2.1.4-dlib/AMODGEN",
    f"{M}/mvsce-2.1.4-dlib/AGENLIB", f"{M}/mvsce-2.1.4-dlib/ATSOMAC",
    f"{M}/mvsce-2.1.4-dlib/ATCAMMAC", f"{M}/mvsce-2.1.4-dlib/APVTMACS",
    f"{M}/tape", f"{M}/mirror"]], [])
CODE = re.compile(r"\(IFOX00 (IFO\d+)\)")
# most as370 messages carry no IFOX code, so classify by the message itself,
# cut before the part that names a line or a symbol
MSG = re.compile(r"^\s*ERROR:\s*(.+?)(?:\s+in line \d+.*)?$", re.M)
IFOXCODE = re.compile(r"\s(IFO\d+)\s")


def as370_messages(args):
    m, binary = args
    p = subprocess.run(["perl", "-e", "alarm 40; exec @ARGV", binary] + MACS +
                       ["-o", "/dev/null", f"{SRC}/{m}.ASM"],
                       capture_output=True, text=True, errors="replace")
    txt = p.stdout + p.stderr
    codes = {f"{c}" for c in CODE.findall(txt)}
    for msg in MSG.findall(txt):
        msg = CODE.sub("", msg).strip(" -")
        msg = re.sub(r"\s*-\s*\S+$", "", msg) if msg.endswith(tuple("0123456789")) or " - " in msg else msg
        codes.add(msg[:60])
    return m, codes, txt


def main():
    binary = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/repos/mvs/cc370/as370/as370")
    rows = [l.split("\t") for l in open(f"{RUN}/verdicts.tsv").read().splitlines()[1:]]
    loud = [r[0] for r in rows if r[1].isdigit() and int(r[1]) >= 8
            and r[2].isdigit() and int(r[2]) == 0]
    quiet = [r[0] for r in rows if r[1] == "0" and r[2].isdigit() and int(r[2]) >= 8]

    print(f"as370 flags, IFOX00 is content: {len(loud)} modules")
    c, per = Counter(), defaultdict(list)
    with ThreadPoolExecutor(8) as ex:
        for m, codes, _ in ex.map(as370_messages, [(m, binary) for m in loud]):
            if not codes:
                c["(no code in the message)"] += 1
                per["(no code in the message)"].append(m)
            for k in codes:
                c[k] += 1
                per[k].append(m)
    with open(f"{RUN}/as370-flags.tsv", "w") as f:
        f.write("code\tmodules\texamples\n")
        for k, v in c.most_common():
            f.write(f"{k}\t{v}\t{' '.join(sorted(per[k])[:5])}\n")
    for k, v in c.most_common(12):
        print(f"  {k:26s} {v:5d}   {' '.join(sorted(per[k])[:3])}")

    print(f"\nas370 silent, IFOX00 flags: {len(quiet)} modules")
    d = Counter()
    seen = 0
    for m in quiet:
        p = f"{RUN}/diag/{m}.txt"
        if not os.path.exists(p):
            continue
        seen += 1
        for code in set(IFOXCODE.findall(open(p, errors="replace").read())):
            d[code] += 1
    if seen:
        for k, v in d.most_common(12):
            print(f"  {k:26s} {v:5d}")
    else:
        print("  (no listings fetched yet -- run: ifox_run.py diag --list ...)")
    open(f"{RUN}/ifox-flags.txt", "w").write("\n".join(quiet) + "\n")
    print(f"\nmodule list for the diag pass: {RUN}/ifox-flags.txt")


if __name__ == "__main__":
    main()
