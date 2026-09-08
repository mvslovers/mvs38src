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

## An as370 anomaly found while measuring

With this library alone, `IFCE0115`'s `LINE` calls resolve. **Add
`mvsce-2.1.4-dlib/AMACLIB` and they stop**, 43 of them, although `AMACLIB`
contains no member of that name — verified by search. `DSGEN` and `ROUTINE`,
from the same library, keep resolving.

```sh
as370 -I work/macros/erep-instream                      IFCE0115.ASM   # LINE resolves
as370 -I work/macros/erep-instream -I .../AMACLIB       IFCE0115.ASM   # 43x "- LINE"
```

**A minimal fixture does not reproduce it** — a three-line source calling
`LINE (1,1),(44,1),SKIP=3` is clean with both libraries. Only the real module
shows it, which is why the command above names the module rather than describing
the shape.
