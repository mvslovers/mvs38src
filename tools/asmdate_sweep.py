#!/usr/bin/env python3
"""Try every date IBM's own object contains, keep the one that makes the module identical.

`asmdate.py` reads the dates; this decides which one is the assembly stamp, and it
decides it the only way that cannot be argued with -- by assembling and comparing.

**Why not compute the offset instead.** The stamp's position is known in the deck
and the deck is card images, while `cmplmd370`'s clusters are section-relative and
the bound member has its own layout. Mapping between those three coordinate systems
is exactly what `where.py` got wrong once already. A module's object usually holds
a handful of date-shaped byte sequences; assembling against each of them is a few
seconds and needs no mapping at all.

A module counts only when `cmplmd370` exits 0 against the chosen baseline. Nothing
is written to `src/`: **this is not a source repair.** The source was already
right; the pinned `ASMDATE=09/07/26` in `gate.sh` was simply the wrong date for a
module whose eyecatcher carries the day it was assembled.

    asmdate_sweep.py [--decks DIR] [--out FILE] [--jobs N]

Output is `module<TAB>date`, for `gate.sh` to apply per module.
"""
import argparse, collections, concurrent.futures, json, os, re, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from macpath import flags

ARCHIVE = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
BIN = os.path.join(ROOT, "work/src-states/bin/as370-main")
CM = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
DLIB = os.path.join(ROOT, "work/measurements/dlib-bytes/tk5")
TGT = os.path.join(ROOT, "work/measurements/target-bytes/tk5")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")
TMP = os.path.join(ROOT, "work/measurements/asmdate")
PINNED = "09/07/26"
PIN = b"\xf0\xf9\x61\xf0\xf7\x61\xf2\xf6"
DATEPAT = re.compile(rb"[\xf0-\xf9]{2}\x61[\xf0-\xf9]{2}\x61[\xf0-\xf9]{2}")


def as_date(b):
    s = "".join("/" if x == 0x61 else chr(x - 0xF0 + ord("0")) for x in b)
    mm, dd, _ = s.split("/")
    return s if 1 <= int(mm) <= 12 and 1 <= int(dd) <= 31 else None


def refs_for(mod, tx, dlibof):
    out = []
    if mod in dlibof:
        out.append((None, dlibof[mod]))
    for lib, lmod in tx.get(mod, []):
        p = os.path.join(TGT, lib, lmod + ".bin")
        if os.path.exists(p):
            out.append((mod, p))
    return out


def identical(obj, csect, ref):
    cmd = [CM, "--json"] + (["--csect", csect] if csect else []) + [obj, ref]
    q = subprocess.run(cmd, capture_output=True, text=True)
    if not q.stdout.strip():
        return False
    try:
        return bool(json.loads(q.stdout).get("identical"))
    except json.JSONDecodeError:
        return False


def one(job):
    mod, src, cands, rs = job
    for d in cands:
        obj = os.path.join(TMP, f"{mod}.{d.replace('/', '')}.obj")
        subprocess.run([BIN] + flags() + ["-o", obj, src], capture_output=True,
                       env=dict(os.environ, ASMDATE=d, ASMTIME="12.00"))
        if not os.path.exists(obj):
            continue
        for csect, ref in rs:
            if identical(obj, csect, ref):
                return mod, d
        os.unlink(obj)
    return mod, None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--decks", default=os.path.join(ROOT, "obj_overlay7"))
    ap.add_argument("--out", default=os.path.join(GATE, "asmdate.tsv"))
    ap.add_argument("--jobs", type=int, default=6)
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

    jobs = []
    for f in sorted(os.listdir(a.decks)):
        if not f.endswith(".obj"):
            continue
        mod = f[:-4]
        if PIN not in open(os.path.join(a.decks, f), "rb").read():
            continue
        rs = refs_for(mod, tx, dlibof)
        if not rs:
            continue
        cands = set()
        for _, p in rs:
            for m in DATEPAT.finditer(open(p, "rb").read()):
                d = as_date(m.group(0))
                if d and d != PINNED:
                    cands.add(d)
        if not cands:
            continue
        hits = [p for p in (os.path.join(ROOT, "src", l, mod + ".ASM")
                            for l in os.listdir(os.path.join(ROOT, "src"))) if os.path.exists(p)]
        src = hits[0] if hits else os.path.join(ARCHIVE, mod + ".ASM")
        if os.path.exists(src):
            jobs.append((mod, src, sorted(cands), rs))

    print(f"{len(jobs)} modules carry the pinned stamp and have candidates "
          f"({sum(len(j[2]) for j in jobs)} assemblies)", flush=True)
    with concurrent.futures.ThreadPoolExecutor(a.jobs) as ex:
        res = list(ex.map(one, jobs))
    won = {m: d for m, d in res if d}
    with open(a.out, "w") as fh:
        fh.write("module\tasmdate\n")
        for k, v in sorted(won.items()):
            fh.write(f"{k}\t{v}\n")
    print(f"identical once IBM's own date is used: {len(won)} of {len(jobs)}  -> {a.out}")
    for k, v in sorted(won.items())[:20]:
        print(f"   {k:10s} {v}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
