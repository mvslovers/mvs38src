#!/usr/bin/env python3
"""Which system's object code does Dave Kreiss' source assemble to?

Runs `cmplmd370` twice per module -- our IFOX00 object deck against the TK5
distribution-library member and against the MVS/CE one -- and writes one row per
module.  Same deck, same comparator, same options on both sides; the only thing
that varies is which system the reference member came from.  That is the whole
design: a difference in the two columns can only come from the systems.

The left-hand side is the **IFOX00** deck, not the `as370` one.  Both would do
-- they agree on 5,418 of 5,528 modules -- but IFOX00 is the assembler Dave's
process actually used, and using it keeps `as370`'s remaining gaps out of a
measurement that is not about `as370`.

Build dates do not need masking here, unlike in the raw byte comparison
`foo` ran: `cmplmd370` compares CSECT **text**, and a load module's IDR date
lives in its identification records, which are not text.  A date compiled into a
module as a constant is still visible, and shows up as a small difference on
both sides at once -- see the doc.

    deckvsdlib.py --modules mods.tsv --out results.tsv
"""
import argparse, concurrent.futures, json, os, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DECKS = os.path.join(ROOT, "work", "measurements", "ifox-run", "decks")
CACHE = os.path.join(ROOT, "work", "measurements", "dlib-bytes")
COLS = ("module dlib state tk5_rmid ce_rmid bytes_tk5 bytes_ce bytes_equal "
        "v_tk5 v_ce sect_tk5 sect_ce diff_tk5 diff_ce len_tk5 len_ce").split()


def one_side(deck, ref):
    """(verdict, n_sections, diff_bytes, any_length_differs) or ('absent',...)."""
    if not os.path.exists(ref):
        return ("absent", 0, -1, "")
    p = subprocess.run(["cmplmd370", "--json", deck, ref],
                       capture_output=True, text=True)
    if p.returncode == 2 or not p.stdout.strip():
        return ("error", 0, -1, "")
    try:
        d = json.loads(p.stdout)
    except json.JSONDecodeError:
        return ("error", 0, -1, "")
    secs = d.get("sections") or []
    diff = sum(s.get("diff_bytes") or 0 for s in secs)
    lend = any(s.get("length_differs") for s in secs)
    return ("identical" if d.get("identical") else "differs", len(secs), diff,
            "Y" if lend else "N")


def row(job):
    mod, dlib, state, tk5r, cer = job
    deck = os.path.join(DECKS, mod + ".obj")
    ptk5 = os.path.join(CACHE, "tk5", dlib, mod + ".bin")
    pce = os.path.join(CACHE, "ce", dlib, mod + ".bin")
    btk5 = os.path.getsize(ptk5) if os.path.exists(ptk5) else -1
    bce = os.path.getsize(pce) if os.path.exists(pce) else -1
    eq = ""
    if btk5 > 0 and bce > 0:
        eq = "Y" if open(ptk5, "rb").read() == open(pce, "rb").read() else "N"
    vt, st, dt, lt = one_side(deck, ptk5)
    vc, sc, dc, lc = one_side(deck, pce)
    return [mod, dlib, state, tk5r, cer, btk5, bce, eq, vt, vc, st, sc, dt, dc, lt, lc]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--modules", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--jobs", type=int, default=8)
    a = ap.parse_args()

    inv = {}
    for i, l in enumerate(open(os.path.join(
            ROOT, "work/measurements/smp-inventory/module-versions.tsv"))):
        if i == 0:
            continue
        f = l.rstrip("\n").split("\t")
        inv[f[0]] = (f[1], f[2], f[3], f[4])

    jobs = []
    for l in open(a.modules):
        l = l.rstrip("\n")
        if not l:
            continue
        mod, dlib = l.split("\t")[:2]
        d, tk5r, cer, state = inv[mod]
        jobs.append((mod, dlib, state, tk5r, cer))

    with concurrent.futures.ThreadPoolExecutor(a.jobs) as ex:
        rows = list(ex.map(row, jobs))

    with open(a.out, "w") as f:
        f.write("\t".join(COLS) + "\n")
        for r in rows:
            f.write("\t".join(str(x) for x in r) + "\n")
    print(f"{len(rows)} modules -> {a.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
