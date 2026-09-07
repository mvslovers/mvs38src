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
