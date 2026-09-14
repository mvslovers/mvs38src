#!/usr/bin/env python3
"""One question per macro family: does it expand differently, the way XCTL does?

For each owner in macroattr.tsv, collect every TEXT cluster it owns and group by
(our bytes, IBM's bytes). A family with one shared cause shows one dominant cell;
a family that is really N unrelated modules shows N singletons -- the test that
killed the +8 cell and confirmed the x/| one.
"""
import collections, json, os, subprocess, sys
sys.path.insert(0, "tools")
import seclocate as SL, macroattr as MA

CM = "work/src-states/bin/cmplmd370"
TMP = "work/measurements/macroattr"
WANT = sys.argv[1:] or ["IEAPMNIP", "SETFRR", "HMASMMGP", "FREEMAIN", "GETMAIN",
                        "SETLOCK", "IECPDINI", "IECRES", "READ", "WTOR"]

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

fam = collections.defaultdict(lambda: collections.defaultdict(set))
where = collections.defaultdict(list)
for r in rows:
    m = r[0]
    if not any(w + ":" in r[4] for w in WANT):
        continue
    obj, lst = os.path.join(TMP, m + ".obj"), os.path.join(TMP, m + ".lst")
    refs = MA.refs_for(m, tx, dl)
    if not (refs and os.path.exists(obj) and os.path.exists(lst)):
        continue
    q = subprocess.run([CM, "--json", "--csect", m, obj, refs[0]], capture_output=True, text=True)
    try:
        s = next(x for x in json.loads(q.stdout)["sections"] if x["name"] == m)
    except Exception:
        continue
    rws, seq = MA.listing_rows(lst)
    if not rws:
        continue
    org = rws[0][0]
    for c in (s.get("clusters") or []):
        if c.get("in_hole"):
            continue
        stmt, call = MA.owner(rws, seq, org + c["offset"])
        if not (stmt and stmt[1] and call):
            continue
        name = MA.opname(call[1])
        if name not in WANT:
            continue
        fam[name][(c["new"][:16], c["ref"][:16])].add(m)
        if len(where[name]) < 3:
            where[name].append((m, c["offset"], c["new"][:24], c["ref"][:24], stmt[2][:46]))

for name in WANT:
    cells = fam.get(name)
    if not cells:
        continue
    mods = set().union(*cells.values())
    top = sorted(cells.items(), key=lambda x: -len(x[1]))[:4]
    share = len(top[0][1]) / len(mods)
    print(f"\n=== {name}: {len(mods)} modules, {len(cells)} distinct (ours,IBM) cells")
    print(f"    biggest cell covers {len(top[0][1])} of them ({share:.0%})")
    for (a, b), ms in top:
        print(f"      {a:18s} -> {b:18s}  {len(ms):3d} modules")
    for m, off, a, b, st in where[name]:
        print(f"      e.g. {m:9s} 0x{off:04x} {a} -> {b}   |{st}|")
