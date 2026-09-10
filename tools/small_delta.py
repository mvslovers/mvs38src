#!/usr/bin/env python3
"""The cheapest cases in the tree: modules whose whole divergence is a few bytes.

A module that differs from IFOX00 in one to four bytes, at addresses both
assemblers agree exist, is a witness rather than a class. There is no length
deficit to unpick and no card to align -- the object says *this instruction is
wrong* and points at it. That is the shape cc370 can act on fastest, and
`cluster_remaining.py` only ever reported the count.

Read it with `witness.py`, which turns an address into the statement that
generated it. Where the two agree on a construct across several modules, the
family is real; where a module stands alone, it is one instruction to open.

**Re-derive after every merge**, like every other class list here: it is a
snapshot of the assembler.

    small_delta.py [--max N]        # default 4
"""
import os, sys, collections

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
TXT, END = b"\xe3\xe7\xe3", b"\xc5\xd5\xc4"


def image(p):
    """Address-keyed by (ESDID, address). A deck's cards are an encoding."""
    d, out = open(p, "rb").read(), {}
    for i in range(0, len(d), 80):
        c = d[i:i + 80]
        if c[1:4] == TXT:
            a = int.from_bytes(c[5:8], "big")
            n = int.from_bytes(c[10:12], "big")
            e = int.from_bytes(c[14:16], "big")
            for k in range(n):
                out[(e, a + k)] = c[16 + k]
    return out


def main():
    mx = int(sys.argv[sys.argv.index("--max") + 1]) if "--max" in sys.argv else 4
    head = open(f"{RUN}/module-table.tsv").readline().rstrip("\n").split("\t")
    H = {h: i for i, h in enumerate(head)}
    rows = [l.split("\t") for l in
            open(f"{RUN}/module-table.tsv").read().splitlines()[1:]]
    nid = [r[0] for r in rows
           if r[H["tool"]] != "identical" and not r[H["excluded"]]]

    out, pairs = [], collections.Counter()
    for m in nid:
        pa, pi = f"{RUN}/as370/{m}.obj", f"{RUN}/decks/{m}.obj"
        if not (os.path.exists(pa) and os.path.exists(pi)):
            continue
        ia, ii = image(pa), image(pi)
        if set(ia) != set(ii):          # same address set only: no length case
            continue
        d = sorted(k for k in ia if ia[k] != ii[k])
        if 0 < len(d) <= mx:
            out.append((len(d), m, [(e, a, ii[(e, a)], ia[(e, a)]) for e, a in d]))
            for e, a in d:
                pairs[(ii[(e, a)], ia[(e, a)])] += 1
    out.sort()

    with open(f"{RUN}/small-delta.tsv", "w") as f:
        f.write("module\tbytes\tesdid\taddress\tifox\tas370\n")
        for n, m, ds in out:
            for e, a, i_, a_ in ds:
                f.write(f"{m}\t{n}\t{e}\t{a:06X}\t{i_:02X}\t{a_:02X}\n")
    with open(f"{RUN}/classes/small-delta.txt", "w") as f:
        f.write("".join(f"{m}\n" for _, m, _ in out))

    print(f"{len(nid)} modules differ from IFOX00")
    print(f"{len(out)} of them in 1-{mx} bytes, at addresses both sides agree exist\n")
    for n in range(1, mx + 1):
        k = [m for c, m, _ in out if c == n]
        if k:
            print(f"  {n} byte(s): {len(k):3d}   {' '.join(k)}")
    print("\nrecurring byte pairs (IFOX -> as370), 2 or more sites:")
    for (i_, a_), n in pairs.most_common():
        if n > 1:
            print(f"  {n:3d}  {i_:02X} -> {a_:02X}")
    print(f"\n{RUN}/small-delta.tsv, classes/small-delta.txt")


if __name__ == "__main__":
    main()
