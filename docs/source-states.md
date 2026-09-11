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
