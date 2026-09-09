#!/usr/bin/env python3
"""Sort an MVS FB/80 data set off-host, because MVS/CE has no sort product.

Dave's four verification jobs -- `ZLMDRPTD`, `ZLMDRPTT`, `ZCMPNUC`, `ZCMPSVC` --
each begin with two `PGM=SORT` steps over `SYS1.SORTLIB`.  On MVS/CE there is no
`SYS1.SORTLIB`, no `SORT` member in `SYS1.LINKLIB`, `SYS2.LINKLIB` or
`MVSSRC.BLD.LOAD`, and no distribution library that would populate the `SORTLIB`
the build allocates: the OS/VS sort was a separate program product and this
system does not carry it.  So `ZLMDRPTD` ends

    IEF212I RPTDLB SORT1 SORTLIB - DATA SET NOT FOUND

and the load-module cross-reference report -- the comparison of what was built
from source against the original DLIBs, which is the whole point of the exercise
-- never runs.  Dave anticipates half of this (v2.1 p. 9 says to change
`UNIT=SORT` to `UNIT=SYSDA` because TK5 dropped the esoteric name) but assumes
the sort program is there.

The sort itself is trivial: `SORT FIELDS=(1,40,CH,A)` over fixed 80-byte
records.  What is not trivial is the collating order.

**The key must be compared in EBCDIC, not ASCII.**  The two orders disagree on
exactly the characters these records are made of: in EBCDIC the digits sort
AFTER the letters and the lower-case letters before the upper, in ASCII it is
the other way round.  `LMDRPT38` reads the two sorted streams as a merge, so a
consistent order on both sides is what it needs -- but "consistent" is not
enough to trust when the program may also compare a key against a control
statement from `LMDSKIP`, which arrives in EBCDIC from the data set.  So this
sorts by the EBCDIC code point of every key byte.

mvsMF hands the records over already translated to text, so rather than fight
for a binary transfer this maps each character back through cp037 and sorts on
those bytes.  A character with no cp037 representation would silently reorder,
so it is an error rather than a fallback.

    lmdsort.py MVSSRC.BLD.NEW.LMDXRF.DLIB MVSSRC.BLD.NEW.LMDXRF.SORTED
    lmdsort.py --self-test
"""
import argparse, base64, sys, urllib.request

# mvsdev.lan, not mvsdev.  The bare name resolves through the search
# domain, and on 2026-09-09 that stopped working mid-run: the driver
# exhausted its retries on `nodename nor servname provided` at job 105 of
# 259, while `mvsdev.lan` resolved to 192.168.0.233 the whole time.  The
# retry loop was built for exactly this and could not help -- a name that
# does not resolve does not start resolving because you ask again.  ssh
# config has mapped mvsdev to mvsdev.lan all along.
HOST = "http://mvsdev.lan:8082"
USER, PW = "IBMUSER", "SYS1"
KEY = (0, 40)                      # SORT FIELDS=(1,40,CH,A)


def req(method, path, body=None):
    r = urllib.request.Request(f"{HOST}{path}", data=body, method=method)
    r.add_header("Authorization", "Basic " +
                 base64.b64encode(f"{USER}:{PW}".encode()).decode())
    if body is not None:
        r.add_header("Content-Type", "text/plain")
    return urllib.request.urlopen(r, timeout=300).read().decode("utf-8", "replace")


def ebcdic_key(rec):
    """The record's sort field as EBCDIC bytes -- the order MVS would use."""
    field = rec[KEY[0]:KEY[1]].ljust(KEY[1] - KEY[0])
    try:
        return field.encode("cp037")
    except UnicodeEncodeError as e:
        raise SystemExit(f"character outside cp037 in the sort field: {e}\n"
                         f"  record: {rec[:60]!r}\n"
                         f"  The transfer is not carrying EBCDIC losslessly and "
                         f"the sort order cannot be trusted. Stop here.")


def sort_records(lines):
    return sorted(lines, key=ebcdic_key)


def self_test():
    """The control: a case where ASCII and EBCDIC orders actually disagree."""
    recs = ["1ALPHA", "AALPHA", "aALPHA", "ZALPHA", "9ALPHA"]
    got = [r[0] for r in sort_records(recs)]
    ascii_order = [r[0] for r in sorted(recs)]
    # EBCDIC: lower-case < upper-case < digits.  ASCII: digits < upper < lower.
    assert got == ["a", "A", "Z", "1", "9"], got
    assert ascii_order == ["1", "9", "A", "Z", "a"], ascii_order
    assert got != ascii_order
    print("self-test ok -- EBCDIC order 'a A Z 1 9' differs from ASCII "
          "'1 9 A Z a', and the tool produces the EBCDIC one")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("source", nargs="?")
    ap.add_argument("target", nargs="?")
    ap.add_argument("--self-test", action="store_true")
    a = ap.parse_args()
    if a.self_test:
        return self_test()
    if not (a.source and a.target):
        ap.error("give a source and a target data set, or --self-test")

    text = req("GET", f"/zosmf/restfiles/ds/{a.source}")
    lines = [l.rstrip("\r") for l in text.split("\n")]
    if lines and lines[-1] == "":
        lines.pop()
    bad = [len(l) for l in lines if len(l) > 80]
    if bad:
        raise SystemExit(f"{len(bad)} records longer than 80 characters; this is "
                         f"not the FB/80 data set it claims to be")
    print(f"{a.source}: {len(lines)} records")

    out = sort_records(lines)
    assert len(out) == len(lines)
    # A sort that loses or invents a record is worse than no sort at all.
    assert sorted(out) == sorted(lines), "sort changed the multiset of records"
    print(f"  first key: {out[0][:40]!r}\n  last  key: {out[-1][:40]!r}")

    body = "\n".join(r.ljust(80) for r in out) + "\n"
    req("PUT", f"/zosmf/restfiles/ds/{a.target}", body.encode("latin-1"))
    back = req("GET", f"/zosmf/restfiles/ds/{a.target}")
    ok = [l.rstrip() for l in back.split("\n") if l.strip()]
    if len(ok) != len(out):
        raise SystemExit(f"round trip: wrote {len(out)}, read back {len(ok)}")
    print(f"{a.target}: {len(ok)} records written and read back")
    return 0


if __name__ == "__main__":
    sys.exit(main())
