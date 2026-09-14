#!/usr/bin/env python3
"""A second date format nobody was looking for: yy.ddd in the eyecatcher.

asmdate_sweep.py hunts `mm/dd/yy`, which is what &SYSDATE produces. These carry
`73.241` against IBM's `79.137` -- a Julian date, and it differs per module, so it
is a constant in the source rather than the assembler's stamp. That makes it
maintenance level written into the eyecatcher, and option A territory: six bytes
transcribed from the object.
"""
import collections, json, os, re, subprocess, sys
sys.path.insert(0, "tools")
import seclocate as SL, macroattr as MA
CM = "work/src-states/bin/cmplmd370"; TMP = "work/measurements/macroattr"
JUL = re.compile(rb"[\xf0-\xf9]{2}\x4b[\xf0-\xf9]{3}")

rows = [l.rstrip("\n").split("\t") for l in
        open("work/measurements/baseline-gate/macroattr.tsv")][1:]
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

stat = collections.Counter(); only = []; examples = []
for r in rows:
    m = r[0]
    obj, lst = os.path.join(TMP, m + ".obj"), os.path.join(TMP, m + ".lst")
    refs = MA.refs_for(m, tx, dl)
    if not (refs and os.path.exists(obj)):
        continue
    ours = SL.deck_text(obj, m)
    if not ours:
        continue
    hits = [mt.start() for mt in JUL.finditer(ours)]
    if not hits:
        continue
    stat["decks carrying a yy.ddd date"] += 1
    q = subprocess.run([CM, "--json", "--csect", m, obj, refs[0]], capture_output=True, text=True)
    try:
        s = next(x for x in json.loads(q.stdout)["sections"] if x["name"] == m)
    except Exception:
        continue
    if s.get("identical"):
        stat["  already identical"] += 1; continue
    if s.get("length_differs"):
        stat["  length differs"] += 1; continue
    cl = s.get("clusters") or []
    span = [(i, i + 6) for i in hits]
    inside = [c for c in cl if any(a <= c["offset"] < b or
                                   c["offset"] <= a < c["offset"] + c["length"]
                                   for a, b in span)]
    if not inside:
        stat["  the date MATCHES, other bytes differ"] += 1; continue
    if len(inside) == len(cl):
        stat["  the date is the WHOLE difference"] += 1
        only.append(m)
    else:
        stat["  the date differs, and so does other code"] += 1
    if len(examples) < 10:
        i = hits[0]
        th = bytearray(ours)
        for c in cl:
            th[c["offset"]:c["offset"] + c["length"]] = bytes.fromhex(c["ref"])
        examples.append((m, ours[i:i+6].decode("cp037"), bytes(th[i:i+6]).decode("cp037")))

for k, v in stat.most_common():
    print(f"  {k:44s} {v}")
print("\nours -> IBM:")
for m, a, b in examples:
    print(f"   {m:10s} {a} -> {b}")
if only:
    print(f"\nRECOVERABLE by transcribing six bytes ({len(only)}): {only}")
