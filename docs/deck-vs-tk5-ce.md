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

*(pending — the pull is running)*
