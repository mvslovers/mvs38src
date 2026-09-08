#!/usr/bin/env python3
"""Cluster every module whose deck still differs from IFOX00, largest first.

The goal is `as370 == IFOX00` on all 5,528. Whether IBM's shipped object agrees
is a separate question and does not rank this work: a divergence is a divergence
whether or not there is a recovery behind it.

So this ranks by *mechanism size*. Two passes:

1. **Card-type signature** — which record types differ at all. A module whose ESD
   and RLD match and whose TXT differs is a different kind of case from one whose
   card count differs, and mixing them hides both.
2. **Byte-level pattern**, on the modules with few differing addresses. The
   image is rebuilt address-keyed (a deck's cards are an encoding, not the
   object), and each differing byte is read against the byte two positions
   before it: in an RX instruction that is the opcode, and the high nibble of the
   differing byte is the base register. That is how the base-register class was
   found -- 53 modules where `as370` writes B=0 and IFOX00 writes a real base.

**Re-derive after every merge.** Every class here is a snapshot of the assembler,
and sixteen merges have moved these numbers by more than a factor of two.

    cluster_remaining.py [--max-addr N]     # default 8
"""
import importlib.util, os, sys, collections

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
END = b"\xc5\xd5\xc4"

_spec = importlib.util.spec_from_file_location(
    "rt", os.path.join(os.path.dirname(os.path.abspath(__file__)), "retest.py"))
rt = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(rt)


def cards(p):
    d = open(p, "rb").read()
    return [d[i:i + 80] for i in range(0, len(d), 80)]


def signature(pa, pi):
    """Which card types differ, or how far the card counts are apart."""
    ca = [c for c in cards(pa) if c[1:4] != END]
    ci = [c for c in cards(pi) if c[1:4] != END]
    if len(ca) != len(ci):
        d = abs(len(ca) - len(ci))
        return f"card count differs (d {1 if d == 1 else '2-9' if d < 10 else '10+'})"
    df = [(x, y) for x, y in zip(ca, ci) if x[:72] != y[:72]]
    if not df:
        return "identical once END is excluded"
    ts = {x[1:4].decode("cp037") for x, _ in df} | {y[1:4].decode("cp037") for _, y in df}
    return f"only {'/'.join(sorted(ts))}"


def main():
    maxaddr = 8
    if "--max-addr" in sys.argv:
        maxaddr = int(sys.argv[sys.argv.index("--max-addr") + 1])
    head = open(f"{RUN}/module-table.tsv").readline().rstrip("\n").split("\t")
    H = {h: i for i, h in enumerate(head)}
    rows = [l.split("\t") for l in open(f"{RUN}/module-table.tsv").read().splitlines()[1:]]
    nid = [r for r in rows if r[H["tool"]] != "identical" and not r[H["excluded"]]]

    sig = collections.Counter()
    base, onebyte = [], []
    for r in nid:
        m = r[0]
        pa, pi = f"{RUN}/as370/{m}.obj", f"{RUN}/decks/{m}.obj"
        if not (os.path.exists(pa) and os.path.exists(pi)):
            sig["no deck on one side"] += 1
            continue
        sig[signature(pa, pi)] += 1

        ia, ii = rt._image(pa), rt._image(pi)
        hits = [(s, a) for s in ia for a in ia[s]
                if a in ii.get(s, {}) and ia[s][a] != ii[s][a]]
        if not hits or len(hits) > maxaddr:
            continue
        if len(hits) == 1:
            s, a = hits[0]
            onebyte.append((m, s, a, ii[s][a], ia[s][a]))
        # every differing byte is the B/D byte of an RX instruction, and only
        # the base-register nibble moved
        if all(ii[s].get(a - 2) is not None and 0x40 <= ii[s][a - 2] <= 0x7f
               and (ii[s][a] & 0x0f) == (ia[s][a] & 0x0f)
               and (ii[s][a] >> 4) != (ia[s][a] >> 4) for s, a in hits):
            base.append((m, [(ii[s][a] >> 4, ia[s][a] >> 4, ii[s][a - 2]) for s, a in hits]))

    print(f"{len(nid)} modules whose deck differs from IFOX00\n")
    for k, n in sig.most_common(15):
        print(f"  {n:5d}  {k}")

    print(f"\nRX base register, and nothing else ({len(base)} modules):")
    c = collections.Counter()
    for m, ps in base:
        for bi, ba, op in ps:
            c[f"IFOX B={bi:<2d} -> as370 B={ba}"] += 1
    for k, n in c.most_common(8):
        print(f"  {n:5d}  {k}")
    z = sum(1 for m, ps in base if all(ba == 0 for _, ba, _ in ps))
    print(f"  {z} of {len(base)} have as370 writing B=0 throughout")
    fam = collections.Counter(m[:4] for m, _ in base)
    print("  families:", dict(sorted(fam.items(), key=lambda x: -x[1])[:8]))

    with open(f"{RUN}/classes/base-register.txt", "w") as f:
        f.write("".join(f"{m}\n" for m, _ in sorted(base)))
    with open(f"{RUN}/base-register.tsv", "w") as f:
        f.write("module\taddresses\tifox_base\tas370_base\topcode\n")
        for m, ps in sorted(base):
            for bi, ba, op in ps:
                f.write(f"{m}\t{len(ps)}\t{bi}\t{ba}\t{op:#04x}\n")
    print(f"\n{RUN}/base-register.tsv, classes/base-register.txt")
    print(f"exactly one differing byte: {len(onebyte)} modules")


if __name__ == "__main__":
    main()
