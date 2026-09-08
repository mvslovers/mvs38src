# Building Dave Kreiss' environment — the plan, and why it is not the current work

**Status: written down, not started.** Goal A — `as370` byte-identical to IFOX00
on all 5,528 modules — is at 87.0 % and still yielding a defect per merge. This
document exists so the second goal is not re-derived from scratch when the first
one stalls.

## The two goals, and why only one of them needs this

| | |
|---|---|
| **Goal A** | `as370` == IFOX00 on identical input. 4,810 of 5,528, 711 to go. |
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
