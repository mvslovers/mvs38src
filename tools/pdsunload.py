#!/usr/bin/env python3
"""Read an IEBCOPY unload (RECFM=VS) off an AWS tape, member by member.

Written because `file370` recognises this container but parses zero members out
of a real MVS unload of an FB source library (cc370#113).

Record layout:

    RDW(4) SDW(4) [ header(12) key(KL) data(DL) ]...

    header  byte  6..8   TTR
            byte  9      key length: 8 for a directory block, 0 for data
            byte 10..11  data length

Two things are not obvious and both cost a wrong result if missed:

* A header with **data length 0 is the end-of-member mark**, not the end of the
  record. Another member can start behind it in the same record.
* The TTRs in the directory are those of the **original PDS** and do not match
  the ones in the data headers. The assignment runs over the sequence instead:
  members appear in ascending directory TTR, separated by the end marks. One
  end mark sits behind the directory and must be skipped, or every member gets
  its predecessor's text. Alias names share a TTR and therefore a member.

Control case for the reader: 527 of the 848 members of `MVSSRC.BLD.NEW.ASM`
also exist as files in `MVSBLD/`, and 438 of those come out byte-identical. The
rest differ in maintenance level, module state or code page — see
`docs/private-macros.md`.

    from pdsunload import members
    for name, cards in members('BLDMVS.AWS', 14):   # tape file 5, UTL.ASM
        ...

Cards are latin-1 strings of `lrecl` characters without a line ending. Write
them back with `.encode('latin-1')`, never as UTF-8.
"""
from awstape import files, E2A


def _blocks(path, fileidx):
    """Yield (ttr, kl, key, data); data is None for an end-of-member mark."""
    for idx, recs in files(path):
        if idx != fileidx:
            continue
        for r in recs[2:]:                          # skip COPYR1/COPYR2
            p = 8
            while p + 12 <= len(r):
                ttr = int.from_bytes(r[p+6:p+9], 'big')
                kl, dl = r[p+9], int.from_bytes(r[p+10:p+12], 'big')
                if dl == 0:                         # end of member
                    yield ttr, kl, b'', None
                    p += 12
                    continue
                if p + 12 + kl + dl > len(r):
                    break
                yield ttr, kl, r[p+12:p+12+kl], r[p+12+kl:p+12+kl+dl]
                p += 12 + kl + dl
        return


def directory(path, fileidx):
    """Return {member name: TTR}, alias names included."""
    d = {}
    for ttr, kl, key, data in _blocks(path, fileidx):
        if kl != 8 or data is None:
            continue
        used = int.from_bytes(data[0:2], 'big')
        p = 2
        while p + 12 <= used:
            raw = data[p:p+8]
            if raw == b'\xff' * 8:                  # end of the directory
                break
            d[raw.translate(E2A).decode('latin-1').rstrip()] = \
                int.from_bytes(data[p+8:p+11], 'big')
            p += 12 + (data[p+11] & 0x1f) * 2       # skip the user data
    return d


def members(path, fileidx, lrecl=80):
    """Yield (name, [records]) per member; records are latin-1 strings."""
    bynum = {}
    for name, ttr in directory(path, fileidx).items():
        bynum.setdefault(ttr, []).append(name)
    order = sorted(bynum)
    i, cur, seen = 0, [], False
    for ttr, kl, key, data in _blocks(path, fileidx):
        if kl != 0:
            continue
        if data is None:                            # end of member
            if not seen:                            # the mark behind the directory
                continue
            if i < len(order):
                for name in sorted(bynum[order[i]]):
                    yield name, cur
            i += 1
            cur = []
            continue
        seen = True
        txt = data.translate(E2A).decode('latin-1')
        cur.extend(txt[j:j+lrecl] for j in range(0, len(txt), lrecl))
    if cur and i < len(order):
        for name in sorted(bynum[order[i]]):
            yield name, cur
