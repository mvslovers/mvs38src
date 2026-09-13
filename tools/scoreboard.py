#!/usr/bin/env python3
"""The scoreboard: how much of MVS 3.8j we can rebuild from source, by library.

Written into README.md between the scoreboard markers, and GENERATED rather
than maintained. A hand-kept figure in a prominent place is the one that goes
stale first, and this repository has already paid for that lesson twice.

Two numbers, and they must be quoted together or not at all:

  * `as370` == IFOX00 is a TOOL figure -- our assembler agrees with IBM's. It
    says nothing about whether the source carries the object's maintenance.
  * the build's CSECT == IBM's shipped CSECT is the PROJECT figure.

    scoreboard.py [--check]      --check exits 1 if README is out of date
"""
import argparse, collections, os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
TGT = os.path.join(ROOT, "work/build/reports-tk5-run6/RPTTGT")
DLB = os.path.join(ROOT, "work/build/reports-tk5-run6/RPTDLB")
HOST = os.path.join(ROOT, "work/measurements/src-states/ss-run7-vs-tk5.tsv")
OVERLAY = os.path.join(ROOT, "work/measurements/src-states/ss-overlay-vs-tk5.tsv")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate/overlay-vs-both.tsv")
START, END = "<!-- scoreboard:start -->", "<!-- scoreboard:end -->"


def per_library(prefix):
    """(library -> (built, equal)) from the ERRORS detail, not the SUMMARY page.

    SUMMARY's `Compared not equal` is 0 on every run taken here, so its
    `Total equal` counts the CSECTs that differ in content at the same length
    as equal. The authority is the detail. See build-vs-original-tk5.md.
    """
    built = {}
    for line in open(prefix + ".SUMMARY.SYSPRINT.txt", encoding="latin-1"):
        m = re.match(r"^ ([A-Z0-9]{3,10})\s+([\d,]+)\s+([\d,]+)\s+([\d,]+)\*?\s+"
                     r"([\d,]+)\*?\s+([\d,]+)\s+([\d,]+)\s*$",
                     line.rstrip("\n").replace("*", "* "))
        if m:
            built[m.group(1)] = int(m.group(5).replace(",", ""))
    seen = {}
    for line in open(prefix + ".ERRORS.SYSPRINT.txt", encoding="latin-1"):
        parts = re.split(r"[¦º|]", line.rstrip("\n"))
        if len(parts) < 3 or not parts[-1].strip():
            continue
        m = re.match(r"^ ([A-Z0-9@#$]{1,10})\s+(\S+)\s+(\S+)\s+([0-9A-F]{6})", parts[0])
        if m:
            seen[m.groups()[:3]] = parts[-1].strip()
    bad = collections.Counter()
    for (lib, _, _), note in seen.items():
        if note.startswith(("Length difference", "CSECTs don't match", "Extra")):
            bad[lib] += 1
    return {lib: (n, n - bad.get(lib, 0)) for lib, n in built.items() if n}


def host_identity(path=None):
    n = ident = 0
    for row in open(path or HOST, encoding="utf-8"):
        f = row.rstrip("\n").split("\t")
        if len(f) < 3 or f[0] == "module":
            continue
        n += 1
        ident += f[2] == "identical"
    return ident, n


def chosen_baseline(path=None):
    """Every figure the two-baseline block quotes, COMPUTED.

    The project figure is the baseline Mike chose on 2026-09-13: the TARGET
    library where the CSECT has one, the DLIB where it does not.

    A module whose target member `cmplmd370` cannot read counts as NOT identical,
    even where the DLIB says it is. Falling back to the DLIB there would quietly
    credit the project with modules nothing has measured against the chosen
    baseline. The class is named in docs/baseline-dlib-vs-target.md; it is an
    instrument gap, not a result.

    **Everything here used to be a literal in the template and every one of them
    went stale within the day** -- 1,236 / 1,069 / 1,052 / 143 / 18 were measured
    before 201 modules were deposited, and `--check` cannot see a stale literal
    because it only compares README against the tool. Same failure as the DLIB
    figure, one layer up. Nothing in the block is hand-written now.

    `disagree` is also a correction: the block used to say the yardstick "moves
    167 verdicts", which is 1,236 - 1,069 -- the difference between two TOTALS,
    not a count of anything. The number of modules the two baselines actually
    disagree about is counted here, over the modules that have both references.
    """
    p = path or GATE
    if not os.path.exists(p):
        return None
    rows = [l.rstrip("\n").split("\t") for l in open(p, encoding="utf-8")]
    i = {k: n for n, k in enumerate(rows[0])}
    d = dict(n=0, chosen=0, dlib=0, tgt=0, both=0, unread=0, unread_dlib_ok=0,
             disagree=0, no_tgt=0)
    for r in rows[1:]:
        if len(r) < len(rows[0]):
            continue
        d["n"] += 1
        t, dl = r[i["tgt_c"]], r[i["dlib_c"]]
        di, ti = dl == "identical", t == "identical"
        d["dlib"] += di
        d["tgt"] += ti
        d["both"] += di and ti
        if t == "not-in-target":
            d["no_tgt"] += 1
            d["chosen"] += di
        elif t in ("error", "unpaired", "no-ref"):
            d["unread"] += 1
            d["unread_dlib_ok"] += di
        else:
            d["chosen"] += ti
            d["disagree"] += di != ti
    return d


def src_target_only(path=None):
    """How many modules in src/ reach the TARGET and not the DLIB.

    Another literal that went stale the same day it was written: it said "Four"
    while the answer was already seven. A source repaired against the target
    cannot also reach the DLIB where the two libraries hold different bytes, so
    this number grows with every such repair and must never be typed.
    """
    import glob
    p = path or GATE
    if not os.path.exists(p):
        return 0
    ours = {os.path.basename(f)[:-4]
            for f in glob.glob(os.path.join(ROOT, "src", "*", "*.ASM"))}
    rows = [l.rstrip("\n").split("\t") for l in open(p, encoding="utf-8")]
    i = {k: n for n, k in enumerate(rows[0])}
    return sum(1 for r in rows[1:] if len(r) >= len(rows[0])
               and r[i["module"]] in ours
               and r[i["tgt_c"]] == "identical" and r[i["dlib_c"]] != "identical")


def render():
    tgt = per_library(TGT)
    tb = sum(v[0] for v in tgt.values()); te = sum(v[1] for v in tgt.values())
    hi, hn = host_identity()
    oi = on = None
    if os.path.exists(OVERLAY):
        oi, on = host_identity(OVERLAY)
    L = [START, "",
         "### How much of MVS 3.8j rebuilds byte-identical to what IBM shipped",
         "",
         "The assembled CSECT is byte-identical to IBM's, or it is not. Nothing else counts.",
         "",
         f"| | CSECTs built | **identical to IBM's** | |",
         f"|---|---:|---:|---:|"]
    for lib, (b, e) in sorted(tgt.items(), key=lambda x: -x[1][0]):
        L.append(f"| `SYS1.{lib}` | {b:,} | **{e:,}** | {100*e/b:.1f} % |")
    L += [f"| **total** | **{tb:,}** | **{te:,}** | **{100*te/tb:.1f} %** |", "",
          f"Measured a second time from the other side, on the host against TK5's "
          f"distribution libraries: **{hi:,} of {hn:,}** — {100*hi/hn:.1f} %. Two "
          f"different programs, two different populations, two machines.", ""]
    if oi is not None:
        L += [f"**With the source recovered so far**, the same measurement reads "
              f"**{oi:,} of {on:,}** — {100*oi/on:.1f} %. The first figure says how far "
              f"Dave Kreiss got; this one says where the project is. Both are wanted.",
              "",
              f"> **`src/` no longer contributes +1 apiece to this figure, and that is "
              f"deliberate.** It held until 2026-09-12, when every module in `src/` was "
              f"repaired against the DLIB. **{src_target_only()}** are now repaired "
              f"against the **target** instead and therefore differ from the DLIB by "
              f"exactly the amount they used to differ from the target — one source "
              f"cannot reach two different objects. The figure that counts `src/` under "
              f"the chosen baseline is the next one down.", ""]
    c = chosen_baseline()
    if c is not None:
        L += [f"### Under the baseline the project chose on 2026-09-13", "",
              f"Dave Kreiss: *\"target not DLIB is the version of code you should "
              f"compare to since target is what the running system uses.\"* Measured "
              f"([`docs/baseline-dlib-vs-target.md`](docs/baseline-dlib-vs-target.md)), "
              f"the two baselines **disagree about {c['disagree']:,} modules** of the "
              f"{c['n'] - c['no_tgt'] - c['unread']:,} that have a member in both, so "
              f"the yardstick is now **TK5's target library where the CSECT has one, "
              f"its DLIB where it does not**:", "",
              f"| | modules | |", f"|---|---:|---:|",
              f"| **recovered under the chosen baseline** | "
              f"**{c['chosen']:,} of {c['n']:,}** | **{100*c['chosen']/c['n']:.1f} %** |",
              "",
              f"The figures above it are not withdrawn and do not contradict it: the "
              f"same decks are identical to **{c['dlib']:,}** DLIB members, "
              f"**{c['tgt']:,}** target members, and **{c['both']:,}** of both. "
              f"**{c['unread']:,} modules are counted as not recovered because "
              f"`cmplmd370` cannot read their target member** — `IEANUC01` and the "
              f"overlay-structured load modules — and {c['unread_dlib_ok']:,} of those "
              f"the DLIB does call identical. That is an instrument gap, not a result, "
              f"and it is the cheapest {c['unread_dlib_ok']:,} modules on the board. A "
              f"further **{c['no_tgt']:,}** have no target counterpart at all, and for "
              f"those the DLIB is the only object there is.", ""]
    L += [
          "> **Not to be confused with the tool figure.** `as370` reproduces IFOX00's "
          "deck for **5,471 of 5,528** modules — that says our assembler is "
          "trustworthy, not that the source carries the object's maintenance level. "
          "A module is routinely in that 98 % and not in the table above, and that "
          "gap is what this project is about.", "", END]
    return "\n".join(L)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    p = os.path.join(ROOT, "README.md")
    s = open(p, encoding="utf-8").read()
    new = render()
    if START not in s:
        sys.exit(f"{p}: no {START} marker")
    out = re.sub(re.escape(START) + r".*?" + re.escape(END), lambda _: new, s, flags=re.S)
    if a.check:
        sys.exit(0 if out == s else "README scoreboard is out of date -- run tools/scoreboard.py")
    open(p, "w", encoding="utf-8").write(out)
    print("README scoreboard updated")


if __name__ == "__main__":
    main()
