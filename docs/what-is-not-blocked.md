# What is not waiting on Dave Kreiss' tape

2026-09-06, evening. The request for his built `PVTMAC`/`APVTMAC` blocks one
question: whether the 2,079 length differences are our own macro provenance or
genuine source gaps. That is a real blocker for *those* modules. It is not a
blocker for the project, and this is the measurement that says how much.

## Two thirds of the length differences do not depend on it at all

For every module whose section length differs, does its source actually invoke
one of the 319 macros we took from web mirrors?

| | Modules | |
|---|---:|---:|
| uses at least one mirror macro | 719 | 35 % |
| **uses none** | **1,360** | **65 %** |

**Those 1,360 cannot be explained by our macro provenance.** Whatever their
length difference is, we introduced no unknown into them. They are workable now,
and the list is in
[`../work/measurements/len_clean.txt`](../work/measurements/len_clean.txt).

**And a control that keeps the worry proportionate:** of the 572 modules that
came out **byte-identical**, 32 also use mirror macros. So the mirror set is not
uniformly at the wrong level — parts of it demonstrably produce identical object.
The enrichment is real (35 % against 5.6 %, roughly six-fold) and it justifies
the request; it does not justify treating every mirror macro as suspect.

## The 1,256 that do not assemble, by first cause

| First cause | Modules |
|---|---:|
| undefined operation code | 327 |
| undefined symbol | 299 |
| addressability error | 268 |
| **relocatable duplication factor** | **205** |
| **`DC/DS` type `S`** ([cc370#108](https://github.com/mvslovers/cc370/issues/108)) | **52** |
| **relocatable displacement with an explicit base** | **40** |
| **duplication factor using a forward symbol** (IFO231) | **23** |
| card consumed as a continuation | 16 |
| single cases (IFO158, symbol > 8 characters, …) | 26 |

Full table in [`../work/measurements/causes.txt`](../work/measurements/causes.txt).

### 79 of the 327 "missing macros" are not macros

`START` (51), `ISEQ` (25) and `REPRO` (3) are **assembler directives `as370`
does not implement**. They are counted as undefined operation codes because that
is what an unknown mnemonic looks like.

Together with the four gaps marked above, **399 modules fail first on something
`as370` could implement** — the largest single block in the failures, and it
needs no material from anyone.

### The rest of the missing macros

38 genuinely missing macro names. Twelve were found in the web mirrors and are
now in the corpus: `AMCBS` `ICBVARY` `IEZCTGPL` `IHADECB` `IHADVCT` `IHAEXLST`
`IHASHDR` `IHASPCT` `IKJEGSIO` `IKJOCMTB` `ISDAGSPC` `ISDAPSPC`.

**They unlocked 14 modules, not 327.** That is worth recording as a caution about
first-cause counting: most failing modules have several causes, and removing the
first exposes the second. Every number in the table above is an upper bound on
what fixing that cause yields.

26 remain nowhere, and four of them — `DFHCOVER`, `DFHFC`, `DFHPC`, `DFHSC` —
are **CICS** macros, which says something about what is in `MVSBLD/` that nobody
had noticed: not all of it is MVS.

## So the order of work while the tape is awaited

1. **The 589 that differ only in generated text.** Right length, real
   differences, no hole excuse — the recovery work proper, smallest cluster
   count first.
2. **The 1,360 length differences that use no mirror macro.** Not blocked, and
   the largest untouched pool.
3. **The `as370` gaps**, which belong to cc370 and are named above.
4. Only then the 719 that do depend on the macro question.

---

## How much of the remainder is still the assembler?

2026-09-06, late. After six `as370` defects were closed, 2,147 length and 433
text differences remain. cc370 asked the question that decides whether an eighth
round is worth it: **how many of those are still the tool, and how many are the
source?**

The discriminator is the direct comparison: assemble the same source with
`as370` here and with IFOX00 on MVS, and compare the decks. Where they agree,
the difference against the DLIB member belongs to the source or to IBM's
maintenance. Where they disagree, it is ours.

### Sample of 30, and the first answer was wrong

Thirty differing modules under 400 lines — twenty from the length bucket, ten
from the text bucket — assembled both ways:

| | Modules |
|---|---:|
| `as370` == IFOX00 | 14 |
| `as370` differs | 16 |

Read naively that says **half the remainder is still the assembler**, and an
eighth round is clearly worth it.

**That reading is wrong**, and the run that produced it had `SYSPRINT DD DUMMY` —
the diagnostics were thrown away. Repeating twelve of the sixteen with the
listing kept:

| module | statements IFOX00 flagged |
|---|---:|
| `IFDMSG03` | 33 |
| `IEFAB4M5` | 30 |
| `IGG019OK` | 25 |
| `IFDMSG61` | 14 |
| `IFFANA` | 11 |
| `IEECVETE` | 6 |
| `IEAVDSEG`, `IEDQE2` | 2 |
| `IKJTTRM0`, `IEFVGM2`, `HEWLFAPT`, `IGG019BC` | **0** |

**Eight of twelve did not assemble cleanly on the real assembler either.** Their
decks are not an authority on anything, and a difference against them attributes
nothing. Only the four with a clean IFOX00 run and a differing deck are genuine
`as370` gaps.

### So the honest figure

Of thirty sampled differences: **14 belong to the source, roughly 4 to `as370`,
and 8 are modules that fail on both assemblers** — which is a third category
nobody had counted. Extrapolated, the assembler accounts for something like a
sixth of what remains, not a half.

**An eighth round is worth less than the naive number suggested, and the third
category is worth more.** A module IFOX00 flags 33 times is not waiting for a
better assembler; its source is wrong, or its macros are, and it should be in the
recovery queue rather than the tool queue.

### Caveats on this measurement

- Only modules under 400 lines were sampled, so it is biased towards the simple.
- Twelve of the sixteen differing modules were checked for diagnostics, not all
  sixteen.
- `as370` accepts what IFOX00 flags in at least some of these cases — that is
  cc370#133 in a wider form, and it is worth measuring on its own: **where
  `as370` returns 0 and IFOX00 does not, our pipeline records a clean assembly
  that is not one.**
