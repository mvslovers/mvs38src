#!/usr/bin/env python3
"""One source state, assembled, against TK5's distribution-library object.

The question this answers is the project's own: **which sources do not yet
assemble to the object in TK5's DLIBs?**  Run it once per source state and the
columns are comparable, because everything except the source is held fixed --
the same pinned `as370` binary, the same macro path, the same pinned assembly
stamp, the same comparator.

    srcstate_vs_dlib.py --decks obj_<label> --out <label>-vs-tk5.tsv

The module -> library map is taken from the reference tree itself
(`work/measurements/dlib-bytes/tk5/<LIB>/<MOD>.bin`) rather than from a list,
so a module can never be scored against the wrong library's member, and the
population is exactly what the reference actually holds.
"""
import argparse, collections, concurrent.futures, json, os, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
_BASES = {"tk5": ("dlib-bytes", "tk5"), "ce": ("dlib-bytes", "ce")}
TK5 = os.path.join(ROOT, "work", "measurements", "dlib-bytes", "tk5")
CMPLMD = os.path.join(ROOT, "work", "src-states", "bin", "cmplmd370")


def reference_map():
    """module -> (library, path).  A module in two libraries is reported."""
    m, dupes = {}, []
    for lib in sorted(os.listdir(TK5)):
        d = os.path.join(TK5, lib)
        if not os.path.isdir(d):
            continue
        for f in os.listdir(d):
            if not f.endswith(".bin"):
                continue
            mod = f[:-4]
            if mod in m:
                dupes.append((mod, m[mod][0], lib))
            m[mod] = (lib, os.path.join(d, f))
    return m, dupes


def one(job):
    mod, lib, ref, deck = job
    if not os.path.exists(deck):
        return [mod, lib, "no-deck", 0, -1, "", 0, 0]
    p = subprocess.run([CMPLMD, "--json", deck, ref], capture_output=True, text=True)
    if p.returncode == 2 or not p.stdout.strip():
        return [mod, lib, "error", 0, -1, "", 0, 0]
    try:
        d = json.loads(p.stdout)
    except json.JSONDecodeError:
        return [mod, lib, "error", 0, -1, "", 0, 0]
    secs = d.get("sections") or []
    diff = sum(s.get("diff_bytes") or 0 for s in secs)
    hole = sum(s.get("diff_in_holes") or 0 for s in secs)
    text = sum(s.get("diff_in_text") or 0 for s in secs)
    lend = any(s.get("length_differs") for s in secs)
    # cmplmd370 already separates a difference in a DS hole from one in text,
    # and the first version of this tool threw that away -- the exact failure
    # this repository keeps catching in itself. A hole is uninitialised storage:
    # IBM's object carries whatever was in the buffer, so a difference there
    # cannot be a source defect. `verdict` is cmplmd370's own word for the
    # section: identical / holes / differs.
    if d.get("identical"):
        v = "identical"
    elif not lend and text == 0 and hole > 0:
        v = "holes"
    else:
        v = "differs"
    return [mod, lib, v, len(secs), diff, "Y" if lend else "N", hole, text]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--decks", required=True, help="obj_<label> directory")
    ap.add_argument("--out", required=True)
    ap.add_argument("--jobs", type=int, default=8)
    ap.add_argument("--base", default="tk5", choices=sorted(_BASES),
                    help="which object baseline. tk5 is the project's since "
                         "2026-09-10; ce is what ifox_compare.py still uses.")
    a = ap.parse_args()

    global TK5
    TK5 = os.path.join(ROOT, "work", "measurements", *_BASES[a.base])
    refs, dupes = reference_map()
    for mod, l1, l2 in dupes:
        print(f"note: {mod} is in both {l1} and {l2}; scored against {l2}",
              file=sys.stderr)
    jobs = [(mod, lib, ref, os.path.join(a.decks, mod + ".obj"))
            for mod, (lib, ref) in sorted(refs.items())]

    with concurrent.futures.ThreadPoolExecutor(a.jobs) as ex:
        rows = list(ex.map(one, jobs))

    with open(a.out, "w") as fh:
        fh.write("module\tdlib\tverdict\tsections\tdiff_bytes\t"
                 "length_differs\tdiff_in_holes\tdiff_in_text\n")
        for r in rows:
            fh.write("\t".join(str(x) for x in r) + "\n")

    n = len(rows)
    c = collections.Counter(r[2] for r in rows)
    print(f"{a.decks}: {n} reference modules  "
          f"identical {c['identical']}  holes-only {c['holes']}  "
          f"differs {c['differs']}  no-deck {c['no-deck']}  error {c['error']}")
    print(f"  identical or holes-only: {c['identical'] + c['holes']}"
          f"  ({100 * (c['identical'] + c['holes']) / n:.1f} %)")


if __name__ == "__main__":
    main()
