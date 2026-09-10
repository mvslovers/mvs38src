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

## Why the last four are probably not findable as macro members

Dave Kreiss' own SMP `++MAC` declaration catalog — `work/macinv.txt`, 1,927 lines
and **3,163 declared elements** — contains **none** of `ENTRIES`, `ETEPILOG`,
`FREETAB`, `SUMMARY`, `PROLOG`. Not as text, and not even as a bare declaration.

That last part is the evidence. `BTMHJN` and `BTMIOBWA` **are** in that catalog,
declared with empty bodies — the "2,329 declared, 27 carry text" shape recorded in
[`missing-macros.md`](../../docs/missing-macros.md). So a macro that was ever a
catalogued `SYS1.MACLIB` element on Dave's system leaves a stub there even when
its text does not travel. **These five leave nothing at all.**

Together with `EER1400` shipping no AMACLIB, that is two independent reasons to
stop looking for them as library members and look inside EREP source instead.

## Where they are not, checked with a control each time

| searched | control that proves the method worked | result |
|---|---|---|
| `EREPSY.F01`, `SYM104.F06`–`F09` — the raw, unsplit tape dumps Dave was diffing in 2010 | `LINEND` `CONVT` `HEX` found repeatedly in the same files | the five: **zero** |
| `tk4-source.zip`'s 254 `MVSSRC.*` libraries, via the 7,207-row member catalog | `IECPDSCB` correctly *absent* — it is mirror-only and never was on those volumes | `BTMHJN` `BTMIOBWA`: absent |
| `mvsce-2.1.4-dlib` (8 libraries) and `-target` | — | no `ABTAMMAC` subdirectory exists at all |

**`IFCMACS` is not a library and never was.** Its PDS member is named `IFCMACS`
and the macro inside calls itself **`SYSRELN`**, with the same operand shape as
`HEX`. One macro, out of Dave's `BLDMVS.AWS` as an SMP usermod — the same family
as the `IOS*` set, not from the SYM or EREPSYM tapes. It carries none of the
remaining names, and the lead that it might was worth closing.
