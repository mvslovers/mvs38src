# DLIB or Target — the gate, run

2026-09-13. Dave Kreiss, 2026-09-12:

> *"Let me emphasize that target not DLIB is the version of code you should
> compare to since target is what the running system uses."*

Every host-side figure this project has published was measured against TK5's
**distribution** libraries. [`kreiss-reply-2026-09-12.md`](kreiss-reply-2026-09-12.md)
called for a test rather than an argument. This is the test.

**Predicted before it ran, in [`baseline-gate-predictions.md`](baseline-gate-predictions.md),
which is not edited afterwards. All seven predictions hold.**

## The answer in one table

The same 5,353 decks — one `as370` binary, one macro path, one pinned stamp, one
comparator — scored against TK5's DLIB member and TK5's target member.

| | modules |
|---|---:|
| **identical against both** — the baselines agree, work here is safe | **1,052** |
| identical against the DLIB, **not** against the target | **38** |
| identical against the target, **not** against the DLIB | 17 |
| neither | 3,250 |
| no target counterpart at all | 839 |
| target member the comparator cannot read | 143 |
| no deck | 14 |
| | **5,353** |

So the scoreboard figure depends on the yardstick:

| | identical |
|---|---:|
| against the DLIB | **1,236** |
| against the target | **1,069** |
| against both | 1,052 |

**Not 1,277.** That figure is `srcstate_vs_dlib.py`'s, which pairs every section
of a deck by name; this tool restricts to the one CSECT the module is named
after, because a target member holds CSECTs our deck never contained and an
unrestricted comparison would measure the restriction. 238 decks change verdict
under that restriction. The DLIB column reproduces `ss-overlay-vs-tk5.tsv`
**module for module, 0 of 5,353 disagreeing**, so the two tools agree wherever
they ask the same question.

## The part that matters, and it is TSO

Of the 257 `IKJ*`/`IKT*`/`AKJ*` modules:

| | modules |
|---|---:|
| identical against both | **43** |
| identical against the DLIB, **not** against the target | **23** |
| neither | 173 |
| no target counterpart | 15 |
| target unreadable | 3 |

**35 % of the TSO modules we call recovered are recovered against the back-level
copy.** That is the highest concentration anywhere in the tree, which is what
[`maintenance-level.md`](maintenance-level.md) predicted from the other side: 33
of the 76 members carrying service after 1985 are `IKJ*`.

The 23:

```
IKJCT430 IKJCT431 IKJEBEUN IKJEFD31 IKJEFD33 IKJEFD34 IKJEFD35 IKJEFD37
IKJEFE16 IKJEFF02 IKJEFF10 IKJEFF50 IKJEFF53 IKJEFT09 IKJEFT56 IKJEFTE2
IKJEFTSC IKJEGMSG IKJTTRM0 IKT0009C IKT0940A IKTCAS54 IKTXLOG
```

`IKJCT430` and `IKJCT431` are where this whole project started — the TSO CP
service routines the BREXX integration needed.

## And six of our own repairs are on the wrong side of it

`src/` holds 56 modules, every one byte-identical to its DLIB member and
asserted so by `srccheck.py`. Against the target:

| | modules |
|---|---:|
| identical | 32 |
| no target counterpart | 18 |
| **differs** | **5** |
| **length differs** | **1** |

```
IKJEBEUN  IKJEFD35  IKJEFE16  IKJEFF02  IKJEFF50  IKJEGMSG
```

This is [`overlay.md`](overlay.md)'s `IKJRBBCM` at scale. There, one repair was
correct against MVS/CE and wrong against TK5 because the baseline moved and
nothing re-checked the repairs. Here, six repairs are correct against TK5's DLIB
and wrong against TK5's target — **`IKJEFE16` and `IKJEGMSG` were deposited on
2026-09-12, the same day Dave's mail arrived saying the yardstick was the other
one.** Nothing was wrong with the work; the reference under it is in question.

## Where the baselines are apart, without any source in the way

Measured first from `LMDXRF38`'s own extracts, no deck and no assembler
involved — [`xref_distance.py`](../tools/xref_distance.py):

| | |
|---|---:|
| CSECT names in both baselines, one length each | 4,793 |
| same length | 4,719 |
| **length differs** | **74** — 1.5 % |

**The control has a known answer and gives it.** SMP `APPLY`s and `ACCEPT`s the
same object, so Dave's build's own two sides must agree: **4,795 of 4,795, zero
differences.** None of the 74 appears in the control, so they are maintenance and
not library structure.

A length difference proves the baselines differ. A length *match* proves nothing
— equal-length CSECTs can hold different bytes, and that is the commonest class
in Dave's own report. So 74 was a lower bound and the byte comparison closed it:
of the 38 modules that lose their identity against the target, **20 by length and
18 at the same length**.

## What is not decided here

**Which baseline the project measures against.** `TODO.md` records it as open and
it is Mike's call; this document gives it numbers rather than taking it.

What the gate does settle is that the question is not academic — it moves 167
modules' verdicts and 23 of Mike's 257 TSO modules — and it partitions the tree
so that work can continue while the question is open:

- **1,052 modules where both baselines agree.** Any repair here is right under
  either answer.
- **48 of the 65 TSO `fillgaps` candidates carry the same verdict against both
  baselines.** Hand work on those is unambiguous today. The other 17 wait:
  `IKJEBEUN IKJEE150 IKJEE1A0 IKJEFD30 IKJEFD32 IKJEFD35 IKJEFD36 IKJEFE06
  IKJEFE16 IKJEFF02 IKJEFF06 IKJEFF12 IKJEFF50 IKJEFTE8 IKJEGMSG IKJRBBMG
  IKJRBBU1`.
- **839 modules have no target counterpart at all.** For those the DLIB is the
  only yardstick there is, whatever is decided.

## The other direction, which nobody had asked about

**17 modules are identical against the target and not against the DLIB.**

```
HMASMCPL HMASMSUP HMASMTM4 HMASMTMS  ICKAN01 ICKDV00 ICKIN02 ICKSD02 ICKTSEF1
IDA019S4  IDCIO01 IDCIO02  IECVERPL IECVESIO IECVRRSV  IGC121 IGG019V6
```

Four are SMP — Mike's second priority — and the shape fits Dave's account
exactly: maintenance that was `APPLY`ed and never `ACCEPT`ed reaches the target
and leaves the DLIB behind, so a source carrying that maintenance matches the
target and not the DLIB. These are modules where Dave's source is *ahead* of the
DLIB, and against the DLIB they read as failures.

## How it was measured, and what it cannot tell you

The map — which bound module a CSECT lives in — is the part that made the target
side look expensive. `CMDLIB(ALLOCATE)` holds seventeen CSECTs and its name says
nothing about any of them. **Nobody here had to build that map:** Dave's chain
runs `LMDXRF38` over every library on both sides and leaves four cross-references
on `MVSTK5-BLD`, one record per (library, LMOD, CSECT, length).
[`fetch_xref.py`](../tools/fetch_xref.py) brings them across;
[`baseline_gate.py`](../tools/baseline_gate.py) scores against them.

The bytes come from **MVSTK5-REF**, the oracle, pulled with the same
`dlibpull.py` that read the DLIBs — `--cache target-bytes`, a separate root,
because `srcstate_vs_dlib.py` walks *every* directory under `dlib-bytes/tk5` and
a target member cached there would have silently shadowed a DLIB reference.
2,396 members, 2,395 read, 0 absent, including the six whose names carry a `{`.

Map and bytes therefore come from two different systems, and that has to be
shown rather than assumed: over the 1,064 modules whose deck is known to be the
DLIB's length and which both extracts list, the XREF lengths and the comparator
**never contradict each other — 0 contradictions.**

### What this instrument cannot see

`cmplmd370` reports `diff_bytes` 0 in **2,393 of the 2,406** length-differing
rows of `ss-overlay-vs-tk5.tsv`. So a zero byte count next to a length difference
does not mean the bytes agree up to the shorter length — it means the comparator
stopped. **Read the verdict, never a byte count out of a length difference.**
Where the target CSECT is longer, this document says only that our source does
not reproduce it; it does not claim the difference is confined to the tail.

### 143 target members it cannot read at all

By bound module: `IEANUC01` 24, `HEWLF064` 22, `IFDOLT` 18, `IGC0001I` 15,
`HMASMP` 13, `IGC0005E` 13, and a tail. `IEANUC01` is the nucleus — scatter
format — and the others are overlay-structured load modules. This was predicted
and is counted rather than debugged: the MVS-side instrument already reports
`SYS1.NUCLEUS` at 94.4 %, so nothing important is hidden in that class. It is
work for `cmplmd370`, and it is 2.7 % of the corpus.

### Three CSECTs whose several target copies disagree

`BLSRVPAS`, `IEEVSDIO`, `IEFAB4E1`. A CSECT can be bound into several load
modules, each link-edited at its own time, so the copies can sit at different
maintenance levels. `baseline_gate.py` keeps the *best* verdict — which biases a
divergence gate toward "they agree", the wrong way — so `tgt_split` names the
rows where that bias was exercised. Three is small; it is not zero, and it would
have been invisible.

## Two things the tool got wrong first, both caught by a control

Neither was found by reading the code.

1. **The coherence check confused two different lengths** and reported 1,987
   contradictions. `tgt_c = len-differs` compares *our deck* against the target
   member; `len_same` compares the *two libraries*. A deck that is the wrong
   length is the wrong length against both, so `len_same = Y` is then exactly
   right. The check is only meaningful where the deck is known to be the DLIB's
   length. A four-figure count in a coherence test is not a finding about the
   systems; it is a finding about the test.
2. **`len_same` has three states and the fix treated it as two.** `?` means the
   CSECT is in the target extract and not in the DLIB one — 26 rows, no pair of
   lengths to compare — and they came back as contradictions until the third
   state was admitted. Then: zero.

The first version of `xref_distance.py` made a third: it took each CSECT's
*first* length instead of the set of them, and reported 4 differences on the
build's own two sides. All four were CSECTs bound into several modules at
several lengths. Handling them as a set moved them into their own counted class
and the control went to zero — which is what the control was for.
