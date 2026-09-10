# An S-type constant under an absolute USING

The control for cc370#351, and for the rule it corrects. `#108` established that
only a relocatable expression resolves through a USING — measured under a
**relocatable** USING, where `S(0)` really is `0000`. As a general rule it is
wrong: an absolute expression takes its base from an **absolute** USING.

Six forms, so both cases sit side by side. IFOX00 on `MVSCE-LAB`, 2026-09-10:

| form | IFOX00 | before #351 | after |
|---|---|---|---|
| `S(CRCAMCW)` under `USING CRCA,1` | `1008` | `0008` | `1008` |
| `S(LAB)` under `USING STYP,12` | `c000` | `c000` | `c000` |
| `S(0)` under `USING CRCA,1` | `1000` | `0000` | `1000` |
| `S(8)` under `USING CRCA,1` | `1008` | `0008` | `1008` |
| `S(0)` after `DROP 1` | `0000` | `0000` | `0000` |
| `S(LAB)` after `DROP 1` | `c000` | `c000` | `c000` |

The last two are what keeps #108 intact: with no absolute USING in range,
`using_for_abs()` returns 0 and the displacement stays the value. The fix reaches
only the case #108 never measured.

`CRCA EQU 0` / `USING CRCA,1` / `DC X'8300',S(CRCAMCW)` is what PL/S emits for a
DIAGNOSE, which is why `IECVCINT` and `IECVESIO` both carry it.
