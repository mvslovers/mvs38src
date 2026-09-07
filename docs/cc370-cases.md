# Cases for cc370, in the order they pay

2026-09-07. Out of the tree-wide comparison against IFOX00
([`ifox-tree.md`](ifox-tree.md)), **2,112 of 5,528 modules are the assembler's
problem**: the two decks differ although the source and the macro libraries were
the same, or one assembler refuses what the other assembles.

The full list is
[`for-cc370.tsv`](../work/measurements/ifox-run/for-cc370.tsv) — one row per
module, with both return codes, both assemblers' messages, the offset where the
decks part company and both section lengths. This page is the way in.

**These are cases, not diagnoses.** Every line below is what was measured. What
the cause is, is cc370's to find.

**What the work is worth, measured rather than hoped.** Of the 2,112 modules,
**five** are already byte-identical to their DLIB member; the rest are blocked.
Where the two assemblers already agree, 28.2 % of modules with a DLIB
counterpart are byte-identical. If the tool stopped being the obstacle for these
1,947 paired modules, that rate would be the expectation: **on the order of 550
further modules byte-identical to IBM's shipped object.** That is the size of
this list.

**And the expensive half is done once.** The 5,528 IFOX00 decks are a fixed
reference now. Measuring an `as370` change no longer needs MVS at all: assemble
the tree locally (about ten minutes) and compare against the stored decks. The
gate that used to cost a day costs a coffee.

---

## A. `as370` rejects what Assembler XF assembles — 512 modules

The strongest starting point: **`as370`'s own messages name the construct**, and
IFOX00 assembling the same source with the same macros without a word says the
construct is legal. Nothing else is needed to work on these — no listing, no MVS.

And it is code work, not message work: **501 of the 512 also produce a different
deck.** The rejection is not a stray diagnostic on otherwise correct output.

| Issue | `as370` message | Modules | Smallest case |
|---|---|---:|---|
| [cc370#153](https://github.com/mvslovers/cc370/issues/153) | Undefined symbol | 333 | `AMDSATAP` (1,062 cards) |
| [cc370#154](https://github.com/mvslovers/cc370/issues/154) | Addressability error — no active `USING` | 163 | `BLSCCLSE` (472) |
| [cc370#155](https://github.com/mvslovers/cc370/issues/155) | Undefined operation code | 41 | `IFG0193E` (574) |
| [cc370#156](https://github.com/mvslovers/cc370/issues/156) | Relocatable displacement (explicit base) | 29 | `IEE1603D` (644) |
| [cc370#157](https://github.com/mvslovers/cc370/issues/157) | Duplication factor — `IFO206`/`217`/`231` | 23 | `BLSRESAR` (292) |
| [cc370#158](https://github.com/mvslovers/cc370/issues/158) | Card consumed as a continuation | 8 | `IEAVGTCL` (458) |
| [cc370#159](https://github.com/mvslovers/cc370/issues/159) | Symbol longer than 8 characters | 8 | `IEECVET4` |

Each issue carries the failing card, the full module list, and the re-test
recipe. Labelled **Paket A** in the cc370 repository.

Counts overlap where a module carries more than one message. Full breakdown with
five examples each:
[`as370-flags.tsv`](../work/measurements/ifox-run/as370-flags.tsv).

`BLSRESAR` is the whole duplication-factor family in 292 cards: `DS (SYMBOL)CL1`
where the symbol is defined later. Three `as370` messages, one construct, and
IFOX00 assembles it.

## B. Both assemblers silent, the object different — 1,113 modules

The class the comparison exists for. Both exit clean, neither flags a statement,
and the generated code is not the same. Against the distribution libraries this
was indistinguishable from a source defect; it is not one.

`IGG019PF` is the pattern: IFOX00 emits 144 bytes, `as370` emits 265, first
difference at `0x89`, no message from either side.

Sorted by where the difference sits
([`tool-diffs.tsv`](../work/measurements/ifox-run/tool-diffs.tsv)):

| | Sections | What it looks like |
|---|---:|---|
| same length, bytes differ | 1,086 | one or a few bytes inside instructions |
| different length | 1,038 | `as370` generates more or fewer bytes |
| **difference starts in the first 16 bytes of the section** — [cc370#160](https://github.com/mvslovers/cc370/issues/160) | **134** | unlikely to be 134 separate causes |
| section present on one side only — [cc370#161](https://github.com/mvslovers/cc370/issues/161) | 21 (16 modules) | `AHLSETEV`: `as370` emits a whole section `IGAFETCH`, 6,736 bytes, that IFOX00 does not |
| section this tool could not name | 26 | **not comparable by name — the pairing is in question, not the assembler** |

Smallest cases in the prologue group: `IECVXMGN` (45 B, 11 bytes differ from
offset 0), `IECVXVRU` (49 B, 15 bytes from 0), `IDCTSST0` (83 B, 1 byte at
`0x01`). Checked against `cmplmd370`: all 11 of `IECVXMGN`'s differing bytes are
in generated text, none in a `DS` hole, so the class is code and not a hole
artefact.

Issues carry the module lists in
[`classes/`](../work/measurements/ifox-run/classes/); the two `Paket B` issues are
open, the rest of B is a data file to mine, not a ticket.

## C. Both flag, and the decks differ — 393 modules

Both assemblers object, so there is something in the source too; but they
disagree about the result as well. Lower priority than A and B: the source side
has to be untangled first, and part of it is ours.

**849 modules are flagged by both, and in 456 of them the decks are identical
anyway** — those are not cc370's at all, and they are booked to the source.
(An earlier version of this page called all 849 cc370's. It was the count of the
class, not of the part where the decks differ.)

## D. IFOX00 flags, `as370` is silent — 84 modules

In 39 of the 84 the decks are identical, so there it really is a missing
diagnostic; in the other **45 the code differs too**. The listings that say
*what* XF flagged are being fetched; until they are here this package cannot be
worked.
Everything seen so far is `IFO092 KEYWORD PARAMETER PTF/DATE UNDEFINED IN MACRO
DEFINITION` — which also points back at the maintenance level of our macros.

---

## Two things that are not cc370's

**The 3,416 modules where the two assemblers agree.** Whatever differs there
against IBM's shipped object belongs to the source or to IBM's maintenance.

**The assembly stamp.** It was suspected of explaining hundreds of differences.
Every differing module was re-assembled locally with the date and time that IFOX
run used: **one difference of 1,334 is the stamp.**
