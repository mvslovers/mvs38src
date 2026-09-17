#!/usr/bin/env python3
"""How much of a module's KNOWN code do the roots touch, where we have the source?

cc370#383 makes `dasm370` traverse from code roots and emit as `DC` whatever
nothing reaches. The pass is byte-safe by construction -- `DC` reproduces its own
bytes -- so every instrument this project runs reports success whichever way it
goes, and the acceptance has to be a **rule fixed in advance**, not an outcome.

The rule proposed here was *"the entry point, every `LD`/`LR` address in the CESD,
every address constant whose relocation resolves into this section"*. The cc370
session's answer contained two things this measures:

- **the entry point is not in a bound member at all.** Two links differing in
  nothing but the entry point produce byte-identical members; the difference is
  two bytes of the PDS directory (`PDS2EP0`/`PDS2EPA`), and our corpus is extracted
  member content. It survives on a deck's END card and nowhere else. So the rule
  is asymmetric and has to say so.
- **"how many modules have a root" is the wrong question.** The right one is what
  fraction of a module's code the roots reach, and it can only be asked where
  there is real source to say which bytes are code. That is the 30 control CSECTs.

This measures the **static** half of it, which needs no traversal and therefore
does not presuppose the pass being built: the code bytes come from the assembly
listing, the roots from the deck, and a contiguous run of code containing no root
is a run that can only be reached by a branch from somewhere else.

    rootreach.py [--jobs N]

**It is a FLOOR and says so.** The traversal will reach more than this -- that is
what it is for. What the floor answers is whether a narrow root rule leaves most
of a module's code to be found by branch-following (a lot rests on the traversal)
or only a little (the rule carries the weight). Neither is a verdict on #383; both
are a number the rule can be fixed against.
"""
import argparse, collections, os, re, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
sys.path.insert(0, HERE)
from macpath import flags as macflags                     # noqa: E402
from asmparams import params                              # noqa: E402
from seclocate import deck_text                           # noqa: E402

AS = os.path.join(ROOT, "work/src-states/bin/as370-main")
SRC = os.path.join(ROOT, "work/src-states/overlay")
DATA_OPS = {"DC", "DS", "CSECT", "DSECT", "START", "END", "EQU", "ORG", "LTORG",
            "USING", "DROP", "ENTRY", "EXTRN", "TITLE", "SPACE", "EJECT", "CNOP"}


def known_code(mod, csect=None):
    """The offsets the listing shows an INSTRUCTION at, IN ONE SECTION.

    ⚠️ The first version of this did not track the section, and a control caught
    it before the figure was quoted: `IEHPROG1`'s source holds several CSECTs, so
    it returned 4,114 code bytes for an 84-byte section -- 4,096 of them belonging
    to other sections at offsets that collide with ours. A section-blind listing
    walk does not fail, it answers about the wrong bytes.

    Columns are fixed in an as370 listing: location 0-5, object code 7-15, and
    the card image from **40**. Taken positionally rather than by a regex, and the
    off-by-one is worth the sentence: at 41 the operation still parses on every
    unnamed card, so instructions came out right and only the NAME field lost its
    first character -- which is the field the section is tracked by. Every module
    then returned zero code bytes, loudly. One column further and it would have
    returned a section's worth of somebody else's code, quietly.
    """
    argv, env = params(mod)
    lst = os.path.join("/tmp", f"rr-{mod}.lst")
    try:
        subprocess.run(["perl", "-e", "alarm 300; exec @ARGV", AS, "-ae", "-a=" + lst]
                       + argv + macflags() + ["-o", "/dev/null",
                                              os.path.join(SRC, mod + ".ASM")],
                       capture_output=True, env=dict(os.environ, **env))
        if not os.path.exists(lst):
            return None
        code, data, seen, cur = set(), set(), 0, None
        want = csect or mod
        for line in open(lst, encoding="utf-8", errors="replace"):
            if len(line) < 41 or not re.match(r"^[0-9A-F]{6} ", line):
                continue
            card = line[40:].rstrip("\n")
            f = card.split()
            if not f:
                continue
            named = card[:1].strip() != ""
            op = (f[1] if named and len(f) > 1 else f[0]).upper()
            # The section is tracked BEFORE the object-code test, because a
            # `CSECT` card carries no object code -- testing it first skipped
            # every section header and left `cur` at None for ever.
            if op in ("CSECT", "DSECT", "START", "COM"):
                cur = f[0] if named else cur
                continue
            obj = line[7:16].replace(" ", "")
            if not obj or len(obj) % 2:
                continue
            if cur != want:
                continue
            a0 = int(line[:6], 16)
            if op in DATA_OPS:
                for k in range(len(obj) // 2):
                    data.add(a0 + k)
                continue
            a = int(line[:6], 16)
            for k in range(len(obj) // 2):
                code.add(a + k)
            seen += 1
        return (code, data) if seen else None
    finally:
        if os.path.exists(lst):
            os.remove(lst)


def cards(p):
    d = open(p, "rb").read()
    return [d[i:i + 80] for i in range(0, len(d), 80)]


def roots(deck, csect):
    """The three kinds, kept apart, because the rule has to name them separately."""
    esdid, owners, ld, txt = None, {}, [], {}
    end_entry = None
    cur = None
    for c in cards(deck):
        k = c[1:4]
        if k == b"\xc5\xe2\xc4":                                   # ESD
            n = int.from_bytes(c[10:12], "big")
            cur = int.from_bytes(c[14:16], "big")
            for i in range(n // 16):
                o = 16 + i * 16
                name = c[o:o + 8].decode("cp037").rstrip()
                typ = c[o + 8]
                adr = int.from_bytes(c[o + 9:o + 12], "big")
                if typ == 1:                                       # LD
                    ld.append((name, adr, int.from_bytes(c[o + 13:o + 16], "big")))
                    continue
                owners[cur] = name
                if typ == 0 and name == csect:
                    esdid = cur
                cur += 1
        elif k == b"\xe3\xe7\xe3":                                 # TXT
            a = int.from_bytes(c[5:8], "big")
            n = int.from_bytes(c[10:12], "big")
            txt[a] = c[16:16 + n]
        elif k == b"\xc5\xd5\xc4":                                 # END
            v = int.from_bytes(c[5:8], "big")
            if c[4:5] != b"\x40" or v:
                end_entry = v
    if esdid is None:
        return None
    buf = bytearray(max((a + len(b) for a, b in txt.items()), default=0))
    for a, b in txt.items():
        buf[a:a + len(b)] = b
    out = {"ld": set(), "adcon": set(), "end": set()}
    for name, adr, own in ld:
        if own == esdid:
            out["ld"].add(adr)
    for c in cards(deck):
        if c[1:4] != b"\xd9\xd3\xc4":                              # RLD
            continue
        n = int.from_bytes(c[10:12], "big")
        off, end, cont = 16, 16 + n, False
        R = P = None
        while off + 4 <= end:
            if not cont:
                if off + 8 > end:
                    break
                R = int.from_bytes(c[off:off + 2], "big")
                P = int.from_bytes(c[off + 2:off + 4], "big")
                off += 4
            fl = c[off]
            ad = int.from_bytes(c[off + 1:off + 4], "big")
            off += 4
            cont = bool(fl & 1)
            ln = ((fl >> 2) & 3) + 1
            if R == esdid and P == esdid and ln == 4 and ad + 4 <= len(buf):
                out["adcon"].add(int.from_bytes(buf[ad:ad + 4], "big") & 0xFFFFFF)
    if end_entry is not None:
        out["end"].add(end_entry)
    return out


def runs(code):
    """Contiguous runs of known code: [(start, length)]."""
    out, cur = [], None
    for a in sorted(code):
        if cur and cur[0] + cur[1] == a:
            cur = (cur[0], cur[1] + 1)
        else:
            if cur:
                out.append(cur)
            cur = (a, 1)
    if cur:
        out.append(cur)
    return out


def one(job):
    csect, deck, which = job
    kc = known_code(csect, csect)
    if kc is None:
        return csect, None
    code, data = kc
    rt = roots(deck, csect)
    if rt is None:
        return csect, None
    # The SD entry is the section origin, and cc370#383 lists it FIRST among the
    # code roots. Both of this session's tools omitted it, which is why they could
    # report a section as rootless at all: with SD every section has a root at 0.
    if which == "deliverable":
        allr = {0} | rt["ld"] | rt["end"]
    else:
        allr = rt["ld"] | rt["adcon"] | rt["end"]
    rs = runs(code)
    hit = [r for r in rs if any(r[0] <= x < r[0] + r[1] for x in allr)]
    cov = sum(r[1] for r in hit)
    tot = sum(r[1] for r in rs)
    # `covered` is the bytes the listing gives OBJECT CODE for. It does not reach
    # the section length and is not meant to: `DS` and alignment reserve bytes
    # without emitting any, so the remainder is data by construction. It is kept
    # because a listing walk that silently dropped INSTRUCTIONS would show up here
    # as a coverage collapse.
    #
    # The control that actually validates the code set is one-off and independent:
    # our set against `dasm370`'s own classification of the same deck, over the
    # same 30 -- 66,689 of 68,192 comparable bytes agree, 97.8 %. A 2 % doubt in
    # the denominator cannot move a 5 % answer.
    txt = deck_text(deck, csect)
    seclen = len(txt) if txt else 0
    covered = len([a for a in (code | data) if a < seclen])
    return csect, dict(code=tot, runs=len(rs), runs_with_root=len(hit),
                       seclen=seclen, covered=covered,
                       bytes_in_rooted_runs=cov,
                       ld=len(rt["ld"]), adcon=len(rt["adcon"]), end=len(rt["end"]))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--jobs", type=int, default=6)
    ap.add_argument("--set", default="deliverable",
                    choices=("deliverable", "proposed"),
                    help="deliverable: SD + owned LD/LR + END on a deck, NO adcons "
                         "-- cc370#383's own first bullet says an RLD target is a "
                         "LABEL root and not a code root. proposed: the rule this "
                         "session proposed before reading the issue, LD + adcon + "
                         "END, kept so the two can be compared rather than one "
                         "quietly replacing the other.")
    ap.add_argument("--out", default=os.path.join(
        ROOT, "work/measurements/dasm370-rootreach.tsv"))
    a = ap.parse_args()
    rows = [l.rstrip("\n").split("\t") for l in
            open(os.path.join(ROOT, "work/measurements/dasm370-decoder-control.tsv"),
                 encoding="utf-8")]
    h = {k: i for i, k in enumerate(rows[0])}
    jobs = [(r[h["csect"]], os.path.join(ROOT, r[h["our_deck"]]), a.set)
            for r in rows[1:] if len(r) >= len(rows[0])]
    print(f"Wurzelmenge: {a.set}")
    res = []
    with ThreadPoolExecutor(a.jobs) as ex:
        res = list(ex.map(one, jobs))
    cols = ["code", "runs", "runs_with_root", "bytes_in_rooted_runs", "seclen",
            "covered", "ld", "adcon", "end"]
    with open(a.out, "w") as fh:
        fh.write("csect\t" + "\t".join(cols) + "\n")
        for cs, d in sorted(res):
            fh.write(cs + "\t" + "\t".join(str(d[c]) if d else "" for c in cols) + "\n")
    ok = [(cs, d) for cs, d in res if d]
    print(f"{len(ok)} von {len(jobs)} gemessen\n")
    sl = sum(d["seclen"] for _, d in ok)
    cv = sum(d["covered"] for _, d in ok)
    print(f"  Bytes mit Objektcode im Listing: {cv:,} von {sl:,} "
          f"Sektionsbytes = {cv/sl:.1%}  (der Rest ist DS und Ausrichtung)\n")
    tc = sum(d["code"] for _, d in ok)
    tr = sum(d["runs"] for _, d in ok)
    th = sum(d["runs_with_root"] for _, d in ok)
    tb = sum(d["bytes_in_rooted_runs"] for _, d in ok)
    print(f"  bekannte Codebytes                {tc:9,}")
    print(f"  zusammenhaengende Codelaeufe      {tr:9,}")
    print(f"  davon mit mindestens einer Wurzel {th:9,}  = {th/tr:5.1%}")
    print(f"  Codebytes in bewurzelten Laeufen  {tb:9,}  = {tb/tc:5.1%}")
    ld = sum(d["ld"] for _, d in ok)
    ac = sum(d["adcon"] for _, d in ok)
    en = sum(d["end"] for _, d in ok)
    if a.set == "deliverable":
        print(f"\n  Wurzeln: SD {len(ok)}   LD {ld}   END {en}"
              f"   (Adcon {ac} NICHT gezaehlt -- Labelwurzeln, nicht Codewurzeln)")
        print(f"\n  Module ohne jede Wurzel: 0 von {len(ok)} "
              f"-- mit SD hat jede Sektion eine Wurzel bei Offset 0")
    else:
        print(f"\n  Wurzeln: LD {ld}   Adcon {ac}   END {en}   (ohne SD)")
        print(f"\n  Module ohne jede Wurzel: "
              f"{sum(1 for _, d in ok if d['ld'] + d['adcon'] + d['end'] == 0)}")
    print(f"-> {a.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
