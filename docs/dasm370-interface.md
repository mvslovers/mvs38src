# The contract with `dasm370` — what each side promises

**2026-09-16.** `dasm370` is cc370 #112, a disassembler, planned in a sibling
session after Mike reformulated the goal: *every module explained, as many as
possible byte-identical.* 772 CSECTs here have an object and **no source**, and no
amount of editing recovers a module whose source does not exist.

This page exists because the agreements below were reached in conversation and
would otherwise survive only in commit messages. **Anything here that a later
measurement overtakes should be corrected here, visibly.**

## What we give them

| | |
|---|---|
| `DASM370_CORPUS` | `work/measurements/nosource-corpus.tsv` — 800 rows, stage 1's acceptance corpus. `tools/nosource.py` regenerates it |
| reference bytes | `work/measurements/{dlib-bytes,target-bytes}/tk5/…` — a `target` row is a slice of `<library>/<load_module>.bin` at `offset` for `length`; a `dlib` row is a whole `<library>/<csect>.bin` |
| stratification | `work/measurements/baseline-gate/overlay-vs-both.tsv`, one row per CSECT with both baselines' verdicts. **Not `tree-run.jsonl.gz`** — that is a historical gate run |
| the loop | `tools/gate.sh <as370> <label>` assembles the tree; `tools/baseline_gate.py --decks <dir> --out <tsv>` scores a deck directory against both baselines |

`exclude` in the corpus is a **column, not a filter**: `ambiguous-length` 12,
`too-short` 13, `zero-length` 2, `no-bytes` 1, leaving **772 usable**. `text_frac`
is the share of printable EBCDIC in the CSECT's own bytes — a proxy for *table,
not code*, and nothing more. 72 usable rows are above 0.60 (`IKJ` 19, `PDE` 9),
and those are the named case for reachability analysis.

**No IBM material is committed.** The TSVs are derived.

## What they give us

**JSON per divergence, not a patch, and without the marker placed.** Per
divergence: section-relative offset and length; our bytes and IBM's; the owning
source statement's **listing line number and text**; whether the owner is
macro-generated and, if so, the **macro call** — the nearest preceding statement
without the `+`; and whether the statement **RESERVES** bytes (`DS CL1`) or
**ALIGNS** with none (`DS 0F`, `DC 0H'0'`).

That last distinction decides whether a fix **replaces** the statement or is
**inserted before** it, and getting it backwards was a real defect in
`fillgaps.py`.

**Not a patch**, because our sources are fixed-format 80-column records with
sequence numbers in 73–80 and column 72 as the continuation column, and the
`!!! SOURCE COMPARE FIX !!!` marker sits at a column chosen **per line** — at 46
where the right margin is free, at 41 or 38 where a PL/S statement id occupies it.
We place the marker from their JSON. **`dasm370` does not place it.**

Output format `--format=card|free`, default card, so a stage 1 result drops
straight into `src/`.

## Agreed sequence for the hints work — 2026-09-16, evening

Written here rather than left in the message log, for the reason this file exists
at all: a contract with another session has no owner unless it has a file.

**#382 splits in two, with a shared-input change between them:**

1. **PR A — `--hints FILE`.** Nine keys, `REPLACE`/`VERIFY`, and `VERIFY` reads
   the **original** bytes, which is what makes `REPLACE` safe. Needs nothing of
   ours.
2. **The as370 `USING`/`DROP`/`PUSH`/`POP` event export** — its own branch off
   `main`, its own null control. **Mike agreed to pull this forward**, ahead of
   PR B.
3. **PR B — `--derive-hints old.s` / `--infer`.**

**Why the export is worth its own PR, and the reason is measured rather than
argued.** `as370`'s `usings[]` is live state, not an event log: at the end of an
assembly it holds whatever survived the last `DROP`/`POP`. So `--sym` cannot
supply a `USING` with a **lifetime**, and a `USING` without one is precisely the
range inference the third rule above forbids — a base register attributed to the
wrong span produces plausible symbolic operands where it never applied, and the
round trip cannot object because the bytes are identical either way.

What it buys **us**: `IEBWSAM` was settled by one hand-decode of fourteen bytes.
Our 2,231 length-differing and 605 open-code CSECTs all *have* source, at the
wrong level. Disassembling IBM's object in the terms of our own source — our
labels, sections, DSECTs and `USING`s — is what stops *"which statement is
missing here"* being a day of hand work per module. It is the largest open
population in the project.

**`base` is refused, and that is settled rather than deferred.** #112 and #382
both list it and neither defines it; grepped here, it appears **nowhere** as a
hint key — the one hit is `workplan.md:372`, a divergence-diagnosis category with
no connection to a hints file. So it is undefined on both sides, and `dasm370`
refuses it with rc 16 naming the line rather than ignoring it silently. If a need
appears under that name it gets specified then, with a measurement behind it.

**What we run on the export**, so it is not re-negotiated when it lands: both
binaries from `git archive` with sha256 named, the tree assembled with each under
identical inputs, the **deck-hash table compared module by module** (an
output-only change must give `0 of 5,538` decks and `0` rc changed), and the gate
as **sets** in both directions. Plus a second control this file should not leave
implicit: for the 30 decoder-control modules we hold real source with real
`USING`/`DROP`/`PUSH`/`POP` statements, so the event log can be checked against
the **source text** — a witness independent of the assembler that produced it,
and the only one that can catch a log which is internally consistent and wrong.

## The two corpora, and which question each answers — 2026-09-16

Both are ours and both are committed. **They are not interchangeable, and the
difference is the whole reason there are two.**

| | |
|---|---|
| [`work/measurements/dasm370-decoder-control.tsv`](../work/measurements/dasm370-decoder-control.tsv) — **30** | cut by instruction **format**, not by size. Every one already assembles `identical` from real source, so the answer is known **independently of the tool**. This is the acceptance **for the decoder**. |
| [`work/measurements/dasm370-stage1a.tsv`](../work/measurements/dasm370-stage1a.tsv) — **66** | the `IKJ` subset of the 772 with no source. **None has a second reference.** Exit 0 proves the round trip faithful to the member it came from, **not** that the reading is right. This corpus measures **reach**. |

⚠️ **A wrong but self-consistent reading survives the 66 unchanged.** That is not
a hypothetical: a `dec` field with `BE` and `BZ` swapped prints the wrong
mnemonic for `X'47'` mask 8 and still round-trips **byte-identically**. Only the
30, where a second witness exists, can contradict it. Never quote a figure off
the 66 without saying which of the two questions it answers.

**`SRP` has exactly one witness in the whole 1,626-module identical population**
— `IGCFR10D`. Coverage is therefore reported **per format**: a regression there
is a total loss of coverage for that shape, not one line in thirty. `ED` at 5 is
the same caution, less sharply.

**And the pure round trip needs no IBM member at all.** For the 27 of the 30
whose `dlib_identical` is `yes`, our own deck *is* IBM's bytes, so
`obj_sysparm1/<mod>.obj` is both input and reference: one reader on each side and
nothing between them but the decoder. A DLIB member is **not** an object deck —
all 30 begin `X'20'` — so that route still enters `load_lmod`, and 8 of the 30
hold more than one section.

**Two things a reassembly must carry or it measures something else**: the pinned
stamp and any per-module `SYSPARM`, from `tools/asmparams.py`, the one place that
knows the pair; and `--no-clearrld` where the point is the relocations, because
`cmplmd370` compares CSECT **text** and a decoder can get an address constant's
value right and its relocation wrong.

## Where it got to, 2026-09-16 — and what it is not yet

`dasm370` exists and is merged (cc370 #388, #389, #390). Measured **here**, with
our pinned `as370-main` and `cmplmd370`, not taken from the other session:

| | |
|---|---:|
| the 30, deck path: text | **30 / 30** |
| the same with `--no-clearrld` | **30 / 30** |
| END card | 20 byte-identical, 9 equal in meaning, 1 correctly omitted |
| **the 66, member path** | **66 / 66** |
| the same with `--no-clearrld` | 46 / 66 — bound adcons are resolved, so this is the expected shape |

**Sixty-six CSECTs that have no source at all now rebuild byte-identically from
a disassembly.** That is the first time this project has produced source for a
module where none existed, and it is Fahrplan stage 7 reaching its first
measurable result.

⚠️ **It is not 772 and it is not recovery.** The 66 are the `IKJ` subset chosen
for being code rather than text and between 64 and 1023 bytes; the parse and PCL
tables, the modules over 1 KB and the stubs are all still outside. And a module
that round-trips is a module we can **rebuild**, not one whose source we can
claim is IBM's — the scoreboard does not move and must not.

## Four rules agreed, each with the reason that produced it

**A macro call is emitted only where `dasm370 → as370 → cmplmd370` exits 0 for
that module.** Never as a mode, never per system. Five macros are measured at two
levels with the split running per module: `IEDQNT` becomes identical under a
reconstructed `GETMAIN` and `IEDQNV` breaks under the same one, in the same
library; `AHLREADR` wants IBM's `SETFRR` while `AHLTFOR` and `AHLMCIH` are
byte-identical with ours, all three GTF. A module whose macro form does **not**
round-trip is itself a finding worth emitting. Annotation otherwise, and
**under-claiming**: `* SVC 10 — FREEMAIN R, length in R0`, never
`* FREEMAIN R,LV=72`, because a wrong operand in a comment is believed for years.

**An inferred `USING` is never applied silently.** Candidates go into the hint
file with their **evidence kind** — `prologue` / `rld` / `pattern` — recorded
separately from confidence, because a later reader can re-judge `rld` against the
object and cannot re-judge `pattern` against anything. The reason the round trip
cannot arbitrate: a `USING` is a register *lifetime*, not a value. The RLD is
ground truth about a **point** and inference about a **range**, and with no `DROP`s
to bound it a wrong lifetime resolves every displacement in the wrong range
against the wrong section — plausibly, consistently, and with identical bytes.

**An incomplete image is flagged, not refused — and the flag must reach the
verdict.** A flag only in `--json` is not enough: eighteen tools here consume
`cmplmd370` without reading fields that did not exist when they were written, which
is how the phantom `000032` reached eighteen maps. A section built from an
incomplete image must not be reportable as `identical` through the ordinary path.
Hard refusal was rejected because it would have cost the 60 corroborated
`IEANUC01` identicals, and a withheld verdict leaves nothing to re-examine when
the reader improves. The flag should carry **why** — unhandled record type, segment
overlap, missing `CESDSEG`.


**A symbol's section does not mean it has an address in that section.** Added
2026-09-16 from the `as370` symbol export (cc370#376), and it is the rule that
fails *silently*, which is why it is here rather than in a commit message.

Resolving a displacement is **not** a nearest-match scan over `(sect, value)`.
An **absolute `EQU` keeps the section its card was written in while holding no
address in it** — as370's own handler says so: its section is dead weight, and
`expr_sect` and `using_for` both skip `S_ABS`. Every real module opens with
`R0 EQU 0` … `R15 EQU 15` **inside a CSECT**, so the naive scan resolves
`LA 1,4(,12)` to `LA 1,R4(,12)`: plausible, internally consistent, false — and
**the round trip cannot catch it, because the bytes are identical either way.**
That is the same shape as the inferred `USING` above and it needs the same
treatment.

The rule:

> `sect` equal to the addressed section, `defined = 1`, **`type` not `ABS`**,
> nearest `value <= target`.

`--sym=FILE` emits one tab-separated record per symbol — name, value, length,
type (`REL/SD/PC/ER/LD/ABS`), section id, section name, DSECT membership, ESDID,
`defined`, `entry` — with its own `#columns` header and `-` for stdout. Values
are decimal; section-relative inside a DSECT, absolute elsewhere. It emits no
deck byte: it runs where `emit_listing_a` runs, past `g_pass = 0`.

## What they told us, and what it cost

`cmplmd370` does not merely fail on scatter and overlay. For **scatter**,
`lmod_iter_next` frames the `X'10'` record and the compare loop falls through the
`if/else if`, so the image is built **partially and silently**. For **overlay**,
`load_lmod` memcpys every segment into one flat image, last-wins, with `SEGTAB`
copied in as program text and `CESDSEG` never read. **Both exit 0 or 1, never 2.**

> ## ⚠️ Corrected 2026-09-16 — the scatter half was wrong and one sentence below
> was wrong for the whole corpus
>
> **The scatter mechanism does not exist.** A scatter record carries no program
> text — it is the loader's translation and scatter tables — so a reader that
> skips it is right to. The `dasm370` session retracted it; the **overlay** half
> was real. `IDA019S4 IECVERPL IECVESIO IECVRRSV IGC121` come off hold, and
> **the headline no longer carries ±5**.
>
> **And a DLIB row is NOT an object deck.** Measured: **5,353 of 5,353 DLIB
> members begin `X'20'`, a CESD.** Every DLIB row goes through the same reader,
> so the sentence below is false and the independence it claims is not the
> format's. What does hold: **zero DLIB members carry a flagged CESD type byte
> and 21 target members do** (149 entries). That is the separation.
>
> Reader fixed in cc370#375, merged as `63f372f`. Tree-wide: **1,608 -> 1,626,
> +18/-0 as sets**, unreadable target members **143 -> 2**, no
> `identical -> anything` transition in either direction. Of `IEANUC01`'s 24,
> **13 -> identical and 10 -> differs, exactly as the DLIB predicted for each**.
> The published figure stays 1,608 until the comparator is re-pinned here.
> `work/measurements/cmplmd-reader/`.

Exposure measured here: 247 CSECTs have `IEANUC01` as their target member, 65 of
them `identical`. The DLIB comparison is an independent path — a DLIB row is an
extracted **object deck** and never enters `load_lmod` — and **60 of the 65 are
corroborated by it.** Five rest on the scatter reader alone and are **held, not
counted**: `IDA019S4 IECVERPL IECVESIO IECVRRSV IGC121`. The headline is safe to
**±5 of 1,608**.

⚠️ **"18 free modules" is withdrawn** until the reader lands. For `IEANUC01` alone
there are 13 `error/dlib=identical` and 10 `error/dlib=differs`, and if the scatter
path can exit 1 on a partial image then `error` does not mean what that claim
assumed.

## Their issues

`#112` the disassembler, three stages on one branch · `#372` `common/obj370` —
scatter, overlay, SYM, **unnamed sections carried by (offset, length)** · `#373`
the `as370` symbol export, **its own PR ahead of the rest**, reported as a set diff
in both directions rather than the `identical` line · `#374` the shared invertible
opcode table.

`#373` is split on our asking. Every tree-wide change measured here needs a null
control to separate the harness from the finding — the `SETFRR` trial reproduced
1,608 exactly with the unmodified macro on the same path, which is the only reason
its −33 could be attributed to the macro. A shared input changed in the same
branch as a new tool has no such control available.
