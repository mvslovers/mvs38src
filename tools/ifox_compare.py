#!/usr/bin/env python3
"""Attribute every module: is the difference the tool's, or the source's?

Three decks exist per module -- the one `as370` produces, the one IFOX00
produces from the *same* source under MVS/CE, and the one IBM shipped in the
distribution library. The pairs say different things:

  as370 vs IFOX00   the tool alone. Same source, same macro libraries, so a
                    difference here is an `as370` defect and nothing else.
  as370 vs DLIB     the tool *and* the source together -- ambiguous on its own,
                    which is why the first pair had to be measured.

Combining them attributes each module:

  tool agrees, DLIB agrees      recovered
  tool agrees, DLIB differs     the source: Dave Kreiss' text is not what IBM
                                assembled, or IBM's object carries maintenance
  tool differs                  an as370 defect, whatever the DLIB says
  IFOX flags, as370 silent      a defect the byte comparison cannot see

Two rules on the deck comparison, both measured (docs/ifox-oracle.md): columns
1-72 only, and the END card excluded -- each assembler names itself there.

The timestamp class is settled by re-assembling, not by masking: a module whose
decks differ is assembled again with the date and time *that IFOX00 run* used,
taken from its own END card and the step start time. What becomes identical
that way carried a stamp; what does not, did not.
"""
import json, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
DECKS, AS370 = f"{RUN}/decks", f"{RUN}/as370"
DLIB = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/dlib")
SRC = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
BIN = None          # set from argv: the pinned as370
M = os.path.expanduser("~/repos/mvs/mvs38src/work/macros")
MACS = sum([["-I", p] for p in [
    f"{M}/mvsce-2.1.4-dlib/AMACLIB", f"{M}/mvsce-2.1.4-dlib/AMODGEN",
    f"{M}/mvsce-2.1.4-dlib/AGENLIB", f"{M}/mvsce-2.1.4-dlib/ATSOMAC",
    f"{M}/mvsce-2.1.4-dlib/ATCAMMAC", f"{M}/mvsce-2.1.4-dlib/APVTMACS",
    f"{M}/tape", f"{M}/mirror"]], [])


def cards(path):
    d = open(path, "rb").read()
    return [d[i:i + 80] for i in range(0, len(d), 80)]


def body(cs):
    return [c[:72] for c in cs if len(c) >= 4 and c[1:4] != b"\xc5\xd5\xc4"]


def compare(a, b):
    x, y = body(cards(a)), body(cards(b))
    if len(x) != len(y):
        return "cards"
    return "identical" if x == y else "bytes"


def asmdate(deckpath):
    """MM/DD/YY of the IFOX assembly, from the END card's julian date."""
    for c in cards(deckpath):
        if c[1:4] == b"\xc5\xd5\xc4":
            j = c[47:52].decode("cp037")
            if j.isdigit():
                import datetime
                d = datetime.date(2000 + int(j[:2]), 1, 1) + datetime.timedelta(int(j[2:]) - 1)
                return d.strftime("%m/%d/%y")
    return None


def reassemble(m, date, tm, out):
    env = dict(os.environ, ASMDATE=date, ASMTIME=tm)
    subprocess.run(["perl", "-e", "alarm 40; exec @ARGV", BIN] + MACS +
                   ["-o", out, f"{SRC}/{m}.ASM"],
                   env=env, capture_output=True)
    return os.path.exists(out)


def dlib_index():
    ix = {}
    for root, _, fs in os.walk(DLIB):
        for f in fs:
            if f.endswith(".dlib"):
                ix[f[:-5]] = os.path.join(root, f)
    return ix


def dlib_verdict(args):
    m, obj, ref = args
    p = subprocess.run(["cmplmd370", "--json", obj, ref], capture_output=True, text=True)
    try:
        r = json.loads(p.stdout)
    except Exception:
        return m, "error", None
    if p.returncode == 0 or r.get("identical"):
        return m, "identical", r
    v = {s.get("verdict") for s in (r.get("sections") or [])}
    if not v:
        return m, "no-section", r
    for k in ("length", "mixed", "text", "holes"):   # worst wins
        if k in v:
            return m, k, r
    return m, "|".join(sorted(v)), r


def main():
    global BIN
    BIN = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser(
        "~/repos/mvs/cc370/as370/as370")
    state = {}
    for line in open(f"{RUN}/state.tsv"):
        f = line.rstrip("\n").split("\t")
        if len(f) >= 5 and f[0] != "module":
            state[f[0]] = f
    gate = {}
    for line in open(f"{RUN}/as370-gate.tsv"):
        f = line.rstrip("\n").split("\t")
        if len(f) >= 4:
            gate[f[0]] = f

    rows, need = [], []
    for m, s in sorted(state.items()):
        ifox_rc, start, _, _ = s[1], s[2], s[3], s[4]
        a370_rc = gate.get(m, ["", "?"])[1]
        pi, pa = f"{DECKS}/{m}.obj", f"{AS370}/{m}.obj"
        if not os.path.exists(pi):
            v = "no-ifox-deck"
        elif not os.path.exists(pa):
            v = "no-as370-deck"
        else:
            v = compare(pi, pa)
            if v == "bytes":
                need.append((m, start))
        rows.append([m, a370_rc, ifox_rc, v, ""])

    # second pass: the stamp, settled by re-assembling with IFOX's own clock
    os.makedirs(f"{RUN}/restamp", exist_ok=True)
    def redo(t):
        m, start = t
        d = asmdate(f"{DECKS}/{m}.obj")
        tm = (start[:5].replace(":", ".")) if start else None
        if not (d and tm):
            return m, None
        out = f"{RUN}/restamp/{m}.obj"
        if reassemble(m, d, tm, out):
            return m, compare(f"{DECKS}/{m}.obj", out)
        return m, None
    fixed = {}
    if need:
        with ThreadPoolExecutor(8) as ex:
            for m, v in ex.map(redo, need):
                if v:
                    fixed[m] = v
    for r in rows:
        if r[0] in fixed:
            r[4] = fixed[r[0]]

    ix = dlib_index()
    work = [(r[0], f"{AS370}/{r[0]}.obj", ix[r[0]]) for r in rows
            if r[0] in ix and os.path.exists(f"{AS370}/{r[0]}.obj")]
    dv = {}
    with ThreadPoolExecutor(8) as ex:
        for m, v, _ in ex.map(dlib_verdict, work):
            dv[m] = v

    with open(f"{RUN}/verdicts.tsv", "w") as f:
        f.write("module\tas370_rc\tifox_rc\ttool\ttool_restamped\tdlib\n")
        for r in rows:
            f.write("\t".join(r + [dv.get(r[0], "no-pair")]) + "\n")

    def tool(r):
        return r[4] or r[3]
    n = len(rows)
    agree = [r for r in rows if tool(r) == "identical"]
    print(f"{n} modules measured")
    print(f"  as370 == IFOX00 : {len(agree)}  ({100*len(agree)/n:.1f} %)")
    for k in ("bytes", "cards", "no-ifox-deck", "no-as370-deck"):
        c = [r for r in rows if tool(r) == k]
        if c:
            print(f"  {k:14s}: {len(c)}")
    print(f"  of those explained by the assembly stamp: {sum(1 for m, v in fixed.items() if v == 'identical')}")
    # "flags" means return code 8 or worse: 4 is a warning and IFOX00 gives it
    # freely. An ABEND is not the assembler flagging anything -- it is a job
    # that did not finish, and it is counted apart.
    flagged = [r for r in rows if r[1] == "0" and r[2].isdigit() and int(r[2]) >= 8]
    aben = [r for r in rows if not r[2].isdigit()]
    print(f"  as370 silent where IFOX00 flags (rc>=8): {len(flagged)}")
    if aben:
        print(f"  IFOX00 did not finish (abend / not run): {len(aben)}")
    # cross-check: this distribution must match the tree-wide run that was
    # measured without IFOX00 at all (docs/tree-wide-run.md). If it does not,
    # the DLIB side of this run is not the same measurement.
    rc0 = {r[0] for r in rows if r[1] == "0"}
    dd = {}
    for m, v in dv.items():
        if m in rc0:
            dd[v] = dd.get(v, 0) + 1
    # what the two assemblers make of the same source, side by side. The
    # interesting cells are off the diagonal: one assembler content where the
    # other is not.
    print("\nReturn codes, as370 against IFOX00:")
    band = lambda v: ("-" if not v.isdigit() else "0" if int(v) == 0 else
                      "4" if int(v) == 4 else "8+" )
    mat = {}
    for r in rows:
        k = (band(r[1]), band(r[2]))
        mat[k] = mat.get(k, 0) + 1
    cols = ["0", "4", "8+", "-"]
    print("            IFOX  " + "".join(f"{c:>8s}" for c in cols))
    for a in cols:
        line = "".join(f"{mat.get((a, b), 0):8d}" for b in cols)
        print(f"  as370 {a:>4s}      {line}")
    print("\nas370 against the distribution libraries, for control "
          "(as370 rc 0 only -- tree-wide-run.md says 20.4 % identical, "
          "10.5 % holes):")
    for k in sorted(dd, key=lambda x: -dd[x]):
        print(f"  {k:26s}: {dd[k]}")
    # Attribution runs on the population the project's own figures are about:
    # a module `as370` assembled cleanly, and that has a DLIB counterpart. Mixing
    # in the modules as370 could not assemble drops the identical rate from
    # 21 % to 16 % and makes the table incomparable with tree-wide-run.md.
    print("\nAttribution, where as370 assembled cleanly and a DLIB member exists:")
    tab = {}
    for r in rows:
        d = dv.get(r[0], "no-pair")
        if d == "no-pair" or r[1] != "0":
            continue
        t = tool(r)
        # a module with no deck on one side attributes nothing: it is not an
        # as370 defect, it is a measurement that did not happen
        k = ("unattributable (deck missing)" if t.startswith("no-") else
             "tool" if t != "identical" else
             "recovered" if d == "identical" else
             "source (DS holes only)" if d == "holes" else "source")
        tab[k] = tab.get(k, 0) + 1
    for k in sorted(tab, key=lambda x: -tab[x]):
        print(f"  {k:26s}: {tab[k]}")


if __name__ == "__main__":
    main()
