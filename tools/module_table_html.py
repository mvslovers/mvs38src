#!/usr/bin/env python3
"""Render module-table.tsv as one page you can actually work in.

The TSV is the record; this is the instrument. Every summary figure on it is a
filter, so "144 modules where the tool is at fault" is one click away from the
144 module names and what each assembler said about them.
"""
import html, json, os, sys
from collections import Counter

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
OUT = sys.argv[1] if len(sys.argv) > 1 else f"{RUN}/module-table.html"


def band(v):
    if not v or not v.isdigit():
        return "?"
    v = int(v)
    return "0" if v == 0 else "4" if v == 4 else "8+"


def rows():
    lines = open(f"{RUN}/module-table.tsv").read().splitlines()
    head = lines[0].split("\t")
    for l in lines[1:]:
        yield dict(zip(head, l.split("\t")))


def main():
    data = list(rows())
    for r in data:
        t = r["tool"]
        d = r["dlib"]
        r["_a"] = band(r["as370_rc"])
        r["_i"] = band(r["ifox_rc"][-2:] if r["ifox_rc"].isdigit() else r["ifox_rc"])
        r["_class"] = ("unattributable" if t.startswith("no-") else
                       "tool" if t != "identical" else
                       "recovered" if d == "identical" else
                       "holes" if d == "holes" else
                       "source" if d and d != "no-pair" else "unpaired")
    cls = Counter(r["_class"] for r in data)
    mat = Counter((r["_a"], r["_i"]) for r in data)
    tool = Counter(r["tool"] for r in data)

    slim = [[r["module"], r["as370_rc"], r["ifox_rc"], r["tool"], r["dlib"],
             r["first_diff"], r["len_ifox"], r["len_as370"],
             r["as370_messages"], r["ifox_messages"], r["_class"],
             r["_a"] + "/" + r["_i"]] for r in data]

    labels = {"recovered": "recovered", "source": "source", "holes": "source, DS holes only",
              "tool": "tool", "unattributable": "no deck", "unpaired": "no DLIB member"}
    order = ["tool", "source", "holes", "recovered", "unpaired", "unattributable"]
    cards = "".join(
        f'<button class="card c-{k}" data-filter="class:{k}">'
        f'<span class="n">{cls.get(k, 0)}</span>'
        f'<span class="l">{labels[k]}</span></button>'
        for k in order if cls.get(k))

    bands = ["0", "4", "8+", "?"]
    used = [b for b in bands if any((a, b) in mat or (b, a) in mat for a in bands)]
    thead = "".join(f"<th>{b}</th>" for b in used)
    body = ""
    for a in used:
        cells = ""
        for i in used:
            n = mat.get((a, i), 0)
            cells += (f'<td><button class="mx{" on" if a != i and n else ""}"'
                      f' data-filter="rc:{a}/{i}">{n or ""}</button></td>' if n
                      else "<td></td>")
        body += f"<tr><th>{a}</th>{cells}</tr>"

    tpl = open(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            "module_table.tpl.html")).read()
    page = (tpl.replace("/*DATA*/", json.dumps(slim, separators=(",", ":")))
               .replace("<!--CARDS-->", cards)
               .replace("<!--MHEAD-->", thead)
               .replace("<!--MBODY-->", body)
               .replace("<!--TOTAL-->", str(len(data)))
               .replace("<!--TOOLBREAK-->", html.escape(
                   ", ".join(f"{v} {k}" for k, v in tool.most_common() if k))))
    open(OUT, "w").write(page)
    print(f"{len(data)} rows -> {OUT}  ({os.path.getsize(OUT) / 1024:.0f} KB)")


if __name__ == "__main__":
    main()
