# work

Derived material, kept because the measurements have to stay comparable across
days. Most of it reproduces from the raw material in `~/repos/MVSSRC` with the
scripts in [`../tools`](../tools); `macros/mvsce-2.1.4/` does not — that one
comes off a pristine MVS/CE release on `mvsdev`, over the `dasdpdsu` path in
[`../tools/README.md`](../tools/README.md).

| Path | What it is |
|---|---|
| `macinv.txt` | Inventory of all 1,888 `++MAC` elements in `MVSSRC.BLD.SMP.LIB`, with TXLIB, SYSLIB, DISTLIB and the `ASSEM(...)` list — a macro → module map for the whole system |
| `macros/mvsce-2.1.4/` | 1,268 macros from a pristine MVS/CE 2.1.4 — `SYS1.MACLIB` + `SYS1.AMODGEN` + `SYS1.APVTMACS`. The baseline of every measurement, and **known to be incomplete**: 79 of the 554 `AMACLIB` elements in `macinv.txt` are not in it |
| `macros/tape/` | 114 private macros out of `MVSSRC.BLD.NEW.ASM`, tape file 3. Provenance: Dave Kreiss' package |
| `macros/mirror/` | 319 private macros from the two web mirrors. **Maintenance level unverified** — good enough to assemble, not good enough for a byte-identity verdict |
| `macros/*.lst`, `*.tsv` | the lists behind those two directories |
| `measurements/` | the as370 runs of 2026-09-05: `sample.txt` is the 150-module sample, `res_A/B/C.txt` the per-module results, `firstcause.txt` the first error per failing module |
| `utility/` | Dave Kreiss' 64 utilities out of `MVSSRC.BLD.UTILITY.ASM`, tape file 5. Reference material — `COMPLMD.asm` is the specification `cmplmd370` has to reproduce. **Read, do not port** |

Reproduce the measurement:

```sh
tools/measure-as370.sh C work/measurements/sample.txt /tmp/out \
    -I work/macros/mvsce-2.1.4 -I work/macros/tape -I work/macros/mirror
```

The write-up that goes with all of it:
[`../docs/private-macros.md`](../docs/private-macros.md).
