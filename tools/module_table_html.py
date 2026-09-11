#!/usr/bin/env python3
"""Render module-table.tsv as one page you can actually work in.

The TSV is the record; this is the instrument. Every summary figure on it is a
filter, so "144 modules where the tool is at fault" is one click away from the
144 module names and what each assembler said about them.
"""
import html, json, os, re, sys
from collections import Counter
from datetime import datetime

RUN = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
TSV = f"{RUN}/module-table.tsv"
OUT = sys.argv[1] if len(sys.argv) > 1 else f"{RUN}/module-table.html"


def band(v):
    if not v or not v.isdigit():
        return "?"
    v = int(v)
    return "0" if v == 0 else "4" if v == 4 else "8+"


def scoreable(rc):
    """Mirrors tools/retest.py in ../cc370: a distance verdict needs a
    reference IFOX00 actually finished. rc<=4 is a statement; rc>4 is a run
    IFOX00 abandoned, and a distance against it is not a statement about
    what IFOX00 produces."""
    return rc.isdigit() and int(rc) <= 4


def rows():
    lines = open(TSV).read().splitlines()
    head = lines[0].split("\t")
    for l in lines[1:]:
        yield dict(zip(head, l.split("\t")))


def commit_line(text):
    parts = text.strip().split(None, 1)
    return tuple(parts) if len(parts) == 2 else None


STALE_S = 300  # tolerance between a provenance file's mtime and the table's


def provenance(tsv_mtime):
    """The as370 commit module-table.tsv's decks were built from, and when.

    PROVENANCE.txt is written by the same pipeline run that writes
    module-table.tsv, so in that run its mtime lands within seconds of the
    table's. That is also what makes it detectably stale: this directory is
    live (other steps of the same pipeline regenerate module-table.tsv on
    their own schedule), and a PROVENANCE.txt more than STALE_S away from the
    table's mtime was written by a DIFFERENT cut and must not be trusted for
    this one. `as370/.commit` tracks the CURRENT as370 build, which routinely
    runs ahead of the last cut table -- a fresh build there does not imply a
    fresh table here -- so it only ever stands in when PROVENANCE.txt is
    absent or stale AND it is itself no younger than the table. Guessing a
    commit onto data it might not match is worse than naming none.
    """
    p = f"{RUN}/PROVENANCE.txt"
    if os.path.exists(p) and abs(os.path.getmtime(p) - tsv_mtime) <= STALE_S:
        # `decks from' is the field this function's docstring promises: the
        # commit the DECKS were built from, which is what every tool, first_diff
        # and length column in the table came out of. It is not always the same
        # commit that ran the messages -- on 2026-09-11 the decks came from a PR
        # head and the messages from origin/main after it merged. PROVENANCE.txt
        # records both since then; `cc370 commit' is the older single-field name
        # and is still read so an older file still stamps a page.
        decks = fallback = cut = None
        for line in open(p):
            m = re.match(r"\s*decks from\s+(.+?)\s*$", line)
            if m and not decks:
                decks = commit_line(m.group(1))
            m = re.match(r"\s*(?:messages from|cc370 commit)\s+(.+?)\s*$", line)
            if m and not fallback:
                fallback = commit_line(m.group(1))
            m = re.match(r"\s*cut at\s+(.+?)\s*$", line)
            if m:
                cut = m.group(1)
        commit = decks or fallback
        if commit:
            return commit[0], commit[1], cut
    d = f"{RUN}/as370/.commit"
    if os.path.exists(d) and os.path.getmtime(d) <= tsv_mtime + STALE_S:
        commit = commit_line(open(d).read())
        if commit:
            return commit[0], commit[1], None
    return None


def main():
    tsv_mtime = os.path.getmtime(TSV)   # stat before read: a regen mid-read must not
    data = list(rows())                 # pair fresh rows with a stale provenance stat
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
        r["_score"] = "yes" if scoreable(r["ifox_rc"]) else "no"
    cls = Counter(r["_class"] for r in data)
    mat = Counter((r["_a"], r["_i"]) for r in data)
    tool = Counter(r["tool"] for r in data)
    score = Counter(r["_score"] for r in data)
    n_unscoreable = score.get("no", 0)
    n_marked = sum(1 for r in data if r["_score"] == "no" and r["tool"] != "identical"
                   and r["first_diff"])

    slim = [[r["module"], r["as370_rc"], r["ifox_rc"], r["tool"], r["dlib"],
             r["first_diff"], r["len_ifox"], r["len_as370"],
             r["as370_messages"], r["ifox_messages"], r["_class"],
             r["_a"] + "/" + r["_i"], r.get("signal", ""), r.get("owner", ""),
             r["_score"], r.get("excluded", "")]
            for r in data]

    own = Counter(r.get("owner", "") for r in data)
    owncards = "".join(
        f'<button class="card own o-{k}" data-filter="own:{k}">'
        f'<span class="n">{own.get(k, 0)}</span><span class="l">{lab}</span></button>'
        for k, lab in (("cc370", "for cc370 — the assembler"),
                       ("source", "ours — the source")) if own.get(k))
    sig = Counter(r.get("signal", "") for r in data)
    sig_order = ["silent divergence", "as370 alone flags", "IFOX00 alone flags",
                 "both flag", "no deck", "did not finish"]
    sigcards = "".join(
        f'<button class="card sig s-{k.split()[0].lower()}" data-filter="sig:{k}">'
        f'<span class="n">{sig.get(k, 0)}</span><span class="l">{k}</span></button>'
        for k in sig_order if sig.get(k))

    labels = {"recovered": "recovered", "source": "source", "holes": "source, DS holes only",
              "tool": "tool", "unattributable": "no deck", "unpaired": "no DLIB member"}
    order = ["tool", "source", "holes", "recovered", "unpaired", "unattributable"]
    cards = "".join(
        f'<button class="card c-{k}" data-filter="class:{k}">'
        f'<span class="n">{cls.get(k, 0)}</span>'
        f'<span class="l">{labels[k]}</span></button>'
        for k in order if cls.get(k))

    score_meta = {
        "no": ("not scoreable", "IFOX00 return code above 4 — the run it "
               "would be measured against did not finish"),
        "yes": ("scoreable", "IFOX00 return code 4 or below"),
    }
    scorecards = "".join(
        f'<button class="card score sc-{k}" data-filter="score:{k}" title="{html.escape(tip)}">'
        f'<span class="n">{score.get(k, 0)}</span><span class="l">{lab}</span></button>'
        for k, (lab, tip) in score_meta.items() if score.get(k))

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

    prov = provenance(tsv_mtime)
    gen_ts = datetime.now().strftime("%Y-%m-%d %H:%M")
    prov_line = f"rendered {html.escape(gen_ts)}"
    if prov:
        phash, psubj, pcut = prov
        prov_line += (f' · as370 @ {html.escape(phash)} '
                      f'&ldquo;{html.escape(psubj)}&rdquo;')
        if pcut:
            prov_line += f", decks cut {html.escape(pcut)}"

    distnote = (
        f"{n_unscoreable} modules carry an IFOX00 return code above 4; a distance "
        f"against a run IFOX00 did not finish isn&rsquo;t a statement about what "
        f"IFOX00 produces. {n_marked} of those differ from as370 and are marked "
        f'&ldquo;not scored&rdquo; below in first diff / IFOX B / as370 B; filter to '
        f'&ldquo;not scoreable&rdquo; for the full set. Identity is unaffected — a '
        f"byte-identical deck is a fact whatever the return code was.")

    tpl = open(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            "module_table.tpl.html")).read()
    page = (tpl.replace("/*DATA*/", json.dumps(slim, separators=(",", ":")))
               .replace("<!--CARDS-->", cards)
               .replace("<!--SIGCARDS-->", sigcards)
               .replace("<!--OWNCARDS-->", owncards)
               .replace("<!--SCORECARDS-->", scorecards)
               .replace("<!--DISTNOTE-->", distnote)
               .replace("<!--MHEAD-->", thead)
               .replace("<!--MBODY-->", body)
               .replace("<!--TOTAL-->", str(len(data)))
               .replace("<!--PROVENANCE-->", prov_line)
               .replace("<!--TOOLBREAK-->", html.escape(
                   ", ".join(f"{v} {k}" for k, v in tool.most_common() if k))))
    open(OUT, "w").write(page)
    print(f"{len(data)} rows -> {OUT}  ({os.path.getsize(OUT) / 1024:.0f} KB)")
    print(f"  scoreable {score.get('yes', 0)}, not scoreable {n_unscoreable} "
          f"({n_marked} of those carry a distance value)")
    print(f"  provenance: {prov_line}" if prov else
          "  provenance: no commit found (PROVENANCE.txt / as370/.commit missing or stale)")


if __name__ == "__main__":
    main()
