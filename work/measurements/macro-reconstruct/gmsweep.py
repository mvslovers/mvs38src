#!/usr/bin/env python3
"""Tree-wide trial: GETMAIN/FREEMAIN reconstructed, every module rebuilt.

gate.sh appends EXTRA_MACS at the END of the -I list, so a trial macro there
loses to AMACLIB which sits first. A trial that must WIN has to prepend, which
gate.sh cannot do -- hence this one-off sweep rather than a gate label. It writes
a deck directory baseline_gate.py can read, so the acceptance test is the same
set diff as every other change.
"""
import concurrent.futures, os, subprocess, sys
sys.path.insert(0, "tools")
os.environ["SYSPARMS"]="/private/tmp/claude-501/-Users-mike-repos-mvs-mvs38src/5b5bad03-54bd-4be0-8036-9cd5a73a5e47/scratchpad/sysparm-trial.tsv"
from macpath import flags
from asmparams import params
SP="/private/tmp/claude-501/-Users-mike-repos-mvs-mvs38src/5b5bad03-54bd-4be0-8036-9cd5a73a5e47/scratchpad"
OUT=os.path.join(os.getcwd(),"obj_gmtrial"); os.makedirs(OUT,exist_ok=True)
SRC="work/src-states/overlay"
BIN="work/src-states/bin/as370-main"
mods=sorted(f[:-4] for f in os.listdir(SRC) if f.endswith(".ASM"))
def one(m):
    argv,env=params(m)
    subprocess.run([BIN,"-I",SP+"/gmtrial"]+argv+flags()+["-o",os.path.join(OUT,m+".obj"),
                   os.path.join(SRC,m+".ASM")],capture_output=True,
                   env=dict(os.environ,**env),timeout=400)
    return m
done=0
with concurrent.futures.ThreadPoolExecutor(6) as ex:
    for _ in ex.map(one,mods):
        done+=1
        if done%500==0: print(f"  {done}/{len(mods)}",flush=True)
print(f"{done} modules -> {OUT}")
