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
