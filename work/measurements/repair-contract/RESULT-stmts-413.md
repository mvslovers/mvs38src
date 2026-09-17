# cc370 #413 (`#411`) — `as370 --stmts`, gated 2026-09-17

Built here from `git archive d417887` and merged as **`98da84b`**. It closes
`#411`, and with it `cc370#385` becomes a **translator** rather than a listing
scraper.

```
org  cards  loc  len  stmt  gen  mdepth  mcall_stmt  mcall_name  reserves  text
```

## Controls

| | |
|---|---|
| tree-wide, 5,538 modules | `rc0 = 4,699`, 5,538 decks — **identical to the baseline figures** |
| the decks themselves | **0 of 5,538 differ**, and no deck present in one set and not the other |
| CI | green, clang and gcc |

**The export changes no assembly.** That is the null control an added flag needs
and it was run rather than assumed, on both sides.

## Consumption — the half only this side can judge

**The record answers the question a repair asks.** Taken against the one repair
this project made by hand today, `IEFAB486`'s eyecatcher:

```
org=11  cards=1  loc=4   len=1   reserves=1   DC    AL1(24)
org=12  cards=1  loc=5   len=24  reserves=1   DC    C'IEFAB486 79061  UZ25269 '
```

`org` points at the card in the file, character for character. **The morning's hand
repair would have been machine-locatable.**

## 🔑 `reserves` lands inside the bracket the object could only bound

The field `#411` exists for, measured over the 30 control CSECTs and set beside
this session's two object-side attempts from the same day:

```
uncovered bytes over the 30            13,161
  signature A -- explicit DS 0F/0D/0H      89 =  0.7 %
  --stmts reserves=0 -- AUTHORITATIVE     412 =  3.1 %
  signature B -- gap shorter than align  1,788 = 13.6 %
```

This morning the two object-side rules disagreeing twentyfold was written down as
*the* argument that alignment-against-reservation is a **source** fact:
[`DS-AMBIGUITY.md`](DS-AMBIGUITY.md). The source fact is now available, and **it
sits inside the interval the two object methods spanned.**

So the object could not determine it and could bound it, and the bound was right.
That is a better outcome than either being correct would have been: a
disagreement used as evidence, and then checked against the answer.

## What is still open

`org` for a card that arrives through `COPY` — the code comment says a copied
block keeps the `COPY` statement's origin, which would point a consumer at the
`COPY` card rather than the copied one. **The exposure is 24 of the 832 and zero
of the 30**, so the corpus that can be judged cannot exercise it. The stated
defence is that the record's `text` will not match the file line; with 24 modules
that is cheap to verify here, and it is a consumer's obligation rather than
`as370`'s.
