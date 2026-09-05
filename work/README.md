# work

Derived material. Everything here is reproducible from the raw material in
`~/repos/MVSSRC` with the scripts in [`../tools`](../tools) — it is kept because
reproducing it costs minutes and because the measurements have to stay
comparable across days.

| Path | What it is |
|---|---|
| `macinv.txt` | Inventory of all 1,888 `++MAC` elements in `MVSSRC.BLD.SMP.LIB`, with TXLIB, SYSLIB, DISTLIB and the `ASSEM(...)` list — a macro → module map for the whole system |
| `macros/tape/` | 114 private macros out of `MVSSRC.BLD.NEW.ASM`, tape file 3. Provenance: Dave Kreiss' package |
| `macros/mirror/` | 319 private macros from the two web mirrors. **Maintenance level unverified** — good enough to assemble, not good enough for a byte-identity verdict |
| `macros/*.lst`, `*.tsv` | the lists behind those two directories |
| `measurements/` | the as370 runs of 2026-09-05: `sample.txt` is the 150-module sample, `res_A/B/C.txt` the per-module results, `firstcause.txt` the first error per failing module |
| `utility/` | Dave Kreiss' 64 utilities out of `MVSSRC.BLD.UTILITY.ASM`, tape file 5. Reference material — `COMPLMD.asm` is the specification `cmplmd370` has to reproduce. **Read, do not port** |

The write-up that goes with all of it:
[`../docs/private-macros.md`](../docs/private-macros.md).
