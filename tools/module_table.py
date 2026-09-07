#!/usr/bin/env python3
"""One row per module: what each assembler did with it, and what it said.

Joins the four measurements into the table the work is steered by:

  as370   return code, statements flagged, highest severity, its messages
  IFOX00  the same, from the LIST pass -- only for modules it flagged, because
          a clean assembly has no diagnostics to fetch and the listing is 600 KB
  decks   the verdict of comparing the two object decks, and where they part
  DLIB    the verdict of comparing the as370 deck against IBM's shipped object

Written to `module-table.tsv`; `module-table-flagged.tsv` is the same table
reduced to the rows where at least one assembler had something to say.
"""
import os, re
from collections import Counter

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
IFO = re.compile(r"^.?\s*(\d+)\s+(IFO\d+)\s+(.+?)\s*$", re.M)
FLAG = re.compile(r"NUMBER OF STATEMENTS FLAGGED IN THIS ASSEMBLY =\s*(\d+)")
SEV = re.compile(r"HIGHEST SEVERITY WAS\s*(\d+)")


def ifox_messages(m):
    p = f"{RUN}/diag/{m}.txt"
    if not os.path.exists(p):
        return "", "", ""
    t = open(p, errors="replace").read()
    seen, order = set(), []
    for _stmt, code, text in IFO.findall(t):
        key = f"{code} {text.strip()}"
        if key not in seen:
            seen.add(key)
            order.append(key)
    f = FLAG.search(t)
    s = SEV.search(t)
    return (f.group(1) if f else "", s.group(1) if s else "", " | ".join(order[:6]))


def tsv(path, keycol=0):
    out = {}
    if not os.path.exists(path):
        return out
    lines = open(path).read().splitlines()
    head = lines[0].split("\t")
    for l in lines[1:]:
        f = l.split("\t")
        if f and f[keycol]:
            out[f[keycol]] = dict(zip(head, f))
    return out


def main():
    verd = tsv(f"{RUN}/verdicts.tsv")
    a370 = tsv(f"{RUN}/as370-messages.tsv")
    state = tsv(f"{RUN}/state.tsv")
    diffs = {}
    if os.path.exists(f"{RUN}/tool-diffs.tsv"):
        for l in open(f"{RUN}/tool-diffs.tsv").read().splitlines()[1:]:
            f = l.split("\t")
            diffs.setdefault(f[0], f)          # first section only

    head = ["module", "as370_rc", "as370_flagged", "as370_severity", "as370_messages",
            "ifox_rc", "ifox_flagged", "ifox_severity", "ifox_messages",
            "tool", "first_diff", "len_ifox", "len_as370", "dlib"]
    rows = []
    for m in sorted(verd):
        v, a, s = verd[m], a370.get(m, {}), state.get(m, {})
        ff, sv, msg = ifox_messages(m)
        d = diffs.get(m, ["", "", "", "", "", "", ""])
        rows.append([m, a.get("rc", ""), a.get("flagged", ""), a.get("severity", ""),
                     a.get("messages", ""),
                     s.get("ifox_rc", ""), ff, sv, msg,
                     v.get("tool_restamped") or v.get("tool", ""),
                     d[4], d[2], d[3], v.get("dlib", "")])
    with open(f"{RUN}/module-table.tsv", "w") as f:
        f.write("\t".join(head) + "\n")
        for r in rows:
            f.write("\t".join(r) + "\n")
    flagged = [r for r in rows if r[4] or r[8]]
    with open(f"{RUN}/module-table-flagged.tsv", "w") as f:
        f.write("\t".join(head) + "\n")
        for r in flagged:
            f.write("\t".join(r) + "\n")

    print(f"{len(rows)} rows -> module-table.tsv, {len(flagged)} of them with a message")
    pair = Counter((r[1] and ("0" if r[1] == "0" else "8+"),
                    "0" if r[5] == "0000" else "8+" if r[5].isdigit() else "?")
                   for r in rows)
    print("\nas370 rc x IFOX rc:")
    for k, v in pair.most_common():
        print(f"  as370 {k[0]:>2s} / IFOX {k[1]:>2s}: {v}")
    print("\nthe most common message on each side:")
    for col, name in ((4, "as370"), (8, "IFOX00")):
        c = Counter(x for r in rows for x in r[col].split(" | ") if x)
        for k, v in c.most_common(6):
            print(f"  {name:7s} {v:5d}  {k[:70]}")


if __name__ == "__main__":
    main()
