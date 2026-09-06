# The tree-wide run

> **Superseded by the second run, 2026-09-06 evening.** After five `as370`
> defects were closed — `START`, `ISEQ`, `DC/DS` type `S`, `&SYSECT`, the
> cross-section duplication factor — and the per-section location counter
> (cc370#136/#137), the whole tree was measured again. **829 modules are
> byte-identical, up from 572, with none lost.** The section below is the first
> run and is kept for the record; the current figures are at the end.


2026-09-06. The whole of Dave Kreiss' source tree against the whole of MVS/CE's
distribution libraries, measured by `cmplmd370`. This is the number the project
has been working towards: not a sample, the population.

## What was run

| | |
|---|---:|
| modules in `MVSBLD/` | 5,528 |
| **assemble cleanly with `as370`** | **4,270 (77 %)** |
| fail to assemble | 1,256 |
| hang (20-second cap) | 2 |
| of those that assemble, have a member of the same name in an `AOS*` library | **3,888** |

The 5,252 distribution-library members were read off `smp000.3350` with
`dasdcat`, one call per member. No member name occurs in two libraries, so the
pairing by name is unambiguous.

## The result

| Verdict | Modules | |
|---|---:|---:|
| length differs | 2,079 | 53.5 % |
| **only generated text differs** | **589** | 15.1 % |
| **identical** | **572** | **14.7 %** |
| mixed (holes and text) | 331 | 8.5 % |
| **only DS holes differ** | **281** | 7.2 % |
| incompletely paired | 20 | 0.5 % |
| no sections | 16 | 0.4 % |

**572 modules assemble byte-identical to the object code MVS/CE ships.** A
further 281 differ only in `DS` holes, which are by construction not source
defects. Together: **853 of 3,888 — 21.9 %.**

## The hole list, and it is verified in both directions

`cmplmd370 --difout` over the 281 gives
[`../work/measurements/holes-all.difin`](../work/measurements/holes-all.difin) —
**1,673 records for 281 modules** in Dave Kreiss' format.

| check | result |
|---|---|
| the 281 with `--difin holes-all.difin` | **281 identical, 0 differing** |
| the 589 text-differers with the same file | **0 identical, 589 still differing** |

The second row is the one that matters. A tolerance file that makes its own cases
pass proves nothing; one that leaves every genuine difference standing is doing
its job. Nothing in those 1,673 records reaches a module it was not written for.

## What the numbers do not say

- **`identical` is a verdict about one section against one member**, under
  `--clearrld`, which zeroes address constants on both sides. It is the right
  comparison for source recovery and it is not a claim that the module would link
  and run identically.
- **The 2,079 length differences are not all source defects.** Our macro corpus
  contains 319 macros from web mirrors whose maintenance level is unestablished;
  a macro one PTF behind generates a different length from correct source. That
  is measured against a known unknown, not against a clean baseline.
- **1,256 modules do not assemble at all** and are outside this measurement
  entirely. They are, on average, the harder ones.
- **Sixteen modules could not be compared** when this was first run. Their
  members carry a record of type `X'10'` directly behind the IDR records, which
  neither `cmplmd370` nor `file370` recognised; both stopped there. Counted
  across all 5,252 members, the first record after the CESD and the IDRs is
  `X'01'` 3,151 times, `X'0D'` 2,079 times and `X'10'` **22** times — almost all
  `ICK*`, plus `ESRTABLE`, `IECTATEN` and `IECTSVC`. **Resolved the same day:**
  `X'10'` is the scatter/translation record, documented in cc370's own
  `docs/load-module-format.md` and never implemented because neither cc370 nor
  as370 ever binds `SCTR` or `OVLY` — the corpus had never contained the input
  that triggers it. With the fix all sixteen produce a verdict: 13 `text`,
  2 `length`, and **`IECTSVC` identical**. So the counts are one better than the
  table above: **573 identical of 3,904 compared.**
- **71 % of the distribution-library members carry an SPZAP record.** Where IBM
  patched shipped object and never changed source, no source assembles to it. How
  many of the 589 that is, is not known — see
  [`accept-status.md`](accept-status.md).

## Where this leaves the project

At the start of the day there was no tool that could pronounce a single module
recovered. There are now **572 that are**, by measurement, plus 281 that are
identical apart from holes named one by one.

The next question is not "how do we compare" any more. It is **what the 2,079
length differences are made of** — and the first thing to rule out is our own
macro provenance, because that is the one variable we introduced ourselves.

## Reproducing

```sh
# 1. the members, on mvsdev, Hercules shut down (about 60 seconds)
for l in $(dasdls smp000.3350 | grep -oE '^SYS1\\.AOS[A-Z0-9]+' | sort -u); do
  n=${l#SYS1.}; mkdir -p $n
  dasdcat -i smp000.3350 "$l/*:?" 2>&1 | grep -a HHC02407I \\
    | cut -d' ' -f2 | cut -d/ -f3 | sort -u > /tmp/mem.$n
  while read m; do
    dasdcat -i smp000.3350 "$l/$m" > $n/$m.dlib 2>/dev/null </dev/null
  done < /tmp/mem.$n
done
```

⚠️ Two traps in that loop, both silent. `dasdcat` writes its member listing to
**stderr**, so `2>/dev/null` throws the listing away and the loop runs zero
times. And `dasdcat` **reads standard input**, so without `</dev/null` it eats
the rest of the member list and exactly one member per library is extracted.

```sh
# 2. assemble, with a per-module cap - two modules hang
perl -e 'alarm 20; exec @ARGV' as370 "${I[@]}" -o allobj/$m.obj "$src/$m.ASM"

# 3. compare
cmplmd370 --json allobj/$m.obj aosall/$lib/$m.dlib
```

The full result, one JSON record per module with every cluster, is in
[`../work/measurements/tree-run.jsonl.gz`](../work/measurements/tree-run.jsonl.gz)
(511 KB compressed, 5.2 MB raw). The module lists are
[`identical.txt`](../work/measurements/identical.txt),
[`holesonly.txt`](../work/measurements/holesonly.txt),
[`asm_ok.txt`](../work/measurements/asm_ok.txt),
[`asm_fail.txt`](../work/measurements/asm_fail.txt) and
[`asm_hang.txt`](../work/measurements/asm_hang.txt).

---

# The second run, after the assembler was fixed

2026-09-06, evening. Same corpus, same method, current tools.

| | first run | **second run** |
|---|---:|---:|
| modules assembling | 4,270 | **4,510** |
| paired against a DLIB member | 3,888 | **4,107** |
| **byte-identical** | 572 | **832** |
| only `DS` holes differ | 281 | **430** |
| **identical or holes-only** | 853 (21.9 %) | **1,259 (30.7 %)** |
| length differs | 2,079 | 2,147 |
| only generated text differs | 589 | 436 |
| mixed | 331 | 231 |

**257 modules gained byte-identity and not one lost it.** That is the acceptance
for the whole assembler campaign, measured on IBM material rather than inferred
from first-cause counts.

The hole list was regenerated and verified in both directions, as before:
**2,660 records for 430 modules**; with it those 430 compare identical, and of
the 436 modules that differ inside generated text, **none** is wrongly masked.

## What the campaign was worth, in one line each

| | modules unlocked | identity gained |
|---|---:|---:|
| `START`, `ISEQ` | 75 | 15 |
| `DC/DS` type `S` | 44 | 1 |
| `&SYSECT` | 39 | — and it corrected 80 decks that were already assembling |
| cross-section duplication factor | 0 | — it changes a return code, not bytes |
| per-section location counter | ~80 | the `IDCCD*` family and more |

The five together took assembling modules from 4,270 to 4,510 and byte-identical
ones from 572 to 829. **The largest single contribution came from a fix that
unlocked nothing** — `&SYSECT` corrected object code that was already being
produced, silently and wrongly, in 80 modules.

## And the base-register tie, cc370#138/#139

| | before | after |
|---|---:|---:|
| byte-identical | 829 | **832** |
| only generated text differs | 436 | 433 |
| length differs | 2,147 | 2,147 |
| lost | — | **0** |

Three modules, and **all three came out of the text-difference bucket while the
length count did not move at all** — which is what a base-register difference
must do: choosing register 11 instead of 10 for the same displacement changes a
byte, never a length.

A small yield for a fix that is free — the byte-identity corpus does not move,
because no C-ecosystem module has two `USING` ranges tied on one address. It is
the silent class again: **both forms are correct programs, so no test finds it.**
It was visible only because the same source was assembled by both assemblers and
the decks compared.

## Where the remaining work is

`2,147` length differences remain the bulk, and the next question about them is
unchanged: **319 of our macros come from web mirrors with an unestablished
maintenance level.** That is still the one variable we introduced ourselves, and
Dave Kreiss' rebuilt install tape is the route to closing it.

The `436` that differ only inside generated text are the recovery work proper —
right length, real differences, no hole excuse.
