# Which system's object code does Dave Kreiss' source assemble to?

2026-09-10. The probe [`dlib-distance-tk5-ce.md`](dlib-distance-tk5-ce.md)
scoped and did not run: it established that TK5 and MVS/CE carry materially
different object code (800 modules), and left open **which of the two Dave
Kreiss' source actually hits**. That is the question the baseline decision turns
on, and this document answers it.

## What was asked for, and what is measured instead

The ask was to run `ZLMDRPTD` against TK5, the way it was run against MVS/CE on
2026-09-09 ([`build-vs-original.md`](build-vs-original.md)). **That is not
possible yet, and the reason is worth stating rather than working around.**
`ZLMDRPTD` compares the *build output* against the *original DLIBs* — both must
live on the same system, and no build has run on `MVSTK5-BLD`. Running it there
is a Fahrplan item, not a measurement that can be taken today.

So: same question, different instrument, and the instrument is applied to
**both** systems so the two columns are comparable to each other.

| | `ZLMDRPTD`, 2026-09-09 | this |
|---|---|---|
| left side | the build's load modules | our IFOX00 object decks |
| right side | MVS/CE `SYS1.A*` | TK5 **and** MVS/CE `SYS1.A*` |
| unit | CSECT | CSECT, aggregated per module |
| comparator | Dave's `LMDRPT38` | `cmplmd370` |

**The CE column here will not be 60.4 %.** That figure counts CSECTs of the
build output; this counts modules whose source assembles to the shipped object.
Different left-hand side, different unit, different masking rule. Neither
number is wrong and they do not reconcile — they answer different questions.

## Prediction, written before the counts

Recorded first because a prediction adjusted after the fact is not one.

Dave Kreiss verified his reconstruction against **TK3**. TK5 is the maintained
descendant of that lineage; MVS/CE is an independent 2026 sysgen. Two readings
follow, and they point opposite ways:

- **TK5 should win.** Same lineage as Dave's oracle. Where TK3 already carried a
  PTF, Dave's source carries it too, and TK5 inherited it.
- **MVS/CE should win.** `foo` measured that TK5 carries a PTF where CE is at
  base FMID in 193 modules and *never* the reverse. If Dave's source is closer to
  IBM's base level, the less-serviced system is the better match.

**The prediction is TK5, on the divergent modules** — the lineage argument beats
the base-level one, because the project's own thesis is that Dave spent his work
adding *object-level maintenance* back into source that lacked it. A source at
base level is the thing he was correcting away from.

Where the two systems carry the **same** RMID the prediction is not a
prediction but a requirement: the verdicts must be identical, module for module.
That is the harness control.

## Method

For every module with (a) a clean IFOX00 assembly of Dave's source, (b) a
distribution-library member of that name on both systems:

```
cmplmd370 <ifox deck>.obj  work/measurements/dlib-bytes/tk5/<dlib>/<mod>.bin
cmplmd370 <ifox deck>.obj  work/measurements/dlib-bytes/ce/<dlib>/<mod>.bin
```

Same deck, same comparator, same options; only the system varies. Members are
pulled by `tools/dlibpull.py` — one reader, one header set, both systems,
`X-IBM-Data-Type: binary`. The comparison is `tools/deckvsdlib.py`.

Build dates need no masking here, unlike in `foo`'s raw byte comparison:
`cmplmd370` compares CSECT **text**, and a load module's IDR date sits in its
identification records, which are not text. A date compiled into a module as a
constant is still visible — and shows up on *both* sides at once, so it cannot
favour either column.

### Controls

1. **The comparator reproduces its known answers.** Over the 102 committed
   fixture pairs in `work/fixtures/dlib-102/`: 18 identical, 84 differing, 0
   errors — exactly the figures in [`dlib-distance.md`](dlib-distance.md).
2. **The CE side is untouched by four build runs.** 20 members read from
   `MVSCE-LAB` (:8082) and `MVSCE-EXP` (:8083) — which has never run a build —
   are byte-identical on all 20. 18 of the 20 also match the offline extract from
   a pristine MVS/CE 2.1.4 image; the two that differ do so at identical length,
   which is the build date, exactly as `foo` described.
3. **Same RMID must give the same verdict** on both sides. Any disagreement is a
   harness defect or a date-in-text module, and is investigated, not averaged
   away.
4. **`MVSTK5-REF` is read-only throughout.** Nothing is written to it. That is
   also why this runs against the local TK5 rather than against `drnmig3a`,
   which is a third party's machine and answers 401.

## Endpoints

| system | mvsMF | Hercules console | credentials |
|---|---|---|---|
| `MVSCE-LAB` | `mvsdev.lan:8082` | — | `IBMUSER`/`SYS1` |
| `MVSCE-EXP` | `mvsdev.lan:8083` | — | `IBMUSER`/`SYS1` |
| `MVSTK5-REF` | `mvsdev.lan:8084` | `mvsdev.lan:8484` | `HERC01`/`CUL8TR` |
| `MVSTK5-BLD` | `mvsdev.lan:8085` | `mvsdev.lan:8585` | `HERC01`/`CUL8TR` |

## Results

3,988 modules: every one with a clean IFOX00 assembly of Dave Kreiss' source and
a distribution-library member of that name on **both** systems. 7,976 member
reads, none absent, none in error. Raw rows:
[`deck-vs-tk5-ce.tsv`](../work/measurements/smp-inventory/deck-vs-tk5-ce.tsv).

### Control — same RMID must give the same verdict

| | modules |
|---|--:|
| same RMID on both systems | 3,473 |
| verdicts agree | **3,473** |
| verdicts disagree | **0** |

Not one disagreement in 3,473. Where SMP says the object is the same, the
comparator says so too, on both sides, without any date masking. The harness is
measuring the systems and not itself.

### The headline, and it is a small number

| Dave's source assembles byte-identical to… | modules | of 3,988 |
|---|--:|--:|
| **TK5's object** | **1,084** | 27.2 % |
| **MVS/CE's object** | **1,094** | 27.4 % |

**Ten modules apart in 3,988.** Whatever else the baseline decision rests on, it
is not this: 3,473 of the 3,988 carry the same object on both systems, so 87 % of
the corpus cannot distinguish them even in principle.

### Where they can differ — the 515 divergent modules

| | modules |
|---|--:|
| hits **TK5** only | 22 |
| hits **MVS/CE** only | 32 |
| hits both | 2 |
| hits **neither** | **459** |

Read at face value that says MVS/CE, 32 to 22, and **the prediction above was
TK5**. But the face value is the wrong grouping, and separating the modules by
what SMP says about them reverses it.

### Stratified by maintenance level — this is the finding

Of the 515, MVS/CE sits at base FMID in 127 and TK5 sits at base in **none**
(`foo`'s direction result, reproduced on a different sample). So the 515 split
into "CE never applied the PTF" and "both applied one, to different levels", and
those two groups answer different questions:

| | modules | hits TK5 only | hits CE only |
|---|--:|--:|--:|
| **both systems PTFed**, to different levels | 388 | **15** | **1** |
| MVS/CE still at base FMID | 127 | 7 | 31 |

**Where both systems carry maintenance, Dave's source hits TK5 fifteen times to
one.** MVS/CE's apparent lead is made almost entirely of the other group — 31 of
its 32 wins are modules where CE never applied a PTF and Dave's source has not
got it either. That is not the baseline being a better match; that is two
unmaintained things agreeing.

The same asymmetry stated the other way round:

| Dave's source is byte-identical to a **maintained** object the other system does not carry at all | modules |
|---|--:|
| on TK5 (MVS/CE still at base) | **7** — `IASFCB26` `IASFCB28` `IEBVDM` `IECVOTBL` `IGC0206F` `IGGMSG02` `IKJRBBCM` |
| on MVS/CE (TK5 still at base) | **0** |

Seven to nothing. **Dave Kreiss' source demonstrably carries object-level
maintenance that MVS/CE does not**, and there is no case of the reverse. That is
the lineage argument, measured rather than asserted: his oracle was TK3, TK5 is
what TK3 grew into.

And on the 459 that hit neither, the near-miss goes the same way — of those that
differ by an unequal number of bytes, TK5 is the nearer object in 58 and MVS/CE
in 41 (360 differ by the same amount on both sides).

### So the prediction was right, and the raw count was not

Recorded as it happened: the prediction said TK5; the first table said MVS/CE by
32 to 22; the stratified table says TK5 by 15 to 1 and 7 to 0. **The raw count
was not wrong, it was the wrong grouping** — exactly the failure this project
keeps meeting, and the reason the rule is to group by what the oracle says rather
than by what the totals look like.

## Two corrections to what was believed before this ran

**1. "Length differs" is not by itself a code difference.** `dlib-distance-tk5-ce.md`
classified 727 modules as `len-diff` and called that "a definite code difference —
a date never changes the length". Dates do not, but the **member envelope** does.
`IDA121CV` is 502 bytes on TK5 and 490 on MVS/CE, and its CSECT is byte-identical
on both — and identical to ours. The twelve bytes are a **CESD entry**: MVS/CE's
member carries the alias `IGC121`, TK5's does not.

```
tk5  ...  IDA121CV               IDA121A
ce   ... &IDA121CV      IGC121   IDA121A
```

`IEBISMES` is the same shape, 1,686 against 1,674. That is a **floor of two**, not
a rate — the method here can only see it where our own deck matches both sides.
What it establishes is that whole-member length mixes code with aliases and
identification records, and a count built on it is an upper bound on code
differences, not a measurement of them.

**2. TK5's IFOX00 is not a different assembler.** TK5 carries 115 USERMODs against
MVS/CE's 37, which raised the question of whether the 5,528 recorded reference
decks are MVS/CE-specific. `BAS 14,TGT` assembles to `4DE0 F004` at severity 0 on
`MVSTK5-BLD` — the same as on MVS/CE, so `ZP60025` is applied on both
([`ifox-lineage.md`](ifox-lineage.md)). One probe is not a proof for the whole
assembler, and a deck-level comparison of the two is a Fahrplan item; but the
cheap version of the question has been asked and the answer was reassuring.

## What this does and does not settle

**Settled:** the baseline choice is worth 10 modules out of 3,988 in raw match
count, and TK5 by 15 : 1 and 7 : 0 wherever the two systems are both maintained.
**TK5 is the baseline**, and the reason is not lineage-by-assertion but seven
modules where Dave's source carries a PTF that MVS/CE has never seen.

**Not settled, and much larger:** **459 of the 515 divergent modules hit neither
system.** Concentrated in `AOSU0` (94), `AOSD0` (77), `AOSA0` (75), `AOS20` (42).
Choosing a baseline does not move those; they are the actual recovery work, and
they are where the maintenance that never reached any source still sits.
