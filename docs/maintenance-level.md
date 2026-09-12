# What maintenance level do TK5's distribution libraries actually carry?

2026-09-12. The goal at the head of the README names **8505**, and until now
nothing in this repository measured it — it was Mike's stated target, carried as
a claim. This measures it.

## Method, and it reads 100 % of the corpus

Every DLIB member is a bound module and carries **IDR records**: subtype `X'01'`
the translator, `X'02'` the linkage editor (`5752SC104` throughout), `X'04'`
`IMASPZAP`, `X'08'` user data written by `IDENTIFY`
([`dlib-distance.md`](dlib-distance.md)). Each carries a **packed-decimal
`yyddd` date**, three bytes with an `f`/`c`/`d` sign nibble.

`IEFAB4M4`, the worked example:

```
470  f5 f2 e2 c3 f1 f0 f4 40 03 07 78 34 9f ...   |52SC104 ...|
                                  ^^^^^^^^  packed 78349 -> 1978, day 349
488  00 01 78 34 9f 0b d9 e2 c9 f5 f0 f2 f7 ...   |...RSI5027...|
              ^^^^^^^^  the same date again
```

Per module the **latest** such date is taken, anchored on the `57nnSC1nn`
translator/linkage-editor identifiers. **Readable on 3,988 of 3,988 members.**
Per-module table: [`../work/measurements/dlib-linkdates-tk5.tsv`](../work/measurements/dlib-linkdates-tk5.tsv).

## The answer

| year | members | |
|---|---:|---|
| 1973 | 2 | |
| **1978** | **1,869** | the base — MVS 3.8 as shipped |
| 1979 | 278 | |
| 1980 | 443 | |
| 1981 | 366 | |
| 1982 | 343 | |
| 1984 | 396 | |
| **1985** | **215** | |
| 1986 | 34 | |
| 1987 | 18 | |
| 1988 | 15 | |
| 1989 | 8 | |
| 1990 | 1 | |

**3,912 of 3,988 — 98.1 % — are 1985 or earlier.** So `8505` is a good
description of this corpus and the goal was not made up. The maintenance stream
does run out in 1985.

## And the 1.9 % that is not, because it is the interesting part

**76 members carry service after 1985**, and they are not spread evenly:

| prefix | members | |
|---|---:|---|
| `IKJ*` | **33** | TSO |
| `IEF*` | 9 | job management |
| `IEC*` | 8 | data management |
| `HMA*` | 6 | SMP itself |
| `IEA*` | 5 | supervisor |
| others | 15 | |

**TSO is 43 % of the tail.** That is the component IBM kept servicing longest,
and it is also — not coincidentally — where this project started: the
`IKJEFT`-family work that opened the whole thing.

These are **not** TK5's USERMODs. [`fahrplan.md`](fahrplan.md) §1 counted four
TK5 modules changed by a USERMOD in the distribution zone, two of them in this
corpus. 76 is a different population: genuine later IBM maintenance.

## What this does to the goal

- **`8505` stands as the description, with a named exception.** It covers 98.1 %
  of the corpus exactly. The README can stop calling it unmeasured.
- **The target is not one level but a level plus a tail.** A source tree that
  reaches 8505 everywhere would still miss 76 modules, 33 of them TSO. Saying
  "maintenance level 8505" and then hitting `IKJEFLGB` at 1988 is a
  contradiction waiting to be found by somebody else, so it is written down here
  first.
- **It is a per-module ordering, which is new.** Until now the 2,899 open modules
  had no priority beyond library membership. The link date sorts them by how much
  maintenance they received, and a 1978 module whose source still differs is a
  different problem from a 1985 one: the first should already match.

### The control that makes that last point worth having

Of the modules that **are** byte-identical, what do their dates look like against
the ones that are not? That comparison is not run here. It is the obvious next
question and it needs one join, not a new instrument.

---

## The control, run: the date predicts recovery, and that is the thesis

The join named above, over the 3,988 modules that have both a link date and a
verdict against TK5's object:

| class | modules | median year | share at 1978 | share ≥ 1984 |
|---|---:|---:|---:|---:|
| **byte-identical** | 1,089 | 1978 | **79 %** | 3 % |
| holes-only | 495 | 1978 | 96 % | 2 % |
| **differs** | 2,404 | **1981** | 22 % | **27 %** |

And by year, the rate at which the source reaches the object:

| year | modules | identical | |
|---|---:|---:|---:|
| **1978** | 1,869 | 857 | **45.9 %** |
| 1979 | 278 | 41 | 14.7 % |
| 1980 | 443 | 32 | 7.2 % |
| 1981 | 366 | 20 | 5.5 % |
| 1982 | 343 | 105 | **30.6 %** |
| 1984 | 396 | 14 | 3.5 % |
| 1985 | 215 | 14 | 6.5 % |

**The source matches where IBM never serviced the module, and fails where it
did.** 45.9 % at the base level against 3.5 % in 1984. That is
[`kreiss-project.md`](kreiss-project.md)'s founding sentence — *"the object
carries maintenance levels the source never received"* — measured for the first
time on a per-module, machine-readable quantity rather than argued from the
documentation.

Two things in the table are not explained and are not smoothed over:

- **1982 breaks the trend**, 30.6 % against 7.2 % the year before and 3.5 % two
  years after. Something about that year's service is different, or that year's
  population is. Unexplained.
- **The holes-only class is 96 % base-level**, more concentrated at 1978 than
  even the identical class. So hole differences are *not* a maintenance
  phenomenon — they sit in modules IBM never touched, which points at something
  systematic in the base source or in how it was transcribed, and is consistent
  with [`ds-holes.md`](ds-holes.md) finding real initialised bytes there.

### What to do with it

This is the first ordering of the 2,404 that is not library membership. A
1978 module whose source still differs cannot be blamed on missing maintenance —
**there is none to miss** — so those are the ones where the source itself, or our
transcription of it, is wrong.

**There are 535 of them**, and they are a different kind of problem from the ones
dated 1979 and later. By distribution library:

| | |
|---|---:|
| `AOS21` | 136 |
| `AOSC5` | 78 |
| `AOSB3` | 76 |
| `AOSD0` | 40 |
| `AOSD8` | 40 |
| `AOSU0` | 20 |
| `AOS24` | 18 |
| `AOS26` | 15 |

List: [`../work/measurements/differs-at-base-level.tsv`](../work/measurements/differs-at-base-level.tsv).
This is where a find like the `^`/`¬` code-page substitution came from — one
mechanism, ten modules at once — and it is the population such a find would live
in, because a transcription defect does not care what year IBM last serviced
the module.
