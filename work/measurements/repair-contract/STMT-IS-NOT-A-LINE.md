# A listing statement number does not locate a card — 2026-09-17

`cc370#411` proposes one record per generated statement, with `stmt` as *"the
listing statement number, the same one `--usings` already carries as `seq`"*.

**A repair is an edit to a card in a file.** So the field a repair loop needs is
the one that finds that card, and this measures whether `stmt` does.

## It does not, for 88 % of cards

Over the 30 control CSECTs, every **open-code** listing row, comparing the card
the listing prints against the file line at that number:

```
30 modules      4 where stmt == file line everywhere
55,613 open-code cards      48,828 at a DIFFERENT file line   88 %
```

The four that agree are `IGCFR10D`, `BLSRCOPY`, `IGG08113` and `ICKTR02`.

**The cause is continuation.** A continued statement occupies several file lines
and carries **one** statement number, so every continuation puts the two counters
further apart. `IEFAB493` diverges at statement **2**:

```
file line 1   TITLE 'IEFAB493 - VOL.MT. && VE…      <- continued
file line 2        '                                <- its continuation
file line 3   IEFAB493 CSECT ,
listing       stmt 2 = IEFAB493 CSECT ,
```

One statement, two file lines, and from there the offset only grows. `COPY` does
the same thing in the other direction.

## What the record needs

**A file line, and for a continued statement a line RANGE** — `line` and `lines`,
or `line_from`/`line_to`. `stmt` is still wanted, because it is what the listing
prints and what a human reads, but it cannot be the thing a tool edits by.

And the file the line is *in*: with `COPY`, the card a repair must edit is not in
the module's own `.ASM` at all. If `--stmts` can say which file each card came
from, that is the difference between a repair loop that works on `COPY`-using
modules and one that silently edits the wrong file.

## What this does not touch

`mcall_stmt` is right, and the cc370 session's reading of it is confirmed here:
of `IEFAB493`'s 13 generated cards, **one** has text that appears anywhere in the
module's source, and that one is the coincidence `LR 1,13`. The model card is not
in the caller's file, so **the call site is the card a repair edits** — carrying
`text` as the generated card and `mcall_stmt` as the call gives both, and that
pairing is the right way round.

---

## `org` already exists, and the `COPY` exposure is smaller than the headline

The cc370 session answered the line question with a field that was already there:
`line_org[]`, exported as `org`, locates **61,202 of 61,252** open-code cards
(99.9 %) against `stmt`'s 461 (0.8 %). The 50 it "misses" are continued statements
where `org` correctly points at the **first** card and the comparison was against
the joined text. **So the line is solved and only the range is new work.**

### The `COPY` count needs splitting, and the split is the point

They sized it at **583 files, 933 statements**. Measured here:

```
module sources (5,538)   strict: 348 files,  557 statements
                         loose:  467 files,  703 statements
macro libraries (2,038)          183 files,  382 statements
module sources + macro libraries 531 files,  939 statements
```

**939 against their 933 — so their figure is the two together.** That matters,
because **a `COPY` inside a macro library is not a card a repair edits.** A repair
edits the module's source. The exposure for the contract is the first row: 348
files of 5,538.

### And for the population a repair loop will actually work on, it is 24 modules

```
the 832 (--align-diff)    24 use COPY     2.9 %
the 30 (control)           0              0.0 %
macroattr's 1,042        103              9.9 %
```

**Zero of the 30**, so the corpus that can be judged cannot exercise this at all —
the same asymmetry as the reachability harm. 24 of 832 is small and it is exactly
the set where a consumer editing at `org` would edit the `COPY` card instead of the
copied one. Their proposed defence — **the record's text will not match the file
line, so check it** — is the right shape, and with 24 modules it is cheap to verify
module by module once `--stmts` exists.
