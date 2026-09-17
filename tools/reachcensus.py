#!/usr/bin/env python3
"""`--reach-report` over the 772 CSECTs that have no source — the population it is for.

`cc370#406` shipped the traversal as a measurement and held the applied form, on
evidence from the **30 control CSECTs**. Those are the modules that HAVE source,
which is why they can be judged at all — and they are not the population `#383`
exists for. Nobody has run it on the 772.

**There is no witness here and there cannot be**, so the question has to be asked
without one. The man page names the denominator that needs no source:

    of the bytes the disassembly called code WITHOUT reachability,
    how many does the traversal reach

That is `SELF`, and it is the only figure computable on both populations. A module
at 97 % is one a reader can trust a reachability-filtered disassembly of; a module
at 2 % is one where the traversal lost the base and would darken nearly everything.
**It does not say whether the darkened bytes are code or table** — only a source
listing says that, and that is exactly what these 772 lack.

    reachcensus.py [--jobs N] [--out TSV]
"""
import argparse, collections, os, re, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
sys.path.insert(0, HERE)
from reachgate import corpus, classify                     # noqa: E402

RUN = re.compile(r"^REACHRUN ([0-9A-F]+) (\d+)$", re.M)
HDR = re.compile(r"^REACH (\S+) (.*)$", re.M)


def one(job):
    binp, cs, ref = job
    rx = classify(binp, cs, ref)
    if rx is None:
        return (cs, None)
    code = {a for a, v in rx[0].items() if v == "I"}
    p = subprocess.run([binp, "--reach-report", "--csect", cs, ref],
                       capture_output=True, text=True)
    m = HDR.search(p.stdout)
    if not m or not code:
        return (cs, None)
    d = dict(kv.split("=", 1) for kv in m.group(2).split())
    reached = set()
    for o, n in RUN.findall(p.stdout):
        reached.update(range(int(o, 16), int(o, 16) + int(n)))
    return (cs, dict(seclen=int(d["len"]), code=len(code),
                     reached_code=len(reached & code),
                     self=len(reached & code) / len(code),
                     roots=int(d.get("roots", 0)), base=d.get("base", "-"),
                     acon=int(d.get("acon", 0))))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--binary", default=os.environ.get("DASM370", ""))
    ap.add_argument("--jobs", type=int, default=4)
    ap.add_argument("--out", default=os.path.join(
        ROOT, "work/measurements/reach/census-nosource.tsv"))
    a = ap.parse_args()
    if not a.binary:
        sys.exit("give --binary or set DASM370")
    jobs = [(a.binary, cs, ref) for cs, ref in corpus("nosource")]
    print(f"{len(jobs)} CSECTs ohne Quelle", flush=True)
    res = []
    with ThreadPoolExecutor(a.jobs) as ex:
        for i, r in enumerate(ex.map(one, jobs)):
            res.append(r)
            if (i + 1) % 100 == 0:
                print(f"  ... {i + 1}", flush=True)
    cols = ["seclen", "code", "reached_code", "self", "roots", "base", "acon"]
    with open(a.out, "w") as fh:
        fh.write("csect\t" + "\t".join(cols) + "\n")
        for cs, d in sorted(res):
            fh.write(cs + "\t" + "\t".join(
                (f"{d[c]:.4f}" if c == "self" else str(d[c])) if d else "" for c in cols) + "\n")
    ok = [d for _, d in res if d]
    print(f"\n{len(ok)} von {len(jobs)} gemessen")
    b = [(0.95, ">= 95 %"), (0.90, "90-95 %"), (0.70, "70-90 %"),
         (0.30, "30-70 %"), (0.0, "< 30 %")]
    prev = 1.01
    for lo, lab in b:
        g = [d for d in ok if lo <= d["self"] < prev]
        cb = sum(d["code"] for d in g)
        print(f"  SELF {lab:9s} {len(g):4d} Module  {cb:9,} Codebytes")
        prev = lo
    tc = sum(d["code"] for d in ok)
    tr = sum(d["reached_code"] for d in ok)
    print(f"\n  insgesamt {tr:,} von {tc:,} Codebytes erreicht = {tr/tc:.1%}")
    print(f"  Median SELF je Modul: "
          f"{sorted(d['self'] for d in ok)[len(ok)//2]:.1%}")
    print(f"  base=: {dict(collections.Counter(d['base'] for d in ok).most_common(6))}")
    print(f"-> {a.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
