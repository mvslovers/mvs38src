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
    """The project figure under the baseline Mike chose on 2026-09-13:
    the TARGET library where the CSECT has one, the DLIB where it does not.

    A module whose target member `cmplmd370` cannot read counts as NOT identical,
    even where the DLIB says it is. That is 143 modules, 18 of them DLIB-identical,
    and falling back to the DLIB there would quietly credit the project with
    modules nothing has measured against the chosen baseline. The class is named
    in docs/baseline-dlib-vs-target.md; it is an instrument gap, not a result.
    """
    p = path or GATE
    if not os.path.exists(p):
        return None, None, None
    rows = [l.rstrip("\n").split("\t") for l in open(p, encoding="utf-8")]
    i = {k: n for n, k in enumerate(rows[0])}
    n = ident = unread = 0
    for r in rows[1:]:
        if len(r) < len(rows[0]):
            continue
        n += 1
        t, d = r[i["tgt_c"]], r[i["dlib_c"]]
        if t == "identical":
            ident += 1
        elif t == "not-in-target" and d == "identical":
            ident += 1
        elif t in ("error", "unpaired", "no-ref"):
            unread += 1
    return ident, n, unread


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
              f"repaired against the DLIB. Four are now repaired against the **target** "
              f"instead and therefore differ from the DLIB by exactly the amount they "
              f"used to differ from the target — one source cannot reach two different "
              f"objects. The figure that counts `src/` under the chosen baseline is the "
              f"next one down.", ""]
    ci, cn, cu = chosen_baseline()
    if ci is not None:
        L += [f"### Under the baseline the project chose on 2026-09-13", "",
              f"Dave Kreiss: *\"target not DLIB is the version of code you should "
              f"compare to since target is what the running system uses.\"* Measured "
              f"([`docs/baseline-dlib-vs-target.md`](docs/baseline-dlib-vs-target.md)), "
              f"the two baselines are 167 verdicts apart, so the yardstick is now "
              f"**TK5's target library where the CSECT has one, its DLIB where it does "
              f"not**:", "",
              f"| | modules | |", f"|---|---:|---:|",
              f"| **recovered under the chosen baseline** | **{ci:,} of {cn:,}** | "
              f"**{100*ci/cn:.1f} %** |", "",
              f"The figures above it are not withdrawn and do not contradict it: "
              f"1,236 is the same decks against the DLIB alone, 1,069 against the "
              f"target alone, 1,052 against both. **{cu:,} modules are counted as not "
              f"recovered because `cmplmd370` cannot read their target member** — "
              f"`IEANUC01` and the overlay-structured load modules — and 18 of those "
              f"the DLIB does call identical. That is an instrument gap, not a result, "
              f"and it is the cheapest 18 modules on the board.", ""]
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
