# DLIB object distance: TK5 vs MVS/CE

2026-09-10. Companion to [`smp-tk5-vs-ce.md`](smp-tk5-vs-ce.md). That document
compared the two systems' SMP *records*; this one compares the **object decks
themselves** — for every DLIB module whose SMP RMID differs between TK5 and CE,
are the distribution-library objects actually different, and by how much.

It is the TK5-vs-CE analogue of [`dlib-distance.md`](dlib-distance.md), which
measured Dave Kreiss' assembled source against MVS/CE object code. The base
decision needs both: how far the two candidate oracles sit from each other
(here), and which one Dave's source assembles to (the next probe, below).

## Method

For each module, the distribution-library member is read from **both** systems
over mvsMF in binary mode (`X-IBM-Data-Type: binary`, exact bytes, no
EBCDIC→ASCII, no record framing):

```
GET /zosmf/restfiles/ds/SYS1.<distlib>(<module>)
```

and the two byte strings are compared. The sample is **all 804 modules whose
RMID differs** (from
[`module-versions.tsv`](../work/measurements/smp-inventory/module-versions.tsv))
plus **300 same-RMID modules as a control**. 1,104 modules, 2,208 reads, zero
extraction errors. Raw results:
[`dlib-object-distance.tsv`](../work/measurements/smp-inventory/dlib-object-distance.tsv).

## The hidden parameter: the object carries its build date

A naïve byte comparison is wrong, and the control is what caught it. Same-RMID
modules — which *must* be the same object — came back **not byte-identical**. The
differences are the module's **build date**, embedded in the object in two forms:

- a **packed 3-byte IDR date** in the identification records (`yyddd`);
- occasionally a **readable `MM/DD/YY` string** compiled into the module.

`UTRKCALC` (RMID `M024001`, same on both) shows both: TK5 carries `01/26/84` and
the packed `84.026`; CE carries `07/08/26` and `26.189`. **TK5 preserves the
original 1984 object; CE re-processed the module during its 2026 sysgen**
(`26.189` = 2026-07-08, which is exactly CE's dataset creation date). That is a
real difference between the two systems — CE's DLIB objects were rebuilt, TK5's
were kept — but it is not a code difference, and it must be excluded before any
code comparison means anything.

So the comparison distinguishes three outcomes: **length differs** (a definite
code difference — a date never changes the length); **same length, content
differs beyond the date fields** (code); and **differences confined to date
fields** (code identical). The date fields are isolated runs of ≤3 packed bytes
or a short readable date; a code change produces longer runs.

## Control — same RMID, 300 modules

| | modules |
|---|--:|
| byte-identical | 297 |
| code-identical, differ only in build date | 3 |
| **genuine code difference** | **0** |

**Zero same-RMID modules differ in code.** Same RMID means the same object,
exactly as SMP promises — once the build date is accounted for. The control
passes, so the divergent numbers below can be believed. (The first pass of this
probe flagged `IEFVPP` and `UTRKCALC` as code differences; both are date
artifacts — `IEFVPP` has several packed IDR dates from its USERMOD + base +
assembler identification records, `UTRKCALC` a readable date string. Written down
here because the correction is the point.)

## Divergent — RMID differs, 804 modules

| | modules |
|---|--:|
| object **length differs** (definite code difference) | 727 |
| same length, **content differs** (code) | 73 |
| code identical (RMID differs, build date only) | 4 |

**800 of the 804 are genuine object-code differences.** Where SMP records a
different RMID, the two systems really do carry different object code — 727 of
them differ even in length. Only 4 (`IFG0202K`, `IFG0551B`, `IGC0K05B`,
`IGE0010D`) are the same object under two different SYSMOD ids.

The divergence is not spread evenly. The most affected DLIBs
([full counts in `module-versions.tsv`](../work/measurements/smp-inventory/module-versions.tsv)):

| DLIB | divergent modules | (of total) |
|---|--:|--:|
| AOSD0 (Data Management) | 201 | 650 |
| AOSU0 (Utilities/DSF) | 128 | 470 |
| AOSA0 | 84 | 178 |
| AOS20 | 55 | 115 |
| ACMDLIB (TSO command library) | 48 | 160 |
| AOSC5 (BCP) | 48 | 538 |
| AOST4 (TSO) | 45 | 132 |

## Direction

For the 804 divergent modules, which system carries the maintenance:

| | modules |
|---|--:|
| TK5 at a PTF level, CE still at base FMID | 193 |
| CE at a PTF level, TK5 still at base FMID | **0** |
| both PTFed, to different SYSMOD levels | 611 |

**TK5 is never behind CE in the base-vs-PTF sense** — there is no module where CE
carries a PTF and TK5 is still at base. In 193 modules TK5 is patched where CE is
raw. The 611 both-patched cases go in both directions and cannot be ordered from
the RMID alone; some (e.g. `IKJEHDS1`: TK5 `UZ45029`, CE `UZ54574`) plainly show
CE at a later PTF. So neither deck is a strict superset of the other in content,
even though TK5 is the more heavily serviced overall.

## What this settles, and what it does not

Settled: **the two candidate object oracles are materially different** — 800
modules carry different object code, concentrated in Data Management, Utilities,
the BCP and the TSO libraries. Choosing TK5 vs CE as the baseline is therefore a
real choice, not a formality; whichever is not chosen contributes ~800 modules'
worth of object decks that will not match, plus the PTFs behind them
([`smp-tk5-vs-ce.md`](smp-tk5-vs-ce.md) §"Installability").

Not settled: **which deck Dave Kreiss' source actually assembles to.** Dave's
oracle was TK3 object code, and TK5 is the maintained descendant of that lineage
— but "descendant" is not "identical", and 611 modules are patched to different
levels on TK5 and CE. The definitive test is the same one `cmplmd370` runs: take
a divergent module, assemble it from Dave's source, and compare the object
against the TK5 deck and the CE deck. The deck it hits byte-identical (build date
masked, exactly as here) is the baseline that matches Dave's work.

That probe is the next step and needs the toolchain plus Dave's source staged; it
is scoped but not yet run. This document establishes the ground truth it will be
measured against: for these 800 modules, TK5 ≠ CE at the object level, and the
only thing standing between "same RMID" and "same bytes" is the build date.
