#!/usr/bin/env python3
"""Fill the object's bytes into gaps the source leaves uninitialised, Dave's way.

Mike chose this on 2026-09-12: where no rule in the module predicts the missing
bytes, they are transcribed from the object and marked `!!! SOURCE COMPARE FIX
!!!` in columns 46-71, which is where Dave Kreiss puts that marker. See
work/src-pending/README.md for what the choice costs and why it was made.

**The guard is the measurement, not the logic here.** A module is written to
src/ only when `cmplmd370` calls it identical afterwards; anything else is
reported and left alone. So a wrong offset-to-statement mapping cannot deposit a
wrong file -- it can only fail to produce identity.

**2026-09-13: that guard has a blind spot and it cost 99 bytes.** A transcribed
byte always makes the comparison succeed -- that is what transcription is. The
guard proves the byte was copied correctly; it can never prove IBM's source
contained it. `IKJEGMSG` took 100 marked lines out of the DLIB member and came
back identical, and against TK5's target member Dave's untouched source was ONE
byte away while the repair sat 99 away
([`../docs/two-baselines-as-a-control.md`](../docs/two-baselines-as-a-control.md)).

Two things follow and both are implemented here:

1. **The reference is the baseline the project chose** -- TK5's target library
   where the CSECT has one, the DLIB where it does not. `--base` overrides.
2. **Where IBM's two libraries disagree at the byte about to be written, that is
   reported and the module is NOT deposited without `--accept-split`.** A byte
   the two libraries disagree about is not a byte IBM's source contained, so
   writing it is a choice of baseline rather than a recovery, and it has to be
   made deliberately.

What it will touch, and nothing else:

  * a statement that emits NO bytes and reserves or aligns -- `DS CL1`, `DS X`,
    `DS 0F`, `DC 0H'0'`. Inserting a `DC X'..'` before it lands in the gap and
    the alignment absorbs the change, so section lengths do not move.
  * never a macro-generated statement (`+` in the listing): there is no source
    line to precede. IKJEHREN's gap sits inside a STAX expansion and is why
    this rule exists.
  * never a statement that emits bytes. Overwriting an instruction is a
    different act, and the one case examined -- IKJEFE16's dead PL/S epilogue --
    needed its reachability checked first. Not automated.

    fillgaps.py MODULE...           report and, where identical, deposit
    fillgaps.py --dry-run MODULE... report only
    fillgaps.py --base tk5 MODULE.. score against the DLIB, as before 09-13
    fillgaps.py --accept-split ...  deposit even where the baselines disagree
"""
import argparse, collections, glob, json, os, re, shutil, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from macpath import flags

ARCHIVE = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
BIN = os.path.join(ROOT, "work/src-states/bin/as370-main")
CM = os.path.join(ROOT, "work/src-states/bin/cmplmd370")
DLIB = os.path.join(ROOT, "work/measurements/dlib-bytes/tk5")
TMP = os.path.join(ROOT, "work/measurements/fillgaps")
STAMP = dict(ASMDATE="09/07/26", ASMTIME="12.00")
MARK = b"!!! SOURCE COMPARE FIX !!!"
ESD = re.compile(r"^(\S{1,8})\s+SD\s+([0-9A-F]{4})\s+([0-9A-F]{6})\s+([0-9A-F]{6})")
LST = re.compile(r"^([0-9A-F]{6})\s+((?:[0-9A-F]{2,8}[ ]+)*)(\d{1,6})([+ ])\s*(.*?)\s*$")
# Two kinds, and they need opposite treatment -- the control caught this by
# leaving IKJEFLLM at text=0 holes=0 and still not identical, which is a length
# change and nothing else.
#
#   RESERVE: `DS CL1`, `DS X`, `DS CL4` -- occupies bytes. The fix REPLACES the
#            statement with `DC X'..'` of the same width, so the length holds.
#   ALIGN:   `DS 0F`, `DC 0H'0'` -- occupies nothing. The fix is INSERTED before
#            it and the alignment absorbs it.
RESERVE = re.compile(r"^(?:\S+\s+)?DS\s+(?:C?L?\d+|X|[CH]L\d+)\s*(?:\s\S.*)?$")
ALIGN = re.compile(r"^(?:\S+\s+)?(?:DS\s+0[HFDX]|DC\s+0[HFD]'0')\s*(?:\s\S.*)?$")


def marked(body, seq):
    b = body.ljust(45) + MARK
    if len(b) > 72:
        return None
    return b.ljust(72) + seq


TGT = os.path.join(ROOT, "work/measurements/target-bytes/tk5")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")


def library_of(mod):
    for lib in sorted(os.listdir(DLIB)):
        if os.path.exists(os.path.join(DLIB, lib, mod + ".bin")):
            return lib
    return None


def target_members(mod):
    """[(label, path)] of IBM's bound modules holding this CSECT, from LMDXRF38."""
    p = os.path.join(GATE, "org-tgt.txt")
    if not os.path.exists(p):
        sys.exit(f"{p}: missing -- run tools/fetch_xref.py")
    out = []
    for line in open(p, encoding="latin-1"):
        f = line.split()
        if len(f) >= 5 and f[2] == "INCLUDE" and f[3] == mod:
            out.append((f"{f[0]}({f[1]})",
                        os.path.join(TGT, f[0], f[1] + ".bin")))
    return out


def clusters_of(d):
    """{(section, offset): (ref_bytes, in_hole)} out of a cmplmd370 verdict."""
    out = {}
    for s in (d or {}).get("sections") or []:
        for c in s.get("clusters") or []:
            out[(s["name"], c["offset"])] = (c["ref"], c["in_hole"])
    return out


def disagreements(dref, oref):
    """Offsets in a HOLE where IBM's two libraries want DIFFERENT bytes.

    Only offsets both verdicts report are comparable: an offset one library
    reports and the other does not means that library already matches the source
    there, which is a difference between the libraries but not a contradiction
    about what the source should say.

    **This refuses on ANY disagreement, and one attempt to narrow it was wrong.**

    The distinction that tempted the narrowing is real: a disagreement in
    uninitialised storage is link-time or buffer noise and no source contains it,
    while a disagreement in bytes a statement deliberately emitted is maintenance
    the DLIB never received -- `IKJTTRM0`'s `DC H'0'` against the target's
    `XL2'8930'`, `IKT0009C`'s `BE` against mask 13. Both of those were refused
    here and both were recovered by hand.

    **But that distinction does not belong in this function**, because
    `cmplmd370`'s `in_hole` does not mean what the narrowing needed it to mean.
    Alignment padding emitted by a `DC 0H'0'` is `text` -- a statement covers the
    range -- while being exactly as meaningless as a hole. `IKJEHREN` is the case
    that caught it: the byte at `0x23` is the pad of `BRID DC 0H'0'`, the DLIB
    holds `F0` and the target `80`, and under the narrowed rule this tool happily
    made it "identical" by writing the target's noise into the source. That is the
    `IKJEGMSG` mistake with a different offset.

    And the narrowing bought nothing, because **this tool only ever writes into a
    statement that emits NO bytes** -- see `plan()`. Every offset it would fill is
    padding or reservation by construction, so a disagreement at one of them is
    noise by construction. A disagreement in real emitted text is a case `plan()`
    declines anyway, with `emits bytes`, and it is hand work.

    So: refuse on any disagreement, and let the `emits bytes` path carry the
    maintenance cases to a human.
    """
    a, b = clusters_of(dref), clusters_of(oref)
    return sorted(k for k in set(a) & set(b) if a[k][0] != b[k][0])


def assemble(src, mod, tag):
    os.makedirs(TMP, exist_ok=True)
    lst = os.path.join(TMP, f"{mod}.{tag}.lst")
    obj = os.path.join(TMP, f"{mod}.{tag}.obj")
    subprocess.run([BIN] + flags() + ["-a=" + lst, "-o", obj, src],
                   capture_output=True, env=dict(os.environ, **STAMP))
    return (lst, obj) if os.path.exists(obj) else (lst, None)


def verdict(obj, mod, lib):
    """Against the DLIB member, which is one element and needs no --csect."""
    q = subprocess.run([CM, "--json", obj, os.path.join(DLIB, lib, mod + ".bin")],
                       capture_output=True, text=True)
    try:
        return json.loads(q.stdout)
    except json.JSONDecodeError:
        return None


def verdict_tgt(obj, mod):
    """(label, verdict) against IBM's target member, restricted to this CSECT.

    A CSECT can be bound into several load modules; the one that differs least is
    the one worth working on, which is the rule baseline_gate.py uses.
    """
    best = None
    for label, path in target_members(mod):
        if not os.path.exists(path):
            continue
        q = subprocess.run([CM, "--json", "--csect", mod, obj, path],
                           capture_output=True, text=True)
        if not q.stdout.strip():
            continue
        try:
            d = json.loads(q.stdout)
        except json.JSONDecodeError:
            continue
        if d.get("identical"):
            return label, d
        n = sum((s.get("diff_in_text") or 0) + (s.get("diff_in_holes") or 0)
                for s in d.get("sections") or [])
        if best is None or n < best[2]:
            best = (label, d, n)
    return (best[0], best[1]) if best else (None, None)


def plan(lst, d, base):
    """-> (list of (listing_text, occurrence_index, hexbytes), list of skips)"""
    rows = []
    for line in open(lst, encoding="latin-1", errors="replace"):
        m = LST.match(line.rstrip("\n"))
        if m:
            rows.append(dict(addr=int(m.group(1), 16), bytes=m.group(2).strip(),
                             gen=m.group(4) == "+", text=m.group(5)))
    fixes, skips = [], []
    for s in d.get("sections") or []:
        b = base.get(s["name"])
        if b is None:
            skips.append((s["name"], "no ESD base"))
            continue
        for c in s.get("clusters") or []:
            absu = b + c["offset"]
            # The greatest address at or below the cluster, and among several
            # statements sharing it, a usable filler in preference to whatever
            # happened to come last in the listing. Taking rows[-1] in listing
            # order put IKJEGSTA's owner on an SDWA macro expansion.
            cands = [r for r in rows if r["addr"] <= absu]
            if not cands:
                skips.append((f"0x{absu:06x}", "no owning statement"))
                continue
            top = max(r["addr"] for r in cands)
            at = [r for r in cands if r["addr"] == top]
            # An ALIGN statement may carry pad bytes in the listing -- as370
            # prints `00` on the `DC 0H'0'` line that pads an odd address -- and
            # that pad is exactly what gets replaced, so pad bytes must not
            # disqualify it. A statement whose bytes are REAL is a text
            # difference and belongs to a hand diagnosis: IKJEFE16's dead
            # epilogue sat at the same address as a `DS 0H`, and preferring the
            # DS inserted two bytes and grew the section.
            align = [r for r in at if not r["gen"] and ALIGN.match(r["text"])]
            reserve = [r for r in at if not r["gen"] and not r["bytes"]
                       and RESERVE.match(r["text"])]
            real = [r for r in at if r["bytes"] and not ALIGN.match(r["text"])]
            if real:
                skips.append((f"0x{absu:06x}", f"emits bytes: {real[-1]['text'][:34]}"))
                continue
            if any(r["gen"] for r in at) and not (align or reserve):
                skips.append((f"0x{absu:06x}",
                              f"macro-generated: {at[-1]['text'][:34]}"))
                continue
            o = (reserve or align or [None])[0]
            if o is None:
                skips.append((f"0x{absu:06x}", f"not a filler: {at[-1]['text'][:34]}"))
                continue
            mode = ("replace" if RESERVE.match(o["text"])
                    else "insert" if ALIGN.match(o["text"]) else None)
            if mode is None:
                skips.append((f"0x{absu:06x}", f"not a filler: {o['text'][:34]}"))
                continue
            same = [r for r in rows if r["text"] == o["text"] and not r["gen"]]
            same.sort(key=lambda r: r["addr"])
            fixes.append((o["text"], same.index(o), c["ref"].upper(), mode))
    return fixes, skips


def apply(src, out, fixes):
    lines = open(src, "rb").read().split(b"\r\n")
    want = {}
    for text, occ, val, mode in fixes:
        want.setdefault(text, {})[occ] = (val, mode)
    seen, res = {}, []
    for l in lines:
        body = l[:72]
        key = body.rstrip().decode("latin-1")
        hit = None
        for text, byocc in want.items():
            if key == text or key.endswith(text):
                n = seen.get(text, 0)
                seen[text] = n + 1
                if n in byocc:
                    hit = byocc[n]
                break
        if hit:
            val, mode = hit
            m = marked(b"         DC    X'%s'" % val.encode(), l[72:80])
            if m is None:
                return None
            res.append(m)
            if mode == "replace":
                continue          # the reserving statement is gone
        res.append(l)
    if any(x and len(x) != 80 for x in res):
        return None
    open(out, "wb").write(b"\r\n".join(res))
    return len(res)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("modules", nargs="+")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--base", default="tgt", choices=("tgt", "tk5"),
                    help="tgt (default) is the baseline chosen 2026-09-13: the "
                         "target library where the CSECT has one, the DLIB where "
                         "it does not. tk5 is the DLIB alone, as before that date.")
    ap.add_argument("--accept-split", action="store_true",
                    help="deposit even where IBM's two libraries want different "
                         "bytes at the offset being written -- a baseline choice, "
                         "not a recovery")
    a = ap.parse_args()
    ok = bad = split = 0
    for mod in a.modules:
        lib = library_of(mod)
        if lib is None:
            print(f"{mod:10s} SKIP   no TK5 member"); bad += 1; continue
        src = os.path.join(ARCHIVE, mod + ".ASM")
        lst, obj = assemble(src, mod, "before")
        if obj is None:
            print(f"{mod:10s} SKIP   did not assemble"); bad += 1; continue
        base = {}
        for line in open(lst, encoding="latin-1", errors="replace"):
            m = ESD.match(line)
            if m:
                base[m.group(1)] = int(m.group(3), 16)
        ddlib = verdict(obj, mod, lib)
        tlabel, dtgt = verdict_tgt(obj, mod) if a.base == "tgt" else (None, None)
        # The chosen baseline, and the reason the fallback is explicit: 839 modules
        # have no CSECT of that name in any target library at all, and for those
        # the DLIB is the only object there is.
        if a.base == "tgt" and dtgt is not None:
            d, where = dtgt, tlabel
        else:
            d, where = ddlib, f"DLIB {lib}"
            if a.base == "tgt":
                where += " (no target counterpart)"
        if d is None:
            print(f"{mod:10s} SKIP   no verdict"); bad += 1; continue
        if d.get("identical"):
            print(f"{mod:10s} already identical against {where}"); continue
        # Do IBM's two libraries agree about the bytes we are about to write?
        bad_offs = disagreements(ddlib, dtgt) if (a.base == "tgt" and dtgt) else []
        if bad_offs and not a.accept_split:
            print(f"{mod:10s} SPLIT  IBM's two libraries want different bytes at "
                  f"{len(bad_offs)} offset(s) -- e.g. "
                  f"{bad_offs[0][0]}+0x{bad_offs[0][1]:x}; not a recovery. "
                  f"--accept-split to write the {where} value anyway")
            split += 1
            continue
        fixes, skips = plan(lst, d, base)
        if not fixes:
            print(f"{mod:10s} SKIP   nothing fillable" +
                  (f" -- {skips[0][1]}" if skips else "")); bad += 1; continue
        out = os.path.join(TMP, mod + ".ASM")
        if apply(src, out, fixes) is None:
            print(f"{mod:10s} SKIP   could not write 80-column records"); bad += 1; continue
        _, obj2 = assemble(out, mod, "after")
        if not obj2:
            d2 = None
        elif a.base == "tgt" and dtgt is not None:
            _, d2 = verdict_tgt(obj2, mod)
        else:
            d2 = verdict(obj2, mod, lib)
        if d2 and d2.get("identical"):
            dest = os.path.join(ROOT, "src", lib, mod + ".ASM")
            if not a.dry_run:
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                shutil.copy(out, dest)
            print(f"{mod:10s} IDENTICAL against {where}  {len(fixes)} line(s)"
                  + ("  [dry run]" if a.dry_run else f"  -> src/{lib}/"))
            ok += 1
        else:
            t = sum(s.get("diff_in_text") or 0 for s in (d2 or {}).get("sections") or [])
            h = sum(s.get("diff_in_holes") or 0 for s in (d2 or {}).get("sections") or [])
            print(f"{mod:10s} NO     {len(fixes)} fix(es) left text={t} holes={h}"
                  + (f"; skipped: {skips[0][1]}" if skips else ""))
            bad += 1
    print(f"\n{ok} identical, {bad} not"
          + (f", {split} where IBM's two libraries disagree at the byte" if split else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
