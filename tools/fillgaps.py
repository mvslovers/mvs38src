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
"""
import argparse, glob, json, os, re, shutil, subprocess, sys

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


def library_of(mod):
    for lib in sorted(os.listdir(DLIB)):
        if os.path.exists(os.path.join(DLIB, lib, mod + ".bin")):
            return lib
    return None


def assemble(src, mod, tag):
    os.makedirs(TMP, exist_ok=True)
    lst = os.path.join(TMP, f"{mod}.{tag}.lst")
    obj = os.path.join(TMP, f"{mod}.{tag}.obj")
    subprocess.run([BIN] + flags() + ["-a=" + lst, "-o", obj, src],
                   capture_output=True, env=dict(os.environ, **STAMP))
    return (lst, obj) if os.path.exists(obj) else (lst, None)


def verdict(obj, mod, lib):
    q = subprocess.run([CM, "--json", obj, os.path.join(DLIB, lib, mod + ".bin")],
                       capture_output=True, text=True)
    try:
        return json.loads(q.stdout)
    except json.JSONDecodeError:
        return None


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
    a = ap.parse_args()
    ok = bad = 0
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
        d = verdict(obj, mod, lib)
        if d is None:
            print(f"{mod:10s} SKIP   no verdict"); bad += 1; continue
        if d.get("identical"):
            print(f"{mod:10s} already identical"); continue
        fixes, skips = plan(lst, d, base)
        if not fixes:
            print(f"{mod:10s} SKIP   nothing fillable" +
                  (f" -- {skips[0][1]}" if skips else "")); bad += 1; continue
        out = os.path.join(TMP, mod + ".ASM")
        if apply(src, out, fixes) is None:
            print(f"{mod:10s} SKIP   could not write 80-column records"); bad += 1; continue
        _, obj2 = assemble(out, mod, "after")
        d2 = verdict(obj2, mod, lib) if obj2 else None
        if d2 and d2.get("identical"):
            dest = os.path.join(ROOT, "src", lib, mod + ".ASM")
            if not a.dry_run:
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                shutil.copy(out, dest)
            print(f"{mod:10s} IDENTICAL  {len(fixes)} line(s)"
                  + ("  [dry run]" if a.dry_run else f"  -> src/{lib}/"))
            ok += 1
        else:
            t = sum(s.get("diff_in_text") or 0 for s in (d2 or {}).get("sections") or [])
            h = sum(s.get("diff_in_holes") or 0 for s in (d2 or {}).get("sections") or [])
            print(f"{mod:10s} NO     {len(fixes)} fix(es) left text={t} holes={h}"
                  + (f"; skipped: {skips[0][1]}" if skips else ""))
            bad += 1
    print(f"\n{ok} identical, {bad} not")
    return 0


if __name__ == "__main__":
    sys.exit(main())
