# What the build produced, against what IBM shipped — 2026-09-09

The first run of Dave Kreiss' own verification jobs. `ZLMDRPTD` compares the
DLIBs the build produced against the original DLIBs, `ZLMDRPTT` the targets
against the original targets; both had never run here, because each begins with
two `PGM=SORT` steps and MVS/CE carries no sort product. `tools/lmdreport.py`
does the two sorts on the host in EBCDIC order and submits the rest of Dave's job
unchanged — his program, his control cards, his input.

Reports in `work/build/reports/`.

## Corrected: the SUMMARY page undercounts, and my first reading of it was wrong

**What I wrote here first — that every difference is a length difference, and
that a built CSECT of the same size as IBM's is the same bytes — is false.** It
came from reading the `SUMMARY` page's `Compared not equal   0` at face value.
The detailed `ERRORS` report says otherwise, and it is the authority:

| verdict, per CSECT | DLIBs | Targets |
|---|---:|---:|
| `Length difference (n)` | 1,723 | 405 |
| **`CSECTs don't match (n)`** — same length, different content | **1,497** | **468** |

One line settles it:

```
AOSBN   ICHRIN00  ICHRIN00  0000A8  │  AOSBN  ICHRIN00  ICHRIN00  0000A8  │ CSECTs don't match (115)
```

Identical length `0000A8`, and **115 bytes differ**. Across the DLIBs those
mismatches run from 1 byte to 985.

So `Compared not equal   0` on the summary page is not a statement that no
same-length CSECT differs; it counts something narrower, and the two pages do not
reconcile. **The per-CSECT report is what to quote.** I published the flattering
reading for about ten minutes; it is corrected here rather than quietly edited,
because "no exceptions" was exactly the kind of claim that should have sent me to
the detail before it was written down.

## What the comparison actually says

| | DLIBs | Targets |
|---|---:|---:|
| CSECTs built | 4,337 | 1,545 |
| equal to the original | 2,619 (60.4 %) | 1,122 (72.6 %) |
| differ in **length** | 1,723 | 405 |
| differ in **content at the same length** | 1,497 | 468 |
| missing LMODs | 599 (8 ignored) | 47 |
| missing CSECTs | 3 | 31 |
| extra CSECTs | 3 | 2 |

The length differences by size, and this part stands:

| | DLIBs | Targets |
|---|---:|---:|
| 1–10 bytes | **391** | **86** |
| 11–100 | 748 | 176 |
| 101–1000 | 503 | 124 |
| over 1000 | 81 | 19 |

**391 CSECTs are within ten bytes of the original**, and that is still where to
look first — but beside them sit 1,497 that are exactly the right size and wrong
inside, which is a different and probably harder class.

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
