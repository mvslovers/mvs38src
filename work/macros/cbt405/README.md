# `cbt405/` — macros out of the CBT tape, file 405

**Provenance, and it is not established.** These come from a community
collection, not from an IBM distribution library. Nothing here is known to be the
maintenance level MVS 3.8j shipped, and until that is settled a difference in a
module that uses one of them is not attributable.

| Macro | Source | What it was measured to be worth |
|---|---|---|
| `IHANVT` | [CBTTAPE, CBT405, `IHANVT.txt`](https://raw.githubusercontent.com/mainframed/CBTTAPE/0af043012b18a7a645b430db861950abaca02a25/CBT405/CBT.V500.FILE405.PDS/IHANVT.txt) | **partial.** On `IEAVAP00` it takes the diagnostics from 380 to 312; **39 `NVT` symbols stay undefined** — `NVTPAREA` (26 uses), `NVTUCBFN`, `NVTPTAB`, `NVTSENSE`, `NVTMOUNT`, `NVTPRMPT`. It maps a handful of fields by `EQU`, not the table. |

`IHANVT` is called by 33 modules
([`undefined-ops.tsv`](../../measurements/ifox-run/ifox-objections/undefined-ops.tsv)),
and it is not what blocks them: in `IEAVAP00` the dominant undefined symbols are
`RENTRY` (96), `RNVT` (48), `REXIT` (48), `RPARM` (45) — register conventions out
of a further macro we do not have.
