#!/usr/bin/env python3
"""The same map for the length-differing population — the block macroattr cannot see.

`macroattr.py` partitioned the 988 CSECTs that differ at equal length and found
605 of them free of any macro. It cannot touch the **2,231 that differ in length**,
41.7 % of the whole and the largest single block, because `cmplmd370` reports no
clusters at all while the sizes differ. That is precisely the blindness an
unsupplied `&SYSPARM` hid behind for a day.

`seclocate.py` supplies what is missing: it anchors our section's text inside the
bound member and aligns, so the **insert or delete** is located even though
`cmplmd370` will not pair the sections. Feed that offset to `macroattr.py`'s
listing attribution and the same question can be asked of this population:

    is the missing or extra run inside a macro expansion, or in code we can edit?

    lenattr.py [--out FILE] [--jobs N] [--max-bytes 64]

**Reach is the honest limit.** `lenlist.py` covers the modules within 64 bytes of
IBM's length, `seclocate.py` anchors about three quarters of those, and a module
it cannot anchor is reported as unanchored rather than guessed at. So this maps
the reachable part of the block, not the block.

**And the offset it attributes is OURS, not IBM's.** For a `delete` -- bytes we
emit that IBM does not -- `ours[i1:i2]` is a real span in our listing and the
owner is exact. An `insert` has no span of ours at all, and the first version
attributed it to `i1`, the statement the missing bytes would PRECEDE: on the
control that turned `IGCFK10D`'s missing `IEDHJN` eyecatcher into an open-code
`LR` and the module into a false `mixed`. The question being asked is which
expansion came up short, so an insert is attributed to `i1 - 1`, the statement it
follows.
"""
import argparse, collections, concurrent.futures, difflib, json, os, subprocess, sys

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
TMP = os.path.join(ROOT, "work/measurements/lenattr")


def one(job):
    mod, src, refs = job
    argv, env = params(mod)
    lst, obj = os.path.join(TMP, mod + ".lst"), os.path.join(TMP, mod + ".obj")
    if not (os.path.exists(obj) and os.path.exists(lst)):
        subprocess.run([BIN] + argv + flags() + ["-a=" + lst, "-o", obj, src],
                       capture_output=True, env=dict(os.environ, **env))
    if not (os.path.exists(obj) and os.path.exists(lst)):
        return mod, "did not assemble", []
    ours = SL.deck_text(obj, mod)
    if not ours:
        return mod, "no TXT", []
    for ref in refs:
        q = subprocess.run([CM, "--json", "--csect", mod, obj, ref],
                           capture_output=True, text=True)
        if not q.stdout.strip():
            continue
        try:
            s = next(x for x in json.loads(q.stdout)["sections"] if x["name"] == mod)
        except Exception:
            continue
        want = s.get("length_ref")
        if want is None:
            continue
        if s.get("identical"):
            return mod, "identical", []
        if not s.get("length_differs"):
            return mod, "equal length -- macroattr's population", []
        blob = open(ref, "rb").read()
        off, conf, how = SL.anchor(blob, ours, mod)
        if off is None or conf < 0.85:
            return mod, f"not anchored ({how})", []
        off, _ = SL.refine(blob, ours, off, int(want))
        theirs = blob[off:off + int(want)]
        rows, seq = MA.listing_rows(lst)
        if not rows:
            return mod, "no listing rows", []
        origin = rows[0][0]
        out = []
        for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(
                None, ours, theirs, autojunk=False).get_opcodes():
            if tag == "equal" or (i2 - i1) == (j2 - j1):
                continue
            # An `insert` has no span of ours, so `i1` names the statement the
            # missing bytes would PRECEDE -- and the question being asked is
            # which expansion came up short, which is the statement they FOLLOW.
            # On the control, IGCFK10D's missing IEDHJN eyecatcher was attributed
            # to the next open-code instruction and the module read as `mixed`
            # with an open-code cause it does not have.
            probe = origin + (i1 - 1 if tag == "insert" and i1 > 0 else i1)
            stmt, call = MA.owner(rows, seq, probe)
            if not stmt:
                continue
            out.append((tag, i1, (j2 - j1) - (i2 - i1), stmt[1],
                        MA.opname(call[1]) if (stmt[1] and call) else "<open code>",
                        stmt[2][:48]))
        if not out:
            return mod, "no length-changing op located", []
        kinds = {r[3] for r in out}
        v = ("all in macro expansions" if kinds == {True} else
             "all in open code" if kinds == {False} else "mixed")
        return mod, v, out
    return mod, "no usable reference", []


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(GATE, "lenattr.tsv"))
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

    mods = [l.split("\t")[0] for l in open(os.path.join(GATE, "lenlist.tsv"))][1:]
    jobs = []
    for mod in mods:
        if a.only and mod not in a.only:
            continue
        src = os.path.join(SRCDIR, mod + ".ASM")
        if not os.path.exists(src):
            continue
        refs = MA.refs_for(mod, tx, dlibof)
        if refs:
            jobs.append((mod, src, refs))

    print(f"{len(jobs)} length-differing modules within reach of lenlist.tsv", flush=True)
    with concurrent.futures.ThreadPoolExecutor(a.jobs) as ex:
        res = list(ex.map(one, jobs))

    with open(a.out, "w") as fh:
        fh.write("module\tverdict\ttag\toffset\tsize_delta\towner\tstatement\n")
        for mod, v, ops in sorted(res):
            if not ops:
                fh.write(f"{mod}\t{v}\t\t\t\t\t\n")
            for tag, i1, d, ismac, own, st in ops:
                fh.write(f"{mod}\t{v}\t{tag}\t{i1:#06x}\t{d:+d}\t{own}\t{st}\n")

    c = collections.Counter(v for _, v, _ in res)
    print(f"\n-> {a.out}")
    for k, n in c.most_common():
        print(f"   {k:34s} {n:5d}")
    fam = collections.Counter()
    for _, v, ops in res:
        for _, _, _, ismac, own, _ in ops:
            if ismac:
                fam[own] += 1
    print("\nmacro calls owning a length-changing run, by clusters:")
    for k, n in fam.most_common(15):
        print(f"   {k:12s} {n:5d}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
