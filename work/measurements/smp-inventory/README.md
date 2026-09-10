# SMP inventory measurement — TK5 vs MVS/CE

Raw and derived data for [`docs/smp-tk5-vs-ce.md`](../../../docs/smp-tk5-vs-ce.md).
Collected 2026-09-10 with `list-smp.jcl` (identical `PGM=HMASMP` LIST job on both
systems, output to a catalogued dataset, fetched via mvsMF restfiles).

| file | contents |
|---|---|
| `list-smp.jcl` | the exact job (HLQ placeholder); `LIST ACDS/CDS SYSMOD .` + `LIST ACDS/CDS MOD .` |
| `tk5-sysmod.tsv`, `ce-sysmod.tsv` | every SYSMOD: zone, id, type, status, fmid |
| `tk5-mod.tsv`, `ce-mod.tsv` | every module: zone, name, distlib, fmid, rmid, umid |
| `fmid-comparison.tsv` | FMID, product name, TK5 status, CE status |
| `ptf-comparison.tsv` | every PTF: applied/accepted on TK5, applied/accepted on CE |
| `usermod-comparison.tsv` | same, for USERMODs |
| `module-versions.tsv` | every DLIB module: distlib, TK5 rmid, CE rmid, state (same / rmid-differs / only-one) |
| `dlib-compare.txt` | per-DLIB module counts: total / at-base / PTFed, TK5 vs CE |

`applied` = target zone (CDS); `accepted` = distribution-library zone (ACDS).
