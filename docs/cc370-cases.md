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

---

## A. `as370` rejects what Assembler XF assembles — 512 modules

The strongest starting point: **`as370`'s own messages name the construct**, and
IFOX00 assembling the same source with the same macros without a word says the
construct is legal. Nothing else is needed to work on these — no listing, no MVS.

| `as370` message | Modules | Smallest cases |
|---|---:|---|
| Undefined symbol | 333 | `AMDSATAP` (1,062 cards), `AMDPRCOM` (1,826) |
| Addressability error — no active `USING` covers the operand | 163 | `BLSCCLSE` (472), `AMDPRPJB` (2,176) |
| Undefined operation code | 41 | `IFG0193E` (574), `IFG0193D` (772) |
| Relocatable displacement in machine instruction (explicit base) | 29 | `IEE1603D` (644), `IEE3103D` (750) |
| Duplication factor family — `IFO206` / `IFO217` / `IFO231` | 23 | `BLSRESAR` (292), `BLSRESGC` (566) |
| This card was consumed as a continuation | 8 | `IEAVGTCL` (458), `IEECVFTM` (619) |
| Symbol longer than 8 characters in operand expression | 7 | `IEECVET4`, `IFNX1J` |

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
| **difference starts in the first 16 bytes of the section** | **134** | worth taking as one group — a difference at offset 0 is unlikely to be 134 separate causes |
| section present on one side only | 21 | `AHLSETEV`: `as370` emits a whole section `IGAFETCH`, 6,736 bytes, that IFOX00 does not |
| section this tool could not name | 26 | **not comparable by name — the pairing is in question, not the assembler** |

Smallest cases in the prologue group: `IECVXMGN` (45 B, 11 bytes differ from
offset 0), `IECVXVRU` (49 B, 15 bytes from 0), `IDCTSST0` (83 B, 1 byte at
`0x01`).

## C. Both flag, and the decks differ — 849 modules

Both assemblers object, so there is something in the source too; but they
disagree about the result as well. Lower priority than A and B: the source side
has to be untangled first, and part of it is ours.

## D. IFOX00 flags, `as370` is silent — 84 modules

A missing diagnostic rather than wrong code. The listings that say *what* XF
flagged are being fetched; until they are here this package cannot be worked.
Everything seen so far is `IFO092 KEYWORD PARAMETER PTF/DATE UNDEFINED IN MACRO
DEFINITION` — which also points back at the maintenance level of our macros.

---

## Two things that are not cc370's

**The 3,416 modules where the two assemblers agree.** Whatever differs there
against IBM's shipped object belongs to the source or to IBM's maintenance.

**The assembly stamp.** It was suspected of explaining hundreds of differences.
Every differing module was re-assembled locally with the date and time that IFOX
run used: **one difference of 1,334 is the stamp.**
