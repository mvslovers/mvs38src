#!/usr/bin/env python3
"""Cluster the remaining divergences by the *statement* that produced them.

Every class list in this repository so far is defined by what the deck looks
like -- which card types differ, how far the lengths are apart, which byte pairs
recur. That is the object side, and it has been mined: `small_delta.py` is down
to forty modules with no group above three.

Every mechanism found on 2026-09-09 came from the other side -- what the
assembler was *told* to do. #247 was `L 15,(FIELD-BASE)(9)`, #244 was
`DC AL1(&LEN)` inside `ENQ`. Both were read out of a listing, one module at a
time, and both were invisible in the byte histogram.

This does that for all of them. For each module whose deck differs it finds the
**first** address where the two objects part -- everything after it may be
consequence rather than cause -- resolves that address to the statement that
generated it, and clusters the statements.

The first address, not every address, is the whole point. A module missing four
hundred bytes scores as four hundred wrong bytes and one wrong statement.

    first_divergence.py [--jobs N] [--signal silent|loud|all]

`--signal` filters by `module-table.tsv`'s `signal` column, and the default is
**silent** for a reason worth stating. A module that cannot resolve its macros
still produces a deck and still has a first divergence, so the instrument cannot
tell *`as370` is wrong here* from *`as370` was never given what it needed*. On
2026-09-09 that was 85 of 357 modules answering a question nobody asked, and
thirteen of them were the largest cluster under the address constants.

**The population an instrument returns is the population it can see, not the one
the question is about.**
"""
import os, re, sys, subprocess, collections
from concurrent.futures import ThreadPoolExecutor

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
SRC = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
M = os.path.expanduser("~/repos/mvs/mvs38src/work/macros")
BIN = os.environ.get("AS370", os.path.expanduser("~/repos/mvs/cc370/as370/as370"))
MACS = sum([["-I", f"{M}/mvsce-2.1.4-dlib/{d}"] for d in
            ("AMACLIB", "AMODGEN", "AGENLIB", "ATSOMAC", "ATCAMMAC", "APVTMACS")],
           []) + ["-I", f"{M}/tape", "-I", f"{M}/mirror"]
TXT = b"\xe3\xe7\xe3"


def image(p):
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


def first_diff(pa, pi):
    """Lowest address where the two objects part -- content or presence."""
    ia, ii = image(pa), image(pi)
    for k in sorted(set(ia) | set(ii)):
        if ia.get(k) != ii.get(k):
            return k, ii.get(k), ia.get(k)
    return None, None, None


def statement(m, esdid, addr):
    """The listing line that generated that address, in that section."""
    lst = f"/tmp/fd-{m}.lst"
    if not os.path.exists(lst):
        subprocess.run(["perl", "-e", "alarm 200; exec @ARGV", BIN, "-ae", "-a=" + lst]
                       + MACS + ["-o", "/dev/null", f"{SRC}/{m}.ASM"],
                       capture_output=True)
    if not os.path.exists(lst):
        return None
    lines = open(lst, encoding="utf-8", errors="replace").read().splitlines()
    esd = {}
    for l in lines:
        g = re.match(r"^(\S{1,8}) +(SD|CM|PC) +([0-9A-F]{4}) ", l)
        if g:
            esd[int(g.group(3), 16)] = g.group(1)
    name, cur, rows = esd.get(esdid), None, {}
    for l in lines:
        g = re.match(r"^([0-9A-F]{6}) .{16,}?\d+[ +] *(\S+)? +(\S+)", l)
        if not g:
            continue
        if g.group(3).upper() in ("CSECT", "DSECT", "COM", "START"):
            cur = g.group(2) or cur
        rows.setdefault(cur, []).append((int(g.group(1), 16), l))
    best = None
    for loc, l in rows.get(name, []):
        if loc <= addr and (best is None or loc >= best[0]):
            best = (loc, l)
    os.remove(lst)
    return best[1] if best else None


def normalise(l):
    """Strip location, object code, statement number and sequence field."""
    s = re.sub(r"^[0-9A-F]{6} [0-9A-F ]{0,16} *(?:[0-9A-F]{5} +)?(?:[0-9A-F]{5} +)?", "", l)
    s = re.sub(r"^\s*\d+\+?\s*", "", s)
    s = re.sub(r"\s+\S{8}$", "", s.rstrip())     # sequence number
    return re.sub(r"\s+", " ", s).strip()


def main():
    jobs = int(sys.argv[sys.argv.index("--jobs") + 1]) if "--jobs" in sys.argv else 8
    sig = sys.argv[sys.argv.index("--signal") + 1] if "--signal" in sys.argv else "silent"
    KEEP = {"silent": {"silent divergence"},
            "loud": {"as370 alone flags"},
            "all": None}[sig]
    head = open(f"{RUN}/module-table.tsv").readline().rstrip("\n").split("\t")
    H = {h: i for i, h in enumerate(head)}
    rows = [r.split("\t") for r in
            open(f"{RUN}/module-table.tsv").read().splitlines()[1:]]
    nid = [r[0] for r in rows
           if r[H["tool"]] != "identical" and not r[H["excluded"]]
           and (KEEP is None or r[H["signal"]] in KEEP)]

    def one(m):
        pa, pi = f"{RUN}/as370/{m}.obj", f"{RUN}/decks/{m}.obj"
        if not (os.path.exists(pa) and os.path.exists(pi)):
            return None
        k, bi, ba = first_diff(pa, pi)
        if k is None:
            return None
        l = statement(m, k[0], k[1])
        return (m, k[0], k[1], bi, ba, l)

    out = []
    with ThreadPoolExecutor(jobs) as ex:
        for r in ex.map(one, nid):
            if r:
                out.append(r)

    fam = collections.Counter()
    where = collections.defaultdict(list)
    for m, e, a, bi, ba, l in out:
        k = normalise(l) if l else "(no statement -- address beyond the listing)"
        fam[k] += 1
        where[k].append(m)

    with open(f"{RUN}/first-divergence.tsv", "w") as f:
        f.write("module\tesdid\taddress\tifox\tas370\tstatement\n")
        for m, e, a, bi, ba, l in sorted(out):
            f.write(f"{m}\t{e}\t{a:06X}\t"
                    f"{'--' if bi is None else f'{bi:02X}'}\t"
                    f"{'--' if ba is None else f'{ba:02X}'}\t"
                    f"{normalise(l) if l else ''}\n")

    print(f"{len(nid)} modules ({sig}); first divergence resolved for {len(out)}\n")
    print("clustered by the statement that made it, largest first:\n")
    for k, n in fam.most_common(30):
        print(f"  {n:4d}  {k[:96]}")
        print(f"        {' '.join(sorted(where[k])[:8])}")
    print(f"\n{RUN}/first-divergence.tsv")


if __name__ == "__main__":
    main()
