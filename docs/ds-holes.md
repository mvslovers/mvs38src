# The `DS`-hole class is not benign — 2026-09-12

A `DS` reserves storage without initialising it, so our object deck has no bytes
where IBM's distribution member has some. `cmplmd370` calls that a hole and
reports it separately (`verdict: "holes"`, `diff_in_holes`, `diff_in_text`).

**The standing reading was that a hole cannot be a defect** — uninitialised
storage, where IBM's object carries whatever the linkage editor left in its
buffer. [`ifox-oracle.md`](ifox-oracle.md) drew that conclusion explicitly for
`IEFJDSNA`: *"Source correct, tool correct, difference explained — the first time
all three could be said at once."* [`tree-wide-run.md`](tree-wide-run.md) counts
"identical-or-holes" as a success measure, and
[`lpalib.md`](lpalib.md) said, before this file existed, that the scoreboard
counts them as failures and should not.

**That reading is wrong.**

## Measured

The class is larger than the old figure suggested. Over the 3,988 reference
modules, on the run-7 source state:

| | modules | |
|---|---:|---:|
| byte-identical | 1,089 | 27.3 % |
| **holes-only** | **495** | 12.4 % |
| differ in text or length | 2,404 | 60.3 % |

The earlier `work/measurements/holesonly.txt` has 281 — a different corpus, an
older assembler and MVS/CE as the reference.

## The control that settles it, and we already had both sides

If a hole's content were linkage-editor residue, **two independently built
systems could not agree on it.** We hold two object baselines: TK5 and MVS/CE.
Over 60 holes-only modules drawn at random, all of which exist on both:

| | |
|---|---:|
| hole clusters carrying **identical** bytes on TK5 and MVS/CE | **309** |
| hole clusters differing between the two | **0** |
| modules agreeing on every one of their holes | 59 of 59 |

**309 of 309.** Residue does not reproduce byte for byte across two separately
built systems. So the bytes are real: IBM's source initialised them and ours
does not.

The content says the same thing without needing the control. In a sample of 435
hole clusters, 398 have us emitting zeros where the reference carries something,
and what it carries is structured — `IEFAB4M4` at offset 228 holds
`f0c1e3e2d6d4c1c3`, EBCDIC `0ATSOMAC`, and at 288 `OS 218IGFMCH17`. Those are
names, not buffer noise. Median cluster length is 2 bytes; the largest in the
sample is 100.

## What it changes

- **`27.3 %` and `25.9 %` stand as they are.** They are not pessimistic, and
  there is nothing to correct in the scoreboard. The figure that would have been
  wrong to publish is **39.7 %**, "identical or holes-only".
- **A decision disappears rather than being made.** The `DS`-hole class was
  about to be put to Mike as a reporting question — 495 modules counted as
  failures for a difference that "cannot be a defect". It can be, and it is.
- **`ifox-oracle.md`'s `IEFJDSNA` conclusion is retracted.** The single byte at
  offset `0x00AA` is `04` in both TK5 and MVS/CE and `00` in ours. Tool correct,
  yes. Source correct, no — that byte is initialised in IBM's source and not in
  ours.
- **`tree-wide-run.md`'s "identical-or-holes" figures measure something that is
  not success.** They are not re-derived here; the caveat belongs on them.
- **And 73 of `lpalib.md`'s 147 cheapest candidates come back onto the list.**
  They were set aside as hole-only. They are work — cheap work, 1 to 4 bytes,
  but work.

## Why this was worth the hour

The class was 495 modules sitting in a category labelled "cannot be our fault".
The label came from a mechanism that sounds obviously right — uninitialised
storage is uninitialised — and the two object baselines this project keeps for
an entirely different purpose were enough to refute it in one run.

`srcstate_vs_dlib.py` had been discarding `diff_in_holes`/`diff_in_text`
altogether, which is the failure this repository keeps catching in itself: the
comparator had already separated the two and the tool threw the separation away.
It records both now.
