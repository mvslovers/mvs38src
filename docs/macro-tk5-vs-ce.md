# The macro libraries: TK5 against MVS/CE

2026-09-10. The control that has to pass before anything is read into a deck
difference between the two systems — [`fahrplan.md`](fahrplan.md) stage 1. A deck
difference is an *assembler* difference only if both sides expanded the same
macros, and the two systems had never been compared at the macro level at all.

2,326 members over seven libraries, read from both systems by `tools/dlibpull.py`
in binary mode, compared byte for byte.

## Columns 73–80 are not source, and the raw number is a trap

Compared raw, **242 of 242 `APVTMACS` members differ** — and most of them at
identical length. That is not maintenance:

```
TK5  '         MACRO                                                          10000000'
CE   '         MACRO                                                                  '
```

TK5's macro members carry sequence numbers, MVS/CE's do not. The assembler
ignores columns 73–80 entirely, so those are not differences it can see.
`IHADECB` is the same trap one digit wide: 904 differing bytes, all of them
column 80.

Every figure below masks columns 73–80. **The raw count is 358 and means
nothing; the real one is 158.**

## Result

| library | common | identical | differ | only on TK5 |
|---|--:|--:|--:|--:|
| `AMACLIB` | 572 | 553 | 19 | 0 |
| `AMODGEN` | 288 | 274 | 14 | 0 |
| `AGENLIB` | 243 | 205 | 38 | 1 (`OLDCARD`) |
| `ATSOMAC` | 100 | 87 | 13 | 0 |
| `ATCAMMAC` | 139 | **139** | **0** | 0 |
| `APVTMACS` | 242 | 197 | 45 | 0 |
| `MACLIB` | 742 | 713 | 29 | 5 |
| **total** | **2,326** | **2,168** | **158** | 6 |

**93.2 % identical.** `ATCAMMAC` — the TCAM macros — is identical member for
member, which is a useful shape: whatever moved the other libraries did not touch
that one at all.

The five `MACLIB` members TK5 has and MVS/CE has not are `BTMHJN`, `BTMIOBWA`,
`IECPDSCB`, `IEZCTGPL`, `IHADECB` — four of them macros this project spent a day
hunting for in September ([`missing-macros.md`](missing-macros.md)).

## What the 158 are, and what still has to be established

Not all of them are maintenance. **`AGENLIB` is the sysgen library**, and 30 of
its 38 are `SG*` members — stage-1 sysgen macros that encode a system's own
device configuration. Two differently-configured systems *must* differ there, and
it says nothing about maintenance level. `APVTMACS`'s 45 are mostly `IRA*` (SRM
control blocks) and `IHA*` (system control blocks); those are not configuration
and are the interesting half.

**This does not yet clear stage 1.** What it establishes is the size and shape of
the confound: on 93 % of the macro surface there is none, `ATCAMMAC` is clean
throughout, and the residue is concentrated and named. The remaining step is to
check whether any of the 158 is reached by a module in the corpus — the same
distinction [`missing-macros.md`](missing-macros.md) turns on, and one a source
scan cannot answer, because a macro invoked from inside another macro appears on
no module's card. cc370 established that the hard way on 2026-09-10 with a
control (`IDACB2`, certainly used, counted 0).

Raw member bytes are cached under `work/measurements/macro-bytes/` and are not in
git.
