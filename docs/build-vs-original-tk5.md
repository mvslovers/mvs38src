# The build against the original — TK5 beside MVS/CE

2026-09-10. **The comparison this project exists to make, on the baseline chosen
today**, and next to the same comparison on MVS/CE from 2026-09-09
([`build-vs-original.md`](build-vs-original.md)).

Dave Kreiss' own `ZLMDRPTD` and `ZLMDRPTT`, run on `MVSTK5-BLD` against that
system's own DLIBs and targets. Reports in `work/build/reports-tk5/`.

## The two runs side by side

| DLIBs (`ZLMDRPTD`) | MVS/CE | **TK5** |
|---|---:|---:|
| CSECTs built | 4,337 | **5,369** |
| equal to the original | 2,619 | **2,756** |
| differ in **length** | 1,723 | 2,624 |
| differ in **content at the same length** | 1,497 | 1,745 |
| **missing LMODs** | **599** (8 ignored) | **81** (8 ignored) |
| missing CSECTs | 3 | 0 |
| extra CSECTs | 3 | 2 |

| targets (`ZLMDRPTT`) | MVS/CE | **TK5** |
|---|---:|---:|
| CSECTs built | 1,545 | **5,483** |
| equal to the original | 1,122 | **2,971** |
| differ in length | 405 | 2,523 |
| differ in content at the same length | 468 | 1,676 |
| missing LMODs | 47 | 24 (15 ignored) |

**The counts come from the per-CSECT `ERRORS` report, not the `SUMMARY` page.**
`SUMMARY` prints `Compared not equal 0` on both runs and it is not what it looks
like — established on 2026-09-09 and corrected in the MVS/CE document. The
authority is the detail.

## What actually changed, and it is not the match rate

**The build is far more complete on TK5.** 599 missing load modules became 81,
and 1,032 more CSECTs got built. On MVS/CE six libraries produced nothing at all
(`AOSA0` 178 → 1, `AOSC6` 36 → 0, `AOSD7` 43 → 0, `AOSD8` 116 → 0, `AOSH3`
18 → 0, `AOS20` 115 → 0) because three SYSMODs — `EDM1102`, `EBT1102`,
`EJE1103` — terminated their APPLY. On TK5 all three applied on the first run,
including `EDM1102B`, which took MVS/CE four runs and nine hunted-down macros.

**The match rate is lower, and that is the expected shape.**

| | MVS/CE | TK5 |
|---|---:|---:|
| CSECTs built | 4,337 | 5,369 |
| equal | 2,619 (60.4 %) | 2,756 (51.3 %) |

The thousand extra CSECTs are precisely the ones MVS/CE could not build, and they
come from the most heavily serviced SYSMODs in the distribution. **A build that
fails to produce a module cannot be wrong about it.** MVS/CE's higher percentage
is measured over an easier population, and the honest reading is the absolute
count: 2,756 against 2,619, over a corpus a quarter larger.

Nothing here should be read as TK5 being 51 % correct. It is one number from one
run of a source tree that has never been built to completion on this system
before, and the interesting part is the 81.

## What had to change to run it at all

**TK5 has a sort**, which MVS/CE does not: `SYS1.SORTLIB`, and `SORT`, `MVTSORT`
and `IERRCO00` in `SYS2.LINKLIB`. The whole `tools/lmdreport.py` detour — sorting
off-host in EBCDIC order because the four verification jobs begin with
`PGM=SORT` — is unnecessary here.

**But Dave's documented fix is not enough.** His instructions (v2.1 p. 9) say to
replace `UNIT=SORT`, an esoteric name TK5 does not define, with `UNIT=SYSDA`.
That produces:

```
IER042A SORTWORK Unit Error - More than one Unit Type
```

`SYSDA` on TK5 spans **3350 and 3390**, and the three work files landed on `291`
(3390), `34A` (3350) and `198` (3390). OS/360 Sort requires one device type for
all of them. `UNIT=3390` on the six `SORTWK` cards in each of `ZLMDRPTD`,
`ZLMDRPTT`, `ZCMPNUC` and `ZCMPSVC`.

## The run that produced this

`bldrun.py` on `MVSTK5-BLD`, 227 jobs from `$01SMPAL`, then the verification
phase:

```
ZLMDRPTD  CC 0000     ZCMPNUC   CC 0008     ZCMPJES   CC 0004
ZLMDRPTT  CC 0000     ZCMPNUC1  CC 0008     ZCMPSMP   CC 0004
                      ZCMPNUC2  CC 0008     ZCMPSMP1  CC 0004
                      ZCMPNUC3-5 CC 0004    ZCMPSVC   CC 0008
```

and the driver stopped where it is supposed to: `ZCMPSMP1` hands on to `LIB=1`,
which is the Phase-1 boundary and updates the running system.

Two jobs in the run are unexplained: `$08STG1A` (`CC 0020`, six sysgen steps) and
`ZSTAGE2` (`CC 0039`). Both need a re-run to recover their listings — the
snapshot's head-and-tail cap discarded the diagnostics, and the fix for that was
written but not deployed to the machine the driver runs on until afterwards.

> **Both are explained as of 2026-09-11, and neither needed a re-run in the end.**
> `$08STG1A` is a concatenation-DCB trap — `SYS1.AMODGEN` at BLKSIZE 19,040 ahead
> of `SYS1.MACLIB` at 27,920 — and it self-heals, because `ZSTAGE2` re-assembles
> the same six modules from libraries that are both 27,920. Verified: 404 before,
> 200 with content after. `ZSTAGE2`'s `CC 0039` was never a step code at all; its
> highest step was `0012`. See `dave-install-log.md`, `run6-predictions.md` and
> the knowledge base entry `MVS-JCL-0001`.

The seventeen `CC 0008`/`CC 0016` codes in the maintenance phase are not
failures: `MAINT01@` reports 30 × `HMA3930 SYSMOD ... SUCCESSFULLY RECEIVED`, and
`MAINT02E` 14 × `HMA2160 UPDATE SUCCESSFUL - LIBRARY=AMVSSRC - SYSMOD=DSK1003`.
Those are **Dave's own reconstructed source going into the tree.**

---

## Run 6, 2026-09-11: the same comparison on a build that did not run out of space

The run above is **run 5**, and run 5 is the run in which `MAINT03B` ended
`IEC031I D37-04` — out of space mid-write, tearing members of `MVSSRC.BLD.MVSSRC`
that every later APPLY then added to. Run 6 carries the secondary-quantity fix
(`tools/bldrun.py` supplies `S=50` at submit time) and reached the phase-1
boundary clean, so this is the first tree-wide comparison on a TK5 build that is
not damaged.

`ZLMDRPTD` ran as `RPTDLB/JOB00815` and `ZLMDRPTT` as `RPTTGT/JOB00816`, both
`CC 0000`. Reports in `work/build/reports-tk5-run6/`. Run 6's own pass through
these two jobs (`JOB00802`/`JOB00804`, also `CC 0000`) was never fetched and the
spool has since been purged, so they were re-submitted against the same
unchanged build libraries — nothing has run past the phase-1 boundary.

### The counts

Both runs counted by `tools/lmdrpt_count.py`, one script over all four reports.

| `ZLMDRPTD` — distribution libraries | run 5 | **run 6** |
|---|---:|---:|
| CSECTs built | 5,369 | **5,448** |
| length differs | 2,620 | **2,350** |
| content differs at the same length | 1,745 | **1,677** |
| **missing build LMODs** | **81** | **2** |
| extra CSECT in LMOD | 1 | 1 |
| **equal to the original** | **1,003** | **1,420** |

| `ZLMDRPTT` — target libraries | run 5 | **run 6** |
|---|---:|---:|
| CSECTs built | 5,483 | **5,485** |
| length differs | 2,519 | **2,400** |
| content differs at the same length | 1,676 | **1,664** |
| missing build LMODs | 24 | 24 |
| missing build CSECTs | 20 | **18** |
| **equal to the original** | **1,286** | **1,419** |

**The 81 missing load modules are the `D37` damage, and they are gone** — 81 → 2.
That is what the space fix bought, and it is the clearest single number in the
pair. Everything else moves the right way by a few per cent: +417 equal CSECTs on
the distribution side, +133 on the targets.

### A correction to the figures above, and it is this document's own trap

The run-5 table at the head of this document reports **"equal to the original
2,619 / 2,756"** and **"2,971"** for the targets. Those numbers come from the
`SUMMARY` page — and this document already says, one paragraph later, that they
must not:

> The counts come from the per-CSECT `ERRORS` report, not the `SUMMARY` page.
> `SUMMARY` prints `Compared not equal 0` on both runs and it is not what it
> looks like. The authority is the detail.

The warning was written and then not followed. `SUMMARY`'s own totals block says
why:

```
Compared equal          3,038        Compared not equal          0
 Total equal            3,092        Length different        2,399
                                      Total not equal        2,399
                                       Total CSECTs          5,485
```

`Compared not equal` is **0 on every run anyone here has taken**, so `Total
equal` is `Total CSECTs` minus the *length* differences alone. The 1,664 CSECTs
the `ERRORS` detail annotates `CSECTs don't match` — same length, different
content — are inside that `Total equal`. They are not equal.

`tools/lmdrpt_count.py` reproduces the published figures exactly from the
`SUMMARY` page (2,756 and 2,971) and the stricter ones from the detail, which is
what establishes that this is a counting difference and not two different runs.
Both numbers are kept in the tables above so the correction stays visible.

**What this does not change:** every other figure in the run-5 table —
5,369 built, 1,745 content differences, 81 missing LMODs, 0 missing CSECTs —
reproduces exactly. Only the `equal` row moved.

---

## Why 98 % and 26 % are both true — 2026-09-12

Asked because the two headline figures look irreconcilable, and because Dave
Kreiss' own account of what he had finished has to be checked against ours
rather than assumed to disagree.

**They answer different questions.**

| figure | what it measures |
|---|---|
| **5,427 of 5,528 — 98 %** | `as370` produces the same deck as IFOX00. **A tool figure.** It says our assembler is trustworthy; it says nothing about whether the source is at the object's maintenance level |
| **1,422 of 5,485 — 26 %** | the build's CSECT is byte-identical to the one IBM shipped. **The project figure** |

A module can be in the 98 % and not in the 26 %: the assembler is right and the
source is still an older maintenance level. That is the entire premise of the
project.

**Two independent instruments agree on the 26 %.** The build's own `LMDRPT38`
reports 1,422 of 5,485 target CSECTs equal, and the host-side measurement
against TK5's distribution libraries reports 1,089 of 3,988
([`source-states.md`](source-states.md)) — 25.9 % and 27.3 %, over different
populations, from different programs on different machines.

### And Dave's account is confirmed, library by library

He wrote that `SYS1.NUCLEUS` was finished and that `SYS1.LPALIB` and
`SYS1.LINKLIB` were not — and that those two are very large. Measured on run 6's
`ZLMDRPTT`:

| target library | CSECTs built | equal | |
|---|---:|---:|---:|
| **`SVCLIB`** | 59 | **59** | **100 %** |
| **`NUCLEUS`** | 354 | **334** | **94.4 %** |
| `CMDLIB` | 753 | 229 | 30.4 % |
| **`LINKLIB`** | 1,721 | 468 | **27.2 %** |
| **`LPALIB`** | 2,343 | 290 | **12.4 %** |
| `TELCMLIB` | 192 | 32 | 16.7 % |
| `VTAMLIB` | 63 | 10 | 15.9 % |

**`SVCLIB` is complete and `NUCLEUS` is at 94 %** — exactly what he said. And the
two he named as outstanding hold **4,064 of the 5,485 CSECTs, 74 % of the whole
target population**, which is exactly what "super viele Module" means.

So there is no contradiction to resolve. The 26 % is dominated by `LPALIB` and
`LINKLIB` because *they* are where the work is, and he had already told us so.
The distribution side says the same thing in its own vocabulary: `AOSB3` at
6.7 %, `AOS26` at 12.0 %, `AOS21` at 16.3 % against `AOSC5` at 56.5 %.
