# The baseline gate, predicted before it ran

**Written 2026-09-13, before `baseline_gate.py` produced a single row.** Never
edited afterwards, on the model of [`run6-predictions.md`](run6-predictions.md):
a prediction that can be revised after the fact measures nothing.

The question is Dave Kreiss' of 2026-09-12 — *"target not DLIB is the version of
code you should compare to"* — and the instrument is our own source decks scored
against TK5's DLIB members and TK5's target members with the same comparator.

## What is already measured, and therefore not predicted

From the `LMDXRF38` extracts, no source involved
([`xref_distance.py`](../tools/xref_distance.py)):

| | |
|---|---:|
| CSECT names in both baselines, one length each | 4,793 |
| same length | 4,719 |
| **length differs** | **74** — 1.5 % |
| control: the build's own two sides | **0 of 4,795** |

Joined to the 1,277 modules our source already reproduces byte-for-byte against
the DLIB: **19 of them have a different length in the target library**, twelve of
those TSO. That join is arithmetic on the extracts and needs no bytes.

## The predictions

**P1 — the 19 must all come back `tgt_c = len-differs`.** They are the ones whose
target CSECT is a different size, and a source that matches the DLIB cannot also
match a CSECT of another length. If a single one of them comes back `identical`,
the comparator is not reading what I think it is and nothing else in the run may
be interpreted.

**P2 — `CMDLIB(ALLOCATE)` reproduces the hand probe.** `IKJEFD31`, `IKJEFD33`,
`IKJEFD34`, `IKJEFD35`, `IKJEFD37` identical against the DLIB and not identical
against the target; `IKJEFD30` and `IKJEFD32` not identical against either;
`IKJEFD36` holes-only against the DLIB.

**P3 — the `dlib` column reproduces `ss-overlay-vs-tk5.tsv` module for module.**
This is plumbing, not a finding. If a *small* set disagrees, the first suspect is
the pinned assembly stamp — `TODO.md` names 38 modules whose jobs ran at 29
distinct times, and one pinned `ASMTIME` cannot satisfy them. If a *large* set
disagrees, the binary is wrong (`as370` against `as370-main`) and the target
column must not be read at all until the DLIB column comes back.

**P4 — the negative control at scale.** Of the ~1,046 modules that are identical
against the DLIB *and* carry the same length in both libraries, the large
majority must come back `identical` against the target too. This is the
prediction that distinguishes a working comparator from one that cannot read a
packed multi-CSECT member: if those come back `differs` en masse, the finding is
about relocation and section packing, not about maintenance.

**P5 — the envelope.** The count of modules that are `identical` against the DLIB
and *not* identical against the target should land in the region of **35 to 45**:
the 19 length cases plus the fifteen-to-twenty content-at-equal-length cases that
Dave's own `RPTTGT` report flags where `RPTDLB` does not. Hundreds would be the
instrument. Single digits would mean the `RPTTGT`-only set was a population
artefact after all.

**P6 — error classes exist and are to be counted, not debugged.** `SYS1.NUCLEUS`
is essentially one scatter-format member, `IEANUC01`, holding some 350 CSECTs,
and there is no reason to assume `cmplmd370` parses that format. Overlay-format
members are the same kind of case. Both should appear as their own verdict in the
table rather than as a surprise.

**P7 — map and bytes come from two systems, and that has to show as zero.** The
CSECT-to-member map was cut by `LMDXRF38` on **MVSTK5-BLD** on 2026-09-11; the
bytes were pulled from **MVSTK5-REF** on 2026-09-13. If both systems' `SYS1`
libraries are still IBM's, then `len_same = Y` together with
`tgt_c = len-differs` — or `N` together with `identical` — must be empty or very
nearly so. A populated cell there means one of the two systems moved, and the
assumption written into `fetch_xref.py`'s docstring is what broke.

## What no prediction covers

Whether the target is the **right** baseline. That is Mike's call, not a
measurement, and `TODO.md` records it as open rather than decided. What the gate
can do is partition the tree so that the part where the two baselines agree can
be worked on while the question is open.

---

# Run 8's source, predicted before it was pulled

**Written 2026-09-13 while `srcpull.py` was still running**, so before a single
module of the new tree had been assembled. Same rule as above: not edited after.

`MAINT05Z` and the 82 jobs behind it put maintenance into phases 6–15 for the
first time — **1,017 distinct modules, 596 of which had never been maintained at
all** ([`dave-install-log.md`](dave-install-log.md)). The question this run asks is
the only one that matters about it:

> **Does any of that reach the SOURCE library, and does the source it produces
> reach IBM's object?**

Those are two different questions and the run answers them in order.

## What is known and therefore not predicted

| state | against TK5's DLIB |
|---|---:|
| Dave's archive | 1,221 of 5,353 |
| the system's source after **run 7** (`ss-run7-vs-tk5.tsv`) | **1,221** |
| archive + our 256 repairs (`overlay`) | 1,470 |
| the same overlay under the chosen baseline | 1,403 |

Run 7's source scored **exactly what the archive scores**. That is the fact this
run is aimed at: [`source-states.md`](source-states.md) explains it as run 6
stopping at the phase-1 boundary, so 619 of 1,357 `DSK`-marked modules never
reached the system's source at all.

## The predictions

**Q1 — the source moved.** The run-8 tree differs from the run-7 tree in a
substantial number of members. If the two trees are *identical*, then the 82 jobs
APPLYed maintenance to object and listings and not to `AMVSSRC`, and everything
below is moot. **This is the prediction I am least sure of** and it is the one
that decides whether the rest means anything.

**Q2 — the score rises above 1,221.** Direction predicted, magnitude not. A gain
of a few dozen would say the maintenance reaches the source and mostly is not
IBM's; a gain in the hundreds would say Dave's `DSK` PTFs reconstruct IBM's object
closely. **Refutation: 1,221 or below.** That would mean either the maintenance
does not reach the source, or it reaches it and moves it *away* from IBM's object
— and the second would be the more interesting result of the two.

**Q3 — the two source libraries may now differ.** `MVSSRC.BLD.AMVSSRC` is the
distribution source, `MVSSRC.BLD.MVSSRC` the target source, and Dave names the
**target** one. Measured on 2026-09-12 over 25 random members they were identical,
columns 1–72, on a tree where everything had been ACCEPTed. Run 8 did both APPLY
and ACCEPT per phase, so they should still agree — but this is the first chain
where they had a chance to drift, and a fresh 25-member sample is cheap.

**Q4 — `src/`'s 256 modules are a separate axis and must not be folded in.** The
comparison is run-7 source against run-8 source, both without our repairs. Mixing
them would credit the build with work we did by hand, which is exactly the
confusion `overlay.md` was written to prevent.

## What no prediction covers

Whether Dave's `DSK` PTFs are IBM's maintenance. They are his reconstruction of
it, and a module can take a `DSK` PTF and move further from IBM's object rather
than closer. The scoreboard is the only thing that can tell, and it does not care
which of the two happened.
