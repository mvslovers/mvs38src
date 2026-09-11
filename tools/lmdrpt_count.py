import os, sys
#!/usr/bin/env python3
"""Count Dave's `LMDRPT38` report -- from the ERRORS detail, not the SUMMARY page.

`ZLMDRPTD` and `ZLMDRPTT` each print three reports.  SUMMARY looks like the
answer and is not: its second-to-last column counts only the CSECTs whose
*length* differs, and its last column ("Not EQ") is 0 on every run anyone here
has taken.  A CSECT that differs in content at the same length appears nowhere
on that page.  The authority is the per-CSECT ERRORS detail, which annotates
every non-equal CSECT with why.

That distinction is not academic.  `docs/build-vs-original-tk5.md` reported
"equal to the original 2,756" for run 5, and 2,756 = 5,369 built - 2,624 length
differences: the 1,745 CSECTs differing in content at the same length were
counted as equal.

  lmdrpt_count.py <ERRORS.txt> <SUMMARY.txt>

Counts DISTINCT (library, LMOD, CSECT) triples, because a CSECT can occupy
several lines of the detail report.
"""
import re, collections


def errors(path):
    seen = {}
    for line in open(path, encoding="latin-1"):
        parts = re.split(r"[¦º|]", line.rstrip("\n"))
        if len(parts) < 3:
            continue
        note = parts[-1].strip()
        if not note:
            continue
        m = re.match(r"^ ([A-Z0-9@#$]{1,8})\s+(\S+)\s+(\S+)\s+([0-9A-F]{6})", parts[0])
        key = (m.group(1), m.group(2), m.group(3)) if m else ("?", parts[0][:40], note)
        seen[key] = re.sub(r"\(-?[\d,]+\)", "", note).strip()
    return collections.Counter(seen.values())


def summary(path):
    """read the totals block, not the per-library columns.

    The block is the report's own arithmetic and it is where the trap lives:

        Compared equal          3,038
        Total equal             3,092
        Compared not equal          0      <- always 0 on every run taken here
        Length different        2,399
        Total not equal         2,399
        Total CSECTs            5,485

    `Compared not equal 0` is not a finding.  The ERRORS detail annotates 1,664
    CSECTs "don't match" for the same run -- content differing at the same
    length -- and this page counts every one of them inside `Total equal`.
    So `Total CSECTs` is taken from here and nothing else is.
    """
    tot = {}
    want = ("Total CSECTs", "Total equal", "Total not equal",
            "Compared equal", "Compared not equal", "Length different")
    for line in open(path, encoding="latin-1"):
        line = line.rstrip("\n")
        for w in want:
            m = re.match(r"^\s*" + re.escape(w) + r"\s+([\d,]+)", line)
            if m:
                tot[w] = int(m.group(1).replace(",", ""))
    return tot


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    a = errors(sys.argv[1])
    t = summary(sys.argv[2])
    length = sum(v for k, v in a.items() if k.startswith("Length difference"))
    content = sum(v for k, v in a.items() if k.startswith("CSECTs don't match"))
    misslmod = sum(v for k, v in a.items() if k.startswith("Missing build LMOD"))
    extra = sum(v for k, v in a.items() if k.startswith("Extra"))
    other = {k: v for k, v in a.items()
             if not any(k.startswith(p) for p in
                        ("Length difference", "CSECTs don't match",
                         "Missing build LMOD", "Extra"))}
    built = t["Total CSECTs"]
    print(f"Total CSECTs (SUMMARY)          {built:6d}")
    print(f"  SUMMARY says equal            {t['Total equal']:6d}"
          f"   <- counts the content differences below as equal")
    print(f"length differs                  {length:6d}")
    print(f"content differs, same length    {content:6d}")
    print(f"missing build LMOD              {misslmod:6d}")
    print(f"extra CSECT in LMOD             {extra:6d}")
    for k, v in sorted(other.items()):
        print(f"  other: {k:28s}{v:6d}")
    print(f"EQUAL = {built} - ({length} + {content} + {extra})"
          f"       {built - length - content - extra:6d}")


if __name__ == "__main__":
    main()
