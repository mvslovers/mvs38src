#!/usr/bin/env python3
"""The same question, asked of open code: is there a shared cause left in the 605?

`macroattr.py` partitioned the 988 CSECTs that differ at equal length, and 605 of
them have every differing byte in open code with no macro family involved. That is
the workable population and the largest thing on the board. Whether it is 605
separate problems or a handful of causes has never been measured.

The move is the one that decided four macro families on 2026-09-14 — group the
differing clusters by `(our bytes, IBM's bytes)` — with the weighting that made it
work: **distinct modules, not clusters.** Ranking `macroattr`'s output by raw
cluster count put `WTO` on top with 45 modules, and 139 of its 158 clusters were
in DS holes, in 40 modules, all of them `fillgaps.py`'s answered population. By
distinct modules with text differences it is 11 and unremarkable.

Three views, because a cause can hide in any of them:

  pair      exact (ours, IBM) bytes -- finds `IGGCP14`'s wrong digit and the
            `×`/`|` code page, both of which were exactly this
  delta     signed difference for one-byte clusters -- finds displacement shifts,
            which is how the `±4` group surfaced
  stmt      the operation field of the owning statement -- finds a class that
            spans different bytes, e.g. every `DC C'…'` or every `MVC`

    opencode_families.py [--out FILE] [--all]

`--all` widens from the 605 to every open-code cluster in the 988, mixed modules
included. The default is the clean population: no macro anywhere in the module.
"""
import argparse, collections, json, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
sys.path.insert(0, HERE)
import seclocate as SL
import macroattr as MA

CM = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
TMP = os.path.join(ROOT, "work/measurements/macroattr")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(GATE, "opencode-families.tsv"))
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--top", type=int, default=20)
    a = ap.parse_args()

    rows = [l.rstrip("\n").split("\t") for l in open(os.path.join(GATE, "macroattr.tsv"))][1:]
    want = [r[0] for r in rows if a.all or r[1] == "all in open code"]
    print(f"{len(want)} modules", flush=True)

    tx = collections.defaultdict(list)
    for line in open(os.path.join(GATE, "org-tgt.txt"), encoding="latin-1"):
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

    pair = collections.defaultdict(set)
    delta = collections.defaultdict(set)
    stmt = collections.defaultdict(set)
    sample = {}
    seen = nclust = 0
    for m in want:
        obj, lst = os.path.join(TMP, m + ".obj"), os.path.join(TMP, m + ".lst")
        refs = MA.refs_for(m, tx, dl)
        if not (refs and os.path.exists(obj) and os.path.exists(lst)):
            continue
        q = subprocess.run([CM, "--json", "--csect", m, obj, refs[0]],
                           capture_output=True, text=True)
        try:
            s = next(x for x in json.loads(q.stdout)["sections"] if x["name"] == m)
        except Exception:
            continue
        rws, seq = MA.listing_rows(lst)
        if not rws:
            continue
        seen += 1
        origin = rws[0][0]
        for c in (s.get("clusters") or []):
            if c.get("in_hole"):
                continue
            st, call = MA.owner(rws, seq, origin + c["offset"])
            if not st or st[1]:            # macro-generated: macroattr's business
                continue
            nclust += 1
            k = (c["new"], c["ref"])
            pair[k].add(m)
            sample.setdefault(k, (m, c["offset"], st[2][:52]))
            if c.get("length") == 1:
                d = int(c["ref"], 16) - int(c["new"], 16)
                delta[d].add(m)
            op = MA.opname(st[2])
            stmt[op].add(m)
            sample.setdefault(("stmt", op), (m, c["offset"], st[2][:52]))

    print(f"{seen} measured, {nclust} open-code text clusters\n")

    def show(title, d, fmt):
        print(f"=== {title}")
        for k, ms in sorted(d.items(), key=lambda x: -len(x[1]))[:a.top]:
            ex = sample.get(k if not isinstance(k, str) else ("stmt", k))
            tail = f"   e.g. {ex[0]} 0x{ex[1]:04x} |{ex[2]}|" if ex else ""
            print(f"   {fmt(k):40s} {len(ms):4d} modules{tail}")
        print()

    show("(our bytes -> IBM's), by distinct modules", pair,
         lambda k: f"{k[0][:16]} -> {k[1][:16]}")
    show("signed byte delta, one-byte clusters", delta, lambda k: f"{k:+d}")
    show("operation field of the owning statement", stmt, lambda k: k)

    with open(a.out, "w") as fh:
        fh.write("kind\tkey\tmodules\texample_module\texample_offset\texample_statement\n")
        for k, ms in sorted(pair.items(), key=lambda x: -len(x[1])):
            ex = sample.get(k, ("", 0, ""))
            fh.write(f"pair\t{k[0]}->{k[1]}\t{len(ms)}\t{ex[0]}\t{ex[1]:#06x}\t{ex[2]}\n")
        for k, ms in sorted(delta.items(), key=lambda x: -len(x[1])):
            fh.write(f"delta\t{k:+d}\t{len(ms)}\t\t\t\n")
        for k, ms in sorted(stmt.items(), key=lambda x: -len(x[1])):
            ex = sample.get(("stmt", k), ("", 0, ""))
            fh.write(f"stmt\t{k}\t{len(ms)}\t{ex[0]}\t{ex[1]:#06x}\t{ex[2]}\n")
    print(f"-> {a.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
