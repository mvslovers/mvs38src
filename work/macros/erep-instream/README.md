# `erep-instream/` — the EREP macros, lifted out of the modules that carry them

**Measured, not adopted.** These five are genuine and they land, and supplying
them recovers nothing. Kept as the record of that measurement.

`DSGEN`, `LINE`, `ROUTINE` come out of `MVSBLD/IFCE0135.ASM`; `SPECIAL` and `SUM`
out of `IFCEOAK1.ASM`. Both modules define their own macros in-stream, which is
the whole finding: the EREP family splits into modules that carry their macros
and modules that expect them, and `docs/missing-macros.md`'s list is the second
half. Jay Moseley's `MVSSRC.EREPSYM` carries `DSGEN` in 144 members and `LINE` in
145 — same story, more copies.

## Re-measured after cc370#237, and the first answer was wrong

**The first measurement of these macros was taken through a defect that made it
meaningless.** cc370#237: an `AIF` condition longer than **126 characters** was
cut mid-term, so a macro with a long multi-term guard took its error path
*whatever it was passed*. IBM's macros are full of long `AIF`s. "The macro does
not fit" was not a safe reading, and the table below is the honest one.

| | before #237 | after #237 |
|---|---:|---:|
| decks changed | 33 | **107** |
| modules reaching `rc 0` | 0 | **47** |
| **closer to IBM's shipped object** | **0** | **25** |
| further from it | 0 | **0** |
| byte-identical to IBM's object | 0 | **1** — `IEAVPIOI` |

`IEAVPIOI` goes `text` → `identical`: a module that now reproduces the object IBM
shipped, byte for byte, because the macros are on the path. Twelve `IECVX*`
modules go `length` → `text` or `mixed` — wrong size to right size with wrong
content, which is the transition that matters most.

**So the earlier conclusion — "they land and recover nothing" — is withdrawn.**
It was measured on an assembler that could not evaluate the guards, and it is the
clearest case this project has produced of an instrument defect inverting a
result rather than merely blurring it.

## What supplying them did before #237, for the record

Against `d81edda`, on the 31 modules that need `DSGEN`:

| | |
|---|---:|
| diagnostics, total | 5,980 -> **5,011** |
| `Undefined operation code - DSGEN` | 611 -> **0** |
| `- ROUTINE` | 398 -> **0** |
| `- BIN` | 531 -> **688** |
| `- LINE` | 611 -> **622** |
| `- HEX` | 160 -> **165** |
| decks changed | **33** |
| **closer to IBM's shipped object** | **0** |
| further from it | 0 |

**Two macros land and expose the need for three more.** `DSGEN`'s body calls
`BIN`, `HEX` and `LINE`, so resolving it produces *more* diagnostics for those —
the macro gap is a cascade, and the count of blocked modules understates it.

**Nothing moves toward IBM's object.** All 33 keep the verdict they had —
`length` or `unpaired`. This is `ISDAFSPC` again: a macro is usable when its
expansion is right, not when the assembly falls silent.

**And they must not go on the gate path.** IFOX00's reference decks were produced
without these macros, so `as370` with them is being compared against an IFOX00
without them: all 33 move *away* from IFOX00 by construction, 32 further and 1
closer. A macro can only be adopted on both sides at once — see
`docs/ifox-objections.md`.

## An anomaly I reported and then had to withdraw

I reported to cc370 that `IFCE0115`'s `LINE` calls resolve with this library alone
and stop resolving the moment `AMACLIB` is added. **It is not true.** Re-measured
with real argument vectors:

| configuration | `DSGEN` | `LINE` | `ROUTINE` |
|---|---:|---:|---:|
| this library alone | **0** | **0** | **0** |
| this library + `AMACLIB` | **0** | **0** | **0** |
| the eight gate libraries | 11 | 52 | 3 |
| the eight + this one | **0** | **0** | **0** |

`AMACLIB` makes no difference in either direction; the macros resolve wherever
this library is on the path.

**The false result came from a shell trap that is written down in my own notes.**
The ladder that "found" `AMACLIB` accumulated its flags in a variable —

```sh
ACC="$ACC -I $M/$d"
as370 $ACC ...        # zsh does not word-split: one argument, not two
```

zsh passes `$ACC` as a **single** argument, so no `-I` ever took effect and every
rung of the ladder measured the same thing. Worse, cc370#104 records that an
unrecognised option is silently taken as the source filename, so there was no
error to notice. The figures in this file's table above were taken from direct
command lines and from `gate.sh`, both of which pass a real argv, and they stand.

**Measuring a difference requires that the two runs differ.** A ladder whose
rungs are identical produces a clean-looking trend and means nothing.

## 2026-09-09: measured a third time, and the answer is that it cannot be measured here

The entry above says *"they are genuine and they land, and supplying them recovers
nothing."* The first version of that was invalidated by cc370#237. **This one was
taken through a shell defect**: the two `-I` flags sat in a variable, reached
`as370` as a single argument, and were ignored — so the run that "supplied" them
was the run without them. Written out explicitly, `IFCSI115` goes from a 480-byte
deck with `DSGEN LINE ROUTINE SPECIAL SUM` undefined to **1,680 bytes** with all
five resolved.

So they do land, and the honest question is what that costs. Gated tree-wide with
`EXTRA_MACS="-I work/macros/kreiss-smp -I work/macros/erep-instream"`, against the
same binary:

| | |
|---|---:|
| modules at `rc 0` | 4,573 → **4,600** |
| decks **closer** to IFOX00 | **1** |
| decks **further** from it | **106** |
| `DECK AND RC BOTH` | 5,403 → **5,339 (−64)** |
| `IFOX00 alone flags` | 4 → **28** |

**That is not a verdict on the macros. It is the `IHANVT` result at twenty times
the scale**, and `docs/ifox-objections.md` predicted it in as many words: a macro
adopted on the host side alone is measured against a reference assembled without
it, and the two sides seeing different macro libraries is the one inequality that
makes every difference unattributable.

**So the third answer is neither "they help" nor "they recover nothing": it is
that this question cannot be answered from the host.** Deciding it needs the
macros on MVS *and* the affected modules' reference decks re-made in the same
step — the recipe at the end of `ifox-objections.md` — and that replaces part of
the oracle, so it is a deliberate act, not a measurement.

The 27 modules that reach `rc 0` are the reason it is worth doing: they are the
EREP family, the largest single block left in `both flag`.
