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

    where.py <module> [--src PATH] [--base tk5|ce|tgt]

Without --src the archive copy is used. Exit 0 if the module is identical.

`--base tgt` is **TK5's target library**, the baseline the project chose on
2026-09-13 ([`docs/baseline-dlib-vs-target.md`](../docs/baseline-dlib-vs-target.md)).
That reference is a bound load module holding several CSECTs under a name that is
usually none of them, so the member is looked up in `LMDXRF38`'s extract and the
comparison is restricted to the one CSECT with `--csect`. Everything else --
section bases out of the listing's own ESD, owning statement by address -- is
unchanged, because it is a property of our side and not of the reference.

**One thing this cannot tell you on `--base tgt`.** Where the target CSECT is a
different length, `cmplmd370` stops and reports no clusters, so there is nothing
to attribute to a source line. The tool says so rather than printing an empty
list.
"""
import argparse, collections, glob, json, os, re, subprocess, sys

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


TGT = os.path.join(ROOT, "work/measurements/target-bytes/tk5")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")


def library_of(mod, base):
    for lib in sorted(os.listdir(os.path.join(DLIB, base))):
        if os.path.exists(os.path.join(DLIB, base, lib, mod + ".bin")):
            return lib
    return None


def target_ref(mod):
    """(label, path) of the bound module holding this CSECT in IBM's targets.

    Several may hold it; the one that differs least is the one worth looking at,
    so they are all tried and the best verdict wins -- the same rule
    `baseline_gate.py` uses, and for the same reason.
    """
    p = os.path.join(GATE, "org-tgt.txt")
    if not os.path.exists(p):
        sys.exit(f"{p}: missing -- run tools/fetch_xref.py")
    cands = []
    for line in open(p, encoding="latin-1"):
        f = line.split()
        if len(f) >= 5 and f[2] == "INCLUDE" and f[3] == mod:
            cands.append((f[0], f[1]))
    if not cands:
        sys.exit(f"{mod}: no CSECT of that name in IBM's target libraries")
    return [(f"{lib}({lmod})", os.path.join(TGT, lib, lmod + ".bin"))
            for lib, lmod in cands]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("module")
    ap.add_argument("--src")
    ap.add_argument("--base", default="tk5", choices=("tk5", "ce", "tgt"))
    a = ap.parse_args()
    mod = a.module
    src = a.src or os.path.join(ARCHIVE, mod + ".ASM")
    if not os.path.exists(src):
        hits = glob.glob(os.path.join(ROOT, "src", "*", mod + ".ASM")) + \
               glob.glob(os.path.join(ROOT, "work/src-pending", "*", mod + ".ASM"))
        if not hits:
            sys.exit(f"{mod}: no source at {src} and none in src/ or src-pending/")
        src = hits[0]
    if a.base == "tgt":
        refs, lib = target_ref(mod), None
    else:
        lib = library_of(mod, a.base)
        if lib is None:
            sys.exit(f"{mod}: no {a.base} distribution-library member to compare against")
        refs = [(f"{lib}", os.path.join(DLIB, a.base, lib, mod + ".bin"))]

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

    best = None
    for label, path in refs:
        if not os.path.exists(path):
            print(f"  note: {label} not pulled -- {path}")
            continue
        cmd = [CM, "--json"] + (["--csect", mod] if a.base == "tgt" else []) \
            + [obj, path]
        q = subprocess.run(cmd, capture_output=True, text=True)
        if not q.stdout.strip():
            print(f"  note: {label} gave no verdict (rc {q.returncode})")
            continue
        try:
            dd = json.loads(q.stdout)
        except json.JSONDecodeError:
            print(f"  note: {label} produced no JSON")
            continue
        n = sum((s.get("diff_in_text") or 0) + (s.get("diff_in_holes") or 0)
                for s in dd.get("sections") or [])
        if dd.get("identical"):
            best = (label, dd, -1)
            break
        if best is None or n < best[2]:
            best = (label, dd, n)
    if best is None:
        sys.exit(f"{mod}: no usable {a.base} reference")
    label, d, _ = best
    print(f"{mod}  ({label}, {a.base})  source: {os.path.relpath(src, ROOT) if src.startswith(ROOT) else src}")
    if d.get("identical"):
        print("  identical")
        return 0
    secs = d.get("sections") or []
    if secs and all(s.get("length_differs") for s in secs) and \
            not any(s.get("clusters") for s in secs):
        for s in secs:
            print(f"  {s['name']:10s} LENGTH DIFFERS {s.get('length_new')}/"
                  f"{s.get('length_ref')} -- cmplmd370 reports no clusters for a "
                  f"length difference, so no byte can be attributed to a statement")
        return 1
    for s in secs:
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
