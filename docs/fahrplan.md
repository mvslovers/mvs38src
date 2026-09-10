# Fahrplan — the baseline is decided, and what follows from it

2026-09-10. **Supersedes the direction of [`workplan.md`](workplan.md)** (2026-09-04)
on one point only: that document left the object baseline open and assumed MVS/CE.
Its host-side recovery machinery — the extract / assemble / compare cycle on the
Mac, the requirement that everything be machine-decidable — is unchanged and still
governs.

## 1. The decision

**The object baseline is TK5.**

Measured, not argued ([`deck-vs-tk5-ce.md`](deck-vs-tk5-ce.md)): over 3,988
modules, where TK5 and MVS/CE both carry maintenance Dave Kreiss' source hits TK5
**15 times to 1**, and it is byte-identical to a maintained object MVS/CE does not
carry at all in **7 modules against 0** the other way.

**And the decision is smaller than it looks.** In raw match count the two systems
are ten modules apart in 3,988 — 1,084 against 1,094 — because 87 % of the corpus
carries the same object on both and cannot distinguish them at all. What the
choice buys is a baseline that is never *behind*: TK5 is at base FMID in none of
the 515 divergent modules, MVS/CE in 127.

Three things the decision does **not** rest on, recorded so nobody re-derives
them:

- not on lineage-by-assertion (TK3 → TK4- → TK5), which was the *prediction*, not
  the evidence;
- not on the raw count, which points the other way and is the wrong grouping;
- not on TK5 being "more complete" — neither deck is a superset of the other
  ([`dlib-distance-tk5-ce.md`](dlib-distance-tk5-ce.md)).

### What must be said out loud when TK5 becomes the reference

The goal is a source tree at **MVS 3.8j DLIB level, distribution-independent** —
not "source for TK5". TK5 carries 115 USERMODs, so non-IBM object code in it has
to be named rather than inherited silently. It is a short list:

| | modules |
|---|--:|
| TK5 modules changed by a USERMOD in the **distribution** zone | **4** |
| of those, in this corpus | 2 — `IEFVHE`, `IEFVHF` (`#DYP005`, `#DYP003`) |
| TK5 modules changed by a USERMOD in the **target** zone only | 49 |

The 49 are the running system and never reach a DLIB. Four objects is the whole
non-IBM surface of TK5's distribution libraries, and both of ours show it: same
RMID as MVS/CE, same length, different bytes.

## 2. The other axis — which source tree, and a finding that reshapes the question

The baseline decides the **right-hand** side of every comparison. The left-hand
side is a separate choice and must not be folded into it. Three candidates were
on the table:

1. Dave Kreiss' source as it sits in the archive — `MVSSRC/Dave Kreiss - MVS from
   Source/MVSBLD/`, 5,528 `.ASM` members, and **the copy all 5,528 reference decks
   were assembled from**;
2. Dave's source "as patched" — what the build chain has on the system;
3. IBM's delivery level — `~/repos/mvs/mvs38-ibmsrc`.

**Candidates 1 and 2 are the same tree at two different states, and they are not
equal.** `MVSSRC.BLD.AMVSSRC` on `MVSCE-LAB` holds 5,529 members against the
archive's 5,528. Over a random sample of 400, comparing columns 1–72 only and
normalising the `^` that the archive extraction produced where the source carries
the PL/S `¬` (`X'AC'`):

| | modules | |
|---|--:|--:|
| source identical | 213 | 53.2 % |
| **differ only in comment lines** | 127 | 31.8 % |
| **differ in code** | **60** | **15.0 %** |

The comment-only class is Dave's own disabled lines. `IGFPMMSG` is 204 records in
the archive and 1,477 on the system; the extra 1,273 are all of the form

```
*DSK1231 @01      EQU   01
```

— statements he commented out, marked with his own `DSK` tag, which the archive
copy simply does not carry. Assembled with `as370`, **the two versions produce
byte-identical decks**. For that class the archive has lost Dave's record of what
he disabled, and nothing else.

The 15 % that differ in code are a different matter, and some are large:
`BLSSLPDE` has 556 code lines in the archive against 2,046 on the system,
`ISTSDCSU` 828 against 2,936.

### What that means for the plan

**"Dave's source" has not been a well-defined phrase, and every figure this
project quotes about it was taken against the archive copy.** That is not
retroactively wrong — the archive is a real state of his tree — but it has to be
named from here on, and the two states have to be told apart.

Three consequences:

- **A source snapshot without its SMP state is unpinned.** Dave designed the
  thing as an SMP-maintained tree; `AMVSSRC` on LAB has had four partial build
  runs ACCEPT into it, so it is not the tape state either. Any measurement of
  "Dave's source" records the library *and* the SYSMOD list.
- **The pristine tape state is reachable off-host and does not need a build.**
  `BLDMVS.AWS` is in the archive, and `tools/awstape.py` plus `tools/pdsunload.py`
  already read AWS tapes at member level. That gives candidate 2's true origin as
  a third column for the cost of an extraction, not a build.
- **Candidate 3 stays a control, not a base.** `dlib-distance.md` already
  measured the web mirrors as an alternative source and found they almost never
  match where Dave's does not — 2 of 300. IBM's delivery level is worth the same
  treatment, and for the same reason: to know whether it is a lever, not because
  anyone expects it to be.

**So the choice is not made by argument.** The instrument that answered the
baseline question answers this one unchanged — same decks, same comparator, one
more column. Run it against all three source states and read the number.

## 3. The systems, and what each one is for

| system | mvsMF | Hercules | credentials | role |
|---|---|---|---|---|
| `MVSCE-DEV` | `:8080` | — | `IBMUSER`/`SYS1` | **tabu** — the user's own |
| `MVSCE-LAB` | `:8082` | — | `IBMUSER`/`SYS1` | the IFOX00 oracle that produced the 5,528 reference decks; build runs 1–4 |
| `MVSCE-EXP` | `:8083` | — | `IBMUSER`/`SYS1` | untouched MVS/CE reference — the control that says LAB was not mutated |
| `MVSTK5-REF` | `:8084` | `:8484` | `HERC01`/`CUL8TR` | **the object baseline. Read-only.** |
| `MVSTK5-BLD` | `:8085` | `:8585` | `HERC01`/`CUL8TR` | where Dave's build runs from here on |

`HERC01`/`CUL8TR` for TK5, `IBMUSER`/`SYS1` for MVS/CE — the wrong pair returns
401, and a 401 loop is indistinguishable from an outage from the outside.

**After every IPL: `/S HTTPD` and `/S FTPD`.**

## 4. Where the work stands

| | |
|---|---|
| `as370` == IFOX00 | 5,418 of 5,528 decks; `as370` alone flags 0 |
| Dave's source == shipped object (TK5) | 1,084 of 3,988 |
| Dave's build, run 4 | **stalled** at `EDM1102A JOB00809`; the driver died with its session |
| EREP macros still missing | 4 — `ENTRIES` `ETEPILOG` `FREETAB` `SUMMARY` |

Run 4 is not worth restarting on LAB. It was always going to move to
`MVSTK5-BLD`, and restarting it there costs the same and produces the thing the
next step needs.

## 5. The stages

### Stage 1 — is TK5's IFOX00 the same assembler? *(blocks stage 4, not stage 2)*

Every recorded figure is against **MVS/CE's** IFOX00, which is IBM's XF plus part
of Greg Price's `ZP60` family ([`ifox-lineage.md`](ifox-lineage.md)). TK5 carries
115 USERMODs against MVS/CE's 37, so the two assemblers may not be the same
program.

The cheap version has been asked: `BAS 14,TGT` assembles to `4DE0 F004` at
severity 0 on both, so `ZP60025` is applied on both. **One instruction is not an
assembler.** The real test is the corpus: run `tools/ifox_run.py` on
`MVSTK5-BLD` and compare the decks against the recorded 5,528.

- decks identical → the reference is not MVS/CE-specific, everything transfers;
- decks differ → the reference belongs to MVS/CE and re-baselining costs a full
  corpus run, exactly as [`erep-adoption.md`](erep-adoption.md) had to pay.

### Stage 2 — run Dave's build on `MVSTK5-BLD`

`tools/bldrun.py` with `HOST` pointed at `:8085`, from `$01SMPAL`. What run 4
learned carries over: SMPSCDS `DR=4500`, SMPPTS `1000`, `MSGCLASS=H`, purge the
spool before starting (`$HASP355 SPOOL VOLUMES ARE FULL` killed a run at job 41),
and the nine EREP macros staged.

Expect new failures: run 4's fixes were made against MVS/CE, and TK5 is a
different system. That is the point of running it.

### Stage 3 — `ZLMDRPTD` and `ZLMDRPTT` on `MVSTK5-BLD`

**This closes the original ask.** `ZLMDRPTD` compares the build's DLIBs against
the system's own DLIBs, and on `MVSTK5-BLD` those are TK5's — so it is the same
job that ran on 2026-09-09 ([`build-vs-original.md`](build-vs-original.md)),
against the baseline that was chosen today. `tools/lmdreport.py` already replaces
the two `PGM=SORT` steps TK5 also lacks.

Then, and only then, the two figures are comparable: 2,619 of 4,337 CSECTs
against MVS/CE, and whatever it is against TK5.

### Stage 4 — re-cut the reference against TK5

Depends on stage 1. If the assemblers agree, only the *right-hand* side moves and
the 5,528 decks stand.

### Stage 5 — the 459

**459 of the 515 divergent modules match neither system.** Concentrated in
`AOSU0` (94), `AOSD0` (77), `AOSA0` (75), `AOS20` (42). No baseline decision
moves them; they are the maintenance that never reached any source, and they are
the actual project.

## 6. Rules this Fahrplan carries forward

- **A source snapshot without its SMP state is unpinned.** Dave's design is an
  SMP-maintained tree ("SMP als Wartungsvehikel"), so "Dave's source" names a
  library *and* a SYSMOD list. Any measurement records both.
- **`MVSTK5-REF` is read-only.** Nothing is submitted to it, nothing allocated on
  it. Assembler probes go to `MVSTK5-BLD`.
- **Purge what you submit.** Four runs left 809 jobs on LAB's spool and the fifth
  died of it.
- **A new instrument needs a case with a known answer** before its first real
  number. Every measurement in this Fahrplan's basis has one, and each one caught
  something.
