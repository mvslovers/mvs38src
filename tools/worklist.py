#!/usr/bin/env python3
"""Every module that is not identical to the chosen baseline, nearest first.

The 25 TSO cases left over from `fillgaps.py` were filed as "a real instruction or
constant differs -- hand work", and worked in that order they look like 25 equally
hard problems. Ranked by how many bytes actually differ they are not: on
2026-09-13 the six nearest were 1, 1, 2, 2, 4 and 5 bytes, all six were recovered,
and **four of the six needed no marker at all** -- an eyecatcher date, a message
number, a branch mask and two table constants. The mechanism was legible every
time.

So the ranking IS the method. This produces it for the whole tree rather than one
component, with the owning source statement beside each differing cluster, which is
the part that turns a byte count into a diagnosis.

    worklist.py [--out FILE] [--prefix IKJ] [--max-bytes 12] [--decks DIR]

Columns: module, total differing bytes, text/holes, clusters, the bound module the
comparison used, and one line per cluster with our bytes, IBM's, and the statement
that owns the address.

**Read the `agree` column before touching anything.** `SAME` means both of IBM's
libraries want the byte, `tgt-only` means the target carries maintenance the DLIB
never received, and `DIFFER` means they disagree -- and for a byte inside a hole or
an alignment pad, disagreement means neither is source
([`../docs/two-baselines-as-a-control.md`](../docs/two-baselines-as-a-control.md)).
"""
import argparse, collections, json, os, re, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from macpath import flags

ARCHIVE = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
BIN = os.path.join(ROOT, "work/src-states/bin/as370-main")
CM = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
DLIB = os.path.join(ROOT, "work/measurements/dlib-bytes/tk5")
TGT = os.path.join(ROOT, "work/measurements/target-bytes/tk5")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")
STAMP = dict(ASMDATE="09/07/26", ASMTIME="12.00")
ESD = re.compile(r"^(\S{1,8})\s+SD\s+([0-9A-F]{4})\s+([0-9A-F]{6})\s+([0-9A-F]{6})")
LST = re.compile(r"^([0-9A-F]{6})\s+((?:[0-9A-F]{2,8}[ ]+)*)(\d{1,6})([+ ])\s*(.*?)\s*$")


def target_map():
    m = collections.defaultdict(list)
    for line in open(os.path.join(GATE, "org-tgt.txt"), encoding="latin-1"):
        f = line.split()
        if len(f) >= 5 and f[2] == "INCLUDE":
            m[f[3]].append((f[0], f[1]))
    return m


def clusters(deck, ref, csect=None):
    cmd = [CM, "--json"] + (["--csect", csect] if csect else []) + [deck, ref]
    q = subprocess.run(cmd, capture_output=True, text=True)
    if not q.stdout.strip():
        return None
    try:
        d = json.loads(q.stdout)
    except json.JSONDecodeError:
        return None
    if d.get("identical"):
        return {}
    return {(s["name"], c["offset"]): (c["new"], c["ref"], c["in_hole"])
            for s in d.get("sections") or [] for c in s.get("clusters") or []}


def owners(lst):
    """(section bases, sorted [(addr, stmt, text)]) out of an as370 listing."""
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
    rows.sort()
    return base, rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(GATE, "worklist.txt"))
    ap.add_argument("--prefix", default=None, help="only modules starting with this")
    ap.add_argument("--max-bytes", type=int, default=16)
    ap.add_argument("--decks", default=os.path.join(ROOT, "obj_overlay5"),
                    help="decks of the CURRENT source state, for the ranking")
    a = ap.parse_args()

    rows = [l.rstrip("\n").split("\t")
            for l in open(os.path.join(GATE, "overlay-vs-both.tsv"))]
    i = {k: n for n, k in enumerate(rows[0])}
    tx = target_map()
    tmp = os.path.join(ROOT, "work/measurements/worklist")
    os.makedirs(tmp, exist_ok=True)

    cand = []
    for r in rows[1:]:
        mod = r[i["module"]]
        if a.prefix and not mod.startswith(a.prefix):
            continue
        if r[i["tgt_c"]] not in ("differs", "holes", "len-differs"):
            continue
        deck = os.path.join(a.decks, mod + ".obj")
        if not os.path.exists(deck):
            continue
        best = None
        for lib, lmod in tx.get(mod, []):
            p = os.path.join(TGT, lib, lmod + ".bin")
            if not os.path.exists(p):
                continue
            c = clusters(deck, p, mod)
            if c is None:
                continue
            n = sum(len(v[0]) // 2 for v in c.values())
            if best is None or n < best[0]:
                best = (n, c, f"{lib}({lmod})")
        if best and 0 < best[0] <= a.max_bytes:
            cand.append((best[0], mod, best[1], best[2]))
    cand.sort()

    dlibof = {}
    for lib in sorted(os.listdir(DLIB)):
        d = os.path.join(DLIB, lib)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith(".bin"):
                    dlibof.setdefault(f[:-4], os.path.join(d, f))

    out = open(a.out, "w")
    for n, mod, cl, lm in cand:
        src = os.path.join(ARCHIVE, mod + ".ASM")
        hits = [p for p in (os.path.join(ROOT, "src", l, mod + ".ASM")
                            for l in os.listdir(os.path.join(ROOT, "src")))
                if os.path.exists(p)]
        if hits:
            src = hits[0]
        if not os.path.exists(src):
            continue
        lst = os.path.join(tmp, mod + ".lst")
        subprocess.run([BIN] + flags() + ["-a=" + lst, "-o", os.path.join(tmp, mod + ".obj"), src],
                       capture_output=True, env=dict(os.environ, **STAMP))
        if not os.path.exists(lst):
            continue
        base, rws = owners(lst)
        D = clusters(os.path.join(a.decks, mod + ".obj"), dlibof[mod]) if mod in dlibof else None
        out.write(f"=== {mod}  {n} bytes  {lm}  src={os.path.relpath(src, ROOT)}\n")
        for k in sorted(cl):
            new, ref, hole = cl[k]
            d = (D or {}).get(k)
            agree = ("SAME" if d and d[0 if False else 1] == ref else
                     "tgt-only" if D is not None and k not in (D or {}) else "DIFFER")
            absu = base.get(k[0], 0) + k[1]
            own = [x for x in rws if x[0] <= absu]
            o = own[-1] if own else (0, "?", "?")
            out.write(f"    0x{k[1]:04x} {'hole' if hole else 'TEXT'} ours={new[:16]:16s} "
                      f"IBM={ref[:16]:16s} {agree}\n")
            out.write(f"        stmt {o[1]:>6s} |{o[2][:62]}|\n")
    out.close()
    print(f"{len(cand)} modules within {a.max_bytes} bytes of the target -> {a.out}")
    for n, mod, cl, lm in cand[:30]:
        print(f"   {mod:10s} {n:3d} bytes  {len(cl)} cluster(s)  {lm}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
