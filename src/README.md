# `src/` — the recovered source

A module is here when its assembly is **byte-identical to the object IBM
shipped** — `cmplmd370` exits 0 against the distribution library member. Nothing
else qualifies. Laid out by the distribution library the object came from.

Format is Dave Kreiss': records of exactly 80 characters, sequence numbers in
columns 73–80, CRLF. Never reformat.

## What is here, and why it is here

**Ten modules, 2026-09-07, the first entries.** They differ from `MVSBLD` in one
character: `^` inside a character constant becomes `¬`.

`MVSBLD` came off the mainframe through a transfer that read EBCDIC as **cp1047**,
where X'5F' is `^`. Everything here reads **cp037**, where X'5F' is `¬` and `^` is
X'B0'. So a constant written `C'^'` assembled to X'B0' where IBM's object has
X'5F'.

**The tree-wide comparison against IFOX00 could not see this**, and that is the
instructive part. `as370` encodes cp037; the source reaches MVS through mvsMF,
which encodes cp037 as well. Both assemblers therefore received X'B0' and agreed
with each other perfectly. These modules sat in the table as *"the two assemblers
agree, only IBM's object differs"* — booked to the source, correctly, with no way
to tell what about the source was wrong. Only IBM's shipped object could settle
it, and it did: with the substitution ten modules become identical and not one
gets worse.

Repair with [`tools/caret_fix.py`](../tools/caret_fix.py). 39 modules carry the
character in a constant; the other 29 have further differences and will follow as
those are settled.

Found by the `mvssrc-20` session, measured here.

## Sixteen more, from IBM's own tape

> ⚠️ **The tape tree is still being built** (`mvssrc` sessions, 2026-09-07). These
> sixteen are safe against that: each was taken from a module name occurring
> **exactly once** across all tapes, so the pending resolution of the 738
> duplicates by SSI cannot change which text they came from. Nothing further is
> taken from it until it is finished.

The `mvssrc-20` session extracted the IBM distribution tapes byte-exact
(`~/repos/mvs/mvs38-ibmsrc`, 7,206 members). For 1,023 modules where the two
assemblers agree, the object still differs from the DLIB member, and IBM's
original source is unambiguously available and **differs from Dave Kreiss'**,
that source was assembled here instead:

| | Modules |
|---|---:|
| became byte-identical to IBM's object | **16** |
| fell to `DS` holes only | 19 |
| **got worse** — text difference became a length difference | **110** |
| unchanged in kind | the rest |

**These are the 16 exceptions, and that is all they are.** IBM's tape is the
material Dave Kreiss started from, curated for us by the `mvssrc` sessions; his
tree being closer to the object is his project's definition, not a discovery. The
16 are the places where his repair never happened or went the wrong way, and the
110 are where it demonstrably worked.

What the comparison does establish, and it was previously an assumption: **IBM's
own source does not reproduce IBM's own object** — for 98 % of these modules the
untouched original misses it too.

The sixteen are here because for them it does. Each names the tape it came from
in the commit.

Seven of them are modules the `^` substitution alone could not rescue
(`ICKTSTP0`, `IDCTSTP0`, `IEBFDANL`, `IGG1QN`, `IGG1QNC`, `IGG2G11`, `IGG2P11`):
IBM's text carries the right byte natively *and* whatever else differed. The two
routes do not overlap and do not collide.
