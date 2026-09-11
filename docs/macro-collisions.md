# The ten places where `-I` order decides what `as370` assembles

2026-09-11. Found by cc370, reproduced here independently, and the value is that
it is a **list of ten names rather than a standing worry**.

## The measurement

Across the ten directories `gate.sh` passes as `-I`, there are **2,027 distinct
member names**. Exactly **ten** appear in more than one directory, and **all ten
differ** — not one is a harmless duplicate. So path order is not "mostly
cosmetic with one known exception": it decides every collision there is, and
there are ten.

The order was read out of `gate.sh` rather than transcribed, so the winner
column is what the gate actually does:

```
mvsce-2.1.4-dlib/{AMACLIB AMODGEN AGENLIB ATSOMAC ATCAMMAC APVTMACS}
tape  mirror  erep-set  amaclib-live
```

| member | in | wins | is that right? |
|---|---|---|---|
| `IECDIPIB` | AMODGEN, APVTMACS | AMODGEN | **yes** — same order as the oracle's SYSLIB |
| `IECDRQE` | AMODGEN, APVTMACS | AMODGEN | **yes** — same |
| `IEZCOM` | AMODGEN, APVTMACS | AMODGEN | **yes** — same |
| `IHASHDR` | APVTMACS, mirror | APVTMACS | **yes** — APVTMACS is in the oracle's SYSLIB, `mirror` is not |
| `IHASPCT` | APVTMACS, mirror | APVTMACS | **yes** — same |
| `IKJEGSIO` | APVTMACS, mirror | APVTMACS | **yes** — same |
| `IKJOCMTB` | APVTMACS, mirror | APVTMACS | **yes** — same |
| `IEZCTGPL` | mirror, amaclib-live | mirror | **yes** — see below |
| `IHADECB` | mirror, amaclib-live | mirror | **yes** — see below |
| `IHADVCT` | mirror, amaclib-live | mirror | **yes, and it was measured** |

## All ten are adjudicated. None is open.

cc370 closed the remaining nine, and the outcome is better than the table above
predicted: **ten of ten**, not seven-by-construction plus two arguments.

| | members | how it was settled |
|---|---|---|
| **cannot affect any assembly** | `IEZCOM` `IHASHDR` `IKJEGSIO` `IKJOCMTB` `IHADECB` | identical in columns 1–71 |
| | `IHASPCT` `IEZCTGPL` | differ **only inside comment cards** |
| **settled against the recorded decks** | `IECDIPIB` `IECDRQE` | the `DVCBPSEC` route; `as370` agrees with the oracle |
| **mattered, and is closed** | `IHADVCT` | cost `IGC018`; fixed by the path order |

**The two entries this document called "argued rather than measured" are now
measured, and both are the same artefact.** Verified here, not taken on report:

```
IHADECB    905 lines,  0 differing in columns 1-71
IEZCTGPL   287 lines,  1 differing -- line 40, a COMMENT card:
             mirror        *%IF CTGPL999 ^= ','
             amaclib-live  *%IF CTGPL999 ¬= ','      (0xAC)
IHASPCT    132 lines,  1 differing -- line 41, a COMMENT card:
             APVTMACS      *%SPCTPLS1: SPCTDUM=SPCTLEVL <1A><1A>' SPCT';
             mirror        *%SPCTPLS1: SPCTDUM=SPCTLEVL ||' SPCT';
```

Both are PL/S transcription artefacts — the NOT operator and the concatenation
operator, rendered differently by whatever produced each copy — and both sit in
comment cards the assembler never reads. That accounts for them completely.

### How `IECDIPIB` and `IECDRQE` were settled with no system involved

The route that settled `IHADVCT`, applied to the `AMODGEN`/`APVTMACS` pair:

```
IECDIPIB   5 symbols exist only in AMODGEN -- IPIBARG2 IPIBIPIB IPIBPASS
           IPIBPBUV IPIBTIME -- referenced by 3, 1, 1, 3 and 1 corpus modules.
           IFOX00 flags NONE of them undefined, so the oracle read AMODGEN.
           The -I order takes AMODGEN. Agreement, measured.
IECDRQE    RQEK0BYP only in AMODGEN, referenced by 2 modules, never flagged.
           Same conclusion.
```

`RQEPRT6R` exists only in `APVTMACS` and is referenced by nobody, so it cannot
distinguish the two — which is worth stating, because a symbol that no module
references proves nothing either way and it would have been easy to count it.

## Two method notes from closing this, both about instruments that lie

**A parser that matches nothing reports agreement.** cc370's first comparison
parsed labelled `DS`/`DC`/`EQU` cards, and `IHASPCT` came back "0 symbols on both
sides, identical". The regex matched nothing in either file, and nothing equals
nothing. It reads exactly like a clean result. What settled all ten was the blunt
instrument — normalise CRLF, truncate at column 71, strip trailing blanks,
compare bytes — **because it cannot fail to observe**. Five constructions were
nearly filed on the back of a parser that was not looking at anything.

**Comparing symbol names cannot prove two mapping macros equivalent.** An
unlabelled `DS` card shifts every offset after it, so two copies can carry the
same symbols at different displacements. The byte comparison does not have that
hole.

## Why each verdict holds

**The seven involving a `mvsce-2.1.4-dlib` library are settled by construction.**
The oracle's SYSLIB is `SYS1.AMACLIB`, `AMODGEN`, `AGENLIB`, `ATSOMAC`,
`ATCAMMAC`, `APVTMACS`, `IBMUSER.PVTMAC`, in that order. The gate's `-I` list
opens with the same six in the same order, so wherever both sides of a collision
are libraries the oracle had, the gate resolves it the way the oracle did. For
the four where the other side is `mirror`, `mirror` is a local collection that
was never in the oracle's SYSLIB at all — it cannot be the right winner.

**The three involving `amaclib-live` are the ones that were paid for.**
`IHADVCT` cost `IGC018` its identity when `amaclib-live` was put first, and the
reference deck adjudicated it: IFOX00 emitted `48F0 9012` and flagged `DVCMODU`
and `DVCUFIX1` but not `DVCBPSEC`, a profile only the 203-line `@ZA40405` copy
has. `mirror` has it, `amaclib-live` does not. See `missing-macros.md`.

`IEZCTGPL` and `IHADECB` have not been adjudicated from the decks the way
`IHADVCT` was. They win from `mirror` on the same reasoning, which is an argument
and not a measurement — `IHADECB` differs from `mirror` only in columns 73-80,
so it cannot change an object; `IEZCTGPL` carries a stray `X'AC'` and LF line
endings in the `amaclib-live` copy, which is an extraction defect rather than a
maintenance level.

## What is not settled

Nothing, on this question. The `-I` order arbitrates ten names, seven of them
cannot reach an object at all, two are measured to agree with the oracle, and
the one that ever mattered is fixed.

## The rule this earns

An `-I` path with no duplicate members has no order question. This one has ten,
and every one of them is a place where two provenances already disagree. **A
collision is not a tie to be broken, it is a disagreement to be adjudicated** —
and until it is, the order is a guess that happens to be defensible.
