#!/usr/bin/env python3
"""Ankerbericht ueber die laengenabweichende Population.
Pro Modul: Hints aus UNSERER Quelle ableiten, auf IBMs Objekt anwenden,
den ERSTEN fehlgeschlagenen Anker festhalten -- das ist der Offset, ab dem
unsere Quelle und IBMs Objekt auseinandergehen."""
import subprocess, sys, os, glob, re, concurrent.futures
sys.path.insert(0,"tools"); from macpath import dirs
D,AS,OUT = sys.argv[1], sys.argv[2], sys.argv[3]
os.makedirs(OUT, exist_ok=True)
INC=[]
for d in dirs(): INC += ["-I", d]
rows=[l.rstrip("\n").split("\t") for l in open("work/measurements/baseline-gate/overlay-vs-both.tsv",encoding="utf-8")]
h={k:i for i,k in enumerate(rows[0])}
jobs=[]
for r in rows[1:]:
    if len(r)<len(rows[0]): continue
    m=r[h["module"]]
    if r[h["tgt_c"]]=="len-differs" and r[h["tgt_lmod"]] not in ("-",""):
        ref=f"work/measurements/target-bytes/tk5/{r[h['tgt_lib']]}/{r[h['tgt_lmod']]}.bin"
    elif r[h["tgt_c"]]=="not-in-target" and r[h["dlib_c"]]=="len-differs":
        g=glob.glob(f"work/measurements/dlib-bytes/tk5/*/{m}.bin"); ref=g[0] if g else None
    else: continue
    src=f"work/src-states/overlay/{m}.ASM"
    if ref and os.path.exists(ref) and os.path.exists(src): jobs.append((m,src,ref))
FAIL=re.compile(r"ANCHOR FAILED\s+([0-9A-F]+)\s+module\s+(\S+)\s+derived\s+(\S+)")
def one(j):
    m,src,ref=j
    hf=f"{OUT}/{m}.hints"
    try:
        p=subprocess.run([D,"--derive-hints",src,"--as370",AS]+INC+["-o",hf],
                         capture_output=True,text=True,timeout=120)
        if p.returncode!=0 or not os.path.exists(hf): return (m,"derive-fail",None,0)
        q=subprocess.run([D,"--csect",m,"--hints",hf,"--anchors=report",ref],
                         capture_output=True,text=True,timeout=120)
        fails=[FAIL.search(l) for l in q.stdout.splitlines()]
        fails=[x for x in fails if x]
        if q.returncode not in (0,1): return (m,f"apply-rc{q.returncode}",None,0)
        if not fails: return (m,"clean",None,0)
        return (m,"diverges",int(fails[0].group(1),16),len(fails))
    except subprocess.TimeoutExpired:
        return (m,"timeout",None,0)
    finally:
        if os.path.exists(hf): os.remove(hf)
print(f"{len(jobs)} Module", flush=True)
res=[]
with concurrent.futures.ThreadPoolExecutor(8) as ex:
    for i,r in enumerate(ex.map(one,jobs)):
        res.append(r)
        if (i+1)%300==0: print(f"  ... {i+1}", flush=True)
with open(os.path.join(OUT,"anchors.tsv"),"w") as fh:
    fh.write("module\tstatus\tfirst_anchor\tn_failed\n")
    for m,s,o,n in res:
        fh.write(f"{m}\t{s}\t{'' if o is None else '0x%X'%o}\t{n}\n")
import collections
print(dict(collections.Counter(s for _,s,_,_ in res)))
