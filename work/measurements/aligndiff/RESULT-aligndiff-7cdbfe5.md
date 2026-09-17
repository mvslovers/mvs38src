# cc370 #405 — `--align-diff`, gated 2026-09-17

The acceptance run for cc370 **#405** (issue #384), head
`7cdbfe51faa40c773e2fd0fb13170acccb8a20c3`, built here from a `git archive` of
that commit and never out of the working tree the cc370 session rebuilds.

## Controls

| control | result |
|---|---|
| **A** the refactor (`62d460d`) against `main` (`210ec3a`), ordinary disassembly | **868 of 868 runs byte-identical**, stdout and exit code — control + stage1a + nosource corpora |
| **B** identity: `--align-diff X X` on the 30 control CSECTs | **30 of 30** `findings=0`, shift set exactly `{+0}` |
| **C** agreement with `cmplmd370` on the 30, member against deck | **30 of 30** — findings on exactly the 3 `cmplmd370` calls differing, none on the 27 it calls identical |
| **D** the 832 run completes | **832 of 832** produced a `SUMMARY`, `align=ok` on all, none abandoned |

**Control A is the one worth keeping as a shape.** A refactor advertised as
behaviour-identical is checked by running it, not by reading it, and 868 runs of
byte-identical stdout is a different kind of statement from a code review. The
cc370 session ran 322; this is the same control over a wider corpus, and it is
the half of the PR that could have broken everything else quietly.

**Control C replaces the acceptance this session first wrote down.** The earlier
one was *"no findings on all 30"*, which would have been wrong: **27 of the 30 are
`dlib_identical`, not 30** — `IECVERPL`, `IECVESIO` and `IKJEFF02` are marked `no`
and `cmplmd370` agrees. The cc370 session caught that in this session's own
handover. The right acceptance is agreement with `cmplmd370`, not silence.

## The measurement, and it reproduces the author's figures exactly

832 modules from `work/measurements/divergence/for-aligndiff.tsv`, reference =
IBM's member, candidate = our deck:

```
382,378  displacement shifts classified as CONSEQUENCES
109,257  constant changes
  2,579  insertions     6,423 deletions     1,904 changed data runs
120,163  findings      43,486 unchanged statements
    158  base exact       347 weak       327 none
    832  align=ok, none abandoned
```

Every figure above matches the cc370 session's own to the unit, from a separate
build on separate hardware paths. The shift-set strength table matches too:

| set size | modules | consequences | |
|---|---:|---:|---:|
| ≤ 8 | 206 | 43,360 | 11.3 % |
| 9–32 | 446 | 212,811 | 55.7 % |
| 33–128 | 166 | 113,877 | 29.8 % |
| > 128 | 14 | 12,330 | 3.2 % |

## ⚠️ One number did not reproduce, and THIS SESSION put it in the wrong place

The section that stood here was headed *"One number does not reproduce, and it is
in the PR body"*, and reported that the PR states a median shift-set size of 20
and a maximum of 174 where 16 and 317 are measured. The measurement was right and
**the claim about where the number lived was invented**: the PR body and
`man/dasm370.pod` have carried **16 and 317 since the first push** — the same
figures measured here — and the man page already says *"membership in a 317-value
set is close to no test at all"*, which is the caution at its right magnitude.

The `20` and `174` were in the cc370 session's **message** and nowhere else. This
session read them there, wrote *"it is in the PR body"*, and never opened the PR
body to look. One `gh pr view 405 --json body` would have settled it before a gate
report went out saying a document said something it does not.

**That is the failure this project keeps writing down, in its usual shape**: the
measurement was checked exhaustively and the one-line claim attached to it was not
checked at all. It is the same shape as merging cc370#375 with a red CI job after
verifying its measurement exhaustively — the thing that was wrong was never the
thing being scrutinised.

The discrepancy itself has a clean explanation and it reproduces, which is what
makes it an explanation rather than an excuse. The cc370 session's `20`/`174` came
from an older binary over the 140-module subset, when `ALIGN_MAXD` was 3,000 and 8
of the 140 were abandoned — among them `ICBMSG56` (317), `IEECB905` (246) and
`IKJEFT02` (175), three of the six large-set modules named below. The other three
are not in the 140 at all. The same subset today gives median 21 and max 175:
**+1 on every module**, because the section-end fix that landed after that message
adds exactly one value to every shift set.

**`16` over the 832 is the number.** The 20/174 is withdrawn from this record, and
the six modules above 174 stand as measured:

```
ICBMSG56 317   ICKRI01 316   IEECB905 246
ICKIT01  232   ICKIN01 225   IKJEFT02 175
```

## Two fields the `SUMMARY` line needs before it is in `main`

`SUMMARY` is the only machine-readable line a population run leaves, and it is
what this repository will grep. Two things it knows and does not print:

- **the section size** — `refstmt=` / `candstmt=`, or bytes. `findings=120163`
  over 832 modules cannot be normalised without it, and the header lines that do
  carry it are not on the greppable line.
- **the offset of the first finding** — `first=`. It is the single most useful
  scalar for triage and it is what
  [`first-divergence.tsv`](../divergence/first-divergence.tsv) is built on;
  without it the whole report has to be re-parsed to rank a module.

## The 22 of 140, which is what the author asked judgement on

The question was whether 22 of 140 classified a *constant change* rather than a
consequence at offset 0 is the right size for the second-cause population, or
whether the alignment is landing short.

Measured from this side, on the 101 of the 104 that anchor: **how far behind
IBM's eyecatcher does the first surviving difference sit?**

| distance behind the identifier | modules | |
|---|---:|---:|
| 0–8 bytes | 24 | 23.8 % |
| 8–16 bytes | 38 | 37.6 % |
| 16–32 bytes | 22 | 21.8 % |
| 32–64 bytes | 8 | 7.9 % |
| 64 bytes and more | 9 | 8.9 % |

**Nothing is landing short.** 24 of 101 (23.8 %) have a second cause within eight
bytes of the identifier — inside one or two instructions — and 62 of 101 (61 %)
within sixteen. The author's 22 of 140 is **15.7 %, below the adjacency
population**, which is the safe direction: the alignment recovers the eyecatcher's
own shift for more modules than the ones whose second cause is immediately behind
it, not fewer.

Two populations, not one (101 measured here against 140 there), so this bounds
the answer rather than matching it. The bound is the one that was asked for.
