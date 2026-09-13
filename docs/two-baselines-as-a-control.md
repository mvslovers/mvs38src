# The second baseline is a control on option A, and it found 99 bytes of noise

2026-09-13, after [`baseline-dlib-vs-target.md`](baseline-dlib-vs-target.md).

**Option A** — the convention Mike chose on 2026-09-12 — says that where no rule
in the module predicts the missing bytes, they are transcribed from the object and
marked `!!! SOURCE COMPARE FIX !!!`. `tools/fillgaps.py` does it mechanically and
its guard is the measurement: it writes to `src/` only when `cmplmd370` calls the
module identical.

That guard has one blind spot, and until 2026-09-13 there was no way to see it.
**A transcribed byte always makes the comparison succeed — that is what
transcription is.** The guard proves the byte was copied correctly. It cannot
prove the byte was ever in IBM's source.

## The control that now exists

IBM shipped the same CSECT in two libraries, link-edited independently.

> **If both libraries hold the same byte at that offset, the byte came from
> IBM's source. If they hold different bytes, it did not — and no single source
> can satisfy both.**

That is cheap, it needs nothing new, and it applies to every marked line in the
tree. Run over all 22 modules in `src/` that carry the marker, 152 lines:

| | modules | |
|---|---:|---|
| **identical against both baselines** | **14** | the transcription holds — both libraries agree |
| identical against the DLIB, no target counterpart | 2 | untestable, the control does not reach them |
| **identical against the DLIB only** | **6** | the two libraries disagree at exactly the transcribed offset |

So option A survives the control on 14 of the 16 modules it could be applied to.
That is the headline and it is a good result: the method is sound and the marker
is honest. **The six are where it went wrong, and one of them went very wrong.**

## `IKJEGMSG` — 100 transcribed bytes, 99 of them noise

A message table. `fillgaps.py` deposited **100 marked lines**, more than every
other module in the tree put together, and the module came back byte-identical to
its DLIB member. Measured against the target member:

| source | vs DLIB | vs target |
|---|---|---|
| Dave's archive text | 100 bytes differ | **1 byte differs** |
| our repair, 100 marked lines | **identical** | 99 bytes differ |

**Dave's untouched source was one byte from the chosen baseline, and the repair
moved it 99 bytes away.** The transcribed bytes are things like `40`, `F0`, `D5`,
`C5`, `E3`, `D9` — EBCDIC blank, `0`, `N`, `E`, `T`, `R` — sitting on alignment
fillers (`DC 0H'0'`) between message constants. The target member holds `X'00'`
there, which is exactly what the source produces.

Rebuilt from the archive text with **one** marked line, at `M0239 DC 0H'0'`
where both libraries do hold a byte and the target wants `X'40'`:

```
         DC    X'40'                         !!! SOURCE COMPARE FIX !!! 02010400
```

`cmplmd370` exits 0 against `CMDLIB(TEST)`. 100 marked lines became 1.

## `IKJEFF02` — the repair was the whole problem

`DC X'F321'`, one marked line. Against the target, **Dave's archive text is
identical** and our repair differs by 2 bytes. Nothing needed fixing; the module
was recovered before anyone touched it. The file is in
[`../work/src-pending/AOST4/IKJEFF02.ASM`](../work/src-pending/AOST4/IKJEFF02.ASM)
as a measurement, exactly as `IKJRBBCM` is.

**That is the third time this pattern has appeared** — `IKJRBBCM` against MVS/CE
on 2026-09-12, and now these two — and all three are the same shape: a repair
made against a reference, correct against that reference, and wrong against the
one the project ended up choosing.

## The three that were re-transcribed, and the trade is exactly symmetric

Here both libraries hold a byte and they hold **different** bytes, so this is a
choice of baseline and not a recovery. The marked line now carries the target's
value:

| module | statement | DLIB wants | target wants |
|---|---|---|---|
| `IKJEFE16` | `@EL01 BCR 15,@E` — a dead epilogue | `1859` | **`91D0`** |
| `IKJEFF50` | `DC 0F'0'` | `5910` | **`E008`** |
| `IKJEBEUN` | `DC 0D'0'` | `AA4770` | **`BC50E0`** |

All three now `cmplmd370`-identical against the target and each differs from the
DLIB by the same count it previously differed from the target. That symmetry is
the point: **one source, two objects, and the object bytes are not the same.**

## `IKJEFD35` — a length difference, and nothing to transcribe

832 bytes against the target's 848. A PTF added sixteen bytes of code that our
source does not have, so there is no filler to fill and no byte to copy. It stays
in `src/` — identical to the DLIB — and it is real maintenance work, not a
marker. `cmplmd370` reports no clusters at all for a length difference, so
`where.py` says so rather than printing an empty list.

## What is measured and what is interpretation

**Measured:** at the offsets where option A transcribed a byte, IBM's two
libraries agree 14 times and disagree 6. Where they disagree, no source reaches
both.

**Not measured, and it matters:** *why* they disagree. The obvious reading is
link-time or assembly-time buffer residue — pad bytes carrying whatever the
previous record held, which `IKJEGMSG`'s EBCDIC message fragments look exactly
like. But [`ds-holes.md`](ds-holes.md) established that **TK5's and MVS/CE's
distribution libraries agree on hole bytes 309 times out of 309**, so those bytes
are not random per link; they are deterministic given the same input object. Both
findings can hold at once — the DLIB and the target member were link-edited from
object decks assembled at different maintenance levels, so their buffers differed
— but that is a hypothesis and it is not tested here.

**The control does not depend on settling it.** Whatever the mechanism, a byte
the two libraries disagree about is not a byte IBM's source contained.

## `IKJEHREN`, and a conclusion the control withdraws

The same control corrects something the project had written down as settled.

`IKJEHREN`'s first CSECT differed from the DLIB in one byte at `0x23`, where IBM
had `X'F0'`. `X'F0'` is EBCDIC `'0'`, the preceding statement is a maintenance
stamp `DC C' UZ45173 08/27/85'`, and the conclusion drawn on 2026-09-12 was that
the stamp had lost its eighteenth character — established by assembling three
candidates and finding that `'0'` alone brings the difference to zero.

**TK5's target member holds `X'80'` at that offset.** `X'80'` is not a printable
EBCDIC character, so it cannot be the eighteenth character of anything. The byte
is the pad byte of `BRID DC 0H'0'`, IBM's two libraries disagree about it, and no
source contains it.

The three-candidate measurement is intact and still says what it said; what is
withdrawn is the reading. A printable byte was read as text because it *could* be
read as text. The second baseline is the thing that could tell the difference,
and it did so the first time it was asked.

## What was done about it

1. **`fillgaps.py` now scores against the chosen baseline** — the target member
   where the CSECT has one, the DLIB where it does not — and **refuses to deposit
   where IBM's two libraries want different bytes at the offset it is about to
   write**, unless `--accept-split` says otherwise. That is a new outcome class,
   `SPLIT`, and it is the one that would have caught `IKJEGMSG`.

   **Controlled against the six modules repaired by hand above, and it reproduces
   all six**: `IKJEGMSG` identical with one line, `IKJEFF02` already identical,
   `IKJEFE16`/`IKJEFF50`/`IKJEBEUN` `SPLIT` at the offsets found by hand
   (`0x12e`, `0x402`, `0x45d`), `IKJEFD35` nothing fillable.

2. **Re-run over all 65 TSO candidates** under the new guard:

   | | modules |
   |---|---:|
   | identical against the chosen baseline | **16** |
   | **`SPLIT` — the two libraries disagree at the byte** | **7** |
   | nothing fillable, or the fix was not enough | 41 |
   | already identical | 1 |

   The seven are `IKJEBEAE IKJEBEUN IKJEE100 IKJEFA21 IKJEFE16 IKJEFF50
   IKJEHREN`. Under the old guard every one of them would have been deposited as
   a recovery.

3. **The 562-module holes run has not happened yet**, which is luck rather than
   judgement: under the old guard it would have produced this class at scale, and
   the holes population is 96 % base-level — exactly where a maintenance
   explanation is least available and a residue explanation most likely.

4. **The 25 hand cases inherit the rule.** Where the two libraries disagree at the
   differing byte, the module is a baseline choice and not a repair. The marker
   text is IBM's own and is not being changed, so the record of which baseline
   each line was copied from lives in this document and in the commits.
