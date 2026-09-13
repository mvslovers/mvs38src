#!/usr/bin/env python3
"""One source state against BOTH of TK5's object baselines -- DLIB and TARGET.

Dave Kreiss, 2026-09-12: *"target not DLIB is the version of code you should
compare to since target is what the running system uses."*  Every host-side
figure this project has published was measured against the distribution
libraries.  This scores the same decks against both, with the same comparator
and the same macro path, so a difference in the two columns can only come from
which library the reference member was read out of.

    baseline_gate.py --decks <dir> --out <tsv>

**The CSECT -> target member map is not guessed.**  A distribution-library
member holds one element and is named after it, so `dlib-bytes/tk5/<LIB>/<MOD>`
is its own map.  A target-library member is a bound load module holding several
CSECTs under a name that is often none of them -- `IKJEFD31` lives inside
`CMDLIB(ALLOCATE)`.  The map comes from Dave's own `LMDXRF38`, whose output sits
on `MVSTK5-BLD` as `MVSSRC.BLD.ORG.LMDXRF.TGT` and `...DLIB`, one record per
(library, LMOD, CSECT, length).  `fetch_xref.py` brings those across.

**Three verdicts per module, and the asymmetry is deliberate.**

  `dlib`    deck against the DLIB member, all sections paired by name.  This is
            exactly what `srcstate_vs_dlib.py` does, so it must reproduce that
            tool's column module for module -- `--control` asserts it.
  `dlib_c`  the same, restricted to the one CSECT named by the module.
  `tgt_c`   the deck against the target member, restricted to the same CSECT.

`dlib_c` exists because `tgt_c` has to be restricted -- a target member carries
CSECTs our deck never contained -- and comparing a restricted verdict against an
unrestricted one would measure the restriction.  **Read the gate off `dlib_c`
against `tgt_c`.**

**What this tool cannot tell you.**  `cmplmd370` reports `diff_bytes` 0 in
2,393 of the 2,406 length-differing cases in `ss-overlay-vs-tk5.tsv`, so a
`diff_bytes` of 0 alongside `length_differs` does NOT mean the bytes agree up to
the shorter length -- it means the comparator stopped. The verdict is
identical-or-not; do not read a byte count out of a length difference.
"""
import argparse, collections, concurrent.futures, json, os, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DLIB = os.path.join(ROOT, "work/measurements/dlib-bytes/tk5")
TGT = os.path.join(ROOT, "work/measurements/target-bytes/tk5")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")
CMPLMD = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
COLS = ("module dlib_lib dlib dlib_c tgt_lib tgt_lmod tgt_c tgt_members "
        "tgt_split dlib_len tgt_len len_same").split()


def dlib_map():
    """module -> (library, path).  The member name IS the element name."""
    m, dupes = {}, []
    for lib in sorted(os.listdir(DLIB)):
        d = os.path.join(DLIB, lib)
        if not os.path.isdir(d):
            continue
        for f in sorted(os.listdir(d)):
            if f.endswith(".bin"):
                mod = f[:-4]
                if mod in m:
                    dupes.append((mod, m[mod][0], lib))
                m[mod] = (lib, os.path.join(d, f))
    return m, dupes


def xref(name):
    """csect -> [(library, lmod, length)] from an LMDXRF38 extract."""
    m = collections.defaultdict(list)
    p = os.path.join(GATE, name)
    for line in open(p, encoding="latin-1"):
        f = line.split()
        if len(f) >= 5 and f[2] == "INCLUDE":
            m[f[3]].append((f[0], f[1], f[4]))
    if not m:
        sys.exit(f"{p}: no INCLUDE records -- wrong file?")
    return m


def verdict(deck, ref, csect=None):
    """cmplmd370's own word for the section, or why there is none."""
    if not os.path.exists(deck):
        return "no-deck"
    if not os.path.exists(ref):
        return "no-ref"
    cmd = [CMPLMD, "--json"] + (["--csect", csect] if csect else []) + [deck, ref]
    p = subprocess.run(cmd, capture_output=True, text=True)
    if p.returncode == 2 or not p.stdout.strip():
        return "error"
    try:
        d = json.loads(p.stdout)
    except json.JSONDecodeError:
        return "error"
    secs = d.get("sections") or []
    if not secs:
        return "unpaired"
    if d.get("identical"):
        return "identical"
    hole = sum(s.get("diff_in_holes") or 0 for s in secs)
    text = sum(s.get("diff_in_text") or 0 for s in secs)
    lend = any(s.get("length_differs") for s in secs)
    if not lend and text == 0 and hole > 0:
        return "holes"
    return "len-differs" if lend else "differs"


def one(job):
    mod, lib, ref, deck, tgts, dlen = job
    row = dict.fromkeys(COLS, "")
    row.update(module=mod, dlib_lib=lib,
               dlib=verdict(deck, ref), dlib_c=verdict(deck, ref, mod),
               dlib_len=dlen or "-", tgt_members=len(tgts))
    if not tgts:
        row.update(tgt_lib="-", tgt_lmod="-", tgt_c="not-in-target",
                   tgt_len="-", len_same="-", tgt_split="-")
        return row
    # A CSECT can sit in several bound modules (IEFBR14 is in dozens). Score
    # every one of them and keep the best verdict; `tgt_members` says how many
    # were tried, so a single row can never hide a fan-out.
    #
    # Best-of biases this gate toward "the baselines agree", which is the wrong
    # direction for a tool whose job is to find divergence: each bound module was
    # link-edited at its own time, so one copy of a CSECT can be a maintenance
    # level behind another. `tgt_split` says the copies disagreed -- that is a
    # finding of its own and must not disappear into the best verdict.
    best, order = None, ["identical", "holes", "differs", "len-differs",
                         "unpaired", "no-ref", "error", "no-deck"]
    seen = set()
    for tlib, tlmod, tlen in tgts:
        v = verdict(deck, os.path.join(TGT, tlib, tlmod + ".bin"), mod)
        seen.add(v)
        if best is None or order.index(v) < order.index(best[2]):
            best = (tlib, tlmod, v, tlen)
    tlib, tlmod, v, tlen = best
    row.update(tgt_lib=tlib, tgt_lmod=tlmod, tgt_c=v, tgt_len=tlen,
               tgt_split="Y" if len(seen) > 1 else "N",
               len_same=("Y" if dlen == tlen else "N") if dlen else "?")
    return row


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--decks", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--jobs", type=int, default=8)
    ap.add_argument("--control", help="an srcstate_vs_dlib.py TSV whose verdict "
                                      "column the `dlib` column must reproduce")
    a = ap.parse_args()

    refs, dupes = dlib_map()
    for mod, l1, l2 in dupes:
        print(f"note: {mod} is in both {l1} and {l2}; scored against {l2}",
              file=sys.stderr)
    tx, dx = xref("org-tgt.txt"), xref("org-dlib.txt")
    jobs = [(mod, lib, ref, os.path.join(a.decks, mod + ".obj"),
             tx.get(mod, []), (dx[mod][0][2] if dx.get(mod) else None))
            for mod, (lib, ref) in sorted(refs.items())]

    with concurrent.futures.ThreadPoolExecutor(a.jobs) as ex:
        rows = list(ex.map(one, jobs))

    with open(a.out, "w") as fh:
        fh.write("\t".join(COLS) + "\n")
        for r in rows:
            fh.write("\t".join(str(r[c]) for c in COLS) + "\n")

    # The gate, read off like against like.
    cross = collections.Counter((r["dlib_c"], r["tgt_c"]) for r in rows)
    print(f"{len(rows)} modules  ->  {a.out}\n")
    print(f"{'dlib_c':14s} {'tgt_c':14s} {'modules':>8s}")
    for (d, t), n in sorted(cross.items(), key=lambda x: -x[1]):
        mark = "  <-- recovered against DLIB, NOT against target" \
            if d == "identical" and t != "identical" else ""
        print(f"{d:14s} {t:14s} {n:8d}{mark}")

    # The map was cut on MVSTK5-BLD and the bytes pulled from MVSTK5-REF. If both
    # systems' SYS1 libraries are still IBM's, the XREF lengths and the comparator
    # must never contradict each other.
    #
    # The first version of this check tested `len_same == Y and tgt_c ==
    # len-differs` over every row and reported 1,987 contradictions, which is not
    # a finding but a confusion of two different lengths: `tgt_c` compares OUR
    # DECK against the target member, `len_same` compares the two LIBRARIES. A
    # deck that is the wrong length is the wrong length against both, and
    # `len_same = Y` is then exactly right. The test is only meaningful where the
    # deck is known to be the DLIB's length -- that is, where `dlib_c` is
    # identical -- and there it is sharp in both directions.
    # `len_same` has THREE states and the second version of this check treated it
    # as two: `?` means the CSECT is in the target extract and not in the DLIB one,
    # so there is no pair of lengths to compare, and 25 such rows were reported as
    # contradictions. They are a counted class, not a defect.
    anchored = [r for r in rows if r["dlib_c"] == "identical"
                and r["tgt_c"] in ("identical", "differs", "len-differs", "holes")]
    known = [r for r in anchored if r["len_same"] in ("Y", "N")]
    incoherent = [r["module"] for r in known
                  if (r["len_same"] == "Y") == (r["tgt_c"] == "len-differs")]
    print(f"\nmap (BLD) against bytes (REF), over the {len(known)} modules whose "
          f"deck IS the DLIB's length and which both extracts list: "
          f"{len(incoherent)} contradictions"
          + (f" -- {incoherent[:10]}" if incoherent else " -- coherent"))
    print(f"  {len(anchored) - len(known)} more are in the target extract and not "
          f"in the DLIB one, so they have no length pair to check")
    nc = sum(1 for r in rows if r["dlib"] != r["dlib_c"])
    print(f"decks where restricting to the named CSECT changes the DLIB verdict: "
          f"{nc} -- read the gate off dlib_c, not dlib")
    split = [r["module"] for r in rows if r["tgt_split"] == "Y"]
    print(f"CSECTs whose several target copies disagree: {len(split)}"
          + (f" -- {split[:10]}" if split else ""))

    if a.control:
        ctl = {}
        for line in open(a.control):
            f = line.rstrip("\n").split("\t")
            if len(f) >= 3 and f[0] != "module":
                ctl[f[0]] = f[2]
        # `srcstate_vs_dlib.py` has no `len-differs` class -- a length difference
        # is a `differs` there -- so the control normalises rather than failing
        # on a distinction this tool added.
        norm = lambda v: "differs" if v == "len-differs" else v
        bad = [r["module"] for r in rows
               if r["module"] in ctl and ctl[r["module"]] != norm(r["dlib"])]
        print(f"\ncontrol against {os.path.basename(a.control)}: "
              f"{len(ctl)} rows, {len(bad)} disagree" +
              (f" -- {bad[:10]}" if bad else " -- the DLIB side reproduces"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
