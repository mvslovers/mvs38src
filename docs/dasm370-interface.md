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

## Three rules agreed, each with the reason that produced it

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
