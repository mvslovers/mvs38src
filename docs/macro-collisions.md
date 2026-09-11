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

**Nine of the ten have never been looked at.** The order is defensible for all
of them and measured for one. The three `AMODGEN`/`APVTMACS` collisions are the
ones to open first, and cc370's reason is the right one: that pair sits inside
the oracle's own SYSLIB in that order, so whatever IFOX00 resolved is answerable
**from the recorded decks, with no system involved** — the same route that
settled `IHADVCT`.

It costs one question per member: does any corpus module reference a symbol that
only one of the two copies defines? If yes, the decks say which copy the oracle
read, exactly as `DVCBPSEC` did.

## The rule this earns

An `-I` path with no duplicate members has no order question. This one has ten,
and every one of them is a place where two provenances already disagree. **A
collision is not a tie to be broken, it is a disagreement to be adjudicated** —
and until it is, the order is a guess that happens to be defensible.
