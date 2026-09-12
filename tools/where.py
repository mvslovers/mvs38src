#!/usr/bin/env python3
"""For one module: every byte that differs from TK5's object, and the source line that owns it.

This exists because the manual version failed. `cmplmd370` reports cluster
offsets **relative to their CSECT**; the assembler listing carries **absolute**
addresses. Subtracting nothing and comparing the two put a hole on a `CLI`
instruction -- which cannot be right for a byte the deck does not cover -- and
the mismatch is invisible in a single-CSECT module and wrong in every other.

The section bases come from the listing's own ESD table (`IKJEHRN2 SD 0008
0003F8 001032`), so absolute = base + offset, and the owning statement is the
last one at or before that address.

    where.py <module> [--src PATH] [--base tk5|ce]

Without --src the archive copy is used. Exit 0 if the module is identical.
"""
import argparse, glob, json, os, re, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from macpath import flags

ARCHIVE = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
BIN = os.path.join(ROOT, "work/src-states/bin/as370-main")
CM = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
DLIB = os.path.join(ROOT, "work/measurements/dlib-bytes")
STAMP = dict(ASMDATE="09/07/26", ASMTIME="12.00")
# ESD row:  NAME  SD  ID  ADDR  LENGTH
ESD = re.compile(r"^(\S{1,8})\s+SD\s+([0-9A-F]{4})\s+([0-9A-F]{6})\s+([0-9A-F]{6})")
# listing row: ADDR  [hex bytes]  STMT[+| ] text
#
# The byte group must be constrained to hex, or `.*?` finds an earlier split and
# a line like `0008D6   1072+IHB0045  DS    0F` yields statement "0" and text
# "F" -- the 0 of `0F` read as the statement number. That produced a plausible
# and wrong answer on the first version of this tool.
LST = re.compile(r"^([0-9A-F]{6})\s+((?:[0-9A-F]{2,8}[ ]+)*)(\d{1,6})([+ ])\s*(.*?)\s*$")


def library_of(mod, base):
    for lib in sorted(os.listdir(os.path.join(DLIB, base))):
        if os.path.exists(os.path.join(DLIB, base, lib, mod + ".bin")):
            return lib
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("module")
    ap.add_argument("--src")
    ap.add_argument("--base", default="tk5", choices=("tk5", "ce"))
    a = ap.parse_args()
    mod = a.module
    src = a.src or os.path.join(ARCHIVE, mod + ".ASM")
    if not os.path.exists(src):
        hits = glob.glob(os.path.join(ROOT, "src", "*", mod + ".ASM")) + \
               glob.glob(os.path.join(ROOT, "work/src-pending", "*", mod + ".ASM"))
        if not hits:
            sys.exit(f"{mod}: no source at {src} and none in src/ or src-pending/")
        src = hits[0]
    lib = library_of(mod, a.base)
    if lib is None:
        sys.exit(f"{mod}: no {a.base} distribution-library member to compare against")

    tmp = os.path.join(ROOT, "work/measurements/where")
    os.makedirs(tmp, exist_ok=True)
    lst, obj = os.path.join(tmp, mod + ".lst"), os.path.join(tmp, mod + ".obj")
    subprocess.run([BIN] + flags() + [f"-a=" + lst, "-o", obj, src],
                   capture_output=True, env=dict(os.environ, **STAMP))
    if not os.path.exists(obj):
        sys.exit(f"{mod}: did not assemble -- see {lst}")

    base, rows = {}, []
    for line in open(lst, encoding="latin-1", errors="replace"):
        line = line.rstrip("\n")
        m = ESD.match(line)
        if m:
            base[m.group(1)] = int(m.group(3), 16)
            continue
        m = LST.match(line)
        if m:
            rows.append((int(m.group(1), 16), m.group(3), m.group(5)))
    rows.sort(key=lambda r: r[0])

    q = subprocess.run([CM, "--json", obj,
                        os.path.join(DLIB, a.base, lib, mod + ".bin")],
                       capture_output=True, text=True)
    d = json.loads(q.stdout)
    print(f"{mod}  ({lib}, {a.base})  source: {os.path.relpath(src, ROOT) if src.startswith(ROOT) else src}")
    if d.get("identical"):
        print("  identical")
        return 0
    for s in d.get("sections") or []:
        b = base.get(s["name"])
        cl = s.get("clusters") or []
        print(f"  {s['name']:10s} base=0x{b:06x}  {s['verdict']:10s} "
              f"text={s['diff_in_text']} holes={s['diff_in_holes']} "
              f"len={s['length_new']}/{s['length_ref']}" if b is not None else
              f"  {s['name']:10s} base=?  {s['verdict']}")
        if b is None:
            continue
        for c in cl:
            absu = b + c["offset"]
            owner = [r for r in rows if r[0] <= absu]
            o = owner[-1] if owner else (0, "", "?")
            print(f"     0x{c['offset']:04x} (abs 0x{absu:06x}) {c['length']:3d}B "
                  f"{'hole' if c['in_hole'] else 'text'}  "
                  f"wir={c['new'][:16]:16s} IBM={c['ref'][:16]:16s}")
            print(f"        stmt at 0x{o[0]:06x} |{o[2][:56]}|")
    return 1


if __name__ == "__main__":
    sys.exit(main())
