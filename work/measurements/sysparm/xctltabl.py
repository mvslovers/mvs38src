#!/usr/bin/env python3
"""XCTLTABL emits &CODE as DC CL6, defaulting to 'Y02080' when &SYSPARM is empty.

Same shape as MODID: length-neutral, so invisible to lenlist.py, and only a byte
difference. The question is the same one -- does IBM's object hold the default?
"""
import collections, json, os, subprocess, sys
sys.path.insert(0, "tools")
from decks import CURRENT
import seclocate as SL

CM = "work/src-states/bin/cmplmd370"
NEEDLE = "Y02080".encode("cp037")

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

stats = collections.Counter()
examples, only = [], []
for f in sorted(os.listdir("work/src-states/overlay")):
    if not f.endswith(".ASM"):
        continue
    m = f[:-4]
    deck = os.path.join(CURRENT, m + ".obj")
    if not os.path.exists(deck):
        continue
    ours = SL.deck_text(deck, m)
    if not ours:
        continue
    i = ours.find(NEEDLE)
    if i < 0:
        continue
    stats["decks carrying the default Y02080"] += 1
    refs = [os.path.join(SL.TGT, l, mm + ".bin") for l, mm in tx.get(m, [])]
    refs = [r for r in refs if os.path.exists(r)] or ([dl[m]] if m in dl else [])
    if not refs:
        stats["  no reference"] += 1
        continue
    q = subprocess.run([CM, "--json", "--csect", m, deck, refs[0]], capture_output=True, text=True)
    if not q.stdout.strip():
        stats["  unreadable"] += 1
        continue
    try:
        s = next(x for x in json.loads(q.stdout)["sections"] if x["name"] == m)
    except (json.JSONDecodeError, StopIteration, KeyError):
        stats["  unreadable"] += 1
        continue
    if s.get("identical"):
        stats["  already identical (so IBM has Y02080 too)"] += 1
        continue
    if s.get("length_differs"):
        stats["  length differs as well"] += 1
        continue
    cl = s.get("clusters") or []
    inside = [c for c in cl if c["offset"] < i + 6 and i < c["offset"] + c["length"]]
    if inside:
        stats["  the CL6 differs" + ("  AND it is the only difference" if len(cl) == len(inside) else "")] += 1
        if len(examples) < 12:
            # Rebuild IBM's section: at equal length it is ours with each
            # cluster's ref bytes substituted at that cluster's own offset.
            # Slicing one cluster's hex by (i - offset) is wrong whenever the
            # field straddles a cluster edge, and it printed 'VS' for every
            # module before this.
            th = bytearray(ours)
            for c in cl:
                th[c["offset"]:c["offset"] + c["length"]] = bytes.fromhex(c["ref"])
            examples.append((m, bytes(th[i:i + 6]).decode("cp037", "replace")))
        if len(cl) == len(inside):
            only.append(m)
    else:
        stats["  the CL6 MATCHES, other bytes differ"] += 1

for k, v in stats.most_common():
    print(f"  {k:46s} {v}")
print("\nwhat IBM holds there instead:")
for m, t in examples:
    print(f"   {m:10s} {t!r}")
if only:
    print(f"\nmodules where the CL6 is the WHOLE difference: {only}")
