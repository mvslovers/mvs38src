# Dave Kreiss' build environment on `MVSCE-LAB` — install log

2026-09-09. Steps 1–5 of *Build MVS From Source Instructions* v2.1 are done. This
records what the document says, what it does not say, and what had to be different
here — so the next person does not re-derive it.

**Machine: `MVSCE-LAB`** — 3270 3272, FTP 2122, mvsMF 8082, Hercules console 8282,
tmux window `0:1` on `mvsdev`. **`MVSCE-EXP` is untouched on purpose**: it produced
all 5,528 IFOX00 reference decks, and an APPLY of Dave's 2,221 PTFs would destroy
the reference every gate figure since 2026-09-07 is measured against.

## What is on the machine now

| | |
|---|---|
| twelve 3390-1 volumes `BLDDLB`…`BLDWK2` at 192–19D | `PRIV/RSERV` |
| `BLDMVS.AWS`, 190 MB, SHA256 verified against the copy in `MVSSRC` | mounted at **0100** |
| `MVSSRC.BLD.*` — 15 datasets on `BLDSMP` | loaded, `COPY` step `CC 0000` |

```
MVSSRC.BLD.SMP.JCL   .JCL1 .JCL2 .JCL3 .JCL4 .JCL5
MVSSRC.BLD.SMP.LIB   .LIB1 .LIB2 .LIB3 .LIB4 .LIB5
MVSSRC.BLD.NEW.ASM   MVSSRC.BLD.MVT.ASM   MVSSRC.BLD.UTILITY.ASM
```

## Four things the document does not tell you

**1. No IOGEN is needed — the addresses are already there.** `D U,,,192,12` before
any change shows 192–19D as **3390 OFFLINE**. MVS/CE has them genned; they only
need Hercules devices behind them and the VATLST00 entries.

**2. `attach` works without a Hercules restart, but the volumes still need the
IPL.** Attaching all twelve live and issuing `V 192-19D,ONLINE` leaves them
`O … /REMOV` — online, label read, *not mounted*. Individual
`M unit,VOL=(SL,volser)` sometimes takes and sometimes does not
(`IEE335I MOUNT VOL PARAMETER MISSING`). **After the IPL all twelve come up
`PRIV/RSERV` by themselves**, from VATLST00. Dave's Step 4 is not optional; it is
just not explained.

**3. VATLST00 alignment: follow the file, not the PDF.** The document shows eight
spaces before `,N`; `SYS1.PARMLIB(VATLST00)` on this system uses four, with the
comma at **column 20** and the flag at **21**. Its own note says to watch the `,N`
alignment — so match the existing entries column for column, not the printed
example. Entries added as `BLDxxx,1,2,3390    ,N` (reserved, **private**).

**4. There is no device at 480.** Dave puts the install tape there and the JCL
says `UNIT=480`. On MVS/CE `D U,,,480,4` comes back **empty**, and the job fails
with

```
IEF210I BLDCOPY COPY JCLI - UNIT FIELD SPECIFIES INCORRECT DEVICE NAME
```

MVS knows tapes at **100–103** (2400, online) and 200–203 / 210–213 (offline);
Hercules has 3420s at 0100–0103 and 0310–0313. So: `devinit 0100 tapes/BLDMVS.AWS`
and `UNIT=480` → `UNIT=100` throughout the JCL. Fifteen occurrences.

## Two things about the job itself

**`MSGCLASS=H`.** Dave's card says `A`; with `A` the output is printed and purged
and the job cannot be read back through the API.

**`CC 0008` is the expected result of a first run.** The `DELETE` step is IDCAMS
deleting datasets that do not exist yet. The step that matters is `COPY`, and it
reports `CC 0000`.

## The mistake worth recording

I restarted Hercules **detached**, with `setsid nohup ./start_mvs.sh`, instead of
in its tmux window — so the instance ran where Mike could not see or drive it. It
belongs in `0:1`:

```sh
tmux send-keys -t 0:1 "cd ~/MVSCE-LAB && ./start_mvs.sh" C-m
```

And after every IPL, **`/S HTTPD` and `/S FTPD`** — `mvsce.rc` does not start them,
and without `HTTPD` there is no mvsMF on 8082 and no way to submit anything.

While chasing that I also convinced myself a stray Hercules was respawning from
`/home/mike`. It never existed: `pgrep -f "hercules -f conf/local.cnf"` **matched
its own command line** — the shell running the pgrep contained the pattern. Use
`ps -eo pid,args` and filter, or match on something the query cannot contain.

## Step 6, run 1: 265 jobs, and 26 SYSMODs that did not apply

The chain ran the whole Basic phase and stopped at the load-module cross-reference
report. **It looked finished and it was not.** Reading the return codes instead of
the last line:

| | Jobs |
|---|---:|
| `CC 0000` / `CC 0004` — SMP's normal | 239 |
| **`CC 0012`, APPLY terminated — the SYSMOD did not apply** | **26** |
| `JCL ERROR` at the report job | 1 |

A build with 26 unapplied SYSMODs is not a build, and nothing in the chain says
so: Dave's `SUB` step carries no `COND`, so every job submits its successor
whatever happened. **The only place the failure exists is inside the SMP listing
of the job that failed.**

### Cause 1 — `SMPSCDS` runs out of directory blocks, 21 SYSMODs

```
HMA2673 ** DIRECTORY SPACE EXCEEDED ATTEMPTING TO STORE LMOD IFCEWIN2 ON SMPSCDS
HMA4180    INLINE JCLIN PROCESSING FAILED FOR SYSMOD=EER1400
HMA3020    APPLY PROCESSING TERMINATED FOR SYSMOD EER1400 - REASON = INLINE JCLIN FAILURE
```

`$01SMPAL` allocates it `DR=90`. It filled at **629 members** and stayed full, so
every APPLY from `EER1400B` onward died the same way. `SMPCDS` and `SMPACDS` in
the same job already get `DR=4500` — `SMPSCDS` is the outlier, and it holds one
saved entry per LMOD the APPLY touches.

**`SMPPTS` was next**: 307 members against `DR=105`, about 315 of capacity. It had
not failed yet and would have, hours in.

Changed in `MVSSRC.BLD.SMP.JCL($01SMPAL)`, on `MVSCE-LAB` only:

```
//SMPSCDS  EXEC ALCPDS,D=SMPSCDS,P=20,S=5,DR=4500,V=BLDSMP   (was DR=90)
//SMPPTS   EXEC ALCPDS,D=SMPPTS,P=105,S=5,DR=1000,V=BLDSMP   (was DR=105)
```

The other 85 `ALCPDS` allocations were checked against their live member counts
in the same pass. Nothing else is near its limit.

### Cause 2 — 5 SYSMODs, `SYSTEM UTILITY FAILURE`, still open

`EBT1102B` and `EDM1102B` lose **42 and 119 macro copies**:

```
HMA4092 ** COPY FAILED - MAC=ACB - LIBRARY=MACLIB - SYSMOD=EDM1102 - RETURN CODE=04
```

Every `SRC=` copy in the same job succeeds — 116 and 892 of them. The split is by
target library, not by member. Ruled out, each by measurement rather than by
reasoning:

| Suspected | Checked | Result |
|---|---|---|
| the macros are not in the source library | `ACB ACBVS IFGEXLST IHADCB IHB01 OPEN NOTE POINT LOCATE MODCB PROTECT IMGLIB` in `SYS1.AMACLIB` | **all present** |
| `MACLIB`'s directory is full | wrote a probe member into it | **accepted**, so not full |
| `MACLIB` copies never work | `EDS1102` in the same run | **one succeeded** |

All 119 failures name `TXLIB(OMACLIB)`, which `SYS1.PROCLIB(BLDSMP)` maps to
`SYS1.AMACLIB`. The library is there and holds the macros. **What IEBCOPY itself
said is the missing evidence, and Dave's process throws it away** — see below.

### Why it could not be diagnosed, and what was changed instead

`BLDCLR` empties `COPPRINT`, `UPDPRINT`, `ASMPRINT`, `LKDPRINT` and `SMPOUT` at
the **start of every job**, and `BLDCOPY` archives only `SMPOUT`:

```
//SYSUT1   DD  DSN=MVSSRC.BLD.SMPOUT,DISP=SHR
//*        DD  DSN=MVSSRC.BLD.COPPRINT,DISP=SHR      <- commented out
//*        DD  DSN=MVSSRC.BLD.UPDPRINT,DISP=SHR      <- commented out
```

So the utility listing that would answer this is overwritten by the next job. The
obvious repair is to uncomment those two cards — but that edits the running
system's `SYS1.PROCLIB` and changes Dave's process, which is the thing being
reproduced. `tools/bldrun.py` does it without either: the driver already waits
for each job before submitting the next, so it is standing at the one moment the
listings still exist. On a bad return code it now copies all five into
`work/build/snapshots/` first.

## `SYS1.SORTLIB` does not exist on MVS/CE — the report jobs cannot run

The chain's last job, `ZLMDRPTD`, ends `JCL ERROR`:

```
IEF212I RPTDLB SORT1 SORTLIB - DATA SET NOT FOUND
```

There is **no sort product on this system at all** — no `SYS1.SORTLIB`, and no
`SORT` member in `SYS1.LINKLIB`, `SYS2.LINKLIB` or `MVSSRC.BLD.LOAD`. `ZLMDRPTT`
and `ZCMPNUC` are the same two SORT steps and will fail identically.

Dave anticipates half of this — v2.1 p. 9 says to change `UNIT=SORT` to
`UNIT=SYSDA` in `ZCMPSVC, LMDRPTD, ZLMDRPTT, ZCMPNUC` because TK5 dropped the
esoteric name — but assumes the sort *program* is there. On MVS/CE it is not.

**These are the verification jobs, not build steps**: `LMDRPT38` compares the
load modules built from source against the original DLIBs, which is precisely the
comparison this project exists to make. They are deferred, not abandoned. The
inputs (`MVSSRC.BLD.NEW.LMDXRF.DLIB`, `.ORG.`) are produced correctly by
`BLDNDLB`/`BLDODLB`, and the sort is `SORT FIELDS=(1,40,CH,A)` on FB/80 — doable
off-host as long as **both** sides get the same collating order, which for
EBCDIC data means sorting the raw bytes rather than a translated copy.

## Next

**Step 6** — the SMP build job streams, starting with the Basic phase. Per the
document the Basic phase *does not alter the running system*; it writes under
`MVSSRC.BLD`. Phase 1 onward updates `SYS1.LINKLIB` of the running system and is
the point at which `MVSCE-LAB` stops being restorable from anything but a backup.
