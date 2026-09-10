#!/usr/bin/env python3
"""Is the deck well formed? -- the question the gate does not ask.

`retest.py` compares our deck with IFOX00's and reports how many bytes differ.
It is the best instrument here and it is **not a well-formedness check**: on
2026-09-09 cc370 built a change that produced a structurally malformed deck --
a section chained at the wrong origin, its TXT landing on top of another
section's, its ESD entry gone while the TXT remained -- and the gate line read
`+0, closer 1, none lost`. Green, on a deck no linkage editor would accept.

So this asks, of one deck alone, without any reference:

  1. every TXT card names an ESDID that the ESD defines as SD, PC or CM
  2. every TXT byte lies inside its section's declared origin..origin+length
  3. no two sections overlap
  4. every RLD position and relocation ESDID exists
  5. no ESDID is defined twice

**The control is IFOX00.** All 5,528 recorded reference decks must pass, and if
they do not the rule is wrong rather than the deck -- that is the only way to
tell a defect from a misunderstanding of the format.

    deck_lint.py [dir ...]        # default: the promoted as370 decks and IFOX00's
"""
import os, sys, collections

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
ESD, TXT, RLD, END = b"\xc5\xe2\xc4", b"\xe3\xe7\xe3", b"\xd9\xd3\xc4", b"\xc5\xd5\xc4"
SECT = {0x00, 0x04, 0x05}          # SD, PC, CM


def lint(path):
    d = open(path, "rb").read()
    sects, seen, bad = {}, {}, []
    for i in range(0, len(d), 80):
        c = d[i:i + 80]
        if c[1:4] != ESD:
            continue
        n = int.from_bytes(c[10:12], "big")
        eid = int.from_bytes(c[14:16], "big")
        for j in range(0, n, 16):
            nm = c[16 + j:24 + j].decode("cp037", errors="replace").strip()
            t = c[24 + j]
            # An LD entry carries no ESDID of its own -- it names the section
            # it belongs to in its own field and does NOT advance the counter.
            # Counting it made every module with an ENTRY look as though it
            # defined an id twice, which is how the second version of this tool
            # "found" 476 defects in IFOX00's decks.
            if t == 0x01:
                continue
            if eid in seen:
                bad.append(f"ESDID {eid} defined twice ({seen[eid]} and {nm})")
            seen[eid] = nm
            if t in SECT:
                sects[eid] = (nm, int.from_bytes(c[25 + j:28 + j], "big"),
                              int.from_bytes(c[29 + j:32 + j], "big"))
            eid += 1

    for i in range(0, len(d), 80):
        c = d[i:i + 80]
        if c[1:4] == TXT:
            a = int.from_bytes(c[5:8], "big")
            n = int.from_bytes(c[10:12], "big")
            e = int.from_bytes(c[14:16], "big")
            if e not in sects:
                bad.append(f"TXT at {a:06X} names ESDID {e}, which is "
                           + (f"'{seen[e]}' and not a section" if e in seen
                              else "not in the ESD"))
                continue
            nm, org, ln = sects[e]
            if a < org or a + n > org + ln:
                bad.append(f"TXT {a:06X}+{n} outside {nm} "
                           f"[{org:06X}..{org + ln:06X})")
        elif c[1:4] == RLD:
            n = int.from_bytes(c[10:12], "big")
            k, r, pp, cont = 16, None, None, False
            # RRPP FAAA, and bit 0x01 of the flag says the NEXT item repeats
            # the same R/P and is written as FAAA alone.  Getting this wrong
            # makes every continued RLD look like a dangling ESDID -- which is
            # how the first version of this tool "found" 1,855 defects in
            # IFOX00's own decks.
            while k < 16 + n:
                if not cont:
                    if k + 8 > 16 + n:
                        bad.append("RLD entry runs past the card")
                        break
                    r = int.from_bytes(c[k:k + 2], "big")
                    pp = int.from_bytes(c[k + 2:k + 4], "big")
                    for x, w in ((r, "relocation"), (pp, "position")):
                        if x not in seen:
                            bad.append(f"RLD {w} ESDID {x} not in the ESD")
                    k += 4
                if k + 4 > 16 + n:
                    bad.append("RLD entry runs past the card")
                    break
                cont = bool(c[k] & 0x01)
                k += 4

    ranges = sorted((org, org + ln, nm) for nm, org, ln in sects.values() if ln)
    for (a0, a1, n0), (b0, b1, n1) in zip(ranges, ranges[1:]):
        if b0 < a1:
            bad.append(f"sections overlap: {n0} [{a0:06X}..{a1:06X}) and "
                       f"{n1} [{b0:06X}..{b1:06X})")
    return bad


def main():
    dirs = sys.argv[1:] or [f"{RUN}/as370", f"{RUN}/decks"]
    for d in dirs:
        fs = sorted(f for f in os.listdir(d) if f.endswith(".obj"))
        hits = collections.Counter()
        who = collections.defaultdict(list)
        for f in fs:
            for b in lint(os.path.join(d, f)):
                k = b.split(":")[0].split(" [")[0]
                k = k if len(k) < 60 else k[:60]
                hits[k] += 1
                who[k].append(f[:-4])
        n = len({m for v in who.values() for m in v})
        print(f"{d}\n  {len(fs)} decks, {n} with a complaint")
        for k, v in hits.most_common(8):
            print(f"    {v:5d}  {k}")
            print(f"           {' '.join(sorted(set(who[k]))[:6])}")
        print()


if __name__ == "__main__":
    main()
