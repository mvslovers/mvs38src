# The six members `mvsce-2.1.4-dlib/AMACLIB` is short of

2026-09-10. The local copy of `SYS1.AMACLIB` has 566 members; the live library on
`MVSCE-LAB` has 572. These are the six, read from the live library.

```
BTMHJN  BTMIOBWA  IECPDSCB  IEZCTGPL  IHADECB  IHADVCT
```

They were added because `gate.sh` had `mirror` copies for three of them and
nothing at all for the other three, so `as370` and the oracle were being given
different macro input -- the one asymmetry `gate.sh`'s own comment warns about,
carried since 2026-09-07.

## They go LAST on the `-I` path, not first

This file first argued the opposite: that `SYS1.AMACLIB` is the first library in
the oracle's `SYSLIB`, so its copies should win the search. **The premise is
true and the conclusion was wrong**, and the reference decks are what say so.

`IGC018` codes `LH R0,DVCBPSEC`. IFOX00 emitted `48F0 9012` for it, and its own
diagnostics for that assembly -- `work/measurements/ifox-run/diag/IGC018.txt` --
flag `DVCMODU` and `DVCUFIX1` undefined while saying nothing about `DVCBPSEC`.
Only one macro level has that profile:

| copy | lines | DVCBPSEC | DVCMODU | DVCUFIX1 |
|---|---|---|---|---|
| `amaclib-live/IHADVCT` (live `SYS1.AMACLIB`) | 196 | -- | -- | -- |
| `mirror/IHADVCT` | 203 | yes | -- | -- |
| `mvsce-2.1.4-dlib/AMODGEN/IHADVCT2` | 88 | yes | yes | yes |

The oracle saw the 203-line copy. Putting the live one first gave `as370` the
196-line one, it reported `DVCBPSEC` undefined -- correctly, on the input it was
given -- and `IGC018` lost its identity. Measured at one binary: **identical
with `amaclib-live` last, DIFFER with it first**, 7 bytes in 3 clusters.

Three of the six exist nowhere else on the path and resolve out of this
directory whatever the order. The other three collide, and letting path order
arbitrate in `mirror`'s favour is what reproduces the oracle.

## The open question, stated rather than answered

Why the live library cannot produce the oracle's own recorded behaviour is
**not settled**. What has been ruled out:

* **The SYSLIB was not different.** `git show` of `tools/ifox_run.py` at its
  2026-09-07 state has the same seven libraries in the same order.
* **No other library supplied it.** `IHADVCT` was fetched from all seven on
  `MVSCE-LAB`: it exists only in `SYS1.AMACLIB`, at the 196-line level.
* **The read was not truncated.** The difference is three interleaved hunks
  carrying `@ZA40405` in the change field, not a missing tail -- a genuine
  maintenance level, faithfully read. `PM-2026-003` made truncation a live
  hypothesis; the diff shape closes it.

What is left is that `MVSCE-LAB`'s `SYS1.AMACLIB(IHADVCT)` **is no longer in the
state that produced the reference corpus on 2026-09-07**. That matters beyond
this member: re-running the oracle on `MVSCE-LAB` today would not reproduce the
corpus it holds. It is one more reason the reference is moving to `MVSTK5-REF`.

## Two extraction defects in this directory

Deck-invisible today, both worth knowing before the next puller runs:

* **`IEZCTGPL` carries one `X'AC'`** where `mirror` has `^` -- the PL/S `NOT`
  operator, in a comment line. It makes the file `ISO-8859` rather than ASCII,
  and `cut`/`grep` abort on it with *illegal byte sequence*.
* **Line endings are LF, not CRLF.** 23,166 bytes against `mirror`'s 23,452 --
  exactly 286 missing `CR`, one per line.

`IHADECB` differs from `mirror` only in columns 73-80. `BTMHJN`, `BTMIOBWA` and
`IECPDSCB` have no counterpart to differ from.

See [`../../../docs/missing-macros.md`](../../../docs/missing-macros.md) -- the
same six are what four agents spent a day hunting for in September, and they were
in `SYS1.AMACLIB` on our own systems the whole time.
