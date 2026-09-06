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

---

## Addendum: what the IDR records say

The cc370 session ran the new load-module walk over all 102 members and counted
their IDR records — three in 34 of them, four in 68. Decoding the subtype byte
answers what the fourth is.

| IDR subtype | Meaning | Members carrying one |
|---|---|---:|
| `X'01'` | translator | 102 |
| `X'02'` | linkage editor (all `5752SC104`) | 102 |
| **`X'04'`** | **IMASPZAP** | **73 (71 %)** |
| `X'08'` | user, written by `IDENTIFY` | 97 |

**71 % of the distribution-library members were touched by SPZAP after
link-edit.** Whether every one of them had instructions changed, as opposed to
only having IDR data stamped, does not follow from the count — that needs the
zap data itself. But an SPZAP record means the object was modified after it was
assembled and bound, which is by construction something no source carries.

The user IDR carries a maintenance identifier per module: 77 of the 102 have a
readable one, 29 of them PTF numbers (`UZ79011`, `UZ24221`, `UZ60057`, …) and 48
IBM `RSI` stamps. That is a **per-module maintenance level, machine-readable**,
which is what the inventory in item 6 wants and what
[cc370#111](https://github.com/mvslovers/cc370/issues/111) is for.

### The correlation, and it is the interesting part

| | Modules | of those, zapped |
|---|---:|---:|
| section lengths agree | 49 | 28 (57 %) |
| section lengths differ | 52 | 45 (86 %) |

A zap patches in place and does not change a section's length, so this is not a
mechanical effect. The reading that fits: an SPZAP record is a **proxy for "this
module received maintenance after the base release"**, and the modules that
received maintenance are exactly the ones where our source lags. That is the
project's thesis again — measured a second time, on a different quantity than
section lengths, and pointing the same way.

Both readings rest on 102 modules drawn from the ones that already assemble, so
treat the rates as indicative rather than as the population.

### The 21 that should go first

Of the 49 whose lengths agree, **21 carry no SPZAP record at all**. Those are the
cleanest candidates for a first byte-identity verdict: the right size, and
nothing patched into the object behind the source's back.

They are in
[`../work/measurements/first-candidates.txt`](../work/measurements/first-candidates.txt):

```
AMDSAGTF IEAVEUPC IEDQ27   IEDQWID  IEFAB49C IEFDB450 IEFDB4FA
IEFJDSNA IGG0192V IGG019JP IGG019UO IGG026DU IGG0940D IGG0CLB3
IGG0CLBR IRBMFDPP ISTESC02 ISTINCDT ISTINCR1 ISTZBFAM ISTZGFAB
```

`IGG026DU` and `IEFJDSNA` are among them and are already committed as fixture
pairs.

---

## The first verdicts, and what the differences turned out to be

`cmplmd370` exists. Over all 102 pairs:

| | identical | differing |
|---|---:|---:|
| candidates (length equal, no SPZAP) | 6 | 15 |
| length equal, zapped | 12 | 16 |
| **length differs** | **0** | **53** |

**18 modules are byte-identical**, and all 52 negative controls were correctly
reported as differing — the check that mattered, because a comparator that
returns 0 too easily would have shown up there.

### Ten modules whose differences are all "ours zero, theirs occupied"

The cc370 session counted, byte by byte, which side was zero in each difference,
and found ten length-equal modules that differ **exclusively** in that pattern.
It flagged the right caveat with it: our side being zero is not proof of a `DS`
hole — a simply missing constant looks identical in that statistic.

There is a mechanical way to tell them apart. **An object deck's `TXT` cards say
which offsets the assembler generated anything for.** An offset covered by no
`TXT` card is one where `as370` emitted nothing at all; the loader zeroes it, and
whatever the shipped module carries there is residue. An offset covered by a
`TXT` card holding `00` is a zero the assembler deliberately produced — and a
difference there is a real one.

| Module | differing bytes | in a gap | in generated text |
|---|---:|---:|---:|
| `AMDSAGTF` | 100 | 100 | 0 |
| `IEFDB4FA` | 2 | 2 | 0 |
| `IEFJDSNA` | 1 | 1 | 0 |
| `IFDMSG53` | 22 | 22 | 0 |
| `IGG0CLB3` | 5 | 5 | 0 |
| `IGG0CLBR` | 2 | 2 | 0 |
| `ISTINCR1` | 1 | 1 | 0 |
| `ISTZBFAM` | 5 | 5 | 0 |
| `ISTZGFAB` | 2 | 2 | 0 |
| **`HMASMRCC`** | **186** | **0** | **186** |

**Nine of the ten are entirely holes. One is not.** `HMASMRCC` differs only
inside text `as370` actually generated, so its zeros are deliberate — a real
difference, and an SMP module at that.

### Verified, not only inferred

The criterion was checked against the source in two cases.

`IEFJDSNA`, one byte at `0x00AA`: `BR @14` ends there and the next constant is
fullword-aligned at `0x00AC`.

`IFDMSG53`, an 11-byte gap at `0x00007D` and a 3-byte one at `0x0000B5`:

```
00007D           MSG3     DS    F
000084                    DS    F
000088  0029              DC    AL2(41)      <- first generated byte again
...
0000B5           MSG4     DS    0F
0000B8  0039              DC    AL2(57)
```

Two fullwords of `DS` and their alignment — exactly 11 bytes. And three bytes of
padding before `MSG4`'s fullword boundary. The gaps the `TXT` coverage finds are
the `DS` statements in the source.

The remaining seven were not read line by line. Their gap lengths (1, 2, 3, 4, 8,
13, 18, 19, 31) are all consistent with alignment and small work areas, and none
of their differing bytes lies in generated text.

### What that is worth

`work/fixtures/holes.difin` records all of it in Dave Kreiss' format — 32 lines
for nine modules. With it, **27 of roughly 50 length-equal modules are identical
apart from documented holes**: the 18 already byte-identical plus these nine.

That is the point of the whole `DIFIN` mechanism, arrived at independently: the
holes are unavoidable, they are not defects, and the only honest way to handle
them is to name each one and carry the list forward.

---

## Would another source copy fit better?

2026-09-06, evening. The cc370 session found, while chasing a counting
discrepancy, that the same module exists in several of our source pools with
**structurally different** section layouts:

```
www.stben.net       ICFBDE00 ICFBDE00 ICFCVTOR ICFBDE00   ICFCVTOR is a DSECT
Dave Kreiss/MVSBLD  ICFBDE00 ICFBDE00 ICFBDE50 ICFBDE00   ICFBDE50 is a CSECT
mainframe.eu        ICFBDE00 ICFBDE00 ICFCVTOR ICFBDE00   as stben
```

Different maintenance levels, different structure. Measured over the index:

| | Modules |
|---|---:|
| indexed | 5,252 |
| exist in more than one pool | 1,209 |
| **copies structurally unequal** | **29** |

That raises an obvious question, since 3,118 of the 3,316 differing modules have
a copy in a mirror: **would the other copy match the shipped object where Dave
Kreiss' does not?**

### Measured on 300 of them: almost never

| | Modules |
|---|---:|
| mirror copy assembles | 294 |
| does not assemble | 6 |
| **byte-identical to the DLIB member** | **2** |

`HMASMVLU` and `ISTYSSCP`. Extrapolated over all 3,118 that is on the order of
twenty modules — real, cheap to harvest, and not a lever.

**The negative result is the more useful half.** The web mirrors are not a better
basis than Dave Kreiss' reconstruction; where his source does not match, theirs
almost never does either. That validates the project's premise — build on his
work — with a measurement rather than an assumption, and it retires the idea that
the mirrors might be a shortcut.

It also means the **29 structurally divergent modules** are the ones to watch: a
byte-identity verdict there can be measured against the wrong copy, and it would
look exactly like an assembler defect. The README already warns that
`macros/mirror/` has an unverified maintenance level. This is the same problem on
the source side, and it now has an upper bound.
