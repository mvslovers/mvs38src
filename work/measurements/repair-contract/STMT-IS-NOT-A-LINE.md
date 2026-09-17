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
