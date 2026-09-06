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
