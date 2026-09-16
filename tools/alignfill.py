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
something else. **Why is open**, and that is the case to hand over -- a question,
not a diagnosis.
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
ZERO_DUP = re.compile(r"\bDC\s+0[A-Z]", re.I)


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
            st, _ = MA.owner(rows, seq, origin + c["offset"])
            if st and not st[1] and ZERO_DUP.search(st[2]):
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
