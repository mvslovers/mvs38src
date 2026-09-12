# TSO first, SMP second — the two components that matter most

2026-09-12. Mike's priority, and it changes what "the work" means: **TSO is
where he intends to build his own development on top**, so its recovery is worth
more than its share of the module count. SMP is second, and it is the
maintenance vehicle the whole project design rests on.

Both profiled on the same instrument as everything else: the run-7 source state,
one pinned `as370`, against TK5's distribution libraries.

## TSO — `IKJ*` and `IKT*`, 228 modules in the reference corpus

| | modules | |
|---|---:|---:|
| **byte-identical** | **44** | 19.3 % |
| holes-only | 29 | |
| differs | 155 | |
| **`as370` disagrees with IFOX00** | **0** | |

**Not one tool case in 155.** Whatever is wrong in TSO is the source.

### And the shape is unusually favourable at the base level

| link year | open | identical | holes |
|---|---:|---:|---:|
| **1978** | 21 | **36** | 27 |
| 1979 | 17 | 1 | 0 |
| 1980 | 18 | 0 | 1 |
| 1981 | 7 | 1 | 1 |
| 1982 | 10 | 0 | 0 |
| 1984 | 10 | 0 | 0 |
| **1985** | **43** | 2 | 0 |
| 1986–89 | 29 | 4 | 0 |

**At base level TSO is largely recovered** — 36 identical and 27 holes-only
against 21 open. The problem is concentrated where IBM kept servicing it:
**43 open modules at 1985**, and a 29-module tail out to 1989 that is the
longest in the whole corpus ([`maintenance-level.md`](maintenance-level.md)).

By distribution library: `AOST4` 64, `ACMDLIB` 48, `AOST3` 42.

**22 differ at the same length**, which is the tractable shape, and the smallest
are very small: `IKJEFA42` and `IKJEFLLM` at **1 byte**, `IKJEFE16` and
`IKJEFLGH` at 2, `IKJEFL00` at 4.

## SMP — `HMA*`, 109 modules, and a different shape entirely

| | modules | |
|---|---:|---:|
| **byte-identical** | **19** | 17.4 % |
| holes-only | **0** | |
| differs | 90 | |
| **`as370` disagrees with IFOX00** | **0** | |

| link year | open | identical |
|---|---:|---:|
| **1978** | **1** | **11** |
| 1979 | 10 | 2 |
| 1980 | 10 | 0 |
| **1981** | **28** | 2 |
| 1982 | 7 | 0 |
| **1985** | **28** | 4 |
| 1986–87 | 6 | 0 |

**SMP's base level is essentially done** — 11 identical against 1 open at 1978 —
and everything open is maintenance, in two blocks: 1981 (28) and 1985 (28). All
90 sit in one distribution library, `AOS12`.

**And 82 of the 90 differ at the same length.** That is a far better shape than
`LPALIB`, where two thirds differ in length: same size and different content
usually means a patch rather than a rewrite. The smallest are `HMASMTSB` at
2 bytes and `HMASMDC1` at 6.

## Why these two are worth taking before the big libraries

`LPALIB` has 2,343 CSECTs and is 93 % unmarked by Dave — a body of work
([`lpalib.md`](lpalib.md)). TSO and SMP are **337 modules together**, both with
zero tool involvement, both already recovered at base level, and both with their
remaining work concentrated in two or three maintenance years rather than spread
across everything.

| | modules | identical | same-length differences | tool cases |
|---|---:|---:|---:|---:|
| TSO | 228 | 44 | 22 | **0** |
| SMP | 109 | 19 | **82** | **0** |
| `LPALIB` for contrast | 2,343 | 290 | 393 of 1,423 | 1 |

**SMP's 82 same-length differences are the single most tractable block found so
far**, and SMP is the vehicle the project's own design depends on — Dave built
the whole thing around SMP as the maintenance mechanism, and we have just spent
two days discovering that his chain cannot deliver 485 of his own SYSMODs
because of one statement SMP refuses.

## What has not been done

The per-module diagnosis. This says where the work is and what shape it has; it
does not say what any individual difference *is*. The next step on TSO is the
22 same-length cases, smallest first, because a 1-byte difference in a module
nobody has looked at is where a mechanism gets found — that is exactly how the
`^`/`¬` code-page substitution turned up and recovered ten modules at once.
