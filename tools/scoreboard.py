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
              f"Dave Kreiss got; this one says where the project is. Both are wanted, "
              f"and the difference is exactly the number of modules in `src/`.", ""]
    L += [
          "> **Not to be confused with the tool figure.** `as370` reproduces IFOX00's "
          "deck for **5,427 of 5,528** modules — that says our assembler is "
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
