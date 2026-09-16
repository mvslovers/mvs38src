#!/usr/bin/env python3
"""Two baseline_gate TSVs, compared as SETS and not as sizes.

TODO.md's control: "When a macro changes, compare the identical SETS before and
after, not their sizes." The same rule applies to a comparator change, and more
sharply -- a reader fix can move a module in either direction and a net figure
would hide it.
"""
import sys, collections, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "tools"))
import scoreboard

def load(p):
    rows = [l.rstrip("\n").split("\t") for l in open(p, encoding="utf-8")]
    i = {k: n for n, k in enumerate(rows[0])}
    return {r[i["module"]]: r for r in rows[1:] if len(r) >= len(rows[0])}, i

a, ia = load(sys.argv[1]); b, ib = load(sys.argv[2])
la, lb = os.path.basename(sys.argv[1]), os.path.basename(sys.argv[2])
print(f"A = {la}   {len(a)} modules")
print(f"B = {lb}   {len(b)} modules")
assert set(a) == set(b), f"different module sets: {len(set(a)^set(b))} differ"

for col in ("dlib_c", "tgt_c"):
    cross = collections.Counter()
    mods = collections.defaultdict(list)
    for m in a:
        va, vb = a[m][ia[col]], b[m][ib[col]]
        if va != vb:
            cross[(va, vb)] += 1
            mods[(va, vb)].append(m)
    print(f"\n=== {col}: transitions A -> B ===")
    if not cross:
        print("  none -- set-identical")
    for (va, vb), n in sorted(cross.items(), key=lambda x: -x[1]):
        ms = mods[(va, vb)]
        print(f"  {va:14s} -> {vb:14s} {n:5d}   {', '.join(ms[:8])}"
              + (" ..." if len(ms) > 8 else ""))

ida = {m for m in a if a[m][ia["tgt_c"]] == "identical"}
idb = {m for m in b if b[m][ib["tgt_c"]] == "identical"}
print(f"\ntgt_c identical: A {len(ida)}  B {len(idb)}  "
      f"gained {len(idb-ida)}  LOST {len(ida-idb)}")
if ida - idb:
    print("  LOST:", ", ".join(sorted(ida - idb)))

for lab, p in (("A", sys.argv[1]), ("B", sys.argv[2])):
    d = scoreboard.chosen_baseline(p)
    print(f"\nchosen[{lab}] = {d['chosen']} of {d['n']}   "
          f"dlib {d['dlib']}  tgt {d['tgt']}  both {d['both']}  "
          f"unread {d['unread']} (dlib says identical for {d['unread_dlib_ok']})  "
          f"no-target {d['no_tgt']}  disagree {d['disagree']}")
