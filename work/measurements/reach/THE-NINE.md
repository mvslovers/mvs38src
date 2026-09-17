# The nine low-reach modules of `cc370#383`, read from their sources — 2026-09-17

The cc370 session's traversal reaches **aggregate 71.2 %, median 97.4 %** of the
witnessed code bytes over the 30 control CSECTs, with **nine below 50 %** and six
of those under 4 %. Their reading was *"it is not the root set, it is the
traversal losing the base"*, and they asked this side to read the nine before the
re-specification is written.

**It is four different things, and three of them are not the traversal losing a
base.** Read from the assembly listings of the nine.

## A — the base comes from entry-time `R15` through `LR`, and no `BALR` is needed (3)

```
IGCFR10D  000000  LR R12,R15   then  B A00001A
IKJEGSTA  000000  LR R11,R15   then  L R8,CVTPTR
IECVERPL  000000  LR R10,R15   then  L R12,PSAAOLD-PSA
```

These three have **no `BALR Rn,0` anywhere** — not because the base is lost but
because none is needed. `R15` holds the entry address by MVS convention and the
module copies it. **The traversal's `r15` assumption is already right; what is
missing is propagating a known base through `LR Rx,Ry`.** That is a
one-instruction rule, exact rather than heuristic, and it is worth stating in the
re-specification as a named case rather than left to the `--infer` prologue
scanner, which by construction cannot see it.

Reach today: 0.6 %, 2.4 %, 26.6 %.

## B — `R15`-relative throughout, with several entry stubs at the front (3)

```
ICKTR02   000000  B 42(,R15)   000018 ICKDVSER B 18(,R15)   00001E ICKTRHXD B 12(,R15)
IECVESIO  000000  B @PROLOG    00001E  B @PROLOG
IEAVTCR1  000000  B @PROLOG    000018  B @PROLOG    00001E  B @PROLOG
```

`ICKTR02` is the explicit case and it names the shape: `B 42(,R15)` is a
**D(X,B) written against `R15` with no `USING` at all**, so the module never stops
depending on `R15` being the section origin. A traversal that adopts the prologue
`BALR` base and drops `R15` loses every one of these. The other two carry the same
front-table shape through `@PROLOG`.

`ICKTR02` having four roots and reaching 1.1 % is what makes this group's cause
*not* the root set — the roots are there and land on the stubs; what fails is what
happens after them.

Reach today: 1.1 %, 0.8 %, 2.9 %.

## C — a second base register loaded from storage (1)

```
AMASPZAP  00001A  STM 14,12,12(13)
          00001E  BALR BASREG,0
          000020  L    BASREG2,ACONSTS      <- second base, from a constant
```

The prologue is ordinary and the first base is established normally. The second
base is **loaded from memory**, which no prologue scan can follow and which an
`--infer` candidate would have to record as `pattern` evidence — a question, not
an answer. Reach today: 3.9 %.

## D — textbook PL/S prologue, partial reach, and NOT explained from this side (2)

```
BLSCAMER  000000 B @PROLOG   000016 @PROLOG STM @14,@12,12(@13)   00001A BALR @12,0
HMASMADD  000000 B A000016   000016 STM R14,R12,12(R13)           00001A BALR R12,0
```

Both are exactly the shape of the 21 that reach essentially everything — `B` at 0,
`STM` at `0x16`, `BALR` at `0x1A` — and both get a long way in and stop: **39.5 %
and 49.7 %**. Nothing structural at the front distinguishes them from the modules
that work. **These two are where the trace is needed and this side cannot supply
it**; they are the only two of the nine for which "the traversal loses the base"
is still the live reading rather than a description.

## What this says for the re-specification

- **Groups A, B and C are limits of the stated base assumptions, not defects**,
  and each has a name: a base copied from `R15`, a module addressed through `R15`
  throughout, a base loaded from storage. Naming them is better than a number,
  because a reader of a 2 %-reached module can then be told *which* of the three
  it is.
- **Group D is two modules and it is the one to chase**, precisely because the
  other seven now have explanations.
- None of this argues against the per-module coverage line. It argues that the
  line should carry **why**, not only **how much**.

---

## Follow-up 2026-09-17, after the traversal moved 71.2 % → 81.0 %

Category A landed: `IGCFR10D` 0.6 → 99.6 %, `IKJEGSTA` 2.4 → 99.2 % on `LR Rx,R15`
propagation alone. Category B is intact as the explanation for three of the six
that remain. Two corrections from this side.

### ⚠️ `IECVERPL`'s `X'05A0'` at `0x244` is a REAL `BALR`, not a phantom in a table

The cc370 session reported it as *"inside a table"*, a phantom their pre-scan took
for a prologue. Our witness says `0x244` is **code**, and the listing says why:

```
000244           ERPLESTA DS    0H
000244 05A0               BALR  R10,0
000246 41F0 0246          LA    R15,ERPLESTA-IECVERPL+2
00024A 1BAF               SR    R10,R15
```

It is a **second entry point** — an ESTAE exit — establishing its own base for the
same register the module's front end loads with `LR R10,R15`.

**The fix is right and the reason recorded for it is wrong**, and the corrected
reason is the more useful one. The defect was not a phantom; it was a **pre-scan
adopting a base that belongs to a different entry path and applying it from offset
0**. So `IECVERPL` is not a category A module that the `LR` rule should have
finished — it is a **per-path base** case, which is exactly the limit the cc370
session named for the other three. That is why it moved to 49.5 % and stopped.

Moving base discovery into the walk is still the right change, and the sentence it
earns stands: *a `BALR` that is never reached never sets anything*. But
`IECVERPL` is no longer its evidence; it is evidence for per-path state.

### `BLSCAMER` — category D — carries four `BALR R14,R15` and six real phantoms

```
0000E4  05EF   BALR @14,@15        four external calls
0001C6  05EF   BALR @14,@15
0002F2  05EF   BALR @14,@15
000382  05EF   BALR @14,@15
```

and, in bytes our witness calls **data**, six halfwords that decode as a prologue:
`0x052A 0590`, `0x0536 0590`, `0x0542 0590`, `0x0552 05D0`, `0x0566 05E0`,
`0x0586 05D0`. With base discovery inside the walk those can no longer be adopted,
which is a second reason the change was right.

**The hypothesis worth testing for category D, offered as a case and not a
diagnosis**: `BALR R14,R15` is a **call and falls through** — a traversal that
treats `BALR Rx,Ry` as an unconditional transfer with no fall-through stops at the
first external call. `BLSCAMER` has four of them and reaches 39.5 %. This side
cannot confirm it without the trace.

---

## The branch table behind `BLSCAMER 0001D8`, and what it does to the rule

The cc370 session refuted this side's category D lead — `BALR R14,R15` does not stop
their traversal, everything but `BALR Rn,0` falls through — and found **one cause
for all six**: each stops at an unconditional branch through a register. The
worked case is `BLSCAMER`:

```
0001D8  SLA  9,2(0)
0001DC  L    9,1744(9,12)     indexed load, base @12 = 0x1C
0001E0  BR   9
```

Measured here, because *"the branched-through adcon"* suggests a single constant
and this is not one:

```
table at 0x06EC  (base 0x1C + 1744)   -- DATA per the witness, not code
0x06EC 00000000   0x06F0 000001E2 …   20 words, EVERY ONE RLD-covered,
                                       R = BLSCAMER, length 4
values 0x1E2 ×6, then 0x1EE, 0x1FA, 0x206 -- code addresses beginning at
the byte after the `BR 9` that stopped the walk
```

**So the first and fourth bullets of `cc370#383` are not in tension; the fourth is
the promotion rule for the first.** An RLD target is a label root on its own —
that is bullet 1 and it is right. A register loaded from an RLD-covered location
and then **branched through** promotes those targets to code roots — that is bullet
4. The discriminator is the `BR`, not the adcon.

**And the traversal does not have to resolve the index.** It cannot know which
entry `R9` selects, and it does not need to: what it recognises is that the load's
target region is RLD-covered, and then **every relocated word in that table** is a
code root. That is why the `rld` pass alone fires four times and adds nothing — it
has the targets and lacks the gate.

**The one thing the rule text must then say, and it is not obvious: what delimits
the table.** Here it is 20 contiguous RLD-covered words. *"The maximal run of
RLD-covered words containing the load's target"* is implementable and checkable;
anything vaguer decides `DC A(BUFFER)` cases by accident, which is what bullet 1
exists to prevent.
