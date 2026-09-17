# The `--align-diff` gate — 2026-09-17

The acceptance run for cc370 **#405** (issue #384), and the basis for merging it
as `01ee607`. `RESULT-aligndiff-7cdbfe5.md` is the account.

| file | what it is |
|---|---|
| `RESULT-aligndiff-7cdbfe5.md` | the four controls, the measurement, and the correction this session had to make to its own report |
| `run-832-7cdbfe5.tsv` | the 832-module run on the first gated head |
| `run-832-6eff921.tsv` | the same on the second, after the `SUMMARY` line gained `first=`, `refstmt=`, `candstmt=`, `reflen=`, `candlen=` |

**The pair is a null control, not a duplicate.** Not one of the eleven shared
columns moves on any of the 832 modules between the two heads, so the fields were
added and nothing else changed.

## The result

```
A  refactor 62d460d vs main 210ec3a      868 of 868 runs BYTE-IDENTICAL
B  identity --align-diff X X on the 30   30/30 findings=0, shift set {+0}, first=-
C  agreement with cmplmd370 on the 30    30/30
D  the 832 run                           832/832 SUMMARY, align=ok, none abandoned

382,378 conseq   109,257 const   2,579 ins   6,423 del   1,904 data
120,163 findings  43,486 unchanged   base 158 exact / 347 weak / 327 none
shift set: median 16, max 317, of 8,191 possible deltas
```
