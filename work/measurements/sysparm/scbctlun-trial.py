#!/usr/bin/env python3
"""SCBCTLUN = X'04' or X'01'? Measure the whole population both ways, as sets.

The SCHEDULE rule: when a macro changes, compare the identical SETS before and
after, never their sizes. SCHEDULE was +3 and -10 and the net alone would have
said "wrong" without saying why.
"""
import collections, json, os, subprocess, sys, concurrent.futures
sys.path.insert(0, "tools")
from macpath import flags
import seclocate as SL
SP = "/private/tmp/claude-501/-Users-mike-repos-mvs-mvs38src/5b5bad03-54bd-4be0-8036-9cd5a73a5e47/scratchpad"
BIN = "work/src-states/bin/as370-main"
CM = "work/src-states/bin/cmplmd370"
TMP = SP + "/scbtrial"; os.makedirs(TMP, exist_ok=True)

sysparm = {}
for l in open("work/measurements/baseline-gate/sysparm.tsv"):
    f = l.rstrip("\n").split("\t")
    if len(f) >= 2 and f[0] != "module":
        sysparm[f[0]] = f[1]

mods = sorted(f[:-4] for f in os.listdir("work/src-states/overlay")
              if f.endswith(".ASM") and b"SCBCTLUN" in open("work/src-states/overlay/" + f, "rb").read())

tx = collections.defaultdict(list)
for line in open(os.path.join(SL.GATE, "org-tgt.txt"), encoding="latin-1"):
    f = line.split()
    if len(f) >= 5 and f[2] == "INCLUDE":
        tx[f[3]].append((f[0], f[1]))
dl = {}
for lib in sorted(os.listdir(SL.DLIB)):
    d = os.path.join(SL.DLIB, lib)
    if os.path.isdir(d):
        for fn in os.listdir(d):
            if fn.endswith(".bin"):
                dl.setdefault(fn[:-4], os.path.join(d, fn))

# The 136 are NOT in sysparm.tsv -- their value is derived and unproven -- so a
# trial that only reads the table assembles them without one and they come out
# length-differing, which looks like "the macro change did nothing".
import sysparm_sweep as SW
from decks import CONTROL
_rest = [l.rstrip("\n").split("\t") for l in open("work/measurements/baseline-gate/sysparm-rest.tsv")][1:]
for _m, _o in _rest:
    if _o != "tried, still differs" or _m in sysparm:
        continue
    _r = None
    for _l, _mm in tx.get(_m, []):
        _p = os.path.join(SL.TGT, _l, _mm + ".bin")
        if os.path.exists(_p):
            _r = _p; break
    if _r is None and _m in dl:
        _r = dl[_m]
    if _r is None:
        continue
    _c = SW.candidates(os.path.join(CONTROL, _m + ".obj"), _r, _m)
    if _c:
        sysparm[_m] = _c[0][0] + _c[0][1]


def refs(m):
    r = [os.path.join(SL.TGT, l, mm + ".bin") for l, mm in tx.get(m, [])]
    r = [x for x in r if os.path.exists(x)]
    return r or ([dl[m]] if m in dl else [])

def build(m, trial):
    obj = os.path.join(TMP, f"{m}.{'01' if trial else '04'}.obj")
    cmd = [BIN] + ([f"--sysparm={sysparm[m]}"] if m in sysparm else [])
    if trial:
        cmd += ["-I", SP + "/tscbd01"]
    cmd += flags() + ["-o", obj, f"work/src-states/overlay/{m}.ASM"]
    subprocess.run(cmd, capture_output=True, env=dict(os.environ, ASMDATE="09/07/26", ASMTIME="12.00"))
    return obj if os.path.exists(obj) else None

def ident(obj, m):
    for r in refs(m):
        q = subprocess.run([CM, "--json", "--csect", m, obj, r], capture_output=True, text=True)
        if not q.stdout.strip():
            continue
        try:
            d = json.loads(q.stdout)
        except json.JSONDecodeError:
            continue
        s = next((x for x in (d.get("sections") or []) if x.get("name") == m), None)
        if s and s.get("identical"):
            return True
    return False

def one(m):
    a = build(m, False); b = build(m, True)
    return m, (ident(a, m) if a else False), (ident(b, m) if b else False)

with concurrent.futures.ThreadPoolExecutor(6) as ex:
    res = list(ex.map(one, mods))
base = {m for m, a, b in res if a}
tri  = {m for m, a, b in res if b}
print(f"{len(mods)} modules reference SCBCTLUN")
print(f"  identical with X'04' (today): {len(base)}")
print(f"  identical with X'01' (trial): {len(tri)}")
print(f"  GAINED {sorted(tri-base)}")
print(f"  LOST   {sorted(base-tri)}")
