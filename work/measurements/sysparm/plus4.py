#!/usr/bin/env python3
"""The +-4 group: length-equal, every cluster a displacement off by the same amount.

A uniform displacement delta at EQUAL total length means two length errors that
cancel: N bytes too many somewhere and N too few somewhere else. The question is
where the boundary sits -- below it the displacements agree, above it they are
off by N, and the switch point is the byte that is actually missing.
"""
import collections, json, os, subprocess, sys, concurrent.futures
sys.path.insert(0, "tools")
from macpath import flags
from decks import CONTROL
import seclocate as SL, sysparm_sweep as SW

CM = "work/src-states/bin/cmplmd370"
TMP = "work/measurements/sysparm/second"

rest = [l.rstrip("\n").split("\t") for l in open("work/measurements/baseline-gate/sysparm-rest.tsv")][1:]
mods = [m for m, o in rest if o == "tried, still differs"]
tx = collections.defaultdict(list)
for line in open(os.path.join(SL.GATE, "org-tgt.txt"), encoding="latin-1"):
    f = line.split()
    if len(f) >= 5 and f[2] == "INCLUDE":
        tx[f[3]].append((f[0], f[1]))
dl = {}
for lib in sorted(os.listdir(SL.DLIB)):
    d = os.path.join(SL.DLIB, lib)
    if os.path.isdir(d):
        for fn in os.listdir(d):
            if fn.endswith(".bin"):
                dl.setdefault(fn[:-4], os.path.join(d, fn))

def one(m):
    refs = [os.path.join(SL.TGT, l, mm + ".bin") for l, mm in tx.get(m, [])]
    refs = [r for r in refs if os.path.exists(r)] or ([dl[m]] if m in dl else [])
    if not refs:
        return None
    ref = refs[0]
    obj = os.path.join(TMP, m + ".obj")
    if not os.path.exists(obj):
        return None
    q = subprocess.run([CM, "--json", "--csect", m, obj, ref], capture_output=True, text=True)
    if not q.stdout.strip():
        return None
    try:
        s = next(x for x in json.loads(q.stdout)["sections"] if x["name"] == m)
    except (json.JSONDecodeError, StopIteration, KeyError):
        return None
    if s["length_differs"] or s["identical"]:
        return None
    cl = s["clusters"]
    ds = [int(c["ref"], 16) - int(c["new"], 16) for c in cl
          if c["length"] == 1]
    if not ds:
        return None
    return m, s, cl, collections.Counter(ds)

with concurrent.futures.ThreadPoolExecutor(6) as ex:
    res = [r for r in ex.map(one, mods) if r]

for delta in (4, -4):
    fam = [(m, s, cl, c) for m, s, cl, c in res if c and c.most_common(1)[0][0] == delta]
    print(f"\n===== modules whose commonest one-byte delta is {delta:+d}: {len(fam)}")
    for m, s, cl, c in sorted(fam):
        one_b = [x for x in cl if x["length"] == 1]
        offs = [x["offset"] for x in one_b]
        purity = c[delta] / sum(c.values())
        print(f"  {m:10s} len {s['length_new']:5d}  clusters {len(cl):3d}  1-byte {len(one_b):3d}  "
              f"{delta:+d}-share {purity:.0%}  offsets 0x{min(offs):04x}..0x{max(offs):04x}")
        big = [x for x in cl if x["length"] > 1]
        for x in big[:2]:
            print(f"        multi 0x{x['offset']:04x} len {x['length']:3d} "
                  f"ours={x['new'][:32]} IBM={x['ref'][:32]}")
