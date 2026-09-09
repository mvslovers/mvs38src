# The remaining — where they are and what each block needs

> ⚠️ **Every figure below carries the commit it was derived against, and the
> commit alone is not enough.** cc370 found this file 29 merges stale while its
> mtime read as today: *fresh by mtime, stale by content*. Second time the same
> shape cost us — `as370-messages.tsv` was eleven merges behind and looked
> current too. So a derivation line now records the distance as well:
>
> ```sh
> git -C ~/repos/mvs/cc370 rev-list --count <that-commit>..main
> ```
>
> If that is not 0, the numbers under it are too large by an unknown amount and
> `cluster_remaining.py` has to be re-run before anything is planned around them.
> **Derived against `ff783f6`; run the command above before quoting anything here.**

# The remaining 96 — as measured on 2026-09-09 against `ff783f6`

**Derived against cc370 `1112488`; `git rev-list --count 1112488..main` = 0 at
writing.** The derivation has been re-cut three times today, each time because
the guard above caught it stale: `7a0cd90` was 6 merges behind, then `2f90d47`,
then `847aed7`. Promoted gate run `g323r`, compared against the recorded IFOX00
decks.

| | |
|---:|---|
| `as370` == IFOX00, **deck** | **5,427 of 5,528 (98.2 %)** with the assembly stamp normalised; **5,404** raw |
| `as370` == IFOX00, **deck and return code** | **5,403** |
| flagged-or-silent agrees (rc 4 counted as flagged) | **5,517** |
| `as370` alone flags | **3** — `IFCEL155`, `IFCSXXXF`, `IFCSXXXH` |
| IFOX00 alone flags | **4** — `IBCDASDI` (deck identical), `IBCDMPRS`, `IEAVEXS`, `IEAVRTI0` |
| byte-identical to IBM's shipped object | 1,209 of 5,056 pairs |
| `rc 0` | 4,576 |

From 3,465 (62.7 %) at `ee1090b` on 2026-09-07 — distance 130 — with **no deck
identity lost** anywhere along the way. This is the map for the last 1.9 %.

**The DLIB figure fell from 1,211 and no deck moved away from IBM's object.** It
is filtered on `as370 rc 0`, and #324 correctly took 14 modules out of that filter
by teaching `as370` to raise `IFO220` where IFOX00 does — 7 of them
DLIB-identical, against 1 joining. A control whose population moves reads exactly
like one that regressed unless the filter is stated.

**Say which identity.** On the deck the claim holds without exception. On the
stricter goal it does not: cc370#304 took `IFNX1K`, `IFNX3K` and `IFNX5V` from
`rc 0` to `rc 8`, and the gate line that carried it read `LOST : 0` and `as370
alone flags 23 -> 19` — both true, because the three decks already differed and
seven other modules improved in the same run. `retest.py` names such modules
outright now.

**What this block said before it was re-derived, and why that was wrong.** It
read *the remaining 524 … against `89fb177`*, 90.4 %. `89fb177` is **distance 29**
from `main`: the block was twenty-nine commits behind while its mtime read as the
current day, and the number it named had more than halved in the meantime. That
is the failure the warning above exists for, and it is the second time this file
has been caught in it.

The 1,211 is the `dlib` verdict `identical` exactly. Fourteen further modules
come back `identical|unpaired` — identical where the sections pair up, with a
section on one side the comparison could not match — and they are **not** in the
1,211.

## The count, reconciled

Three numbers have been used for "what is left" and they are all correct. On
`7a0cd90`:

| | |
|---:|---|
| **149** | modules whose deck differs card-for-card from IFOX00's |
| **135** | after the clock — 14 of those carry only a `&SYSTIME` stamp, and `ifox_compare.py` settles them by re-assembling with IFOX00's own `ASMDATE`/`ASMTIME` |
| **128** | after the 7 excluded: 5 CICS (`BNGC*`), 2 whose source was torn by an FTP transfer (`IBCDASDI`, `IBCDMPRS`) |

The fourteen the clock settles:

```
BLSDMSGS BLSDSTAE IFCDIP00 IFCIOHND IFNX1S IFNX5L IFNX6A IFNX6C
IFOX0B IFOX0C IFOX0E IFOX0G IFOX0I IGC0007F
```

`module-table.tsv`'s `tool` column already holds the effective verdict, so **128
is the number to quote** and `cluster_remaining.py` is right to report it. Say
which of the three any figure is before comparing it with another. The three were
539 / 531 / 524 against `89fb177`, so a figure quoted without its commit is not
merely imprecise here — it is wrong by a factor of four.

**And the exclusion list has not kept up with the family it names.** It names
five CICS modules, all `BNGC*`. Six further `BNG*` — `BNGI3270`, `BNGIDISP`,
`BNGT3270`, `BNGTDISP`, `BNGTLOCL`, `BNGTRMOT` — are inside the 128. Whether they
belong with the five is unmeasured: `BNGC3270` carries 34 `DFH*` references and
these six carry between 0 and 3, which is not enough to put them in the same
class or to keep them out of it. Recorded, not decided.

## Where they are

On the 128, against `7a0cd90`:

| signature | modules |
|---|---:|
| only TXT differs | 30 |
| card count differs by 2–9 | 22 |
| card count differs by 1 | 21 |
| only ESD/RLD/TXT | 17 |
| only ESD/TXT | 17 |
| only RLD/TXT | 12 |
| card count differs by 10+ | 7 |
| only RLD | 2 |

By length, on the same 128: **33 too short, 45 too long, 50 the right shape with
wrong content.**

**The too-short block has stopped being the bulk of the tail.** Against `89fb177`
it was 216 of 524 and every named mechanism pointed into it; here it is 33 of 128,
and the largest single length group is now *too long*. By signal, the same 128
split **48 silent divergence, 62 both flag, 16 `as370` alone, 2 IFOX00 alone** —
the `signal()` reading, which asks `as370` `rc >= 8` against IFOX00 `rc 0`. The 19
in the table at the top is the *return-code* reading, `rc <= 4` against `rc > 4`
over the whole tree; it includes two modules whose decks are identical and one
whose IFOX00 return code is 4. Two definitions, both in use, and they differ by
three.

| family | modules |
|---|---:|
| `IFC*` | 37 |
| `IFN*` | 21 |
| `IEE*` | 15 |
| `IEC*` | 14 |
| `BNG*` | 6 |
| `IGG*` | 6 |
| everything else | 29 |

## No mechanism table has been re-derived for `7a0cd90`

The three that stood here — cc370#247 (68 modules), #244 (27), #241 (52) — are
merged. Their reach figures described `89fb177` and are not carried forward; the
issues themselves are the record of what each was worth.

**No replacement table is offered, because none was measured.** Producing one
means running `cluster_remaining.py` and `rebuild_classes.py`, and both read and
rewrite the promoted state in `work/measurements/ifox-run/`. That state did not
belong to `main` when this was written, so the honest entry here is the absence
rather than a table derived from the wrong build. Re-derive after the next clean
promote; the recipe is the four steps in
[`regression-gate.md`](regression-gate.md).

What *was* measured on `7a0cd90`, read-only, is the small-delta cut: **16 of the
128** differ in one to four bytes at addresses both assemblers agree exist.

```
IEAXPALL IECVESIO IECVHDET IECVXMGN IECVXT2S IECVXURT IECVXVRT IEDQWIE
IFCS33XX IFDOLT39 IFNX5C IFNX5D IFOX0A IGC0001F IKJEBELT IKJEGMNL
```

That is down from 47 against `89fb177`, which is what the cut does as the modules
above it are fixed — it is a *shrinking* instrument, not a stable class.

## Four instruments, and each found what the others could not

This is the method statement, and it is worth more than any single class.

*The counts in this table are each instrument's yield at the merge that closed
it, not a current population. They are history and stay as they were measured.*

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

**The wide-reach mechanisms are gone**; what is left yields tens per fix. The
table above is the record of merges that landed, not a forecast — every entry in
it is closed. On `7a0cd90` the recent merges move single figures: cc370#299 was
+3 decks and +3 return codes, #296 and #294 moved **no deck at all** and were
worth taking on the return code alone.

## What "100 %" would require

Nothing structural forbids it: the goal is `as370` == IFOX00 on identical input,
and IFOX00's own return code does not enter into it. Two things make the tail
expensive:

On `7a0cd90` the two costs are no longer the same size they were:

- **78 length problems** — 33 too short, 45 too long — each "material missing or
  extra", and no named mechanism covers them since #240 closed;
- **50 shape-right modules**, correct sizes and wrong content, which is where
  single-instruction defects live — small reach each, and the small-delta cut is
  the only instrument that has reached into them.

Against `89fb177` those were 291 and 233. The tail did not just get shorter; the
*ratio* moved, and the shape-right group — the expensive one, one defect per
module — is now well under half of what remains.

There is no named sequence to give. The three mechanisms that ordered this
section are merged, no re-derived cluster table exists for `7a0cd90` (above), and
inventing an order from the last one would repeat exactly the error this file was
caught in. Re-run `small_delta.py` and `cluster_remaining.py` after the next
clean promote and order it from what they say then.

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

**Re-derived on `7a0cd90`: eighteen of the nineteen are byte-identical now.** The
one still differing is `IFCEA155`. The list above is kept because it is the
record of what #240 left behind, not because it is still a population.

## Two in the small-delta cut that are the clock, not the assembler

*Re-derived on `7a0cd90`: this holds for `IFOX0A` and no longer for `IFNX5V`.*
**`IFOX0A`** still differs in exactly four bytes, is still in the small-delta cut
above, and is still the case described here. **`IFNX5V` is not**: it differs in
**278 bytes** at addresses both assemblers agree exist, its sections are 1,773
bytes against IFOX00's 1,769, and `retest.py` puts its distance at 286. It left
the cut at cc370#304 — the same merge that took its return code from 0 to 8 —
and it is now an ordinary object divergence, not a stamp. What is behind that is
cc370's to find; what is measured is that the four-byte reading below is no
longer true of it.

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

## A seventh instrument: a third opinion on the silent 138 — 2026-09-09

cc370#270 merged: **+0, none lost, one deck closer.** Checked deck against deck:
**exactly 1 of 5,528 differs, and it is `IGC0E05A`** — whose own source has at
most **20 commas in any `DC`**, so its long one is macro-generated. That is
precisely the limitation written on #270 and declared unclosable from here. **A
stated blind spot, and the instrument that covers it finding exactly one thing
inside it** — better than the zero simply being right, because it puts a size on
what the scan could not see.

| | |
|---:|---|
| `as370` == IFOX00 | **5,275 of 5,528 (95.4 %)** |
| still differing | **253** |
| silent / `as370` alone / both flag / IFOX00 alone | **138 / 29 / 68 / 10** |

### The angle the six instruments could not give

All six compare `as370` against IFOX00 and treat IFOX00 as the authority. On a
silent divergence that is the whole difficulty: neither assembler says anything,
so nothing in either output says which is wrong.

**IBM's shipped object is a witness neither of them produced.** `three_way.py`
compares all three:

| `as370` vs IBM | IFOX00 vs IBM | modules |
|---|---|---:|
| differs | differs | 87 |
| no pair | no pair | 43 |
| **differs** | **identical** | **6** |
| identical | identical | 2 |

**Six modules are settled without any appeal to the oracle's authority**: IFOX00's
deck is byte-identical to IBM's object and `as370`'s is not. Two independent
parties agree and one does not.

```
AMASPZAP  IEHINITT  IFCEA155  IGG019GC  IGG019GD  ISTINCDT
```

`ISTINCDT` is the cheapest — 816 bytes on both sides, 96 differing, first at
`X'07'`, and the statement is `DC A(ISTC000)` in VTAM's USS definition table:
IFOX00 writes `0000000C`, `as370` writes `00000000`, and the adcons after it
diverge the same way.

**The 87 cannot be settled this way and that is the honest limit**: where both
assemblers differ from IBM's object, the *source* does not match what IBM
shipped, which is the gap this whole project exists to close. The 43 have no DLIB
member at all — mostly `IER*`, the sort package MVS/CE does not carry.

And two modules — `HMASMTMD`, `IFFAHA16` — match IBM within `cmplmd370`'s
tolerance while differing from each other, which says the tolerance is wider than
a byte comparison and is worth knowing before quoting either verdict.

## 95.6 %, a divergence with no wrong bytes, and text filed under the wrong section

cc370#280 merged: **+1, `IEHINITT`.** `ORG *+200` as a maintenance area reserves
space and emits **no TXT at all**; `as370` tracked the high-water mark from
`DS`/`DC` alone, so the section was 200 bytes short and the next one 200 forward.
**The highest TXT byte is `X'0C42'` on both sides.**

**That is a second shape for the silent group, and it names a blind spot in four
of my seven instruments.** `small_delta.py`, `first_divergence.py`,
`cluster_remaining.py` and the byte histogram all read TXT; a divergence that
lives entirely in the ESD has no wrong bytes for them to find. `seclen()` and the
three-way table are the two that can see it — and `seclen` exists only because
cc370 found the same blind spot from the other side on #174.

| | |
|---:|---|
| `as370` == IFOX00 | **5,287 of 5,528 (95.6 %)** |
| still differing | **241** |
| byte-identical to IBM's object | **1,208** |

### `AMASPZAP`, and a total that hid two whole sections

I had it filed as *"moved its length onto IFOX00's exactly and stayed thousands
of bytes wrong"* — from **totals**. Per section:

| | `as370` | IFOX00 | differing |
|---|---:|---:|---:|
| `AMASPZAP` | 5,256 B | 5,256 B | **16** |
| `AMASZDMP` | 964 B | 964 B | **0** |
| `AMASZCON` | **0 B** | 3,654 B | 3,654 |
| `AMASZIOR` | **0 B** | 3,046 B | 3,046 |

**The bytes are not missing.** They are in the deck under the *external
reference*'s ESDID, created by `DC V(AMASZCON)` at line 1142 — before the
`AMASZCON CSECT` at 2826. IFOX00 has the same two ERs and files the text under
the SDs. **cc370#281**, six cards.

**Two readings of this module were wrong before that**, and both were failures of
aggregation rather than of measurement: mine from whole-module totals, cc370's
from *"different origins swamp it"*. `distance()` has keyed by section name since
#171; what neither of us did was **report** per section. The class file that
stopped measuring its own issue was the same failure, and so was the stale
`as370-messages.tsv` — **the number was available and nobody looked at it in the
right shape.**

## 95.8 %: four of the six settled, and every one lived outside the text

cc370#282 merged as #283: **+7, none lost, none further.** `sect_hwm` was raised
by `put()`, which runs only in pass 2, while `assign_origins()` chains origins
from the *pass-1* lengths — so a section ending in **machine instructions** was
measured only to its last `DS`/`DC` and the next section was placed inside it. The
section's own ESD length was right the whole time; only its **neighbour's origin**
was wrong.

| | |
|---:|---|
| `as370` == IFOX00 | **5,294 of 5,528 (95.8 %)** |
| still differing | **234** |
| silent / `as370` alone / both flag / IFOX00 alone | **128 / 23 / 66 / 9** |

### `AMASPZAP`: 7,252 → 0, and it appears in no gained list

Compared **by address alone, ignoring which ESDID the text is filed under**, the
module is now byte-for-byte identical to IFOX00 — 12,920 bytes on both sides. All
that remains is cc370#281's filing.

**Two defects stacked, and the module reads as untouched by either metric taken
alone**: `gained` says no because the cards differ, the ESDID-keyed image says no
because the text is under the wrong id. Only a third view — address without
ESDID — shows it.

### The through-line of the third witness

```
ISTINCDT   cc370#274   a term after a substring is concatenated
IGG019GC   cc370#278   USING *+8 is an expression
IGG019GD   cc370#278
IEHINITT   cc370#280   ORG past the content extends the section
AMASPZAP   cc370#283   pass-1 high-water mark   (image; #281 open on the filing)
IFCEA155   open        -8 across 3,876 bytes, section 8 short
```

**Four of the five closed were length or origin defects that no text-reading
instrument could see.** The three-way table never said *what* was wrong — only
*which module to open* — and every one turned out to be a divergence outside the
bytes anyone was comparing. That is a better argument for the instrument than its
hit rate: it selects on a property none of the other six can test.

The table now settles **two**: `AMASPZAP` (filing) and `IFCEA155`.

### Aggregation, four times in one day

Every input correct, and the number looked at in the wrong shape:

| | |
|---|---|
| `addressability.txt` | stopped measuring its own issue when a fix made deck and diagnostic disagree |
| `as370-messages.tsv` | eleven merges stale, and *"the silent group has not moved"* was a claim about a file |
| `AMASPZAP`, twice | my module totals; cc370's *"different origins swamp it"* — neither looked per section |
| `AMASPZAP` again | image to zero, invisible in `gained` and in the ESDID-keyed image both |

**Only the last was caught before it shipped**, and only because cc370
re-measured the module while writing the commit message rather than after.

## 96.6 %, and the eighth instrument answers the question cc370 asked for

cc370#281 merged as #284: **+46, none lost, none further, `closer : 0`.**
`AMASPZAP` plus **45 TSO command processors** — `IKJEBE*`, `IKJEG*`, `IKJCT*` —
that reference their own constant sections before defining them. An idiom, not an
accident, which is why one module's diagnosis carried a family.

**`closer : 0` beside `+46` is the shape**: a filing defect has no partial state.
The text is under the right id or it is not.

| | |
|---:|---|
| `as370` == IFOX00 | **5,340 of 5,528 (96.6 %)** |
| still differing | **188** |
| **silent** | **90** — from 166 this evening |
| byte-identical to IBM's object | **1,209** |

### `section_view.py` — three views, and the disagreements are the finding

cc370 asked for *the sections that are empty on one side and not the other*.
Built, and generalised: compare the deck at three layers and read where they part.

| cards | (esdid, addr) | addr alone | what it is |
|---|---|---|---|
| differ | differ | **same** | **a filing defect** — right bytes, wrong section (cc370#281) |
| differ | **same** | same | **the object is right and the deck is not** — cc370#199 |
| differ | differ | differ | ordinary wrong content |

Of the 188: **171 content, 10 object-right-deck-wrong, 7 excluded/absent.** And
the empty-section question outright:

```
IECVHDET  IECVHIDT   as370      8 B   IFOX00      0 B
ISTINCU7  IKJEGAPL   as370    182 B   IFOX00      0 B
ISTINCU7  IKJEGAT    as370     50 B   IFOX00      0 B
ISTNSC00  MSGCSECT   as370      0 B   IFOX00    429 B
ISTNSC00  RWKAREAS   as370      0 B   IFOX00   3360 B
```

Five sections in three modules, and none of the seven earlier instruments asks it.

### cc370#285 — #281's sibling one level down

The ten in the middle row split: **six are one defect.** A section outranks an ER
of the same name since #284; a **label definition does not**. `DC V(IKJEGIST)`
registers an ER, `ENTRY IKJEGIST` and the label follow, and the `LD` entry gets
the ER's address:

```
IKJEGCVT  IKJEGIST   IFOX00 0017A8   as370 000000
IKJEBESA  IKJEBSA3   IFOX00 0014D8   as370 000000
IKJEHREN  IKJEHSMG   IFOX00 001D7C   as370 0006A4
```

**Every TXT card is identical in all six.** One `LD` address per module is the
entire divergence, and the two zeros say plainly which entry was written: the
ER's, which carries no address at all.

Two more are RLD address lists with entries both **missing and extra**
(`IGC0E05A`, `IFFAHA16`), and two are ordinary content that had landed in the
class by accident.

### What the third witness proved about the silent group

Of the five modules it settled and closed, **not one was a wrong byte of code
generation.** Every one was a length, an origin, or a filing — the text `as370`
emitted was already right, and what diverged was where it said the text belonged.
That is the first structural statement anyone has been able to make about the
silent divergences, and it is why the three-view comparison exists.

## 96.7 %, and a third silent cap — 2026-09-09

cc370#285 merged as #286: **+6, exactly the six, none lost, `closer : 0` again.**
The cause is better than the symptom I filed: every `S_ER` assignment is guarded
by `if (!s->defined)`, so **the type is only ever set while the symbol is
undefined and never taken back when the definition arrives.**

| | |
|---:|---|
| `as370` == IFOX00 | **5,346 of 5,528 (96.7 %)** |
| still differing | **175** |
| **silent** | **85** — from 166 earlier this evening |

**`closer : 0` is a diagnostic in its own right.** `+46 closer 0` and
`+6 closer 0` say the defect was **binary before anyone read the code** — an
ordinary content defect has partial states and essentially never produces that
line. A gate line of that shape is a hint about the *kind* of defect, and it is
free.

### cc370#287 — a macro definition of 4,096 lines loses its tail

`ISTNSC00` was the empty-section case on IFOX00's side, and it is one call:

```
266:          NETSOL SYSTEM=VS2
```

`SYS1.AMACLIB(NETSOL)` is **6,881 lines**. A macro body of **4,095 lines works and
4,096 does not** — everything past the cut is absent, with no diagnostic of its
own. `R12 EQU 12` sits at line 5,814, so `as370` reports `Undefined symbol - R12`
on a `STM` the macro generates at line 404, and `RWKAREAS` and `MSGCSECT` never
appear at all: one section and 5,007 bytes where IFOX00 has three and 12,506.

Reach **6 of the 175** — `ISTNSC00` through `NETSOL`, and `IGG019Q2` `IGG019Q3`
`IGG019Q4` `IGG019Q5` `IGG019R0` through `LINEEND` (5,828 lines).

**Third silent cap**, after #269's four buffers and #271's `DC` value list. Each
cuts at a bound and carries on as though nothing had been cut, so the failure
surfaces somewhere else — here as an undefined register equate 5,400 lines from
the cause.

### `$0` again, and this time the control caught it

My first reach scan reported **zero callers for all three macros** — `$0` expanded
inside a double-quoted `[A-Z@#$0-9]`, the **second time today**. What differed is
that I ran the control: the same command must find `ISTNSC00` for `NETSOL`,
because that is the module the defect was diagnosed on. It did not, so the scan
was wrong rather than the answer.

**A known-answer control is the only thing that has caught any of these**, and it
has now caught two of six. The other four were found by someone else.

## 96.8 %: `END` ends the assembly, and a worry that measured to nothing

cc370#289 merged: **+2 (`IERRCJ`, `ISTINCU7`), none lost.** Cards after the first
`END` are not read, not listed and not assembled — and **3,231 of the 5,528
`MVSBLD` members carry non-blank cards behind theirs**, not stray comments but
whole second and third modules concatenated into one member (`ICKDV03` has 17,503).

**I expected that to have polluted every diagnostic class and it did not.**
Measured across both binaries:

| | |
|---|---:|
| total flagged statements | 21,370 → **21,087** |
| modules whose count changed | **2** |
| `ISTINCU7` | 329 → **0** |
| `IBCDMPRS` | 10 → 8 |
| `IECVHDET` | 68 → **116** |

**283 fewer, and 329 of it is one module.** So the concern was real, checkable and
false: a tail behind `END` almost never produced a diagnostic, because it almost
never got far enough to. `ISTINCU7` was the exception and it was the module the
defect was found on.

And my first comparison **missed `ISTINCU7` entirely** — the filter required both
counts to be digits, and the post-fix `flagged` field is *empty* when `rc` is 0.
The totals disagreed by 283 and that is the only reason I looked. **A filter that
drops the row you care about is the same shape as the six shell traps today**, and
the check that caught it was arithmetic that had to add up.

`IECVHDET` going **up** is worth passing on: it is the last of the empty-section
list, and #289 made it noisier rather than quieter.

| | |
|---:|---|
| `as370` == IFOX00 | **5,348 of 5,528 (96.8 %)** |
| still differing | **173** |

## The first merge measured on the stricter goal — 2026-09-09

`as370 == IFOX00` now means the deck **and** the return code. cc370#162 is the
first change gated on it, and it prints a shape this gate has never produced:

```
as370 == IFOX00 : 5334 -> 5334   (+0)      gained 0  LOST 0  closer 0  FURTHER 0

  return code agrees : 5377 -> 5493   (+116)
    as370 alone flags : 33 -> 33
    IFOX00 alone flags: 118 -> 2
  DECK AND RC BOTH   : 5210 -> 5325   (+115)
```

**Not one of the 5,528 decks moved by a byte** — checked deck against deck, not by
the counts. The decks were right and stayed right; the entire change is in the
verdict. **+115 against a completely still deck comparison**, and it was invisible
until the goal was stated properly.

| | |
|---:|---|
| deck identical | **5,348 of 5,528 (96.7 %)** |
| **deck and return code both** | **5,325 (96.3 %)** |
| still differing in the deck | 176 — 84 silent, 64 both flag, 22 `as370` alone, 2 IFOX00 alone, 1 timing out |
| byte-identical to IBM's object | 1,210 |
| `deck_lint` complaints | 5, all the excluded CICS modules |

The two left where IFOX00 flags and `as370` does not are `IEAVEXS` and
`IEAVRTI0`, both `IFO007 USAGE OF &CODE IS INCONSISTENT WITH ITS DECLARATION`.

### A new diagnostic makes silent caps loud

The change alone read `as370 alone flags : 33 -> 60` — **27 modules newly flagged
against macros that declare their keywords perfectly well.** `char pname[100][20]`
against `SYS1.MACLIB(IDACB2)`'s **127** declared parameters, cc370#292.

**It cost nothing for eleven months because a parameter nobody passes is a
parameter nobody misses.** The moment an undeclared keyword became a *diagnostic*,
every call passing one of the 27 raised `IFO092`.

Fourth silent cap this week and **the first found by a fix rather than by a
measurement**. It is also the mirror of the shape traded all evening — *the
complaint goes and the module stays* — running backwards: here the module was
already fine and the complaint was new and wrong.

### Two near-misses on cc370's side, both worth the fix

**A baseline that was not `main`.** The first gate ran against a tree that
included the #290 code cc370 had withdrawn, and reported `IECVHDET(+2) FURTHER`
against a state that does not exist. *A baseline is a claim about what is on
`main`* — promoting after every merge is what keeps that claim true.

**And an ecosystem worry that measured false.** `vsam_dcb` going `rc 0 → rc 8` read
as libc370's vendored macros being a cut-down copy, which would have meant every
`mbt` build failing at `rc >= 8`. Checkable only because this corpus assembles
against the **distribution** libraries rather than a vendored subset — two
independent macro paths, a property of the setup that nobody designed for this and
that settled it.

### And a number for the alarm

`IFCEL155` is 41 s alone and over 150 s under `-P 8`: a **3.7× contention factor**.
The alarm measures the module *plus seven neighbours*, so a bound picked from a
solo run is wrong by about that much — which is how 20, 240 and 150 were all
chosen and all wrong. 400 s is ten times the solo time, the first bound set with
the factor in it rather than against it.

## A test can keep passing while ceasing to test what it was for — 2026-09-09

cc370#294: `as370 alone flags 33 → 25`, `DECK AND RC BOTH 5325 → 5333`, **0 of
5,528 decks changed.** Eight modules where `IFOX00` gives a statement-losing
continuation and a harmless continued comment the same severity 4, and `as370`
split them and returned 8 — with the reason written at the call site, *a build
must not pass silently*.

**cc370 put it to Mike rather than flipping it**, because it reverses a deliberate
choice with a stated safety rationale rather than fixing a defect, and because the
consequence is outward: `mbt` fails at `rc >= 8`, so a module assembled against a
mangled macro library would go from failing to warning — cc370#115's exact
scenario, 150 modules compared in good faith against source the assembler had
eaten. The answer was **faithful by default, guard on request**. Verified here:

```
default        -> rc 4        --strict-cont  -> rc 8
```

### The finding is in the fixtures

`diag_cap` and `libmac_mend` both asserted `rc 8`, so the default change broke
them — and **lowering their expectation to 4 would have left them green while
converting them into re-tests of `cont72`.** What they exist to check is that a
discarded statement is still *counted* past the print cap, and that a column-72
comment inside a library macro definition eats the model statement. Neither is a
claim about severity. Passing `--strict-cont` keeps them testing their own claim.

**Three tests encoded one policy decision and only one of them was about the
policy.** That belongs beside the four aggregation failures: every input correct,
every test green, and two of them no longer measuring their subject.

And `cont72` pins **both** levels now — a fixture that pins only the default
cannot tell the flag from a no-op, which is the control rule again: **the case a
control must exercise is the one that can go wrong, not the one that must pass.**

## `BLSCAMOD` reduced to three lines, and five mechanisms eliminated — 2026-09-09

cc370 measured the `MNOTE` cluster and found their own guess wrong: the notes are
**the macros' own**, raised because `as370` hands them something IFOX00 does not,
and 7 of the 8 also differ in the deck. `BLSCAMOD` is the exception — deck
byte-identical, `rc 8` alone — and they left it *not isolated*.

**It reproduces in three lines against the real macro:**

```
T        CSECT
A        BLSCAMMM B,RDQSAMDS,Q
         END
```

→ `MNOTE 8,'' IS AN INVALID VALUE FOR 'DYRB(2,1)'. NO FLAGS1 BIT IS SET.`

### The path, and what it requires

`BLSCAMMM` line 321 calls `BLSCAMM1 &DYRB(2)` to count sublist entries into the
global `&BLSCAGA`; `&DYRB` takes its default `AL` and is not a sublist, so the
count must be **0** and the loop at `.TEST1 AIF (&CTR GT 0).LOOP1` must not run.
`as370` generates `BLSCAMM2 ,1` — so **`&CTR` is 1**, and the only source of that
is `&BLSCAGA`.

### Five mechanisms eliminated, each by measurement

| probe | result |
|---|---|
| `BLSCAMM1` called directly — bare, `AL`, `(A,B)` | `&BLSCAGA` = **0, 1, 2** — correct |
| `&P(2)` on `&P=AL`, substituted into an inner macro call | arrives **empty** — correct |
| `K'` of a `SETC` assigned an empty parameter | **0** — correct |
| an inner macro's `LCLA &CTR` leaking into the caller | does not leak — correct |
| `LCLB`/`LCLC` **mid-body** (`BLSCAMMM` has them at lines 319–320) | locals and globals unchanged — correct |

So `BLSCAMM1` returns the right count when called by hand and the wrong one when
called from `BLSCAMMM`, with every obvious difference between those two paths
measured and ruled out. **The defect still does not survive simplification** —
but the reproduction is now three lines instead of a module, and the next person
starts five candidates further on.

### And one side-observation, unverified against the oracle

A **source macro definition does not override a machine mnemonic**:

```
         MACRO
         M     &A
         MNOTE 4,'MACRO M CALLED'
         MEND
T        CSECT
         M     1,2            -> 5C10 0002, the Multiply instruction, no MNOTE
```

IBM's assembler gives a source macro precedence over an identically-named
instruction — that is how an instruction is overridden deliberately. **Not
checked against IFOX00**, and it is not in this cluster's path; recorded because
it turned up while a fixture was named `M` by accident, and a fixture whose name
collides with a mnemonic silently tests nothing.

## A reduction can remove the defect while keeping everything you were looking at

cc370#296 isolated `BLSCAMOD`, and the answer was the eighth candidate after our
seven eliminations:

```
         BLSCAMM1 &DYRB(2)         COUNT FLAGS1 ENTRIES INTO &BLSCAGA
```

**`&DYRB(2)` substituted to nothing, and the operand took the remark's first
word.** The counting macro was handed the string **`COUNT`**, called it a
one-element list, and the `MNOTE` was a macro complaining — correctly — about
input we had invented.

`as370 alone flags 25 → 24`, `DECK AND RC BOTH 5333 → 5334`, **0 of 5,528 decks
changed**, and the three-line reproducer goes from four MNOTEs to none.

### Why neither of us could reduce it

**The defect needs an operand that becomes empty *and* a remark behind it.** Every
simplification either of us wrote dropped one of the two — the direct
`BLSCAMM1` calls had no remark, the `INNER &P(2)` probe had none either. All seven
eliminations were *correct measurements of something that was not the defect*.

That belongs beside the aggregation failures and the tests that stop testing their
subject:

> A reduction can remove the defect while keeping everything you were looking at.

What broke it was **instrumenting a local copy of the macro and printing what
actually arrived**, rather than reasoning about what should. Every instrument in
this repository reads the *output*; this was a question about the *input*.

### And the mnemonic question, answered by the oracle against my premise

`MACRO / M &A / MEND` then `M 1,2`: IFOX00 gives **`IFO043 MACRO PROTOTYPE
STATEMENT HAS INVALID OP CODE` at rc 12**. Assembler XF does not give a source
macro precedence over a mnemonic — **it refuses to let you name one that way**, so
precedence never arises. `OPSYN` is HLASM's answer and XF has none.

`as370`'s behaviour is therefore right and only its silence is wrong — cc370#297,
filed with the reach stated as probably zero. **The premise I brought to it was
wrong, which is exactly why it was worth an oracle run rather than an assumption.**

## A message count is a floor — the third way the key fails

cc370#299 (`BNPR`, `BNMR`): **+3 decks and +3 return codes**, none lost. And two of
the three — `IECVEXCP`, `IGG019Q0` — **were not in the `Undefined operation code`
cluster at all.** They reach the missing mnemonics behind conditional assembly the
message never got to, so they were sitting in the silent population.

**The message column under-counted its own cause by two thirds.**

That is a third, distinct failure of clustering by message:

| | |
|---|---|
| `IFO026` | the message **was** the defect — the key worked |
| `MNOTE` | the message is a downstream macro's opinion — the key selects a symptom |
| **`Undefined operation code`** | **the message is right and its population is a lower bound** |

The first two say the key is *wrong*. This one says it is **incomplete**, in a
direction nothing here measures: **a module can carry a defect and never reach
it.** Every reach figure quoted from a message count in this document is a floor
for that reason, and none of them said so.

| | |
|---:|---|
| deck identical | **5,351 of 5,528** |
| **deck and return code both** | **5,337** |
| still differing | 173 — 82 silent, 64 both flag, 23 `as370` alone, 2 IFOX00 alone, 1 timing out |

## The literal pool — 23 of the 53 resolved silent divergences, 2026-09-09

Handed to cc370 as two packages. The reason it is worth stating here as well is
that the arithmetic closes, and that is what turns a cluster into a case.

**L1 — the pool is N bytes short and every later displacement is N lower.**

```
IEESD03D IEESE03D IEESF03D IEESG03D IEESH03D IEESI03D IEESK03D IEESL03D
IEESQ03D IEESR03D IEESZ03D IEEZA03D IEEZJ03D AMDPRUIM IFNX4M   IFNX4T
```

| | Δ length | Δ displacement |
|---|---:|---:|
| `IEESI03D` | 36 | 36 |
| `IEEZA03D` | 24 | 24 |
| `IEESE03D` | 12 | 12 |
| `AMDPRUIM` | 8 | 8 |
| `IFNX4M` | 4 | 4 |

`as370`'s object is exactly N bytes shorter than IFOX00's and every displacement
past the pool is exactly N lower — on all sixteen, with N always a multiple of 4.
Thirteen of them diverge at **address 0x000005**, the displacement byte of the
first instruction. The sources carry mixed literal widths (`IEESD03D` has `=A(`
`=C'` `=F'` `=H'` `=X'`), so alignment padding inside the pool is the first thing
to test.

**L2 — same length, wrong offset.** `IFNX1J IFNX2A IFNX3N IFNX4D IFNX4N IFNX4S
IFNX4V`: Δ length **0**, Δ displacement **exactly 8** (4 on `IFNX4S`). Same pool,
different order within it.

**What was deliberately left out, and why it matters.** `BNGI3270 BNGIDISP
BNGT3270 BNGTDISP BNGTLOCL BNGTRMOT IFDOLT12 IFDOLT14 IFDOLT39` also first
diverge at a literal reference — nine more modules, and it would have made the
package half again as large. Their two deltas do not agree at all (`IFDOLT14` is
−1216 bytes against −5). Grouping by *where* the divergence appears would have
swept them in; grouping by *whether the numbers reconcile* keeps them out. The
first cut of this cluster had all 35 modules in one package and was wrong.

Data: `work/measurements/ifox-run/first-divergence.tsv`.

## After cc370#318: the literal pool is closed, and what is left has no families

`847aed7` — the duplication factor a literal carries. **`as370 == IFOX00` 5,398 →
5,418 (98.0 %), silent divergence 56 → 36, decks differing 125 → 105.**

Both packages above were **one defect**: `lit_classify()` skipped the duplication
factor and never applied it, so `=8X'0F'` measured one byte. The pool's segment
key is the alignment its *length* implies, so a literal of the wrong length lands
in the wrong segment as well — which is why the same fault showed as a short pool
in L1 and as a correct-length pool in the wrong order in L2.

**My alignment-padding reading was the right place and the wrong mechanism.** The
multiples of 4 were real; they were the literal lengths the segment key is
derived from, not padding. What settled it was cc370's negative fixture: a
hand-built `pool.s` with mixed `=A =C =D =F =H =X` in an awkward reference order,
on which **both assemblers produced the identical pool**. A control that
reproduces nothing is still an answer, provided it was capable of failing.

**The remaining silent class is pairs, not families.** Largest cluster is 2:

| | |
|---|---|
| `IFNX4D IFNX4N` | `=FS3'65535'`, Δ length **0** both |
| `IFNX4M IFNX4T` | `LH R11,=Y(MAXDBL)`, Δ length **+4** both, same address `0x45` |
| `BNGTLOCL BNGTRMOT` | the same `CLC 15(3,INREG),=C'SS='`, Δ length **−9** both |

The six `BNG*` still first diverge at a literal reference, but their deltas are
+13, −10, +10, −16, −9, −9 — mixed signs, so they are not the pool. Kept out of
the literal heading deliberately; see the note above about a hunting list going
stale when a heading outlives what it describes.

`IEESC03D` moved **backwards** (+4 bytes) in the same merge that made twelve of
its siblings identical — a second defect the first one was masking. Named rather
than averaged in.

## After #319, #322 and #324 — 5,424 of 5,528 (98.1 %), and five classes are empty

| | |
|---|---:|
| `as370 == IFOX00` | **5,424 (98.1 %)** |
| decks differing | **99** |
| silent divergence | 36 |
| `as370 alone flags` | **3** |
| `IFOX00 alone flags` | 4 |

Empty and closed: `addressability` (#154), `undefined-symbol` (#153),
`continuation-consumed` (#158), `duplication-factor` (#157), `symbol-over-8`
(#159), `undefined-opcode` (#155), `relocatable-displacement`.

**Three of those ended on the same module.** `undefined-symbol` went 39 → 1,
`addressability` 36 → 9 → 1, and `section-one-side` 4 → 2, and in each case the
last member standing was `ISTNSC00` — one 4,096-line macro-body cut wearing three
different diagnostics. Nothing in the issue titles said so; the regenerated class
lists did, because they group by what the assembler reported rather than by what
the problem was called.

Still open with members: `section-one-side` (`IECVHDET ISTNSC00`), `prologue`
(`IECVXMGN IECVXVRU IGG019RO`), `ifox-alone-flags` (`IBCDASDI IBCDMPRS IEAVEXS
IEAVRTI0`).

## The largest remaining class is not the assembler's — 2026-09-09

`both flag, and the decks differ` is **57 of the 99**, and reading that as "the
biggest package for cc370" would be wrong. Split by what the oracle objected to:

| | modules |
|---|---:|
| blocked on the missing `COPY` member **`IFCMACS`** | **33** |
| the rest | 24 |

The 33 are the EREP family — `IFCE*` 27, `IFCS*` 6 — and IFOX00's own message is
`IFO068 COPY MEMBER IFCMACS NOT FOUND IN LIBRARY`. **Neither assembler has it**,
so both fail, both produce a wrong deck, and the two decks differ only in *how*
they failed.

**`IFCMACS` is on Dave Kreiss' own SMP tape** and already extracted to
`work/macros/kreiss-smp/IFCMACS` — 77 cards defining `SYSRELN`. Putting it on
`as370`'s path resolves the `COPY` and changes **nothing else**: `IFCSI115` still
ends `rc 8` with the same 166 diagnostics and the same 480-byte deck, because what
it then wants is `SUMMARY` and `DSGEN`, the EREP family from
[`missing-macros.md`](missing-macros.md). `work/macros/erep-instream/` records
that those five were measured and recover nothing.

And the 24 are mostly the same story one level along. Both assemblers name the
**same undefined symbols** — `BASER`, `RENTRY`, `UCBR`, `IOSBR`, `CWORK260` —
which is a macro absent from both sides, not a divergence between them.
`IFO195 INVALID USING OR DROP` on 22 of the 24 is what follows from a `USING` on
a symbol that never got defined. `IECVOID` is the `MODID` maintenance-level case
already in [`ifox-objections.md`](ifox-objections.md).

**So the surface that is genuinely cc370's is about 46 modules, not 99:**

| | modules | whose problem |
|---|---:|---|
| silent divergence | 36 | **cc370** — no families left, largest cluster is two |
| `as370` alone flags | 3 | **cc370** — `IFCEL155 IFCSXXXF IFCSXXXH` |
| IFOX00 alone flags, deck differs | 3 | **cc370** — `IBCDMPRS IEAVEXS IEAVRTI0` |
| the 0-versus-4 boundary | 4 | **cc370** — `IFO026` ×3, an MNOTE ×1 |
| both flag, deck differs | 57 | **macro hunt** — see above |

Saying "the largest class is 57" without that split would send the next round of
work at modules no assembler change can fix, and the fix would be measured
against a reference IFOX00 itself flagged.

## After #328 and the EREP adoption — 5,427 of 5,528 (98.2 %)

| | |
|---|---:|
| decks differing | **96** |
| silent divergence | **33** — and no cluster larger than **one** |
| `as370` alone flags | 3 |
| `IFOX00` alone flags | 4 |
| both flag, decks differ | 57 — of which 33 are the EREP family |

**The silent class has run out of pairs.** After the scale-modifier fix took
`IFNX4D IFNX4N IFNX5F` together, `first_divergence.py` clusters the remaining 33
into groups of one. Every case from here is its own case.

The shape of what is left, by what differs in the deck: 25 only TXT, 21 a card
count off by 2–9, 14 only ESD/TXT, 12 only RLD/TXT, 11 off by one card, 9
ESD/RLD/TXT, 2 only RLD, 1 off by ten or more.
