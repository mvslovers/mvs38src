# Which of Dave Kreiss' source states reaches TK5's object?

2026-09-11. [`fahrplan.md`](fahrplan.md) §2 established that "Dave's source" is
not a well-defined phrase — the archive copy and the library his own SMP chain
produces are two different trees — and said how to settle it: *"the choice is not
made by argument. The instrument that answered the baseline question answers this
one unchanged — same decks, same comparator, one more column. Run it against all
three source states and read the number."*

This is that run. It had never been made.

## What was held fixed, and it is the whole design

Everything except the source:

| | |
|---|---|
| assembler | **one pinned `as370`**, copied out of the cc370 tree, `sha256 affc90e3…` — see [`../work/src-states/bin/PROVENANCE.txt`](../work/src-states/bin/PROVENANCE.txt) |
| macro path | the promoted gate path, verbatim from `tools/gate.sh` |
| assembly stamp | `ASMDATE=09/07/26`, `ASMTIME=12.00`, pinned |
| reference | TK5's distribution-library members, `work/measurements/dlib-bytes/tk5` |
| comparator | `cmplmd370`, one pinned copy |
| population | the **3,988** modules the TK5 reference actually holds, mapped from the reference tree itself rather than from a list |

The binary matters more than it sounds. Its default path points into a working
tree another session rebuilds continuously — that produced two different binaries
inside one measurement on the morning of 2026-09-11 — so it is pinned by copy and
by hash, not by path.

## The control the run needed first

The archive is **CRLF**; a member read back off MVS over mvsMF is **LF**. If that
moved a deck, every difference between the columns would have had two
explanations.

Eight modules that
[`archive-vs-system-source.md`](archive-vs-system-source.md) calls *identical*
were assembled from both trees: **8 of 8 byte-identical decks**, one of them at
`rc 8` so the failure path is covered too. **Line endings are not a variable.**

And the instrument reproduces a recorded number it was not tuned to: the archive
column lands on **1,084 of 3,988**, which is exactly the figure
[`deck-vs-tk5-ce.md`](deck-vs-tk5-ce.md) carries — derived there from *IFOX00*
decks, here from `as370` ones.

## The two states

| | source | pinned by |
|---|---|---|
| **archive** | `MVSSRC/Dave Kreiss - MVS from Source/MVSBLD/`, 5,528 `.ASM` | the path; this is the copy all 5,528 reference decks were cut from |
| **applied** | `MVSSRC.BLD.AMVSSRC` on `MVSTK5-BLD` after **run 6**, pulled 08:10 | the library **and** the SYSMOD state: Dave's `DSK*` chain, `MAINT01@`–`MAINT04F`, on the first TK5 build that did not run out of space |

## The result, and the two measures disagree

| | archive | **applied** | |
|---|---:|---:|---|
| modules assembling `rc 0` (of 5,528) | 4,576 | **4,676** | **+100** |
| **byte-identical to TK5's object** (of 3,988) | **1,084** | **1,076** | **−8** |
| — gained | | 32 | |
| — lost | | 40 | |
| **closer to the object** | | **100** | |
| **further from it** | | **51** | |

The last two rows are counted over the **3,480 modules that assemble `rc 0` on
both sides**, because a byte distance measured against a partial deck is not a
statement. Over all 3,988 it is 109 against 55 — the filter barely moves it,
which is itself worth knowing.

**So Dave's applied maintenance makes a hundred more modules assemble, and moves
twice as many modules towards IBM's object as away from it — and costs eight net
byte-identities.** Both of those are real. They are not reconcilable into one
number, and this document does not try.

**The eight are not assembly failures.** Of the 40 modules that lost identity,
**zero** changed return code. They assemble exactly as cleanly as before and
produce different object.

### What is lost, and it clusters

```
AHLTCTL1 AKJLKMSG AMASPZAP AMDPRECT AMDPRFAR BLSCABLD BLSRADD3 BLSRIOSK
BLSRVECT BLSUINI2 BLSUMONL BLSUTSO  BLSUVP31 IEAVRTOD IEAVTFTM IEBMCM
IEBVDM   IEBVMS   IEEMB878 IEHDMSGS IEHDSCAN IFCETUL1 IFCSXXX4 IFCSXXX6
IFDMSG00 IGC0308B IGG019P8 IKJCT432 IKJEBEAA IKJEBECH IKJEBESC IKJEFA42
IKJEFD33 IKJRBBCM IKTCAS54 ISTCFMMI ISTINCD7 ISTINCOS ISTINMAV ISTSDCSU
```

Ten `BLS*` (service aids), seven `IKJ*`/`IKT*` (TSO), four `IST*` (VTAM).
`ISTSDCSU` and `IKJEFA42` are two of the modules
[`fahrplan.md`](fahrplan.md) §2 named when it first measured the two states
apart — 828 source lines in the archive against 2,936 on the system for
`ISTSDCSU`. The gained 32 cluster too, in `IGG*` Data Management and the
`HMASM*`/`BLST*` families.

Per-module rows: [`../work/measurements/src-states/moves.txt`](../work/measurements/src-states/moves.txt).

### What this does not say

It does not say which state is the better base. It says the applied state is
better on the *population* measure and worse on the *identity* measure, and that
the identity measure is the project's success criterion while the distance
measure is the better predictor of where work will pay. Choosing between them is
Mike's call, and the 40 are the evidence to look at first.

## The third state does not exist in the form the plan assumed

`fahrplan.md` §2 expected a third column: *"The pristine tape state is reachable
off-host and does not need a build. `BLDMVS.AWS` is in the archive, and
`tools/awstape.py` plus `tools/pdsunload.py` already read AWS tapes at member
level. That gives candidate 2's true origin as a third column for the cost of an
extraction."*

**The tape carries no source tree.** Read end to end, `BLDMVS.AWS` is 45 files
and its data sets are:

```
SMP.JCL   SMP.LIB   NEW.ASM   MVT.ASM   UTL.ASM
SMP.JCL1..5         SMP.LIB1..5
```

`NEW.ASM` is 848 members, `MVT.ASM` 106, `UTL.ASM` 64 — and the `SMP.LIB*` sets
are his SYSMOD libraries, the `DSK*` PTFs themselves. There is no 5,528-member
source library on it, because there was never meant to be one: **the base source
comes from IBM's own distribution** — the `MVSSRC.SYM*` volumes `BLDSMP`
references — and Dave's tape carries what is applied *onto* it. A "pristine Dave
source tree" is not a thing that exists off-host.

So the honest third column is `fahrplan.md`'s **candidate 3**, IBM's delivery
level in `~/repos/mvs/mvs38-ibmsrc`, and it is a separate run.

## Reproducing it

```sh
SRC_TREE=<tree> tools/gate.sh work/src-states/bin/as370 <label>
tools/srcstate_vs_dlib.py --decks obj_<label> --out <label>-vs-tk5.tsv
```

---

## The mechanism, and it reverses the reading — 2026-09-11, later

The −8 is not Dave's maintenance moving modules away from IBM's object. It is
the opposite: **`AMVSSRC` after run 6 is not Dave's full maintenance level, and
for the modules in question it is *behind* the archive.**

### Two controls first

**The tool is not in question for any of the 72 modules that moved.** Joined
against [`../work/measurements/ifox-run/module-table.tsv`](../work/measurements/ifox-run/module-table.tsv):
all 40 lost and all 32 gained sit in the class where `as370`'s deck is
**byte-identical to IFOX00's**. So none of these verdicts can be an `as370` gap
scoring as a source difference — the movement is source and nothing else.

**And Dave's own change markers say what moved.** Of the 40 that lost identity,
**38 are modules whose `DSKnnnn` marker is present in the archive and gone in
`AMVSSRC`.** Not changed — gone. By his own phase scheme
([`kreiss-project.md`](kreiss-project.md)):

| vanished marker | Dave's phase | count, of the 40 |
|---|---|---:|
| `DSKK*` | phase 4 — `SYS1.LINKLIB` | 21 |
| `DSKC*` | phase 3 — `SYS1.CMDLIB` | 15 |
| `DSKL*` | phase 5 — `SYS1.LPALIB` | 3 |
| `DSK0*` | fix source so it assembles | 1 |

**Run 6 stopped at the phase-1 boundary.** Its own last line says so:
`ZCMPSMP1 hands on to LIB=1 (MAINT05@)`. Phases 3, 4 and 5 were never applied,
so the library holds the *unrepaired* level for every module those phases touch,
while the archive — Dave's working copy, where he had already made those
repairs — holds the repaired one.

### How large the effect is tree-wide

| | |
|---|---:|
| modules carrying a `DSK*` marker in the archive | **1,357** |
| of those, marker **gone** in `AMVSSRC` after run 6 | **619 (46 %)** |

**Nearly half of everything Dave marked is not in the system's source.** The −8
is the small visible corner of that, restricted to the 3,988 modules the TK5
reference holds and to the ones where the difference happens to cross the
identity threshold.

### What this corrects

- **"Dave's PTFs have been applied to the source" is not true of run 6.** They
  have been applied *through phase 1*. The chain's remaining phases update the
  running system, which is why the driver guards that boundary.
- **The column heading `applied` in the table above oversells it.** It is
  `applied, phase 1`. Kept as it was written, with this section as the
  correction.
- **The comparison is still sound and still worth having** — it is a true
  measurement of the two states that exist today. What changes is the
  conclusion drawn from it: the archive being ahead by 8 identities is evidence
  that **Dave's later-phase repairs are real and reach the object**, not evidence
  that his maintenance hurts.

### The question it opens

Running the chain past `MAINT05@` would apply phases 3–5 and put the system's
source at Dave's full level — and it updates the running system, which is why it
has not been done. That is a decision, not a step: it needs `MVSTK5-BLD`
backed up first, and it is the only way to measure Dave's *complete* maintenance
against TK5's object.

---

## A third state: after the chain past Dave's stop — 2026-09-11

`MAINT06@`…`MAINT15G` ran on `MVSTK5-BLD` — 82 jobs, Dave's phases 3, 4 and 5,
skipping the one job of the 83 that writes to `SYS1.LINKLIB`. 54 ended non-zero
for a single reason documented in
[`dave-install-log.md`](dave-install-log.md): SMP rejects `./ DELETE` and 485
SYSMODs were never received. It still delivered.

**144 modules changed**, carrying markers that had been missing: `DSKC*` on 111,
`DSKK*` on 30, `DSKL*` on 2, `DSK6*` on 3.

### The three states, one instrument

Same pinned `as370` (`sha256 affc90e3…`), same macro path, same stamp, same
comparator, same 3,988-module reference population.

| source state | `rc 0` of 5,528 | **identical to TK5's object**, of 3,988 |
|---|---:|---:|
| archive (`MVSBLD`) | 4,576 | 1,084 |
| applied, phase 1 (run 6) | **4,676** | 1,076 |
| **applied, phases 3–5 (run 7)** | 4,649 | **1,089** |

**Phase 1 → run 7: +13 identities and nothing lost.** Not a net figure — the
`LOST` column is empty.

```
AMDPRECT IEAVTFTM IEBVMS  IEHDMSGS IFCETUL1 IFCSXXX4 IFCSXXX6
IFDMSG00 IKJCT435 IKJEBEAA IKJEBEBO IKJEHMEM IKJRBBCM
```

**Ten of those are modules from the original list of 40** that the phase-1 state
had lost against the archive. Three — `IKJCT435`, `IKJEBEBO`, `IKJEHMEM` — were
never on that list: the applied state reaches IBM's object where the archive
does not.

**Archive → run 7: +5 identities (35 gained, 30 lost), and 100 closer against
48 further.** This is the **first state that beats the archive on both
measures**, and it settles the question the −8 raised: Dave's later-phase
repairs do reach the object, and the phase-1 state was behind because the
repairs had not been applied, not because they were wrong.

### And the marker count moves with it

| | modules |
|---|---:|
| carrying a `DSK` marker in the archive | 1,357 |
| marker missing after run 6 (phase 1) | 619 — 46 % |
| **marker missing after run 7** | **486 — 36 %** |
| recovered | **133** |

486 still missing is the size of what the `./ DELETE` rejection is costing.

### The one thing that went the other way

`rc 0` fell from 4,676 to 4,649, **−27 modules that no longer assemble
cleanly**. That is not a contradiction — a return code is not the success
criterion here, and identity rose over the same population — but it is
unexplained and is not being presented as harmless. Those 27 are the first thing
to look at if the applied state is ever adopted as the base.

---

## 2026-09-13: the two source libraries have come apart, and that is new

The question of *which* source library was settled on 2026-09-12 by finding that
it did not matter. Dave Kreiss names the **target** source library —
*"use the target source libraries that result from the build job streams instead
of using the source of the build job streams"* — where every extraction here had
read the **distribution** one, `MVSSRC.BLD.AMVSSRC`. Measured over 25 random
members, columns 1–72: **identical, 25 of 25.** The recommendation cost nothing.

**After the `MAINT06@`..`MAINT15G` chain of 2026-09-13 it costs something.** Same
method, 25 members drawn with a fixed seed, both libraries at 5,529 members:

| | members |
|---|---:|
| identical, columns 1–72 | 19 |
| **differ** | **6** |

And not marginally:

| module | `AMVSSRC` (distribution) | `MVSSRC` (target) |
|---|---:|---:|
| `IEFAB435` | 136 lines | **3,626** |
| `IDDWIFRR` | 920 | **3,592** |
| `IFDOLT00` | 40 | **206** |
| `IKJCT472` | **1,688** | 1,298 |
| `IDCDB02` | 6,820 | **7,035** |
| `IEE4203D` | **205** | 96 |

Four are much larger on the target side and two on the distribution side, so this
is not one library being a stub of the other. **24 % of a sample is not a detail**,
and it means every extraction before today read a library that is now known to
differ from the one Dave names.

Why the earlier answer was right at the time is in his own explanation: a chain
that ACCEPTs everything keeps the two sides in step — *"Because all jobs do an
ACCEPT of all functions and PTFS the Target and DLIBs of the install are in
sync"*. The 82-job chain APPLYs and ACCEPTs per phase, and the phases do not
close the same way; `MAINT14` archives 57 APPLY members against 7 ACCEPT, and
`MAINT15` 22 against 2.

**So both libraries are being extracted, not one.** `srcpull.py` takes
`SRCPULL_DS` now, and which library a figure came from is part of the figure.

---

## 2026-09-13: the run-8 source library has read errors, and the extraction is not measurable

`MVSSRC.BLD.AMVSSRC` was pulled again after the 82-job chain, to answer whether the
maintenance reaches the source. **It does not answer, because the library cannot be
read.**

| | members |
|---|---:|
| in the library | 5,529 |
| read | 5,145 |
| **unreadable** | **384** |

Every reader fails the same way and MVS itself is one of them:

```
MVSMF106E I/O ERROR READING MVSSRC.BLD.AMVSSRC ERRNO=5          (mvsMF console)
451 Read error on data set after 0 bytes                        (FTP, port 2125)
IEB351I I/O ERROR ,RDTEST ,S1 ,196,DA,SYSUT1 ,READ ,NO RECORD FOUND,
        000000AF000C04,BSAM                                     (IEBGENER)
```

`NO RECORD FOUND` at `CCHHR 0000 00AF 000C 04` — the directory points at a record
that is not on the volume. A second pull recovered exactly **one** of the 384, so
it is not transient.

**The documented cause from 2026-09-10 does not apply.** That incident correlated
with a full volume; `IEHLIST LISTVTOC` on `BLDSR2` now reports **1,017 empty
cylinders plus 14 tracks**, and 106 empty cylinders inside the data set itself.

### All 384 were readable before

Every one of them is in the run-7 extraction with content — `AHLTSVC` at 812 KB,
`AHLTCTL1` at 156 KB. Whatever happened, happened between 2026-09-11 and the
82-job chain.

### And the damage is not confined to those 384

- **69 members are truncated at the front**: the first record of the run-8 copy
  appears further down in the run-7 copy. `AHLCWRIT` went from 12,372 lines to
  2,600 and now begins mid-instruction, which is why it fails to assemble with
  *Addressability error — no active USING*.
- **743 modules assemble cleanly from the run-7 source and fail from the run-8
  source**, against 21 the other way.

### Why the figures below it must not be quoted

Both trees were assembled over the identical 5,144-member population, one binary,
one macro path:

| | run 7 source | run 8 source |
|---|---:|---:|
| `rc 0` | 4,275 | 3,553 |
| identical against both baselines | 936 | 699 |

**That is not a measurement of the source. It is a measurement of the truncation.**
A module missing its `CSECT` and `USING` cannot assemble, and a module that cannot
assemble cannot match anything. The prediction in
[`baseline-gate-predictions.md`](baseline-gate-predictions.md) — Q2, the score
rises above 1,221 — is **neither confirmed nor refuted**, and recording it as
refuted would be the worst available reading.

### Three of my own tests failed before one worked

Kept because each was wrong in a way worth not repeating.

1. **"Not in the APPLY listing ⇒ run 8 did not touch it."** This would have let
   run 7's text stand in for 372 of the 384. The control — did any module outside
   the APPLY listing change? — says **1,778 did**. The listing does not enumerate
   what the chain writes to the source library. Inference discarded.
2. **A truncation test on the sequence number in columns 73–80** reported 4,971
   of 5,145 truncated. Run against the run-7 extraction as a control it reported
   5,290 of 5,528, which is impossible. mvsMF strips trailing blanks, so the
   column arithmetic was measuring nothing. The 69 above come from a test with no
   column assumption: is the run-8 first line present further down in run 7?
3. **"Run 7's last line missing from run 8 ⇒ truncated at the end"** counted
   2,028. `AHLMCER` is in it and **grew** from 2,735 lines to 2,755, so the test
   conflates a truncated tail with a maintained one. No end-truncation figure is
   claimed.

And one test did work, on the question of whether shrinkage is damage at all:
`AHLMCIH` loses 1,208 lines and **every one of them is a `*DSK` comment**, with the
final line intact — that is Dave's `./ DELETE` doing exactly what it is for.
`BLSCALOC` loses 835 lines of **code** including its own eyecatcher
`DC C'BLSCALOC  78.066'`, and its final line is gone. Both are "shorter"; only one
is damage.

### The reader is not the cause, and the shape points at the source side of SMP

`AHLCWRIT` read over **FTP** gives the same 2,600 lines starting at the same
`LA GPR01F,245`. Two independent readers, one answer: the member on the system
really does begin there. It is missing its first 9,772 lines, up to and including
its `TITLE`, `CSECT` and `USING` — and the cut falls exactly at sequence number
`097730`, a line boundary rather than a block boundary.

That is not what a media fault looks like. It is what `./ DELETE` looks like with
the wrong base: a line-range deletion that removed everything up to a sequence
number. **Source-side element management is precisely the functionality Dave says
he added to SMP**, and `MAINT05Z` installed that SMP immediately before the chain
ran.

So the chain's two sides came out differently: the **object** side is clean — 82
jobs, no ABEND, no `CC 0012`, 1,017 modules maintained — and the **source** side is
damaged. That is worth telling him, because it is his SMP and nobody else knows
what `./ DELETE` expects.

### What has to happen before this question can be asked again

The library needs repairing or re-creating, and that is a decision about a running
system rather than a measurement. The pre-chain backup
`~/MVSTK5-BLD-frozen-20260913` is intact and verified — 32 volumes, 32 SHA-256
sums, `sha256sum -c` clean — so nothing is lost that was there before the chain.
