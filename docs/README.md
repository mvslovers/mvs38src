# The documents, and which of them is current

Forty-odd files accumulated in a week, most of them records of a single
measurement on a single day. That is deliberate — this project's rule is that
corrections stay visible and a number that moved four times says so — but it
leaves no way in. This page is the way in.

**Read these four, in this order, and nothing else is needed to start:**

1. [`../README.md`](../README.md) — the goal: MVS 3.8j at maintenance level
   8505, from source, measured against TK5's distribution libraries
2. [`../TODO.md`](../TODO.md) — *Start here tomorrow*, written as a handover
3. [`fahrplan.md`](fahrplan.md) — the baseline decision and the five stages
4. [`runbook.md`](runbook.md) — anything that touches a running MVS

## How to read a date here

**Every document below is a measurement taken on a day, and says so in its first
lines.** None of them is maintained afterwards; a later document corrects an
earlier one, and the earlier one keeps its number so the correction stays
visible. So the date is not decoration — it is the statement's scope.

Three were overtaken within hours of being written and now carry a banner
saying so: [`fahrplan.md`](fahrplan.md), [`open-decisions.md`](open-decisions.md)
and [`build-vs-original-tk5.md`](build-vs-original-tk5.md). If a document has no
banner, that means nobody has *found* it to be stale — not that it is current.

## Direction and plan

| | |
|---|---|
| [`fahrplan.md`](fahrplan.md) | **the current direction.** TK5 is the object baseline, and the five stages that follow. Corrected inline 09-11 in three places |
| [`workplan.md`](workplan.md) | 09-04, the founding plan. Superseded on the baseline question by `fahrplan.md`; its host-side method — extract, assemble, compare, everything machine-decidable — still governs |
| [`open-decisions.md`](open-decisions.md) | what needs Mike. Items 1–4 are decided; see the banner |
| [`kreiss-project.md`](kreiss-project.md) | **what we are building on.** Dave Kreiss' project, his `DSK*` PTF scheme, and why his PTFs are not IBM's |
| [`dave-environment-plan.md`](dave-environment-plan.md) | how his environment gets built, and why that is not the current work |
| [`mail-kreiss-2026-09-12.md`](mail-kreiss-2026-09-12.md) | draft: status, the scoreboard, and the `./ DELETE` question |

## The two instruments

The project measures two different things and they must never be quoted as one.

| | |
|---|---|
| [`ifox-oracle.md`](ifox-oracle.md) | **the oracle.** Every claim about what `as370` should do is checked against the real IFOX00, not against a manual. The recipe, the traps, and what it has settled |
| [`ifox-tree.md`](ifox-tree.md) | the tree-wide IFOX00 run — how the 5,528 reference decks were cut |
| [`regression-gate.md`](regression-gate.md) | **re-testing an `as370` change.** The gate, the promote sequence, and its traps. Ten minutes on the host, no MVS |
| [`complmd-spec.md`](complmd-spec.md) | `COMPLMD` read as the specification for `cmplmd370` |
| [`what-is-left.md`](what-is-left.md) | the map of what still differs, by block and by mechanism |

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
| [`macro-collisions.md`](macro-collisions.md) | the ten places where `-I` order decides what gets assembled |
| [`missing-macros.md`](missing-macros.md) | the 40 operations neither assembler can resolve, and where each has been hunted |
| [`private-macros.md`](private-macros.md) | the private macros, and what they are worth |
| [`igc018-macro-path.md`](igc018-macro-path.md) | one identity lost to macro path order, not to the assembler |

## Which object baseline, and which source

| | |
|---|---|
| [`deck-vs-tk5-ce.md`](deck-vs-tk5-ce.md) | **the measurement that chose TK5.** 15 to 1 where both systems carry maintenance |
| [`dlib-distance-tk5-ce.md`](dlib-distance-tk5-ce.md) | how far apart the two object bases are; neither is a superset |
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
