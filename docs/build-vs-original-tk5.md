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

The seventeen `CC 0008`/`CC 0016` codes in the maintenance phase are not
failures: `MAINT01@` reports 30 × `HMA3930 SYSMOD ... SUCCESSFULLY RECEIVED`, and
`MAINT02E` 14 × `HMA2160 UPDATE SUCCESSFUL - LIBRARY=AMVSSRC - SYSMOD=DSK1003`.
Those are **Dave's own reconstructed source going into the tree.**
