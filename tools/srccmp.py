#!/usr/bin/env python3
"""Dave's archived source against the source his own build left on the system.

Two things are both called "Dave's source" and they are not the same. The
archive in `MVSSRC/Dave Kreiss - MVS from Source/MVSBLD/` is one state. What
`MVSSRC.BLD.AMVSSRC` holds after his SMP chain has run is another -- his DSK
SYSMODs went in during the build. This says how far apart they are, module by
module.

The only formatting difference between the two sides is line endings: the
archive is CRLF, a member read over mvsMF comes back LF, and the sequence
numbers in columns 73-80 are present and identical on both. Measured on
IEFBR14 before this was written, the same way the macro comparison was.

Four classes, narrowing:

    identical          the same bytes after CRLF -> LF
    sequence-only      differ only in columns 73-80
    comment-only       differ only on lines whose first column is `*`
    code               a statement differs

`comment-only` is not cosmetic here and the class exists for that reason: the
PL/S transcription artefacts that explain the macro collisions -- the NOT
operator, the concatenation operator -- live in comment cards, and so do the
build's own change flags. A module in that class is one nobody needs to look at
twice; a module in `code` is the work.
"""
import io, os, sys, collections

ARCHIVE = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
SYSTEM = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                      "work", "measurements", "amvssrc-tk5")


def lines(b):
    return b.replace(b"\x0d\x0a", b"\x0a").replace(b"\x0d", b"\x0a").split(b"\n")


def classify(a, b):
    if a == b:
        return "identical", 0
    la, lb = lines(a), lines(b)
    if la == lb:
        return "identical", 0
    ca = [l[:72].rstrip() for l in la]
    cb = [l[:72].rstrip() for l in lb]
    if ca == cb:
        return "sequence-only", 0
    # Comment cards are `*` in column 1. Compare what is left; if that agrees,
    # every difference was in a comment.
    ka = [l for l in ca if not l.startswith(b"*")]
    kb = [l for l in cb if not l.startswith(b"*")]
    if ka == kb:
        return "comment-only", 0
    n = sum(1 for x, y in zip(ka, kb) if x != y) + abs(len(ka) - len(kb))
    return "code", n


def main():
    mods = sorted(f[:-4] for f in os.listdir(ARCHIVE) if f.endswith(".ASM"))
    have = set(os.listdir(SYSTEM))
    counts = collections.Counter()
    rows = []
    for m in mods:
        if m not in have:
            counts["absent on the system"] += 1
            rows.append((m, "absent", 0, 0, 0))
            continue
        a = io.open(os.path.join(ARCHIVE, m + ".ASM"), "rb").read()
        b = io.open(os.path.join(SYSTEM, m), "rb").read()
        k, n = classify(a, b)
        counts[k] += 1
        rows.append((m, k, n, len(lines(a)), len(lines(b))))
    extra = sorted(have - set(mods))
    for m in extra:
        counts["only on the system"] += 1
        rows.append((m, "only-on-system", 0, 0, 0))

    out = os.path.join(os.path.dirname(SYSTEM), "archive-vs-system.tsv")
    with io.open(out, "w") as f:
        f.write("module\tclass\tdiffering_code_lines\tarchive_lines\tsystem_lines\n")
        for r in sorted(rows):
            f.write("\t".join(str(x) for x in r) + "\n")

    total = sum(counts.values())
    print(f"{len(mods)} modules in the archive, {len(have)} members on the system\n")
    for k in ("identical", "sequence-only", "comment-only", "code",
              "absent on the system", "only on the system"):
        if counts[k]:
            print(f"  {k:22} {counts[k]:5}  {100*counts[k]/total:5.1f} %")
    print(f"\n{out}")
    worst = sorted((r for r in rows if r[1] == "code"), key=lambda r: -r[2])[:12]
    if worst:
        print("\nlargest code differences:")
        for m, k, n, la, lb in worst:
            print(f"  {m:10} {n:5} lines   archive {la:5} / system {lb:5}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
