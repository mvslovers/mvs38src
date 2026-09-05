#!/usr/bin/env python3
"""Reader for AWS tape images (`*.AWS`, Hercules `awstape` format).

Each block is preceded by a 6-byte header: current length and previous length
as little-endian 16-bit values, then two flag bytes. The flags are the part
that is easy to get backwards, so they are spelled out:

    flags1  0x80  NEWREC    this block starts a logical record
            0x40  TAPEMARK  end of a tape file
            0x20  ENDREC    this block ends a logical record

A logical record may be split across several blocks: the first carries NEWREC,
the last ENDREC, the ones between neither. A tape mark has length 0.

This replaces the earlier `awsread.py`, which had NEWREC and ENDREC swapped and
took 0x20 for the tape mark. That reader still found the file boundaries (a
tape mark has length 0 either way) and the byte stream it produced was intact,
but every record boundary it reported was wrong.

    python3 awstape.py TAPE.AWS      print the structure of the tape

EBCDIC is translated with `E2A`: cp037 in, latin-1 out. Never UTF-8 — `X'5F'`
would become two bytes and shift every column behind it.
"""
import struct
import sys

E2A = bytes(range(256)).decode('cp037').encode('latin-1', 'replace')


def files(path):
    """Yield (file_index, [logical_record, ...]) for every file on the tape."""
    with open(path, 'rb') as f:
        idx, recs, cur = 1, [], b''
        while True:
            hdr = f.read(6)
            if len(hdr) < 6:
                break
            cur_len, prev_len, fl1, fl2 = struct.unpack('<HHBB', hdr)
            if fl1 & 0x40 or cur_len == 0:              # tape mark
                if recs:
                    yield idx, recs
                    idx += 1
                    recs = []
                continue
            data = f.read(cur_len)
            cur = data if fl1 & 0x80 else cur + data    # NEWREC starts over
            if fl1 & 0x20:                              # ENDREC completes it
                recs.append(cur)
                cur = b''
        if recs:
            yield idx, recs


def label(rec):
    """Return (kind, text) for a standard tape label, else (None, None)."""
    if len(rec) >= 4:
        kind = rec[:4].translate(E2A).decode('latin-1', 'replace')
        if kind in ('VOL1', 'HDR1', 'HDR2', 'EOF1', 'EOF2', 'EOV1', 'EOV2'):
            return kind, rec.translate(E2A).decode('latin-1', 'replace')
    return None, None


if __name__ == '__main__':
    for idx, recs in files(sys.argv[1]):
        kind, text = label(recs[0])
        total = sum(len(r) for r in recs)
        if kind:
            print(f"  file {idx:2d}: LABEL {kind}  {text[:56].strip()}")
        else:
            print(f"  file {idx:2d}: DATA  {len(recs):7d} records, "
                  f"{total/1e6:8.2f} MB, first record {len(recs[0])} bytes")
