#!/usr/bin/env python3
"""Convert dasdpdsu output (raw EBCDIC, RECFM=FB 80) to host text.

    ebcdic2text.py <indir> <outdir> [reclen]

Two things this gets right, both of which cost a day on 2026-09-04:

  * dasdpdsu writes the member's bytes with no record separators at all. The
    members are fixed-length records, so the stream has to be cut into reclen
    chunks before anything can read it.

  * The output must be single-byte. cp037 in, latin-1 out. Writing UTF-8 turns
    EBCDIC X'5F' (the not sign) into two bytes and shifts every column after it
    one to the right. In fixed-format assembler that is fatal: column 72 is the
    continuation column and 73-80 the sequence number, so a shifted line silently
    changes what the assembler sees.
"""
import pathlib, sys

def convert(src: pathlib.Path, dst: pathlib.Path, reclen: int = 80) -> tuple[int, int]:
    dst.mkdir(parents=True, exist_ok=True)
    ok = skipped = 0
    for f in sorted(src.iterdir()):
        if not f.is_file():
            continue
        raw = f.read_bytes()
        if not raw or len(raw) % reclen:
            skipped += 1          # not a fixed-length member; leave it alone
            continue
        out = bytearray()
        for i in range(0, len(raw), reclen):
            out += raw[i:i+reclen].decode("cp037").encode("latin-1", "replace").rstrip() + b"\n"
        (dst / f.name).write_bytes(bytes(out))
        ok += 1
    return ok, skipped

if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    n, s = convert(pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]),
                   int(sys.argv[3]) if len(sys.argv) > 3 else 80)
    print(f"converted {n}, skipped {s} (length not a multiple of the record length)")
