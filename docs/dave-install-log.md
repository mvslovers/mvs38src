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

### Cause 2 — two missing TCAM macros, and SMP's arithmetic on top of them

Run 2 answered this, because the driver now keeps `COPPRINT` before the next job
wipes it. **`EBT1102B` does not lose 42 macro copies. It loses two.**

```
IEB177I  BTMHJN   WAS SELECTED BUT NOT FOUND IN ANY INPUT DATA SET
IEB177I  BTMIOBWA WAS SELECTED BUT NOT FOUND IN ANY INPUT DATA SET
IEB147I  END OF JOB -04 WAS HIGHEST SEVERITY CODE
```

| | |
|---|---:|
| macros `SELECT`ed for `MACLIB` | 42 |
| **`IEB154I ... SUCCESSFULLY COPIED`** | **40** |
| `IEB177I ... NOT FOUND` | **2** |
| what SMP then reported as `HMA4092 ** COPY FAILED` | **42** |

**IEBCOPY returns 04 for the step, and SMP attributes the step's return code to
every element in it.** So one missing macro reads as forty-two failures, and the
SYSMOD's APPLY is terminated as a `SYSTEM UTILITY FAILURE`. The run-1 entry here
said "loses 42 and 119 macro copies" — that was SMP's accounting repeated back,
and it is wrong. `EBT1102E` is the same two macros on the ACCEPT side.

`EDM1102B` is the same shape an order of magnitude up:

| | `EBT1102B` | `EDM1102B` |
|---|---:|---:|
| `IEB154I ... SUCCESSFULLY COPIED` | 40 | **1,007** |
| `IEB177I ... NOT FOUND` | **2** | **4** |
| SMP's `HMA4092 ** COPY FAILED` | 42 | **119** |

**Six macros, not 161.** The whole list, across both jobs:

| Macro | In `SYS1.AMACLIB`? | Anywhere else we hold? |
|---|---|---|
| `BTMHJN` | no | **nowhere** |
| `BTMIOBWA` | no | **nowhere** |
| `IECPDSCB` | no | **nowhere** |
| `IEZCTGPL` | no | web mirror |
| `IHADECB` | no | web mirror |
| `IHADVCT` | no | web mirror **and MVS/CE's own `SYS1.MACLIB`** |

**Do not simply supply them.** `IHADVCT` is the warning: the copy in MVS/CE's
target `SYS1.MACLIB` and the copy in the web mirror **differ in 11,648 of about
16,646 bytes**. Two macros of the same name at unrelated levels, and nothing here
says which one this build wants. `ISDAFSPC` made the same point from the other
direction — a macro is usable when its expansion is right, not when the assembly
falls silent — and supplying the wrong one would produce a build that looks
correct and is not. These belong on the hunting list in
[`missing-macros.md`](missing-macros.md), reached by a route nothing else on that
list took: **the build asked for them, rather than an assembly failing on them.**

**This is why the snapshot was worth building.** Three plausible causes were
ruled out by measurement first — the macros are in `SYS1.AMACLIB` (they were, for
the 40), the `MACLIB` directory takes new members, and `EDS1102` copied one in
successfully — and all three were true and none of them was the answer. The
answer was in a listing Dave's process deletes.

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

## Run 2: the directory fix holds, and it uncovered a seventh macro

At job 79 of 259, against run 1 at the same point:

| | run 1 | run 2 |
|---|---:|---:|
| SYSMODs whose APPLY was terminated | 9 | **6** |
| of those, `DIRECTORY SPACE EXCEEDED` | 3 | **0** |
| of those, a missing macro | 6 | 6 |

`EER1400B`, `EGA1102B` and `EIP1102B` — the first three of the 21 — now end
`CC 0004`. **The SMPSCDS cascade is gone.**

**And fixing it revealed a defect it had been hiding.** `EJE1103B` failed in run 1
with `DIRECTORY SPACE EXCEEDED` before it ever reached the copy step. In run 2 it
gets there and fails on

```
IEB177I  $ASXB    WAS SELECTED BUT NOT FOUND IN ANY INPUT DATA SET
```

one JES2 macro, absent from `SYS1.AMACLIB`, `SYS1.MACLIB` and `SYS1.HASPSRC`
alike. So the list is seven, not six, and there is no way to know whether the
remaining 18 SCDS casualties hide anything else until they run — which is the
argument for a full rerun rather than re-driving the 21 failures in place.

## One root cause, not two: the MAINT jobs are downstream of the terminated SYSMODs

`MAINT01A`–`MAINT04F` all end `CC 0008` and I had them filed as a second, separate
class of failure. They are not. `MAINT01A` selects 30 SYSMODs and reports

```
HMA3792 ** SYSMOD DSK1001 SELECTED FOR APPLY HAS NO APPLICABLE ++VER
           MODIFICATION CONTROL STATEMENT
```

for **11** of them. Read all eleven out of `MVSSRC.BLD.SMPPTS`:

```
DSK1001 M023000 M023201 M023202 M023203 M023204
M024001 M024205 M024206 M024207 M026200
```

**Every one names `FMID(EDM1102)`.** Unanimous, not a majority. `EDM1102` is the
SYSMOD whose APPLY was terminated for want of four macros, so the FMID is not
installed, so no PTF that applies *to* it has an applicable `++VER`, so every
maintenance job that selects one ends `CC 0008`.

**Corrected, one job later.** I wrote the paragraph above from `MAINT01A` alone
and generalised it to `EDM1102`. `MAINT02A` selects 148 SYSMODs and skips six —
all of them Dave's own `DSK*` usermods rather than IBM PTFs — and they split:

```
DSK1053 EDM1102    DSK1096 EDM1102    DSK1108 EDM1102
DSK1102 EBT1102    DSK1119 EBT1102    DSK1137 EBT1102
```

**Three name `EBT1102`, the TCAM SYSMOD**, which is terminated for its own two
missing macros. So the mechanism is right and the attribution was too narrow: the
`MAINT` jobs are downstream of *whichever* of the three terminated SYSMODs their
selection touches, not of `EDM1102` alone. One job is not a class, and the second
one is what said so.

**Swept across the whole family**, rather than generalised from one job again:

| job | skipped | FMIDs named |
|---|---:|---|
| `MAINT01A B D E` | 11 each | `EDM1102` ×11 |
| `MAINT02A B D E` | 6 each | `EDM1102` ×3, **`EBT1102` ×3** |
| `MAINT03A` | 11 | `EDM1102` ×11 |

**28 distinct SYSMODs, and every one names `EDM1102` or `EBT1102`** — the two
terminated SYSMODs. No exceptions, and no skipped SYSMOD names an FMID that
actually installed. (`EJE1103`'s own maintenance has not come up yet; it would be
the third.)

So the whole build's failure surface reduces to:

| root | consequence |
|---|---|
| `IECPDSCB IEZCTGPL IHADECB IHADVCT` absent from `SYS1.AMACLIB` | `EDM1102` terminated → **11 PTFs skipped → 7 `MAINT` jobs at `CC 0008`** |
| `BTMHJN BTMIOBWA` absent | `EBT1102` terminated |
| `$ASXB` absent | `EJE1103` terminated |

**Three of the four `EDM1102` macros are recoverable** — `IEZCTGPL`, `IHADECB`
and `IHADVCT` are in `MVSSRC.SYM601.F01`, a RELFILE the job already has open.
**`IECPDSCB` is not**, anywhere: not in the 254 `MVSSRC.*` libraries, not in
`SYS1.AMACLIB` under that name or any near-miss (`IECP*`, `IEC*DSCB`, `*PDSCB`
all return nothing), not in `mvs38-ibmsrc`, the web mirrors, or Dave's tape.

**One member is holding the largest cascade in the build.** That is a better
statement of where the work is than "seven jobs fail", and it is the kind of thing
that only shows up when the return codes are read rather than the last line.

## `ZSTAGE1` `CC 0008` and `ZSTAGE2` `CC 0039` — what they actually are

Both recur in run 2 and neither had been read.

**`ZSTAGE2` is the stage-2 sysgen: 117 steps, mostly link-edits.**

| condition code | steps |
|---:|---:|
| 0000 | 93 |
| 0004 | 8 |
| 0008 | 4 |
| 0012 | 11 |
| 0016 | 1 |

The 16 above `CC 4` are `LINK` steps (`SG10 SG13 SG15 SG16 SG17 SG28 SG31 SG32
SG37 SG38`) and three assemblies (`SG5 SG6`). Across 29 of their `SYSPRINT`s the
linkage editor says:

```
IEW0342  524   module map / unresolved reference entries
IEW0642  452
IEW0143   92   ERROR - NO TEXT.
IEW0123   36   ERROR - NO ESD ENTRIES, EXECUTION IMPOSSIBLE.
IEW0461   67   -- Dave's own JCL says this one is EXPECTED for IKJEFLD
```

`NO ESD ENTRIES` and `NO TEXT` mean the linkage editor was handed **object
members that are empty**. That is the shape one would expect from SYSMODs whose
APPLY was terminated — their modules never got assembled into `OBJPDS0n` — but
**the link from these particular members to `EDM1102`, `EBT1102` and `EJE1103`
has not been established**, and it should not be asserted until it is: the
sweep that proved the `MAINT` case took reading every skipped SYSMOD's `++VER`,
and nothing that cheap is available here.

`IEW0461` being documented in Dave's own JCL comment is the reminder that not
every diagnostic in this build is a defect.

**`ZSTAGE1` `CC 0008`** is the stage-1 sysgen assembly. Its `SYSPRINT` is not
written to the spool at all — the job has only `SYSTERM` and `SYSGO` — so the
assembler's diagnostics are not recoverable from the job output, and the
snapshot has nothing either because `BLDCLR` does not run in this job. Reading
it needs a re-run with `SYSPRINT` routed to `SYSOUT`; it is on the list, not
done.

## The causal chain, predicted and then measured — 2026-09-10

Run 3 carried `BTMHJN`, `BTMIOBWA`, `IECPDSCB` and `$ASXB`. Two of the three
terminated SYSMODs applied:

```
EBT1102  HMA4180 INLINE JCLIN PROCESSING SUCCESSFUL   rc 04   0 failed copies
EJE1103  HMA4180 INLINE JCLIN PROCESSING SUCCESSFUL   rc 04   0 failed copies
EDM1102  still rc 12 -- IEZCTGPL, IHADECB, IHADVCT
```

`EDM1102`'s three were already known to be in `MVSSRC.SYM601.F01`, a RELFILE the
job has open; they had not been installed because while `IECPDSCB` was missing,
installing three of four would have unblocked nothing. They are in
`SYS1.AMACLIB` now.

### The prediction, written before the job ran

`MAINT02A` skipped six SYSMODs in run 2 — three naming `FMID(EBT1102)`, three
naming `FMID(EDM1102)`. With `EBT1102` applied and `EDM1102` not, **it should skip
exactly three, and they should be the `EDM1102` three.**

```
run 2:  DSK1053 DSK1096 DSK1102 DSK1108 DSK1119 DSK1137
run 3:  DSK1053 DSK1096         DSK1108
```

`DSK1102`, `DSK1119`, `DSK1137` are gone — the three with `FMID(EBT1102)`.
**Predicted three, got three, and the right three.**

So the chain is no longer a reading of the evidence, it is a measured mechanism:

> a missing macro → the SYSMOD's APPLY is terminated → the FMID is not installed
> → every PTF with that `++VER` is inapplicable → every `MAINT` job selecting one
> ends `CC 0008`

**Every link checked separately, and the number written down before the job ran.**
That matters here because twice on 2026-09-09 the same chain was generalised too
far — once from a single `MAINT` job, once from a report's summary page — and both
times a second measurement corrected it. A prediction that could have come out at
6, or at 3 with the wrong three, and came out at 3 with the right three, is worth
more than either.

### Run 3 against run 2, at the same point

| | run 2 | run 3 |
|---|---:|---:|
| jobs at job 81 | 81 | 81 |
| non-zero | 7 | **2** — `$02ASM`, `EDM1102B` |

`$02ASM` is the `PRTTRK` / `DS4DEVCY` macro-level difference the driver already
documents, in a utility the build does not use.

### Established: the empty object members were the terminated SYSMODs

I wrote yesterday that `ZSTAGE2`'s `NO TEXT` and `NO ESD ENTRIES` had *the shape*
of the terminated SYSMODs and that the link was **not established**. Run 3, with
two of the three applying, settles it — and it did not need `EDM1102` after all:

| linkage-editor message | run 2 | run 3 |
|---|---:|---:|
| `IEW0123 ERROR - NO ESD ENTRIES, EXECUTION IMPOSSIBLE` | 36 | **0** |
| `IEW0143 ERROR - NO TEXT` | 92 | **0** |
| `IEW0342` | 524 | **0** |
| `IEW0461` — Dave's JCL says this one is expected | 67 | 264 |

The empty object members are gone entirely. `IEW0461` rising is consistent rather
than contrary: more modules link, so the one warning Dave documents as expected
appears more often.

And the step codes move with them:

| | run 2 | run 3 |
|---|---:|---:|
| `CC 0000` | 93 | **100** |
| `CC 0012` | 11 | **0** |
| `CC 0008` | 4 | **1** |
| steps above `CC 4` | 16 | **2** — `SG6`, `SG32` |

**`ZSTAGE1` is `CC 0000`**, from `CC 0008` in both earlier runs. Its `SYSPRINT`
never reached the spool, so the code could not be read at all — and it turned out
not to need reading. Two of the seven failure classes in this build closed without
anyone diagnosing them directly, because they were consequences rather than
causes.

`ZSTAGE2` still ends `CC 0039` on `SG6` and `SG32`. Those two are now the whole
of it, and they are a question for run 4.

---

## Run 5 — Dave's build on `MVSTK5-BLD`, 2026-09-10

First run on the chosen baseline. Setup in
[`fahrplan.md`](fahrplan.md) §5 stage 2; four things had to be built on TK5 that
are not on Dave's tape.

**44 jobs, two non-zero.** On `MVSCE-LAB` run 1 had 26 failed SYSMODs and even
run 4 still had two.

| | |
|---|---|
| `$02ASM` | `CC 0024` — the same `PRTTRK` case as on MVS/CE |
| `$08STG1A` | `CC 0020` — **new**, six sysgen steps (`SG3`–`SG7`, `SG11`) |
| everything else through `EDM1102D` | `CC 0000` / `CC 0004` |

**`EDM1102B` returned `CC 0004` on the first run.** On MVS/CE that job failed 119
macro copies in run 1 and was still one of only two non-zero jobs in run 4, after
nine macros had been hunted down and installed. Here it went through clean. That
is the single most encouraging number of the run, and it is one job — not a
result about the whole chain.

### `$08STG1A` is unexplained, and the snapshot is why

`snapshot()` exists so a failing job's listing survives the next job's `BLDCLR`.
It fired, kept `ASMPRINT`, and **explained the opposite of what happened**: the
listing was 31,524 lines, the cap kept the first and last 4,000, and all fifteen
severity lines in the kept part read `HIGHEST SEVERITY WAS 0`. The six failures
are in the 23,524 lines that were thrown away.

Head-and-tail is the wrong rule for a job that runs fifteen assemblies. It was
written for `EBT1102B`, where four `IEB177I` lines sat in a 343-line `COPPRINT`,
and it does not generalise. `snapshot()` now keeps the head, the tail, **and
every line carrying a verdict** — `IFOnnn`, a non-zero severity, `IEBnnn`,
`IEWnnn`, `HMAnnn`, `RETURN CODE`, `COPY FAILED` — with two lines of context
each. Tested against a synthetic listing whose only `SEVERITY WAS 8` sits dead in
the middle: the old rule loses it, the new one keeps it.

`$08STG1A` has to be re-run on its own to get its listing back, and that is a
to-do, not a blocker: Dave's chain carries no `COND` and runs on past a step
failure by design.
