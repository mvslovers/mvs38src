# What the build produced, against what IBM shipped — 2026-09-09

The first run of Dave Kreiss' own verification jobs. `ZLMDRPTD` compares the
DLIBs the build produced against the original DLIBs, `ZLMDRPTT` the targets
against the original targets; both had never run here, because each begins with
two `PGM=SORT` steps and MVS/CE carries no sort product. `tools/lmdreport.py`
does the two sorts on the host in EBCDIC order and submits the rest of Dave's job
unchanged — his program, his control cards, his input.

Reports in `work/build/reports/`.

## The headline, and it is the same in both

| | DLIBs | Targets |
|---|---:|---:|
| CSECTs built | 4,337 | 1,545 |
| **equal to the original** | **2,619 (60.4 %)** | **1,122 (72.6 %)** |
| differ | 1,723 | 405 |
| **of which differ in content at the same length** | **0** | **0** |
| missing LMODs | 599 (8 ignored) | 47 |
| missing CSECTs | 3 | 31 |
| extra CSECTs | 3 | 2 |

**`Compared not equal` is zero on both sides.** Every difference the report found
is a *length* difference. Where a built CSECT is the same size as the one IBM
shipped, it is the same bytes — 2,619 times in the DLIBs and 1,122 in the
targets, without exception.

That is a much sharper statement than "60 % matches". It says the disagreement
is about **how much** is generated, never about **what** is generated at a given
size, and it is the second independent instrument to say so: the `as370`/IFOX00
comparison reaches the same shape from the assembler side.

The length differences, by size:

| | DLIBs | Targets |
|---|---:|---:|
| 1–10 bytes | 391 | 86 |
| 11–100 | 748 | 176 |
| 101–1000 | 503 | 124 |
| over 1000 | 81 | 19 |

**391 CSECTs are within ten bytes of the original.** That is where to look first.

## The 599 missing load modules are not a mystery

Six libraries produced nothing at all — `AOSA0` 178 → 1, `AOSC6` 36 → 0, `AOSD7`
43 → 0, `AOSD8` 116 → 0, `AOSH3` 18 → 0, `AOS20` 115 → 0 — and others are
short: `AOSD0` 649 → 250, `AOSU0` 470 → 373, `AOSC5` 538 → 520.

That is the expected shape of three SYSMODs whose APPLY was terminated
(`EDM1102`, `EBT1102`, `EJE1103`), and it is consistent with the `IEW0123 NO ESD
ENTRIES` and `IEW0143 NO TEXT` the stage-2 link-edit reported. **Consistent is
not established**: nobody has mapped these particular libraries to those FMIDs,
and after two over-broad attributions today that mapping is worth doing properly
before it is asserted.

## What this does not say

It is a **CSECT length and content** comparison of what the build produced
against what IBM shipped, and nothing more. It does not say the built system
would IPL, and it does not distinguish a length difference that comes from the
source from one that comes from the assembler. The `as370` work answers the
second question for the modules it covers; this answers neither on its own.
