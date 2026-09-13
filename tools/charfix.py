#!/usr/bin/env python3
"""The `^`/`¬` repair, generalised to any character the transfer got wrong.

`caret_fix.py` recovered ten modules by substituting one character inside
character constants: `MVSBLD` came through a transfer that read EBCDIC as
**cp1047**, and everything here reads **cp037**. That was one character. It is not
the only one.

**`×` for `|`, found 2026-09-13.** Ranking the tree by distance to the object and
grouping the differences by (our byte, IBM's byte) put nine modules in one cell:
`BF` where IBM has `4F`. The source carries latin-1 `×` (`X'D7'`), cp037 encodes it
to `BF`, and `X'4F'` is `|`. `BLSUMONI`'s `TEXITF DC CL1'×'`, `BLST05`'s
`MFST2 DC CL3' × '` and seven more.

    charfix.py --from × --to '|' [--check] [module…]

**The guard is the measurement, and it is per module.** A repaired module is
written to `src/` only when `cmplmd370` calls it identical against the chosen
baseline -- the target member where the CSECT has one, the DLIB member where it
does not. A substitution that makes a module worse is discarded, and the counts at
the end say how many of each there were. That is what makes a substitution
*proven* rather than plausible: `caret_fix.py`'s own docstring records `[` and `]`
as a substitution that is real in the code pages and **not** applied, because the
two modules carrying them did not improve.

Only inside character constants, never in a comment card, never in columns 73-80.
"""
import argparse, collections, json, os, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from macpath import flags

ARCHIVE = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
BIN = os.path.join(ROOT, "work/src-states/bin/as370-main")
CM = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
DLIB = os.path.join(ROOT, "work/measurements/dlib-bytes/tk5")
TGT = os.path.join(ROOT, "work/measurements/target-bytes/tk5")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")
TMP = os.path.join(ROOT, "work/measurements/charfix")
STAMP = dict(ASMDATE="09/07/26", ASMTIME="12.00")


def repair(text, frm, to):
    """Substitute inside character constants only -- caret_fix.py's rule, verbatim."""
    out, n = [], 0
    for s in text.split("\r\n"):
        if s[:1] in ("*", ".") or not s.strip():
            out.append(s)
            continue
        body, seq = s[:72], s[72:]
        res, q = [], 0
        for ch in body:
            if ch == "'":
                q ^= 1
            if ch == frm and q:
                res.append(to)
                n += 1
            else:
                res.append(ch)
        out.append("".join(res) + seq)
    while out and out[-1].strip() == "":
        out.pop()
    return out, n


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("modules", nargs="*")
    ap.add_argument("--from", dest="frm", required=True)
    ap.add_argument("--to", dest="to", required=True)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--jobs", type=int, default=6)
    a = ap.parse_args()
    assert len(a.frm) == 1 and len(a.to) == 1
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
    dates = {}
    p = os.path.join(GATE, "asmdate.tsv")
    if os.path.exists(p):
        for line in open(p):
            f = line.rstrip("\n").split("\t")
            if len(f) == 2 and f[0] != "module":
                dates[f[0]] = f[1]

    mods = a.modules or sorted(f[:-4] for f in os.listdir(ARCHIVE) if f.endswith(".ASM"))
    touched = won = worse = 0
    gained = []
    for m in mods:
        src = os.path.join(ARCHIVE, m + ".ASM")
        if not os.path.exists(src):
            continue
        lines, n = repair(open(src, "rb").read().decode("latin-1"), a.frm, a.to)
        if not n:
            continue
        touched += 1
        if a.check:
            continue
        cand = os.path.join(TMP, m + ".ASM")
        open(cand, "wb").write(b"".join(l.ljust(80)[:80].encode("latin-1") + b"\r\n"
                                        for l in lines))
        obj = os.path.join(TMP, m + ".obj")
        subprocess.run([BIN] + flags() + ["-o", obj, cand], capture_output=True,
                       env=dict(os.environ, **{**STAMP, "ASMDATE": dates.get(m, STAMP["ASMDATE"])}))
        if not os.path.exists(obj):
            continue
        refs = [(m, os.path.join(TGT, l, lm + ".bin")) for l, lm in tx.get(m, [])]
        if not refs and m in dlibof:
            refs = [(None, dlibof[m])]
        ok = False
        for csect, ref in refs:
            if not os.path.exists(ref):
                continue
            cmd = [CM, "--json"] + (["--csect", csect] if csect else []) + [obj, ref]
            q = subprocess.run(cmd, capture_output=True, text=True)
            if q.stdout.strip():
                try:
                    if json.loads(q.stdout).get("identical"):
                        ok = True
                        break
                except json.JSONDecodeError:
                    pass
        if ok:
            lib = next((l for l in sorted(os.listdir(DLIB))
                        if os.path.exists(os.path.join(DLIB, l, m + ".bin"))), None)
            if lib:
                dest = os.path.join(ROOT, "src", lib, m + ".ASM")
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                open(dest, "wb").write(open(cand, "rb").read())
                won += 1
                gained.append((m, n))
        else:
            worse += 1
    print(f"{a.frm!r} -> {a.to!r}: {touched} modules carry it in a character constant")
    if not a.check:
        print(f"  identical after the substitution, deposited: {won}")
        print(f"  not identical, discarded:                    {worse}")
        for m, n in gained[:30]:
            print(f"     {m:10s} {n} occurrence(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
