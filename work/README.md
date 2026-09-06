# work

Derived material, kept because the measurements have to stay comparable across
days. Most of it reproduces from the raw material in `~/repos/MVSSRC` with the
scripts in [`../tools`](../tools); `macros/mvsce-2.1.4/` does not — that one
comes off a pristine MVS/CE release on `mvsdev`, over the `dasdpdsu` path in
[`../tools/README.md`](../tools/README.md).

| Path | What it is |
|---|---|
| `macinv.txt` | Inventory of all 1,888 `++MAC` elements in `MVSSRC.BLD.SMP.LIB`, with TXLIB, SYSLIB, DISTLIB and the `ASSEM(...)` list — a macro → module map for the whole system |
| `macros/mvsce-2.1.4-dlib/` | **The macro set to use.** The distribution libraries off `smp000.3350`, one directory each. `AHELP` and `ASAMPLIB` are in there for completeness but must stay **out of the assembler's search path** — they are help text and samples, and 14 of their names collide with real macros |
| `macros/mvsce-2.1.4-target/` | The earlier corpus: `SYS1.MACLIB` + `AMODGEN` + `APVTMACS`, a **mix of target and distribution level**. Kept only so the measurements of 2026-09-05 stay reproducible. Do not build on it |
| `macros/tape/` | 114 private macros out of `MVSSRC.BLD.NEW.ASM`, tape file 3. Provenance: Dave Kreiss' package |
| `macros/mirror/` | 319 private macros from the two web mirrors. **Maintenance level unverified** — good enough to assemble, not good enough for a byte-identity verdict |
| `macros/*.lst`, `*.tsv` | the lists behind those two directories |
| `measurements/` | the as370 runs of 2026-09-05: `sample.txt` is the 150-module sample, `res_A/B/C.txt` the per-module results, `firstcause.txt` the first error per failing module |
| `utility/` | Dave Kreiss' 64 utilities out of `MVSSRC.BLD.UTILITY.ASM`, tape file 5. Reference material — `COMPLMD.asm` is the specification `cmplmd370` has to reproduce. **Read, do not port** |

Reproduce the measurement:

```sh
M=work/macros/mvsce-2.1.4-dlib
tools/measure-as370.sh E2 work/measurements/sample.txt /tmp/out \
    -I $M/AMACLIB -I $M/AMODGEN -I $M/AGENLIB -I $M/ATSOMAC \
    -I $M/ATCAMMAC -I $M/APVTMACS \
    -I work/macros/tape -I work/macros/mirror
```

⚠️ In zsh, build that list as an **array** and pass `"${arr[@]}"` if you script
it. An unquoted `$VAR` holding the whole `-I` chain arrives as one argument and
as370 silently assembles with no macro path — which looks exactly like a
catastrophic regression.

The write-up that goes with all of it:
[`../docs/private-macros.md`](../docs/private-macros.md).
