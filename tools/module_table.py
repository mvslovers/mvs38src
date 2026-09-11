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
import time
import os, sys, re
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


def signal(as370_rc, ifox_rc, tool):
    """The name of what this row is a case of.

    Two axes: do the assemblers agree that something is wrong, and do their
    decks agree. The dangerous cell is neither -- both silent, both exit clean,
    and the object code is different anyway. IGG019PF is the pattern: as370
    emits 265 bytes where IFOX00 emits 144 and neither says a word.
    """
    a = int(as370_rc) if as370_rc.isdigit() else None
    i = int(ifox_rc) if ifox_rc.isdigit() else None
    if a is None or i is None:
        return "did not finish"
    if a >= 8 and i == 0:
        return "as370 alone flags"
    if a == 0 and i >= 8:
        return "IFOX00 alone flags"
    if a >= 8 and i >= 8:
        return "both flag"
    if tool in ("bytes", "cards"):
        return "silent divergence"          # both clean, decks differ anyway
    if tool.startswith("no-"):
        return "no deck"
    return ""


def owner(as370_rc, ifox_rc, tool, sig):
    """Whose problem this row is.

    `cc370` means the assembler is demonstrably at fault: the two decks differ
    although the source and the macros were the same, or as370 rejects what
    Assembler XF assembles, or it produced no deck where XF produced one. That
    is the list to hand over for repair.

    `source` means the two assemblers agree and the difference is against IBM's
    shipped object -- our own work, not cc370's.
    """
    if tool in ("bytes", "cards") or tool == "no-as370-deck":
        return "cc370"
    if sig in ("as370 alone flags", "IFOX00 alone flags"):
        return "cc370"
    if tool == "identical":
        return "source"
    return "-"


RANK = {"cc370": 0, "source": 1, "-": 2}
SIGRANK = {"silent divergence": 0, "as370 alone flags": 1, "IFOX00 alone flags": 2,
           "both flag": 3, "no deck": 4, "did not finish": 5, "": 6}


def tsv(path, keycol=0):
    out = {}
    if not os.path.exists(path):
        return out
    lines = [l for l in open(path).read().splitlines() if not l.startswith("#")]
    # Leading `#' lines are a provenance header -- which assembler, which commit,
    # when. as370_messages.py writes one since 2026-09-11, after a run measured
    # two different binaries because the default path points into a working copy
    # another session builds in. A reader that takes line 0 as the header would
    # turn that record into a parse error, so the record is skipped here rather
    # than not written there.
    if not lines:
        return out
    head = lines[0].split("\t")
    for l in lines[1:]:
        f = l.split("\t")
        if f and f[keycol]:
            out[f[keycol]] = dict(zip(head, f))
    return out


def excluded():
    """Modules deliberately out of scope, with the reason each one is out.

    Not deleted: a number that quietly loses rows stops being checkable. They
    stay in module-table.tsv with the reason in their own column, and drop out
    of the hand-over list only.
    """
    p = f"{RUN}/excluded.tsv"
    if not os.path.exists(p):
        return {}
    return {l.split("\t")[0]: l.split("\t")[1]
            for l in open(p).read().splitlines()[1:] if "\t" in l}


def _deck_commit():
    """Which as370 built the decks -- NOT necessarily the one that ran the messages.

    gate.sh writes a .commit beside its output and the two halves genuinely come
    from different commits: on 2026-09-11 the decks were cut from a PR head and
    the messages from origin/main after it merged. Same assembler code, different
    commits, and the first version of this file reported only one of them -- the
    precise failure the paragraph below has warned about since 2026-09-10.
    """
    try:
        return open(f"{RUN}/as370/.commit").read().strip() or "unknown"
    except OSError:
        return "unknown"


def write_provenance():
    """Record what this cut was made against, beside the tables it produces."""
    binhdr = {}
    try:
        for l in open(f"{RUN}/as370-messages.tsv"):
            if not l.startswith("#"):
                break
            k, _, v = l[1:].strip().partition(" ")
            binhdr[k] = v.strip()
    except OSError:
        pass
    body = [
        "Derived tables in this directory -- what they were cut against.",
        "",
        f"  as370 binary   {binhdr.get('as370', 'unknown')}",
        f"  binary sha256  {binhdr.get('sha256', 'unknown')}",
        f"  messages from  {binhdr.get('commit', 'unknown')}",
        f"  decks from     {_deck_commit()}",
        f"  cut at         {time.strftime('%Y-%m-%d %H:%M')}",
        "",
        "Binary and commit are recorded separately on purpose: these tools read a",
        "binary AND stored state, and that is exactly where the two halves come from",
        "different commits without it being written down anywhere (cc370, 2026-09-10).",
        "",
        "Written by module_table.py, from the header as370_messages.py leaves in",
        "as370-messages.tsv. Both were hand-maintained until 2026-09-11 and both",
        "had drifted; a provenance record only helps if the thing it describes",
        "writes it.",
        "",
        "Regenerate the whole chain in this order -- each step feeds the next:",
        "",
        "  as370_messages.py <bin>   -> as370-messages.tsv",
        "  ifox_compare.py   <bin>   -> verdicts.tsv",
        "  ifox_cluster.py           -> tool-diffs.tsv",
        "  module_table.py           -> module-table.tsv  (and this file)",
        "  rebuild_classes.py <bin>  -> classes/*.txt",
        "",
    ]
    with open(f"{RUN}/PROVENANCE.txt", "w") as f:
        f.write("\n".join(body))


def main():
    verd = tsv(f"{RUN}/verdicts.tsv")
    # as370-messages.tsv is a CACHED input and nothing re-derived it for a day.
    # On 2026-09-09 it was eleven merges behind the promoted decks, and every
    # signal split reported from this table -- silent vs loud vs both-flag --
    # was computed from yesterday's diagnostics. It said IEFVEA returned rc 8
    # on a module whose deck had become byte-identical and whose gate row said
    # rc 0. The gate row was right.
    #
    # Regenerate it with `as370_messages.py <binary>` after every promote, in
    # the same breath as ifox_compare.py. This refuses to run on a file older
    # than the gate it would be described against.
    gate_mtime = os.path.getmtime(f"{RUN}/as370-gate.tsv")
    msg_mtime = os.path.getmtime(f"{RUN}/as370-messages.tsv")
    if msg_mtime < gate_mtime:
        sys.exit(f"STALE: as370-messages.tsv is older than as370-gate.tsv.\n"
                 f"  Run  python3 tools/as370_messages.py <as370-binary>  first.\n"
                 f"  Every signal in this table would otherwise describe an "
                 f"assembler that is no longer the one being measured.")
    a370 = tsv(f"{RUN}/as370-messages.tsv")
    state = tsv(f"{RUN}/state.tsv")
    diffs = {}
    if os.path.exists(f"{RUN}/tool-diffs.tsv"):
        for l in open(f"{RUN}/tool-diffs.tsv").read().splitlines()[1:]:
            f = l.split("\t")
            diffs.setdefault(f[0], f)          # first section only

    head = ["module", "as370_rc", "as370_flagged", "as370_severity", "as370_messages",
            "ifox_rc", "ifox_flagged", "ifox_severity", "ifox_messages",
            "tool", "first_diff", "len_ifox", "len_as370", "dlib", "signal", "owner",
            "excluded"]
    skip = excluded()
    rows = []
    for m in sorted(verd):
        v, a, s = verd[m], a370.get(m, {}), state.get(m, {})
        ff, sv, msg = ifox_messages(m)
        d = diffs.get(m, ["", "", "", "", "", "", ""])
        tool = v.get("tool_restamped") or v.get("tool", "")
        sg = signal(a.get("rc", ""), s.get("ifox_rc", ""), tool)
        rows.append([m, a.get("rc", ""), a.get("flagged", ""), a.get("severity", ""),
                     a.get("messages", ""),
                     s.get("ifox_rc", ""), ff, sv, msg,
                     tool, d[4], d[2], d[3], v.get("dlib", ""), sg,
                     owner(a.get("rc", ""), s.get("ifox_rc", ""), tool, sg),
                     skip.get(m, "")])

    # sorted so the hand-over list is one contiguous block at the top and
    # everything below it can go in a single stroke
    rows.sort(key=lambda r: (RANK.get(r[15], 3), SIGRANK.get(r[14], 9),
                             -int(r[11] or 0) if r[11].isdigit() else 0, r[0]))
    # PROVENANCE.txt is read by module_table_html.py to stamp the page with what
    # the tables were cut against. It used to be maintained by hand, so it drifted:
    # on 2026-09-11 it was a day behind a recut and the page fell back to the
    # as370 binary's own .commit -- which was SIXTEEN commits ahead of the data,
    # and would have printed a fix as the commit behind rows that predate it.
    # A provenance file nobody writes is the thing it exists to prevent. So the
    # step that cuts the tables writes it, from what it can actually see.
    write_provenance()
    with open(f"{RUN}/module-table.tsv", "w") as f:
        f.write("\t".join(head) + "\n")
        for r in rows:
            f.write("\t".join(r) + "\n")
    cc = [r for r in rows if r[15] == "cc370" and not r[16]]
    with open(f"{RUN}/for-cc370.tsv", "w") as f:
        f.write("\t".join(head) + "\n")
        for r in cc:
            f.write("\t".join(r) + "\n")
    open(f"{RUN}/for-cc370.txt", "w").write("\n".join(r[0] for r in cc) + "\n")

    print(f"{len(rows)} rows -> module-table.tsv"
          + (f", {len(skip)} of them out of scope" if skip else ""))
    print(f"{len(cc)} of them are the assembler's business -> for-cc370.tsv / .txt")
    print("\nwho owns the difference:")
    for k, v in Counter(r[15] for r in rows).most_common():
        print(f"  {k:22s}: {v}")
    pair = Counter((r[1] and ("0" if r[1] == "0" else "8+"),
                    "0" if r[5] == "0000" else "8+" if r[5].isdigit() else "?")
                   for r in rows)
    print("\nas370 rc x IFOX rc:")
    for k, v in pair.most_common():
        print(f"  as370 {k[0]:>2s} / IFOX {k[1]:>2s}: {v}")
    print("\nwhat each row is a case of:")
    for k, v in Counter(r[14] for r in rows).most_common():
        print(f"  {k or '(assemblers agree)':22s}: {v}")
    print("\nthe most common message on each side:")
    for col, name in ((4, "as370"), (8, "IFOX00")):
        c = Counter(x for r in rows for x in r[col].split(" | ") if x)
        for k, v in c.most_common(6):
            print(f"  {name:7s} {v:5d}  {k[:70]}")


if __name__ == "__main__":
    main()
