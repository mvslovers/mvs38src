#!/usr/bin/env python3
"""What a reachability change did, per REGION rather than per module.

cc370#383 makes `dasm370` traverse from code roots, so bytes nothing reaches are
emitted as `DC` instead of being decoded. The pass is conservative, which means
unreached *code* also becomes `DC` -- and that is **byte-safe**, so the round
trip still exits 0 and every gate this project runs reports success. The defect
is invisible to the only instrument that has been watching.

A ratio of instruction bytes to `DC` bytes per module does not fix that, and the
reason is the one that cost cc370#401 a second PR: **a scalar cannot see a local
failure.** A module where 400 bytes of a text table correctly stop decoding and
20 bytes of real code incorrectly stop decoding moves the ratio exactly as
intended. The aggregate is consistent with both readings.

So this compares two dasm370 builds byte by byte and reports **every contiguous
region whose classification changed**, with its offset, its length and its
direction. A module becomes a list of regions rather than a number.

    reachgate.py OLD NEW --corpus control|stage1a|nosource [--out FILE]

**The discriminating direction is `instruction -> DC`.** `DC -> instruction`
means reachability found more, which is not what it is for. Every `I->D` region
is a candidate defect, and outside the text-heavy CSECTs there should be very
few -- a list to read rather than a number to trust.

**And the control that makes it a test rather than a tally**: for the 30
decoder-control CSECTs we hold real source, so a region that stopped decoding can
be checked against the assembly listing -- is there an instruction at that offset
or not? That is the same independent witness that caught an operand comparison
silently skipping 88 of 204 registers, and it is the only thing here that can say
a classification is *wrong* rather than merely *different*.
"""
import argparse, os, re, subprocess, sys, collections, glob

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
sys.path.insert(0, HERE)

# ' <op>  <operands>  <6-hex offset>' -- the offset sits in the remark column and
# the sequence number in 73-80 is NOT it. Anchor on the op field, take the LAST
# 6-hex group before column 72, which is what the emitter writes.
LINE = re.compile(r"^(.{0,8})\s+(\S+)\s")
OFF  = re.compile(r"\b([0-9A-F]{6})\b")
DATA_OPS = {"DC", "DS"}


def classify(binary, csect, ref):
    """{offset: 'I'|'D'} for every byte the disassembly accounts for."""
    p = subprocess.run([binary, "--csect", csect, ref],
                       capture_output=True, text=True)
    if p.returncode not in (0, 1):
        return None
    ent = []
    for line in p.stdout.splitlines():
        body = line[:72]
        # A comment card carries `*` in COLUMN 1, where it lands inside LINE's
        # name-field group -- so the second field is an ordinary word and the
        # card was classified as an instruction at whatever six-hex number it
        # mentioned. `* reachability: 3 roots, 000412 bytes reached` invented a
        # phantom instruction byte at 0x412 out of a statistic. Found by the
        # cc370 session, and triggered by the statistics line THEY asked to add:
        # the addition would have corrupted this gate's own baseline on its first
        # run. Column 1 decides, before anything else looks at the line.
        if body[:1] == "*":
            continue
        m = LINE.match(body)
        if not m:
            continue
        op = m.group(2).upper()
        if op in ("CSECT", "ENTRY", "EXTRN", "END"):
            continue
        offs = OFF.findall(body)
        if not offs:
            continue
        ent.append((int(offs[-1], 16), "D" if op in DATA_OPS else "I"))
    if not ent:
        return None
    ent.sort()
    out = {}
    for i, (off, kind) in enumerate(ent):
        end = ent[i + 1][0] if i + 1 < len(ent) else off + 1
        for a in range(off, max(end, off + 1)):
            out[a] = kind
    return out


def regions(a, b):
    """Contiguous runs where the classification differs: (start, len, old, new)."""
    keys = sorted(set(a) | set(b))
    out, cur = [], None
    for k in keys:
        x, y = a.get(k), b.get(k)
        if x == y:
            if cur:
                out.append(cur); cur = None
            continue
        if cur and cur[0] + cur[1] == k and cur[2] == x and cur[3] == y:
            cur = (cur[0], cur[1] + 1, x, y)
        else:
            if cur:
                out.append(cur)
            cur = (k, 1, x, y)
    if cur:
        out.append(cur)
    return out


def corpus(name):
    """[(csect, reference)] -- the reference is whatever form that corpus has."""
    def rows(p):
        r = [l.rstrip("\n").split("\t") for l in open(p, encoding="utf-8")]
        return r[0], r[1:]
    if name == "control":
        h, rs = rows(os.path.join(ROOT, "work/measurements/dasm370-decoder-control.tsv"))
        i = {k: n for n, k in enumerate(h)}
        return [(r[i["csect"]], os.path.join(ROOT, r[i["our_deck"]])) for r in rs]
    if name == "stage1a":
        h, rs = rows(os.path.join(ROOT, "work/measurements/dasm370-stage1a.tsv"))
        i = {k: n for n, k in enumerate(h)}
        out = []
        for r in rs:
            g = glob.glob(os.path.join(ROOT, f"work/measurements/target-bytes/tk5/*/{r[i['load_module']]}.bin"))
            if g:
                out.append((r[i["csect"]], g[0]))
        return out
    h, rs = rows(os.path.join(ROOT, "work/measurements/nosource-corpus.tsv"))
    i = {k: n for n, k in enumerate(h)}
    out = []
    for r in rs:
        if len(r) < len(h) or r[i["exclude"]]:
            continue
        lm = r[i["load_module"]] or r[i["csect"]]
        for pat in ("target-bytes", "dlib-bytes"):
            g = (glob.glob(os.path.join(ROOT, f"work/measurements/{pat}/tk5/{r[i['library']]}/{lm}.bin"))
                 or glob.glob(os.path.join(ROOT, f"work/measurements/{pat}/tk5/*/{lm}.bin")))
            if g:
                out.append((r[i["csect"]], g[0])); break
    return out



# --- the source witness, for the 30 control CSECTs only --------------------
#
# A region that stopped decoding is `different`. Only the source can say it is
# `wrong`. These 30 assemble byte-identical from real source, so our own listing
# is an account of what is an instruction and what is a constant -- produced by
# a different program from a different input, which is the whole point.

LST = re.compile(r"^([0-9A-F]{6})\s")

def source_kinds(csect):
    """{offset: 'I'|'D'} from OUR assembly listing, or None."""
    import tempfile
    from macpath import flags
    from asmparams import params
    src = os.path.join(ROOT, f"work/src-states/overlay/{csect}.ASM")
    if not os.path.exists(src):
        return None
    binp = os.path.join(ROOT, "work/src-states/bin/as370-main")
    with tempfile.TemporaryDirectory() as td:
        lst = os.path.join(td, "l.lst")
        argv, env = params(csect)
        subprocess.run([binp] + argv + list(flags()) + ["-a=" + lst,
                        "-o", os.path.join(td, "o.obj"), src],
                       capture_output=True, env=dict(os.environ, **env))
        if not os.path.exists(lst):
            return None
        out = {}
        for line in open(lst, encoding="latin-1", errors="replace"):
            m = LST.match(line)
            if not m:
                continue
            body = line[:72]
            f = body[41:].split()
            if not f:
                continue
            op = f[0].upper()
            if op in ("CSECT", "DSECT", "END", "EQU", "USING", "DROP"):
                continue
            out[int(m.group(1), 16)] = "D" if op in DATA_OPS else "I"
        return out or None


def witness(csect, regs):
    """For each instruction->DC region, what the SOURCE says is there."""
    k = source_kinds(csect)
    if not k:
        return None
    seen = sorted(k)
    out = []
    for st, ln, o, n in regs:
        if not (o == "I" and n == "D"):
            continue
        # the statement covering this offset is the greatest listed address <= st
        prev = [a for a in seen if a <= st]
        kind = k[prev[-1]] if prev else "?"
        out.append((st, ln, kind))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("old"); ap.add_argument("new")
    ap.add_argument("--corpus", default="control",
                    choices=("control", "stage1a", "nosource"))
    ap.add_argument("--out")
    ap.add_argument("--jobs", type=int, default=8)
    a = ap.parse_args()
    import concurrent.futures
    jobs = corpus(a.corpus)

    def one(j):
        cs, ref = j
        x = classify(a.old, cs, ref)
        y = classify(a.new, cs, ref)
        if x is None or y is None:
            return (cs, None, None)
        return (cs, regions(x, y), (sum(1 for v in x.values() if v == "I"),
                                    sum(1 for v in y.values() if v == "I")))

    res = []
    with concurrent.futures.ThreadPoolExecutor(a.jobs) as ex:
        res = list(ex.map(one, jobs))

    tot = collections.Counter(); bad = []; err = 0
    for cs, regs, cov in res:
        if regs is None:
            err += 1; continue
        for st, ln, o, n in regs:
            tot[f"{o}->{n}"] += 1
            if o == "I" and n == "D":
                bad.append((cs, st, ln))
    print(f"{len(jobs)} CSECTs, {err} unreadable")
    print(f"  regions by direction: {dict(tot)}")
    print(f"  instruction -> DC regions: {len(bad)} in "
          f"{len({c for c,_,_ in bad})} modules")
    for cs, st, ln in sorted(bad, key=lambda r: -r[2])[:15]:
        print(f"     {cs:10s} 0x{st:06X}  {ln:5d} bytes")
    if a.out:
        with open(a.out, "w") as fh:
            fh.write("csect\toffset\tlength\tfrom\tto\n")
            for cs, regs, _ in res:
                for st, ln, o, n in (regs or []):
                    fh.write(f"{cs}\t0x{st:06X}\t{ln}\t{o}\t{n}\n")
        print(f"  -> {a.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
