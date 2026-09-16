# The documents, and which of them is current

Fifty-nine files accumulated in two weeks, most of them records of a single
measurement on a single day. That is deliberate — this project's rule is that
corrections stay visible and a number that moved four times says so — but it
leaves no way in. This page is the way in.

> ## ⚠️ The goal was reformulated on 2026-09-16, and it changes how to read
> everything below
>
> **Every module explained, as many as possible byte-identical, and a system that
> builds and runs from those sources.** There are now **two** measured verdicts —
> *recovered* (`cmplmd370` exits 0) and *explained* (every differing byte
> attributed to a named class, none left over). Both are machine-decidable; the
> second is not a softening.
>
> The reason: **five macros are measured to exist at two levels, with the split
> running per module** — `SCHEDULE`, `TSCBD`, `GETMAIN`/`FREEMAIN`, `SETFRR`,
> `XCTL`/`IHBINNRB`, 332 modules touched. IBM assembled over years against a macro
> library that moved between assemblies, so **no single macro library reproduces
> them all and no archive can supply one.** For some modules byte-identity is
> unreachable with any surviving material.
>
> **Every document written before 2026-09-16 assumes the single verdict.** That
> does not make it wrong — it makes its scope narrower than it reads.
> [`../README.md`](../README.md), [`macro-attribution.md`](macro-attribution.md).

**Read these five, in this order, and nothing else is needed to start:**

1. [`../README.md`](../README.md) — the goal and the two verdicts
2. [`../TODO.md`](../TODO.md) — *Start here tomorrow*, written as a handover
3. [`macro-attribution.md`](macro-attribution.md) — **where the remaining
   differences come from**: the two attribution maps, the five two-level macros,
   and the three reconstruction trials
4. [`fahrplan.md`](fahrplan.md) — the baseline decision and the five stages
5. [`runbook.md`](runbook.md) — anything that touches a running MVS

## How to read a date here

**Every document below is a measurement taken on a day, and says so in its first
lines.** None of them is maintained afterwards; a later document corrects an
earlier one, and the earlier one keeps its number so the correction stays
visible. So the date is not decoration — it is the statement's scope.

**Twelve carry a stale banner**, added 2026-09-16 after every one of the 59 was
audited against the current state. If a document has no banner it has now been
*checked* and found to hold — which is new; before that audit, no banner only
meant nobody had looked.

## The 2026-09-14 to 09-16 documents, and they carry the current picture

These four are the newest and the load-bearing ones. A reader coming back after a
break should treat them as the state of the project.

| | |
|---|---|
| [`macro-attribution.md`](macro-attribution.md) | **the map.** Where every differing byte comes from — macro expansion or open code — over both populations, plus the five two-level macros and the `GETMAIN`/`SETFRR`/`XCTL` reconstruction trials |
| [`sysparm.md`](sysparm.md) | `&SYSPARM` was empty in every assembly ever run here; supplying it per module recovers **111 modules**. `MODID` and `XCTLTABL` read it too and recover none |
| [`missing-macros.md`](missing-macros.md) | two kinds of missing: **absent** (the assembler says so) and **present at the wrong level** (nothing says so). The second kind is 332 modules and was not on the page until 09-16. Also: the VS2 3.7 starter tapes carry none of them |
| [`assembler-options.md`](assembler-options.md) | what IFOX00 accepts, what `as370` does with it, and the 09-16 finding that **the shipped object was never built by the customer SYSGEN** |

## Direction and plan

| | |
|---|---|
| [`fahrplan.md`](fahrplan.md) | **the current direction.** TK5 is the object baseline, and the five stages that follow. Corrected inline 09-11 in three places |
| [`workplan.md`](workplan.md) | 09-04, the founding plan. Superseded on the baseline question by `fahrplan.md`; its host-side method — extract, assemble, compare, everything machine-decidable — still governs |
| [`open-decisions.md`](open-decisions.md) | what needs Mike. Items 1–4 are decided; see the banner |
| [`kreiss-reply-2026-09-12.md`](kreiss-reply-2026-09-12.md) | **his answer, and it reverses two of our decisions.** Compare against TARGET not DLIB; `MAINT05Z` is required and is the likely cause of the `./ DELETE` failures |
| [`kreiss-project.md`](kreiss-project.md) | **what we are building on.** Dave Kreiss' project, his `DSK*` PTF scheme, and why his PTFs are not IBM's |
| [`dave-environment-plan.md`](dave-environment-plan.md) | how his environment gets built, and why that is not the current work |
| [`mail-kreiss-2026-09-12.md`](mail-kreiss-2026-09-12.md) | draft: status, the scoreboard, and the `./ DELETE` question |
| [`mail-kreiss-2026-09-13.md`](mail-kreiss-2026-09-13.md) | **draft, held — do not send as it stands.** Its figure is 1,491 and the current one is 1,608, and it asks about `ESTAE` alone where the ask is now five macros and 332 modules. Nothing goes to Dave until an earlier answer arrives (TODO.md) |

## The two instruments

The project measures two different things and they must never be quoted as one.

| | |
|---|---|
| [`ifox-oracle.md`](ifox-oracle.md) | **the oracle.** Every claim about what `as370` should do is checked against the real IFOX00, not against a manual. The recipe, the traps, and what it has settled |
| [`ifox-tree.md`](ifox-tree.md) | the tree-wide IFOX00 run — how the 5,528 reference decks were cut |
| [`regression-gate.md`](regression-gate.md) | **re-testing an `as370` change.** The gate, the promote sequence, and its traps. Ten minutes on the host, no MVS |
| [`complmd-spec.md`](complmd-spec.md) | `COMPLMD` read as the specification for `cmplmd370` |
| [`what-is-left.md`](what-is-left.md) | **superseded as the map, 09-16.** Its figures stop at 09-13 and it knows neither the five two-level macros nor `&SYSPARM`. Read [`macro-attribution.md`](macro-attribution.md) instead; keep this for its dated history |
| [`overlay.md`](overlay.md) | **`src/` means finished and had 3 modules that were not; nothing measured it until now.** Our repairs are +33, and one was made against the superseded baseline |
| [`tso-and-smp.md`](tso-and-smp.md) | **the two components Mike prioritises**, profiled. TSO 44 of 228, SMP 19 of 109, zero tool cases in either, and SMP's 82 same-length differences are the most tractable block found so far |
| [`ds-holes.md`](ds-holes.md) | **a class of 495 modules that was labelled "cannot be our fault", refuted.** The two object baselines agree on the hole bytes 309 times out of 309 |
| [`lpalib.md`](lpalib.md) | **the largest and reddest library, sorted by mechanism.** 93 % of it carries no `DSK` marker — it was never reached, not failed |

## The assembler question — is `as370` right?

| | |
|---|---|
| [`as370-gaps.md`](as370-gaps.md) | the gaps, and what closing each was worth |
| [`cc370-cases.md`](cc370-cases.md) | cases handed to cc370, in the order they pay |
| [`ifox-objections.md`](ifox-objections.md) | why IFOX00 was not content, and how that limits the reference |
| [`silent-divergences.md`](silent-divergences.md) | both assemblers clean, object different — the class only this comparison can see |
| [`assembler-options.md`](assembler-options.md) | IFOX00's options and what `as370` does with them |
| [`opencode-gate.md`](opencode-gate.md) | the gate on cc370's open-code branch |
| [`parity-by-commit.md`](parity-by-commit.md) | parity re-derived across three cc370 commits, one macro path |

## Which IFOX00, and which macros

| | |
|---|---|
| [`ifox-lineage.md`](ifox-lineage.md) | three Assembler XF lineages, none merged |
| [`ifox-tk5-vs-ce.md`](ifox-tk5-vs-ce.md) | is TK5's IFOX00 the same assembler? — fahrplan stage 1 |
| [`ifox-gorlinsky.md`](ifox-gorlinsky.md) | Paul Gorlinsky's IFOX00 source against ours |
| [`macro-tk5-vs-ce.md`](macro-tk5-vs-ce.md) | **93 % of the macro surface is identical, and the residue moves 68 modules.** The reason stage 1 must carry MVS/CE's macros across |
| [`macro-path.md`](macro-path.md) | **`gate.sh` decides the `-I` path and eight tools had drifted from it.** 33 EREP decks differ between the two paths; the short one starves them |
| [`macro-collisions.md`](macro-collisions.md) | the ten places where `-I` order decides what gets assembled |
| [`missing-macros.md`](missing-macros.md) | **two kinds of missing.** The 40 operations neither assembler can resolve, and — since the 09-16 rewrite — the nine macros that are *present at the wrong level*, emit different bytes than IBM shipped and flag nothing. The second kind touches **332 modules** |
| [`private-macros.md`](private-macros.md) | the private macros, and what they are worth |
| [`igc018-macro-path.md`](igc018-macro-path.md) | one identity lost to macro path order, not to the assembler |

## Which object baseline, and which source

| | |
|---|---|
| [`deck-vs-tk5-ce.md`](deck-vs-tk5-ce.md) | **the measurement that chose TK5.** 15 to 1 where both systems carry maintenance |
| [`baseline-dlib-vs-target.md`](baseline-dlib-vs-target.md) | **the measurement that answers Dave's reversal.** DLIB 1,236, target 1,069, both 1,052 — and 23 of Mike's TSO modules are recovered against the back-level copy |
| [`baseline-gate-predictions.md`](baseline-gate-predictions.md) | the seven predictions that gate wrote down first. **Never edited, by design** |
| [`two-baselines-as-a-control.md`](two-baselines-as-a-control.md) | **the second baseline is a control on option A, and 99 of `IKJEGMSG`'s 100 transcribed bytes were noise.** What `fillgaps.py`'s guard could never see |
| [`dlib-distance-tk5-ce.md`](dlib-distance-tk5-ce.md) | how far apart the two object bases are; neither is a superset |
| [`maintenance-level.md`](maintenance-level.md) | **what level TK5's DLIBs actually carry.** 98.1 % at 1985 or earlier, and a 76-module tail to 1990 that is 43 % TSO |
| [`dlib-distance.md`](dlib-distance.md) | how far Dave's source is from the object — and the IDR route to a per-module maintenance level |
| [`smp-tk5-vs-ce.md`](smp-tk5-vs-ce.md) | SMP inventory, TK5 against MVS/CE |
| [`tk5-ptfs-and-usermods.md`](tk5-ptfs-and-usermods.md) | what TK5 carries that MVS/CE does not |
| [`accept-status.md`](accept-status.md) | was the maintenance ACCEPTed into the distribution libraries? |
| [`archive-vs-system-source.md`](archive-vs-system-source.md) | Dave's archived source against what his own build left behind — **the two states are not equal** |
| [`source-states.md`](source-states.md) | **and which of those two states reaches TK5's object.** The −8 turns out to be run 6 stopping at the phase-1 boundary: 619 of 1,357 `DSK`-marked modules are not in the system's source at all |
| [`module-origin.md`](module-origin.md) | where each module comes from |
| [`mvssrc-source-hunt.md`](mvssrc-source-hunt.md) | where the 236 `MVSSRC.*` source libraries come from |
| [`src-volumes-vs-corpus.md`](src-volumes-vs-corpus.md) | the source volumes the build reads, against our corpus |
| [`tree-wide-run.md`](tree-wide-run.md) | the first tree-wide run |
| [`what-is-not-blocked.md`](what-is-not-blocked.md) | what does not wait on Dave Kreiss' tape |

## Dave Kreiss' build

| | |
|---|---|
| [`dave-install-log.md`](dave-install-log.md) | the install log, run by run, with every failure explained |
| [`run6-predictions.md`](run6-predictions.md) | run 6 predicted before it ran, then its result. **Never edited, by design** |
| [`build-vs-original-tk5.md`](build-vs-original-tk5.md) | **the comparison the project exists to make**, on TK5. Run 5 and run 6 side by side |
| [`build-vs-original.md`](build-vs-original.md) | the same on MVS/CE, 09-09 |
| [`erep-adoption.md`](erep-adoption.md) | adopting the EREP macros on both sides |

## Operations

| | |
|---|---|
| [`runbook.md`](runbook.md) | **how things actually work.** Read before anything touches a running MVS |
| [`../tools/scoreboard.py`](../tools/scoreboard.py) | regenerates the scoreboard at the head of the README. **Run it after every build comparison**; `--check` fails if it is stale |
| [`../tools/systems.json`](../tools/systems.json) | which instance may be submitted to, and which is the oracle. Machine-readable, and its comments explain why |
