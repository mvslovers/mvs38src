# Cases for cc370, in the order they pay

> ⚠️ **The packages below are the hand-over as it stood on 2026-09-07, against
> cc370 `879e86a` — `git rev-list --count 879e86a..main` is **126**.** They are
> kept as the record of what was handed over and what each package was worth;
> **every count in them is superseded.** Do not quote a figure from A, B, C or D
> without re-deriving it.
>
> **Current, derived against `7a0cd90` (distance 0 at writing), from a worktree
> build gated as `gdoc`:**
>
> | | modules | this page said |
> |---|---:|---:|
> | still the assembler's problem | **128** | 2,021 |
> | A — `as370` rejects what XF assembles | **16** (19 on the return code) | 512 |
> | B — both silent, object different | **48** | 1,169 |
> | C — both flag, decks differ | **62** | 380 |
> | D — IFOX00 flags, `as370` silent | **2** | 96 |
> | no deck on one side / does not terminate | **0** | 8 / 2 |
>
> The map that replaces this page is [`what-is-left.md`](what-is-left.md).
> `for-cc370.tsv` is **not** re-derived here: it is output of the promote
> sequence, and the promoted state was not `main` when this banner was written.

2026-09-07, re-baselined against `as370` at cc370 **879e86a** (the merge of #164
and #165). Out of the tree-wide comparison against IFOX00
([`ifox-tree.md`](ifox-tree.md)), **2,021 of 5,528 modules are the assembler's
problem**: the two decks differ although the source and the macro libraries were
the same, or one assembler refuses what the other assembles.

The full list is
[`for-cc370.tsv`](../work/measurements/ifox-run/for-cc370.tsv) — one row per
module, with both return codes, both assemblers' messages, the offset where the
decks part company and both section lengths. This page is the way in.

**These are cases, not diagnoses.** Every line below is what was measured. What
the cause is, is cc370's to find.

⚠️ **Two modules were withdrawn on 2026-09-07 and the reason is worth knowing.**
`IBCDASDI` and `IBCDMPRS` carry an embedded binary deck in which an FTP transfer
tore one 80-character record into records of 61 and 18. IBM's tape has it whole.
Their `cards` verdict is that tear, not an assembler defect. Reported by the
`mvssrc-20` session.

The same table named twelve more, and for those the warning does **not** carry:
`IKJEFP20`/`IKJEFP40` have IBM's record count exactly and no short record in
Kreiss' tree, and the `IDCCD*` family is not the damaged copy at all — Kreiss'
`IDCCDDE` is 8,665 records against IBM's 1,885, a different text rather than a
torn one. Those twelve stay on the list.

⚠️ **The message column is a set, not a sequence.** as370 dumps its diagnostics
by category, not in source order (undefined-symbol last), so the first message
listed for a module is not its first defect; and `line_org` folds
macro-generated diagnostics onto the call card, so their line numbers point at
the call. Reported by cc370 on 2026-09-07 and confirmed here as a property of the
output, not of this pipeline. Partitioning these modules by "first diagnostic"
gives a wrong answer.

**What the work is worth, and the first instalment is measured.** #164 and #165
together turned **93 modules byte-identical to IFOX00, none lost — and every one
of the 93 was a row this list had booked to the assembler.** Ten of them went the
whole way to byte-identical with IBM's shipped object, so the recovered count
went 869 -> 879.

Where the two assemblers agree, 22.7 % of modules with a DLIB counterpart are
byte-identical to IBM's object. If the tool stopped being the obstacle for the
rest of this list, that rate is the expectation: **on the order of 400 further
recoveries.**

**And a fix reclassifies as much as it removes.** Package A fell by 146 modules;
93 became identical and **56 moved into Package B**, where neither assembler says
anything and the object differs anyway. Package D grew from 84 to 96. The total
came down by 91; the hard class grew.

**And the expensive half is done once.** The 5,528 IFOX00 decks are a fixed
reference now. Measuring an `as370` change no longer needs MVS at all: assemble
the tree locally (about ten minutes) and compare against the stored decks. The
gate that used to cost a day costs a coffee.

---

## A. `as370` rejects what Assembler XF assembles — 512 modules

> **On `7a0cd90` this class is 19 modules** (16 of them with a differing deck).
> Its message census: 12 `MNOTE`, 11 `Undefined symbol`, 10 `Invalid type
> declared on DC/DS/DXD constant`, 2 addressability, 2 `IFO217`, 2 `IFO206`, and
> one each of four more; counts overlap where a module carries several. The seven
> issues in the table below are closed or nearly so — the table is what was handed
> over, not what is open.

The strongest starting point: **`as370`'s own messages name the construct**, and
IFOX00 assembling the same source with the same macros without a word says the
construct is legal. Nothing else is needed to work on these — no listing, no MVS.

And it is code work, not message work: **355 of the 366 also produce a different
deck.** The rejection is not a stray diagnostic on otherwise correct output.

| Issue | `as370` message | Modules | Smallest case |
|---|---|---:|---|
| Issue | `as370` message | Modules | was | Smallest case |
|---|---|---:|---:|---|
| [cc370#153](https://github.com/mvslovers/cc370/issues/153) | Undefined symbol | **176** | 333 | `AMDPRCOM` |
| [cc370#154](https://github.com/mvslovers/cc370/issues/154) | Addressability error — no active `USING` | **156** | 163 | `BLSCCLSE` (472) |
| [cc370#156](https://github.com/mvslovers/cc370/issues/156) | Relocatable displacement (explicit base) | **44** | 29 | `IEE1603D` (644) |
| [cc370#155](https://github.com/mvslovers/cc370/issues/155) | Undefined operation code | **39** | 41 | `IFG0193E` (574) |
| [cc370#157](https://github.com/mvslovers/cc370/issues/157) | Duplication factor — `IFO206`/`217`/`231` | 23 | 23 | `BLSRESAR` (292) |
| [cc370#158](https://github.com/mvslovers/cc370/issues/158) | Card consumed as a continuation | 8 | 8 | `IEAVGTCL` (458) |
| [cc370#159](https://github.com/mvslovers/cc370/issues/159) | Symbol longer than 8 characters | 8 | 8 | `IEECVET4` |

`#153` more than halved and `#156` grew by half: modules that used to fail
earlier now reach the relocation check. Both are gate figures against `879e86a`.

Each issue carries the failing card, the full module list, and the re-test
recipe. Labelled **Paket A** in the cc370 repository.

Counts overlap where a module carries more than one message. Full breakdown with
five examples each:
[`as370-flags.tsv`](../work/measurements/ifox-run/as370-flags.tsv).

`BLSRESAR` is the whole duplication-factor family in 292 cards: `DS (SYMBOL)CL1`
where the symbol is defined later. Three `as370` messages, one construct, and
IFOX00 assembles it.

**And two modules that never finish** —
[cc370#163](https://github.com/mvslovers/cc370/issues/163). `HEWLDIOC` burned
299 s of CPU and had produced nothing when it was killed; IFOX00 assembles it to
8,160 bytes in under a second. `IFNX1A` the same. They are the only two the gate
ever had to kill, and they are why the count of packages is 2,021 and not 2,019.

## B. Both assemblers silent, the object different — 1,169 modules

> **On `7a0cd90` this class is 48 modules.** It is no longer the largest package;
> C is. It remains the one no instrument reaches — see
> [`dave-environment-plan.md`](dave-environment-plan.md).

The class the comparison exists for. Both exit clean, neither flags a statement,
and the generated code is not the same. Against the distribution libraries this
was indistinguishable from a source defect; it is not one.

`IGG019PF` is the pattern: IFOX00 emits 144 bytes, `as370` emits 265, first
difference at `0x89`, no message from either side.

Sorted by where the difference sits
([`tool-diffs.tsv`](../work/measurements/ifox-run/tool-diffs.tsv)):

| | Sections | What it looks like |
|---|---:|---|
| different length | 1,038 | `as370` generates more or fewer bytes |
| same length, bytes differ | 991 | one or a few bytes inside instructions |
| **difference starts in the first 16 bytes of the section** — [cc370#160](https://github.com/mvslovers/cc370/issues/160) | **49** (was 134) | #165 cleared 85 of them |
| section present on one side only — [cc370#161](https://github.com/mvslovers/cc370/issues/161) | 20 (15 modules) | `AHLSETEV`: `as370` emits a whole section `IGAFETCH`, 6,736 bytes, that IFOX00 does not |
| section this tool could not name | 26 | **not comparable by name — the pairing is in question, not the assembler** |

Smallest cases in the prologue group: `IECVXMGN` (45 B, 11 bytes differ from
offset 0), `IECVXVRU` (49 B, 15 bytes from 0), `IDCTSST0` (83 B, 1 byte at
`0x01`). Checked against `cmplmd370`: all 11 of `IECVXMGN`'s differing bytes are
in generated text, none in a `DS` hole, so the class is code and not a hole
artefact.

Issues carry the module lists in
[`classes/`](../work/measurements/ifox-run/classes/); the two `Paket B` issues are
open, the rest of B is a data file to mine, not a ticket.

## C. Both flag, and the decks differ — 380 modules

> **On `7a0cd90` this class is 62 modules and is now the largest of the four.**
> 46 of them name an undefined operation — 33 `IFC*`, 11 `IEC*`, one `IEA*`, one
> `IEW*` — and are blocked on macros that are in none of our libraries
> ([`missing-macros.md`](missing-macros.md)), not on `as370`.

Both assemblers object, so there is something in the source too; but they
disagree about the result as well. Lower priority than A and B: the source side
has to be untangled first, and part of it is ours.

**837 modules are flagged by both, and in 457 of them the decks are identical
anyway** — those are not cc370's at all, and they are booked to the source.
(An earlier version of this page called all 849 cc370's. It was the count of the
class, not of the part where the decks differ.)

## D. IFOX00 flags, `as370` is silent — 96 modules — [cc370#162](https://github.com/mvslovers/cc370/issues/162)

> **On `7a0cd90` this class is 2 modules**, `IEAVEXS` and `IEAVRTI0`, both
> `IFO007 USAGE OF &CODE IS INCONSISTENT WITH ITS DECLARATION`. cc370#162 took
> the class from 118 to 2 in one merge.

In 41 of the 96 the decks are identical, so there it really is a missing
diagnostic; in the other **55 the code differs too**. The class grew from 84
because #164 and #165 made `as370` fall silent on modules XF still objects to.

The listings are in now, and the class is one thing: **83 of the 84 are
`IFO092 KEYWORD PARAMETER ... UNDEFINED IN MACRO DEFINITION`.** `IECVOID` is the
whole case in three cards:

```
         IECDVOID CSECT=YES
         MODID BR=NO,DATE=11/21/78
         END   ,
```

`MODID` in `SYS1.AMACLIB` has the prototype `&LABEL MODID &BRANCH=,&BR=`, so
`DATE=` is not a keyword it defines. IFOX00 says `IFO092`; `as370` returns rc 0
and prints nothing.

---

## What this class also told us, and it is ours

**Our `MODID` is not the level the source was written against.** 112 modules call
`MODID` with `DATE=` or `PTF=`; the only `MODID` we have — from the MVS/CE 2.1.4
`AMACLIB`, the same library IFOX00 read — defines neither. Its own comments
mention the PTF that added `PTF=` support (`OZ15314`), and the prototype does not
carry it.

That is the macro-provenance question with a measured instance for the first
time, and it is not cc370's: it is evidence about which maintenance level our
macros are at. `MODID` also stamps the assembly date into the object, so it sits
directly on top of the 302 timestamp-bearing modules.

## Two things that are not cc370's

**The 3,507 modules where the two assemblers agree.** Whatever differs there
against IBM's shipped object belongs to the source or to IBM's maintenance.

**The assembly stamp.** It was suspected of explaining hundreds of differences.
Every differing module was re-assembled locally with the date and time that IFOX
run used: **one difference of 1,242 is the stamp.**
