#!/usr/bin/env python3
"""Where do the differing bytes come from — a macro expansion, or code we can edit?

Three of the four investigations on 2026-09-14 ended at the same wall: a macro at
a level no surviving copy carries. `ESTAE`, `STAX`, `SCHEDULE`, `TSCBD` and
`IHBINNRB` are five of them and at least 35 modules sit behind them. Nobody knows
how big that wall is, and it decides what this project can do before Dave Kreiss
answers and what it cannot do at all without him.

The listing already says it. `as370` marks every macro-generated statement with a
`+` after the statement number, and `where.py`'s own regex has been capturing that
column since it was written — into `m.group(4)`, which it then throws away. So the
measurement needs no new information, only the column nobody read.

    macroattr.py [--out FILE] [--jobs N] [--only MOD ...]

Per module: how many differing clusters land on macro-generated statements, how
many on open code, and — walking back to the nearest statement WITHOUT the `+` —
which macro call owns them. Grouping by that last column is what turns "11 modules
are +4" into "`XCTL SF=(E,…)` expands differently".

**Two limits, and the second one matters more than the first.**

It can only run where `cmplmd370` reports clusters, so the 2,231 length-differing
CSECTs are out of reach — this covers the 665 that differ at equal length and the
323 that differ only in holes. `seclocate.py` would have to supply the mapping for
the rest, and that is a second tool, not a flag on this one.

And **open code is not the same as our problem.** `IGE0104G`'s one differing byte
is emitted by `OI SCBERR4,SCBCTLUN`, an ordinary open-code instruction — and the
cause is `TSCBD` shipping `SCBCTLUN` at two levels. The byte is open code; the
defect is a macro. So `macro` here is a **lower bound** on the macro wall and
`open` is "could be either", never "ours to fix". Both control cases below are
carried for exactly that reason.
"""
import argparse, collections, concurrent.futures, json, os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
sys.path.insert(0, HERE)
from macpath import flags
from asmparams import params
import seclocate as SL

BIN = os.path.join(ROOT, "work/src-states/bin/as370-main")
CM = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")
SRCDIR = os.path.join(ROOT, "work/src-states/overlay")
TMP = os.path.join(ROOT, "work/measurements/macroattr")

# The same row pattern as where.py, with the one column it discards kept:
# group(4) is `+` for a macro-generated statement and a blank for open code.
# The text group must NOT be left-stripped: the listing preserves the source's
# own columns, so a leading blank is exactly what says "this statement has no
# label", and that is how the operation field is found. Stripping it made
# opname() return `SF=(E,OPCXCTL(ROPCAVT))` where the answer is `XCTL`.
LST = re.compile(r"^([0-9A-F]{6})\s+((?:[0-9A-F]{2,8}[ ]+)*)(\d{1,6})([+ ])(.*?)\s*$")
# A statement that emits nothing has no address, and **the macro call is always
# one of those**: `XCTL SF=(E,…)` generates no code of its own. Walking back
# through emitting lines alone therefore never reaches it -- the first version of
# this tool answered `LR` for every cluster in the XCTL expansion, naming the
# previous open-code instruction instead of the macro. Comment lines match here
# too and that is correct: they are open code and stop the walk-back only if the
# macro call itself were missing, which it never is.
# A line with no address can still carry an EFFECTIVE-ADDRESS field, and without
# the optional group below the regex reads that as the statement number:
#     `                            00001  1750+CVTSDTRC EQU   X'01'`
# matched `00001` + a blank flag, leaving `1750+CVTSDTRC` as the text, which
# opname() then returned as a macro name. Column indent alone did not fix it --
# the two fields sit one column apart -- so the field itself is described instead,
# and backtracking still finds a genuine five- or six-digit statement number.
NOEMIT = re.compile(r"^\s{6,}(?:[0-9A-F]{5,6}\s+)?(\d{1,6})([+ ])(.*?)\s*$")


def listing_rows(path):
    """(emitting rows by address, every statement in file order).

    Returned as `(rows, seq)`: `rows` is [(address, is_macro, text, seq_index)]
    sorted by address for the address lookup, `seq` is [(is_macro, text)] in the
    order the listing prints them, which is the order the walk-back needs.

    **`rows` holds CSECT statements only, and leaving DSECTs in wrecked the
    result.** A DSECT has its own location counter starting at zero, so its rows
    collide with the CSECT's addresses and the lookup takes whichever sorts last.
    The first ranking that came out of this tool was led by `CVT` with 806
    clusters across 104 modules, followed by `IHAPSA`, `IECDSECT` and `IEFUCBOB`
    -- every one of them a mapping macro that emits no bytes at all. `seq` still
    carries them, because the walk-back needs the listing complete.
    """
    rows, seq, in_dsect = [], [], False
    with open(path, encoding="latin-1", errors="replace") as fh:
        for line in fh:
            line = line.rstrip("\n")
            m = LST.match(line)
            if m:
                text = m.group(5)
                seq.append((m.group(4) == "+", text))
                op = opname(text)
                if op == "DSECT":
                    in_dsect = True
                elif op in ("CSECT", "START", "RSECT"):
                    in_dsect = False
                elif not in_dsect:
                    rows.append((int(m.group(1), 16), m.group(4) == "+", text, len(seq) - 1))
                continue
            m = NOEMIT.match(line)
            if m:
                text = m.group(3)
                seq.append((m.group(2) == "+", text))
                op = opname(text)
                if op == "DSECT":
                    in_dsect = True
                elif op in ("CSECT", "START", "RSECT"):
                    in_dsect = False
    rows.sort(key=lambda r: r[0])
    return rows, seq


def owner(rows, seq, addr):
    """The statement emitting `addr`, and the macro CALL it came from.

    The owner is the greatest address not above the cluster -- the rule
    `fillgaps.py` had to be corrected into, because the last listing row is not
    the owning one when the listing is not in address order.

    The call is then the nearest preceding statement WITHOUT the `+`, walked back
    **in listing order and not in address order**: an inner macro is itself
    macro-generated, so this names `XCTL` rather than `IHBINNRB`, which is the
    level a family groups at.
    """
    lo, hi = 0, len(rows)
    while lo < hi:
        mid = (lo + hi) // 2
        if rows[mid][0] <= addr:
            lo = mid + 1
        else:
            hi = mid
    if lo == 0:
        return None, None
    stmt = rows[lo - 1]
    if not stmt[1]:
        return stmt, None
    j = stmt[3]
    while j >= 0 and seq[j][0]:
        j -= 1
    return stmt, (seq[j] if j >= 0 else None)


def opname(text):
    """The operation field of a statement, which is the macro's name on a call."""
    if text[:1] in ("*", "."):          # a comment is never a macro call
        return "?"
    f = text.split()
    if not f:
        return "?"
    # `LABEL  OP  OPERANDS` or ` OP OPERANDS`; a label starts in the source's
    # column 1, which the listing preserves, so text beginning with a blank has
    # none and its first token IS the operation.
    if text[:1] == " ":
        return f[0]
    return f[1] if len(f) > 1 else f[0]


def refs_for(mod, tx, dlibof):
    out = [os.path.join(SL.TGT, l, m + ".bin") for l, m in tx.get(mod, [])]
    out = [p for p in out if os.path.exists(p)]
    return out or ([dlibof[mod]] if mod in dlibof else [])


def one(job):
    mod, src, rs = job
    if not rs:
        return None
    argv, env = params(mod)
    lst = os.path.join(TMP, mod + ".lst")
    obj = os.path.join(TMP, mod + ".obj")
    subprocess.run([BIN] + argv + flags() + ["-a=" + lst, "-o", obj, src],
                   capture_output=True, env=dict(os.environ, **env))
    if not os.path.exists(obj) or not os.path.exists(lst):
        return mod, "did not assemble", 0, 0, {}
    q = subprocess.run([CM, "--json", "--csect", mod, obj, rs[0]],
                       capture_output=True, text=True)
    if not q.stdout.strip():
        return mod, "unreadable", 0, 0, {}
    try:
        s = next(x for x in json.loads(q.stdout)["sections"] if x["name"] == mod)
    except (json.JSONDecodeError, StopIteration, KeyError):
        return mod, "unreadable", 0, 0, {}
    if s.get("identical"):
        return mod, "identical", 0, 0, {}
    if s.get("length_differs"):
        return mod, "length differs", 0, 0, {}
    cl = s.get("clusters") or []
    if not cl:
        return mod, "no clusters", 0, 0, {}
    rows, seq = listing_rows(lst)
    if not rows:
        return mod, "no listing rows", 0, 0, {}
    # Listing addresses are absolute within the CSECT here: the section starts at
    # 0 in a single-CSECT deck. Where it does not, the cluster offset is
    # section-relative and the listing is not -- the mistake where.py made once,
    # and the reason a module whose first row is not 0 is reported rather than
    # guessed at.
    origin = rows[0][0]
    mac = op = 0
    calls = collections.Counter()
    for c in cl:
        stmt, call = owner(rows, seq, origin + c["offset"])
        if stmt is None:
            continue
        if stmt[1]:
            mac += 1
            calls[opname(call[1]) if call else "?"] += 1
        else:
            op += 1
    verdict = ("all in macro expansions" if op == 0 else
               "all in open code" if mac == 0 else "mixed")
    return mod, verdict, mac, op, dict(calls)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(GATE, "macroattr.tsv"))
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
    for lib in sorted(os.listdir(SL.DLIB)):
        d = os.path.join(SL.DLIB, lib)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith(".bin"):
                    dlibof.setdefault(f[:-4], os.path.join(d, f))

    rows = [l.rstrip("\n").split("\t") for l in open(os.path.join(GATE, "overlay-vs-both.tsv"))]
    i = {k: n for n, k in enumerate(rows[0])}
    jobs = []
    for r in rows[1:]:
        if len(r) < len(rows[0]):
            continue
        mod = r[i["module"]]
        if a.only and mod not in a.only:
            continue
        t, dl = r[i["tgt_c"]], r[i["dlib_c"]]
        v = t if t != "not-in-target" else dl
        if v not in ("differs", "holes") and not a.only:
            continue
        src = os.path.join(SRCDIR, mod + ".ASM")
        if os.path.exists(src):
            jobs.append((mod, src, refs_for(mod, tx, dlibof)))

    print(f"{len(jobs)} modules differ at equal length (or only in holes)", flush=True)
    with concurrent.futures.ThreadPoolExecutor(a.jobs) as ex:
        res = [r for r in ex.map(one, jobs) if r]

    with open(a.out, "w") as fh:
        fh.write("module\tverdict\tclusters_in_macro\tclusters_in_opencode\tmacro_calls\n")
        for mod, v, mac, op, calls in sorted(res):
            top = " ".join(f"{k}:{n}" for k, n in
                           sorted(calls.items(), key=lambda x: -x[1]))
            fh.write(f"{mod}\t{v}\t{mac}\t{op}\t{top}\n")

    c = collections.Counter(v for _, v, *_ in res)
    print(f"\n-> {a.out}")
    for k, n in c.most_common():
        print(f"   {k:26s} {n:5d}")
    fam = collections.Counter()
    for _, v, mac, op, calls in res:
        for k, n in calls.items():
            fam[k] += 1
    print("\nmacro calls owning differing bytes, by DISTINCT modules:")
    for k, n in fam.most_common(20):
        print(f"   {k:12s} {n:5d}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
