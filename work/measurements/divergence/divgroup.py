#!/usr/bin/env python3
"""Die 1.878 Divergenzstellen nach URSACHE gruppieren, nicht nach Ort.

Der Ankerbericht druckt an jeder Fehlstelle beide Seiten:
    * ANCHOR FAILED 000054 module 4510B04E derived 16000A86
Gestern habe ich nur den Offset behalten. Die Bytes sind das Material: gruppiert
nach (unsere Bytes, IBMs Bytes) zeigt eine Zelle mit mehreren Modulen eine
FAMILIE -- eine Ursache, die mehr als ein Modul bewegt. Genau so wurden IGGCP14
(neun Module, ein falsches CCW-Zaehlfeld) und die x/|-Klasse (neun Module, ein
Codepage-Zeichen) gefunden, damals ueber 47 Module. Dies ist dieselbe Frage ueber
1.878.
"""
import subprocess, sys, os, re, glob, collections, concurrent.futures
sys.path.insert(0,"tools"); from macpath import dirs
D,AS,OUT = sys.argv[1], sys.argv[2], sys.argv[3]
os.makedirs(OUT, exist_ok=True)
INC=[]
for d in dirs(): INC += ["-I", d]
FAIL=re.compile(r"ANCHOR FAILED\s+([0-9A-F]+)\s+module\s+(\S+)\s+derived\s+(\S+)")
rows=[l.rstrip("\n").split("\t") for l in open("work/measurements/baseline-gate/overlay-vs-both.tsv",encoding="utf-8")]
h={k:i for i,k in enumerate(rows[0])}
jobs=[]
for r in rows[1:]:
    if len(r)<len(rows[0]): continue
    m=r[h["module"]]; t=r[h["tgt_c"]]; d=r[h["dlib_c"]]
    if t=="len-differs" and r[h["tgt_lmod"]] not in ("-",""):
        ref=f"work/measurements/target-bytes/tk5/{r[h['tgt_lib']]}/{r[h['tgt_lmod']]}.bin"
    elif t=="not-in-target" and d=="len-differs":
        g=glob.glob(f"work/measurements/dlib-bytes/tk5/*/{m}.bin"); ref=g[0] if g else None
    else: continue
    src=f"work/src-states/overlay/{m}.ASM"
    if ref and os.path.exists(ref) and os.path.exists(src): jobs.append((m,src,ref))
def one(j):
    m,src,ref=j
    hf=f"{OUT}/{m}.h"
    try:
        p=subprocess.run([D,"--derive-hints",src,"--as370",AS]+INC+["-o",hf],
                         capture_output=True,text=True,timeout=180)
        if p.returncode!=0 or not os.path.exists(hf): return (m,[])
        q=subprocess.run([D,"--csect",m,"--hints",hf,"--anchors=report",ref],
                         capture_output=True,text=True,timeout=180)
        out=[]
        for l in q.stdout.splitlines():
            g=FAIL.search(l)
            if g: out.append((g.group(1), g.group(2), g.group(3)))
        return (m,out)
    except subprocess.TimeoutExpired:
        return (m,[])
    finally:
        if os.path.exists(hf): os.remove(hf)
print(f"{len(jobs)} Module", flush=True)
pairs=collections.Counter(); mods=collections.defaultdict(set); n=0
with open(os.path.join(OUT,"divergences.tsv"),"w") as fh:
    fh.write("module\toffset\tmodule_bytes\tderived_bytes\n")
    with concurrent.futures.ThreadPoolExecutor(8) as ex:
        for i,(m,res) in enumerate(ex.map(one, jobs)):
            for off,mb,db in res:
                fh.write(f"{m}\t0x{off}\t{mb}\t{db}\n"); n+=1
                pairs[(db,mb)]+=1; mods[(db,mb)].add(m)
            if (i+1)%300==0: print(f"  ... {i+1}", flush=True)
print(f"\n{n} Divergenzstellen aus {len(jobs)} Modulen")
print("\nZellen (unsere Bytes -> IBMs Bytes), nach DISTINKTEN MODULEN:")
top=sorted(mods.items(), key=lambda kv: -len(kv[1]))[:25]
for (db,mb),ms in top:
    print(f"  {len(ms):5d} Module  {pairs[(db,mb)]:6d}x   unser {db[:20]:22s} -> IBM {mb[:20]}")
