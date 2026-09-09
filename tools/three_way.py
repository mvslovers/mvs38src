#!/usr/bin/env python3
"""A third opinion: as370, IFOX00, and IBM's shipped object.

Every other instrument here compares `as370` against IFOX00 and treats IFOX00 as
the authority. On the silent divergences that is the whole difficulty -- neither
assembler says anything, so nothing in either output says which one is wrong.

IBM's DLIB object is a witness neither of them produced. Where **IFOX00's deck is
byte-identical to it and `as370`'s is not**, the question is settled without any
appeal to the oracle's authority: two independent parties agree and one does not.

That is a much smaller and much harder set than "the silent divergences", and it
is the only part of them where being wrong is not a matter of interpretation.

Run after a promote:  three_way.py [--signal silent]
"""
import os, sys, json, subprocess, collections
from concurrent.futures import ThreadPoolExecutor

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
DLIB = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/dlib")


def index():
    ix = {}
    for root, _, fs in os.walk(DLIB):
        for f in fs:
            if f.endswith(".dlib"):
                ix[f[:-5]] = os.path.join(root, f)
    return ix


def same(obj, ref):
    p = subprocess.run(["cmplmd370", "--json", obj, ref],
                       capture_output=True, text=True)
    try:
        r = json.loads(p.stdout)
    except Exception:
        return "error"
    return "identical" if (p.returncode == 0 or r.get("identical")) else "differs"


def main():
    sig = sys.argv[sys.argv.index("--signal") + 1] if "--signal" in sys.argv else "silent divergence"
    head = open(f"{RUN}/module-table.tsv").readline().rstrip("\n").split("\t")
    H = {h: i for i, h in enumerate(head)}
    rows = [r.split("\t") for r in
            open(f"{RUN}/module-table.tsv").read().splitlines()[1:]]
    mods = [r[0] for r in rows
            if r[H["tool"]] != "identical" and not r[H["excluded"]]
            and (sig == "all" or r[H["signal"]] == sig)]
    ix = index()

    def one(m):
        ref = ix.get(m)
        if not ref:
            return m, "no-pair", "no-pair"
        return m, same(f"{RUN}/as370/{m}.obj", ref), same(f"{RUN}/decks/{m}.obj", ref)

    c, who = collections.Counter(), collections.defaultdict(list)
    with ThreadPoolExecutor(8) as ex:
        for m, a, i in ex.map(one, mods):
            c[(a, i)] += 1
            who[(a, i)].append(m)

    print(f"{len(mods)} modules ({sig}) against IBM's shipped object\n")
    print(f"{'as370 vs IBM':>14} {'IFOX00 vs IBM':>15}   modules")
    for k, n in c.most_common():
        print(f"{k[0]:>14} {k[1]:>15}   {n}")

    settled = sorted(who[("differs", "identical")])
    print(f"\nSETTLED AGAINST as370 -- IFOX00 matches IBM's object and as370 does "
          f"not ({len(settled)}):")
    print("  " + " ".join(settled))
    other = sorted(who[("identical", "differs")])
    if other:
        print(f"\nSettled the other way -- as370 matches IBM and IFOX00 does not "
              f"({len(other)}):")
        print("  " + " ".join(other))
    both = sorted(who[("identical", "identical")])
    if both:
        print(f"\nBoth match IBM within cmplmd370's tolerance yet differ from each "
              f"other ({len(both)}): {' '.join(both)}")
    with open(f"{RUN}/classes/settled-against-as370.txt", "w") as f:
        f.write("".join(f"{m}\n" for m in settled))
    print(f"\n{RUN}/classes/settled-against-as370.txt")


if __name__ == "__main__":
    main()
