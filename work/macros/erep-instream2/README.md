# Three more EREP macros, lifted in-stream — 2026-09-09

`LINEND`, `HEX` and `CONVT`, taken from the modules that define their own:

| macro | from | copies in `MVSBLD` | prototype |
|---|---|---:|---|
| `LINEND` | `IFCE0135.ASM` | **118** | `LINEND` (no operands) |
| `HEX` | `IFCE0135.ASM` | **112** | `HEX &LOGITEM,&SKIP$OR,&BYTES` |
| `CONVT` | `IFCEAXXX.ASM` | **24** | `CONVT ,` — SYSLIST-driven, like `DSGEN` |

Controlled: `LINEND` resolves with this directory on the `-I` path and is
`Undefined operation code` without it.

**Not adopted yet.** A macro supplied on the host alone is measured against a
reference assembled without it — `docs/erep-adoption.md` has that measured at
twenty times the scale. These go to the oracle and the host together, or not at
all.

## The missing list is four, not eight

| still missing | |
|---|---|
| `ENTRIES` `ETEPILOG` `FREETAB` `SUMMARY` | no definition anywhere: not in the 5,528 `MVSBLD` members, Jay Moseley's 6,351, `mvs38-ibmsrc`, the web mirrors, any code host, or `mainframe.eu`'s 192 EREP members |
| `PROLOG` | found twice — `IEAVESC0`, `IEAVMWTO` — and **both are the wrong macro**: no operands, where every EREP caller writes `PROLOG NAME=IFCE0115` |

## The scan that found them had to be fixed first, and the bug is embarrassing

My first pass reported **zero** definitions for all seven names. The test was

```python
if l[:80].strip() != "MACRO": continue
```

**Columns 73–80 are the sequence number.** `l[:80]` includes it, so the card reads
`MACRO       00160002` and never matches. `CLAUDE.md` says this in its second
paragraph about these files, and I wrote the parser anyway.

It was caught by the rule rather than by reading the code: a zero result is a
claim about the instrument, so the next run asserted that `DSGEN` is found in
`IFCE0135.ASM` before printing anything. With `l[:72]` the control passes and the
seven names come back 118, 112, 24, and four genuine zeros.

**A negative that agrees with what you expected is the one that gets shipped.** I
expected these to be missing — the previous entry in `missing-macros.md` said so —
and a broken parser told me they were.
