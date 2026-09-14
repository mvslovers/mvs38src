#!/usr/bin/env python3
"""`&SYSPARM` was empty in every assembly we have ever run, and it emits bytes.

`IEDHJN` — TCAM's module-identifier macro, called by 436 of our sources — reads
the assembler's `SYSPARM` option and emits it as data:

        &HJA     SETC  '&SYSPARM'(1,4)
                 DC    C'&NAME' .              MODULE IDENTIFIER
                 DC    X'&HJA' .               DATE OF MODIFICATION

With no `SYSPARM`, `'&SYSPARM'(1,4)` flags `IFO117` and `DC X''` flags `IFO178`
and emits **nothing**. IBM's object carries two bytes there, so our CSECT comes
out two bytes short and every displacement after the eyecatcher is two low. That
is what the length population looked like from the outside: `IEDQA1` reported as
`LENGTH differs: new 230, reference 232 (-2)` and no clusters at all, because
`cmplmd370` will not cluster sections of unequal size.

**This is the `ASMDATE` class, not a source defect.** Nothing is written to
`src/`: the source was already right and the instrument was not. As with the
date, the value is taken from IBM's own object rather than guessed — `seclocate.py`
reports the inserted run, and the sweep keeps a value only when `cmplmd370` exits
0 against the chosen baseline.

**`as370` has had `--sysparm=` since the open-code work** — implemented,
undocumented, absent from `--help`, and recorded in
[`docs/assembler-options.md`](../docs/assembler-options.md). So this is not a
`cc370` case. `docs/opencode-gate.md` left the matching question open in as many
words — *"what `&SYSPARM` the real TCAM assemblies passed is now a source
question, not a tool question"* — and this answers it per module, from IBM's own
object.

The first version of this sweep measured through a patched copy of the macro on a
private `-I` directory, because `as370 --help` does not list the option and the
option was taken to be missing. Same answer, `IEDQA1` identical either way; the
patched-macro route is gone because a macro override one path entry ahead of
`gate.sh`'s is exactly the hazard `macpath.py` exists to prevent.

    sysparm_sweep.py [--out FILE] [--jobs N] [--only MOD ...]

Output is `module<TAB>sysparm`. The second half of an eight-character `SYSPARM`
is written `0000` whenever the caller did not pass `HJN`, because the macro then
never emits `&HJB` and **the bytes are not observable** — a recorded value that
was never measured would be the worst kind of number in this repository.
"""
import argparse, collections, concurrent.futures, difflib, json, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
sys.path.insert(0, HERE)
from macpath import flags
from decks import CONTROL
import seclocate as SL

BIN = os.path.join(ROOT, "work/src-states/bin/as370-main")
CM = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
DLIB = os.path.join(ROOT, "work/measurements/dlib-bytes/tk5")
TGT = os.path.join(ROOT, "work/measurements/target-bytes/tk5")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")
SRCDIR = os.path.join(ROOT, "work/src-states/overlay")
ASMDATES = os.path.join(GATE, "asmdate.tsv")
TMP = os.path.join(ROOT, "work/measurements/sysparm")


def asmdates():
    """The per-module date table `gate-worker.sh` applies, read the same way.

    There is no overlap with the IEDHJN callers today -- measured, 0 of 37 -- but
    a sweep that pins one date while the gate pins another is a false negative
    waiting for the first module that needs both, and it would look like a module
    SYSPARM cannot reach.
    """
    out = {}
    if os.path.exists(ASMDATES):
        with open(ASMDATES) as fh:
            for line in fh:
                f = line.rstrip("\n").split("\t")
                if len(f) >= 2 and f[1] and f[0] != "module":
                    out[f[0]] = f[1]
    return out


def clusters_after(obj, csect, ref):
    """The differing runs once the lengths already match, or None while they do not.

    This is the second pass, and `IEDCSA` is why there is one. `seclocate.py`
    anchors by agreement, and a weakly scored anchor puts the inserted run in
    roughly the right place rather than exactly it: `IEDCSA` scored 90 % with a
    margin of only 30 points, and the two bytes it reported were `0010` where IBM
    holds `8117`. The first pass therefore assembles a deck of the RIGHT LENGTH
    with the WRONG VALUE — and at equal length `cmplmd370` finally reports
    clusters, so IBM's own bytes are readable at the exact offset. Feeding those
    back makes `IEDCSA` identical.
    """
    q = subprocess.run([CM, "--json", "--csect", csect, obj, ref],
                       capture_output=True, text=True)
    if not q.stdout.strip():
        return None
    try:
        d = json.loads(q.stdout)
    except json.JSONDecodeError:
        return None
    s_ = next((x for x in (d.get("sections") or []) if x.get("name") == csect), None)
    if s_ is None or s_.get("identical") or s_.get("length_differs"):
        return None
    return [c for c in (s_.get("clusters") or []) if c.get("length") == 2]


def identical(obj, csect, ref):
    q = subprocess.run([CM, "--json", "--csect", csect, obj, ref],
                       capture_output=True, text=True)
    if not q.stdout.strip():
        return False
    try:
        return bool(json.loads(q.stdout).get("identical"))
    except json.JSONDecodeError:
        return False


def length_ref(deck, ref, csect):
    q = subprocess.run([CM, "--json", "--csect", csect, deck, ref],
                       capture_output=True, text=True)
    if not q.stdout.strip():
        return None
    try:
        d = json.loads(q.stdout)
    except json.JSONDecodeError:
        return None
    for s in d.get("sections") or []:
        if s.get("name") == csect:
            return s.get("length_ref")
    return None


def candidates(deck, ref, mod):
    """The inserted bytes IBM's object carries, as 4- or 8-hex-digit SYSPARM halves.

    Derived, not guessed: `seclocate.py` anchors our section in the bound member
    and the alignment names the run. Only an `insert` of exactly two or four bytes
    is a candidate — anything else is a different problem wearing the same
    length difference.
    """
    ours = SL.deck_text(deck, mod)
    if not ours:
        return []
    want = length_ref(deck, ref, mod)
    if want is None:
        return []
    blob = open(ref, "rb").read()
    off, conf, how = SL.anchor(blob, ours, mod)
    if off is None or conf < 0.85:
        return []
    off, _ = SL.refine(blob, ours, off, int(want))
    theirs = blob[off:off + int(want)]
    ins = [(j1, j2) for tag, i1, i2, j1, j2
           in difflib.SequenceMatcher(None, ours, theirs, autojunk=False).get_opcodes()
           if tag == "insert"]
    out = []
    for j1, j2 in ins:
        run = theirs[j1:j2]
        if len(run) == 2:
            out.append((run.hex().upper(), "0000"))
        elif len(run) == 4:
            out.append((run[:2].hex().upper(), run[2:].hex().upper()))
    return out


def one(job):
    mod, src, rs, date = job
    tried = 0
    for csect, ref in rs:
        cands = candidates(os.path.join(CONTROL, mod + ".obj"), ref, mod)
        tried += len(cands)
        for hja, hjb in cands:
            obj = os.path.join(TMP, f"{mod}.{hja}{hjb}.obj")
            subprocess.run([BIN, f"--sysparm={hja}{hjb}"] + flags() + ["-o", obj, src],
                           capture_output=True,
                           env=dict(os.environ, ASMDATE=date, ASMTIME="12.00"))
            if not os.path.exists(obj):
                continue
            if identical(obj, csect, ref):
                return mod, hja + hjb, os.path.basename(ref), "recovered"
            # Second pass: the length is right, so IBM's bytes are now readable.
            for c in (clusters_after(obj, csect, ref) or []):
                b = c.get("ref", "").upper()
                if len(b) != 4:
                    continue
                for v in (b + hjb, hja + b, b + b):
                    if v == hja + hjb:
                        continue
                    o2 = os.path.join(TMP, f"{mod}.{v}.obj")
                    subprocess.run([BIN, f"--sysparm={v}"] + flags() + ["-o", o2, src],
                                   capture_output=True,
                                   env=dict(os.environ, ASMDATE=date, ASMTIME="12.00"))
                    if os.path.exists(o2) and identical(o2, csect, ref):
                        return mod, v, os.path.basename(ref), "recovered (second pass)"
    return mod, None, None, ("no 2- or 4-byte insert" if tried == 0 else "tried, still differs")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(GATE, "sysparm.tsv"))
    ap.add_argument("--jobs", type=int, default=6)
    ap.add_argument("--only", nargs="*", default=None)
    a = ap.parse_args()
    os.makedirs(TMP, exist_ok=True)

    tx = collections.defaultdict(list)
    for line in open(os.path.join(GATE, "org-tgt.txt"), encoding="latin-1"):
        f = line.split()
        if len(f) >= 5 and f[2] == "INCLUDE":
            tx[f[3]].append((f[0], f[1]))
    dlibof = {}
    for lib in sorted(os.listdir(DLIB)):
        d = os.path.join(DLIB, lib)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith(".bin"):
                    dlibof.setdefault(f[:-4], os.path.join(d, f))

    dates = asmdates()
    jobs = []
    for f in sorted(os.listdir(SRCDIR)):
        if not f.endswith(".ASM"):
            continue
        mod = f[:-4]
        if a.only and mod not in a.only:
            continue
        src = os.path.join(SRCDIR, f)
        if b"IEDHJN" not in open(src, "rb").read():
            continue
        if not os.path.exists(os.path.join(CONTROL, mod + ".obj")):
            continue
        rs = [(mod, os.path.join(TGT, lib, lmod + ".bin")) for lib, lmod in tx.get(mod, [])]
        rs = [r for r in rs if os.path.exists(r[1])]
        if not rs and mod in dlibof:
            rs = [(mod, dlibof[mod])]
        if rs:
            jobs.append((mod, src, rs, dates.get(mod, "09/07/26")))

    print(f"{len(jobs)} IEDHJN callers with a deck and a reference", flush=True)
    with concurrent.futures.ThreadPoolExecutor(a.jobs) as ex:
        res = list(ex.map(one, jobs))
    won = [(m, v, r) for m, v, r, _ in res if v]
    with open(a.out, "w") as fh:
        fh.write("module\tsysparm\treference\n")
        for m, v, r in sorted(won):
            fh.write(f"{m}\t{v}\t{r}\n")

    # The partition, not just the wins. "110 of 436" says nothing about what is
    # left in the other 326 -- and the cc370 case has to say what it is.
    part = collections.Counter(w for *_x, w in res)
    rest = os.path.splitext(a.out)[0] + "-rest.tsv"
    with open(rest, "w") as fh:
        fh.write("module\toutcome\n")
        for m, v, r, w in sorted(res):
            if not v:
                fh.write(f"{m}\t{w}\n")
    print(f"identical once IBM's own SYSPARM is supplied: {len(won)} of {len(jobs)}"
          f"  -> {a.out}")
    for k, v in part.most_common():
        print(f"   {k:28s} {v}")
    print(f"the non-wins, by outcome -> {rest}")
    for m, v, r in sorted(won)[:20]:
        print(f"   {m:10s} {v}  {r}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
