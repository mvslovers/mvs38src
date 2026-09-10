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

## DLIB object distance ([`docs/dlib-distance-tk5-ce.md`](../../../docs/dlib-distance-tk5-ce.md))

| file | contents |
|---|---|
| `dlib-object-distance.tsv` | for 804 divergent + 300 control modules: the DLIB member read from both systems (mvsMF binary) and compared. Columns: kind, module, dlib, tk5_rmid, ce_rmid, len_tk5, len_ce, verdict, ndiff. `verdict`: `identical` / `date-only` (code identical, build date differs) / `content-diff` / `len-diff`. |

Build-date masking: the object embeds its build date as a packed 3-byte IDR
field (`yyddd`) and sometimes a readable `MM/DD/YY` string. Differences confined
to those are code-identical; a code change produces a diff run > 3 bytes or a
length change. The 300 same-RMID control modules show zero genuine code
differences under this rule.

## TK5 PTF / USERMOD inventory ([`docs/tk5-ptfs-and-usermods.md`](../../../docs/tk5-ptfs-and-usermods.md))

| file | contents |
|---|---|
| `tk5-ptf-list.tsv` | all 712 TK5 PTFs: ptf, component, fmid, tk5_applied, tk5_accepted, on_ce, n_modules, modules |
| `tk5-usermod-list.tsv` | all 115 TK5 USERMODs: usermod, component, fmid, tk5_applied, tk5_accepted, on_ce, source, description (from the SMPPTS cover text where still resident) |
