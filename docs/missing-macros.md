# The macros nobody here has

2026-09-07, measured against `as370` at the merge of cc370#174. **40 operations
cannot be resolved by either assembler, and they block 204 module–operation
pairs across the two source trees we build from.** Table:
[`missing-macros.tsv`](../work/measurements/missing-macros/missing-macros.tsv),
one row per operation with the module list.

This is a hunting list. Every one of these was searched for and not found — the
point of the document is that the searching is already done, so what is left is
to find the material somewhere else.

## Where it has been searched

| Searched | Result |
|---|---|
| our eight macro libraries — `AMACLIB` `AMODGEN` `AGENLIB` `ATSOMAC` `ATCAMMAC` `APVTMACS` (566 + 288 + 243 + 100 + 139 + 242) plus Dave Kreiss' tape macros and the web mirrors, 1,822 members | not there |
| the IBM distribution tapes as extracted by the `mvssrc` sessions — 5,927 members, 615 macros | not there, except `ISDAFSPC` |
| `stben.net`'s maclib, 1,024 members; the HASP set, 181; `ext/`, 41 — 1,761 macros in total, searched by name **and** by prototype | not there |
| `mainframe.eu` | a proper subset of `stben`, nothing new |
| Dave Kreiss' own install tape, `NEW.ASM`, 848 members | not there |

Two independent derivations agree on the negative: ours from the module side,
the `mvssrc` sessions' from the manifest side.

## The list, largest first

| Operation | Modules | Where they are | Family |
|---|---:|---|---|
| **`TABLE`** (with `NAME`) | **48** | Kreiss' `NEW.ASM` | `XTB*` translate tables, all with a DLIB object |
| **`DSGEN`** | **31** | `MVSBLD` | EREP internals |
| `PROLOG` | 11 | `MVSBLD` | EREP |
| `LINE` | 11 | `MVSBLD` | EREP |
| `ROUTINE` | 10 | `MVSBLD` | EREP |
| `IQAERB` | 9 | `NEW.ASM` | |
| `IOSTRAP` | 8 | `MVSBLD` | IOS mapping |
| `IOSSIO` | 7 | `MVSBLD` | IOS |
| `IOSSCP` | 6 | `MVSBLD` | IOS |
| `IOSCPA` | 6 | `MVSBLD` | IOS |
| `SUMMARY` | 4 | `MVSBLD` | EREP |
| `IOSCKVOL` | 3 | `MVSBLD` | IOS |
| `DFHPC` `DFHSC` `DFHTC` | 3 each | `MVSBLD` | **CICS — out of scope**, those five modules are excluded |

The rest are single-module entries; the TSV has them all.

## What is worth knowing before searching

**The EREP family is one find, not five.** `DSGEN`, `PROLOG`, `LINE`, `ROUTINE`,
`SUMMARY`, `SPECIAL`, `FREETAB`, `BIN`, `HEX`, `CONVT`, `ENTRIES`, `ETEPILOG`,
`LSTART` all belong to the `IFCE*`/`IFCS*` error-recording programs and are
called by the same modules. Whatever library IBM shipped them in would bring the
whole set.

**`TABLE` is the single largest prize and it is not in `MVSBLD` at all** — the 48
modules that need it are `XTB*` translate tables on Dave Kreiss' install tape,
every one with a DLIB object to verify against. Three of them
(`XTB1GFC`, `XTB1GSC`, `XTB1GUC`) are already recovered because the IBM tape
happens to carry those three in expanded, macro-free form. The other 45 need the
macro.

**Two that were on this list are not any more, and both taught something.**
`IHANVT` and `UCBDADVC` no longer appear: with cc370#174 fixing a 63-character
clamp on operand fields, the modules that seemed to need them get far enough to
resolve them from a library we already had. Any earlier count of this list was
measuring `as370`'s truncated macro expansion, not the program. **A missing-macro
list is only as good as the assembler that produced it.**

**`ISDAFSPC` is on IBM's tape and is empty on purpose** — three cards with IBM's
own APAR marker `@Y30LB55`, a placeholder for a function this edition does not
build. Supplying it removes a diagnostic from 27 modules and changes no byte. It
is the one hit out of everything searched, and it is not worth much.

## What supplying one is worth

Nothing, by itself, unless the module then matches IBM's object. `ISDAFSPC` is
the warning: it resolves the diagnostic for 27 modules and leaves every one of
them exactly as wrong as before. The measurement to make after finding a macro is

```sh
tools/gate.sh /path/to/as370 <label>    # with the macro on the -I path
tools/retest.py obj_<label>
```

and the number that counts is modules reaching byte-identity with the DLIB
object, not modules that stop complaining.
