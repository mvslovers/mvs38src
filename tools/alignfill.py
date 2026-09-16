#!/usr/bin/env python3
"""Modules that differ ONLY in alignment padding — bytes no source statement owns.

`DC 0H'0'` has a duplication factor of zero: it emits nothing and only moves the
location counter to a boundary. The bytes the assembler puts in that gap are
**fill**, not data, and no source text controls them. `IGG019Q1` is three bytes
from identical and all three are exactly that:

```
000010 E4E9F3F4F6F6F4        DC    CL7'UZ34664'        seven bytes, ends 0x16
000017 00            START   DC    0H'0'               <- one byte of fill
000018 4140 1000             LA    R4,AVTEZERO(,R1)
```

Ours is `00` there and IBM's object holds `0C`; at `0x039A`, after a `BR R14`,
ours is `0000` and IBM's is `B25A`.

`cmplmd370` counts these as **generated text** and therefore as a difference.
TODO.md's control list has said so since September — *"`cmplmd370` calls alignment
padding `text`"*, which is why `fillgaps.py` keeps its `SPLIT` refusal broad — but
nobody has counted what it costs.

    alignfill.py [--out FILE] [--jobs N]

A module reported here is **not a source defect, and the cause is not
established.** Two things were checked and both refute the obvious readings:

- **It is not the assembler.** 43 of the 44 carry `tool = identical` in
  `verdicts.tsv` -- `as370` reproduces IFOX00's deck exactly -- so IFOX00 emits
  the same `00` we do. (The 44th, `BLSR3270`, is already a `cc370` case.)
- **It is not an uncovered hole either.** The deck's TXT cards were read directly:
  `IGG019Q1`'s bytes at `0x0017` and `0x039A` are both **covered** by TXT, the
  section has no uncovered gaps at all, and our deck therefore defines them as
  zero on purpose.

So both assemblers write zero into the gap and IBM's shipped object holds
something else.

## Answered 2026-09-16 by the cc370 session, and it inverts the class

**The bytes are not fill and alignment is not the cause -- it is the SELECTION.**
Six measurements, of which three refuted readings held at the start:

- **Not a fill pattern.** 338 differing bytes in 138 clusters: ours is `00` in
  every one, IBM's side carries **114 distinct values** (`40` x35, then
  `80 47 58 F0 B0 E0 50 10 60 01 C1`), 78 % printable EBCDIC. A fill byte is one
  value.
- **Three clusters are 11, 14 and 16 bytes** and a `DC 0D` pads at most 7, so
  they cannot be padding under any reading. `IEBWSAM` at `0x0548` is
  `95f84b43 47a0b54a 92f84b43 41f0` -- `CLI`, `BC`, `MVI`, `LA`. Instruction text.
- **The bytes were in IBM's deck, not added at link time**: for 47 of the 49,
  IBM's DLIB copy and IBM's bound target member -- two separate link-edits --
  hold identical bytes in the same gaps.
- Not an `ORG` artefact (11 of 149 clusters), not the wrong source state (all 49
  differ under `run8-asm` too), and not "IBM's literal was longer" (tested on
  `BLSSLCCA` and refuted: as370 re-zeroes a pad laid over `ORG`'d-back text).

**So this is a source question, not an assembler question**: content IBM's deck
carried that neither recovered source produces. A missing statement lands in this
bucket only when its bytes fit inside a pad -- anything larger moves the section
length and lands in `length-differs` instead. That is why the population is small
and why its members look unrelated to one another. Worth up to 48 modules of
SOURCE fidelity.

## The worked example above does NOT reproduce in the live state

⚠️ `IGG019Q1` is **not in `alignfill.tsv`** and has not been for some time. Live,
it is a *length-differs* module -- 964 against 968 -- because it calls
`IEDHJN ,,325` and fails `IFO117` + `IFO178` at rc 8 on an empty `&SYSPARM`. It
is **not in `sysparm.tsv`**, so nothing supplies one.

The three bytes above are reproducible, and only like this:

    as370 --sysparm=03250000 ...        -> rc 0, 968 = 968, 3 bytes in 2 clusters
                                           0x0017 ours 00 / IBM 0c
                                           0x039a ours 0000 / IBM b25a

That value comes from `work/measurements/lenattr/sysparm-trial.tsv`, where it is
marked **`DERIVED-UNPROVEN`** -- the table TODO.md says to pass for analysis and
never for the count. So the docstring was accurate about what it measured and
silent about the one condition that makes it visible, and the case it presents as
canonical cannot be cut from the live tree. Found by the cc370 session while
answering the question above; **pick a case out of the current `alignfill.tsv`
before quoting one from here.**
"""
import argparse, collections, concurrent.futures, json, os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
sys.path.insert(0, HERE)
from macpath import flags
from asmparams import params
import seclocate as SL
import macroattr as MA

BIN = os.path.join(ROOT, "work/src-states/bin/as370-main")
CM = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")
SRCDIR = os.path.join(ROOT, "work/src-states/overlay")
TMP = os.path.join(ROOT, "work/measurements/macroattr")

# `DC 0<type>` -- a duplication factor of exactly zero. `DC 01F` is a real
# duplication factor and must not match, so the digit run has to be a lone 0.
ZERO_DUP = re.compile(r"\bDC\s+0([A-Z])", re.I)
# How far a zero-duplication DC of each type reaches: its own alignment.
# D and L are doubleword, F/A/V/E/S word, H/Y halfword, the rest byte -- so a
# `DC 0D` pads at most 7 bytes and `DC 0C` pads none at all.
ALIGN = {"D": 8, "L": 8, "F": 4, "A": 4, "V": 4, "E": 4, "S": 4,
         "H": 2, "Y": 2, "X": 1, "C": 1, "B": 1, "P": 1, "Z": 1}


def one(job):
    mod, src, refs = job
    argv, env = params(mod)
    lst, obj = os.path.join(TMP, mod + ".lst"), os.path.join(TMP, mod + ".obj")
    if not (os.path.exists(obj) and os.path.exists(lst)):
        subprocess.run([BIN] + argv + flags() + ["-a=" + lst, "-o", obj, src],
                       capture_output=True, env=dict(os.environ, **env))
    if not (os.path.exists(obj) and os.path.exists(lst)):
        return None
    for ref in refs:
        q = subprocess.run([CM, "--json", "--csect", mod, obj, ref],
                           capture_output=True, text=True)
        if not q.stdout.strip():
            continue
        try:
            s = next(x for x in json.loads(q.stdout)["sections"] if x["name"] == mod)
        except Exception:
            continue
        if s.get("identical") or s.get("length_differs"):
            return None
        cl = [c for c in (s.get("clusters") or []) if not c.get("in_hole")]
        if not cl:
            return None
        rows, seq = MA.listing_rows(lst)
        if not rows:
            return None
        origin = rows[0][0]
        fill = 0
        for c in cl:
            addr = origin + c["offset"]
            st, _ = MA.owner(rows, seq, addr)
            if not (st and not st[1]):
                continue
            m = ZERO_DUP.search(st[2])
            if not m:
                continue
            # The owner lookup returns the nearest EMITTING row at or below the
            # address, and a `DC 0X` is the last emitting row before a region
            # defined entirely by EQUs -- IEBWSAM's @DATA work area is 184 bytes
            # of exactly that. So the lookup happily named one `DC 0D'0'` as the
            # owner of clusters 52, 14 and 33 bytes long, and the whole module
            # entered this table. Arithmetic settles it without the lookup:
            # a zero-duplication DC only reaches the next boundary of its own
            # type, so a cluster that starts before the pad or runs past that
            # boundary is not padding, whatever owns it.
            align = ALIGN.get(m.group(1).upper(), 1)
            pad_end = (st[0] + align - 1) // align * align
            if st[0] <= addr and addr + len(c.get("ref", "")) // 2 <= pad_end:
                fill += 1
        if fill == len(cl):
            return mod, s.get("diff_bytes"), len(cl), os.path.basename(ref)
        return None
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(GATE, "alignfill.tsv"))
    ap.add_argument("--jobs", type=int, default=6)
    a = ap.parse_args()

    tx = collections.defaultdict(list)
    for line in open(os.path.join(GATE, "org-tgt.txt"), encoding="latin-1"):
        f = line.split()
        if len(f) >= 5 and f[2] == "INCLUDE":
            tx[f[3]].append((f[0], f[1]))
    dlibof = {}
    for lib in sorted(os.listdir(SL.DLIB)):
        d = os.path.join(SL.DLIB, lib)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith(".bin"):
                    dlibof.setdefault(f[:-4], os.path.join(d, f))

    rows = [l.rstrip("\n").split("\t") for l in open(os.path.join(GATE, "macroattr.tsv"))][1:]
    jobs = []
    for r in rows:
        mod = r[0]
        src = os.path.join(SRCDIR, mod + ".ASM")
        refs = MA.refs_for(mod, tx, dlibof)
        if os.path.exists(src) and refs:
            jobs.append((mod, src, refs))

    print(f"{len(jobs)} candidates", flush=True)
    with concurrent.futures.ThreadPoolExecutor(a.jobs) as ex:
        res = [r for r in ex.map(one, jobs) if r]
    res.sort(key=lambda r: r[1])
    with open(a.out, "w") as fh:
        fh.write("module\tdiff_bytes\tclusters\treference\n")
        for m, db, nc, ref in res:
            fh.write(f"{m}\t{db}\t{nc}\t{ref}\n")
    print(f"\nmodules whose ONLY differences are alignment fill: {len(res)}  -> {a.out}")
    for m, db, nc, ref in res[:25]:
        print(f"   {m:10s} {db:4d} bytes in {nc:3d} clusters   {ref}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
