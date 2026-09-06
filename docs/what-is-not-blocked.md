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
