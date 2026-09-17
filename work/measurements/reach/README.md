# The code-run witness for `cc370#383` — 2026-09-17

`code-runs-30.tsv` is the witness the cc370 session needs to measure its
reachability traversal against, and it is here because building it there would
mean the party being measured re-implementing the instrument that measures it.

**1,554 runs, 62,078 bytes, over the 30 control CSECTs** — the same runs
`tools/rootreach.py`'s coverage figures are computed over.

| column | |
|---|---|
| `csect` | the section |
| `offset` | section-relative, hex |
| `length` | bytes |

## The two properties that decide what a fraction over this means

Both are decided, so neither needs reporting twice.

**A run is bytes the listing emitted as INSTRUCTIONS**, not bytes inside a region
the listing called code. Alignment and padding between statements emit no object
code in a listing, so they are **not** in any run and a run **breaks** across
them. A traversal that walks over an alignment gap and continues is doing the
right thing and will simply not be credited for those bytes — they are in neither
numerator nor denominator.

**A `DC` inside a code region breaks the run and is excluded entirely.** A literal
pool or an inline constant is an emitting statement in the listing, but it is not
reachable by execution, so it is in neither the numerator nor the denominator. It
cannot count against a traversal.

## Two properties of the witness itself, which are not definitions but limits

⚠️ **The offsets are OUR deck's.** The witness comes from assembling
`work/src-states/overlay/<csect>.ASM` with the gate's own parameters. **27 of the
30 are `dlib_identical`**, so for those the offsets are the member's as well. The
three that are not — `IECVERPL`, `IECVESIO`, `IKJEFF02` — must **not** be scored
against this witness when the traversal runs over the bound member: it would be
comparing a traversal of one byte stream against a witness derived from another.

⚠️ **The witness is not ground truth to the byte.** Against `dasm370`'s own
independent classification of the same decks, **66,689 of 68,192 comparable bytes
agree — 97.8 %**. Neither side is the reference, so the 2.2 % is a disagreement
between two instruments and not an error rate for either. A fraction computed over
this denominator carries that.

## Provenance

`tools/rootreach.py --set deliverable --runs-out work/measurements/reach/code-runs-30.tsv`

Two defects in the listing walk were caught by controls before any figure left
this machine, and both are recorded in that file's docstring: it did not track the
section, and the card image begins at column 40 rather than 41.
