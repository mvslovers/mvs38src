#!/usr/bin/env python3
"""Give a module IBM's eyecatcher and measure what is still different afterwards.

`work/measurements/divergence/eyecatcher.tsv` records 218 modules whose first
divergence is at byte 0: the branch around the module identifier jumps further in
IBM's object than in ours, because IBM's identifier is longer. 104 of them share
the largest single cell, `47F0F016` against `47F0F01E` -- eight bytes.

The sentence that grew out of that was *"everything after it is a consequence"*,
and it was never measured. It cannot be measured by looking, either: eight bytes
inserted at the front move every later displacement, so a module that is otherwise
identical still shows hundreds of differing bytes, and a module that is genuinely
different shows the same thing.

So the assembler decides it. Take IBM's own identifier out of the bound member,
put it in our source in place of ours, assemble, and compare again: the assembler
recomputes every displacement, so whatever survives is a cause of its own.

    eyerepair.py --list FILE [--out TSV] [--jobs N]

Three things are controlled, because each of them can fake the result:

  identity   the UNMODIFIED source is assembled here first and its text must equal
             the deck the gate built. Otherwise "the repair changed something" and
             "this assembly is not the gate's assembly" are the same observation.
  repair     after assembly the module's own bytes must show IBM's branch and
             IBM's identifier. A repair that did not take would report the module
             unchanged and read as a finding.
  instrument the same comparison runs before and after -- differing bytes and
             alignment edits against IBM's section, plus `cmplmd370`'s verdict.

`--anchors` is deliberately NOT the instrument. Anchors are sparse: `IEEMB814`
has 23 failing anchors and is 188 bytes shorter than IBM's module.

**`bytes_after` is a magnitude and not a verdict, and the difference showed up on
the first run.** `IEFAB486` came back with `cmplmd370` exit 0 -- byte-identical --
while the alignment still counted 51 differing bytes. Both are right: a bound
member has its address constants relocated, so a deck's TXT and the member never
agree on them, and `cmplmd370` clears the RLD-covered bytes before comparing while
a plain byte comparison cannot. So the verdict columns are `cmplmd_*`, taken from
`cmplmd370 --json`, and the alignment columns say how far apart the two are while
`cmplmd370` still refuses to compare them at all -- which it does for as long as
the lengths differ, which is the whole reason this measurement exists.
"""
import argparse, collections, difflib, glob, os, re, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
sys.path.insert(0, HERE)
from seclocate import deck_text, anchor, refine, verdict           # noqa: E402
from decks import CURRENT                                          # noqa: E402
from macpath import flags as macflags                              # noqa: E402
from asmparams import params                                       # noqa: E402

AS = os.environ.get("AS370", os.path.join(ROOT, "work/src-states/bin/as370-main"))
SRC = os.path.join(ROOT, "work/src-states/overlay")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")
AL1 = re.compile(r"^(.{9})DC\s+AL1\((\d+)\)")


def references():
    """module -> (label, path), picked exactly as divgroup.py picked them."""
    rows = [l.rstrip("\n").split("\t")
            for l in open(os.path.join(GATE, "overlay-vs-both.tsv"), encoding="utf-8")]
    h = {k: i for i, k in enumerate(rows[0])}
    out = {}
    for r in rows[1:]:
        if len(r) < len(rows[0]):
            continue
        m, t, d = r[h["module"]], r[h["tgt_c"]], r[h["dlib_c"]]
        if t == "len-differs" and r[h["tgt_lmod"]] not in ("-", ""):
            out[m] = (f"{r[h['tgt_lib']]}({r[h['tgt_lmod']]})",
                      os.path.join(ROOT, "work/measurements/target-bytes/tk5",
                                   r[h["tgt_lib"]], r[h["tgt_lmod"]] + ".bin"))
        elif t == "not-in-target" and d == "len-differs":
            g = glob.glob(os.path.join(ROOT, "work/measurements/dlib-bytes/tk5",
                                       "*", m + ".bin"))
            if g:
                out[m] = ("DLIB", g[0])
    return out


def cards(raw):
    return raw.split("\r\n") if "\r\n" in raw else raw.split("\n")


def repair(raw, ident):
    """Replace `DC AL1(n)` + `DC C'...'` with IBM's length and IBM's bytes.

    `DC X'...'` and not `DC C'...'`: the identifier is not guaranteed printable,
    and a C-constant would need `'` and `&` doubled. 24 bytes per card, so a long
    one continues onto further cards instead of running past column 71.
    """
    lines = cards(raw)
    for i, l in enumerate(lines[:40]):
        g = AL1.match(l)
        if not g or not re.match(r"^.{9}DC\s+C'", lines[i + 1]):
            continue
        seq = l[72:] if len(l) > 72 else ""
        def card(op):
            return (" " * 9 + op).ljust(72)[:72] + seq
        new = [card(f"DC    AL1({len(ident)})")]
        for k in range(0, len(ident), 24):
            new.append(card("DC    X'" + ident[k:k + 24].hex().upper() + "'"))
        return "\r\n".join(lines[:i] + new + lines[i + 2:]) + "\r\n", True
    return raw, False


def assemble(mod, path, outdir):
    argv, env = params(mod)
    obj = os.path.join(outdir, mod + ".obj")
    subprocess.run(["perl", "-e", "alarm 400; exec @ARGV", AS] + argv + macflags()
                   + ["-o", obj, path],
                   capture_output=True, env=dict(os.environ, **env))
    return obj if os.path.exists(obj) else None


def distance(ours, theirs):
    """(differing bytes under alignment, alignment edits) against IBM's section."""
    sm = difflib.SequenceMatcher(None, ours, theirs, autojunk=False)
    ops = [x for x in sm.get_opcodes() if x[0] != "equal"]
    return sum(max(i2 - i1, j2 - j1) for _, i1, i2, j1, j2 in ops), len(ops)


def one(job):
    mod, label, ref = job
    src = os.path.join(SRC, mod + ".ASM")
    row = dict(module=mod, ref=label, status="", len_ours="", len_ibm="",
               len_repaired="", ident_ours="", ident_ibm="",
               bytes_before="", edits_before="", bytes_after="", edits_after="",
               cmplmd_after="", cmplmd_verdict_after="", cmplmd_diff_after="")
    if not os.path.exists(src):
        row["status"] = "no-source"
        return row
    gate_obj = os.path.join(CURRENT, mod + ".obj")
    gate_txt = deck_text(gate_obj, mod) if os.path.exists(gate_obj) else None
    if not gate_txt:
        row["status"] = "no-gate-deck"
        return row
    s = verdict(gate_obj, ref, mod)
    if not s or not s.get("length_ref"):
        row["status"] = "no-verdict"
        return row
    want = int(s["length_ref"])
    blob = open(ref, "rb").read()
    off, conf, how = anchor(blob, gate_txt, mod)
    if off is None or conf < 0.85:
        row["status"] = "not-anchored"
        return row
    # `refine` runs difflib nine times over the whole section, and difflib is
    # quadratic: on IEECB909's 19,808 bytes that is the entire cost of the run.
    # It exists to nudge a SCORED anchor, which can sit a byte or two off. A
    # prologue or prefix anchor matched exactly and has nothing to nudge.
    if not (how == "prologue" or how.startswith("prefix")):
        off, _ = refine(blob, gate_txt, off, want)
    theirs = blob[off:off + want]
    if len(theirs) < 8:
        row["status"] = "short-reference"
        return row
    n = theirs[4]
    ident = theirs[5:5 + n]
    row["len_ours"], row["len_ibm"] = len(gate_txt), len(theirs)
    row["ident_ours"], row["ident_ibm"] = gate_txt[4], n
    row["bytes_before"], row["edits_before"] = distance(gate_txt, theirs)

    raw = open(src, "rb").read().decode("latin-1")
    with tempfile.TemporaryDirectory() as td:
        # identity control: our own assembly of the unmodified source must be the
        # deck the gate built, or nothing measured after it is about the repair.
        p0 = os.path.join(td, mod + ".ASM")
        open(p0, "wb").write(raw.encode("latin-1"))
        o0 = assemble(mod, p0, td)
        if not o0 or deck_text(o0, mod) != gate_txt:
            row["status"] = "setup-mismatch"
            return row
        os.remove(o0)
        fixed, done = repair(raw, ident)
        if not done:
            row["status"] = "no-eyecatcher-in-source"
            return row
        p1 = os.path.join(td, mod + ".ASM")
        open(p1, "wb").write(fixed.encode("latin-1"))
        o1 = assemble(mod, p1, td)
        if not o1:
            row["status"] = "assembly-failed"
            return row
        got = deck_text(o1, mod)
        if not got or got[:4] != theirs[:4] or got[4:5 + n] != theirs[4:5 + n]:
            row["status"] = "repair-failed"
            return row
        row["len_repaired"] = len(got)
        row["bytes_after"], row["edits_after"] = distance(got, theirs)
        q = subprocess.run([os.path.join(ROOT, "work/src-states/bin/cmplmd370"),
                            "--csect", mod, o1, ref], capture_output=True)
        row["cmplmd_after"] = q.returncode
        sec = verdict(o1, ref, mod)
        if sec:
            row["cmplmd_verdict_after"] = sec.get("verdict") or ""
            row["cmplmd_diff_after"] = sec.get("diff_bytes")
        row["status"] = "identical" if q.returncode == 0 else "differs"
    return row


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--list", required=True)
    ap.add_argument("--out", default=os.path.join(
        ROOT, "work/measurements/divergence/eyecatcher-repair.tsv"))
    ap.add_argument("--jobs", type=int, default=8)
    a = ap.parse_args()

    refs = references()
    jobs, missing = [], 0
    for l in open(a.list):
        m = l.strip()
        if not m:
            continue
        if m in refs:
            jobs.append((m,) + refs[m])
        else:
            missing += 1
    print(f"{len(jobs)} Module, {missing} ohne Referenz", flush=True)

    cols = ["module", "ref", "status", "len_ours", "len_ibm", "len_repaired",
            "ident_ours",
            "ident_ibm", "bytes_before", "edits_before", "bytes_after",
            "edits_after", "cmplmd_after", "cmplmd_verdict_after",
            "cmplmd_diff_after"]
    rows = []
    with ThreadPoolExecutor(a.jobs) as ex:
        for i, r in enumerate(ex.map(one, jobs)):
            rows.append(r)
            if (i + 1) % 20 == 0:
                print(f"  ... {i + 1}", flush=True)
    rows.sort(key=lambda r: r["module"])
    with open(a.out, "w") as fh:
        fh.write("\t".join(cols) + "\n")
        for r in rows:
            fh.write("\t".join(str(r[c]) for c in cols) + "\n")

    c = collections.Counter(r["status"] for r in rows)
    print()
    for k, v in c.most_common():
        print(f"  {v:4d}  {k}")
    got = [r for r in rows if r["status"] in ("identical", "differs")]
    pair = [r for r in got if r["cmplmd_verdict_after"] not in ("length", "")]
    if pair:
        print(f"\n{len(pair)} Module, die cmplmd370 nach der Reparatur "
              f"ueberhaupt vergleichen kann (vorher: keins, die Laenge stand im Weg)")
        print(f"  davon identisch: {sum(1 for r in pair if r['cmplmd_after'] == 0)}")
        print(f"  abweichende Bytes nach RLD-Bereinigung: "
              f"{sum(int(r['cmplmd_diff_after'] or 0) for r in pair):,}")
    if got:
        b = sum(r["bytes_before"] for r in got)
        af = sum(r["bytes_after"] for r in got)
        print(f"\n{len(got)} repariert und gemessen")
        print(f"  abweichende Bytes  vorher {b:,}  nachher {af:,}"
              f"  ({(af - b) / b:+.1%})")
        print(f"  Module ohne jede Abweichung nachher: {c['identical']}")
        worse = [r for r in got if r["bytes_after"] > r["bytes_before"]]
        print(f"  Module, die schlechter wurden: {len(worse)}")
    print(f"\n-> {a.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
