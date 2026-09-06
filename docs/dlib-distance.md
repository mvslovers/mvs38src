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
| 1–8 bytes | 0 |
| 9–64 bytes | 7 |
| 65–256 bytes | 3 |
| 257–1024 bytes | 3 |
| over 1024 | 0 |

Median 60 bytes, maximum 709. Our deck is smaller in 9 cases and larger in 4.

**Nothing differs by less than 9 bytes**, which is worth noting: these are not
near misses. A missing or extra instruction sequence, not a single field.

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

Three things, immediately:

1. **A worklist with a real ordering.** The 49 go first: they are the ones where
   `cmplmd370` will produce a meaningful verdict on its first run.
2. **A test set for the comparator itself.** 49 plausible-identity cases and 52
   certain-difference cases, real IBM material, before the tool exists.
3. **A baseline.** Re-run it after the macro provenance is settled and the number
   moves — or it does not, which is also an answer.
