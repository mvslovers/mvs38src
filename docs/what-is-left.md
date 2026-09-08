# The remaining 524 — where they are and what each block needs

2026-09-09, re-derived against cc370 `89fb177`. **`as370` == IFOX00 on 4,997 of
5,528 (90.4 %)**, from 3,465 (62.7 %) on 2026-09-07, across 49 merges with **no
identity lost**. This is the map for the last 12.6 %.

## The count, reconciled

Three numbers have been used for "what is left" and they are all correct:

| | |
|---:|---|
| **539** | modules whose deck differs card-for-card from IFOX00's |
| **531** | after the clock — 8 of those carry only a `&SYSTIME` stamp, and `ifox_compare.py` settles them by re-assembling with IFOX00's own `ASMDATE`/`ASMTIME` |
| **524** | after the 7 excluded: 5 CICS (`BNG*`), 2 whose source was torn by an FTP transfer (`IBCDASDI`, `IBCDMPRS`) |

`module-table.tsv`'s `tool` column already holds the effective verdict, so **524
is the number to quote** and `cluster_remaining.py` is right to report it. Say
which of the three any figure is before comparing it with another.

## Where they are

| signature | modules |
|---|---:|
| only TXT differs | 189 |
| card count differs by 1 | 87 |
| card count differs by 2–9 | 78 |
| only ESD/TXT | 74 |
| only ESD/RLD/TXT | 56 |
| only RLD/TXT | 22 |
| card count differs by 10+ | 16 |
| only RLD, only ESD | 1 each |

By length, on the same 524: **216 too short, 75 too long, 233 the right shape with
wrong content.**

## Three mechanisms named, with fixtures and measured reach

| | modules | what it is |
|---|---:|---|
| **cc370#247** | **68** | an RX displacement beginning with `(` is dropped along with its base — `L 15,(FIELD-BASE)(9)` gives `58F0 0000`, `L 15,FIELD-BASE(9)` gives `58F9 0010` |
| **cc370#244** | **27**, 13 of them entirely | `L'` of a variable symbol returns `K'` — the `ENQ` macro's RNAME-length byte |
| cc370#241 | 52 | modules that generate more than IFOX00; the multiple-of-eight signature is gone and the mechanism is not established |

#247 absorbed #246 and is the largest single mechanism left. Both it and #244 are
**silent on both sides**: neither assembler says a word, so no diagnostic class
points at either, and only the object comparison finds them.

## Four instruments, and each found what the others could not

This is the method statement, and it is worth more than any single class.

| instrument | tool | found |
|---|---|---|
| **byte histogram** over remaining divergences | `cluster_remaining.py` | `EQU C''''` → 0 (#238, +12); the RX base-register class (#190, +54) |
| **source pairs** — two readers of one syntax | reading | `dc_split` (#218), `expr_sect` (#215), `join_cont` (#183) |
| **section-length deficit** | `ifox_offdiag.py` | the bit-length modifier (#240, +99) — no *wrong* bytes at all, only absent ones |
| **small delta → statement** | `small_delta.py` + `witness.py` | **#247 and #244**, both on 2026-09-09 |

The fourth is new and is the one that opened the last two. It takes the modules
whose whole divergence is one to four bytes at addresses both assemblers agree
exist — **47 of the 524** — and resolves each address to the statement that
generated it. A module that differs in one byte is not a class, it is a witness:
there is no length to unpick and no card to align, and the object says *this
instruction is wrong* and points at it.

```sh
python3 tools/small_delta.py                 # the 47, by size, with byte pairs
python3 tools/witness.py IEFAB469 95D        # -> DC AL1(5)  RNAME LENGTH
python3 tools/witness.py IKJEBERE 26 38 64   # -> L 15,(CANXTSVA-IKJEBECA)(COMMREG)
```

`witness.py` resolves the ESDID to its control section first. **That step cannot
be skipped**: a listing's location counter restarts at every CSECT and DSECT, so
"the last statement below the address" picks a line out of whichever section was
listed last. It answered `IEEMB812 CSECT` for an address inside a macro-generated
`ENQ` list — true, and useless.

## What the rate says

| merge | gain |
|---|---:|
| #175 absolute `EQU` section | +282 |
| #187 RLD length clobber | +160 |
| #240 bit-length modifier | +99 |
| #241 (the block, not one cause) | +67 |
| #231 `CNOP` | +57 |
| #191 absolute `USING` | +57 |
| #204 SS base | +47 |
| #198 `L'` of an `EQU` | +38 |
| #238 `EQU C''''` | +12 |
| #237 `AIF` clamp | +9 |

**The wide-reach mechanisms are gone**; what is left yields tens per fix. #247's
68 is the largest single block with a fixture behind it.

## What "100 %" would require

Nothing structural forbids it: the goal is `as370` == IFOX00 on identical input,
and IFOX00's own return code does not enter into it. Two things make the tail
expensive:

- **291 length problems**, each "material missing or extra", and no named
  mechanism covers them since #240 closed;
- **233 shape-right modules**, correct sizes and wrong content, which is where
  single-instruction defects live — small reach each, and the small-delta cut is
  the only instrument that has reached into them.

The sequence is **#247 (68), then #244 (27, 13 outright), then re-run
`small_delta.py`** — every merge changes what the cut catches, and the two
mechanisms found on 2026-09-09 were both invisible until the modules above them
were fixed.

## The 19 that came off #205

#240 took the EREP short class from 84 to 19. The rest are

```
IFCE0135 IFCE0155 IFCEA155 IFCEI145 IFCEMAD1 IFCEMER1 IFCEMER4 IFCEMER5
IFCET002 IFCET008 IFCET00D IFCEWIN1 IFCEXXXC IFCEXXXD IFCST008 IFCSXXXD
IFCSXXXX IFNX1K IFNX3K
```

and they are on the too-short block, not on a class of their own: the bit-length
modifier was #205's mechanism and it is fixed. `IFCE0155` differs in exactly four
bytes and is not a length case at all.

## Two in the small-delta cut that are the clock, not the assembler

`IFNX5V` and `IFOX0A` each differ in four bytes and all four are a `&SYSTIME`
stamp — `PATCHDC DC C'IFNX5V00 00.13 09/09/26'` and its like. They are the two
the restamp pass did *not* settle, and the reason is not the clock: re-assembled
with IFOX00's own `ASMDATE`/`ASMTIME` (which match `state.tsv`'s job start to the
minute, `05.34` and `05.24`), the TXT becomes identical and **one RLD card is
left** on each. That belongs to cc370#186, not to a time-stamp chase.

Everything else in `small-delta.tsv` is a real object difference.

## A fifth instrument, and the largest block in the tree — 2026-09-09

`small_delta.py` reached forty modules with no group above three, which is the
signal that the object side is mined out. cc370 named the way on: **every class
here is defined by what the deck looks like, and every mechanism found this week
came from asking what the assembler was told to do.**

`first_divergence.py` does that for all of them. For each module whose deck
differs it takes the **first** address where the two objects part — everything
after may be consequence rather than cause — resolves it to the generating
statement, and clusters the statements.

```
 90  DC AL2(sym-sectionbase)  LENGTH OF CSECT      IKJ* 40  BLS* 32  IDC* 18
 78  DC A/AL(...)  address constant
 29  LA
 27  DC Y(sym-sym)                                 IDCTS* almost entirely
 24  SPM
 21  DC C'...'
```

**The first row is 18 % of everything still differing and it is one macro card.**
The length and offset constants are symptoms — forward references to the end of a
PARSE control list whose size is wrong. Skipping every divergence whose statement
is a length or offset constant and taking the next lands on `IKJIDENT`'s

```
         DC    AL2(IKJ@&SYSNDX-*),AL2(18),C&TYPNAM PARAMETER TYPE MESSA*
               GE SEGMENT
```

where `as370` loses `&TYPNAM` entirely because the card is continued. **cc370#250**,
nine-card fixture with its control.

**Read the first divergence, then read past it.** A length constant that names a
symbol at the end of its own section can only ever be a symptom, and it was the
largest cluster in the tree — the instrument would have handed over ninety
modules of symptom if it had stopped at its own answer.
