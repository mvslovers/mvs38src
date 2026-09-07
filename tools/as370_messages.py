#!/usr/bin/env python3
"""What as370 says about every module: return code, severity, and its messages.

The other half of the per-module table. IFOX00's half comes from its listing
(`ifox_run.py diag`); this half is local and cheap, so it is taken for all 5,528
modules rather than only the interesting ones.

as370 prints its diagnostics as

     ERROR: <text> (IFOX00 IFOnnn) in line 718
     Assembler Done   6 Statements Flagged /   8 was Highest Severity

and the exit code is the highest severity. The message text is the useful key --
most messages carry no IFOX code at all.
"""
import os, re, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
SRC = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
M = os.path.expanduser("~/repos/mvs/mvs38src/work/macros")
MACS = sum([["-I", p] for p in [
    f"{M}/mvsce-2.1.4-dlib/AMACLIB", f"{M}/mvsce-2.1.4-dlib/AMODGEN",
    f"{M}/mvsce-2.1.4-dlib/AGENLIB", f"{M}/mvsce-2.1.4-dlib/ATSOMAC",
    f"{M}/mvsce-2.1.4-dlib/ATCAMMAC", f"{M}/mvsce-2.1.4-dlib/APVTMACS",
    f"{M}/tape", f"{M}/mirror"]], [])

MSG = re.compile(r"^\s*(ERROR|WARNING):\s*(.+?)\s*$", re.M)
CODE = re.compile(r"\(IFOX00 (IFO\d+)\)")
DONE = re.compile(r"Assembler Done\s+(\d+) Statements? Flagged\s*/\s*(\d+) was Highest")


def one(m):
    p = subprocess.run(["perl", "-e", "alarm 40; exec @ARGV",
                        os.environ["AS370"]] + MACS +
                       ["-o", "/dev/null", f"{SRC}/{m}.ASM"],
                       capture_output=True, text=True, errors="replace",
                       env=dict(os.environ, ASMDATE="09/07/26", ASMTIME="12.00"))
    txt = p.stdout + p.stderr
    d = DONE.search(txt)
    flagged, sev = (d.group(1), d.group(2)) if d else ("", "")
    seen, order = set(), []
    for kind, text in MSG.findall(txt):
        code = CODE.search(text)
        text = CODE.sub("", text)
        text = re.sub(r"\s+in line \d+.*$", "", text).strip(" -")
        key = f"{code.group(1)} {text}" if code else text
        if key not in seen:
            seen.add(key)
            order.append(key)
    return m, p.returncode, flagged, sev, " | ".join(order[:6])


def main():
    os.environ["AS370"] = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser(
        "~/.local/bin/as370")
    mods = sorted(f[:-4] for f in os.listdir(SRC) if f.endswith(".ASM"))
    with open(f"{RUN}/as370-messages.tsv", "w") as f:
        f.write("module\trc\tflagged\tseverity\tmessages\n")
        with ThreadPoolExecutor(8) as ex:
            for i, r in enumerate(ex.map(one, mods), 1):
                f.write("\t".join(str(x) for x in r) + "\n")
                if i % 500 == 0:
                    print(f"{i}/{len(mods)}", flush=True)
    print(f"written: {RUN}/as370-messages.tsv")


if __name__ == "__main__":
    main()
