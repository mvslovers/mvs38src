# Is TK5's IFOX00 the same assembler as MVS/CE's?

2026-09-10. [`fahrplan.md`](fahrplan.md) stage 1, first probe. Every recorded
figure in this project is against **MVS/CE's** Assembler XF; TK5 carries 115
USERMODs against MVS/CE's 37, so the two may not be the same program. If they are
not, moving the baseline to TK5 costs a re-run of all 5,528 reference decks.

## The probe, and why it is the RLD `R` field

cc370 measured that `as370` and MVS/CE's IFOX00 produce an **image-identical**
module for ten `IFNX*`/`IFOX*` modules and differ only in the RLD `R` field — the
ESDID the relocation points at. `as370` names the enclosing `SD` where IFOX00
names the `LD` or `ER` entry.

That field is a **discrete value**. It depends on neither the assembly stamp nor
the clock, which matters here more than anywhere else in the corpus: **21 of the
26 stamp-dependent modules in the whole tree are this same family**, because
Assembler XF assembles itself and writes its own build time into its own object.
A whole-deck comparison of these modules against a deck recorded three days
earlier *must* differ. The `R` field does not.

## Setup

Assembled on **`MVSTK5-BLD`** (`:8085`). `MVSTK5-REF` was not written to.

The macro input is held constant: `MVSCE-EXP`'s `IBMUSER.PVTMAC`, all 453
members, copied byte for byte to `HERC01.PVTMAC` and used as the seventh SYSLIB,
exactly as the oracle run does. **The question is whether the assemblers differ,
so the macros must not.**

### The first attempt was a failure that looked like a finding

Run without that seventh library, `IFOX0A` came back `CC 0012` with 527
diagnostics — `R1`, `R3`, `R13` undefined, the register equates — and the RLD
comparison dutifully reported **TK5 1 entry, MVS/CE 3, different**. That reads
exactly like a lineage result. It is the return code of a failed job. The probe
now refuses to compare a deck whose job did not end `0000` or `0004`.

## Result

| module | rc TK5 | RLD entries TK5 / CE | RLD | deck |
|---|---|---|---|---|
| `IEFBR14` *(control)* | 0000 | 0 / 0 | same | **byte-identical** |
| `IEDUSSTB` *(control)* | 0000 | 2 / 2 | same | **byte-identical** |
| `IFNX1A` | 0000 | 38 / 38 | **same** | stamp only |
| `IFNX1J` | 0000 | 1 / 1 | **same** | stamp only |
| `IFNX3N` | 0000 | 1 / 1 | **same** | stamp only |
| `IFNX5A` | 0000 | 11 / 11 | **same** | stamp only |
| `IFNX5C` | 0000 | 4 / 4 | **same** | stamp only |
| `IFNX5V` | 0000 | 2 / 2 | **same** | stamp only |
| `IFNX6B` | 0000 | 3 / 3 | **same** | stamp only |
| `IFOX0A` | 0008 | — | — | rc 0008 on MVS/CE too |
| `IFOX0D` | 0008 | — | — | rc 0008 on MVS/CE too |
| `IFNX5D` | 0008 | — | — | rc 0008 on MVS/CE too |

**Two controls came back byte-identical**, which is what says the probe is
measuring anything at all. **Seven modules: every RLD entry identical** — `R`,
`P` and address, continuation bit honoured. **Three failed, and failed the same
way on both systems** (`ifox_rc 0008` in `state.tsv`), so even the failures agree.

"Stamp only" was verified, not assumed:

```
IFNX5C  TXT card 26, cols 44-54   TK5 'IFNX5C00 11.40 09/10/26'
                                  CE  'IFNX5C00 02.40 09/07/26'
        END card 29, col 52       TK5 ...26253    CE ...26250
```

Five differing bytes in the whole 2,400-byte deck: the eyecatcher's build time in
the module's own text, and the julian date on the `END` card. `IFNX1J` is the same
shape, seven bytes.

## What this settles

**For cc370:** the `R`-field divergence is **`as370`'s**, not a lineage
difference. TK5's IFOX00 places the relocation exactly where MVS/CE's does.
cc370#186 has a direction of cause, not only a membership rule.

**For the Fahrplan:** on this sample the two assemblers are indistinguishable —
identical decks where nothing is stamped, identical RLDs where something is,
identical return codes where both fail. Together with `BAS 14,TGT` assembling to
`4DE0 F004` at severity 0 on both ([`ifox-lineage.md`](ifox-lineage.md)), TK5's
IFOX00 looks like MVS/CE's.

**What it does not settle.** Twelve modules are not 5,528, and they are drawn from
one family — the assembler's own source, which is the family most likely to be
identical because both systems build it from the same maintenance. The corpus run
is still the test. What this buys is the right to expect a null result from it,
and a probe cheap enough to repeat.

It also does not clear the macro question:
[`macro-tk5-vs-ce.md`](macro-tk5-vs-ce.md) counts 158 differing members, and this
probe sidestepped them by carrying MVS/CE's `IBMUSER.PVTMAC` across rather than
resolving them.

---

## Addendum: the two-card fixture reproduces nothing

cc370 localised the `R`-field difference to `as370/src/as370.c:1453-1457`
(`add_reloc()`), where a symbol with no ESDID of its own is resolved through its
owning section, and raised the sharper half of the hypothesis: **an A-con on an
`EXTRN` symbol** relocated against the enclosing CSECT instead of its `ER` entry
would be a binding error, not cosmetics.

Tested before anyone touches the line — the fixture they asked for:

```
RELFIX   CSECT
         EXTRN EXTSYM
         ENTRY LOCLAB
         DC    A(EXTSYM)      A-con on an EXTRN
         DC    A(LOCLAB)      A-con on an ENTRY label
         DC    V(EXTSYM)      V-con, takes the isV branch
         DC    A(RELFIX)      A-con on the section itself
LOCLAB   DS    0H
         DC    A(SIS)         A-con into the sister section
SIS      CSECT
         DS    0H
         END
```

IFOX00 on `MVSCE-LAB`, `as370` at `5f326b4`, both decks 400 bytes:

| | R | P | address | |
|---|--:|--:|---|---|
| `A(EXTSYM)` | **2** | 1 | `0x0000` | the `ER` entry — **both** |
| `A(RELFIX)` | 1 | 1 | `0x0004` | |
| `V(EXTSYM)` | **2** | 1 | `0x0008` | |
| `A(LOCLAB)` | **1** | 1 | `0x000c` | the enclosing section — **both** |
| `A(SIS)` | 3 | 1 | `0x0010` | |

**Every entry identical.** The A-con on an `EXTRN` is relocated against its `ER`
entry by `as370` too, so the binding-error half of the hypothesis is not
reproduced here. And both assemblers resolve an A-con on an `ENTRY` label through
the enclosing section — `R=1`, not the `LD`'s own id.

**A fixture that reproduces nothing is still an answer when it could have
failed**, and this one could: it contains all four constructs and would have
shown a difference in any of them.

What it narrows: the real cases have a different ESD layout. In `IFNX6B` the
`LD` is id 2 and the `ER` id 3; here the `ER` is id 2 and the `LD` shares id 3
with the sister section. So whatever produces the difference is bound up with
**how the ESD is numbered** in those modules, not with the constructs on their
own. The next fixture has to reproduce the layout, not just the operands.


### The cause, found by cc370 and confirmed against the oracle

The narrowing above pointed at the ESD layout. It was not that either — cc370
found that their `LD id 2` was a third parser artefact (**an `LD` entry has no
ESDID of its own**; it carries an LDID naming its section, and their script
counted it in the running ESDID sequence). The real construct is an **`EQU`
alias on an external symbol**, which `mirror/JEXTRN` generates by the dozen:

```
         EXTRN IFNX6C01
ERRMSGS  EQU   IFNX6C01
```

Their fixture, run here against IFOX00 on `MVSCE-LAB` and `as370` at `5f326b4`:

```
RELFIX3  CSECT
         EXTRN EXTA
ALIASA   EQU   EXTA
         USING RELFIX3,15
         L     1,=A(EXTA)
         L     2,=A(ALIASA)
         DC    A(EXTA)
         DC    A(ALIASA)
         LTORG
         END
```

| address | | IFOX00 `R` | `as370` `R` | |
|---|---|--:|--:|---|
| `0x0008` | `DC A(EXTA)` | 2 | 2 | |
| `0x000c` | `DC A(ALIASA)` | **2** | **1** | **wrong** |
| `0x0010` | `=A(EXTA)` | 2 | 2 | |
| `0x0014` | `=A(ALIASA)` | **2** | **1** | **wrong** |

ESD identical on both sides: `1:RELFIX3/SD  2:EXTA/ER`.

**It is not the literal** — both direct forms are right and both alias forms
wrong, in the `DC` and in the literal pool alike. `add_reloc()` finds no
`s->esdid` for the alias and falls through to `sect_esdid_of(s->sect)`, the
CSECT.

**And the binding-error half of the hypothesis stands after all, narrowed to the
alias form**: the linker adds the section origin instead of resolving the
external symbol. That is why the first fixture found nothing — it tested the
constructs cc370 and I both suspected, and the defect is in a construct neither
of us had written down.

The fixture also carries its own control: `EXTA` and `ALIASA` are the same symbol
by definition of `EQU`, so they must relocate identically. A wrong answer is
visible without an oracle at all.

## Operational: `MVSCE-EXP` rejects submitted jobs

Every job submitted to `MVSCE-EXP` (`:8083`) with the MVS/CE credential from `.env` ends
`JCL ERROR` / `IEF722I ... INVALID PASSWORD GIVEN`. **Reads with the same
credential succeed** — `IBMUSER.PVTMAC` was copied off it member by member, 453
of 453, no failures — so mvsMF authenticates the request and the job card is
then rejected by the system.

**The cause is not established.** An earlier version of this section said mvsMF
generates the card with an empty password, citing the JESJCL listing:

```
//RELFIXB  JOB (ACCT),...,NOTIFY=IBMUSER,
//         USER=IBMUSER,PASSWORD=   GENERATED BY MVSMF
```

That reading is wrong: **the password is never shown in the spool**, so a blank
there is the normal masking and not evidence of anything. The correction is
Mike's. What is measured is only the pair of facts above — reads work, submits
are rejected — and the reason is open.

**`tools/ifox_run.py` is hardcoded to `:8083`** and would fail on its first job,
which matters the moment stage 1's corpus run is attempted. `MVSCE-LAB`
(`:8082`) and both TK5 systems submit normally, which is why the fixture above
ran on LAB.

---

## The probe, run on the pinned oracle — 2026-09-12

[`fahrplan.md`](fahrplan.md) stage 1 proposed a cheap first probe before the
corpus run: ten modules — `IFNX1A 1J 3N 5A 5C 5D 5V 6B`, `IFOX0A 0D` — where
`as370` and IFOX00 produce an image-identical module and differ only in the
**`R` field** of the RLD entries. A discrete value, independent of the clock,
which is what makes it a good first question.

It has been run, on `MVSTK5-REF`.

### What had to exist first

The run that died on 2026-09-11 at 10:33 needed three things, and the third is
the one that matters:

1. `IBMUSER.IFOXOB2`, `IBMUSER.IFOXLST`, `IBMUSER.SRCD` allocated
   (`IFOXALO2/JOB00040`, `CC 0000`). The first attempt drew `IEF618I OPERAND
   FIELD DOES NOT TERMINATE IN COMMA OR BLANK` — a continuation line 74
   characters long. JCL operands end before column 72.
2. `IBMUSER.PVTMAC` allocated with **the same DCB as the copy on `MVSCE-EXP`**
   (`FB/80/19040`).
3. **Its 453 members copied from `MVSCE-EXP`, not rebuilt from the local macro
   directories.** Locally `tape` + `mirror` is 444; `MVSCE-EXP` carries 453,
   the extra nine being the EREP macros adopted on 2026-09-09
   ([`erep-adoption.md`](erep-adoption.md)). The authority for what the
   reference decks saw is the library they were assembled against, not a
   reconstruction of it. Round-trip control: 15 of 15 members fetched back and
   hashed byte-identical.

**And the freeze held.** `tools/macrosnap.py` before and after:

```
2332 unchanged
0 CHANGED, 0 gone, 453 new      <- all 453 are IBMUSER.PVTMAC
```

No `SYS1` macro library moved. The oracle took work and stayed frozen, which is
exactly what `systems.json` says the guarantee is.

### The result

Ten modules assembled by TK5's IFOX00, against the decks MVS/CE's IFOX00 cut on
2026-09-07. Same source, same `SYSLIB`, columns 1–72, `END` card excluded.

| | |
|---|---:|
| decks differing on raw bytes | **10 of 10** |
| **differing RLD cards** | **0** |
| **differing ESD cards** | **0** |
| differing TXT cards | 20 |
| differing END cards | 10 |

**Every one of those differences is the assembly timestamp.** The TXT cards
carry `&SYSTIME`/`&SYSDATE` — `05.20 09/07/26` against `23.53 09/11/26` — and
the `END` card carries the Julian day, `6250` against `6254`. Masking date and
time leaves three cards, and all three are the same thing: the date straddles a
card boundary (`09/0` + `7/26`), which the mask could not see.

This family is the worst possible one for a naive byte comparison and the best
one for this question, and both for the same reason: **Assembler XF assembles
itself and stamps its own build time into its own object.** 21 of the 26
stamp-dependent modules in the whole corpus are `IFNX*`/`IFOX*`, which is why
the fahrplan named the `R` field rather than the bytes.

### What it says, and what it does not

**TK5's IFOX00 and MVS/CE's IFOX00 produce the same object code for these ten
modules.** No instruction differs, no ESD entry, no relocation. The 115 USERMODs
against 37 do not show here.

**Ten modules are not an assembler**, exactly as one instruction was not. What
this buys is the right to expect the corpus run to agree rather than to fear it
— and a measured reason to spend the run. The full cut is the next step, and it
now needs only the macro carry-across
([`macro-tk5-vs-ce.md`](macro-tk5-vs-ce.md): TK5's own libraries would move 68
modules), because the work data sets and `PVTMAC` are in place.
