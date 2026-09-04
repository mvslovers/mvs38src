#!/usr/bin/env python3
"""Minimal AWS tape reader.

Block header, 6 bytes: curblk (u16 LE), prevblk (u16 LE), flags1, flags2.
flags1: 0x80 end-of-record, 0x40 start-of-record, 0x20 tape mark.
A tape mark separates files.
"""
import sys, struct

E2A = bytes(range(256)).decode('cp037').encode('latin-1', 'replace')

def files(path):
    """Yield (file_index, [logical_record, ...])."""
    with open(path, 'rb') as f:
        idx, recs, cur = 1, [], b''
        while True:
            hdr = f.read(6)
            if len(hdr) < 6:
                break
            cur_len, prev_len, fl1, fl2 = struct.unpack('<HHBB', hdr)
            if fl1 & 0x40 and not (fl1 & 0x80):   # start of a split record
                cur = b''
            if cur_len == 0:                       # tape mark
                if recs:
                    yield idx, recs
                    idx += 1
                    recs = []
                continue
            data = f.read(cur_len)
            cur += data
            if fl1 & 0x80 or fl1 == 0:             # end of record
                recs.append(cur)
                cur = b''
        if recs:
            yield idx, recs

def label(rec):
    if len(rec) >= 4:
        t = rec[:4].translate(E2A).decode('latin-1', 'replace')
        if t in ('VOL1', 'HDR1', 'HDR2', 'EOF1', 'EOF2', 'EOV1', 'EOV2'):
            return t, rec.translate(E2A).decode('latin-1', 'replace')
    return None, None

if __name__ == '__main__':
    path = sys.argv[1]
    for idx, recs in files(path):
        kind, text = label(recs[0])
        total = sum(len(r) for r in recs)
        if kind:
            print(f"  Datei {idx:2d}: LABEL {kind}  {text[:56].strip()}")
        else:
            print(f"  Datei {idx:2d}: DATEN  {len(recs):7d} Sätze, {total/1e6:8.2f} MB, "
                  f"Satzlänge {len(recs[0])}")
