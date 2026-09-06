# How far is Dave Kreiss' source from MVS/CE's object code?

2026-09-06. The first measurement of that distance, and it needs no comparator.

## The idea

`cmplmd370` does not exist yet, so byte-identity cannot be tested. But a section
carries its **assembled length** in the ESD of our object deck and in the CESD of
the distribution-library member. Those two numbers can be compared today.

Equal length is **necessary but not sufficient** for byte-identity. Unequal
length is close to conclusive in the other direction — with one caveat below.

## The sample

Of the 111 modules in the standing sample that assemble cleanly, **102 have a
member of the same name in a distribution library**. All 102 were extracted from
a pristine MVS/CE 2.1.4 (`smp000.3350`, `dasdcat`) and compared section by
section, matched on section name.

## The result

Per module:

| | Modules |
|---|---:|
| **section names and lengths identical** | **49** |
| lengths differ | 52 |
| section names differ | 1 |

Per section — 109 sections across the 102 modules:

| | Sections |
|---|---:|
| `EQUAL` | 50 |
| `LEN_DIFF` | 52 |
| `OBJ_ONLY` | 6 |
| `DLIB_ONLY` | 1 |

The full table is in
[`../work/measurements/section-lengths.tsv`](../work/measurements/section-lengths.tsv);
the 102 members themselves are in
[`../work/fixtures/dlib-102/`](../work/fixtures/dlib-102).

**Roughly half of what assembles is already the right size.** For those 49, the
question "is it byte-identical" is open and worth asking. For the other 52 the
answer is already no, and the source needs work before a comparator would say
anything useful about it.

## How far off are the 52?

| Difference | Sections |
|---|---:|
| 1–8 bytes | 6 |
| 9–64 bytes | 15 |
| 65–256 bytes | 18 |
| 257–1024 bytes | 12 |
| over 1024 | 1 |

Minimum 4 bytes, median 81, maximum 1,028. **The DLIB member is the larger side
in 39 of 52 cases** — our source is more often short than long, which is what one
would expect if maintenance reached the object code and not the source.

> An earlier version of this section reported "nothing differs by less than 9
> bytes, median 60, maximum 709". That was computed over 13 of the 52 cases: the
> evaluation ran against a listing that had been truncated for display. The
> table above is over all 52.

The smallest differences are the interesting ones, and there are six of them at
8 bytes or less.

## One trap, and it does not apply

The cc370 session flagged it: in a bound load module the binder places sections
on doubleword boundaries, so the **distance between two section origins** can
exceed the assembled length by up to 7 bytes. Measuring distances would produce
a false difference for every section whose length is not a multiple of 8.

This measurement reads the **SD length field**, not distances. And the field is
not rounded either: of 103 SD length fields in the 102 members, **57 (55 %) are
not divisible by 8**. The field carries the raw assembled length.

## What the number does not say

- **Equal length is not identity.** Two different instruction sequences of the
  same length compare equal here and differ byte for byte.
- **Unequal length does not always mean the source is wrong.** If our macros sit
  at a different maintenance level than the ones IBM assembled with, the
  generated code differs in length while the source itself is correct. 319 of our
  private macros come from web mirrors with an unestablished level — exactly this
  risk. See [`private-macros.md`](private-macros.md).
- **The sample is biased towards the simple.** These 102 are drawn from the
  modules that already assemble. The ones that do not are, on average, the harder
  ones, and there is no reason to expect the same rate there.
- **Dave Kreiss verified against TK3**, and this is MVS/CE. A length difference
  may be a distribution difference rather than a source defect. Which of the two
  it is becomes answerable once the DLIB hypothesis (item 5b) is measured.

## What it is good for

**The 52 are worth more than the 49**, and that is worth stating plainly because
the instinct runs the other way.

`cmplmd370`'s load-bearing property is *exit 0 only on identity*. A comparator's
failure mode is not inventing differences — it is returning 0 too easily: a
`--difin` that masks too generously, a `--clearrld` that zeros too much, a
section-pairing bug that quietly compares nothing at all. Every one of those ends
in a green zero. The 52 catch exactly that class, and they catch it **before the
tool exists**.

The 49 are **not** a positive control. Their answer is unknown; using them as
"must exit 0" would be the same tautology this document warns about above.

Ordered by sharpness — a comparator that misses 1,028 bytes is broken, one that
misses 4 is plausibly broken:

| Δ | Module | Section | DLIB | ours |
|---:|---|---|---:|---:|
| 4 | `IEBUPDTE` | `IEBUPDTE` | 776 | 772 |
| 4 | `IEE4303D` | `IEE4303D` | 662 | 666 |
| 8 | `IEAVAD11` | `IEAVAD11` | 518 | 526 |
| 8 | `IEDQB7` | `IEDQB7` | 284 | 276 |
| 8 | `IGCAD10D` | `IGCAD10D` | 953 | 945 |
| 8 | `IKTQMIN` | `IKTQMIN` | 4044 | 4052 |

And two more things:

1. **A worklist with a real ordering.** The 49 go first for *recovery* work:
   they are where a verdict is worth asking for.
2. **A baseline.** Re-run it after the macro provenance is settled and the number
   moves — or it does not, which is also an answer.
