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

## 92.7 %, and the symptom rule earns its keep twice — 2026-09-09

cc370#250 merged: **+82, none lost, 107 closer**, and `cards : 183 -> 128` —
fifty-five modules stopped being card-count differences in one merge. One deck
moved further, `ISTINCU7(+6)`, and it is not a regression: that module is 2,498
bytes against IFOX00's 210 and was 2,492 before, wrong at 2,282 addresses either
way. **Check a module that moves away before accepting the run**; six bytes on
something wrong by a factor of twelve is not information about the change.

| | |
|---:|---|
| `as370` == IFOX00 | **5,123 of 5,528 (92.7 %)** |
| still differing | **398** |
| byte-identical to IBM's shipped object | **1,168** |

The re-clustered first divergences, and both new entries were found the same way:

```
 67  DC A/AL(...)
 29  LA                        27  PARSE PCL constant (was 90)
 27  DC Y(sym-sym)             24  SPM
 21  DC C'...'                 15  TM
```

**cc370#252 — `SPM` keeps the R2 field of the previous RR instruction**, 24
modules. `SR GR8,GR8` then `SPM GR8` gives `1B88 0488` where IFOX00 gives
`1B88 0480`. `SPM` alone encodes correctly, which is why a source scan finds
nothing: it needs a preceding RR instruction, and in real code there always is
one.

**cc370#253 — `DC H'6,0,17,6,0'` generates only the first value**, 32 modules,
almost all `IDCTS*`. Three controls in the same fixture — a single value, a
duplication factor, and two separate operands — all work.

### Read past the symptom, and then past that one too

`DC Y(sym-sym)` at 27 modules is a table of message offsets, and every one of
them is six to eight bytes low. Skipping them lands on **more** offset constants
(`DC Y(STE11A-TXT1A) TEXT OFFSET`), and only skipping those as well reaches
`DC H'06,00,17,06,00'` — the eight bytes that were never generated.

That is twice in one day that the largest cluster was a symptom, and the second
time it was two layers deep. **A constant that names another symbol in its own
section can only be wrong because something else is**; the instrument has to be
told to walk past every one of them, not just the first kind.

## 93.0 % — and a class fix that produced no collateral at all

cc370#252 merged: **+17, none lost, none further, nothing moved between buckets.**
Three merges in a row with no deck moving the wrong way.

**It was not an `SPM` defect.** `split_fields` filled only as many fields as the
operand had, into a stack array the next statement reused, so an unwritten slot
held the previous statement's text at the same address. `SPM` has one operand and
the RR emitter reads two. cc370 fixed it in `split_fields` — every consumer of a
shorter-than-expected operand list had the same exposure — which touches every
statement in the tree and moved nothing the wrong way.

| | |
|---:|---|
| `as370` == IFOX00 | **5,140 of 5,528 (93.0 %)** |
| still differing | **388** |
| byte-identical to IBM's object | **1,172** |

### A limit of the byte histogram, stated properly

`cluster_remaining.py` had this defect filed as eight unrelated single-byte
cases — `88 87 8E C4 C8 E4 EB F6`. cc370's reading is the one to keep:

> It clusters by *value*, and a defect whose value is copied from elsewhere has
> no value of its own.

The leaked nibble is whatever register the previous RR instruction named, so the
histogram is **guaranteed** to shred this class into as many pieces as the corpus
has preceding instructions. That is not a bug in the instrument; it is the shape
of question it cannot ask, and it explains a run of singletons that had been
written off as noise.

The observation that made the diagnosis quick was a *negative* one: `SPM R12`
alone encodes correctly. That says the encoder is right and something before the
instruction decides the byte — a very short list of possibilities.

## The `DC A/AL(...)` walk produced no new mechanism — 2026-09-09

Written down because a negative result that is not recorded gets re-derived.

121 modules have an address or offset constant as their first divergence. Walking
past **every** kind of them — `A`, `AL`, `Y`, `S`, `V` — leaves 4 with nothing but
address constants differing, and the rest resolve to:

| under it | modules | verdict |
|---|---:|---|
| `DC X'8400' STATIC TEXT FLAG` and friends | 14 | **already cc370#253** — the `IDCTS*` value lists |
| `BAL 1,*+24  BRANCH AROUND PARM LIST` | 13 | **not a defect** — see below |
| `DC BL2'…'` in a PARSE expansion | 15 | **withdrawn** — see below |

**The `BAL` family is the missing-macro class.** All thirteen are `IFCE*`, and
`module-table.tsv` says `both flag`, `rc 12`, with `as370` reporting
`Undefined operation code` and `Addressability error`. The four zero bytes where
IFOX00 has an instruction are what an EREP module does when `DSGEN` and `PROLOG`
are not there — [`missing-macros.md`](missing-macros.md), not a new issue. The
first-divergence instrument will keep offering them, because a module that cannot
resolve its macros still produces a deck and still has a first divergence.

**The `BL2` lead was withdrawn before it was filed, and by the rule already in
the runbook.** `IKJIDENT` line 275 is

```
         DC    BL2'100&FPRPT&FDFLT.0&FHELP&FVALID&FLIST&FASIS&FRANGE.00*
```

— a literal split across a macro continuation — and `as370`'s listing renders the
expansion as `DC BL2'10000000000000`: fourteen digits, no closing quote. That
looks exactly like a residue of cc370#250.

It is not. A fixture with the same shape produces **the correct two bytes**; the
truncation is in how the listing prints a continued statement, not in what is
assembled. *A listing is faithful for what it reports and is not a substitute for
the object* — the rule was already written down two sections above, from two
earlier withdrawals, and it caught a third.

So the remaining divergence in those fifteen is a layout difference with no cause
yet, and the honest entry is that the walk found nothing new.

## 93.5 %, and the silent population has no large mechanism left — 2026-09-09

cc370#253 merged: **+31, none lost, none further**, `cards : 128 -> 108`. Four
merges in a row with nothing moving the wrong way, and the card-count bucket is
down from 2,063 at the start of this comparison to 108.

| | |
|---:|---|
| `as370` == IFOX00 | **5,171 of 5,528 (93.5 %)** |
| still differing | **357** |
| byte-identical to IBM's object | **1,191** |

### What the 357 actually are

`first_divergence.py` now defaults to `--signal silent`, because the instrument
cannot tell *`as370` is wrong here* from *`as370` was never given what it needed*:

| signal | modules | what it is |
|---|---:|---|
| **silent divergence** | **163** | neither assembler says a word and they disagree — the real work |
| `as370` alone flags | 92 | the diagnostic classes, #153 / #154 and friends |
| both flag | 85 | mostly EREP without `DSGEN` and `PROLOG` — **not `as370` defects** |
| IFOX00 alone flags | 9 | |
| did not finish | 1 | |

**The 163 atomise completely**: 160 distinct first-divergence statements, largest
cluster **three**. There is no large mechanism left in the silent population that
clustering can see. That is a result, not a gap — five instruments have been run
over it and the sixth says the same thing.

What is left with a name: **cc370#217**, the scale modifier on a fixed-point
constant, `TWOPI DC FS28'6.2832'` in the `IFFP*` scientific routines, **6
modules** — measured here for the first time. And five `IEES*03D` modules whose
`L R0,SIZE` displacement differs, silently, with no cause yet.

### The rule this session ends on

cc370 stated it and it covers the missing-macro thirteen, the `L'` count I got
wrong in both directions, and the 85 above:

> **The population an instrument returns is the population it can see, not the
> one the question is about.**

## 93.6 %, and the loud population is where the clustering still works — 2026-09-09

cc370#217 merged: **+5, none lost, none further.** Five of the six the reach
measurement named; `IFNX5M` stays, exactly as the issue said when it was filed —
647 differing bytes in 126 runs from something else. **A reach figure that comes
with the module it will not fix is the only kind worth quoting.**

| | |
|---:|---|
| `as370` == IFOX00 | **5,176 of 5,528 (93.6 %)** |
| still differing | **352** |
| byte-identical to IBM's object | **1,192** |

### The instrument has to match the population

`first_divergence.py --signal loud` on the 92 where `as370` alone flags is just as
atomised as the silent 163 — largest cluster **two**. But the same 92 clustered
**by message** are not atomised at all:

```
 40  Undefined symbol                        cc370#153
 36  Addressability error, no active USING   cc370#154
 28  MNOTE
  5  Undefined operation code                cc370#155
  5  Symbol longer than 8 characters
```

**A message names its own cause; a statement does not.** That is why the loud
population is the one worth taking next: the 163 silent modules are exhausted for
clustering, and these are clustered by construction.

Splitting the 28 `MNOTE` modules by the *text* of the note:

| the macro's complaint | modules | |
|---|---:|---|
| `REDUNDANT LOGIC, MACRO EXPANSION ATTEMPTED` | 8 | all `IFNX*`, undiagnosed |
| `IHB001 REGISTER OPERAND REQ'D-NOT SPECIFIED` | 7 | undiagnosed |
| **`INVALID TYPE ATTRIBUTE SPECIFIED IN PARAMETERS`** | **6** | **cc370#257** |
| `ITEMFIND FAILED FOR NAME YCPU / YSER / YCUA` | 2 | EREP |
| `STATUS--CHANGE LEVEL n` | 11 | severity `*`, informational, harmless |

**cc370#257** — `T'` of a variable symbol in a `SETC` is not evaluated; the four
characters `T'&P` are assigned verbatim. Third defect in the attribute operators
in two days and each fails differently: `L'&VAR` returned `K'` (#249, fixed),
`L'ORDINARY` returns `0` (open, on #244), `T'&VAR` is not evaluated at all.

### Two class files to close by hand

`relocatable-displacement` is **empty**, and `symbol-over-8` is down to 2
(`ICAPRTBL`, `IGC0001I`) from 7.

## A message can name the wrong cause — 2026-09-09

cc370#257 (`T'` in a `SETC` not evaluated) is a real defect, merged as #259, and
its corpus reach is **zero**: 0 of 5,528 decks changed by a single byte. I
checked that by comparing every deck against the promoted run rather than reading
the verdict counts, because a count can cancel two opposite movements and has
done so here before.

**I had attributed six `AMDPR*` modules to it, and they were not it.** All six
still raise `MNOTE 12,'INVALID TYPE ATTRIBUTE SPECIFIED IN PARAMETERS'` after the
fix, at the same 36 sites. They use the *comparison* path, which already worked.
I filed them on nothing better than the words matching.

The real cause is **cc370#260**: `T'` of a macro parameter that is a **sublist**
gives `U` where IFOX00 gives `N`. `SYS1.APVTMACS(HEXCNVT)` guards on
`AIF (T'&OUT NE 'N').ERROR4`, and `AMDPREXT` calls it as `HEXCNVT (3),(2),4` — so
`&OUT` is `(3)`, a sublist.

```
T'(3)   = U     should be N        T'4    = N   correct
T'(3,4) = U     should be N        T'FLD  = C   correct
```

**So the rule about symptoms reaches one layer further than I had it.** It was
written for object bytes — *a constant that names another symbol in its own
section can only be wrong because something else is*. It applies to **diagnostic
text** as well:

> A message names its own cause, but the name can be wrong. `INVALID TYPE
> ATTRIBUTE` named the right operator and the wrong operand shape.

That does not undo the reason for taking the loud population first — clustering
by message still found this, and clustering by statement could not have. It
means the message is where the search **starts**, not where it ends.

### And the attribute family is now five failures in five shapes

| | |
|---|---|
| `L'&VAR` in a `SETA` | returned `K'` — cc370#244, fixed |
| `L'ORDINARY` in an open-code `SETA` | returns `0` — open |
| `T'&VAR` in a `SETC` | not evaluated — cc370#257, fixed, zero reach |
| `T'` of a sublist | `U` instead of `N` — **cc370#260**, 6 modules |
| `S'` and `I'` | not evaluated — cc370#258 |
| `N'`, `K'` | correct |

## 93.7 %, and checking the code path before filing — 2026-09-09

cc370#260 merged: **+5, none lost, none further.** Four of the six `AMDPR*`, plus
`IGG019MA` — a named residual from #237, one of two decks that had moved the
wrong way and was written down instead of chased. **Second time this week a
labelled residual paid on a change aimed elsewhere** (`IFCE0155` from #205's
nineteen was the other). Neither would have been found by looking for it.

| | |
|---:|---|
| `as370` == IFOX00 | **5,181 of 5,528 (93.7 %)** |
| still differing | **347** |

### cc370#262, and three hypotheses eliminated on the way

`REDUNDANT LOGIC, MACRO EXPANSION ATTEMPTED` — 8 `IFNX*` modules, 76 sites — is
`GOIF1` line 37:

```
.C4      AIF   (NOT(&B(1) AND &B(2) AND &B(3))OR '&ELSE' EQ '').C5
```

**`)OR` with no blank.** With the blank the same expression is evaluated
correctly. Same family as cc370#245 one step out: a *logical* operator, after a
closing parenthesis rather than a term.

Eliminated first, each with a fixture: an explicitly empty keyword (`GT=`)
comparing unequal to `''` — no; subscripted `SETB` reading wrong — no; the three-
term `AND` chain — no, correct in a `SETB` at two and three terms and in either
order. **`NOT(` with no blank on the opening side is also correct**, which is what
narrows it to the closing side.

### The macro-provenance scare, and why it was unfounded

`GOIF1` is in **none** of the six `SYS1.A*` libraries — `as370` reads it from our
web-mirror directory, and the mirror supplies ~300 macros the DLIBs do not. For
an hour that looked like the unequal input that makes every difference
unattributable, across the whole comparison.

It is not. The IFOX00 runs passed **seven** libraries and the seventh is
`IBMUSER.PVTMAC` — 444 members, holding `GOIF`, `GOIF1`, `GOIF3`. Fetched
`IBMUSER.PVTMAC(GOIF1)` from MVSCE-EXP and compared: **228 cards, byte-identical
to the mirror copy over columns 1–72.**

**The check cost one REST call and it had to be made before filing**, because the
`IHANVT` case already showed what an unequal macro path does to a verdict. The
rule stands and this time it came out the other way.

## 93.9 %, and the last named MNOTE group turned out to be a collating sequence

cc370#262 merged: **+9, none lost, none further**, `cards : 101 -> 94`. None of
the nine is one of the eight `IFNX*` the issue was filed for — but **all 76
`REDUNDANT LOGIC` sites are gone in all eight**; those modules still differ for
other reasons. *The complaint is fixed and the module is not* is a distinct
outcome from *nothing happened*, and the gained list alone cannot tell them apart.

Two more labelled residuals came in free — `AHLMCER` (#237) and `IGG09301`
(#245). **Third and fourth this week**, after `IFCE0155` and `IGG019MA`. All four
were recognisable only because the residual had been written down *with its
module name*; a "2 decks further" line would have lost every one.

| | |
|---:|---|
| `as370` == IFOX00 | **5,190 of 5,528 (93.9 %)** |
| still differing | **338** |

### cc370#264 — character comparison is in ASCII order

The last named group, `IHB001 REGISTER OPERAND REQ'D-NOT SPECIFIED` at 7 modules,
is `SYS1.AMACLIB(DOM)`'s register test:

```
         AIF   ('&MSG'(1,1) EQ '(' AND '&MSG(1)' GE '1' AND            X
               '&MSG(1)' LE '12').DOML4
```

`IGG019V2` calls `DOM MSG=(R1)` with `R1 EQU PARMREG`, so `&MSG(1)` is `R1`.
`'R1' LE '12'` is **true** in EBCDIC (`R`=`X'D9'` < `1`=`X'F1'`) and **false** in
ASCII (`R`=`X'52'` > `1`=`X'31'`). `as370` says false.

```
'A' LE '1'   FALSE   should be TRUE      'A' LT 'B'   TRUE   correct in both
'Z' LT '0'   FALSE   should be TRUE
```

**In EBCDIC letters sort before digits; in ASCII they sort after.** That is the
only disagreement between the two orders over the characters assembler source
uses — letter-against-letter and digit-against-digit agree — which is why a
fifteen-card fixture with no macro libraries finds it and five instruments did
not.

**103 macros in our libraries carry the idiom** — `DCB`, `ENQ`, `ESTAE`, `SDUMP`,
`XCTL`, `XDAP`, `CONSOLE`, `QEDIT`, `STATUS` among them. Seven modules is what
raises an `MNOTE`; a comparison that answers wrongly also takes the wrong branch
**silently**, and there are 149 silent divergences with no mechanism named. Not
established, and the seven are what can be proved.

### The provenance check, the other way round

`DOM` reaches `as370` from our extracted `AMACLIB` and IFOX00 from `SYS1.AMACLIB`
on the running system — **a distribution library against a maintained one**, which
is the `MODID` maintenance-level question in
[`ifox-objections.md`](ifox-objections.md) applied to the whole comparison.
Fetched `SYS1.AMACLIB(DOM)`: 104 cards, byte-identical.

Two such checks in one day, both confirming the ground rather than finding a
fault. cc370's rule for when to make them is better than the one either of us had
been using:

> **The checks worth running are not the ones most likely to fail, they are the
> ones whose failure costs most.**

## 94.0 %, and the reach question answered in the negative — 2026-09-09

cc370#264 merged: **+7, none lost, none further.** Checked at deck level rather
than by verdict count: **exactly 7 of 5,528 decks differ from the promoted run,
and they are the 7 that became identical.**

**That answers the open question, and the answer is no.** The ASCII-collating
defect is present in 103 macros, and its whole reach is the seven modules where a
macro was loud about it. It does *not* take wrong branches silently, so it reaches
none of the 149 silent divergences. A wrong branch in conditional assembly was the
most plausible silent mechanism left — it is the one thing that changes generated
code with nothing to say about it — and it is excluded now. **It cost nothing to
find out: the gate ran because it always runs, and a change made for another
reason answered it.**

| | |
|---:|---|
| `as370` == IFOX00 | **5,197 of 5,528 (94.0 %)** |
| still differing | **331** |
| byte-identical to IBM's object | **1,195** |
| silent / `as370` alone / both flag | 149 / 81 / 84 |

### cc370#154 has a mechanism: multi-register `USING`

`USING sect,R1,R2,R3` covers three 4096-byte ranges. **`as370` honours `R1` and
ignores the rest**, so every operand past 4095 gets no base:

```
         USING D,11,12,10
         L     3,LOW      5830 B000   correct, within the first 4096
         L     3,HIGH     0000 0000   should be 5830 C398
         L     3,HIGH2    0000 0000   should be 5830 A33C
```

`BLSUPUT` line 20 is `USING BLSUPRAB,RB,RC`; `ZZ2TRMVP` at `X'1144'` gets no base
while its neighbours at `X'E38'` and `X'28A'` assemble correctly — the split is
visible in one listing.

**28 of the class's 36 modules**, 40 of the 331 still differing, 50 in the tree.
The 3,123 diagnostic sites are mostly cascade from one missing `USING` range.

### And a scan that returned zero and was a shell bug

The first count said **0 of 331**. The regex was inside double quotes and zsh
expanded `$0` in `[A-Z@#$0-9]`. Single quotes give 40.

**A scan that returns zero reads exactly like a clean negative**, and this
repository has spent real effort on recorded negatives today. Quote the regex.

## cc370#153 localised to one COPY member, and a limit that is real but not the cause

The 39 modules where `as370` alone reports `Undefined symbol` — 1,257 sites — are
not 39 problems. Clustered by the *symbol* it cannot resolve:

```
  7  MPNM        5  JTTITLE     4  JTERROR JTPRINT JTSPACE JTREPRO JTPUNCH
  4  JTUSING JTADJII            3  JTPUSH JTEJECT JTDROP JTPOP JTMNOTE JTSYMII
```

**Every `JT*` name comes from one statement.** `IFNX1A` line 188 is
`COPY JTEXT`, and inside `JTEXT` the whole symbol set is defined by a single
macro call spanning **86 cards — 85 continuations** — `JTIOP1 DBV ,` followed by
some two hundred `NAME(expression),` operands.

`IBMUSER.PVTMAC(JTEXT)` fetched from MVSCE-EXP: **182 cards, byte-identical** to
our copy. The oracle read the same text.

### What was found, and what it does not explain

`as370` has a **64-operand limit** on positional macro operands, with its own
diagnostic:

```
ERROR: More than 64 positional macro operands - the rest are not
       addressable through &SYSLIST
```

Reproduced with a 56-card fixture (one call, 200 operands, 50 continuation
cards). IBM's assembler has no such limit and IFOX00 assembles these modules
cleanly, so the limit is wrong.

**But it is not demonstrably the cause here: no module among the 331 raises that
message.** `IFNX1A` has 13 `Undefined symbol` messages and not one "More than
64". So either `DBV`'s operands are not counted as positional by the same path,
or the symbols are lost somewhere else in an 86-card continuation.

Recorded as a partial result. What it buys is that **cc370#153 is one statement
in one COPY member**, not thirty-nine independent module problems — which is a
much better starting point than the class list, and it is where the next person
should begin.

### Two scans that returned zero today

The multi-register `USING` count said `0 of 331` because zsh expanded `$0` inside
a double-quoted regex; the real figure is 40. The 64-operand count says `0 of 331`
and this one is real — verified by running the same command on a module by hand.

**A zero from a scan has to be confirmed against a case you already know the
answer for**, and today one of two was an artefact.

## 94.5 %, and the class lists have come apart from the issues they serve

cc370#154 merged: **+25, none lost, 47 closer, 3 further.** The three were
answered rather than waved past, and two of them turn out not to count:

| | differing bytes | as370 / IFOX00 | |
|---|---|---|---|
| `BNGC3270` | 6,466 → 6,562 | 8,068 / 8,081 B | **excluded** (CICS) |
| `BNGCDISP` | 5,348 → 5,515 | 6,965 / 6,949 B | **excluded** (CICS) |
| `ISTNSC00` | 10,658 → 11,451 | **5,007 / 12,506 B** | `MSGCSECT` and `RWKAREAS` absent from the deck |

All three diverge from **address 0**. Giving more instructions a base in a layout
already wrong from the first byte makes more bytes differ, which is the expected
direction. **Check `excluded.tsv` before analysing a module that moved** — two of
these cannot regress the measurement at all.

| | |
|---:|---|
| `as370` == IFOX00 | **5,224 of 5,528 (94.5 %)** |
| still differing | **304** |
| silent / `as370` alone / both flag / IFOX00 alone | **149 / 62 / 76 / 9** |

### The 149 are now half of everything left

The loud population has halved today — 92 → 62 — and **the silent 149 have not
moved at all**, through eleven merges. Every mechanism found today was loud;
nothing has touched the silent group since the small-delta cut, and cc370#264
excluded the most plausible candidate for it.

### A class file can stop measuring what its issue is about

`addressability.txt` went 36 → 8, and **`IEFVEA` is not on it and still raises the
diagnostic**:

```
IEFVEA   tool=identical   as370_rc=8   ifox_rc=0000   signal=as370 alone flags
```

The file selects modules whose deck **differs** *and* where `as370` alone flags.
`IEFVEA`'s deck is now byte-identical, so it drops out — while still returning
`rc 8` where IFOX00 returns `rc 0`. The issue is about the diagnostic; the file is
a deck-divergence class. **They agreed until a fix made them disagree.**

Both failure modes are now on the board with a named module each:

| | |
|---|---|
| the complaint goes, the deck stays | the eight `IFNX*` after cc370#262 |
| **the deck goes, the complaint stays** | **`IEFVEA` after cc370#154** |

Neither is visible in a gained list, and `rebuild_classes.py` can only see the
first. Measure the diagnostic separately rather than inferring it.

## 94.6 %, and a diagnostic that never fires is not a limit that is never reached

cc370#153's `JT*` half is closed: **+2, none lost, `cards : 94 -> 91`.** The one
deck that moved away, `IFNX2A`, was **117 bytes wrong and is now 118**, same total
length on both sides, first divergence at `X'1D'` — noise inside an existing
field, and the unchanged length is what rules out a layout regression.

| | |
|---:|---|
| `as370` == IFOX00 | **5,227 of 5,528 (94.6 %)** |
| still differing | **301** |
| silent / `as370` alone / both flag / IFOX00 alone | **166 / 43 / 74 / 10** |
| IFOX00 clean while `as370` returns `rc 8+` | **55**, nine with an identical deck |

### The 64-operand limit was one of four caps, and three of them hid it

I filed it as *wrong on its own account but explains nothing here, because no
module raises the message.* The first half was right. The second was **a
consequence of a defect one layer up**: `sysvar_sub` capped every source line at
1022, `parse()` the operand field at 1023, and `vref` built `&SYSLIST` as one
synthetic string in a 1024-byte buffer and then copied it into a second one. The
statement reached the operand counter already cut to about 61 — **so the "more
than 64" message could not fire.**

**A diagnostic that never fires is indistinguishable from a limit that is never
reached**, and no census of messages can tell them apart. That is the limit of the
instrument I had just finished recommending.

`join_cont` was flawless throughout: 116 cards, 1,492 characters, all 86 operands.
I said an 85-line continuation was a suggestive place to look and was right about
the location for the wrong reason.

### And a silent divergence produced by a cap rather than a rule

`DBV` read `&SYSLIST(62)` as empty, `K'` of it as 0, skipped its own tail and
returned **`rc 0`**. **39 modules lost every late `JT*` symbol to a macro that
said it was fine.** Nothing in either assembler's output named it.

That is a shape the 166 silent divergences may well contain more of: not a wrong
rule, but a bound reached quietly by a construct large enough to cross it. It is
the first candidate mechanism for that group since cc370#264 removed the last one.

## 95.4 %, and the silent group falls for the first time — 2026-09-09

cc370#269, the buffer sweep: **+46, none lost, `cards : 91 -> 56`.** The largest
merge of the campaign, and thirty-five modules stopped being card-count
differences in one step — that bucket was 2,063 when this comparison began.

| | |
|---:|---|
| `as370` == IFOX00 | **5,275 of 5,528 (95.4 %)** |
| still differing | **253** |
| byte-identical to IBM's object | **1,204** |
| silent / `as370` alone / both flag / IFOX00 alone | **138 / 29 / 68 / 10** |

**The silent group fell 166 → 138** — the first time it has dropped. It had grown
through every merge before this one, and the thing that moved it was the shape
this document proposed for it: a **cap rather than a rule**. Four buffers held a
macro parameter at 96, a prototype default at 40, a `&SYSLIST` element at 128 and
a `SETC` value at 96, where IFOX00 holds 255 and diagnoses `IFO042` past it. Each
cut the value and then reported the *cut* length through `K'`, so a macro that
measures its own operand was told a smaller number than it was handed, generated
accordingly, and returned `rc 0`.

**That is the first mechanism to reach into the silent population all week**, and
it arrived from a hypothesis rather than from an instrument — none of the six
instruments could see it, because all of them look at what differs rather than at
what was quietly dropped.

### The four decks that moved away, and the length column that settles them

| | IFOX00 | before | after | |
|---|---:|---:|---:|---|
| `AMASPZAP` | 12,920 | 12,956 | **12,920** | exact |
| `IASXSD82` | 3,943 | 3,976 | **3,943** | exact |
| `IFCSXXXF` | 4,021 | 3,992 | 4,009 | closer |
| `IFCSXXXH` | 8,251 | 8,195 | 8,227 | closer |

**And two byte measures disagreed by 42 on `AMASPZAP`.** `retest.py`'s
`distance()` keys the image by **section name** and says +6; a hand-rolled count
keying by **ESDID** says −36. Section name is the better key and `retest.py` is
the figure to quote — but anyone re-deriving a "further" line with their own
script will get a different number from the gate's. Mine was the hand-rolled one.

### cc370#270 — a real defect with no reach, and a zero that was confirmed

A `DC` operand accepts at most **32 nominal values** and drops the rest silently;
the cut is by value count, not by card count, which varying the values per card
settles. **No module in `MVSBLD` has a `DC` operand with more than 32 values**, so
it explains nothing here.

**The zero was confirmed against a known case before being reported** — the same
scanner finds 99 commas in a 100-value fixture. That is the rule this day
produced, applied to my own negative: `$0` inside a double-quoted regex, `grep -P`
absent from this `grep`, `$MACFLAGS` unsplit by zsh, a `rm -f` on an empty glob
aborting a command line — **five instances in one day of a mistake that returns a
plausible number instead of an error.**
