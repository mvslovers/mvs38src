# TODO — MVS 3.8j source recovery

The working list for [`docs/workplan.md`](docs/workplan.md). The plan says *why*
and *where to*; this list says *what next*.

> ⚠️ **Every count below carries the cc370 commit it was derived against, and the
> commit alone is not enough** — check the distance before quoting it:
>
> ```sh
> git -C ~/repos/mvs/cc370 rev-list --count <that-commit>..main
> ```
>
> The handover block below read *3,466 of 5,528, 62.7 %* until 2026-09-09. That
> was the founding measurement at `ee1090b`, **distance 130**, and it had stood in
> the "where the project stands" position for two days while the real figure went
> past 97 %. Dated entries further down are history and keep their own numbers.

**Key:** 🔒 blocks other work · ⚡ runs in parallel, blocks nothing ·
🚪 gate: the outcome decides how we proceed

---

## Start here tomorrow

*Written as a handover: a fresh session should be able to start from this section
alone. Last rewritten **2026-09-14, morning**.
Everything below the History heading is dated and keeps its own numbers.*

### The goal

**MVS 3.8j at maintenance level 8505, built from source.** One question, module by
module: **which sources do not yet assemble to the object IBM shipped?**
`cmplmd370` exits 0 or it does not.

`8505` is **measured**: the IDR records in all 3,988 DLIB members were read and
**98.1 % carry a link date of 1985 or earlier**, with a 76-module tail to 1990 that
is 43 % TSO ([`docs/maintenance-level.md`](docs/maintenance-level.md)).

The scoreboard at the head of [`README.md`](README.md) is **generated** —
`tools/scoreboard.py`, `--check` fails when it is stale. Never hand-edit it.

**And since 2026-09-16 `--check` also reads the two derivable figures out of the
*"Where it stands"* table below** — `recovered` and `explained` — and fails naming
both values when they disagree with the tools. It was added because that table
carried `explained = 1,724` for an evening after the figure had dropped to 1,719,
in the section a fresh session reads first, with nothing watching it. It checks
only what it can derive; every other number in this file is prose that no tool
reads, and a `--check` failure naming `TODO.md` means that table and nothing
else.

### 🔑 218 modules diverge first at byte 0, and the cause is the eyecatcher — 2026-09-17

**The first shared cause found in the length-differing block, and the largest
family this project has measured.**
[`work/measurements/divergence/eyecatcher.tsv`](work/measurements/divergence/eyecatcher.tsv).

The anchor report prints both sides at every failed anchor. Re-run keeping the
bytes and grouped by `(ours, IBM's)` — the move that found `IGGCP14` and the
`×`/`|` class over 47 modules — this time over **185,385 divergence points in
2,292 modules**:

```
104 modules, ALL at offset 0x000000, identical pair:
   ours 47F0F016 = B 22(,15)        IBM 47F0F01E = B 30(,15)
```

The branch over the eyecatcher at a PL/S module's entry. **IBM's is eight bytes
longer**, and what is in them is maintenance identification our source never
received — per module, not shared:

| | ours | IBM |
|---|---|---|
| `ICBMSG05` | `'ICBMSG05  78.188'` | `'ICBMSG05 01/11/85'` + more |
| `AMDPRCVT` | `'AMDPRCVT  76.189'` | `'AMDPRCVT 78215  UZ86400'` |

`UZ86400` is a PTF number, the shape `MODID` turned up as `UZ61918` and
`UY35469` ([`sysparm.md`](docs/sysparm.md)). Ours declares `DC AL1(16)`; IBM's
declares 25. Widened to the **form** — any branch-over-eyecatcher at offset 0
whose target differs — it is **218 modules, 80 % of the 274 that diverge first at
byte 0**.

⚠️ **It is a FORM, not a family, and "the +8 family" is how both sessions were
saying it.** The file has **24 distinct deltas spanning −8 to +170**, and `+8`
covers 119 of 218 — **55 %, just over half**:

```
-8 × 2   -4 × 2   -2 × 18   +2 × 2   +4 × 6   +6 × 24   +8 × 119
+10 × 5  +12 × 2  +14 × 2  +16 × 16  +18 × 4  +20 × 3
singletons: +24  +28 × 3  +32  +34  +36  +40  +42  +48  +78  +134  +170
```

An expectation keyed on `+8` scores 99 working modules as failures, and the three
at `+78`, `+134` and `+170` are where an unclassified shift would be most plainly
wrong and least likely to be looked for.

⚠️ **The delta is SIGNED and the description "IBM's is longer" is wrong for 22 of
them**: `+8` × 119, `+6` × 24, `+16` × 16, `+4` × 6 … and **`−2` × 18, `−4` × 2,
`−8` × 2** (`IGG019DD`, `IKTIOFRR`). For those 22 **ours is longer and IBM's
shorter** — our source carries something IBM's object does not, which is a
different repair entirely. Caught by the cc370 session reading the file after
this session had summarised it without the sign.

⚠️ **It is not a recovery.** Median 148 divergence points per module, minimum 5,
and **zero of the 104 have only this one**. Repairing the eyecatcher recovers
nothing by itself.

**It is a shared FIRST cause**, and the value is the mechanism that has paid three
times now: everything after byte 0 is shifted by the same amount, `cmplmd370`
pairs nothing while lengths differ, and removing the shift makes the rest
visible. That is how `&SYSPARM` went from invisible to 111 recovered and how the
reader fix went from 143 unreadable to 2.

**And it is `cc370#384`'s acceptance set**, which is what it is worth most as.
218 modules with a known cause, at a known offset, of a known size, each carrying
~148 divergences: **a module whose classifier reports ~148 constant changes has
failed; one reporting a handful has worked, and the handful is the finding.** The
22 negatives are the only thing in the set that exercises the deletion path.

**The next measurement, not yet run**: give one of the 104 IBM's longer eyecatcher
and see what survives. That tests this section's own claim — that the 148 are
consequences rather than 148 causes.

### 🔑 1,878 of 2,292 length-differing modules now have a located divergence point

**The length block is 41.7 % of the corpus and the largest single thing between
this project and its goal. This morning 909 of it had a number saying where the
divergence starts. Tonight 1,878 do.**
[`work/measurements/divergence/first-divergence.tsv`](work/measurements/divergence/first-divergence.tsv).

`dasm370 --derive-hints` assembles **our** outdated source, writes out what the
assembly found — labels, and base registers with the lifetimes `--usings` gave
them — and applies it to **IBM's** object. Where our source has already diverged,
a derived expectation fails, and `--anchors=report` prints the offset. That
offset is where the two part company.

| | |
|---|---:|
| anchor offsets | 1,664 |
| `seclocate.py` offsets | 909 |
| **union** | **1,878 of 2,292 — 82 %** |
| only the anchor reaches | 969 |
| only `seclocate` reaches | 214 |

**They overlap on 695 and agree exactly on 7 % of those, and that is not a
disagreement.** They measure different quantities: `seclocate` locates the first
**length-changing** run by text-anchoring in the bound member; an anchor locates
the first **byte** where a derived expectation fails, which includes
substitutions and exists only where a label does. Hence the median +15 — anchors
fire a little after the true first divergence, because they sit at labels. The
gain is the coverage, not the precision.

**Why this matters more than the number**: `IEBWSAM` cost a person a hand-decode
of fourteen bytes to answer *"does this continue the preceding code"* for **one**
module. This is the same question answered mechanically for 1,878.

⚠️ **It is a starting offset, not an explanation.** A module with a divergence
point at `0x54` is a module somebody still has to read. And the population is not
closed: 510 refuse because our own source does not assemble (`rc0 = 4,699 of
5,538` — correct refusals, not defects), 100 report no failed anchor at all, and
18 refuse on an anchor landing inside a relocatable field.

**The measurement took two attempts and the first one was broken in a way no
fixture could show.** `--derive-hints` shipped refusing where it should have
reported: 404 `base outside section` — which is the length-differing population's
*defining property*, our section and IBM's are different lengths — and 158 label
collisions, which are themselves divergence reports. **Every one of those 634
refusals was correct in its own case and they were a broken measurement in
aggregate.** Nothing but running the mode over the whole population could see it;
the fixtures were green throughout. cc370#400 made `--anchors=report` mean report
for every detector, and 616 of the 634 became measurements.

🔑 **That is the transferable lesson and it is worth more than the 1,878: a new
mode must meet the population, not only its fixture.**

### `--infer` reaches the 772 now, and 606 of them carry a question list

**Fixed and merged — cc370#401, and #382 closed with it.** The cause was a `goto`:
the bound-member path jumped past the `--infer` block and produced **an ordinary
disassembly**, which is well-formed, plausible, and silently answers a different
question. Our 648-of-648 was that.

```
30 control CSECTs      our deck 374   DLIB member 374   equal in 30/30
772 no-source CSECTs   772 ran, 606 with candidates, 5,126 candidates
   pattern   4,690  91 %      prologue  408  8 %      rld  28  1 %
```

**606 of the 772 now carry a list of base-register questions.** The 4,690
`pattern` lines are the honest half — a register the code addresses through whose
origin nothing explains — and that is exactly what a reader of a module with no
source needs. `rld`, the only kind with ground truth in the object, fires **28
times in 5,126**.

⚠️ **`prologue` cannot be made reliable and the reason is not a defect.**
Measured against the real `USING` events on the 30: 25 of 28 agree, 3 do not, and
all three are one limit — **`BALR Rn,0` is a run-time fact and `USING` is an
assembly-time declaration; the object records the first and cannot record the
second.**

- `IGG08113` hand-codes the displacement (`B 32(,R15)`), so no `USING` was ever
  needed — the same bytes either way.
- `IECVERPL` establishes R10 twice and the second has no `USING` beside it, so
  the assembly resolved everything against R10 = 0 throughout. **True about the
  code, false as a hint.**
- `ICKTR02` is **data**: `A001188 DC F'01296'`, and decimal 1296 is
  `X'00000510'`, whose low half reads as `BALR 1,0`. The reported value `X'118C'`
  is the `V(ICKTP05)` that follows it.

It is stated in cc370's source, in the emitted file's header and in its man page
rather than covered by an accuracy figure.

### The chain of four correct-looking readings, and it is the day in one artefact

`ICKTR02` took four steps and **nobody held a wrong measurement at any point**:

1. the tool reported `value=0x118C` — true about the bytes;
2. this session read it as a guard failure on a `BALR R1,R15` at source line 31 —
   plausible source, wrong line, and **the candidate had printed its own offset**;
3. cc370 checked its guard instead of changing it, and refuted the diagnosis:
   `BALR 1,15` is `X'051F'`, so `0x1F & 0xF` never reaches the prologue branch;
4. this session then read the offset from step 1 and found the constant.

🔑 **So the rule gets its amendment**: *send the case, not the diagnosis* becomes
**send both, and label which is which.** A labelled diagnosis can be checked
against its own evidence and discarded without losing the measurement — which is
what happened here in both directions on the same day, cc370's scatter mechanism
in the afternoon and this session's `BALR` reading at night. The corollary cc370
added and this file should carry: **check a diagnosis before acting on it, even a
good one — being right most of the time is exactly what makes the exception
expensive.**

### 🔑 `dasm370` rebuilds 66 modules that have no source — 2026-09-16, evening

**The first source this project has produced for modules where none existed.**
cc370 #388, #389 and #390 landed; the acceptance was run **here**, with our
pinned `as370-main` and `cmplmd370` and the per-module stamp from
`asmparams.py`, rather than taken from the other session:

| | |
|---|---:|
| the 30-module decoder control, deck path | **30 / 30** |
| the same with `--no-clearrld` | **30 / 30** |
| **the 66 `IKJ` no-source CSECTs, member path** | **66 / 66** |
| the same with `--no-clearrld` | 46 / 66 — the expected shape; bound adcons are resolved |

Both corpora are ours and both are committed —
`work/measurements/dasm370-decoder-control.tsv` and `…/dasm370-stage1a.tsv`.
[`docs/dasm370-interface.md`](docs/dasm370-interface.md) carries which question
each answers, and they are **not interchangeable**: a `dec` field with `BE` and
`BZ` swapped prints the wrong mnemonic and still round-trips byte-identically, so
only the 30 — where a second witness exists — can contradict a wrong but
self-consistent reading.

⚠️ **The scoreboard does not move and must not.** A module that round-trips is one
we can **rebuild**, not one whose source we can claim is IBM's. `recovered` stays
**1,626** and `explained` **1,719**. This is Fahrplan stage 7 reaching its first
measurable result, not a recovery.

⚠️ **And it is 66, not 772.** The 66 are the `IKJ` subset chosen for being code
rather than text and 64–1023 bytes. Still outside: 19 parse/PCL tables where an
opcode subset will not stop text decoding as `L`/`LA`/`ST`/`BC`, 23 modules of
1 KB or more, 19 stubs — and the other prefixes entirely.

**`SRP` has exactly one witness in the whole identical population** (`IGCFR10D`),
so coverage is reported per format: a regression there is total loss of coverage
for that shape, not one line in thirty.

### The failure shape that ran seven times in one day, across two sessions

Worth its own heading because it is not an anecdote and it is not about either
session being careless. Seven instances on 2026-09-16, ours and theirs:

| | |
|---|---|
| a right number with an **unrecorded precondition** | `IGG019Q1`'s `03250000`, marked `DERIVED-UNPROVEN` |
| a right number inside a **stale sentence** | `scoreboard.py`: *"the cheapest 0 modules on the board"* |
| a right lookup asked a **question it cannot answer** | `MA.owner` on a region with no emitting row |
| a **line-by-line diff** conflating ordering with content | our ESD comparison of dasm370's output |
| a regex matching **file370's filename line** | our "RLD differs in 28" |
| **EBCDIC blanks read as numbers** — `0x404040` | our raw END parse, against a warning already in this file |
| a regex reading **columns 73–80** as data | theirs: `37 of 37 outside` where the answer is `37 of 37 inside` |

**Every one was found by the other side's instrument.** In most of them the side
that made the error had already written down the rule that would have caught it —
the EBCDIC-blank warning is in this file's own control list, and the seventh
happened half an hour after its author wrote the previous six into a memory.

🔑 **So it is not a knowledge problem and not an attention problem. It is a
position problem: an instrument cannot check the assumption it was built on, and
only one built on a different assumption can.** That is why *send the case, not
the diagnosis* works in both directions, and it is the argument for the
two-session arrangement rather than a story about one day.

The practical form, which is the same lesson `DC 0D pads at most 7 bytes` had:
**derive a count, never write one down.** A number in a document is an assumption
with no instrument behind it.

### The reader adoption — 2026-09-16, and the +18 is now counted

cc370#375 fixed `cmplmd370`'s load-module reader. It was accepted the way this
project accepts a cc370 change — a tree-wide run, three controls at 0/0 — and the
whole chain has been run: comparator re-pinned, gate re-cut, scoreboard
regenerated, every attribution map rebuilt.
Full account: [`work/measurements/cmplmd-reader/`](work/measurements/cmplmd-reader/).

| | before | after |
|---|---:|---:|
| **recovered** | 1,608 | **1,626** |
| **explained** | 1,700 | **1,724** |
| target member not paired | 143 | **2** |
| equal-length differing CSECTs — `macroattr`'s population | 988 | **1,044** |
| within 64 bytes — `lenlist`'s reach | 1,221 | **1,222** |
| alignment fill only | 44 | **49** |
| per-module macro path is worth (`reachable`) | 1,629 | **1,647** |

**+18 / −0 as sets**, and no `identical → anything` transition in either
direction — so nothing that was recovered stopped being recovered.

**What the newly comparable modules did to the maps.** 123 modules entered a
state the maps could see for the first time (61 `len-differs`, 50 `differs`, 12
`holes`), and the partitions moved accordingly:

| | before | after |
|---|---:|---:|
| equal length, every differing byte in **open code** | 605 | **607** |
| equal length, mixed | 293 | **301** |
| equal length, all inside macro expansions | 90 | 90 |
| length block, every length-changing run in open code | 361 | **374** |
| length block, mixed | 474 | **460** |
| length block, all in macro expansions | 77 | 75 |
| length block, not anchored | 281 | 288 |

**`macroattr`'s top owners barely moved and that is the useful part** — `WTO` 49,
`MODID` 48, `XCTLTABL` 43, `HMASMMGP` 37, `FREEMAIN` 34, `XCTL` 31, `IEDHJN` 29,
`SETFRR` 28. The wall is the same wall; it just has 56 more modules in front of
it.

⚠️ **The pin names `c5f3d07`, not the commit that was measured**, and the reason
belongs here rather than only in `PROVENANCE.txt`: **`63f372f` was merged with a
red gcc job.** The measurement had been checked exhaustively and `gh pr checks`
was never run. cc370#377 fixed it — an error-message buffer gcc can prove too
small under `_FORTIFY_SOURCE`, which macOS clang cannot see — and the binary
built from the fixed commit is **set-identical** to the measured one, 0/0,
`chosen = 1,626` both ways. **Read the checks before merging, not only the
measurement.**

⚠️ **And a generated number can sit inside a stale sentence.** With `unread` down
to 2 and `unread_dlib_ok` to 0, `scoreboard.py`'s template went on calling them
*"the cheapest 0 modules on the board"* and still blamed *"the
overlay-structured load modules"*, which the fixed reader handles. Every figure
in it was correct. **`--check` passes on that**, because it compares the README
against the tool and both agreed. The template now branches; the class does not
go away.

**One tool was reaching into a dead session.** `reachable.py` read the three
reconstruction-trial gates by absolute path out of *one session's scratchpad* —
nothing re-cuts them, no clone has them, and they vanish when the session ends.
Moved to `work/measurements/macro-reconstruct/`, with the deck directories named
beside them so the next re-pin can re-cut all four with one command each.

**Still stale, named rather than fixed**: `worklist.py` defaults to `--decks
obj_overlay5`, which is older than the `obj_overlay12` TODO already flagged as
two generations behind — `decks.py` exists precisely for this and `worklist.py`
does not ask it. `worklist.txt` and `worklist16.txt` were not re-cut, so they
rank against a comparator and a deck set that are both superseded.

### Where it stands, 2026-09-16 evening

| | |
|---|---:|
| **under the chosen baseline — target, DLIB where no target exists** | **1,626 of 5,353 — 30.4 %** |
| **explained — the second verdict** | **1,719 — 32.1 %** |
| the same decks against the DLIB alone | 1,633 |
| against the target alone | 1,476 |
| against both | 1,451 |
| target member not paired — was 143 | **2** |

⚠️ **1,719 and not the 1,724 this table said until it was re-read.** The figure
dropped by five when `alignfill.py`'s guard was added the same evening — it had
been counting five modules as explained that nothing explained. A number that
moves DOWN on a correction is the healthy direction; a number that stays up in
the handover while the tool says otherwise is the failure this file spent the day
documenting. **`scoreboard.py --check` could not catch it** — it compared README
against the tool and never the prose above it — **which is why it does now.** The
two derivable figures in this table are checked, and a `--check` failure naming
`TODO.md` means one of them disagrees with the tools. The rest of this file is
still prose no instrument reads.

**The +18 came from the instrument, not from source work.** cc370#375 fixed
`cmplmd370`'s load-module reader; the comparator is re-pinned and everything
downstream re-cut. See *"The reader adoption"* below. `src/` is unchanged at 316
and `srccheck.py` still passes.

### Where it stood, 2026-09-14 morning — kept for the delta

| | |
|---|---:|
| **under the chosen baseline — target, DLIB where no target exists** | **1,602 of 5,353 — 29.9 %** |
| the same decks against the DLIB alone | 1,626 |
| against the target alone | 1,451 |
| against both | 1,426 |
| archive source, no repairs, against the DLIB | **stale — re-run with `SYSPARMS`** |
| `src/` — finished, guarded by `srccheck.py` | **310 modules** |
| `as370` == IFOX00 (a TOOL figure, not a project figure) | 5,471 of 5,528 |

**1,491 the evening before.** The whole of the +111 is one cause:
[`docs/sysparm.md`](docs/sysparm.md).

> ⚠️ **`scoreboard.py --check` only checks README against the tool.** Its *input*
> can be stale, and it was for hours on 2026-09-13: `fillgaps.py` deposits to
> `src/` the moment `cmplmd370` exits 0, so **re-run `gate.sh` and
> `baseline_gate.py` after a sweep, not after the commit that describes it.**
>
> ⚠️ **And a stale deck directory is not a comparison base.** Diffing the 2026-09-14
> run against `obj_overlay12` showed 118 decks moved where 110 were expected; the
> eight extra were `src/` repairs deposited at 20:45 while those decks were cut at
> 18:21. **Cut the control run yourself, with the one variable switched off** —
> here `SYSPARMS=/dev/null`, which reproduced `rc0=4590` and `chosen=1491` exactly.

### ✅ Decided 2026-09-16: disassembled code does NOT go into `src/` by itself

**Mike:** *"Rein disassemblierter Code sollte nicht nach `src/` wandern. Jedenfalls
nicht automatisch. Wir haben in den meisten Fällen alte Sourcen mit PL/S-
Kommentaren. Diese sollten mit Hilfe des disassemblierten Codes so bearbeitet
werden, dass das Resultat passt."*

**So a disassembly is an instrument for repairing the source we have, not a
source of new source.** That resolves the question this file recorded as open a
few hours earlier, and it resolves it in the direction that keeps the figures
meaning what they say: `recovered` stays *source that assembles to IBM's object*,
never *source we produced from the object*.

**The reason is the one no measurement would have found.** The surviving sources
carry **PL/S comments** — statement ids, APAR markers, the original structure and
its intent. A disassembly reconstructs bytes and can reconstruct nothing of that,
and it never will. Depositing it would trade something irreplaceable for
something we can regenerate at any time.

**What this changes about the tools, and it is not small.** If disassembly exists
to *edit existing source until the result matches*, then for the 2,292
length-differing and 1,044 equal-length CSECTs the criterion is **readability
against our own source**, not round-trip fidelity. That raises
[`cc370#384`](https://github.com/mvslovers/cc370/issues/384) — `--align-diff`,
both sides disassembled, differences classified as insertion / deletion /
displacement shift / constant change — above #383 in value for this project,
because #384 is the one that says *what to change in the source we are keeping*.
#383 governs how much of a module decodes at all, which matters most where there
is no source to edit.

**The named exception is answered too, in the same breath.** Mike: *"Es wird auch
Fälle geben, wo es keinen alten Quellcode gibt, dann wandert natürlich das
disassembly nach `src/`. Es soll halt nur nicht automatisch passieren."* So for a
CSECT with no old source the disassembly **does** become the source — **by hand,
never by a tool exiting 0**. The rule is not *"disassembly stays out"*; it is
*"an existing source is repaired rather than replaced, and nothing enters `src/`
unattended"*.

⚠️ **And `dasm370` is not only ours.** Mike: *"dasm370 wird später auch von
anderen benutzt, die nicht wie wir Quellen haben."* That is a constraint on the
tool rather than on us, and it cuts against the reordering above: for a user with
no sources at all there is nothing to repair, the no-source path is the *whole*
product, and **#383's reachability is what decides whether the output is readable
at all**. So #384 first is right for this project and #383 must not be
deprioritised into never — it is the half that serves everyone who is not us.

**"Not automatically"** is the other half and it is a process rule: nothing
deposits into `src/` off the back of a round trip exiting 0. `fillgaps.py` already
deposits the moment `cmplmd370` exits 0 — that mechanism must never be pointed at
disassembler output.

### Decided, do not re-open

1. **The object baseline is TK5** (2026-09-10), **and within TK5 the TARGET
   library, with the DLIB where a CSECT has no target counterpart** — Mike,
   2026-09-13, on [`docs/baseline-dlib-vs-target.md`](docs/baseline-dlib-vs-target.md).
   The two baselines disagree about 55 modules of the 4,371 that have a member in
   both. Named cost, in `fahrplan.md` §1: the target is TK5's *running* system, so
   up to 49 USERMOD-changed modules enter a measurement the DLIB kept out.
   **Unmeasured: how many of the 55 are TK5 USERMODs rather than IBM service.**
2. **`src/` means finished.** `srccheck.py` asserts every module there is identical
   to **at least one** baseline and prints which. Where IBM's two libraries hold
   different bytes no source can reach both, so deleting a file that is correct
   against a real IBM object would put nothing in its place; the *count* carries
   that fact, not the tree.
3. **Option A, Dave's way** — bytes with no rule behind them are transcribed from
   the object and marked `!!! SOURCE COMPARE FIX !!!` in columns 46–71.
4. **Priority: TSO first, SMP second.**
5. **A per-module macro path is agreed in principle — and waits for Dave's macro
   libraries** — Mike, 2026-09-14. The mechanism is the one `ASMDATES` and
   `SYSPARMS` already use: a `module<TAB>…` table read by `gate-worker.sh`,
   applied per module, never global.

   **What is NOT agreed is filling it with variants we construct ourselves.** The
   `TSCBD` case would need exactly one invented line — `SCBCTLUN EQU X'01'`, a
   value that stands in **no surviving copy of the macro** — and that is nearer to
   option A than to `ASMDATE`, because a macro is third-party source material and
   `SYSPARM` is an assembler option that leaves the source untouched. Dave's
   libraries may hold the *real* second `TSCBD`, and an override carrying a real
   macro is a different object from one carrying a derived line.

   So: **build the mechanism when there is a real macro to put in it, not before.**
   Until then the modules stay blocked and are counted as blocked — not as
   "waiting on a tool". ≥24 modules, two of them (`IGE0104G`, `IGE0304G`) **one
   byte** from identical.

### What 2026-09-14 established

**`&SYSPARM` was empty in every assembly this project has ever run, and it emits
bytes.** `IEDHJN`, TCAM's module-identifier macro, is called by 436 of our
sources and does `DC X'&SYSPARM'(1,4)`. With no `SYSPARM` that flags `IFO117` +
`IFO178` and emits **nothing**, so the CSECT comes out 2 or 4 bytes short and
`cmplmd370` reports a length difference with no clusters at all.

**111 of the 436 are byte-identical the moment IBM's own `SYSPARM` is supplied.**
No source change, no marker, nothing deposited in `src/` — the `ASMDATE` class,
one size larger. `gate.sh` reads `SYSPARMS` per module now, exactly as it reads
`ASMDATES`. Acceptance test: **+111 / −0**, as sets.
Full account in [`docs/sysparm.md`](docs/sysparm.md).

- **It was not a `cc370` case.** `as370` has had `--sysparm=` since the open-code
  work — implemented, undocumented, absent from `--help`, and already recorded in
  [`docs/assembler-options.md`](docs/assembler-options.md).
  [`docs/opencode-gate.md`](docs/opencode-gate.md) left the matching question
  open in as many words: *"what `&SYSPARM` the real TCAM assemblies passed is now
  a source question, not a tool question."* **That question is the one that was
  just answered**, per module, out of IBM's own object. Read the option table
  before opening a case: this one was measured for an hour through a patched
  macro on a private `-I` path, which is precisely what `macpath.py` exists to
  prevent.
- **The `+2` cell was a family after all, and the grouping is what hid it.** On
  2026-09-13 it was inspected — 44 modules, 29 of them `IED*` — and written off as
  *"different one-byte cases that happen to share a magnitude"*. The offsets
  genuinely differ (`IEDQA1` at `0x000e`, `IEDQA2` at `0x000a`, `IEDAYY` at
  `0x000c`), because the eyecatcher sits after however much prologue each module
  has. **Group by what the run is for, not by where it lands.** The verdict still
  holds for `+8`; it was never true of `+2`.
- **The other eight `&SYSPARM` readers are measured now, and none of them pays.**
  `IECEQU`/`IECDSECS`/`UTRK3390` use it for listing `PRINT` only and emit nothing.
  The `BNG*` family and `BTMHJN` have the `IEDHJN` shape exactly and **zero
  callers** in the tree. `XCTLTABL` is real — `DC CL6'&CODE'`, 202 sources, 174
  decks carrying its default `Y02080` — and it is the `MODID` class: **65 modules
  confirm the default is right**, 17 want `VS2-R2` (via `SDC=VS2-R2`, which drops
  exactly five bytes from each, the arithmetic of the value itself), and in **0**
  is it the whole difference. Stays out of `sysparm.tsv`; `IFG0193C` and
  `IFG0553C` are down to four bytes with it.
- **`MODID` reads `&SYSPARM` too and recovers nothing.** 288 decks carry its
  default `R03700` where IBM's object holds a PTF number — ` UZ61918 `,
  ` UY35469 `. `DC CL9` is length-neutral, so it is invisible to `lenlist.py`,
  and in **0** modules is it the whole difference (192 also differ in length, 89
  have other clusters, 7 are already identical). Worth reading against
  [`maintenance-level.md`](docs/maintenance-level.md) as evidence, not as a queue.
- **`ASMDATES` has already drifted, and `SYSPARMS` will.** Twenty tools invoke
  `as370`; **three** know the date table — `gate.sh`, `gate-worker.sh`,
  `sysparm_sweep.py`. Ten hardcode `ASMDATE="09/07/26"`, `fillgaps.py:60`,
  `where.py:41` and **`srccheck.py`** among them. It costs nothing today, measured
  — none of the 36 dated modules is in `src/`, one is in `worklist16.txt` — and it
  is the `macpath.py` shape exactly. The fix is one module returning the
  per-module `(flags, env)`; **not done**, named so it is not re-learned.

### What 2026-09-13 established

**On the baselines and the instruments**

- The two baselines are **74 CSECTs apart by length**, with the build's own two
  sides at **0 of 4,795** as the control
  ([`xref_distance.py`](tools/xref_distance.py)). The CSECT→bound-module map came
  free from Dave's own `LMDXRF38` output on BLD — `fetch_xref.py`.
- **The second baseline is a control on option A**, and it found 99 bytes of noise
  in `IKJEGMSG` alone ([`docs/two-baselines-as-a-control.md`](docs/two-baselines-as-a-control.md)).
  Corrected twice by using it: agreement proves *assembly-time*, not
  *source-derived*; and `fillgaps.py`'s `SPLIT` refusal stays broad, because
  `cmplmd370` calls alignment padding `text`.
- **Two claims withdrawn.** `IKJEHREN`'s "missing `'0'`" is a pad byte — the target
  holds `X'80'`, which is not printable. And "175 modules wait on `ESTAE`" was a
  generalisation from n = 1; `seclocate.py` found 2 of 21 located insertions. The
  second was in the mail draft and was corrected before it could be sent.

**On MVS**

- **`MAINT05Z` ran and Dave was right.** 82 jobs, `MAINT06@`→`MAINT15G`, all four
  JCL libraries, no ABEND and no `CC 0012`. `HMA3462` went from **675,382 lines to
  zero** ([`docs/dave-install-log.md`](docs/dave-install-log.md)).
- **The source library came out damaged.** 384 members unreadable by mvsMF, FTP
  *and* MVS (`NO RECORD FOUND`), 69 more missing their beginning, `AHLCWRIT` cut at
  sequence `097730` — a line boundary, not a block boundary
  ([`docs/source-states.md`](docs/source-states.md)). The pre-chain backup
  `~/MVSTK5-BLD-frozen-20260913` is verified: 32 volumes, 32 sums, `sha256sum -c`
  clean.
- **The two source libraries came apart**: 6 of 25 members differ where on 09-12 it
  was 0 of 25. `srcpull.py` takes `SRCPULL_DS` now.
- **`mvsMF` rewrites the JOB card** with its own `USER=`/`PASSWORD=`, so a card
  that carries them is rejected — `JOB NOT RUN - JCL ERROR`, and with `MSGCLASS=A`
  it purges itself and looks like it was never submitted. `bldrun.py` strips them.
- **The TK5 shutdown script does not know `JRP`**, mvsMF's job REST processor. Now
  in [`docs/runbook.md`](docs/runbook.md) with `HTTPD` and `FTPD`.

**What moved the number, and what did not**

| | modules |
|---|---:|
| the holes run under the new guard | **+201** |
| per-module `ASMDATE` — the pin was the wrong date | **+29** |
| the ranked `fillgaps` sweep, ≤6 bytes | **+27** |
| six TSO modules by hand, four needing no marker | **+6** |
| `IGGCP14` — one wrong digit in a CCW count | **+9** |
| `×`/`|` — a second wrong character, `caret_fix`'s class | **+9** |
| the full `fillgaps` sweep over all 3,686 open modules | +4 |

Everything else produced knowledge and no modules: four hours on MVS, the
`SCHEDULE` edit (+3 and **−10**, reverted), the `ESTAE` dive.

### What is exhausted, and what is left

**Exhausted.** `fillgaps.py` over all 3,686 open modules recovers **four**.
Widening its filler rule to `DS C`, `DS AL2`, `DS BL1` recovers **zero** more.

**Left, and counted rather than guessed.** 1,295 modules are within 64 bytes of
IBM's length (`lenlist.tsv`, whose `delta` column is **IBM minus ours** — the
tool's own docstring said the opposite until 2026-09-14). `seclocate.py` anchors
**987** and prints the differing run with its bytes; **71 have exactly one
length-changing spot**, and 34 of those are gone already. See queue item 1 for why
these are not the 1,038 / 182 recorded the day before.

**"No large shared cause remains" was wrong once and the correction is the day's
main result.** It was said of the `+8` cell — 21 distinct insertions, and that
still holds — and extended to `+2` on the grounds that its modules diverge after
offset 3. They do not: they insert at different offsets because each module's
eyecatcher ends at a different offset, and grouped by what the inserted run *is*
they are one family, `IEDHJN` on an empty `&SYSPARM`, **111 modules**. Eight and
four bytes may still be amounts rather than causes. Two bytes was a cause.

### Blocked, and on what

| | modules | blocked by |
|---|---:|---|
| `ESTAE` eight bytes short | some | a macro level in **none** of the three libraries, TK5's own included — **Dave's zip** |
| `SCHEDULE` at two levels | ~18 | one macro file cannot be both; the per-module macro path is agreed but waits on a real macro to put in it — **Dave's zip**, per decision 5 |
| `IHBINNRB` / `XCTL SF=(E,…)` at two levels | 11 | the whole `±4` group. IBM expands to `LA 15,D(,B)` + `EX 0,32(,2)` + `SVC 7` where we emit `LA 15,D(X)` + `SVC 7` — four bytes more, cancelled by four we emit elsewhere, which is why the lengths match and nothing clustered before. **Not the assembler**: `verdicts.tsv` gives `IGCFK10D` `tool = identical`, so IFOX00 emits our bytes too. All three surviving copies of `IHBINNRB` are byte-identical and none emits the `EX` — **Dave's zip**, per decision 5 |
| `SETFRR` at two levels | 28 | a different expansion outright: ours `LA R12,32` + `AL` + `CL` + `BH`, IBM's `L R12,FRRSCURR` + `C` + `BE` + `A R12,8` — an FRR stack entry of 8 bytes where ours computes 32. All three surviving copies byte-identical, `MACDATE 75295`. **Not the assembler**: `AHLREADR` is `tool = identical` — **Dave's zip** |
| `GETMAIN` / `FREEMAIN` at two levels | 52 | one cause shared across both: `ST R2,0(0,1)` where IBM has `ST R2,0(1)`. `HMASMDRV`/`HMASMDSU` are `tool = identical` — **Dave's zip** |
| `IEAPMNIP` | 21 | ours emits zeros where IBM emits instructions (`58f020f805ef` and the like), so the expansion produces nothing on a path IBM's takes. `IEAVNIPX` is `tool = identical` — **Dave's zip** |
| `TSCBD` at two levels — `SCBCTLUN` | ≥6 | the same thing, newly measured. `IEDAYC`'s object emits `04` and `IGE0004G`/`IGE0104G`/`IGE0304G`/`IGE0404G`/`IGE0604G` emit `01`, **both out of IBM's own members**, so no single value reproduces both and editing the shared macro gains the `IGE*` set by losing `IEDAYC`. Two of them, `IGE0104G` and `IGE0304G`, are **one byte** from identical — **Dave's zip**, per decision 5 |
| length differences | ~2,000 | one cause per module; `seclocate.py` shows each |

### The Julian eyecatcher date — six modules, done

`asmdate_sweep.py` hunts `mm/dd/yy` because that is what `&SYSDATE` produces, and
it cannot see a Julian `yy.ddd` sitting in the eyecatcher as a source constant.
Six modules had one, it was the **only** difference in the whole CSECT, and the
value was taken from IBM's object — option A, decision 3. `tools/julian_fix.py`.

| module | ours | IBM | now in |
|---|---|---|---|
| `AMDUSRF9` | `76.352` | `78.272` | `src/ALPALIB/` |
| `IEECB801` | `75.325` | `77.235` | `src/AOSB3/` |
| `IEFAB820` | `76.328` | `77.279` | `src/AOSB3/` |
| `IEFJCNTL` | `76.190` | `80.261` | `src/AOSB3/` |
| `ISTCFCR2` | `78.062` | `78.312` | `src/AOS26/` |
| `ISTZCF1B` | `78.100` | `78.265` | `src/AOS24/` |

**+6 / −0** as sets; 1,602 → **1,608**. `srccheck.py` passes on all 316.

**The marker sits at column 41 or 38, not 46, and that is the one new convention
here.** All 424 existing markers are at 46 because nothing had ever been in the
way; on these six lines columns 46–71 carry the PL/S statement id (`0001`,
`01S0001`). The free block between operand and id is 29–32 columns and the marker
is 26, so it is **right-aligned against the id** and nothing is overwritten:

```
         DC    C'AMDUSRF9  78.272'      !!! SOURCE COMPARE FIX !!! 0001 00008000
         DC    C'IEFAB820  77.279'   !!! SOURCE COMPARE FIX !!! 01S0001 00011000
```

⚠️ **This was first reported to Mike as a dilemma and it was not one.** The claim
was that 46–71 are occupied and something must be sacrificed; measuring the line
showed 32 free columns for a 26-character marker. **Measure the record before
describing what does not fit in it.**

### Nothing needs Mike right now

**The mail to Dave is written, unsent, and held on purpose** —
[`docs/mail-kreiss-2026-09-13.md`](docs/mail-kreiss-2026-09-13.md). Mike is
waiting on an answer to an earlier question, and **nothing goes out to Dave until
that arrives** (2026-09-14). Do not offer to send it and do not read it as an
oversight.

It carries two questions only he can answer — what `./ DELETE` expects of the
source library going in, and whether his macro libraries carry the missing
`ESTAE` — plus the zip he offered and `where.py --base tgt`, the tool he asked
for, with a worked example.

**Before it ever goes it needs one addition: `TSCBD` / `SCBCTLUN`.** That is a
sharper instance of the same `ESTAE` question — a macro IBM demonstrably shipped
at two levels, with two modules one byte from identical — and since decision 5 his
libraries are a *precondition* rather than a convenience. Sending without it asks
the weaker version.

### The map: where the differing bytes come from

**Of the 988 CSECTs that differ at equal length, 605 have every differing byte in
open code, 293 are mixed, and 90 are entirely inside macro expansions.** The macro
wall is not what dominates this population — `tools/macroattr.py`,
[`docs/macro-attribution.md`](docs/macro-attribution.md).

The owners, by differing clusters in generated **text** (holes counted separately,
because holes are `fillgaps.py`'s answered population):

| owner | text clusters | modules |
|---|---:|---:|
| `<open code>` | 12,931 | 558 |
| `IEAPMNIP` | 218 | 21 |
| `MODID` | 195 | **48** |
| `SETFRR` | 157 | 28 |
| `XCTLTABL` | 145 | **43** |
| `XCTL` | 95 | **31** |
| `HMASMMGP` | 70 | 30 |
| `FREEMAIN` / `GETMAIN` | 52 / 46 | 31 / 21 |

`MODID` and `XCTLTABL` are the validation: both were measured by hand the same day
from the `&SYSPARM` side and the tool found them without being told. `XCTL` is the
`±4` family, which hand analysis had put at 11 and is 31.

⚠️ **Two limits.** It needs clusters, so the **2,231 length-differing CSECTs are
out of reach** — the largest block, 41.7 %. And **open code is not the same as our
problem**: `IGE0104G`'s byte is emitted by an ordinary `OI` and caused by `TSCBD`
at two levels. `macro` is a *lower bound* on the wall; `open` means "could be
either".

### The method that works, and it is a ranking

`tools/worklist.py`: every module not identical to the chosen baseline, **nearest
first**, with the owning source statement beside each differing cluster. Then group
the differences by **(our byte, IBM's byte)** and look at the cell with several
modules in it. That is where `IGGCP14` and the `×`/`|` class came from, and it is
the only move that paid today.

`tools/lenlist.py` is the same idea for the population the byte ranking cannot see —
length differences, ranked by signed gap. `tools/seclocate.py` then says *where* the
missing bytes are, by anchoring our section's text in the bound member and aligning.

### The tools, and the control each one needed

Everything here was wrong at least once, and each was caught by a case with a
known answer rather than by reading the code.

| tool | what it does | the control that caught it |
|---|---|---|
| `scoreboard.py` | regenerates the README figures | — |
| `srccheck.py` | asserts every `src/` module is identical | found 3 that were not |
| `where.py` | every differing byte + the source line that owns it | cluster offsets are section-relative, listing addresses absolute; and `(\d+)` read the `0` of `DS 0F` as a statement number |
| `fillgaps.py` | fills gaps from the object, measures, deposits only on identity **against the chosen baseline**, refuses `SPLIT` | `DS CL1` must be replaced not preceded; owner is the greatest address, not the last listing row; **and the guard could not tell a recovered byte from a transcribed one — 99 of `IKJEGMSG`'s 100 were noise** |
| `overlay.py` | `src/` shadowing the archive, so our repairs are measurable | nothing read `src/` at all before this |
| `macpath.py` | the one `-I` path, parsed from `gate.sh` | eight tools had drifted two directories from it |
| `case_list.py` | the ordered as370 case list for cc370 | reported two modules that assemble perfectly — needed the per-module clock |
| `srcstate_vs_dlib.py` | one source state against TK5 | was discarding `diff_in_holes`/`diff_in_text` |
| `lmdrpt_count.py` | counts the build reports from the ERRORS detail | the published figure came off the SUMMARY page |
| `fetch_xref.py` | brings `LMDXRF38`'s four cross-references off BLD — the CSECT→bound-module map | — |
| `xref_distance.py` | the two baselines' CSECT lengths, no source involved | took each CSECT's *first* length instead of the set; 4 phantom differences on the build's own two sides |
| `baseline_gate.py` | one source state against **both** baselines | a coherence check that confused our deck's length with the two libraries' lengths — 1,987 contradictions; then the same check reading a three-state column as two |
| `maintenance-level` | IDR link dates | (in `docs/`, no tool) |

### The TSO block, closed out

*Superseded as a work item — kept because it is where the method came from.*

Sixty candidates went through `fillgaps.py` on 2026-09-12 and were filed as 17
recovered, 25 "a real instruction or constant differs — hand work", 9 macro
expansions, 6 not enough, 3 not a filler. **Re-run on 2026-09-13 under the guard
that scores against the chosen baseline and refuses `SPLIT`: 16 identical, 7
`SPLIT`, 41 not.** The seven — `IKJEBEAE IKJEBEUN IKJEE100 IKJEFA21 IKJEFE16
IKJEFF50 IKJEHREN` — would every one have been deposited as a recovery under the
old guard. `IKJEGMSG` needs **1** marked line where it had 100, `IKJEFF02` none at
all.

**And the "25 hard cases" were not 25 hard cases.** Ranked by distance to the
object instead of listed by name, the six nearest were 1–5 bytes and all six fell,
and **four needed no marker**: an eyecatcher date, a message number, a branch
condition mask, two table constants. That is the whole origin of `worklist.py`.

What is genuinely left of the block is macro provenance: `IKJEHREN`'s gap sits
inside a `STAX` expansion, TK5's and MVS/CE's `STAX` are byte-identical, so IBM
assembled against a `STAX` neither system ships. Same shape as the `ESTAE` case,
same resolution — Dave's macro libraries.

### The length-differing block is mapped too — 2026-09-15

`tools/lenattr.py` does for the 2,231 length-differing CSECTs what `macroattr.py`
does for the rest: `seclocate.py` locates the insert or delete, the listing says
who owns it. **Reach is 1,221 of the 2,231** — `lenlist.tsv`'s 64-byte window —
and of those:

| | modules |
|---|---:|
| mixed | 474 |
| **every length-changing run in open code** | **361** |
| not anchored | 281 |
| every run inside a macro expansion | 77 |

Owners by **distinct modules**: `<open code>` 835, `XCTL` **107**, `IEDHJN` **90**,
`MODID` 46, `GSPACE` 39, `XCTLTABL` 35, `FREEMAIN` 34, `GETMAIN` 33, `DEQ` 32,
`SDUMP` 30, `ESTAE` 26.

**`XCTL` is 107 here against 31 in the equal-length map** — the `IHBINNRB` family
is over four times what hand analysis found. **`IEDHJN` is 90**: `&SYSPARM`
modules the sweep could not prove a value for, seen from the other side of
`sysparm-rest.tsv`. `GSPACE` and `DSCAN` are macros not met before; **`LSTART` is
not a macro in the path at all** and is an artefact — a name in that column is a
hypothesis until the macro is found.

**Both maps together: 966 modules are workable with no macro in the way** — 605 at
equal length, 361 in the length block. Unmapped: 281 the anchor cannot reach and
1,010 outside the 64-byte window.

### What is under the missing eyecatcher — the 136, re-mapped

The 136 that `sysparm_sweep.py` derives a value for and keeps none of had an
invisible second cause: still length-differing, so no clusters, and every map ran
**without** their derived value and therefore named `IEDHJN` and stopped. Re-cut
with the values applied — a trial table, `SYSPARMS` pointed at it, the real one
untouched — `work/measurements/lenattr/the136-with-sysparm.tsv`:

| of the 95 that were length-differing | modules |
|---|---:|
| mixed | 43 |
| **now equal length**, so they leave this population | 22 |
| every remaining run in open code | 17 |
| every remaining run in a macro expansion | 10 |

What is left, by distinct modules: `<open code>` **60**, **`XCTL` 41**, `IEDHJN`
11, `BLDL` 3.

**`XCTL` is the second cause in 41 of them** — `IHBINNRB` runs through the whole
TSO `IGC*10D` set and is the largest single blocker under the eyecatcher.

**`IEDHJN` still owns a run in 11, so the derived value is wrong for those** — and
six show a `replace +8`, meaning IBM's expansion emits eight bytes where the sweep
reads two or four. **A lead the second pass does not cover and nobody has
followed.**

### The alignment-fill class is answered, and it inverts — 2026-09-16

> **Amended the same evening: the table itself was over-counting, 49 -> 44.**
> `alignfill.py` asked `MA.owner` who owns a cluster and accepted any
> zero-duplication `DC`. But `owner` returns the nearest **emitting** row at or
> below the address, and a region defined entirely by `EQU`s has none — so the
> last `DC 0D'0'` before `IEBWSAM`'s 184-byte `@DATA` work area was named the
> owner of clusters **52, 14 and 33 bytes long**, and the module entered a table
> named for padding.
>
> **Arithmetic settles it and needs no lookup**: a zero-duplication `DC` reaches
> only the next boundary of its own type, so `DC 0D` pads at most 7 bytes and
> `DC 0C` none at all. A cluster running past that boundary is not padding,
> whatever the listing says owns it. With the guard: **44 modules**, and
> `HMASMDR1 HMASMIO1 IEAVEIO IEBWSAM IGC111` leave. `explained` 1,724 -> **1,719**.
>
> On clusters: **22 of 139 are not padding, 16 %.** The cc370 session's own audit
> put it at 68 of 149 (46 %) and asked for it to be re-derived with our lookup,
> which excludes DSECT rows and macro-generated rows; theirs did neither. Their
> *conclusion* was right and their magnitude was high.
>
> ⚠️ **Neither of the two mechanisms we suspected was the one.** Not a DSECT at
> colliding addresses (`listing_rows` has excluded those since `macroattr.py`'s
> fourth defect) and not the `ZERO_DUP` regex (it correctly requires a `0`
> duplication factor). It was the *absence* of any emitting row after the pad.


*Was: "44 modules differ only in alignment fill, and the cause is open", with
`IGG019Q1` as the worked case. Both halves of that heading are now wrong: it is
49 modules, and the cause is not alignment.*

**Answered by the cc370 session**, asked as a question rather than handed a
diagnosis, and the answer refutes the framing rather than filling it in.

- **The bytes are not fill.** 338 differing bytes in 138 clusters: ours is `00`
  in every one, IBM's carries **114 distinct values** — `40` ×35, then
  `80 47 58 F0 B0 E0 50 10 60 01 C1` — **78 % printable EBCDIC**. A fill byte is
  one value.
- **Three clusters are 11, 14 and 16 bytes**, and a `DC 0D` pads at most 7.
  `IEBWSAM` at `0x0548` is `95f84b43 47a0b54a 92f84b43 41f0` — `CLI`, `BC`,
  `MVI`, `LA`. **Instruction text.**
- **It was in IBM's deck, not added at link time**: for **47 of 49**, IBM's DLIB
  copy and IBM's bound target member — two independent link-edits — hold
  identical bytes in the same gaps.
- Not an `ORG` artefact (11 of 149 clusters), not the wrong source state (all 49
  differ under `run8-asm` too), and not "IBM's literal was longer" — tested
  directly on `BLSSLCCA` and refuted.

🔑 **Alignment is not the cause, it is the selection.** A statement our source is
missing lands in this bucket **only when its bytes fit inside a pad**; anything
larger moves the section length and lands in `length-differs`. That is why the
population is small and why its members look unrelated. **So this is source
fidelity, not assembler behaviour** — worth up to 48 modules, and it belongs with
the recovery work rather than on a cc370 list.

**The next step is one disassembled cluster**: does `IEBWSAM`'s fourteen bytes
continue the preceding code? That is the measurement that closes the class, and
it is the first concrete thing `dasm370` would earn.

⚠️ **And the worked example this project has quoted all along does not
reproduce.** `IGG019Q1` is **not in `alignfill.tsv`**: live it is *length-differs*,
964 against 968, failing `IFO117` + `IFO178` at rc 8 because it calls
`IEDHJN ,,325` with an empty `&SYSPARM` and **is not in `sysparm.tsv`**. Its three
bytes appear only under `--sysparm=03250000`, which comes from
`sysparm-trial.tsv` and is marked **`DERIVED-UNPROVEN`** — the table this file
says to use for analysis and never for the count. Measured here:

| | rc | length | clusters |
|---|---:|---|---:|
| live | 8 | 964 vs 968 | **0** |
| `--sysparm=03250000` | 0 | 968 = 968 | 2 — `00`/`0c` at `0x0017`, `0000`/`b25a` at `0x039a` |

**Pick a case out of the current `alignfill.tsv` before quoting one.** The
docstring in `alignfill.py` and `docs/macro-attribution.md` both carried it
without the condition, and the condition is what makes it visible.

### The open-code population, and there is no family in it

`tools/opencode_families.py` over the 605: **4,972 clusters, biggest
`(ours, IBM)` cell 15 modules of 605**, and that cell is `00 -> 40` on a
`DC 0D'0'` — **alignment fill, not a defect class**. From here it is one module at
a time, and that is measured rather than felt: the same instrument found four real
macro families the same day and rejected two false ones.

What the population is made of, by owning statement and distinct modules: `DC` a
real constant **159**, `DC` zero-duplication **alignment fill** 131, `L` 78, `MVC`
56, `ST` 47, `TM` 41, `LA` 40, `OI` 38. **Data, not instructions** — which is what
option A was decided for. Alignment fill is 9 % of the clusters and is **not a
source defect**; `cmplmd370` counts it as text.

### The `dasm370` contract is written down — [`docs/dasm370-interface.md`](docs/dasm370-interface.md)

Everything agreed with the disassembler session in one place: the corpus path and
`DASM370_CORPUS`, the reference-byte layout, which index to stratify from, the
JSON-per-divergence contract, **that they do not place the `!!!` marker**, and the
three rules — macro emission only where the round trip exits 0 for *that* module,
an inferred `USING` never applied silently, an incomplete image flagged with the
flag reaching the **verdict** and not only the JSON.

⚠️ **It was written because all of it lived in commit messages**, which nobody
reads after four weeks. A contract with another session is exactly the thing that
has no owner unless it has a file.

### `cmplmd370`'s reader is fixed, the ±5 is withdrawn, and the 18 are measured

**Superseded 2026-09-16.** This section read *"⚠️ `cmplmd370` misreads scatter and
overlay modules — exposure measured at 5"*, held five modules out of the count,
and told the reader to stop quoting "18 free modules". The scatter half of that
was wrong, the hold was unnecessary, and the 18 are now measured. What follows
replaces it; the old claims are named so the correction stays visible.

**The scatter mechanism does not exist.** The `dasm370` session reported it and
then retracted it: `lmod_iter_next` does frame the `X'10'` record and the compare
loop does fall through, but **a scatter record carries no program text** — it is
the loader's translation and scatter tables, written between the IDRs and the
first control record — so a consumer building a module image is *right* to skip
it. `IEANUC01`'s four sit exactly there and the walk reaches MODEND cleanly.
The **overlay** half was real: a flat last-wins image, `CESDSEG` never read.

**So the five come off hold**, and not on anybody's say-so:

```
IDA019S4  IECVERPL  IECVESIO  IECVRRSV  IGC121
```

They are `identical` under the comparator *before* the fix as well — the verdict
never depended on it — and the new reader now reports `image_incomplete: false`,
`scatter: true`, `records: 797`, `anomalies: ''` for each, so the completeness the
verdict rests on is stated instead of assumed. **The headline no longer carries
±5.**

**And "stop quoting 18 free modules" is answered rather than lifted.** The worry
was that of `IEANUC01`'s 24 unreadable CSECTs, some of the 13 whose DLIB said
identical might not be free and some of the 10 whose DLIB said differs might be
real. Measured on the fixed reader: **13 → `identical`, 10 → `differs`, exactly
what the DLIB predicted for each.** The DLIB was right about all 24.

Tree-wide, `work/measurements/cmplmd-reader/`:

| | before | after |
|---|---:|---:|
| **recovered under the chosen baseline** | 1,608 | **1,626** |
| target member unreadable | 143 | **2** |
| …of those, DLIB calls identical | 18 | 0 |
| explained — the second verdict | 1,700 | 1,718 |

**+18 / −0 as sets**, with no `identical → anything` transition in either column
in either direction. The 18 are exactly the set this section told you not to
quote, and all 18 are `dlib_c = identical` as well.

⚠️ **The published figure stays 1,608 until the comparator is re-pinned.**
cc370#375 is merged (`63f372f`, binary sha256 `faa151cc…e5f49b5`), but adoption
here is a coordinated change — pin, `PROVENANCE.txt`, re-gate, regenerate the
scoreboard, and re-cut `macroattr`, `lenattr`, `alignfill`, `reachable` and the
three macro-reconstruction sweeps, all of which were built on a corpus that could
not see 123 modules. **Measured is not counted.**

**The two members still refused are not reader failures**: `IECVOID` and
`ISTNSC00`, both `image_incomplete: false` and exit 2 on `no section named X` —
the deck names a CSECT the member does not carry.

**One claim in this section was wrong for the whole corpus, not just at the
edges.** It read: *"the DLIB comparison is an independent path: a DLIB row is an
extracted **object deck**, not a load module, so it never enters `load_lmod`."*
**5,353 of 5,353 DLIB members begin `X'20'` — a CESD. Not one is an object
deck**, and every DLIB row goes through the same reader. The corroboration still
holds, for a reason that has to be stated instead of inferred from the format:
**zero DLIB members carry a flagged CESD type byte and 21 target members do**
(149 entries — `X'20'` 135, `X'80'` 12, `X'14'` 2). The same sentence was in
`docs/dasm370-interface.md` and is corrected there too.

⚠️ **One thing the fix does not prove, and it is not a blocker.** The per-segment
slicing has no discriminating test. Running `HEWLF064`'s sections against their
own single-CSECT DLIB members agrees on 22 of 22 — and cannot mean anything:
`length_ref` comes from the CESD entry rather than the sliced text, and
`diff_bytes` is 0 in all 22 *because* the lengths differ, so the byte comparison
never ran. All 22 are `len-differs` against both libraries, so TK5's one overlay
member contributes **0** to the figure either way. Unproven and unexposed; it
becomes load-bearing the moment one of those 22 reaches equal length.

**The trap this run caught, and it is a general one.** A CESD record's bytes 6–7
hold the **data** length (240) while its entries run to the end of the **record**
(248). Bounding the entry loop by the data length silently drops the last entry of
every record — it gave 18 members / 137 entries where the answer is 21 / 149, and
it was caught only because a peer's figure disagreed. **A census with no second
opinion would have stood.**

### One CSECT in the target library has no name, and eighteen tools invent one

`org-tgt.txt` has 5,517 `INCLUDE` rows and **one has a blank CSECT name**:

```
LPALIB   IGC0004{  INCLUDE   IGC0001D  0008FE 000000 0000000     7 fields
LPALIB   IGC0004{  INCLUDE             000032 000900 0002304     6 fields
```

Eighteen tools read that file with `line.split()`, which collapses the empty field
and reads the **length** `000032` as the CSECT's **name**.

**The phantom is inert** — nothing is called `000032`, so it never matches and
never moved a verdict. **The real cost is the other way round**: an unnamed
control section of **8,964 bytes at offset `0x900` in `LPALIB(IGC0004{)` is
invisible to every instrument here**, because all of them key on a CSECT name and
it has none.

**Not fixed in the other seventeen** — one inert row does not justify a batch edit.
`nosource.py` skips six-field rows with the reason written at the skip, and
[`docs/macro-attribution.md`](docs/macro-attribution.md) carries the account.

Found only because `nosource.py` printed its corpus row by row instead of counting
it. **A filter that drops awkward rows silently would never have surfaced it**,
which is why that tool names its exclusions in a column.

### 800 modules have an object and no source — and 598 are distinct CSECTs

Asked by the `dasm370` session (cc370 #112, the disassembler Mike named for
semantic restoration), because their stage 1 is ranked on it.

| | |
|---|---:|
| CSECT names with a DLIB object | 5,353 |
| CSECT names in a TARGET member | 5,240 |
| **object present, no source** | **800** |
| source present, no object | 260 |

172 DLIB-only, 615 target-only, 14 both. Prefixes of the 615: `IKJ` **154**,
`IEH` 40, `IGC` 40, `IFN` 38 — and TSO first is this project's stated priority.

**`org-tgt.txt` carries a length and an offset per row**, so "is this a real
CSECT" is a direct test rather than a guess:

| of the 615 | |
|---|---:|
| length 0 — genuine alias/entry candidates | 2 |
| shorter than 16 bytes — stubs or entries | 15 |
| appearing with **different lengths** across load modules | 12 |
| **distinct CSECTs with real length** | **~598** |

**Quote 598, not 800**, and name the 15 short ones as excluded rather than
filtering them silently. The 12 with differing lengths are the interesting
residue — the same name bound at two sizes is either two CSECTs sharing a name or
one re-assembled between load modules, and neither belongs in an acceptance
corpus.

**74 of the 615 are more than 60 % printable EBCDIC in their own CSECT slice** —
`IKJ` 22, `PDE` 9, `BLS` 4 — with the extremes tiny and total: `IKJEFLE4` 21 bytes
at 100 %, `DSVPCL` 53, `DDNPCL` 40. Those are parse/PCL tables, not message text,
and they are the named case for reachability analysis in a disassembler: an opcode
subset will not stop text decoding as `L`, `LA`, `ST` or `BC`.

⚠️ **The first cut of that figure said 2 of 615** because it measured the whole
bound member instead of the CSECT's own bytes. Slice by the offset and length the
file already carries.


Asked by the `dasm370` session (cc370 #112, the disassembler Mike named for
semantic restoration), because their stage 1 is ranked on it. Measured against the
overlay tree and every object we can see:

| | |
|---|---:|
| CSECT names with a DLIB object | 5,353 |
| CSECT names in a TARGET member | 5,240 |
| union — objects of any kind | 6,079 |
| **object present, no source** | **800** |
| source present, no object | 260 |

172 DLIB-only, 615 target-only, 14 both. **All 615 target-only have a readable
`.bin`**, so they are reachable input. Prefixes: `IKJ` **154**, `IEH` 40, `IGC` 40,
`IFN` 38, `IEA` 27, `IEC` 23, `AMD` 22 — and TSO first is this project's stated
priority, so the 154 weigh more than the count suggests.

⚠️ **Not yet proven**: that all 615 are distinct disassemblable CSECTs rather than
aliases or entry points. The figure is solid as *"readable object, no source of
that name"* and no further. One name (`000032`) was a parse artefact and is
excluded — 801 raw, 800 real.

### The second verdict has a number now: 1,700 of 5,353 — 31.8 %

`tools/explained.py`, and it is on the README scoreboard beside the first verdict.

| tier | modules | |
|---|---:|---:|
| `recovered` — `cmplmd370` exits 0 | 1,608 | 30.0 % |
| `reachable` — identical under a named macro reconstruction | 21 | 0.4 % |
| `blocked` — attributed, no reconstruction exists to prove it | 71 | 1.3 % |
| **explained** | **1,700** | **31.8 %** |
| **unexplained** | **3,653** | **68.2 %** |

The 71 blocked are **44 alignment fill**, 7 equal-length macro, 20 length macro.

**The second verdict adds 92 modules and no more, and that is the honest result.**
The `blocked` rule is deliberately narrow: *one* differing byte in open code and
the module is unexplained, however obvious its cause looks. Most modules are
`mixed` — macro differences **and** open-code differences — and they are correctly
counted as unexplained, because the open-code half is real work nobody has done.

**So 68 % is the actual size of the job**, and reformulating the goal did not
shrink it. What it changed is that the 68 % is now *countable* and the 1.3 % that
is genuinely blocked is separated from it.

⚠️ **The inference this used to claim is not the one the code makes, and the
truth is worse. Corrected 2026-09-16.**

This said: *"the displacement shifts that **follow** an attributed length change
are consequences of an attributed cause and are not counted separately."* Two
things are wrong with it.

**The ordering is wrong**, and the cc370 session's first constructed case for
#384 shows why structurally rather than incidentally: `L 2,18(0,12)` addresses a
field in the data area at the end of the section, so an insertion **anywhere
before that field** moves it — including from a point *after* the instruction
that addresses it. The rule is **"shifts in statements that address data beyond
the insertion point"**, which has no ordering relationship to the insertion at
all.

**And we do not implement any such rule.** `lenattr.py:90` is
`if tag == "equal" or (i2 - i1) == (j2 - j1): continue` — a displacement shift is
an equal-length `replace` and is dropped there, upstream or downstream alike. So
no figure of ours ever rested on the ordering.

🔑 **What the filter does instead is the real limit: it cannot tell a
displacement shift from a genuine constant change of the same size.** Both are
equal-length replaces, both are dropped. So in the length block we are not
over-claiming shifts as consequences — **we are silently discarding real constant
changes**, which are precisely the differences a repair has to make.

That is what [`cc370#384`](https://github.com/mvslovers/cc370/issues/384) is worth
to this project, and it is more than "turning an assumption into a measurement":
its classifier separates *a single consistent delta* (the consequence we are right
to ignore) from *anything else* (a constant change we have never counted).

At **equal** length no allowance is made and that part stands — a shift there
means two compensating errors, and accepting it would let judgement in.

### What decision 5 is worth, measured: 1,608 → 1,629

`tools/reachable.py`. The second verdict needs a testable definition, and the
strongest one is not "the differences look accounted for" — it is **byte-identical
under a named macro level we can actually produce**.

Three of the five two-level macros have a reconstruction read out of IBM's own
objects, and each was swept tree-wide. So for every module we already know whether
it is identical under our macro or under that reconstruction, and **the union of
those identical sets is exactly what a per-module macro path would deliver**:

| run | identical | adds |
|---|---:|---:|
| our macros (live) | 1,608 | — |
| `XCTL`/`IHBINNRB` reconstructed | 1,621 | 14 |
| `SETFRR` reconstructed | 1,579 | 4 |
| `GETMAIN`/`FREEMAIN` reconstructed | 1,593 | 3 |
| **union — per-module choice** | **1,629** | **+21** |

**Two of the three reconstructions lose modules on their own** — `SETFRR` drops
29, `GETMAIN` drops 15 — **and the union loses none.** The tool asserts that: no
module identical today is absent from the union. That is the whole argument for
per-module selection in one line, and it is now a measurement rather than a
principle.

⚠️ **This is only the reachable half of "explained".** A module whose differences
are attributed to `ESTAE`, `SCHEDULE`, `TSCBD`, `IEAPMNIP` or `STAX` is **named
but not reachable** — no reconstruction exists, so nothing can prove it. That
third tier, *explained but blocked*, needs the per-module attribution roll-up,
which does not exist yet and is the next tool.

### 🔑 What four two-level macros mean, and it changes decision 5's premise

`SCHEDULE`, `TSCBD`, `GETMAIN`/`FREEMAIN`, `SETFRR`, `XCTL` — five now, measured
two-level, and **every time the split runs per module.** Not per component
(`AHLREADR`, `AHLTFOR`, `AHLMCIH` are all GTF and disagree), not per library
(`AHLREADR` and `AHLTFOR` share one), not per date.

**Only one model fits: the shipped objects were assembled over years against a
macro library that moved between assemblies.** A module carries whatever level
`SYS1.AMACLIB` happened to be at on the day IBM assembled it, and the library
IBM *shipped* is one snapshot of a decade of PTFs.

Three consequences, and the third is the important one:

1. **No archive can solve this, however pristine** — not Dave's, not an original
   IBM 3.8 distribution tape, not anything. Any macro library is one snapshot and
   the objects need several.
2. It explains every measurement at once: why our macro is right for 98 `SETFRR`
   callers and wrong for 22, why `IGCFK10D` and `IGCA110D` have identical source
   and different objects, why `SYSPARM` had to be per module.
3. ⚠️ **Decision 5 waits for "a real macro rather than a constructed one", and
   that premise no longer holds.** A real library would be one level and we need
   two or more per macro. **The per-module macro path is not a workaround for
   missing material — it is the only model that matches how the object was
   actually built**, and a reconstruction read out of the objects is the only
   thing that can fill it.

### 🚪 `XCTL` gains 14 and loses 1 — the one trial that is worth applying, and it needs Mike

Three reconstructions tried. Two are hopeless as global changes. **The third is
not**, and it is the largest single gain on the board:

| trial | gained | lost | chosen |
|---|---:|---:|---:|
| `GETMAIN`/`FREEMAIN` | 3 | 18 | 1,608 → 1,593 |
| `SETFRR` | 4 | 33 | 1,608 → 1,579 |
| **`XCTL`/`IHBINNRB`** | **14** | **1** | 1,608 → **1,621** |

`IGCFK10D` drops from 23 differing bytes in 13 clusters to **2, both in `DS`
holes** — the expansion is IBM's byte for byte. 53 verdict changes, **every one
inside the 147-module `SF=(E,symbol)` population and none outside**. The single
loss is `IGCSW10D`.

**The question is not whether it works. It is whether we may install a macro we
know is not IBM's.** The inserted operand is a **literal**: `EX 0,32(,2)`, where
`32` is `IEDQOPCD+32` and `2` is `ROPCAVT` in every module of the family. No
expression over `&SF` yields it. **This is a TCAM-build-private macro, not a
general `IHBINNRB`** — applying it globally puts a TCAM hook into every
`XCTL SF=(E,…)` in the tree. That it costs only one module is *measured*; that it
is *correct* for a non-TCAM caller is not.

**The gain is bigger than +14, and the cost is smaller than it looks.** The 53
verdict changes are 14 to `identical`, **18 to `holes`** and **17 from
`len-differs` to `differs`** — so 35 further modules move into a state where
`worklist.py`, `fillgaps.py` and `macroattr.py` can see them, which today they
cannot.

And "walls off the 21 permanently" overstates it. Only **one** of the 21 no-`EX`
modules is identical today; the other 20 are not, and cannot become identical
under either macro alone — they need the per-module path regardless. **The real
cost of a global apply is `IGCSW10D` and one extra difference to undo later in 20
modules that are already blocked.**

Three ways to go: apply globally (+14 identical, +35 newly workable, −1, knowingly
wrong where it is harmless); build the per-module macro path of decision 5 first
and put it there (right, and the mechanism does not exist); or leave it.

**And it is two-level either way, proven without the trial:** `IGCFK10D` and
`IGCA110D` have identical source and IBM emits the `EX` in one and not the other.
130 objects carry it, 21 do not.

**A second axis is measured and untried**: `IHBINNRB`'s `.ISAREGA` path
(`@ZA65467`) — ours emits `LA 0,0(0,R)` + `ST`, IBM the single `ST`, in **138 of
143**. `.ISAREGB` runs the opposite way. Its own trial, not to be bundled.

### Reconstruction works, and it keeps finding the macros are TWO-level

Mike asked whether the wrong-level macros could be brought to the level we need.
**Yes as a method; so far no as a shortcut, twice.**
[`work/measurements/macro-reconstruct/`](work/measurements/macro-reconstruct/).

| trial | gained | lost | chosen |
|---|---|---:|---:|
| `GETMAIN`/`FREEMAIN` — `ST …,0(0,1)` → `0(1)` | `HMASMIO HMASMRDS IEDQNT` | **18** | 1,608 → 1,593 |
| `SETFRR` — read the entry length from the header | `AHLSBLOK ISTAPC56 ISTORFBQ ISTZFMFA` | **33** | 1,608 → 1,579 |

**The method is sound.** `IEDQNT` went from two differing bytes to zero;
`AHLREADR` went from 23 bytes in 8 clusters to **8 bytes in 3, all of them `DS`
holes** — every `SETFRR` byte matching.

**The macros are two-level, and the split is per MODULE.** `AHLREADR`, `AHLTFOR`
and `AHLMCIH` are all GTF, two of them in the same library, and one wants IBM's
level while the other two break under it. Per-caller census for `SETFRR`: **98
want ours, 22 want IBM's, 118 unclassifiable**.

That is four measured two-level macros now — `GETMAIN`/`FREEMAIN`, `SCHEDULE`,
`SETFRR`, `TSCBD`. Not a component boundary, not a library boundary, not a date:
**the signature of modules assembled at different times against a macro library
that moved between them.** Which is exactly what decision 5's per-module macro
path is for, with a reconstructed macro as its content — and the `wants-trial`
lists are the table it needs.

⚠️ **Every trial of this shape needs the null control.** The `SETFRR` run included
it — the *unmodified* macro on the same prepended `-I` path with the same
`SYSPARMS` reproduces the live figure exactly, 1,608 and 0/0 — so the −33 is the
macro and not the harness. The `GETMAIN` trial did not have that control.

⚠️ **One documented claim was wrong and is corrected**: "an FRR stack entry of 8
bytes where ours computes 32". The `8` is `FRRSELEN-FRRS`, the displacement of the
entry-length field in `IHAFRRS`. **IBM's level reads the length from the header
where ours hardcodes 32; the entry is still 32 bytes.**


Mike asked whether the six wrong-level macros could simply be brought to the level
we need. **Yes as a method, and the first trial says no as a shortcut.**

`GETMAIN`/`FREEMAIN` emit `ST …,0(0,1)`; IBM's object shows `ST …,0(1)`. One
character per line, six lines each. Rebuilt all 5,538 modules with the
reconstruction prepended to the macro path
([`work/measurements/macro-reconstruct/`](work/measurements/macro-reconstruct/)):

| | |
|---|---|
| gained | `HMASMIO`, `HMASMRDS`, `IEDQNT` |
| **lost** | 18, including `IEDQNV` — `IEDQNT`'s neighbour in the same library |
| chosen baseline | 1,608 → **1,593** |

**The method works**: a line read back out of IBM's object took `IEDQNT` from two
differing bytes to zero. **The macro is two-level**, like `SCHEDULE` and `TSCBD`,
so a global reconstruction cannot help — 18 modules want one form and 3 want the
other. **Nothing was applied.**

That makes three known two-level macros and moves `GETMAIN`/`FREEMAIN` out of
"reconstructable" and into "needs the per-module macro path", decision 5 — with a
reconstructed macro as the content, which is exactly the question decision 5
deferred.

⚠️ **The `SCHEDULE` rule held for the third time**: +3/−10 there, +3/−18 here. The
net says "wrong" without saying why; only the identical **sets** say which modules
want which level, and that list is the input to a per-module table.

### There is no hidden assembler option, and the shipped object was not built by SYSGEN

Mike's question after `&SYSPARM` proved worth 111 modules: are there **other**
options or global SET symbols IBM supplied that we do not? Closed, three ways —
[`docs/assembler-options.md`](docs/assembler-options.md).

**A macro can see exactly three things from outside**: `&SYSPARM`, `&SYSDATE`,
`&SYSTIME`. All three are handled; only `ASMTIME` is unsolved, 38 decks.

**The nine wrong-level macros read no external global.** `XCTL`'s `&IHBSWA`/
`&IHBSWB` it sets itself, `IHBINNRB`'s `&IHBNO` is an error number, and the other
seven declare none at all. `SGGBLPAK`, the SYSGEN global package, **we do have**
and it is already on the gate's path — and it is irrelevant twice: **0 of 5,538**
sources `COPY` it, and none of the nine reads a global it declares.

**And the starter tapes settle the rest.** `SYSPARM` appears **zero times** on
either volume. The SYSGEN assembly proc `ASMS` — the one whose SYSLIB is
`SYS1.AMODGEN` + `SYS1.AMACLIB` — passes **no PARM**; the others pass `OBJ` or
nothing.

> 🔑 **We proved IBM passed a per-module `SYSPARM`. The customer SYSGEN passes
> none. So the shipped object modules were never built by the customer SYSGEN —
> they were assembled in IBM's own build environment, with its own macro libraries
> and its own PARMs, and no customer tape carries either.**

That is why every archive sits at or before the base level. **It closes the
"search another tape" avenue**: what remains is reconstruction from the object,
and asking people who might hold something IBM-internal.

### The VS2 3.7 starter tapes do not have them, and they point the wrong way

Jay Moseley's `vs2StarterTapes.tar.gz`, searched 2026-09-16.

**No macro library is catalogued on either volume** — no `MACLIB`, `AMACLIB`,
`AMODGEN`, `APVTMAC`, `AGENLIB` in either VTOC. They are CKD volume images
(`START1`, `SPOOL0`) in Hercules **HET** format, which `awstape.py` cannot read
until each block is inflated.

START1 does carry ~46,000 card images of macro source as **residue** on cylinders
54–70, 320 members recoverable without a directory. **None of the nine is among
them**, by two independent searches that agree. `STAX` is there and is
**identical** to ours.

⚠️ **And the residue is at an EARLIER level than our archives, not a later one**:
of 69 members that differ, **36 carry an APAR-tagged line present only in our
copy** (`CALL` lacks four `@ZA33014` lines we have; `SAVE` lacks `@ZA58263`).
That is the shape of the whole problem seen from a new angle — **the public
material sits at or before the base level, and what MVS 3.8j was assembled with is
later than all of it.** No archive we have found runs in the direction we need.

Full account and the agent's five caught errors in
[`docs/missing-macros.md`](docs/missing-macros.md).

### The wrong-level macros are a class of their own, and they are 332 modules

[`docs/missing-macros.md`](docs/missing-macros.md) tracked only macros that are
**absent** — `Undefined operation code`, module does not build. **The second kind
is larger and was not on that page**: the macro is present, assembles without a
diagnostic, and emits different bytes than IBM shipped. Nothing flags.

| macro | modules | | macro | modules |
|---|---:|---|---|---:|
| `XCTL` → `IHBINNRB` | **138** | | `SCHEDULE` | 27 |
| `FREEMAIN` | 65 | | `IEAPMNIP` | 23 |
| `GETMAIN` | 54 | | `TSCBD` | ≥6 |
| `SETFRR` | 43 | | `STAX` | small |
| `ESTAE` | 35 | | **union** | **332** |

⚠️ **Touched is not blocked.** Many of the 332 also differ in open code and need
that work anyway: on the equal-length side the blocked families touch 112 and stop
only **11** outright. 332 is the exposure, not the yield.

Both controls are in the document: `tool = identical` in `verdicts.tsv` for every
one, so **not the assembler**; and every surviving copy compared by `diff` rather
than by grep, so **not a transcription slip**. Nine for nine, every archive has the
same wrong level.

**This is the list for a mailing-list post**, and it is why asking publicly beats
searching again.

### The queue, in the order it pays

1. **The 37 single-spot length modules still open** —
   `work/measurements/baseline-gate/single-spot.txt`, persisted for the first time
   on 2026-09-14. `seclocate.py` prints the differing run and its bytes for each;
   `lenlist.py` ranks them.

   ⚠️ **This replaces "the 182", and that number does not reproduce.** Re-derived
   over the same `lenlist.tsv` with the same unchanged `seclocate.py`: **987
   anchored, not 1,038**, and the single-spot count is **71** by *(a)* one
   size-differing alignment op, **56** by *(b)* one insert/delete, **4** by *(c)*
   one non-equal op of any kind. None of the three is 182, the 2026-09-13 list was
   never written to a file, and the gap is **unexplained** — one candidate was
   ruled out by measurement (`seclocate.py` tries the next reference when an anchor
   fails; a sweep that broke instead was the first suspect and fixing it moved
   nothing). Quote 71, with its definition, or re-derive.

   34 of the 71 were carried off by the `SYSPARM` sweep, which is what leaves 37.
2. **The 44 alignment-fill modules** (49 until the guard below was added) — see above. Not a source defect, cause
   unestablished, and the single biggest lever on the board. Start by asking
   `cc370` what a byte in an alignment gap should be, with `IGG019Q1` as the case.
3. **The 326 `IEDHJN` callers the `SYSPARM` sweep did not close** —
   `work/measurements/baseline-gate/sysparm-rest.tsv`, partitioned: 137 have a
   clean 2- or 4-byte insert and still differ after it (so a *second* cause sits
   on top and is now isolated), 167 show no clean insert, 18 differ in bytes at
   equal length, 4 have no usable reference.

   **Of those, 23 change state when their derived value is applied: `length
   differs` -> `equal length, clusters`.** That is the whole point of them —
   `cmplmd370` reports no clusters at all while the sizes differ, so those 23 are
   invisible to `worklist.py` and `fillgaps.py` today and become visible the
   moment the value is passed. 99 stay length-differing and **3 move the wrong
   way** (`equal length` -> `length differs`), which is direct evidence their
   derived value is wrong for them.

   **Of the 34, eleven are the `±4` group and they are blocked, not workable** —
   `IHBINNRB` at a level nobody has, see the blocked table. Three more are `−4`.
   That leaves ~20 with a second cause that is still open.

   **The second pass already harvests part of this and it is in the sweep.** A
   length-equal deck with a 2-byte cluster at the parameter's own offset hands
   back IBM's bytes; `IEDCSA` went `--sysparm=00100000` DIFFER,
   `--sysparm=81170000` IDENTICAL. Worth one module. The other 35 length-equal
   ones have their second cause **elsewhere**, and their clusters are printable
   now — that is what makes them work rather than a wall.

   ⚠️ **Their values are derived, not proven** — `cmplmd370` does not exit 0, so
   they are deliberately NOT in `sysparm.tsv` and must not be put in the gate.
   Pass them for *analysis* (`--sysparm=` on a one-off assembly), never for the
   count.

   ⚠️ **`MODID` is not the way in, and it is the obvious idea.** It prints the
   parameter as text (`DC CL9`), so a module expanding both macros would carry
   `&SYSPARM` twice. **Zero of the 436 do**, and zero of the 111. `grep` finds 101
   sources mentioning both and every one is a comment — the deck is what counts.
4. ✅ **Done 2026-09-16 — the 18 whose target member could not be read.** The
   reader fix landed (cc370#375), all 18 are now `identical`, and the 143
   unreadable target members are **2**. Both survivors, `IECVOID` and
   `ISTNSC00`, are `no section named X` — the deck names a CSECT the member does
   not carry — and neither is called identical by the DLIB, so the instrument is
   withholding nothing. `work/measurements/cmplmd-reader/`.
5. **Which of the 55 divergent modules are TK5 USERMODs** rather than IBM service.
   Needs the target zone's SYSMOD-to-module mapping out of the SMP CDS. `IKJEFF53`
   is a known usermod target and is among them, so the answer is not zero.
6. **The 605 modules with no named macro family and every differing byte in open
   code.** That is the workable population, and it is the largest thing on this
   list. `macroattr.tsv` names them; `worklist.py` ranks them.

   The family question has now been asked of all of them
   ([`docs/macro-attribution.md`](docs/macro-attribution.md)). `SETFRR` (28, one
   cause in 75 %), `GETMAIN`+`FREEMAIN` (52, one cause shared) and `IEAPMNIP` (21,
   ours emits zeros where IBM emits instructions) joined `XCTL` on the wall.
   `HMASMMGP` (30) and `SETLOCK` (10) have **no** shared cause and are genuinely
   per-module. Together the blocked families touch 112 modules but stop only
   **11** outright — the other 101 have open-code differences too.
7. **`work/measurements/baseline-gate/worklist16.txt`** — 438 modules within 16
   bytes, with the owning statement per cluster. Swept below six bytes; the 6–16
   band is untouched by hand.

### Waiting, and none of it blocks host-side work

- **Dave Kreiss — his macro libraries are now the single largest blocker**, and
  decision 5 makes them a precondition rather than a convenience. Four macros are
  known to exist at a level none of our libraries carries: `ESTAE`, `STAX`,
  `SCHEDULE` and — measured 2026-09-14 — `TSCBD`. Together ≥24 modules, two of
  them one byte away. **The 2026-09-13 mail is held, not pending** — nothing goes
  to Dave until an earlier answer arrives — and it asks about `ESTAE` only.
  `TSCBD` is to be added to it before it goes.
- **Dave Kreiss — mail sent 2026-09-12**
  ([`docs/mail-kreiss-2026-09-12.md`](docs/mail-kreiss-2026-09-12.md)): the
  `./ DELETE` question (SMP here refuses it, costing 485 of his SYSMODs and 486
  modules' `DSK` markers), five macro items with `TABLE` the largest at 45
  measurable `XTB*` modules, and his rebuilt `PVTMAC`/`APVTMAC`.
- **cc370** merged #365 and #367 after our tree-wide verification; it is on its
  own backlog. The case list for it is `work/measurements/cases-for-cc370.tsv`,
  three entries.
- **mainframed767** on an MVS/CE 3.0.1 — sent 2026-09-06.

### Open for Mike

- ✅ **DLIB or Target — decided 2026-09-13: target primary, DLIB as the
  fallback.** See decision 1. `srccheck.py` and `scoreboard.py` follow it; the
  published figure is **1,491 of 5,353**.
- **`work/src-pending/AOST4/IKJRBBCM.ASM`** — a repair made against MVS/CE.
  Dave's archive text is identical against TK5, so the module is recovered and
  always was, and nothing needs changing. Kept only because it is itself a
  measurement of a difference between the two objects.
- **Does option A extend to overwriting an instruction that IS executed?** Still
  not needed. The case that looked like one — `IGE0104G`/`IGE0304G`, `OI
  SCBERR4,SCBCTLUN` emitting `04` where IBM holds `01` — is **not a source
  question**: `TSCBD` exists at two levels and `IEDAYC`'s object proves the other
  one. See the blocked table and [`docs/sysparm.md`](docs/sysparm.md).

### Controls that must not be dropped

- **The IFOX00 comparison has THREE moving inputs, and a null control against it
  comes back wrong without saying so.** Measured 2026-09-16, after the `dasm370`
  session could not reproduce the recorded `as370 == IFOX00` figure: `gate.sh`
  defaults apply `asmdate.tsv` and `sysparm.tsv`, while the reference decks were
  cut on 2026-09-07 against one pinned date and an empty `SYSPARM`. So every
  override costs that module its IFOX identity — **−36 for the dates and −111 for
  the `SYSPARM`s, exactly the modules those two tables name, and no module
  outside them.** The tables are not wrong; they are matched to IBM's shipped
  object, which is the *other* comparison. **The two halves of the gate want
  different inputs and nothing said so.**

  **And the residual −9 is a third input: our own macro repairs.**
  `IGG019HP IGG019JN JO JP JQ JR JS JT JU` — the `IGGCP14` CCW-count fix of
  2026-09-13 (`ed5cf4f`), six months' worth of one digit. Measured directly, same
  binary, same flags, the repaired macro against the pre-repair one on the same
  `-I` path: **all nine are `identical` to IFOX00 with the old macro and `bytes`
  with the repaired one, 9 of 9.** The repair is right — it gained those nine
  against IBM's object — and the reference corpus predates it.

  So: **to compare against IFOX00, null BOTH tables and remember the macro
  corpus has moved since 2026-09-07.** To compare against IBM's object, apply
  them. A figure that does not say which it is, is not a figure.
- **Pass all 80 columns.** Column 72 is the continuation; cutting at 71 produces
  `IFO035` everywhere and looks like a source defect.
- **Both sides must see the same macros.** On `MVSTK5-REF` that means the
  carried-across `IBMUSER.*` copies, not TK5's own `SYS1.A*` — the delta moves
  68 modules. `macpath.py` is the single definition; `gate.sh` is its source.
- **Pin `ASMDATE`/`ASMTIME`, and per module where it matters.** `gate.sh` reads
  `ASMDATES`, a `module<TAB>mm/dd/yy` table that `asmdate_sweep.py` writes by
  assembling against every date the object carries and keeping the one that exits
  0 — 36 modules were being reported as defective over the pinned constant. The
  **time** is the same class and is **not** solved: 38 decks carry the pinned
  `12.00` and sweeping every time-shaped byte sequence recovers none of them.
- **`gate.sh`'s `.commit` degrades to `unknown` without the run failing.** It
  runs `git log` in the directory above the binary, so a binary built out of a
  `git archive` extraction — which is how a cc370 commit is measured here without
  touching that session's working tree — records nothing, and `retest.py` prints
  `unknown` as though it were a provenance. Measured 2026-09-16 on the #376
  acceptance: both runs wrote it, neither said so. **The sha256 is the identity
  and it never degrades** (`PROVENANCE.txt` says so for the pinned binaries);
  `.commit` is context. Not fixed — recording the hash beside it is one line and
  nobody has written it.
- **Pin the binary by hash.** `work/src-states/bin/as370-main`, provenance in
  `PROVENANCE.txt`. The default path points into a tree another session rebuilds.
- **And pin the DECK DIRECTORY the same way.** `tools/decks.py` names it:
  `CURRENT` = `obj_sysparm1`, `CONTROL` = the same with `SYSPARMS` off.
  `obj_overlay12` was the hardcoded default of three tools and was two generations
  behind before anyone looked. **`sysparm_sweep.py` must read `CONTROL`** — in
  `CURRENT` its 110 winners are already identical, so there is no inserted run to
  read, and a re-run would write a table with 110 fewer rows at exit 0.
- **`grep` here is `ugrep` and `ls` is `eza`.** `ls -1 > list.txt` wrote eza's
  header line into a module list and the first REST call answered HTTP 400. Use
  `/bin/ls`, `/usr/bin/grep`, or Python.
- **`grep -r` AND `-R` return zero over `work/src-states/overlay/`, for every
  pattern.** The tree is nothing but symlinks (`overlay.py` writes them) and BSD
  grep 2.6 descends into none of them. The control that settled it: one directory
  holding a real file and a symlink, both containing the pattern — `-R` finds one.
  **Use a glob (`overlay/*.ASM`) or Python.** The first count taken on 2026-09-14
  was "0 modules call `IEDHJN`"; the answer is 436.
- **Read the option table before opening a tool case.** `as370 --help` does not
  list `--sysparm=`; `docs/assembler-options.md` does, as *"implemented,
  undocumented"*. An hour went into measuring through a patched macro on a private
  `-I` path — the one thing `macpath.py` exists to prevent — for a switch that was
  already there.
- **A cell that "diverges immediately" may be grouped on the wrong key.** The `+2`
  cell was closed on 2026-09-13 because its modules insert at different offsets.
  They do; the offsets are where each module's eyecatcher ends. Grouped by what the
  inserted run *is*, they are one family of 111. Group by cause, not by coordinate.
- **In zsh a variable is not word-split.** `kill -TERM $PIDS` with newlines kills
  nothing and reports success. Use `xargs`. **Hit twice more on 2026-09-15**:
  `for m in $MODS` made one 3 kB filename (`rm: File name too long`) and
  `--only $MODS` made one argument, so the tool matched **0 modules and exited
  0**. Write the list to a file and pipe it through `xargs`.
- **`git add <missing-path>` stages a DELETE**, and a newline-separated command
  after a failed one still runs. One commit removed a file its own message
  claimed to have edited. Chain with `&&`.
- **A scan with no hits is a claim about the instrument** until a control says
  otherwise.
- **Before calling something a boundary, check reachability.** One `grep` of the
  listing for the label.
- **Re-measure after a sweep, not after the commit that describes it.**
  `fillgaps.py` deposits to `src/` the moment `cmplmd370` exits 0, and
  `scoreboard.py --check` compares README against the tool — not the tool against
  the tree. Eight modules sat measured, deposited and uncounted on 2026-09-13, and
  the figure was quoted eight low for hours.
- **When a macro changes, compare the identical SETS before and after, not their
  sizes.** `IGGCP14` was +9 and 0 lost; `SCHEDULE` was +3 and **10 lost**, and the
  net alone would have said "wrong" without saying why — that ten modules want the
  old form is what proves IBM shipped the macro at two levels.
- **One command per call against the Hercules console.** A compound with `&&`, or
  a foreground `sleep`, is refused; the same command alone goes through. And the
  refusals are not deterministic — `/P HTTPD` was allowed and `/P FTPD` refused
  one call later, which is how a shutdown ended up half-done.
- **A generalisation from one case is not a finding.** "189 modules are +8, one of
  them is `ESTAE`, therefore they all are" survived into a document and into an
  unsent mail before `seclocate.py` measured it: 2 of 21 located insertions.
- **An anchor into a bound member must report its confidence.** `seclocate.py`
  prints the agreement fraction and the margin, and refines to the offset with the
  fewest alignment edits — a scored anchor one byte out invents `delete`/`insert`
  pairs that look like findings.

---

## History — dated entries, each keeping the numbers it was written with

### Dave Kreiss' install tape holds source we were not measuring

`BLDMVS.AWS` has `NEW.ASM` as its own data set — 848 members, **321 of them not in
`MVSBLD`**. His package separates what he built (`NEW.ASM`), the MVT-era
originals (`MVT.ASM`, 106 members, all also in `MVSBLD`) and his own tools
(`UTL.ASM`, 64, none in `MVSBLD`). `MVSBLD` itself is flat and mixed: original
and repaired side by side, with nothing but his `*DSKnnnn` markers to tell them
apart.

Of the 321: **56 have a DLIB object**, so they were measurable all along and were
never measured.

- **7 are recovered immediately** — `HASPBLKS`, `HASPFMT0`–`FMT5`, byte-identical
  at the first attempt. These are exactly the seven the `mvssrc` sessions had
  reported as having no source anywhere, presumed to need a `HASPGEN` run.
- **48 are `XTB*` translate tables** blocked on a `TABLE`/`NAME` macro pair that
  is in none of our libraries, none of the IBM tapes and not in `NEW.ASM`. That
  makes them a 52nd and 53rd entry for the missing-macro inventory, and `TABLE`
  is now the second-largest single blocker after `IHANVT`.

  **Three of the 48 need no macro at all.** `mvssrc-20` found that their tape
  carries `XTB1GFC`, `XTB1GSC` and `XTB1GUC` in the expanded, macro-free form —
  `DC`/`DS`/`ORG` only, no call. Measured here: **all three assemble
  byte-identical to the DLIB object**, 288 bytes each, `rc 0`. Not deposited: the
  tape tree is held pending Mike's word, and these come from it.

  Their search for `TABLE`/`NAME` was exhaustive and negative — 1,761 macros
  across the tapes, stben's maclib, the HASP set and `ext/`, no member of that
  name and no definition with that prototype. The other 45 stay blocked.

Everything is kept in `work/kreiss-newasm/` unmeasured. Recovered goes 928 -> 935.

### The first recovered source — ten modules, and a class the IFOX comparison could not see

`src/` has its first entries. `MVSBLD` came through a transfer that read EBCDIC
as **cp1047**, where X'5F' is `^`; everything here reads **cp037**, where X'5F' is
`¬` and `^` is X'B0'. A constant written `C'^'` therefore assembled to the wrong
byte. 39 modules carry the character inside a constant, 78 occurrences.

**With the substitution, ten modules become byte-identical to the object IBM
shipped, and not one gets worse.** Repaired copies in `src/`, tool in
[`tools/caret_fix.py`](tools/caret_fix.py). Recovered goes 902 -> 912.

**Why this took a third instrument.** `as370` encodes cp037; the source reaches
MVS through mvsMF, which encodes cp037 as well. So IFOX00 received X'B0' too, and
the two assemblers agreed with each other perfectly. Every one of these sat in the
table as *"the assemblers agree, only IBM's object differs"* — booked to the
source, which was right, and unexplainable from either assembler. Only IBM's
shipped object could settle it.

Found by the `mvssrc-20` session as a case; measured here. `!` is X'5A' in both
code pages. `[`/`]` do differ but the two modules carrying them do not improve, so
that substitution stays unapplied — unproven.

**What follows from it, and it is not small:** every module whose verdict is
"assemblers agree, source differs" is now a candidate for a *transfer* defect
rather than a maintenance-level one. That is 3,507 modules, and this is the first
mechanism found in them.

### What the tape tree is for — the material Dave Kreiss started from

**Two projects, one goal, and they are not the same work.** What this repository
does is take over Dave Kreiss' project: bring the surviving sources up to the
maintenance level of the shipped object. The `mvssrc` sessions are not doing that
— they are **curating IBM's original sources for us** out of several archives, so
that we have one byte-exact, provenance-known starting point instead of a
handful of mirrors.

So the tape tree is not an alternative base to be compared against his. It is
**what he began with**, which means it finally makes his work visible as a delta:
what he changed, where he changed it, and what he never reached. The trial below
should be read for its 16 exceptions and not for its headline — that his tree
beats IBM's original is his project's definition, not a result.

What the tape does give, for the first time, is **which modules he worked on**.
His change markers (`*DSKnnnn`, or `DSKnnnn` in column 65) mark 783 modules:

| | Paired | identical + holes | |
|---|---:|---:|---:|
| **with his marker** | 744 | 108 | **14.5 %** |
| without | 4,284 | 1,289 | **30.1 %** |

**He worked on the hard ones** — that is what the inverted rate says, and it is
the right way round. The untouched modules are untouched because nobody needed to
look at them.

**634 modules carry his marker and still differ from the object.** They split in
a way that decides who does what:

- **364 wait on the assembler** — they are booked to `cc370`, so his source may
  already be right and unmeasurable until more fixes land. Every `as370` merge
  re-tests them for free.
- **270 are real source work**, and they are the best-documented modules in the
  tree: he left markers, and 44 of them carry `???` where he could not
  reconstruct what the code does. 142 differ in text, 107 in length.

**And inside it, a hard core of 25.** The `mvssrc` sessions list 116 modules
whose text matches no variant on any tape. 91 of them carry no marker of Dave's
and score 28.6 % — the tree's ordinary rate for unmarked modules, so their
provenance is open but their quality is not a problem. The other **25 carry his
marker and reach the object in 1 case out of 25** — against 14.5 % for marked
modules generally. Those are the hardest thing he touched: worked on, matching no
distribution text, and still not reaching the object.

`classes/kreiss-source-unfinished.txt` is that list. It is the most concrete
source-side work item this project has: modules with a known repair history, a
known author, and a measured gap.

### And the second: IBM's own source, measured against IBM's own object

`mvssrc-20` extracted the IBM distribution tapes byte-exact —
`~/repos/mvs/mvs38-ibmsrc`, 7,206 members, cp037, 80 columns. For **1,023**
modules where the assemblers agree, the object differs, and IBM's source is
unambiguously available *and different from Dave Kreiss'*, it was assembled here
instead:

| | Modules |
|---|---:|
| byte-identical to IBM's object | **16** |
| `DS` holes only | 19 |
| **worse** — a text difference became a length difference | **110** |

**Read this for the 16, not for the headline.** IBM's tree is the material he
started from, so "his is closer" is the definition of his project rather than a
result. The useful part is the exceptions: 16 modules where IBM's untouched text
reaches the object and his does not — places his repair either never happened or
went the wrong way — and 110 where his is better by a measurable margin.

The sixteen are in `src/`; recovered goes 912 -> 928. Full result in
[`ibm-source-trial.tsv`](work/measurements/ifox-run/ibm-source-trial.tsv).

⚠️ **A trap `mvssrc-20` measured and we must not walk into:** the FTP table is a
*swap*, X'5F' and X'B0' exchanging places, so `^` -> `¬` is only half a rule.
`MVSBLD` is not one pipeline: two members (`IFCDIP00`, `IFCIOHND`) are already
cp037 and never went through FTP, and `ICAPRTBL` carries a third encoding
(X'9B') that no substitution can repair — it has to come from the tape.
`caret_fix.py` cannot touch any of the three, which was checked and not assumed.

### #195: +4 in identities, −27 in messages, and a "regression" that wasn't one

`vref()` represents `&SYSLIST` as `(op1,op2,...)` and copies 95 bytes; `N'`
counted commas in that truncated string. So the answer tracked the **length**
of the operands rather than their count — at 13 operands, `N'` said ten, while
`&SYSLIST(11)`–`(13)` delivered the correct text. `IFNX1K` is a **three-card
module**, and `JTEXT`'s loop over 39 entries saw seven.

Plus three table limits that became visible as the work went on (global SET
4,096 → 32,768, local SET 256 → 512, `&SYSLIST` 32 → 64). **Each was recorded
twice** — field declaration and check kept separate — so raising only one of
the two changes nothing and still looks like it does.

**+4 is the identity count, −27 is the real one:** `undefined-symbol` drops
from 110 to **83**, five modules get a deck at all for the first time
(rc 2 → rc 0).

**And the 17 "further" are 16 plus one misunderstanding.** Sixteen of them are
1–4 bytes in decks that are 537 to 13,200 bytes wrong. The seventeenth is
`IKJEGMNL` with **+295** — and read on the length instrument:

| Section | before | after | IFOX00 |
|---|---:|---:|---:|
| `IKJEGSCD` | 97 | **390** | 390 |
| `IKJEGSCU` | 0 | **1** | 1 |

Two sections now hit IFOX00's length **exactly**. The byte distance grows
because 293 bytes of content now sit where a hole used to be — exactly the
#174 lesson, that a byte comparison at fixed addresses condemns content that
filled a hole. It is the largest single improvement of the merge and stood in
the regression line.

### #205: four hypotheses tested, four dead — and that is the result

Continued work on `IFCE0155`, with IFOX00's complete listing as the oracle
(`work/measurements/ifox-run/ifox-155.txt`, pulled from tape by cc370). **Four
hypotheses empirically disproved**, including the one handed over and two of
my own:

| Hypothesis | Test | Result |
|---|---|---|
| global SET arrays overflow at 3,000 | `&ITEM(1)`, `(2999)`, `(3000)` set and read | **all correct** |
| `K'&SYSLIST(1)` vs `K'&SYSLIST(1,1)` wrong | `(ABC,3)` → 7 vs 3, `ABC` → 3 vs 3 | **both directions correct** |
| omitted first sublist element | `SHOW (,4)`, `(AB,4)`, `(,4,EQU)` | **empty branch correct every time** |
| macro calls a macro defined later | outer macro calls inner, defined afterward | **expands correctly** |

**And an observation that was treated as proof is not one.** "as370 generates
more statements and fewer bytes" (1,099 against 1,037) — the excess is **inner
macro-call lines that IFOX00 does not list**. A listing convention, not a
difference in content. That belongs out of the case description.

**And the sharpest observation is retracted.** "IFOX00 reaches
`LOG ITEM SYMBOL NOT PROVIDED` 28 times, `as370` never" — the card is a
**comment inside the macro body**, and `as370` does not list generated
comment cards at all. A difference between two listing conventions, not a
branching difference. That also removes the count of generated statements in
both directions.

What remains is exclusively deck evidence: section 2,550 against 2,832, images
identical up to `0x340` and then diverging throughout, both assemblers
silent, the instruction stream correct until it points at data that isn't
there.

**The class is thus cleanly bounded and has neither mechanism nor a live
trail.** That is the honest state of it.

**And it is the second time in one day that an instrument could not see what
it was trusted to see** — after the card-based deck comparison, which
reported "269 of 274 cards" for a one-byte error. Both times the number
looked significant, both times the error pointed toward a more interesting
conclusion.

**Four dead hypotheses are a result, not a failure.** Two of them would have
looked plausible and would each have cost a session.

### 90.4 % — and the "alignment class" wasn't one

**#241: a comparison operator with no surrounding space is not recognized.**

```
         AIF   ('&EVENT'EQ'USERRDY').EOK
```

The tokenizer ends a token when a letter runs into a **closing** quote — that
correctly separates `'&EVENT'` from `EQ`. There was no rule for the mirror
case: an operator running into the **opening** quote of its right operand.
`EQ'USERRDY'` became **one** token, no comparison took place, the `AIF` fell
through. The same rule existed for an operator against `(` — **the seventh
case of a syntax with two readers.**

In `IEAVESC0`, `SYSEVENT` thereby ran past its own match *and* ignored
`ENTRY=BRANCH`: wrong event code, wrong linkage, four bytes longer — **an
alignment-shaped difference with no alignment in it.**

**+67, none lost.** The three "further" decks are **closer in size** (excess
+16→+12, +16→+12, +8→+6) — measured here.

**And my class is thereby disproved, as it should be.** The 136 "too long"
fall to **52**, and the majority of the multiples of eight are **gone**: now
17 of 52 divisible by eight, 18 by four, 15 odd. The distribution is flat.

I had filed the class as an alignment question — read off the distribution of
differences, with the explicit note that I had not opened a single module.
The smallest witness (`IFCETRN7`, an `MNOTE` path) was the first to break the
hypothesis, and the fix showed that the multiples of eight were a *symptom*.
**The label did what it was there for.**

### 89.2 % — the last three-digit block closes

**#240: `DC AL.12(1)` reserved nothing.** The length parser reads `L` and
expects digits; `.` is not one, so the length stayed 0 — no bytes, no
advance of the location counter, rc 0, no message on either side. Every
symbol after it sat exactly as far too early as whatever was never reserved.

**+99, none lost, 124 decks closer** — the largest gain since #175. And
**byte-identical to IBM's object: 1,080 → 1,124.**

**Both of my gate conditions paid off, and the second one more than the
first.** The control cases (`AL1(1)`, `XL1'F'`, `AL2(1)`, `CL3'AB'`, `F'7'`)
come out byte-equal from both binaries — checked here, not taken on trust.
cc370 shaped the implementation so that they can: **the bit path is a branch
ahead of the type dispatch**, an operand without `L.` reaches exactly the
same code as before.

**And cc370 asked the oracle a second time before they wrote it.** The
first pass fixed packing and padding; the second asked the cases that were
*not* measured — mixing bit and non-bit operands, the duplication factor,
the end of a run. **They would have guessed three of the five answers
wrong**: `AL.12(1),AL2(3)` flushes to `0010 0003` instead of packing
through, `3AL.4(1)` multiplies *into* the run, and `AL.4(1),C'A',AL.4(2)`
flushes **mid-statement**, twice. Written from the first pass, the result
would have been a feature that passes its own test fixture.

**The one "further" case checked in advance**: `IGG0193S` was already 13
bytes too long before the change and is now 20 — pre-existing excess,
different cause.

### 87.4 % — and an instrument defect that flipped a result

**#235: an `AIF` condition longer than 126 characters was truncated
mid-term**, while both call sites pass a 512-byte buffer. A macro with a
long, multi-part guard condition thereby took its error path — **no matter
what was passed to it.** `AMACLIB(IKJIDENT)`'s type check is 153 characters
long across three cards; every call fell through to `.BAD`, reported
`MNOTE 8,'PARAMETER TYPE NAME MISSING BUT REQUIRED'`, and produced
**nothing at all**.

**And that meant my macro measurement had it backwards.** Same macros,
same modules:

| | before #235 | after #235 |
|---|---:|---:|
| decks changed | 33 | **107** |
| modules reaching rc 0 | 0 | **47** |
| **closer to IBM's object** | **0** | **25** |
| further away | 0 | **0** |
| byte-identical to IBM's object | 0 | **1** (`IEAVPIOI`) |

I had reported "they engage and restore nothing" and written it into two
documents. **Retracted.** Every other instrument defect this week got one
number wrong; **this one turned "restores 25" into "restores nothing"**,
and both readings were internally consistent.

cc370's generalization is the useful form of this: **you cannot measure
whether a macro fits, on an assembler that cannot evaluate its guard.**
That holds for any measurement whose subject is exactly the thing the
instrument is broken at — and it is why #39 had to come before all the
macro work instead of running alongside it.

**And I first checked cc370's twelve "further" cases wrong.** Compared on
section length: "1 closer, 7 unchanged" — read like a disproved claim.
Computed on **total generated bytes**: **6 closer, 2 unchanged, 0
further**. A section-length comparison on a module whose sections are
mostly right hides the one that grew.

### #238: `EQU C''''` — and there were three readers, not one

The self-defining construct `C'..'` is read in **three** places — the
operand evaluator, the `SETA` reader, the conditional-assembly evaluator.
**All three fold `&&` to a single `&`. None of them folded the doubled
apostrophe.** `DC C''''` was right the whole time, because the `DC` path
has its own scanner and *that one* knew about it — **the path everyone
checks first was the one that worked.**

Found from the bytes: a histogram of byte pairs over the remaining
divergences, `0x7D → 0x00` as the largest group, and `0x7D` is EBCDIC `'`.
**+12, none lost.** Sixth instance of the pattern — and cc370 has stopped
treating each one as an individual defect, and now treats **the doubling**
itself as the defect.

### #39: 182 modules assembled cleanly while a macro was complaining

`as370` produced **nothing** for an `MNOTE` — no line, no message, rc 0,
where IFOX00 passes the severity through (uncapped: `MNOTE 20` yields
rc 20). Gated: **0 of 5,528 decks changed, 224 rc changes, 182 of them from
rc 0.**

**182 modules assembled cleanly while a macro was complaining and nothing
could hear it.** That is the size of the hole every macro measurement this
week has been read through — ahead of every new macro on the path.

For my side that means: **a module that goes from rc 0 to rc 8 under #39
is not a regression from a new macro**, but an `MNOTE` that was always
there. Separating the two needs a baseline run with #39 and without new
macros — that is now `m234`.

**And a number that is not comparable yet:** `as370` now reports `MNOTE`
in **304** modules, IFOX00 in **26**. That is not a finding but an
instrument difference — my IFOX message column comes from the diagnostics
section of the listing, and an `MNOTE *` or one with severity 0 does not
appear there at all. The two numbers count different things until that is
checked.

### 87.0 % — and a histogram found what two days of counting did not

**#231, the largest gain since #175: +57, none lost, 88 closer, zero
further.** Two defects in a five-line handler:

```c
if (nn > 0) while ((lc % nn) != b && g++ < 64) { put(lc, 0x0700, 2); lc += 2; }
```

**`CNOP` never aligns to a halfword.** From an odd counter, `lc % 4` is
always odd, so it never reaches an even remainder — 64 no-ops, the counter
128 bytes further on, **rc 0 and no message on either side**, and every
subsequent address in the section wrong. And **it never defines the name
field.**

That left `NOREL1` in `IEAVSTAA` undefined — the name of a `LOAD EP=` that
`AMACLIB(LOAD)` sets with `&NAME CNOP 0,4`.

**The nine modules that moved from the length bucket into the byte bucket
are the proof from the other side.** Measured here:

| Module | Distance before → after | Lengths |
|---|---|---|
| `IECIOSAM` | 1,351 → **43** | == IFOX00 |
| `IKTMSGS` | 1,316 → **112** | still different |
| `IGG019Q0` | 514 → **55** | == IFOX00 |
| `IGG019PD` | 140 → **12** | == IFOX00 |

Six of the nine now hit IFOX00's section lengths **exactly**. A wrecked
section, seen from the other side.

**And `HEWLDIOC` is now byte-identical to IFOX00.** The module that stood
in both runbooks for eleven months as "terminates under no alarm."

**The lesson is cc370's, and it lands on me:** *"A number told me nothing,
a histogram told me everything."* "83 modules report undefined symbols" is
a number that stood for two days. Looking at the **symbol names** — `R5`,
`R15`, `R1`, register equates — cost ten minutes and pointed straight at
the mechanism. I had taken re-deriving the population for the work; it was
the setup.

And it shows that my buckets "silent divergence" and "as370 alone flags"
are less independent than they look: **one defect put modules into both**,
and the nine length changes sat in the first while the diagnostic that
would have explained them sat in the second.

### #227 — and the third question found the only byte-touching defect

The same cause, one statement earlier: `lrecs[].loc` is stamped **before**
the statement runs, so anything that moves or replaces the location
counter lists the value from before. IFOX00 does it the other way round —
LOC keeps the counter from before, the **new** value sits in ADDR2:

```
ohne Fix   00000A                21   ORG   *-4
mit Fix    00000A        00006   21   ORG   *-4
IFOX00     00000A        00006   21   ORG   *-4
```

**The continued cases are the whole test fixture.** Without them, "the
section's origin" and "the section's own counter" give the same answer,
and cc370 would have shipped one rule or the other with a green test.

**And the third question found the only one of the three defects that
touches bytes.** `COM` was in the probe only because cc370 wanted to
capture every counter-moving statement in one pass: **`as370` does not
support `COM` at all** — no ESD entry, the counter does not jump back, and
storage declared afterward lands in the previous section. Filed as #229.

Recounted here, tokenized field by field: **`COM` occurs 0 times in the
corpus.** That is why it never caused trouble — and why it would never
have fallen out of any tree-wide measurement. A defect that only a
question asked out of thoroughness could find.

**The checker asserts the divergence** — the `COM` card and everything
after it is excluded by **source text**, not by statement numbers, because
the comment block at the head of every fixture would otherwise shift
everything. The case fails **the moment `COM` stops diverging**: #229's
gate exists before the work begins. And `equlist`'s list of known
divergences is now **empty** — the emptying is itself the proof that #226
landed.

### #226: two retracted findings, one rendering bug

My `PREFL` misreading and cc370's `L'4.0'` misreading were **the same
defect**, and it is now fixed rather than merely named.

An `EQU` does not sit at the location counter — it names a **value**, and
IFOX00 lists it that way: LOC blank, the value in ADDR2. `as370` printed
the running counter in LOC and left ADDR2 blank.

```
ohne Fix   00000A                         18 E1  EQU  A1
           00000A                         19 E2  EQU  A1+4
mit Fix                            00000  18 E1  EQU  A1
                                   00004  19 E2  EQU  A1+4
IFOX00                             00000 / 00004
```

**Without the fix, both symbols showed the same number** — the signature
of a column reporting something other than what it claims to. That is
exactly what I got hung up on.

**A wrong listing does not just inform wrongly, it creates work:** two
sessions, two retracted findings, one rendering bug. That gives the
runbook's table a fourth row — instrument defect, and both misreadings
read the same lying column, while #223 held up because it read a message.

**And no test could catch it:** none of the five `listref` cases ever
contained an `EQU`. The suite has been column-exact since it was created
and had simply never seen this statement. `equlist.s` now carries, among
other things, a DSECT-relative equate — the `PREFL` form — as a regression
test.

In doing so the test fixture found two more divergences (`ORG`, `DSECT`,
from the same cause one statement earlier) that cc370 did **not** fix
along with it: filed as its own issue, so the measurement stays
attributable. The checker **asserts the divergence** instead of tolerating
it — whoever fixes it breaks the test loudly, instead of letting it pass
quietly.

### #223 — and a contradiction I had invented

`attr_apos` carried an `E` in the attribute-letter set that IFOX's own
source does not know (`T L I S N K`, `ifnx1a.asm:4862`). `E` is not an
attribute in Assembler XF, but it is a **constant type** — so `DC E'1.0'`
does not open a string at all, the closing quote switches the quote state
*on*, the operand no longer ends at the blank, and the remark gets pulled
in. A comma inside it then turns it into a second constant:

| | rc | Bytes |
|---|---|---|
| IFOX00 | **0**, no diagnostic | `41100000` |
| `as370` before | **8**, "Invalid type declared" | `41100000` |

**Same bytes, and `as370` rejects the statement.** A false alarm, not a
missed error — and under `COND=(8,LT)` that fails a build that IFOX00
assembles cleanly.

**The case fails at the rc gate, not at the byte comparison.** Every
instrument I have built this week reads bytes; this defect never touched
one. It was visible only because the return code is its own axis, one we
also record.

**And I reported a contradiction to cc370 that did not exist.** I had
reported that their statement came out "rc 0, in three forms" for me.
Checked again: their file yields rc 8 — and **so does my own**, the same
file I had reported as clean. I also ran the gap before the remark from 1
to 24 characters: **rc 8 everywhere.** There was no difference in the
input for them to go looking for, which is what I had asked them to do. I
cannot reconstruct how I arrived at rc 0.

cc370's response to that is the rule: **send the file, not the
description.** They committed `attre.s` instead of describing the card,
and it was settled in one run.

### #221: a fix this tree can neither prove nor disprove

The `L'` of an `EQU` is the length of its leftmost term. `equ_len_of`
checked the first character for a letter, so a leading parenthesis fell
through to 1.

**Tree run: zero. Not one byte of 5,528 decks moved.** And the construct
is not rare — **`EQU (` occurs 135 times in 75 modules** (cc370 counts 126
cards across the same 75; the nine-card difference is unresolved and
affects only the count, not the fix). The tree *carries* it and **never
consumes** it: nobody reads the `L'` of such a symbol.

**So the test fixture is the only safeguard.** Run against both binaries:

```
ohne Fix   01 01 01 01 01 01 01
mit Fix    07 01 07 07 03 01 01
IFOX00     07 01 07 07 03 01 01
```

Three of the seven cases are controls that stay `01` in **both**
binaries — `(4+S1)` against "first symbol anywhere", `(X'04'+S1)` against
"first alphabetic token", `( S1+4)` against "also skip blanks". An
over-eager fix would fail there.

This is the first change where "moves nothing" **was the expectation**
rather than the finding — and cc370 put that in the PR text, instead of
leaving someone to find later that the change moves nothing and conclude
from that that it was unnecessary.

### 86.0 % — the site class delivers before the enumeration is finished

**#218:** three readers split on top-level commas. Two check for the
attribute apostrophe, `dc_split` never does. After an odd number of
`L'`/`K'`, it considers itself inside a string, and the next comma no
longer splits:

```
DC AL1(L'FLD),X'FF'   ->  07        IFOX00: 07FF
```

**The `X'FF'` drops out — at rc 0, with no message, and IFOX00 also
assembles it at rc 0 with no diagnostic.** Neither the return code nor a
message would ever have seen this; only the bytes. +2, none lost.

**And cc370's source-text scan was a bound on the wrong population.** It
found two modules with the construct — **neither of the two is among the
gainers.** The operand reached `IEAVNP11`/`IEAVNP12` through a macro, and
a card scan sees no generated text. The same lesson as the 35 against 79
from the first day, only one level subtler: an attribute apostrophe in a
DC operand is lexical, the characters sit on a card — just not on one
that was read.

**One candidate pair was explicitly not a defect.** Six readers decide "is
this apostrophe an attribute", with three different letter sets (`KNLT`,
`LTKNIS`, `LTKNISE`). Looks like neglect, but is correct: IFOX00 reads
`S'` and `I'` in an ordinary expression as an opening quote. **Different
sets depending on context.** Without the oracle this would have been
filed as the fifth case of the site class.

**#217, the scale modifier — and my number shrinks it.** `DC FS3'1.25'`
gives `0000000A` on IFOX00 and `00000001` on `as370`; the modifier is
ignored. Six modules carry it, all six diverge — but:

| Module | Section length | diverging bytes | attributable |
|---|---|---:|---|
| **`IFFPEAGR`** | **equal** | 18 | **yes** |
| `IFFPIAPG` | 3,692 vs 3,844 | 63 | no |
| `IFFPJAPV` | 3,214 vs 3,366 | 59 | no |
| `IFFPCAAR` | 2,150 vs 2,288 | 49 | no |
| `IFFPFAVA` | 2,616 vs 2,754 | 62 | no |
| `IFNX5M` | equal | **647** across 126 runs | no |

**A scale modifier changes the value, not the width.** A module whose
section is 138 to 152 bytes too short is that for a different reason.
`IFNX5M` carries **one** `HS14` and diverges in 647 bytes. Measured reach
of the defect in this tree: **one module, sixteen bytes.** Sixth time
that "N modules carry the construct" gets read as a reach of N.

### All 5,528 modules produce a deck — for the first time

**`HEWLDIOC` was never slow. It has been hanging, for eleven months, on
`main`.** `expr_sect`'s expression pass consumes blanks, operators, and
parentheses and stops a name at a comma — with no branch for that. A
comma leaves the pointer standing still, and the loop runs forever.
Reachable from a perfectly ordinary machine operand; found only when
cc370 approached the same pass from a second angle.

Measured individually, once the guard was in place:

| `HEWLDIOC` | |
|---|---|
| Runtime | **0.04 s** |
| Section length | **5,224 against IFOX00's 5,224** |
| Distance to the image | **4 bytes out of 5,056** |

Eleven months of "never terminates" — and it was four bytes from
identity.

**And my runbook carried that along.** I had written in `gate-worker.sh`
and in the gate document: "does not terminate in 300 s and will not under
any alarm". The 300 s were measured, the "never" was an inference — and
it justified the alarm value, which is why nobody questioned it further.
**A time alarm cannot distinguish slow from broken**; it reports where
the measuring stopped. Both places corrected.

**The alarm is now 150 s instead of 240.** The slowest module that gets
through is `IFCEL155` at 72 s — double margin — and since #215 **not a
single one** has been shot down any more. The run costs 2:02 instead of
4:04. Calibrated as a no-op: 5,528/5,528, zero different.

**And the relocation side is closed.** `IEDCSA` is identical, and the
line that has been the most interesting one since yesterday:

```
image identical AND RLD different: 0
```

**Every module whose bytes are right now also has a correct Relocation
Dictionary.** That was the failure mode hardest to see — right value,
right image, and a binder that does not relocate.

### CI was red, and two of the failures were mine

**#208 was merged with red CI.** `gcc -Werror` rejects
`strncpy(r->name, b, 19)` as a possible truncation; the run on the PR
branch had failed at 13:46, the merge was at 13:56. My gate looks at
object decks and never looked at CI. **#212** fixes it with `scopy`, the
helper the file already had.

**I wrote that my gate was "structurally blind" for this class. That is
not true.** `/opt/homebrew/bin/gcc-16` sits on this machine and
reproduces the error exactly. I had tried `gcc-14`, `gcc-13`, `gcc-12`,
and `/usr/bin/gcc` and stopped. **A tool that is missing under three
guessed names is not a missing tool** — the same shape as everything else
that went wrong this week: concluded from a description instead of
checked.

**And the second failure:** #213 hung as a stacked PR off #212. My
`--delete-branch` on the merge of #212 removed its branch and thereby
**closed** #213. GitHub will not reopen a PR whose base is missing, and
the base of a closed one cannot be changed — it had to be reopened as
**#214**, same commit. Both are now in the runbook.

### #214: the CCW data address `*`, +7

A CCW whose data address is written as `*` is relocatable, and `as370`
dropped the entry: `reloc_sym` returns `"*"`, `sym_find` finds nothing.
The `DC` path six lines below has always handled the location counter in
its `tgtreal` predicate — two paths, the same term, one right.

**And cc370 split my 78 and turned the size question around.** Of 410
missing entries, 390 are downstream: 43 modules report undefined symbols
(an undefined symbol assembles as absolute zero and by definition carries
no relocation), for 28 the `TXT` image already diverges. **That leaves 7
modules with 20 entries**, and 18 of those are this one CCW defect.

My entry comparison **cannot distinguish a missing relocation from a
missing symbol** and reports both the same way. I had suspected that,
alongside the small change, a bigger one with twenty times the reach was
sitting there. It was the other way round: the small one was the right
one, and the 178 `R == P` were not a population.

### #209: missing relocation entries — 78 modules, and the mechanism is one of them

In #199's remainder, cc370 found that six modules produce **no**
Relocation Dictionary at all, and diagnosed it: `DC A(IEDIAP05-IEDIAP04)`
across two control sections is net absolute, so `as370` emits nothing,
while IFOX00 sets a **negative** and a positive pair — `as370`'s RLD
emitter has no direction bit.

I measured the reach tree-wide, entry by entry (`R`, `P`, address) across
all 5,527 decks:

| | Modules |
|---|---:|
| IFOX00 has **more** RLD entries than `as370` | **78** |
| of those: `as370` produces **no** RLD at all | **6** |
| of those: IFOX00 has an entry with the **direction bit** | **1** |

The six are exactly cc370's six — derived independently from the entry
comparison rather than from the remainder, so confirmed from two sides.
**But the mechanism applies to only one of them.** `IEDCSA` is the only
module in the whole tree where IFOX00 sets a flag with `0x02`.

The other 77 are missing 410 ordinary positive entries — 178 of them with
`R == P`, i.e. address constants that point into their own control
section. `IGG019R0`: IFOX00 14 entries, `as370` 3.

**A correct diagnosis and a correct population, but for different
questions.** Six modules produce no RLD; one of them for the reason
found. Crediting the direction bit as the cause of the six would mean
putting a one-module mechanism behind a six-module heading — the shape
we have run into five times this week, and the first time on a defect
that is unquestionably real.

### #208: one change, both problems, no limit raised

A subscripted SET symbol is now **one** table row with a vector instead
of N named rows. `MAXLSET` stays at 512, `MAXGSET` stays at 32,768 — the
limit question dissolved, as predicted.

**The three-part gate, in the order I had fixed it in:**

1. **0 of 5,524 shared decks changed.** The only decks that move are the
   three that had none before.
2. **All three produce a deck.** `no-as370-deck` 4 → 1.
3. **Runtime:** `IFCE0155` 1.441 s → **0.339 s** (factor 4.2), `IFCEE155`
   5.796 s → **2.254 s** (factor 2.6).

**Point 3 was the one I did not want to leave out, and it is the only one
that produced something the others do not show.** cc370 measures a
factor of 9.8, I measure 4.2 — different machines, the same sign. Had it
come out flat, identical decks and three rescued modules would still have
looked like success.

**And my gate was wrong on the first pass — against my own time alarm.**
`IFCEL155` no longer died at the table, but ran 72 s alone and, under
`-P 8`, went over the 90 s alarm: `rc 2 → rc 142`. The rule from the
`IFCEE155` case, one order of magnitude higher — **a module near the
alarm is a module that comes and goes.** Alarm set to 240 s, after which
all three are stable. The run now costs 4:04 instead of 1:40, because
`HEWLDIOC` draws the full 240 s. A gate that reports a difference no code
produced is worse than a slow one.

**A mix-up of my own belongs here too.** I had named a checkpoint to
cc370: "`IFCE0155` runs today in 6.50 s". What I had measured was
`IFCEE155` — one letter, in the specification of the gate I had demanded
myself. `IFCE0155` ran in 1.44 s.

**+0 identities, none lost.** The three new decks are 7,528, 3,104, and
7,087 bytes wrong — EREP modules, so from here on #205's territory. #173
was about them dying, not about their correctness.

### #173: the diagnosis — not the limit, but the storage model

cc370 profiled instead of estimating and corrected me: the **local**
table peaks in `IFCE0155` at **eleven** entries. The cost sits in the
**global** scan — 98 million comparisons over 6,757 entries.

I then measured the other half. The three modules that die at
`local SET-symbol table full (512)` each declare **one** thing:

```
IFCEL155 Zeile 1336:   LCLB   &SW(4000)
IFCSXXXF Zeile  377:   LCLB   &SW(4000)
IFCSXXXH Zeile  378:   LCLB   &SW(4000)
```

Their distinct `LCL` symbols number 45, 52, and 52 — nowhere near 512.

**Established with test cases: a subscripted array costs one table entry
per *assigned* subscript.**

| Test case | Result |
|---|---|
| `LCLB &SW(4000)` declared, never assigned | rc 0 |
| 400 distinct subscripts assigned | rc 0 |
| **600 distinct subscripts** | **table full (512)** |
| 5,000 assignments to two symbols | rc 0 — no duplicate error |
| 60 nested expansions with 20 locals each | rc 0 — no leak |

**And with that, cc370's finding and mine are the same thing seen from
two sides.** `DSGEN`'s `GBLC &ITEM(3000)` and `GBLA &BITS(3000),&SHIFT(3000)`
are likewise subscripted arrays, stored the same way — which is why
6,757 entries exist there at all, and why 512 is not enough for *one*
array.

An array with N elements is N individually named rows in a linearly
searched table. **Changing the storage model fixes both and makes the
limit question largely disappear.** Fixing only the global search would
leave the three modules failing at a limit that would then be arbitrary.

### #207: the first change with no deck gain, taken deliberately

`struct ctx` and the `seqn`/`seqi` pair no longer live on the stack.
**Measured with `sizeof`: 78,240 + 49,152 = 127,392 bytes per level, 4.86
MB at depth 40** — my calculated figures were off by eleven bytes.

**Strict no-op, and checked exactly that way:** 0 of 5,524 decks changed
(by hash), 0 rc changes, `+0 / 0 lost / 0 closer / 0 further`. Also
measured the runtime, because a heap allocation per macro expansion could
cost something:

| Module | before #207 | after #207 |
|---|---:|---:|
| `IFCEE155` | 6.58 s | 6.50 s |
| `IEAVNP01` | 0.06 s | 0.04 s |
| `IEAVAP00` | 0.11 s | 0.11 s |

No measurable difference. The gate run was 1:38 instead of 1:18 —
machine load, not the change.

**The value does not sit in the deck.** It decouples *every*
context-local table from recursion depth and is what makes #173 solvable
at all. A change with no deck gain never wins an argument against a
"+47" — it only happens deliberately, or not at all.

**And cc370's first no-op comparison reported 13 changed decks.** Seven
were #206's own gains, three were my card-packing changes: the baseline
was one merge old. The two-builds trap in its most ordinary form — not
two binaries in one number, but a stale comparison directory lying
around. **On a no-op this error is visible**, which is one more argument
for running no-ops deliberately.

### 85.8 % — two populations that only seemed to contradict each other

**#206:** an `ENTRY` that names a control section gets no `LD` — the `SD`
*is* that entry point. `as370` emitted one anyway, and **first**, because
the `ENTRY` card precedes the `CSECT` (in `IERABW`, 104 cards earlier).
+7, none lost.

**And a discrepancy in numbers that was not a question of definitions.**
cc370 derived the #199 remainder as **17**, I derived **32**, and we
were already about to reconcile the definitions. Laid side by side by
module name: their four signatures are subsets of my seven, identical
module for module, and exactly the three categories in which **`TXT`
cards** differ are missing (8 + 6 + 1 = 15). 17 + 15 = 32.

So not a difference in definitions, but a missing category — the same
bytes, different card boundaries. **Comparing names, not numbers**, would
have shown that immediately, and it is cheaper than any debate about
definitions.

After #206 it is **25**:

| Signature | Modules |
|---|---:|
| `TXT` only | 8 |
| card count −1 | 6 |
| `RLD`/`TXT` | 6 |
| `RLD` only | 2 |
| card count +1, `ESD` only, `ESD`/`RLD`/`TXT` | 1 each |

`AMDPRPJB` and `AMDPRPMS` are in there — the same two that cc370 had
picked out of #186's remainder as "never the flag byte." They belong
here.

### 85.7 % — the largest remaining block is EREP

**cc370#205: 84 modules, almost all `IFC*`, in which `as370` produces
hundreds of bytes less than IFOX00 from the same source — and both
assemblers stay silent.**

| Module | `as370` | IFOX00 | Δ |
|---|---:|---:|---:|
| `IFCE0145` | 10,432 | 11,635 | **−1,203** |
| `IFCE0135` | 6,975 | 8,017 | **−1,042** |
| `IFCE0155` | 2,550 | 2,832 | −282 |

**It is not the macro gap.** `IFCE0155` calls `DSGEN` 59 times, `LINE` 17
times, `HEX` 16 times — all names from the search list — and **defines
them itself**: eight `MACRO` definitions in the source. That is why both
stay silent. It is conditional assembly inside nested macros (`AIF` 27
times, `SETA` 10 times, in that one module) that generates less material
in `as370`.

The finding in two lines — the instruction stream matches up to `0x24`,
then an `LA` **distance**:

```
IFOX   41 50 93 96      LA R5,X'396'(,R9)
as370  41 50 93 76      LA R5,X'376'(,R9)      Ziel 32 Bytes früher
IFOX   41 60 96 61      LA R6,X'661'(,R9)
as370  41 60 95 47      LA R6,X'547'(,R9)      Ziel 282 Bytes früher
```

**The code is right, and the data it addresses is not there.** The two
differences are different (32 and 282), so something is missing in
**more than one place**.

**And the class is defined by a threshold, not by a mechanism — that was
my mistake in the case description.** Measured across all 84:

| | Modules |
|---|---:|
| Δ a multiple of 8 | 27 |
| multiple of 4 | 27 |
| even | 17 |
| odd | 13 |

Practically an even distribution; the most common single value occurs
**3 times out of 84**. And `IFCE0155` is the **least typical** module in
the class: 78 of the 84 already diverge within the first 32 bytes, with
50–93 % divergence after that, while `IFCE0155` has 832 bytes of
identical lead-in and a single, late break point.

I had picked the cleanest witness — and **picking the cleanest witness is
exactly how a threshold class turns into a mechanism class.** "One cause
plausible because EREP is a coherent product" was an inference from a
family name and one module. The measurement does not support it.

Fourth remainder this week that was defined by a membership rule instead
of a cause — and the first one where I wrote the mechanism
interpretation into the issue myself.

### 84.8 % — the remainder, sorted by form

The 832 remaining divergences, split by whether the **section lengths**
are right — "right form, wrong content" is a different job from "wrong
form":

| | Modules |
|---|---:|
| exactly **one** section with the wrong length | **471** |
| all lengths correct | **328** |
| two sections wrong | 14 |
| three or more | 11 |
| different section count | 4 |

The 471 do not break down further: the length differences are scattered
(most common −8 with 21 modules, +16 with 20, +8 with 17), so there are
many causes and not one. Among the 328, the median is eight diverging
bytes, and 173 have at most eight.

**cc370#203 fell out of this: the mirror image of #190.** There, `as370`
wrote `B=0` where IFOX00 sets a base register. Here **`as370` gives a
base register where IFOX00 writes `B=0`** — a blank distance into low
storage. 49 modules pure, 18 partial, and of 164 diverging bytes, **161
are the `B1` field of the first operand of an SS instruction**. None is
RX.

```
AHLTPID   0x058   IFOX  d5 01 00 8e      as370  d5 01 20 8e     B1 0 -> 2
AMDSAPGE  0x06a   IFOX  d2 27 00 58      as370  d2 27 80 58     B1 0 -> 8
```

**And #191's own control case asserts exactly the rule violated here**: a
relocatable `USING *,15` over the whole CSECT, and IFOX00 never uses R15
for an absolute operand. The control case stands on an **RX** operand and
so does not reach here.

**What I ruled out beforehand:** that this is a regression from #191.
Eight of these modules measured against the state *before* #191 —
divergence count and base 0→n identical, module for module. The class is
older and independent. That was the first thing to rule out, because
#191's first version was off in exactly this direction.

### 84.6 % — hand-over list at 927

**#200: an ESDID belongs to the ESD entry, not to the symbol.** A name
can carry two — a CSECT that contains a `V`-con on its own name has an
`SD` **and** an `ER` entry, and IFOX00 numbers them separately. `as370`
kept the ID on `struct sym`, so the `ER` assignment overwrote the `SD`'s.

**My interpretation was close, and the actual issue was smaller and
nastier.** I had written that it was a question of order — *when* the
section's entry is assigned relative to the external references. The
order was already correct: `HMASMDC2` sits in `esdord` at position 0
**and** 117, and the numbering gave the same `struct sym` first 1 and
then 116. Because an ESD card carries *one* starting ID and the entries
follow positionally, that shifted the entire first card — which is why
entries 1–3 were wrong and, from the fourth on, everything was.

**And the half that would have shipped broken.** The `R` pointer was
*accidentally* correct: it wants the ID of the `ER` entry anyway, and
that is exactly what stood there after the overwrite. The `P` pointer
was wrong in every RLD entry. Fixing only the numbering gets you `P=1`
and **breaks `R` into 1**, where IFOX00 has `0x74`. cc370 broke `R`
first, saw it, and the control case is what the test fixture kept from
that.

**+53, none lost, zero further.** The class "image identical, deck not"
falls from 83 to **31**, and none of the 31 are newly added.

### 83.7 % — the case with no defect in content

**83 modules whose object image is byte-identical to IFOX00 and whose
deck is not.** Same sections, same bytes at every address, same
lengths — and the cards that carry them differ. cc370#199.

| what diverges | Modules |
|---|---:|
| **ESD numbering** — same symbols, different ESDIDs | **56** |
| `RLD` only, image identical | 13 |
| card count off by one | 7 |
| `TXT` only, image identical | 3 |

`HMASMDC2`, 118 ESD entries, the same 118 symbols:

```
IFOX00                        as370
id=0x0001 HMASMDC2  SD        id=0x0074 HMASMDC2  SD
id=0x0002 HMASMAAR  ER        id=0x0075 HMASMAAR  ER
id=0x0004 HMASMALC  ER        id=0x0004 HMASMALC  ER
```

The control section's own entry gets **1** from IFOX00 and **0x74** from
`as370`; from the fourth entry on, both agree again. So a question of
order, not a numbering scheme.

**This is the reverse of every case so far.** There is no defect in
content here: the image is right, the object loads, IBM's module matches
both decks. 83 modules that are **correct** and not **identical** — and
only a byte comparison of the cards sees that. By this project's goal
they still count.

**And it explains a remainder.** `HMASMTMD` was the witness for #194; its
image reached zero diverging bytes under #198, its deck did not, because
it carries one more card than IFOX00. Whoever measures a class remainder
on the image calls such a module done; whoever measures it on the deck
does not. Both are right, and the number has to say which.

**Unlike #190, there is no self-contradiction here** to appeal to —
`as370` is internally consistent and simply orders differently. Here the
oracle is the whole argument, and that needs to be said along with it.

### The case that survived: the implicit SS length — and the witness pointed deeper

cc370#194/#198: it was not the SS path that was wrong, but **the `L'` of
an `EQU` symbol was 1**. The SS path reads the length attribute
correctly. `HMASMTMD`'s control case therefore delivered more than it
looked like: the explicit form was not right because the SS path is
different, but because an explicit length never queries the attribute at
all.

The rule, as measured: **leftmost term, and only if that term is a
symbol.** `1+A` gives 1, not 4 — the case that establishes the rule
rather than merely confirming it, because everywhere else "leftmost
term" and "first symbol in the expression" coincide.

**+38, none lost, 57 closer, zero further.** Of the 54 in the class, 34
are deck-identical, 12 still carry the SS-length pattern (a second
cause, e.g. `IGC121`), and 8 have an identical image with a diverging
deck — those now belong to #199.

### The original case: the implicit SS length, 54 modules pure and 59 partial

cc370#194. **An SS instruction with no explicit length gets length 1 from
`as370`**, where IFOX00 uses the length attribute of the first operand.
The length byte goes out as `0x00` instead of as `L'operand − 1`.

| | Modules |
|---|---:|
| **all** of the deck's divergences are SS length bytes at 0 | **54** |
| SS length byte **plus** something else | **59** |

31 of the 54 differ in exactly this one byte across the whole deck.
Opcodes: `D1` MVN, `D2` MVC, `D4` NC, `D5` CLC, `D6` OC, `D7` XC — and
**always** `as370` with 0 against a real length, never the other way
round.

**The witness carries its own control case.** `HMASMTMD`, offset
`0x3020`, the only diverging byte in the deck:

```
IFOX00 : D2 03 C507 1000     MVC @PC00031,0(R1)     Länge 4
as370  : D2 00 C507 1000                            Länge 1
```

`@PC00031 EQU A003520`. And 135 cards earlier, the same module writes the
same field correctly:

```
6774     MVC   @PC00031(4),0(R1)      ausdrücklich -- as370 gibt D2 03 aus
6909     MVC   @PC00031,0(R1)         impliziert   -- as370 gibt D2 00 aus
```

Same symbol, same instruction, same module. **The assembler has the
length and does not use it.** This is again the self-contradiction
argument, and this time it holds: the correct behaviour is present in
the same module.

**A check that was not optional.** `D1`, `D2`, `D5`, `D6`, `D7` are also
EBCDIC letters (`J`, `K`, `N`, `O`, `P`), so the whole class could have
been text constants. Every witness was checked by reading the
neighbouring bytes — all sit between a load instruction and a branch,
none in a string.

### #191: 82.9 %, and guessed wrong twice before it was right

`ISDACVT EQU 0` with absolute `EQU` fields is the way to map a control
block ahead of its DSECTs; `USING ISDACVT,2` makes R2 the base for those
offsets. `as370` had registered such `USING`s and **never consulted
them** — it had no resolution of absolute domains at all. **+57, none
lost, 69 closer, zero further.**

Recomputed after the merge:

| | |
|---|---:|
| of the 54, became identical | **52** |
| gained, but **not** among the 54 | **5** |
| of the 54, remaining | **2** — `IECVXURT`, `IDA019S6` |

**The lower bound was real, and short by 5.** The scan only saw modules
with at most eight diverging addresses; five carried this defect *and*
something else. And the two survivors are exactly the two that never had
the `B → 0` pattern — the remainder of a class consists of what never
belonged to the class. I had given cc370 that same warning about the
remainder of #186; it applies here to my own.

**And my forecast was wrong.** I had written to cc370 that they would
not need the oracle: if `as370` takes base 0 where a `USING` applies, it
contradicts itself, and that settles the matter. They needed IFOX00
twice, and both times it changed the answer:

1. Whether a bare `256` gets a base — cc370's instinct said no, IFOX00
   resolves all six forms. The expected exception would have moved the
   class halfway and the test would have been green.
2. The first version came out **+0 and −52**. The distinguishing feature
   is not "not relocatable" but **"defined and absolute"**: an
   *undefined* symbol also evaluates to 0 and non-relocatable, so
   `USING GSPCB,R2WRK` in `IFFAAA01` became the absolute domain and
   `L R4WRK,16` reached R2+16 instead of absolute 16 — the CVT pointer.

**Self-contradiction proves that an assembler is wrong, but it does not
say what is right.** That is the limit of the argument that worked for
`IEAVELCR`, and I had stretched it too far.

### Realigned: the 940, sorted by mechanism

**The goal is `as370 == IFOX00` on all 5,528.** Whether IBM's shipped
object matches that is a separate question and does not order this
work — a divergence is a divergence, whether a recovery stands behind it
or not. The sort by IBM's verdict in `docs/silent-divergences.md`
remains as a side finding, but it is no longer the ordering.

`tools/cluster_remaining.py`, against `928454b` (in parentheses, the
state before #191):

| Card-type signature | Modules |
|---|---:|
| `TXT` only | **277** (335) |
| card count different (Δ2–9) | 161 |
| card count different (Δ10+) | 141 |
| card count different (Δ1) | 128 |
| `ESD`/`RLD`/`TXT` only | 124 |
| `ESD`/`TXT` only | 56 |
| `RLD`/`TXT` only | 20 |
| `RLD` only | 13 |
| `ESD` only | 7 |
| `ESD`/`RLD` only | 4 |

> **These rows sum to 931, and the heading says 940.** Noticed 2026-09-11 while
> translating this file; the discrepancy is in the original entry and neither
> number is changed here, because there is nothing left to say which is right —
> the table may be a subset, or the 940 may have been read from a different cut.
> A figure that disagrees with its own table is worth a line saying so rather
> than a silent correction to whichever looks tidier.

**69 modules differ in exactly one byte** (before #191: 101), and out of
that fell the case #191 dealt with: **54 modules whose only divergence
is the base register of an RX instruction**, and in 52 of them `as370`
writes **B=0** where IFOX00 sets a real base register. The distance is
identical, every other byte of the deck is identical.

`ISDAAPR1`, section offset `0x2e`, one byte in the whole deck:

```
IFOX00 : 4110 2100     LA R1,256(,R2)
as370  : 4110 0100     LA R1,256(,R0)
```

27 of the 54 are `ISDA*` with the same signature — one resolution site,
not 27 separate source-text questions. **B=0 is not a wrong base
register, it is no base register at all**: the instruction then
addresses the blank distance, i.e. low storage.

**And it is not #154.** Zero of the 54 are in the `addressability`
class — `as370` reports nothing here, it resolves the operand, silently
takes base 0, and produces an instruction that assembles cleanly and
points somewhere else. 23 of the 54 are complete silent divergences.
Filed as cc370#190.

Lower bound: the scan only sees modules with at most 8 diverging
addresses.

### #188: +2 in identities, and a module the heading does not show

`join_cont()`, the third and last card splitter, with the same
attribute-apostrophe guard. As an identity count, **+2** — a continued
statement with an attribute reference ahead of a remark is simply rare.
cc370 took it anyway, "because leaving one of three splitters wrong is
exactly how the next reader takes the family for done." Right.

**The line `length -> bytes : 1` was the more interesting part.** It
reads like a swap and is actually an improvement:

| `IEDQOB` | before | after | IFOX00 |
|---|---:|---:|---:|
| Distance to IFOX00 | 3,345 | **2,963** | — |
| Section length | 4,068 | **3,928** | 3,936 |

382 bytes closer, and the section length went from 132 too long to 8 too
short. The hand-over list still shows the module, the heading does not,
and without the third instrument it would have gone through as "a
module switched buckets."

The three "further" (`IFNX1J` +3, `IFNX2A` +7, `IFNX3N` +2) are 2–7 bytes
in decks that are 2,325 to 3,136 bytes wrong — measured here, not taken
on trust.

### Done: one bit in the RLD, +160 — and the cause was in the idiom

`docs/silent-divergences.md`, cc370#186, fixed in #187. **173 of the
1,242 handed-over modules differed from IFOX00 in nothing but their
Relocation Dictionary** — same `ESD`, same `TXT`, 163 of 175 diverging
entries in the flag byte alone, each off by exactly one bit (`0x04`), and
**152 of those the deck's last entry**.

**The cause was an idiom, not a computation error.** Every call site
wrote the width *after* the call:

```c
add_reloc(lc, r, 1); rels[nrel - 1].len = blen;
```

`add_reloc` bails out on `in_dsect` — and the assignment then lands on
the **previous** entry. In `IEAVELCR`, 24 real calls against 138 from
dummy sections: the last real relocation got overwritten 138 times and
kept the width of the last DSECT constant. Hence the one bit, and hence
"152 of 163 are the last entry" — the target of the overwrite is always
`rels[nrel-1]`. `len` is now a parameter, the idiom is gone from all
five sites and cannot come back through copying.

**+160 identities, none lost, zero closer, zero further.** The zero in
both directions is the signature of a defect that was never partial:
every affected deck diverged in exactly this one bit, so it moved
straight to identical or not at all. RLD-only fell from 173 to **13**,
the impossible cell from 27 to **1**.

**Which assembler was right could not be settled without the oracle.**
`IEAVELCR`'s table is `VL3` constants; `as370` gave 23 of them length 3
and the last one 4. It disagreed with itself, so IFOX00 is right and
nothing remains for `ifox-objections.md`. That is exactly why "it
disagrees with itself" was the sound observation, and not "IFOX00 is the
oracle."

No diagnostic tool could have pointed at this: both assemblers stay
silent, and both decks load to an image that is byte-identical to IBM's
shipped object. Found through a cell that cannot exist — 27 modules
where *both* decks hit IBM's object and differ from each other.

**And out of that, a limit on a number that appears often here:**
"byte-identical to the shipped object" means the **image** is identical,
not the deck. `cmplmd370` builds the loadable image. Some of the 1,015
carry a Relocation Dictionary that diverges from IBM's. Not a
retraction — the image is what runs — but the deck is not thereby
proven, and the two ideas have so far shared one sentence here.

### Twelve fixes in — 62.7 % to 78.7 %, and the first class emptied outright

Baseline `126d8d3`. **as370 == IFOX00: 3,737 of 5,528 (67.6 %)**, recovered
against IBM's shipped object **902**, hand-over list **1,841** (from 2,107).

| merge | identical | lost | closer | further |
|---|---:|---:|---:|---:|
| #164 + #165 | +93 | 0 | — | — |
| #166 (diagnostics order) | 0 | 0 | 0 | 0 |
| #168 (parenthesised adcon) | +24 | 0 | 69 | 9 |
| #170 (index subscript, grouping parens) | +58 | 0 | **178** | **1** |
| #171 (`L'` of a value-length constant) | **+95** | 0 | 229 | 1 |
| #172 (three more call sites of the same guard) | **+86** | 0 | 177 | 5 |
| #174 (the 63-character operand-field clamp) | **+92** | 0 | see below | see below |
| #175 (a relocatable `EQU` took its section from the card's position) | **+282** | 0 | 452 | 2 |
| #178 (a `USING` replaces the domain of its base register) | **+108** | 0 | 167 | **0** |
| #180 (a continued operand must also close its parentheses) | +24 | 0 | 90 | 5 |
| #182 (an attribute apostrophe is not a quote) | +23 | 0 | 50 | 1 |
| #183 (the same guard in the second splitter) | 0 | 0 | 0 | 0 |
| #187 (an RLD entry's length belongs to that entry) | **+160** | 0 | **0** | **0** |
| #188 (the same guard in the third splitter) | +2 | 0 | 4 | 3 |
| #189 (a character comparison ordered by length first) | +9 | 0 | 12 | 1 |
| #191 (an absolute `USING` domain was never consulted) | **+57** | 0 | 69 | **0** |
| #192 (documentation: control case and remainder rule) | 0 | 0 | 0 | 0 |
| #195 (`N'&SYSLIST` counted a representation, plus three table limits) | +4 | 0 | 77 | 17 |
| #198 (the `L'` of an `EQU` symbol was 1) | **+38** | 0 | 57 | **0** |
| #197 (comment fix) | 0 | 0 | 0 | 0 |
| #200 (an ESDID belongs to the ESD entry, not the symbol) | **+53** | 0 | 9 | **0** |
| #202 (omitted SS length, plus the absolute DSECT difference) | +11 | 0 | 19 | 1 |
| #204 (`sub[0]` of an SS instruction is the length, never a base) | **+47** | 0 | 52 | 2 |
| #206 (an `ENTRY` on a control section produces no `LD`) | +7 | 0 | 0 | 0 |
| #207 (macro frames moved from the stack to the heap) | 0 | 0 | 0 | 0 |
| #208 (a SET array is one row with a vector) | 0 | 0 | 0 | 0 |
| #212 (bounded copy in `set_put` — CI repair) | 0 | 0 | 0 | 0 |
| #214 = #213 (the CCW data address `*` is relocatable) | **+7** | 0 | 0 | 0 |
| #215 (`expr_sect` never terminated at a comma) | 0 | 0 | 0 | 0 |
| #209 (signed relocation pair) | +1 | 0 | 0 | 0 |
| #218 (`dc_split` read every apostrophe as a quote) | +2 | 0 | 4 | 0 |
| #221 (a grouping parenthesis hid the leftmost term) | 0 | 0 | 0 | 0 |
| #223 (`E` does not belong in the attribute-letter set) | 0 | 0 | 0 | 0 |
| #226 (an `EQU` does not sit at the location counter) | 0 | 0 | 0 | 0 |
| #227 (`ORG`/`CSECT`/`DSECT` listed the counter from before) | 0 | 0 | 0 | 0 |
| #231 (`CNOP` from an odd counter, and with no name field) | **+57** | 0 | 88 | **0** |
| #39 (`MNOTE` produced nothing at all) | 0 | 0 | 0 | 0 |
| #235 (`AIF` condition truncated at 126 characters) | +9 | 0 | 104 | 12 |
| #238 (`EQU C''''` evaluates to zero) | +12 | 0 | 26 | 1 |
| #240 (bit length modifier reserved nothing) | **+99** | 0 | 124 | 1 |
| #241 (comparison operator with no space not recognized) | **+67** | 0 | 84 | 3 |

**#180's +24 is the smaller half, and the larger half is a bracket, not a
number.** The mis-joined continuation was inventing operations out of
change-level tags — `XCTLTABL`'s operand broke inside an unclosed sublist and
carried the tag `Y02134` in as a sublist element, so a module whose only fault
was a line break was reported as using an undefined operation.

| Counting rule | Reach |
|---|---:|
| class files, deltas summed (`undefined-opcode` 51 -> 5, `undefined-symbol` 170 -> 135, `addressability` 42 -> 37) | **81** — upper bound |
| modules that stopped carrying **any** of the three, counted independently by cc370 (`e3f55f2`) | **33** — lower bound |

The class files hold each module once under its dominant diagnostic, so their
deltas are summable — but a module that merely *reclassifies* leaves one class
without becoming clean, and the sum counts it. The two bracket the same change.
The commit message of `9947ff6` states the upper bound as a result; this is the
correction. It is the class-proper-against-symptom distinction one level down,
and an identity count sees neither end of it.

**#174 needed a third instrument, and both of ours were wrong for it.** Widening
an operand field changes macro expansion, expansion changes layout, and a block
that is *correct but displaced* scores as wholly wrong when bytes are compared at
a fixed address. Judged on the declared section length, which a shift cannot
fake:

| | Sections |
|---|---:|
| **wrong -> correct** | **134** |
| closer | 76 |
| further | 23 |
| correct -> wrong | 2 |

The two are `IFG0196W` and `IEAVSWCH`, and neither was near recovery.
`IEAVSWCH` held IFOX00's exact length with **7,503 of its 10,938 bytes wrong** —
a correct length over entirely wrong content. So a length measure can flatter as
badly as a byte measure can condemn, and the honest report needs both. cc370
proposed the instrument; that caveat came out of using it.

**And a consequence for every population we have quoted.** A macro argument cut
at 63 characters changes what the expansion emits, so a construct could appear or
disappear from the expanded source depending on this defect. Every scan either
side ran before this commit measured `as370`'s truncated expansion, not the
program. Populations derived that way were lower bounds.

Baseline `6cddc98`: **as370 == IFOX00 4,329 of 5,528 (78.3 %)**, **1,002 modules
byte-identical to the object IBM shipped**, silent divergences 1,169 -> **682**,
hand-over list 2,107 -> **1,242**.

*The hand-over figure is whatever `for-cc370.tsv` holds — 1,242 rows, from 1,249
owned by the assembler less the 7 excluded. An earlier draft of this paragraph
carried 1,289, arrived at by subtracting a merge's gain from the previous figure
instead of re-counting the file. Derive it, and it drifts.*

Baseline `fdf7427`: **as370 == IFOX00 4,352 of 5,528 (78.7 %)**, **1,015 modules
byte-identical to the object IBM shipped**.

**#182 is the first change to empty a class outright, and it took a second one
with it.** An attribute apostrophe — the `'` in `L'A`, `T'&V` — was toggling the
splitter's quote state, so the state stayed inverted, the first blank read as
inside a string, and the remarks field was swallowed into the operand.

| class | before | after |
|---|---:|---:|
| #156 relocatable-displacement | 2 | **0** |
| #157 duplication-factor | 23 | **2** |
| #153 undefined-symbol | 135 | 119 |
| #159 symbol-over-8 | 8 | 7 |

#157 had not moved a module in eleven merges and was on the list of issues
nobody had touched; #182 was not aimed at it and took 21 of its 23. So "flat
across eleven merges" was a statement about where the attention went, not about
five independent defects.

**And the class files hid the completed fix.** `rebuild_classes.py` collected
into a `defaultdict`, so a class with no members was never written and its file
kept its last non-empty contents — `relocatable-displacement.txt` still named
the two modules #182 had just repaired. The one file the tool never rewrote was
the one where a fix had succeeded completely. It is the stale-class failure the
tool exists to prevent, arriving through the case where the news is good, and it
is the second time today a container's shape decided what a measurement could
say. Every class is seeded now and an emptied one prints `EMPTY`.

**#183 changes no deck and was still worth taking, and the gate found something
of its own while proving it.** 0 of 5,518 decks differ, verified by hash rather
than by verdict count. The second splitter feeds the listing and the
substitution, so its operand boundary decides whether a *remark* is substituted
— and IFOX00 leaves remarks alone. 2,030 bare `&` sit in open-code remarks
across 716 modules, and every one behind a string ending in `L T K N I S E` was
exposed the moment substitution becomes field-aware.

**And the run that proved it produced a phantom.** The gate reported one deck
more than the previous run, on a change that alters nothing: `IFCEE155` assembles
in **11.4 s** and the worker's alarm was 20 s, so under `-P 8` it finished
sometimes and was killed sometimes. Its deck is byte-identical either way.

The alarm is 90 s now — it costs one module's wall clock and buys a run that
repeats. **A gate that reports a difference no code produced is worse than a slow
one**, and this one had been doing it since the first tree-wide run.

**And the same run hid a real result behind the same count.** `no-as370-deck`
read `10 -> 10` across #182, so this tool reported that nothing had moved. Two
modules had moved, in opposite directions:

| | before #182 | after |
|---|---|---|
| `IFNX1A` | **does not finish in 240 s** | **0.06 s**, deck produced |
| `IFCEE155` | deck | killed by the 20 s alarm — a race, not the code |

Timed here against a `713ee9b` build, not taken on report. `IFNX1A` is a genuine
non-terminating module, it was never on cc370#163's list, and #182 — a fix aimed
at an apostrophe — ended it. The unterminated quote state evidently left a scan
without an end condition.

So cc370#163's "two modules that never terminate" was three modules, of which one
was never a defect, one is fixed by a change aimed elsewhere, and `HEWLDIOC`
stands — it does not finish in **300 s**.

[`regression-gate.md`](docs/regression-gate.md) already said a count cannot see
two modules moving in opposite directions. It said it about verdict counts, and
the deck count has exactly the same shape; the warning was one line above the
number that was lying. `retest.py` names both directions now.

**cc370's own suite stayed green through a version that cost 96 identities.**
The obvious fix reused a purely lexical predicate, which reads the *closing*
quote of a string whose last character is an attribute letter as an attribute
apostrophe — `'S'` in `AMDPREAD` card 327. None of their 743 corpus modules
contains such a string. This is the first time the corpus blindness we have both
been describing let a real regression through rather than merely failing to show
a gain, and the gate caught it on the `LOST` line.

**#178 is the only change today with no regression on any instrument** — none
lost, none further by bytes, section lengths unmoved. And it settles the
`USING`-rekey hypothesis this session pushed for #154: the defect is real, the
neighbourhood was right, and it closes **one** of #154's 40 residual modules. The
6-of-156 count is the only thing that kept the two apart; plausibility would have
merged them and buried a +282 fix inside a +108 one.

`IDA019R2` — the witness offered here for the silent class and correctly rejected
as belonging to a different issue — is among the 108 and is now byte-identical.
Right module, right mechanism, wrong issue.

**#175 is the largest single change and it corrected three of our guesses.** The
class had sat still through eight merges, which was read here as evidence for the
`USING` rekey. It is not: a relocatable `EQU` took its section from *where the
card sits*, and PL/S output puts every `EQU` at the end of the module, after a
mapping macro has left a DSECT current. A CSECT label booked into a DSECT then
either finds no `USING` in range — the `IFO209` the issue reported — or finds the
wrong section's and takes that base register **silently at rc 0**. One line, two
symptoms, +282.

Corrected with it: the `USING` table being append-only is *not* the cause of this
class (only 6 of 156 modules carry 32 or more `USING` cards) and wants its own
issue; `HEWLDIOC` still does not terminate, so #163 is untouched; and `IDA019R2`,
which this session offered as the witness for the silent class, is not in the
addressability class at all — it belongs to `rx-index-dropped`. The behaviour it
was cited for is real and now pinned by cc370's `tests/equsect.s`; the module was
the wrong example.

#172's five are the same shape as before but at a larger scale, and were weighed
individually: `IEBVMS` 77 % wrong -> 80 %, `IGC0M05B` 90.5 % -> 94 %,
`IFG0191Y` 4.9 % -> 7.6 %. Every one is dominated by another defect; the fix
changes bytes inside a region that is wrong either way.

**Two defect classes neither instrument here can see**, reported by cc370's sweep
and worth keeping because the reason is structural:

- `set_canon()` takes the first `)` of a subscripted SET label. **Zero modules in
  our 5,528** — but twelve damaging labels in real IBM macro source
  (`ATCAMMAC/LINEGRP`, `INVLIST`, `INVLIST1..6`). No module in the corpus loads
  those members, so no deck can point at it. A TCAM-generation module added later
  would hit it silently at `rc 0`.
- The eight `IFC*` modules die on a fixed 4,096-entry global SET-symbol table
  ([cc370#173](https://github.com/mvslovers/cc370/issues/173)). They produce no
  deck, so they are invisible to every deck comparison — ours — and absent from
  every scan of as370 output — theirs. They sat in this table for a day as
  "aborts at rc 2" with no cause. IFOX00 assembles all eight at `rc 0`.

**#170's row is corrected**, and by cc370 finding the fault in a measure I had
built from their idea. The distance in `retest.py` walked the deck's *cards* and
charged a whole card for a card-count difference — so a fix that gives a section
its **correct** length read as a regression. `IFNX4S` went to exactly IFOX00's
length and scored +71. Measured on the address-keyed section image instead, #170
moved 178 decks closer and **one** further, not six.

**Nothing has been lost in any of them.** The "further" columns were weighed,
not netted: every one lands inside a TXT card already carrying 8 to 799 wrong
bytes, where a previously wrong value happened to coincide with IFOX00's byte.
The assembler computing the right value is the point; the coincidence was not
worth defending.

#170 also carried a second defect of the same family, found while fixing the
first: a displacement parenthesised for *grouping* was taken as a subscript
list. `SLL R11,24-(8*((A-B)-(((A-B)/4)*4)))` gave `ff fe 00 18` — not even a
valid instruction — where IFOX00 gives `89 b0 00 18`. Silent, and not in any
catalogue of ours.

cc370#168 (an address constant whose value starts with `(` is not zero) was the
first change accepted on more than the verdict counts: +24 identical, none lost,
**69 decks closer to IFOX00 and 9 one byte further**. The nine were weighed
rather than netted — each sits inside a region IFOX00 leaves as zeros and our
macro fills, so the new byte is the correctly computed value in a block that is
wrong for a different reason. `retest.py` now reports that distance, because a
change that improves wrong code without reaching identity is invisible in the
verdict counts.

**A guessed population is a subset.** My class file for #167 was the 35 modules
carrying `DC Y((` in their cards; the fix moved **79**, and the other 44 receive
the construct through a macro where no card shows it. The measured set replaces
the scanned one: `classes/parenthesised-adcon.txt`.

Two filed from the silent class, both with a three- or six-card reproducer
measured against IFOX00 on MVSCE-EXP:

- [cc370#169](https://github.com/mvslovers/cc370/issues/169) — an index register
  written as `((1),0)` is dropped, **and the base with it**. Byte signature:
  962 sites in 277 modules.
- [cc370#148](https://github.com/mvslovers/cc370/issues/148) gets its reach —
  `MVC` length from `L'symbol` comes out zero. 1,016 sites in 192 modules.

These two are the largest signatures in the silent class by some distance;
everything else visible there is under 50 modules.

### Three fixes in; the gate is now the release path

cc370#164, #165 and #166 are merged (`3d6a997`), each measured here before the
merge. **Mike delegated the merge decision to this session on 2026-09-07**, so a
cc370 PR is confirmed and merged here after a gate run, not escalated.

#166 (diagnostics in source order, statement named) is the first change accepted
on a *no movement* claim, and that needed a stricter test than the verdict
counts: **0 of 5,518 decks differ by sha256**, and all seven Package A class
memberships unchanged, both binaries built and classified here.

### The first two fixes are in, and re-baselined

cc370#164 (`.*` is a comment card in `parse()`) and cc370#165 (IPK and PTLB take
no operand) are merged as `879e86a`, confirmed here by an independent rebuild,
and everything is re-measured against that build.

- **+93 byte-identical to IFOX00, none lost** — 3,466 -> 3,559 (64.4 %)
- **+10 recovered**, all three decks agreeing — 869 -> 879
- **all 93 gained modules were rows this table had booked to the assembler**, not
  one to the source. The first independent evidence the ownership column means
  what it says.
- the hand-over list falls 2,107 -> 2,016

**A fix reclassifies as much as it removes.** Package A lost 146 modules: 93
became identical and **56 moved into the silent-divergence class**, which is
harder. Package D grew 84 -> 96. `Relocatable displacement` grew 29 -> 44,
because modules that used to fail earlier now reach it.

Two figures must not be inherited — see
[`regression-gate.md`](docs/regression-gate.md): the "56 modules" for the IPK
class is a superset, the traced number is 48; and the reach figures for the
fourteen unfixed mechanisms in cc370#153's comment are owned by a first
diagnostic and therefore unsound while as370's output is category-ordered.

### What is in the tree that is not in the system

[`docs/module-origin.md`](docs/module-origin.md) — per module, which
distribution library holds its object and whether MVS/CE carries a load module of
that name.

- **CICS: 5 modules excluded.** `BNGC3270`, `BNGCDISP`, `BNGCLOCL`, `BNGCMENU`,
  `BNGCRMOT` call `DFH*` macros; there is no CICS here and none of the five is
  installed. They keep their row with the reason in an `excluded` column and drop
  out of the hand-over list: **2,112 owned by the assembler, 2,107 handed over.**
- **Sort: 251 `IER*` modules, decision open.** No object in any distribution
  library, no member of any target library, and **there is no sort library on the
  instance at all**. They can never be verified. 243 of them already assemble
  identically between `as370` and IFOX00, so excluding them costs the hand-over
  list 8 modules and takes 4.5 % out of a denominator no measurement can settle.
- **The member-name test undercounts** and must not be read as "not installed": a
  CSECT is usually bound into a load module of another name.

### The second corpus — run, and what it did and did not give

`mvssrc` has `handover/not-in-mvsbld.tsv` ready: the 1,025 members their tapes
carry that `MVSBLD` does not, with tape, tape file, SSI, prefix and chosen
variant. **It is not 1,025 measurable modules and must not be quoted as one:**

| | Members |
|---|---:|
| **module — produces a CSECT, has a DLIB object: a byte verdict is possible** | **16** |
| module, no object to compare against | 169 |
| macro — meaningless standalone, needs a driver or a library | 590 |
| dsect / `COPY` member — no CSECT, but exercises the same expression evaluator | 250 |

**185 modules, not 428.** `mvssrc` first classified by the member's *first*
statement — not `MACRO`, therefore source — and PL/S members like `IHASPCT` open
with comment text and a `%GOTO` and carry their `MACRO` further down. 15 macros
were counted as source and 22 members with a real `CSECT` as macros. They found
it while re-deriving our blocker figure independently, and they say plainly what
let it through: their control only asked whether a *macro* had an object, never
whether a *source* was a macro. One-directional, so it could not see this.

The corrected classification is checked both ways: no macro and no dsect has an
object, and every member with an object is a module.

Worth running anyway: the **250 dsects**. They produce no CSECT and so admit no
verdict, but they drive the same expression evaluator, which is where most of
this session's defects were found.

⚠️ **And a trap they marked before we could walk into it.** 129 of the 1,025 are
the members with the missing comment star, 122 of them `kind=source` — 12.6 % of
this corpus against 2.2 % of the tree. A message count over it would show
`INVALID OPERATION CODE` heavily overrepresented and it would look like a finding
about the corpus. Filter on `blank_comment_marker = yes`.

**The blocker count is confirmed twice.** `mvssrc` re-derived our 51-operation
figure independently and got the same four hits: `ISDAFSPC` (27 modules),
`IHASPCT` (7), `IHASHDR` (1), `IECDSCD` (1). The largest of the 47 that are
missing there too: `IHANVT` (33), `DSGEN` (33), `LINE` (33), `UCBDADVC` (32),
`ILRAIA` (30), `ROUTINE` (28). Two computations from different data, one answer.

**Released 2026-09-07 and run.** 435 members (185 modules + 250 dsects) through
`as370`, macros unchanged so the figures stay comparable:

| | |
|---|---|
| assemble at `rc 0` | 97 of 435 |
| the 16 with a DLIB object | **3 identical** (`XTB1GFC`, `XTB1GSC`, `XTB1GUC`), 12 length, 1 mixed |
| dominant message | `Undefined operation code`, 198 — macros we do not have, not a defect |

The three identical are in `src/`. The rest of the corpus is dominated by the
macro gap rather than by assembler defects, which is itself the answer: **this
material cannot be assembled without macros nobody has.**

**The blocker name-check is negative.** Of our 51 unresolvable operations exactly
**one** is among the 590 macros the tapes add — `ISDAFSPC`, and it is the
deliberately empty one. The other 50, `IHANVT` and `UCBDADVC` and the EREP family
among them, are absent from the tapes as well. That direction is now closed with
two independent derivations agreeing.

**And the answer to whether dsects are the better test piece: no.** They were
worth running and the hypothesis does not hold —

| | Members | `rc 0` | carrying an evaluator message |
|---|---:|---:|---:|
| module | 183 | 30.1 % | **23.5 %** |
| dsect | 134 | 31.3 % | 17.9 % |

A dsect is mostly `EQU` and `DC` and was expected to press harder on the
expression evaluator. It presses less. The construct that breaks an evaluator
lives in the code around the data, not in the data.

### The reference is not sound everywhere — and that is the next work here

**IFOX00 flagged 933 of the 5,528 modules at `rc 8` or worse, so their decks are
a doubtful reference.** 495 of the 3,466 `as370`==IFOX00 agreements and 477 of
the 2,112 cases handed to cc370 rest on one. The 869 recovered do not — IBM's
shipped object settles those independently.

Two classes of it are ours to fix, and fixing them opens a loop: a better
reference exposes differences that were hidden behind the flawed one, and those
are new cases for cc370.

- **197 modules, `IFO078` UNDEFINED OP CODE — 51 operations no library of ours
  has.** `IHANVT` (33 modules), `UCBDADVC` (32), `IECDCST` (11) were already
  listed as missing below; now their reach is known. A whole EREP family
  (`DSGEN`, `LINE`, `ROUTINE`, `BIN`, `HEX`, …) blocks 33 more.
- **225 modules, `IFO092` keyword undefined — macros at the wrong level.**

Written up as a standalone brief, meant to be worked in its own session:
[`docs/ifox-objections.md`](docs/ifox-objections.md).

### A source-side finding out of the same run, and it does not wait

**Our `MODID` is not the level the source was written against, and now it is
measured.** 112 modules call `MODID` with `DATE=` or `PTF=`. The only `MODID` we
have — MVS/CE 2.1.4 `AMACLIB`, the same library IFOX00 reads — has the prototype
`&LABEL MODID &BRANCH=,&BR=` and defines neither keyword, while its own comments
name the PTF that added `PTF=` support (`OZ15314`). IFOX00 flags every one of
those calls with `IFO092`; `as370` says nothing, which is
[cc370#162](https://github.com/mvslovers/cc370/issues/162), but the macro level
is ours.

`MODID` is also one of the macros that stamps the assembly date into the object,
so this sits directly on top of the 302 timestamp-bearing modules. Smallest case:
`IECVOID`, three cards.

### The hunting list for the missing macros

[`docs/missing-macros.md`](docs/missing-macros.md) and
[`missing-macros.tsv`](work/measurements/missing-macros/missing-macros.tsv):
**40 operations neither assembler can resolve, blocking 204 module–operation
pairs**, each with its module list and the record of where it has already been
searched — our 1,822 macros, the IBM tapes, stben's 1,761, mainframe.eu, and
Dave Kreiss' `NEW.ASM`. Two independent derivations agree on the negative.

Largest: **`TABLE`** with 48 `XTB*` modules (all with a DLIB object, on Kreiss'
install tape) and the **EREP family** — `DSGEN` 31, `PROLOG`/`LINE` 11 each,
`ROUTINE` 10 — which is one find rather than five, since the same modules call
all of them.

**`IHANVT` and `UCBDADVC` have dropped off this list.** cc370#174 removed a
63-character clamp on operand fields, and the modules that appeared to need them
now get far enough to resolve them from a library we already had. Every earlier
count was measuring `as370`'s truncated expansion rather than the program — a
missing-macro list is only as good as the assembler that produced it.

### Waiting on other people

- **Dave Kreiss — his macro libraries are now the single largest blocker**, and
  decision 5 makes them a precondition rather than a convenience. Four macros are
  known to exist at a level none of our libraries carries: `ESTAE`, `STAX`,
  `SCHEDULE` and — measured 2026-09-14 — `TSCBD`. Together ≥24 modules, two of
  them one byte away. **The 2026-09-13 mail is still unsent** and asks about
  `ESTAE`; `TSCBD` is a new, sharper instance of the same question and is not in
  it yet.
- **Dave Kreiss — mail sent 2026-09-12**
  ([`docs/mail-kreiss-2026-09-12.md`](docs/mail-kreiss-2026-09-12.md)). Three
  asks, and **none of them blocks host-side work**:
  * **the `./ DELETE` question** — SMP here refuses it, which costs 485 of his
    SYSMODs and leaves 486 modules without their `DSK` markers;
  * **five macro items**, the largest `TABLE` at 45 measurable `XTB*` modules;
  * **his rebuilt `PVTMAC`/`APVTMAC`**, still the only route to settling the
    maintenance level of 319 of our macros — until then every length difference
    in those modules has two explanations.
- **mainframed767** on an MVS/CE 3.0.1 — sent 2026-09-06, follow up in ~4 weeks.

### Controls that must not be dropped

Every one of these caught a wrong finding today:

- **Pass all 80 columns** when feeding assembler source anywhere. Column 72 is
  the continuation; cutting at 71 produces `IFO035` everywhere and looks like a
  source defect.
- **Both sides must see the same macro libraries.** Local `-I` uses
  `SYS1.AMACLIB` (566 members); `SYS1.MACLIB` on MVS is the *target* library with
  742. The matched `SYSLIB` is in [`docs/ifox-oracle.md`](docs/ifox-oracle.md).
- **Check that a deck belongs to its module** — first section name against member
  name. `SYSPUNCH ... DISP=SHR` leaves the previous deck in place when a step
  fails, silently.
- **Never `SYSPRINT DD DUMMY`.** The diagnostics decide whether a deck is an
  authority at all.
- **In zsh, build flag lists as arrays** and pass `"${arr[@]}"`. An unquoted
  variable arrives as one argument.
- **`grep` here is `ugrep`, and it returns nothing on MVSBLD members** — no
  count, no error. Use `/usr/bin/grep`, `rg`, or Python. An empty result is not
  evidence of absence; it hid a `COPY` chain for half a day.
- **Pin `ASMDATE`/`ASMTIME` and drop the `END` card** before comparing decks from
  two runs. 381 decks carry the stamp; every deck carries the date.

### Small and named, still open

14 `AMACLIB` elements missing from `SYS1.AMACLIB`; `IHANVT`, `UCBDADVC`,
`IECDCST` with no `++MAC` element; `ACCESS`, `IQAMOD`, `IQAQAL` nowhere on this
machine; the 22 members carrying an `X'10'` scatter record, now readable but
never verified against a rebuild.

---

## Immediate

### 1. ✅ Licensing settled — Dave Kreiss answered on 2026-09-06

**Freeware, no copyright, no terms.** His words: *"it is ok to release it as
freeware with no copyright or terms — that is it is open to anyone to use as
desired."* The same goes for the utility source on the install tape.

- [x] Sent (2026-09-04), answered (2026-09-06)
- [x] **Publication is unblocked** — the repository may go public
- [ ] Credit him **by name and email** on the material and in the repo
- [ ] **Keep `UTL31` out of publication.** It descends from the CBT file 217
      disassembler (R. Thornton) and he does not know its terms either. He
      distributes it but does not assemble it, so nothing depends on it
- [x] **Replied on 2026-09-06.** It asks for his built `PVTMAC`/`APVTMAC` on the
      new install tape — and that request has since turned out to be the *only*
      route to those macros, see [`docs/private-macros.md`](docs/private-macros.md)

**What else his mail says:**

- All target libraries assemble to match TK3 **except `SYS1.LINKLIB` and
  `SYS1.LPALIB`**, the two largest. He has IPLed and run a system with the
  rebuilt libraries.
- **He is rebuilding the install tape**: current documentation, utility source,
  Tom Armstrong's SORT put into SMP format, and source for some compilers
  (COBOL and FORTRAN). Worth waiting for before any large re-baselining.
- The ask that goes with it: **`MVSSRC.BLD.PVTMAC` / `APVTMAC` on the new tape**,
  which would replace our 320 mirror macros with ones at a known level.

### 1a. ✅ Current BLDMVS package reconciled

The 2023 package is on disk and unpacked; the 2021 one is kept beside it.

| | old | new |
|---|---|---|
| location | `Dave Kreiss - MVS from Source/BLDMVS#2021/` | `…/BLDMVS/` |
| instructions | 2020-07-05 | **2023-08-06** |
| `BLDMVS.AWS` | 2021-09-16, 190 MB | **2023-12-01, 191 MB** |
| `NEW.ASM` on tape | 31 MB | **43 MB** — plausibly the DSS370 work |
| `UTL.ASM` on tape | 4.2 MB | **5.3 MB** |

The archive is `~/repos/MVSSRC_BAK/BLDMVS.7z`. No 7z tool is installed, but
**`tar -tf` / `tar -xf` read it** (bsdtar handles 7z).

**What changed in the instructions (762 lines differ):**

- **New: a TK5 section** — install the TK5 source and CBT option, RAKF profiles
  for `MVSSRC.BLD.*`, Hercules config for the build volumes.
- **`MAINT05F` no longer submits its successor.** The step that copies the new
  SMP into the running `SYS1.LINKLIB` is commented out; uncomment it or submit
  `MAINT05Z` by hand. Anyone replaying the build will trip over this.
- **The S106-F appendix is gone entirely** — 11 mentions in 2020, none in 2023,
  and "no failures except the occasional S106-F" became just "no failures". The
  sporadic build aborts seem to have gone away with newer Hercules.
- **Dave got more pessimistic:** "little chance of working correctly" became
  "**no** chance" for LINKLIB, LPALIB, VTAMLIB and TELCMLIB.
- **Newly tested:** 3350 *and* 3390 mod 1 as system residence.
- Appendix C statistics are **unchanged**, so no further modules were completed
  between 2020 and 2023.
- A documentation bug: the Phase 4/5 headings gained parenthetical labels that
  are swapped — "Phase 4 (LPALIB…)" describes `DSKK000` → LINKLIB. The body text
  is right.

### 1b. ✅ Instances run MVS/CE v3.0.0

`SYS1.PARMLIB(RELEASE)` on 2026-09-04: **LAB and EXP are v3.0.0**, `MVSCE-DEV` is
v2.1.4. mvsMF on LAB and EXP has been updated by the user and now reports
`zosmf_version: "1"` with a `plugins` field, like DEV.

- [ ] **Open decision:** the baseline for comparison. Our instances are 3.0.0;
      the pristine copy extracted on `mvsdev` (`~/tmp/mvs38src-work/`) is 2.1.4.
      If the DLIB hypothesis holds this hardly matters — but it should be settled
      rather than drifting.

### 1c. ✅ libc370 v1.0.4 released, all four packages relinked

Done 2026-09-06. The SYNAD fix is in — an I/O error used to end the address
space with `S001` instead of being passed up as `ferror()`+`EIO`.

- [x] Cut libc370 v1.0.4 and relink httpd, ufsd, ftpd, mvsmf
- [ ] Give mvsmf a stable `v1.0.0` rather than only the `v1.0.0-dev` pre-release

Never was on our critical path — we build no C programs for MVS — but it is the
precondition for item 1d, which is now sent.

### 1d. ✅ Asked mainframed767 for an MVS/CE 3.0.1 — sent 2026-09-06

Sent after 1c, so the version table names current releases rather than stale
ones. Draft kept in `~/repos/MVSSRC/WORK/doc/mail-mainframed767-mvsce-301.md`.

**The regression argument was withdrawn before sending** — there is no JES2
regression in v3.0.0, that was our own broken job cards. What went out is the
package-level lag plus three operational findings:

- `SCRIPTS/SHUTDOWN.RC` stops neither HTTPD nor FTPD
- nothing starts them either — no `S HTTPD` anywhere in the repository
- which HTTPD lands in the build is ambiguous: `MVP/desc/HTTPD` says 4.0.0,
  `MVS-sysgen/SOFTWARE/HTTPD` holds `HTTPD330` from 2025-02-13

- [ ] Follow up once after ~4 weeks, then let it rest

### 2. ✅ Repo created

- [x] `git init`, base structure
- [x] **`.gitattributes` with `* -text` and `*.asm binary`** — before the first
      commit. Forget it and Git normalizes the CRLF and the 80-column records,
      and from then on we compare artifacts of our own toolchain
- [x] `README.md`, `CLAUDE.md`
- [x] `.gitignore`: DASD images, `*.AWS`, web mirrors stay out
- [ ] Repo stays **private** (see item 1); no remote until then

### 2b. ✅ The cc370 toolchain — built, not just requested

What was five issues on 2026-09-04 is largely working code on 2026-09-06.

| # | | State |
|---|---|---|
| [#109](https://github.com/mvslovers/cc370/issues/109) | `libobj370` / `libmvs370` | **readers done**; the emitters remain and are on nobody's path |
| [#110](https://github.com/mvslovers/cc370/issues/110) | `cmplmd370` | **built and in use** — comparison, `--clearrld`, `--csect`, `--difin`/`--difout`, `--json`, hole classification |
| [#113](https://github.com/mvslovers/cc370/issues/113) | reading a foreign IEBCOPY unload | **solved**, and the format is documented in [`docs/private-macros.md`](docs/private-macros.md) |
| [#111](https://github.com/mvslovers/cc370/issues/111) | `idrdump370` | open — the 102-member dataset for it is committed |
| [#112](https://github.com/mvslovers/cc370/issues/112) | `dasm370` | open, and still not needed until case D is sized |

**Six `as370` defects closed the same day**, every one measured against IFOX00
rather than argued from the manual:

| | | modules unlocked |
|---|---|---:|
| #127 | `START` not implemented | 75 with #128 |
| #128 | `ISEQ` not implemented | " |
| #108 | `DC/DS` type `S` | 44 |
| #132 | **`&SYSECT` expanded to nothing, silently** | 39 — *and it corrected 80 decks that already assembled* |
| #133 | cross-section duplication factor silently zero | 0 — it changes a return code, not bytes |
| #136 | **each control section needs its own location counter** | ~80, and the `IDCCD*` family came back |
| #138 | base-register tie broken the wrong way | 3 |

`START`, `ISEQ`, `DC/DS` type `S` and the location counter behave like blockers —
close them and modules go through. **`&SYSECT` and the base-register tie
unlocked almost nothing and mattered most**, because they corrected object code
the assembler was already producing, silently and wrongly. See
[`docs/as370-gaps.md`](docs/as370-gaps.md).

One issue in that series, #131, was **wrong**: filed from an error message
without reproducing the case. It is closed with that stated.

### 2c. Dave Kreiss' utilities — extract, read, do not port

His nine utilities are **not** among the 5,529 `.ASM` files in `MVSBLD/`. They
live only on the `BLDMVS.AWS` tape, in `MVSSRC.BLD.UTILITY.ASM` (file 5).

**We do not need to port them.** They are MVS-side tools that our host-side chain
replaces:

| Dave's tool | Replaced by |
|---|---|
| `COMPLMD` | `cmplmd370` (#110) |
| `LOADLMD`, `MAPLMD` | `libobj370` / `file370` (#109) |
| `LMDXRF38`, `LMDRPT38` | our own inventory pipeline |
| `MVSASM38`, `MVSLKD38` | only needed if we run SMP builds ourselves |
| `MVSSMP38` | possibly useful in M7 — it parses SMP output for per-step errors |
| `MACCVT` | prior art for making case-D modules readable; Dave calls it "a twisted piece of code" |

**But the source is worth reading as a specification.** `COMPLMD` defines the
`DIFIN`/`DIFOUT` semantics and `CLEARRLD` that #110 has to reproduce, and
`MACCVT` documents the PL/S conversion rules. Extracting them costs one `hetget`
run and gives the comparator a reference implementation to check against.

- [x] **The tape is readable without Hercules.** `BLDMVS.AWS` is a plain AWS
      tape; a 40-line host reader walks it. Structure confirmed: standard labels,
      15 data files, `UTL.ASM` is file 5 (914 blocks, 4.19 MB, an IEBCOPY unload)
- [x] **Get the members out of that unload — done, 2026-09-05.**
      [`tools/pdsunload.py`](tools/pdsunload.py) reads the unload member by
      member; `UTL.ASM` yields 64 members. cc370#113 stays open for `file370`,
      but it no longer blocks us. The header layout and the control case are in
      [`docs/private-macros.md`](docs/private-macros.md)
- [ ] Read `COMPLMD` before implementing #110 — especially how it decides what
      counts as a difference
- [ ] Keep the extract as reference material; **no MBT project, no port**
- [ ] Revisit `MVSSMP38` when M7 comes around

### 3. ✅ Tooling — extract on `mvsdev`, process on the Mac

Hercules **cannot be built on the Mac** (arm64): it compiles with
`--with-included-ltdl` and permissive CFLAGS, then fails to link because the
external packages ship prebuilt for x86 only and their CMake build script does
not work on this layout. Docker is not installed either. Abandoned deliberately.

**`mvsdev` has everything** in `/usr/local/hercules/bin`: `dasdls`, `dasdpdsu`,
`dasdseq`, `dasdcat`, `hetget`, `cckd*`. Reach it with `ssh mvsdev`.

The working split: **extract on `mvsdev`, process on the Mac.** Extraction needs
no running MVS, only the volume files, and happens once per artifact. Unpack a
pristine release into a scratch directory rather than reading a running
instance's volumes — `~/tmp/mvs38src-work/` holds one (2.1.4).

⚠️ **Two traps in `dasdpdsu` output**, both hit on 2026-09-04:

1. It writes **raw EBCDIC with no record separators**. Members are RECFM=FB 80,
   so split into 80-byte records first.
2. Convert to a **single-byte encoding** — `cp037` in, `latin-1` out. UTF-8 turns
   EBCDIC `X'5F'` (`¬`) into two bytes and shifts every column after it, which
   silently breaks column 72 and therefore the continuation rule.

Also useful: `BLDMVS.AWS` is a plain AWS tape and a 40-line host reader walks it
without Hercules at all.

- [x] Hercules utilities available (on `mvsdev`)
- [x] `as370` confirmed current — `as370/src/` unchanged since the installed build
- [ ] Build `cc370` freshly when `cmplmd370` lands

### 4. ◐ MVS/CE baseline — partly done

- [x] Pristine 2.1.4 unpacked on `mvsdev` at `~/tmp/mvs38src-work/MVSCE/DASD/`
- [x] **DLIBs confirmed on `smp000.3350`** — 34 `AOS*` libraries, exactly the set
      in Dave's appendix C. Also `SYS1.AMODGEN`, `SYS1.SMPCDS`, `SYS1.SMPPTS`,
      `SYS1.UMOD*`, `SYS1.HASPSRC`
- [x] Macro libraries extracted: `SYS1.MACLIB` (742), `SYS1.AMODGEN` (288),
      `SYS1.APVTMACS` (242)
- [x] `retcode` works — it needed a complete job card, nothing else
- [ ] Immutable snapshot with checksums → `baseline/checksums.txt`
- [ ] Inventory the baseline → `baseline/mvsce-*.md`: usermods, MVP packages,
      sysgen parameters, I/O gen
- [x] **Evaluate the SMP CDS: which sysmods are ACCEPTed?** — done, 2026-09-06,
      [`docs/accept-status.md`](docs/accept-status.md)
- [ ] Verify the runbook on a first full pass, raising 📄 to ✅

### 4b. ⚡ Set up the instances on `mvsdev.lan`

Three MVS/CE instances, each Hercules in its own tmux session (roles and
rationale in [`docs/runbook.md`](docs/runbook.md), section 6):

| Instance | Purpose |
|---|---|
| `mvsce-lab` | all other projects, permanently available — **off limits to the agent** |
| `mvsce-src` | this project: PTFs, APPLY/ACCEPT, IPL test |
| `mvsce-exp` | this project: experiments, above all SMPWRK3 reproduction |

- [ ] Decide the port allocation for three instances — **the reader ports are the
      known collision trap** (`MVP/MVP.ini`, see `~/repos/mvs/REFCARD.md`)
- [ ] tmux session names and start scripts per instance
- [ ] Write and test the "recreate an instance from the template" procedure
- [ ] Set up mvsMF access over the network for the agent
- [ ] Decide where the baseline template lives (Mac or `mvsdev.lan`) and how the
      checksums stay consistent across both

**Not on the critical path.** The instances are needed only from M7 on. M0 and M1
need the volume files, not a running system — so the end-to-end test in item 5
works with the local 2.1.4 already.

### 5. ✅ End-to-end test: done, and it went further than one module

Host-side extraction holds up. `dasdcat` reads distribution-library members with
no MVS running; `file370` walks them (CESD, IDR, control, text, MODEND); `as370`
produces object decks from Dave Kreiss' source; and the two sides can be compared
on section names and lengths **without a comparator existing yet**. 102 pairs
measured, 49 of them matching. [`docs/dlib-distance.md`](docs/dlib-distance.md).

The one correction it forced: the `AOS*` libraries hold **load modules**, not
object decks. Everything downstream follows from that.

The original checklist, with what actually happened:

- [x] Pull a module out with **no MVS running** — `dasdcat`, not `dasdpdsu`;
      the latter cannot read a RECFM=U library at all
- [x] `file370 -v` shows the record structure — CESD, IDR, control, text, MODEND
- [x] Read out sections and IDR records — done for 102 members
- [ ] Check one by hand against the same module on the running system — still
      worth doing once, as an independent check on the whole host-side chain

---

## What exists now that did not on 2026-09-04

Written up rather than remembered, because most of it is method rather than
result:

| Document | What it settles |
|---|---|
| [`docs/tree-wide-run.md`](docs/tree-wide-run.md) | the two tree-wide runs, and the numbers that count |
| [`docs/ifox-oracle.md`](docs/ifox-oracle.md) | how to ask the real Assembler XF a question, and every answer so far |
| [`docs/as370-gaps.md`](docs/as370-gaps.md) | six assembler defects, what each was worth, and one issue that was wrong |
| [`docs/private-macros.md`](docs/private-macros.md) | where the private macros are, and how to read an IEBCOPY unload |
| [`docs/complmd-spec.md`](docs/complmd-spec.md) | `COMPLMD` read as the specification for `cmplmd370` |
| [`docs/accept-status.md`](docs/accept-status.md) | the DLIBs carry the maintenance; MVS/CE modifies 28 modules |
| [`docs/dlib-distance.md`](docs/dlib-distance.md) | section lengths, `SPZAP` records, and whether another source copy fits better |
| [`docs/what-is-not-blocked.md`](docs/what-is-not-blocked.md) | how much of the backlog does *not* wait on Dave Kreiss' tape |

And the tooling in [`tools/`](tools): `awstape.py`, `pdsunload.py` (reads a real
MVS unload member by member), `measure-as370.sh`, `ebcdic2text.py`.

**A method worth carrying into every measurement here**, learned about ten times
in one day and in both sessions: *something delivers less than it should and does
not say so.* A truncated listing, an unquoted shell variable, a fixed array of
64, an implausible mutant, a listing that decides nothing because both hypotheses
give the same answer, `dasdcat` writing to stderr, `dasdpdsu` stopping at the
first illegal filename. **Every one was caught by a control case, never by the
tool.** Before a number is believed, construct the case whose answer is already
known and run it on both sides.

## Then: inventory and feasibility

### 5b. 🚪 Measure the DLIB hypothesis: MVS/CE against TK5

**Cheap, early, and the outcome changes the statics of the project.**

Hypothesis: all turnkey distributions sit on the same IBM DLIBs. Differences
arise only through sysgen and usermods — and those affect the *target*
libraries, not the DLIBs. The one exception: sysmods installed by **ACCEPT**.

Both sides are available locally:

| System | DLIB volume |
|---|---|
| MVS/CE | `smp000.3350` |
| TK5 | `tk5dlb.392` (`~/Downloads/mvs-tk5/dasd/`, 30.5 MB) |

- [ ] `dasdls` over both volumes: which `AOS*` libraries exist, same member
      counts?
- [ ] Cross-check at the root: did both process the same `ptfs.het` level and the
      same Morrison usermods? (see the plan, section 5)
- [ ] Extract the object decks and compare CSECT by CSECT
- [ ] Hold divergences against both systems' SMP CDS — are they ACCEPTed sysmods?
      (our side is measured now, see [`docs/accept-status.md`](docs/accept-status.md))
- [ ] Record the outcome in `baseline/dlib-comparison.md`

**If the hypothesis holds**, our output is source for **MVS 3.8j**, not for our
MVS/CE — distribution-independent. The reference-release question then largely
dissolves, and Dave's DLIB-level results do carry after all.

**If it does not hold**, we get a list of affected elements instead of an
uncertainty — also a usable result.

### 5c. 🚪 Examine `ptfs.het` — the measurement with the greatest leverage

**Correcting an earlier assumption:** the IBM PTFs are not lost. The MVS-sysgen
project ships `tape/ptfs.het` with **1,482 PTFs for MVS 3.8j**, and
`jcl/smpjob03.jcl` ("ACCEPT FMIDS/PTFS") installs them into the DLIBs via
`ACCEPT G(fmid)`. So the object code carries them — the source does not.

The decisive question: **do these PTFs contain `++SRC`, or only `++MOD`?**

- [ ] Obtain `ptfs.het` (in the sysgen repo, 14.2 MB) and unpack it on the host
- [ ] Count: how many of the 1,482 PTFs contain `++SRC` elements?
- [ ] If any: which modules do they touch, and do they overlap our
      `DIFF-UNKNOWN` cases?
- [ ] Record the outcome in `baseline/ptfs-analysis.md`

**Why this is worth so much:** every PTF carrying source closes part of the gap
**mechanically** — no disassembly, no alignment loop, no agent. If there are
many, the backlog shrinks considerably. If there are none, we have the
explanation for why source and object drifted apart at all — also a result.

Both are cheap to get and should be settled before the large comparison campaign.

### 5d. 🚪 Dave's 747 modules against the MVS/CE DLIBs

**The single most important measurement of the project** — it answers whether we
can build on Dave's work or have to redo it.

`MVSBLD/` is not his input material but his **working state**. Counted, the
modules he actually touched:

| Series | Area | Modules |
|---|---|---:|
| `DSK0` | base cleanup | 235 |
| `DSK1` | NUCLEUS | 158 |
| `DSK2` | SVCLIB | 32 |
| `DSK3` | JES2 + SMP | 36 |
| `DSK9` | macro modernization | 12 |
| `DSKC` | CMDLIB | 203 |
| `DSKK` | LINKLIB (incomplete) | 61 |
| `DSKL` | LPALIB (incomplete) | 55 |
| | **total** | **747** of ~5,500 |

- [ ] Identify the 747 modules (marker `DSKnnnn` in column 65, or `*DSKnnnn` in
      column 1)
- [ ] Assemble all of them with `as370` and compare against the MVS/CE DLIB
      elements
- [ ] Evaluate: mostly `IDENTICAL`, a systematic residual difference, or
      scattered and unsystematic?
- [ ] **Flag for special handling:** 50 modules carry `???` (Dave could not
      reconstruct the purpose), 16 carry `!!!` (a compare workaround). No agent
      may tidy up there on its own initiative

**If it turns out well**, the backlog is 747 modules smaller and the toolchain is
validated against known material. **If it turns out badly**, his actual PTFs are
on the `BLDMVS.AWS` tape as `MVSSRC.BLD.SMP.LIB` through `.LIB5` — in IEBUPDTE
form, so re-appliable. In no case do we have to redo his work.

> **Partly answered 2026-09-06 without the 747 having been isolated.** The
> tree-wide run compared **all** 4,107 pairable modules, his marked ones among
> them: 832 are byte-identical and 431 differ only in `DS` holes. So the answer
> to "can we build on his work" is already **yes** — it turned out well, at a
> rate of roughly one module in three, and the toolchain is validated against
> known material. What identifying the 747 would still buy is the *split*: how
> much of that 30 % is his marked work and how much came right by itself.

### 6. Inventory and the two tables (M1)

- [ ] Inventory across all system libraries — **target libraries AND
      distribution libraries (`AOS*`)** (`dasdls`)
- [ ] CSECT, IDR and eyecatcher extraction, machine-readable as CSV
- [ ] Evaluate the SMP CDS on `smp000`: sysmod → element, plus ACCEPT status
- [ ] Index all local source pools: `MVSBLD/` (5,529), `IKJ/` (269),
      `www.stben.net/`, `mvssrc/mainframe.eu/`, `NEW.ASM`, `MVT.ASM`
- [ ] Join → table A (ported) and table B (missing)

### 7. ✅ as370 gap analysis (M2) — the gate is passed and the tool is fixed

**Measured tree-wide 2026-09-06: 4,510 of 5,528 modules assemble (82 %).**
The 150-module sample that opened this item is superseded; the numbers below are
the population.

| | first run | after the six fixes |
|---|---:|---:|
| assemble | 4,270 | **4,510** |
| paired against a DLIB member | 3,888 | **4,107** |
| **byte-identical** | 572 | **832** |
| only `DS` holes differ | 281 | **431** |
| length differs | 2,079 | 2,147 |
| only generated text differs | 589 | 433 |

**257 modules gained byte-identity, none lost it.** Full account in
[`docs/tree-wide-run.md`](docs/tree-wide-run.md), the assembler work in
[`docs/as370-gaps.md`](docs/as370-gaps.md).

- [x] Extract `SYS1.AMODGEN`, `SYS1.APVTMACS`, and the whole DLIB macro set
- [x] Recover the private macros — 433 of 436, tape and mirrors
- [x] Categorise failures by first cause over all 1,256 (now 1,018)
- [x] Close six `as370` gaps against IFOX00
- [x] **Cross-check against IFOX00 directly** — the pipeline exists and four of
      five sampled modules produce byte-identical decks
- [ ] Extend that cross-check to the whole assembling tree — item 3 of *Start
      here*
- [ ] Re-categorise the remaining 1,018 failures; the last categorisation was
      before the six fixes

**The gate verdict:** `as370` is not the bottleneck and is no longer a suspect.
What the remaining differences are made of is a source question.

### 8. Re-check Dave's "finished" modules (M3)

Dave's "verified" holds against **TK3**, not against MVS/CE. That has to be
re-established.

- [ ] Build `cmplmd370`: `DIFIN`/`DIFOUT` semantics, `CLEARRLD`, JSON output,
      **exit code 0 only on byte-identity**
- [ ] Pilot: one CMDLIB module through the whole chain — **`as370` OBJ against
      the DLIB element**, with no `ld370` in between. There we know the expected
      answer
- [ ] Cross-check against the target load module; the delta is the
      usermod/sysgen layer
- [ ] Then **completely** across all libraries
- [ ] Assign verdicts, keeping `DIFF_DLIB` and `DIFF_TGT` separate
- [ ] Fill table A with real numbers

Expectation: the hit rate against the DLIBs should be considerably higher than
against the target libraries — usermods, sysgen configuration and the linkage
editor all drop out as sources of noise there.

---

## Tool building

### 9. dasm370 and the round trip (M4)

- [ ] Extract `libobj370` from as370/ld370/file370 (cc370 roadmap phase 0).
      Validation: the existing tools still produce byte-identical output
- [ ] `dasm370` v1 — based on **as370's opcode tables**, not the Waterloo code
      (licensing, see the plan, section 6)
- [ ] **Round-trip test** `dasm370 → as370 → cmplmd370` must yield `IDENTICAL`.
      That is the disassembler's self-test and the precondition for case D
- [ ] Alignment-diff mode: recognise insertions and deletions as such, not as
      byte noise. Without it the agent cannot classify differences
- [ ] Output quality: labels, `USING` reconstruction, literals, address constants

### 10. 🚪 The orchestrator (M5)

- [ ] `mvsrec`: queue, state machine, budget, `work/state/` with resume,
      `evidence/`, escalation reports
- [ ] Enforce the guardrails technically, not just in prose (plan, section 2.4)
- [ ] Write `AGENT.md` — the work contract an agent reads at the start
- [ ] Dry run over case-A modules: a verdict **without any iteration**
- [ ] First autonomous run over five case-B modules

**Gate for the target picture.** This is where it is decided whether the autonomy
carries. Everything before is preparation, everything after is scaling.

---

## Establishing breadth

### 11. Coverage at DLIB level (M6)

No longer a targeted raid but a systematic sweep. The aim is coverage, sorted by
effort rather than by topic.

- [ ] Work outward from Dave's verified areas: NUCLEUS, SVCLIB, JES2, SMP,
      CMDLIB — his source-level maintenance already exists there
- [ ] Then table B from the bottom up, sorted by `DIFF_DLIB`
- [ ] Case D alongside: bring modules with no source to `IDENTICAL-RAW`
      mechanically
- [ ] **Calibrate on the `IKJEFT` group.** Dave's 2024 CSECT compare provides a
      ready-made scale there: `IKJEFT40`, `52`, `53`, `54`, `56` differing by 2
      to 10 bytes at identical length, `IKJEFT35` (1,456), `IKJEFT45` (1,441),
      `IKJEFT55` (4,012), up to `IKJEFT01` (6,867) and `IKJEFT02` (10,899).
      Known numbers from easy to hard — ideal for calibrating the agent
- [ ] **Freeze before the first change of our own:** Git tag on the `IDENTICAL`
      state, with the objects stored as a reference. That is the branch point
      between recovery and development

**No longer the goal:** the BREXX integration. It was the occasion for the
original correspondence and still serves as a proving ground, but it is not a
project goal any more. `IKJ/REXX_INTEGRATION_PLAN.md` is history.

### 12. Back to MVS (M7)

- [ ] Generate `++PTF`/`++USERMOD` with JCLIN from the Git source — templatable
- [ ] Transport via `xmit370` and `RECV370`
- [ ] APPLY/ACCEPT on an MVS/CE **clone**, driven through mvsMF
- [ ] IPL and function test **autonomously on the clone**, per
      [`docs/runbook.md`](docs/runbook.md), with a mandatory wall-clock cap.
      Promotion to anything other than the clone stays with the user

### 13. Build MVS/CE from source (M8) — the end state

Not "apply PTFs" but "produce the system from our source".

The seam is in `sysgen.py`: **`step_03_build_dlibs`** produces the DLIBs from
`tape/zdlib1.het`; `step_04_system_generation` and everything after derive from
them. If the DLIB content comes from our source, the rest of the chain builds on
unchanged.

- [ ] Read `step_03_build_dlibs` in detail — the form and structure of its output
- [ ] Produce DLIB content from our source tree
- [ ] Run a sysgen with step 03 replaced
- [ ] IPL the result and compare it against a regular MVS/CE

**Acceptance:** an IPLable MVS/CE whose DLIBs came from our source.

---

## A strand of its own: SMPWRK3 analysis

⚡ Blocks nothing until M7 and needs no running MVS. Can run alongside at any
time.

> ⚠️ **Downgraded 2026-09-06 — this may not be an SMP defect at all.** Dave
> Kreiss writes that he and Fish diagnosed the intermittent I/O errors with
> Hercules traces and diagnostic builds, and that **Fish changed Hercules to
> eliminate them**. He believes the issue is history but wants to verify it on
> his rebuild. **Do not start the SMP source analysis** until that verification
> comes back — the whole strand may be chasing a fixed emulator bug.

The finding from Dave's mail of 2022-06-08: SMP resets the `SMPWRK3` directory
in the middle of APPLY/ACCEPT, does not notice, and carries on assembling; the
link-edit then produces non-executable load modules. The first FUNCTION affected
is APPLY of `EBB1102`.

**We have the SMP source locally** — 119 `HMASM*` modules in
`Dave Kreiss - MVS from Source/MVSBLD/`. The analysis can start immediately.

Concrete entry points from a first pass:

- [ ] **`HMASMIO`** (plus `HMASMIO1`, `HMASMION`) — the central I/O layer. Every
      SMP module calls it with a function code in `IOPFUNCT`; `IOPSTOWR` is "STOW
      replace". This is where directory handling converges, and the most likely
      place to find the defect
- [ ] The three modules that reference `SMPWRK3` by name: **`HMASMCMP`** (closes
      `SMPWRK3` to set the DEB for the interface module — conspicuous),
      **`HMASMDC2`**, **`HMASMPIN`**
- [ ] The four modules with `STOW` involvement: `HMASMDC1`, `HMASMDR2`,
      `HMASMCRW`, `HMASMRCC`
- [ ] Answer Dave's own open question: **can `STOW` clear a directory under
      MVS 3.8?** The STOW routine is SVC 21 = **`IGC0002A`** ("FIRST LOAD OF BPAM
      STOW ROUTINE"), in `MVSBLD/IGC0002A.ASM` and as a listing on
      `www.stben.net`. Follow the subsequent loads from there
- [ ] Form a hypothesis, then reproduce it deliberately

**A false trail to avoid:** `HMASMPIN` is one of the modules for which no source
existed and which Dave rewrote. That makes it look suspicious — it is not. Dave
reproduced the failure on a **fresh TK3 system with original SMP modules**. The
cause is in the original SMP, not in his reconstruction.

A second thought worth testing: the failure appears only on **large** APPLYs.
That smells of a limit — directory blocks, an extent boundary, a counter
overflowing. Dave's attempt to allocate `SMPWRK3` with a larger directory did not
help, which argues against plain directory size and for something else that
scales with volume.

---

## Decided

- [x] **Re-baselining is complete**, all libraries, comparison included
- [x] **Yardstick:** primarily the DLIB object deck, secondarily the target load
      module; the delta is the usermod/sysgen layer and is measured, not guessed
- [x] **Iteration budget staggered:** case B ≈ 30, case D ≈ 50, case C ≈ 150,
      plus a wall-clock cap
- [x] **The agent may IPL on the clone**, operational knowledge in
      [`docs/runbook.md`](docs/runbook.md)
- [x] **Repository language is English** — documents, issues, PRs, commits.
      German reference copies of the plan and the project analysis stay in
      `~/repos/MVSSRC/WORK/doc/`

## Still open

- [ ] **MVP packages:** a list only, or inventory their contents too?
- [ ] **Wall-clock caps** for IPL and jobs — will fall out of the first run
- [ ] **Reference release of MVS/CE** — proposal: v3.0.0, see item 1b
- [ ] **`IDENTICAL-RAW`:** do case-D modules stay as they are with absolute
      offsets, or does making them readable become a goal of its own later?
