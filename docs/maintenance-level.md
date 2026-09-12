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
