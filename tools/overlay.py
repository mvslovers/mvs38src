#!/usr/bin/env python3
"""Build the tree the project actually claims: Dave's archive with our repairs on top.

Nothing read `src/` until 2026-09-12. Thirty-seven modules had been repaired and
deposited there — including the ten the `^`/`¬` code-page substitution recovered,
which the documents credit as "recovered 902 -> 912" — and **not one of them was
on any measured path.** `gate.sh` assembles `MVSSRC/.../MVSBLD`, so a repair
could have rotted silently and no run would have said so.

This writes a symlink tree where `src/` shadows the archive and the archive
fills in the rest, for `gate.sh`'s `SRC_TREE`:

    overlay.py --out work/src-states/overlay
    SRC_TREE=work/src-states/overlay tools/gate.sh <as370> <label>

It does not replace the archive measurement. Two figures are wanted, not one:
the archive says how far Dave got, the overlay says where the project is.
"""
import argparse, glob, os, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
ARCHIVE = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
SRC = os.path.join(ROOT, "src")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(ROOT, "work/src-states/overlay"))
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    for f in glob.glob(os.path.join(a.out, "*.ASM")):
        os.unlink(f)

    ours = {}
    for p in glob.glob(os.path.join(SRC, "*", "*.ASM")):
        m = os.path.basename(p)[:-4]
        if m in ours:
            sys.exit(f"{m} is in src/ twice: {ours[m]} and {p}")
        ours[m] = p

    n = 0
    for f in sorted(os.listdir(ARCHIVE)):
        if not f.endswith(".ASM"):
            continue
        m = f[:-4]
        os.symlink(ours.get(m, os.path.join(ARCHIVE, f)),
                   os.path.join(a.out, f))
        n += 1
    # Ten modules in src/ are in no archive: the seven HASP* and three XTB1G*
    # that came off Dave's install tape (NEW.ASM), each with a DLIB object and
    # each reported recovered. Linking them too means the gate assembles 5,538
    # rather than 5,528 -- which is the point, since a module nobody assembles
    # is a module whose recovery nobody can check.
    extra = sorted(set(ours) - {f[:-4] for f in os.listdir(ARCHIVE)
                                if f.endswith(".ASM")})
    for m in extra:
        os.symlink(ours[m], os.path.join(a.out, m + ".ASM"))
        n += 1
    print(f"{n} modules linked, {len(ours)} from src/ of which "
          f"{len(ours) - len(extra)} shadow the archive")
    if extra:
        print(f"  {len(extra)} are in src/ only, added to the tree: "
              f"{' '.join(extra)}")


if __name__ == "__main__":
    main()
