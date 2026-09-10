# Building Dave Kreiss' environment — the plan, and why it is not the current work

**Status: written down, not started — and as of 2026-09-09 it is the recommended
next work.** This document was written when Goal A stood at 87.0 % and was still
yielding a defect per merge, so that the second goal would not be re-derived from
scratch when the first stalled. Goal A is now at **98.4 %** — derived against
cc370 `7a0cd90`, `git rev-list --count 7a0cd90..main` = 0 at writing — and the
condition named above has arrived; see *When to start* at the end.

## The two goals, and why only one of them needs this

| | |
|---|---|
| **Goal A** | `as370` == IFOX00 on identical input. **5,441 of 5,528 decks (98.4 %)** with the assembly stamp normalised, 5,404 raw, **99 to go**. On the stricter goal, deck *and* return code, **5,403**. Derived against `b67af3d`, distance 0. The row read *5,379 of 5,528 (97.3 %)* until the four merges of 2026-09-09 afternoon, and *4,810, 711 to go* before that — a figure left standing beside a status line that already disagreed with it. |
| **Goal B** | Source that assembles to the object IBM shipped — Dave Kreiss' project. |

**A reboot does not serve Goal A.** Every one of the 43 merges so far came from
both assemblers seeing the *same* input and differing. Changing the macro
environment changes it for both sides at once, so the difference stays what it
was — while a known, archived reference is thrown away and the gate history
becomes incomparable.

**Goal B cannot be served any other way.** Three measured facts make that
concrete, all from `BLDMVS.AWS`:

| element type | declared | carries text |
|---|---:|---:|
| `++SRC` | **8,533** | 8,533 |
| `++MACUPD` | **159** | 159 |
| `++MAC` | 3,766 | 27 with a real `MACRO` prototype |
| `++MOD` | 49 | 0 |

plus **2,221 PTFs** and **37 FUNCTION** packages.

- The **159 `++MACUPD`** are *deltas* against existing macros. No text scan can
  say what they produce; only SMP applying them can.
- The **8,533 `++SRC`** say which source belongs in which library. Our macro path
  is assembled by hand from eight MVS/CE libraries and guesses.
- The **35 `++JCLIN`** are the link-edit structure — which CSECT goes into which
  load module. That is the question [`module-origin.md`](module-origin.md)
  currently answers by *member name*, which it says itself undercounts by design.

## The path

**1. Apply on its own volumes, not on `MVSCE-EXP`.**
The install package ships twelve empty 3390-1 volumes (`BLD*.192`–`.19D`),
`$$LOAD$$.JCL` and a 48-page instruction PDF for exactly this. `MVSCE-EXP` is the
measuring instrument and an APPLY of 2,221 PTFs changes it.

**2. Extract the resulting libraries, do not keep the system.**
The deliverable is `SYS1.AMACLIB`, `AMODGEN`, `APVTMACS` and the source libraries
as they stand *after* the stream, pulled back out. A running system is not the
product.

**3. A second IFOX00 reference run on that environment.**
All 5,528 modules, same procedure as
[`ifox-tree.md`](ifox-tree.md), producing a second archived deck set beside the
first.

**4. Measure the two references against each other.**
This is the step that pays. IFOX00-on-our-macros against
IFOX00-on-Dave's-macros, module by module, answers a question we can currently
only guess at: **how much of the remaining divergence is the assembler and how
much is the environment?** Every figure this project has produced carries the
silent qualifier *"with our macro path"*, and after step 4 the environment is a
variable with a measured value instead of an assumption.

## What must not happen

**The gate does not move.** The 5,528 decks in `ifox-decks.tar.gz` stay the
assembler's yardstick, and `retest.py` keeps comparing against them.
Rebaselining would invalidate 43 merges of history to gain nothing for Goal A —
see [`regression-gate.md`](regression-gate.md) on why a quoted figure without its
build is worthless.

**A macro is adopted on both sides at once.** Anything from Dave's environment
that goes on the `as370` path must also be on the MVS side before the comparison
means anything — the measured consequence of ignoring this is in
[`ifox-objections.md`](ifox-objections.md) and in
`work/macros/erep-instream/README.md`, where 33 decks moved *away* from IFOX00
by construction.

## What it will not deliver

**`TABLE` will not come out of it.** The 48 `XTB*` modules need a macro whose
text is not on this tape: `FDM1133` declares 73 macros including all 48 `XTB*`
and contains not one `MACRO` card, because the element text lives in RELFILEs
that were never shipped with it. Confirmed in
[`missing-macros.md`](missing-macros.md).

Nor will `PROLOG` (the EREP one), `IQAERB`, or `SUMMARY`. The 112 module–operation
pairs still unresolved there stay unresolved.

## When

**When Goal A stalls.** While `as370` yields a defect per merge, the remaining
divergences are assembler defects and finding them is cheap. As that rate falls,
the residue becomes progressively more likely to be environment rather than
assembler — and that is exactly when the second reference earns its cost.

Steps 1 and 2 block nothing and can be done at any time; step 3 is an hour of
MVS; step 4 is the measurement.


## When to start — 2026-09-09

Goal A is at **98.4 %**, 96 modules differing, and the remainder no longer looks
like assembler work. Derived against `7a0cd90`, distance 0 at writing, on the 128
that survive the clock and the exclusions:

| | modules | was, at 96.8 % | |
|---|---:|---:|---|
| **both flag** | **62** | 63 | of which **46 name an undefined operation** — a macro nobody here has |
| **silent divergence** | **48** | 84 | neither assembler says a word; **no lead, no instrument** — eight have been run over it |
| `as370` alone flags | **16** | 22 | ordinary assembler work: 10 MNOTE, 9 undefined-symbol, 8 invalid `DC/DS/DXD` type, the duplication-factor group |
| IFOX00 alone flags | 2 | 3 | `IEAVEXS`, `IEAVRTI0` |
| did not finish | 0 | 1 | |

**The silent block has halved and the both-flag block has not moved.** That is the
whole argument of this document arriving: assembler work reaches the loud
population and has been reaching it, while the block that needs a second
reference stays where it is.

**46 of the 128 cannot be moved by any assembler change at all.** They are the
`IFC*` EREP family (33 of them), the `IEC*` IOS mappings (11), and one each of
`IEA*` and `IEW*` — blocked on the 27 macros
[`missing-macros.md`](missing-macros.md) has already searched for and not found.
No amount of work on `as370` reaches them. `IFC*` and `IEC*` together are 51 of
the 128 by name.

So the order is:

1. **Finish what is bounded** — the 16 loud modules, `IFCEA155`, and cc370#290's
   named obstacle.
2. **Then this document.**

### And it is not only the macros: it is the instrument for the silent block

The silent 48 have defeated every instrument because both assemblers read the
same input and neither complains. **A second, independent IFOX00 reference — one
assembled under Dave's environment rather than `MVSCE-EXP`'s — splits them**: a
module that differs against both references is `as370`'s, a module that differs
against one is the environment's.

That is the *two measurements beat one* argument, and it is the only proposal
anyone has made for the block no instrument reaches. It happens to fall out of the
same work that supplies the macros.
