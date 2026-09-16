# `SYS1.LPALIB`, sorted by mechanism

> ## ⚠️ Stale, and it contradicts itself, 2026-09-16
>
> Item 1 — *"281 modules are counted as failures for a difference that cannot be a
> defect"* — survives a retraction printed eight lines above it, and is refuted by
> [`ds-holes.md`](ds-holes.md). Read the retraction, not the item.

2026-09-12. `LPALIB` is the reddest row on the scoreboard — **290 of 2,343
CSECTs, 12.4 %** — and it is the largest, so it decides the total more than
anything else. This asks what is actually wrong there, rather than how much.

Source: run 6's `ZLMDRPTT` detail, joined against the host-side comparison
([`source-states.md`](source-states.md)), the assembler verdicts in
`module-table.tsv`, and Dave Kreiss' own change markers.

## The top-level answer: nobody has worked on it

Of **2,061** `LPALIB` CSECTs carrying a finding:

| | CSECTs |
|---|---:|
| **carry no `DSK` marker at all** | **1,916 — 93 %** |
| carry one of Dave's markers | 145 |

**`LPALIB` is not a library where repairs failed. It is the library that was
never reached.** His own phase scheme says so — `DSKLxxx` is phase 5, the last
one — and his mail said the same in words. The 12.4 % is what an untouched
library scores.

That also sets the expectation correctly: this is not a debugging problem with a
few root causes, it is a body of work.

## And it is almost entirely ours to do, not the assembler's

| | CSECTs |
|---|---:|
| measurable on the host, source differs | **1,573** |
| source present, no DLIB counterpart to measure against | 402 |
| no source in the `MVSBLD` tree at all | 85 |
| **`as370` disagrees with IFOX00** | **1** |

**One module.** The tool question is settled here; what remains is source.

## Where the 1,573 sit

By distribution library — maintenance arrives per library, so this is the axis
that can be attacked with a SYSMOD rather than module by module:

| DLIB | open | of total in that DLIB |
|---|---:|---:|
| `AOSB3` | **291** | of 361 — **81 %** |
| `AOS21` | 174 | of 472 |
| `AOS24` | 157 | of 239 |
| `AOSA0` | 150 | of 168 — 89 % |
| `AOSC5` | 116 | of 337 |
| `AOSD0` | 99 | of 312 |
| `AOSD8` | 84 | of 108 |

`AOSB3` and `AOSA0` are nearly untouched. `AOSC5` and `AOSD0`, by contrast, are
majority-recovered, which says the difference between them is history rather
than difficulty.

## The cheapest end, and a caution that removes half of it

Of the 1,423 that differ, **1,030 differ in length** and **393 differ in content
at the same length**. Same length and few bytes is the tractable shape:

| bytes differing | CSECTs |
|---|---:|
| 1–4 | **147** |
| 5–16 | 135 |
| 17–64 | 41 |
| 65–256 | 18 |
| > 256 | 52 |

**But 73 of those 147 are already known to be `DS`-hole-only**
(`work/measurements/holesonly.txt`) — the differing bytes are uninitialised
storage, where IBM's object carries whatever was in the buffer. `IEFJDSNA` is
the documented pattern: source correct, tool correct, and the single differing
byte is the `DS` hole at `0x00AA` ([`ifox-oracle.md`](ifox-oracle.md)).

> **Retracted the same day.** This said the hole differences are not defects and
> the scoreboard wrongly counts them as such. They **are** defects — see
> [`ds-holes.md`](ds-holes.md). The hole bytes are byte-identical between TK5 and
> MVS/CE in 309 of 309 sampled clusters, which linkage-editor residue could not
> be, and they carry structured content (`0ATSOMAC`, `OS 218IGFMCH17`). IBM's
> source initialises them and ours does not. **25.9 % is right as it stands**, and
> all 147 of the cheapest candidates below are real work, not 74.

The remaining **74 of the 147** are the genuinely cheapest open work in the
largest library. List: [`../work/measurements/lpalib-smallest.tsv`](../work/measurements/lpalib-smallest.tsv).

## What this says to do

1. **Decide how the `DS`-hole class is reported.** 281 modules are counted as
   failures for a difference that cannot be a defect. Dave's own answer was a
   `difin` naming the byte range; that is the better fit, and it changes a
   headline figure, so it is a decision rather than a tidy-up.
2. **Attack `AOSB3` and `AOSA0` by library, not by module** — 441 open CSECTs
   between them, both over 80 % open, and maintenance arrives per library.
3. **Do not expect the assembler to give anything back here.** One module.
