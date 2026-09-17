#!/usr/bin/env python3
"""Does a control record hold its ID/length list before or after its RLD info?

The `dasm370` session reported on 2026-09-17 that both `cmplmd370` and `dasm370`
read a bound member's RLD info four bytes late, because both computed the RLD
offset as `16 + idlen` -- the ID/length list first -- where the record in fact
carries the RLD info first and the list after it. `docs/load-module-format.md` §4
documents the list at offset 16, which is right for every record that has no RLD
info at all, and that is exactly the case where the two orders cannot be told
apart.

`cmplmd370` is this project's verdict instrument: `recovered` is defined as it
exiting 0, and a desynchronised RLD parse leaves a relocated field unmasked, which
then reads as an ordinary text difference. So the diagnosis is not taken on
report. This checks it against our own 13,102 members, with the loader's own
arbiter and nobody's parser but ours.

**The arbiter.** A control record's bytes 14-15 are the CCW count: the number of
text bytes the loader is about to read. Its ID/length list gives, per CSECT in
that text, a CESD-ID and a length. The lengths must add up to the CCW count. Read
the list from the wrong place and they do not. That is a closed check on a single
record -- no reference, no second tool, no assumption about what the RLD items
mean.

    ctlorder.py [members...]        default: every .bin under dlib-bytes + target-bytes

**One member of 7,749 does not walk**, and it is named rather than swallowed:
`LINKLIB/HEWLF064` -- the linkage editor itself -- reads 33 records cleanly and
then has 28 bytes left over that are not a record. `cmplmd370` reports the same
thing as `trailing_bytes`, so it is an artefact of how the member image was
extracted and not a record this parser cannot read. It carries none of the records
this tool counts, so it changes nothing here.

Record walking follows `docs/load-module-format.md` §3-§10: CESD `8+n`, SYM `4+n`,
scatter `4+n`, IDR `1+n`, control/RLD `16+idlen+rldlen`, and a control record whose
byte 0 has `X'01'` is followed by a raw text record of the CCW count.
"""
import collections, glob, os, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
B16 = lambda b, o: int.from_bytes(b[o:o + 2], "big")


def records(b):
    """(offset, length, byte0) for every record, or None if the walk desynchronises.

    A walk that runs off the end or onto an impossible length is reported as a
    failure rather than truncated: a member this parser cannot read must not be
    counted as a member that agrees.
    """
    out, o, n = [], 0, len(b)
    while o < n:
        t = b[o]
        if t in (0x20, 0x28):
            ln = 8 + B16(b, o + 6)
        elif t == 0x40:
            ln = 4 + B16(b, o + 2)
        elif t == 0x10:
            ln = 4 + int.from_bytes(b[o + 1:o + 4], "big")
        elif t == 0x80:
            ln = 1 + b[o + 1]
        elif t & 0xF0 == 0:
            ln = 16 + B16(b, o + 4) + B16(b, o + 6)
        else:
            return None
        if ln <= 0 or o + ln > n:
            return None
        out.append((o, ln, t))
        if t & 0xF0 == 0 and t & 0x01:
            tl = B16(b, o + 14)
            if o + ln + tl > n:
                return None
            out.append((o + ln, tl, -1))
            o += ln + tl
        else:
            o += ln
    return out


def check(b):
    """(list-after-RLD agrees, list-at-16 agrees, records with both lists)."""
    rs = records(b)
    if rs is None:
        return None
    after = first = both = 0
    for o, ln, t in rs:
        if t < 0 or t & 0xF0 or not t & 0x01:
            continue
        idlen, rldlen = B16(b, o + 4), B16(b, o + 6)
        if not idlen or not rldlen:
            continue
        both += 1
        want = B16(b, o + 14)
        for base, hit in ((o + 16 + rldlen, "after"), (o + 16, "first")):
            s = sum(B16(b, base + k + 2) for k in range(0, idlen, 4))
            if s == want:
                if hit == "after":
                    after += 1
                else:
                    first += 1
    return after, first, both


def main():
    paths = sys.argv[1:]
    if not paths:
        for d in ("work/measurements/dlib-bytes/tk5", "work/measurements/target-bytes/tk5"):
            paths += sorted(glob.glob(os.path.join(ROOT, d, "*", "*.bin")))
    c = collections.Counter()
    disagree = []
    for p in paths:
        b = open(p, "rb").read()
        r = check(b)
        if r is None:
            c["unwalkable"] += 1
            continue
        after, first, both = r
        c["members"] += 1
        if both:
            c["members with such a record"] += 1
        c["records with both lists"] += both
        c["agrees with list AFTER the RLD info"] += after
        c["agrees with list AT OFFSET 16"] += first
        if both and after != both:
            disagree.append((os.path.basename(p), after, both))
    for k in ("members", "unwalkable", "members with such a record",
              "records with both lists", "agrees with list AFTER the RLD info",
              "agrees with list AT OFFSET 16"):
        print(f"{c[k]:8,}  {k}")
    if disagree:
        print(f"\n{len(disagree)} members where the after-RLD reading does NOT "
              f"account for every such record:")
        for n, a, t in disagree[:20]:
            print(f"  {n:14s} {a} of {t}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
