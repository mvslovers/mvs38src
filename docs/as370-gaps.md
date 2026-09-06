# The as370 gaps, and what closing them was worth

2026-09-06. Mike's instruction was short: *if we have gaps in as370, tackle them
now — file issues and fix them, and always compare against IFOX.* This is the
record of what that produced in one evening.

Everything below was measured on the 5,528-module tree, against the real
Assembler XF running under MVS/CE. The oracle recipe is in
[`ifox-oracle.md`](ifox-oracle.md).

## The gaps, by first cause over 1,256 failing modules

| First cause | Modules | State |
|---|---:|---|
| undefined operation code | 327 | 79 of them were **directives**, not macros |
| undefined symbol | 299 | open |
| addressability error | 268 | open |
| relocatable duplication factor | 205 | **not a defect** — see below |
| `DC/DS` type `S` | 52 | **closed**, cc370#108 |
| relocatable displacement, explicit base | 40 | open |
| duplication factor with a forward symbol | 23 | open |
| card consumed as a continuation | 16 | open |

## What was closed, and what each was worth

| | Issue | first cause | actually unlocked |
|---|---|---:|---:|
| `START` + `ISEQ` | #127, #128 | 76 | **75** |
| `DC/DS` type `S` | #108 | 52 | **44** |
| `&SYSECT` | #132 | 597 | **39** |

**158 of the 1,256 now assemble**, and 16 of those are byte-identical to the
shipped object.

The spread in that last column is the useful part. Directives and a missing data
type are **single-cause blockers** — remove them and the module goes through.
`&SYSECT` is not: the macros that use it carry other constructs too, so 597
modules reach the defect and 39 get past everything else as well. It is the same
shape as the macro work earlier in the day, where twelve genuinely missing macros
unlocked fourteen modules out of a possible 327.

**Every first-cause count in this project is an upper bound, and the ratio is not
predictable from the cause alone.**

## Two of the four fixes corrected object code that was already being produced

`&SYSECT` expanded to **nothing**, silently. Twelve modules in a sample of 340
had been assembling successfully with an empty section name embedded in them —
wrong bytes, no message, and invisible because those modules differed from the
DLIB anyway. After the fix they carry the right content.

That is the more valuable half of #132 and it was not what the issue was filed
for. How many of the 4,270 modules that already assembled were affected is not
yet known; twelve came out of a sample of 340.

The same shape appeared in the S-type work: `as370` wrote `0008` where IFOX00
writes `0000` for an unresolvable address constant, under a diagnostic that made
it look like a message problem. A wrong halfword assembles silently.

## What the oracle caught that neither side had assumed

Three times in one evening the intuitive implementation was wrong and only a
listing showed it:

- **`START 5`** gives an ESD address of `000008`. IFOX00 rounds an unaligned
  origin **up to a doubleword**. Neither side assumed it, and no module in this
  corpus would have revealed it.
- **`S(0)`** is `0000`, not `C000`. Only a *relocatable* expression goes through
  the active `USING`; an absolute one is the displacement with base 0. The
  natural implementation resolves everything through `USING` and is wrong for the
  commonest S-constant there is.
- **`&SYSECT` is frozen at the macro call.** A section change *inside* the
  expansion does not change it. Looking up the current section when the symbol is
  referenced — the obvious implementation — is wrong, and wrong only in macros
  that switch sections, which is where nobody looks.

## And one issue that was wrong

[#131](https://github.com/mvslovers/cc370/issues/131) claimed the relocatable
duplication factor was the defect behind 205 modules. It was not — `as370`
already handles it correctly, including `*` advancing per repetition. It was
filed from the error message without reproducing the case in isolation, and the
cc370 session overturned it by rebuilding the construct without the macro.

The actual cause was `&SYSECT` inside `IFDPATCH`, and the error message was the
consequence. **Every issue in this series asks for the case rather than the
diagnosis; that one shipped a diagnosis.**

Checking it did surface a genuine defect, filed as
[#133](https://github.com/mvslovers/cc370/issues/133): a duplication factor
spanning two control sections is silently accepted as zero, where IFOX00 gives
`IFO206` and RC 8. It moves no bytes — which is exactly why it matters here. A
module IFOX00 refuses and `as370` accepts goes into the comparison as
"assembled", differs, and the difference is attributed to the source. The cost is
not a wrong byte but a wrong category.

## Three times the cause was in a macro, not in the source

`MODID` hides an assembly timestamp. `IFDPATCH` hides the `&SYSECT` reference.
`BLSDMSGG` and `JPATCH` hide more timestamps. Grepping module sources for
`&SYSDATE` finds 162 and misses 140; grepping for `&SYSECT` finds 2 and misses
61 macros' worth.

**Measure the expansion, not the source.** That changes how the 2,079 length
differences should be approached, and it is the most transferable thing learned
today.

---

## The wider sample, and an open case

The cc370 session asked for the twelve silently-wrong modules to be chased
across the whole corpus rather than the next gap being opened. That was the right
call.

**All 4,270 previously-assembling modules re-assembled**, timestamp-bearing ones
excluded:

| | Modules |
|---|---:|
| unchanged | 3,881 |
| **different object bytes** | **80** |
| no longer assemble | 0 |

So 80 modules — 2 % — had been producing wrong object code and passing. That is
the cost of a silent substitution, measured.

### The part that is not resolved

Comparing those 80 against the distribution libraries, same comparator on both
sides:

| | Modules |
|---|---:|
| verdict unchanged | 25 |
| **now identical** | 11 |
| **identity lost** | **16** |

The sixteen are the `IDCCD*` family, and it is `&SYSECT` (#132/#134) that moved
them, not the cross-section fix.

```
IDCCDAL, section against its DLIB member
  before &SYSECT   3372 against 3372   identical
  after            4959 against 3372   length
```

**And the oracle sides with the fix.** What `&SYSECT` is before any section has
been opened:

```
          PC  0001 000000 000004
000000 BABB          DC  C'[]'          before any section: empty
000008 BAD5C1D4C5C4BB DC C'[NAMED]'     after NAMED CSECT
000002 BABB          DC  C'[]'          after an unnamed CSECT: empty again
```

`as370` now does exactly that; before the fix it produced `[]` in both places.

`IDCCDAL` has **no `CSECT` statement at all** — it only calls the `IKJPARM`
family, which uses `&SYSECT`. Those macros come from `SYS1.ATSOMAC`, the
distribution library, so the mirror-provenance question does not apply here.

If IFOX00 resolves `&SYSECT` the way the fix now does, IBM's shipped module
should match the **new** output. It matches the old one.

**Resolved by the cc370 session, and it is two defects stacked.** `as370` runs
**one location counter for the whole assembly**; IFOX00 gives every control
section its own counter from zero and concatenates the sections afterwards. The
two models agree exactly as long as no section is ever *resumed* — and cc370's
own corpus never resumes one, in 853 assembler sources. So the byte-identity
gate could not see it.

The `&SYSECT` fix did not cause this. It **exposed** it: with an empty
`&SYSECT` those modules effectively ran in a single section, where the single
counter is harmless. The TSO parse macros swing out and back once per call —
`&IKJCSNM CSECT` then `&SYSECT CSECT` — so `IDCCDAL` is not a two-section
assembly but dozens of switches. Filed as
[cc370#136](https://github.com/mvslovers/cc370/issues/136); the origins turn out
to come from the sections' **final** lengths, so there is no in-place repair.

### How large that class is

| | Modules |
|---|---:|
| resume a section, via one of 15 macros or literally | **157** of 5,526 |
| of those, assemble today | 49 |
| of those, fail today | 108 |
| **of those, byte-identical today** | **0** |

The last row is the one that matters: **not one of the 572 byte-identical
modules resumes a section.** The two counter models only diverge on resumption,
so #136 cannot break anything that currently holds — and the sixteen lost
`IDCCD*` identities are inside those 157.

**Scope, sharpened by cc370 afterwards:** only a resumption across a *real*,
address-occupying section counts. A **DSECT round-trip** — `A CSECT` … `@DATD
DSECT` … `A CSECT` — costs nothing, because a DSECT occupies no address space and
`as370` already saves and restores the location counter across one. Those are the
more common shape in this tree. The detector used here only ever looked at
`CSECT`/`START` statements, so it excluded them by construction; cc370's own
detector counted them at first and reported 173 before the exclusion, then 0
after. **Two independent detectors, both wrong at first in different directions,
both landing on 0.**

> ⚠️ The first version of this measurement said **2,608** modules, 47 % of the
> tree. It counted every repeated section name, including `X CSECT` immediately
> followed by `X CSECT`. A resumption means the name returns **after an
> intervening different section**. The control that caught it: almost all of the
> byte-identical modules came out as "resuming" too, which cannot be true. 47 %
> against 3 % is the difference between "this must be rebuilt now" and "this is a
> bounded, named set".


### And a correction to how this was checked

`#134` was released on the finding that "all 572 previously identical modules are
still identical". That check ran against the list from the tree-wide run — which
was produced with the **older** comparator, before cc370#125 and #126.
`IDCCDAL` was not in it, because that comparator did not call it identical.

The release was not wrong; the check was. **It measured against a stale baseline
and was taken for complete.** Which means the figure of 589 identical modules
has to be recomputed with the current comparator before it is quoted again.
