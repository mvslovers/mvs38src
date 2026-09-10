#!/usr/bin/env python3
"""Summarise `deckvsdlib.py`'s rows into the tables the decision needs.

Three questions, in order of what they settle:

1. **The control.** Where TK5 and MVS/CE carry the same RMID the two verdicts
   must agree.  A disagreement is a defect in the harness or a module with a
   date compiled into its text -- either way it is looked at, not averaged in.
2. **The count.** How many modules does Dave Kreiss' source assemble to,
   byte-identical, on each system.
3. **The decision.** Within the modules where the two systems genuinely differ,
   which one does his source hit.  That is the only part where the two columns
   are measuring different object code, and it is where the baseline choice is
   actually made.

    deckvsdlib_report.py results.tsv
"""
import collections, sys


def load(p):
    rows, hdr = [], None
    for i, l in enumerate(open(p)):
        f = l.rstrip("\n").split("\t")
        if i == 0:
            hdr = f
            continue
        rows.append(dict(zip(hdr, f)))
    return rows


def table(title, pairs):
    w = max(len(k) for k, _ in pairs)
    print(f"\n{title}")
    for k, v in pairs:
        print(f"  {k:<{w}}  {v:>6}")


def main():
    rows = load(sys.argv[1])
    print(f"{len(rows)} modules compared")

    bad = [r for r in rows if "error" in (r["v_tk5"], r["v_ce"])
           or "absent" in (r["v_tk5"], r["v_ce"])]
    if bad:
        print(f"\n!! {len(bad)} modules could not be compared on one or both "
              f"sides -- excluded from every table below")
        for r in bad[:10]:
            print(f"   {r['module']:9s} {r['dlib']:8s} tk5={r['v_tk5']} ce={r['v_ce']}")
    rows = [r for r in rows if r not in bad]

    same = [r for r in rows if r["state"] == "same"]
    diff = [r for r in rows if r["state"] == "rmid-differs"]

    # 1. control
    disagree = [r for r in same if r["v_tk5"] != r["v_ce"]]
    table("CONTROL -- same RMID on both systems", [
        ("modules", len(same)),
        ("verdicts agree", len(same) - len(disagree)),
        ("verdicts DISAGREE", len(disagree)),
    ])
    for r in disagree[:20]:
        print(f"     {r['module']:9s} {r['dlib']:8s} tk5={r['v_tk5']:9s} "
              f"ce={r['v_ce']:9s} diff {r['diff_tk5']}/{r['diff_ce']}")

    # 2. counts
    def n(rs, col):
        return sum(1 for r in rs if r[col] == "identical")
    table("IDENTICAL -- Dave's source assembles to the shipped object", [
        ("all modules, vs TK5", n(rows, "v_tk5")),
        ("all modules, vs CE ", n(rows, "v_ce")),
        ("  same-RMID, vs TK5", n(same, "v_tk5")),
        ("  same-RMID, vs CE ", n(same, "v_ce")),
        ("  divergent, vs TK5", n(diff, "v_tk5")),
        ("  divergent, vs CE ", n(diff, "v_ce")),
    ])

    # 3. the decision
    c = collections.Counter((r["v_tk5"], r["v_ce"]) for r in diff)
    table("DECISION -- the modules where the two systems really differ", [
        ("modules", len(diff)),
        ("hits TK5 only", c[("identical", "differs")]),
        ("hits CE only", c[("differs", "identical")]),
        ("hits both", c[("identical", "identical")]),
        ("hits neither", c[("differs", "differs")]),
    ])

    only_tk5 = [r for r in diff if r["v_tk5"] == "identical" != r["v_ce"]]
    only_ce = [r for r in diff if r["v_ce"] == "identical" != r["v_tk5"]]
    for name, rs in (("TK5 only", only_tk5), ("CE only", only_ce)):
        if rs:
            print(f"\n  {name} ({len(rs)}):")
            for r in sorted(rs, key=lambda x: x["module"]):
                print(f"     {r['module']:9s} {r['dlib']:8s} "
                      f"TK5 {r['tk5_rmid'] or '-':8s} CE {r['ce_rmid'] or '-':8s}")

    # how near the misses are, on the side that loses
    near = collections.Counter()
    for r in diff:
        if r["v_tk5"] == r["v_ce"] == "differs":
            a, b = int(r["diff_tk5"]), int(r["diff_ce"])
            near["TK5 nearer" if a < b else "CE nearer" if b < a else "equal"] += 1
    table("Of the ones that hit neither, which side is nearer (bytes)",
          sorted(near.items()))
    return 0


if __name__ == "__main__":
    sys.exit(main())
