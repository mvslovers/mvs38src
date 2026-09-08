# `erep-instream/` — the EREP macros, lifted out of the modules that carry them

**Measured, not adopted.** These five are genuine and they land, and supplying
them recovers nothing. Kept as the record of that measurement.

`DSGEN`, `LINE`, `ROUTINE` come out of `MVSBLD/IFCE0135.ASM`; `SPECIAL` and `SUM`
out of `IFCEOAK1.ASM`. Both modules define their own macros in-stream, which is
the whole finding: the EREP family splits into modules that carry their macros
and modules that expect them, and `docs/missing-macros.md`'s list is the second
half. Jay Moseley's `MVSSRC.EREPSYM` carries `DSGEN` in 144 members and `LINE` in
145 — same story, more copies.

## What supplying them does

Against `d81edda`, on the 31 modules that need `DSGEN`:

| | |
|---|---:|
| diagnostics, total | 5,980 -> **5,011** |
| `Undefined operation code - DSGEN` | 611 -> **0** |
| `- ROUTINE` | 398 -> **0** |
| `- BIN` | 531 -> **688** |
| `- LINE` | 611 -> **622** |
| `- HEX` | 160 -> **165** |
| decks changed | **33** |
| **closer to IBM's shipped object** | **0** |
| further from it | 0 |

**Two macros land and expose the need for three more.** `DSGEN`'s body calls
`BIN`, `HEX` and `LINE`, so resolving it produces *more* diagnostics for those —
the macro gap is a cascade, and the count of blocked modules understates it.

**Nothing moves toward IBM's object.** All 33 keep the verdict they had —
`length` or `unpaired`. This is `ISDAFSPC` again: a macro is usable when its
expansion is right, not when the assembly falls silent.

**And they must not go on the gate path.** IFOX00's reference decks were produced
without these macros, so `as370` with them is being compared against an IFOX00
without them: all 33 move *away* from IFOX00 by construction, 32 further and 1
closer. A macro can only be adopted on both sides at once — see
`docs/ifox-objections.md`.

## An anomaly I reported and then had to withdraw

I reported to cc370 that `IFCE0115`'s `LINE` calls resolve with this library alone
and stop resolving the moment `AMACLIB` is added. **It is not true.** Re-measured
with real argument vectors:

| configuration | `DSGEN` | `LINE` | `ROUTINE` |
|---|---:|---:|---:|
| this library alone | **0** | **0** | **0** |
| this library + `AMACLIB` | **0** | **0** | **0** |
| the eight gate libraries | 11 | 52 | 3 |
| the eight + this one | **0** | **0** | **0** |

`AMACLIB` makes no difference in either direction; the macros resolve wherever
this library is on the path.

**The false result came from a shell trap that is written down in my own notes.**
The ladder that "found" `AMACLIB` accumulated its flags in a variable —

```sh
ACC="$ACC -I $M/$d"
as370 $ACC ...        # zsh does not word-split: one argument, not two
```

zsh passes `$ACC` as a **single** argument, so no `-I` ever took effect and every
rung of the ladder measured the same thing. Worse, cc370#104 records that an
unrecognised option is silently taken as the source filename, so there was no
error to notice. The figures in this file's table above were taken from direct
command lines and from `gate.sh`, both of which pass a real argv, and they stand.

**Measuring a difference requires that the two runs differ.** A ladder whose
rungs are identical produces a clean-looking trend and means nothing.
