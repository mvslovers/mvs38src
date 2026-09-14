# `&SYSPARM` was empty in every assembly this project has ever run

> **In the gate, and the acceptance test passed: +111 / −0.**
> `gate.sh` reads `SYSPARMS` per module, the published figure is **1,602 of
> 5,353 (29.9 %)**, up from 1,491. Derived with `as370-main`, sha256
> `bdef7470…6146f` (`work/src-states/bin/PROVENANCE.txt`), 2026-09-14.

**111 modules are byte-identical to IBM's shipped object the moment the assembler
is given the `SYSPARM` IBM gave it.** No source change, no marker, nothing
deposited in `src/` — the source was already right and the instrument was not.
This is the `ASMDATE` class, one size larger.

Measured 2026-09-14 against the chosen baseline (TK5 target, DLIB where a CSECT
has no target counterpart), with `as370` at
`work/src-states/bin/as370-main` and the decks of `obj_overlay12`.

## The mechanism

`IEDHJN` is TCAM's module-identifier macro. 436 of our sources call it, and it
reads the assembler's `SYSPARM` option as data:

```
&HJA     SETC  '&SYSPARM'(1,4)
&HJB     SETC  '&SYSPARM'(5,4)
         DC    C'&NAME' .              MODULE IDENTIFIER
         DC    X'&HJA' .               DATE OF MODIFICATION
         AIF   ('&HJN' NE 'HJN').DATE
         DC    X'&HJB' .               HJN OF MODIFICATION
```

With no `SYSPARM` the substring flags `IFO117`, `DC X''` flags `IFO178`, and the
constant **emits nothing**. IBM's object carries two bytes there — four when the
caller passes `HJN`. So our CSECT comes out short and every displacement past the
eyecatcher is low by the same amount.

That is precisely what the length population looked like from outside:

```
IEDQA1   LENGTH differs: new 230, reference 232 (-2)     DIFFER
```

and **not one cluster**, because `cmplmd370` will not cluster sections of unequal
size. The whole class was invisible to the byte ranking by construction.

## Why it was missed for a day, and it was not the data

`seclocate.py` had already located the spot on 2026-09-13. The `+2` cell — 44
modules, 29 of them `IED*` — was inspected, found to "share a `replace` at offset
3 and diverge immediately after", and written off:

> Eight bytes, four bytes, two bytes are common **amounts** of missing code, not
> common causes.

The grouping was by *offset*, and the offsets genuinely do differ — `IEDQA1`
inserts at `0x000e`, `IEDQA2` at `0x000a`, `IEDAYY` at `0x000c`, because the
eyecatcher sits after however many bytes of prologue each module has. Grouped by
*what the inserted run is for* rather than where it lands, they are one family.
The sentence above is still true of the `+8` cell. It was never true of `+2`.

## The identity test, three ways

| | |
|---|---|
| `IEDQA1`, gate deck | `LENGTH differs: new 230, reference 232 (-2)` → `DIFFER` |
| `IEDQA1`, `IEDHJN` patched to `X'7033'` | **`IDENTICAL`** |
| `IEDQA1`, `as370 --sysparm=70330000` | **`IDENTICAL`** |

The middle row is how this was first measured, and it was the wrong way round:
`as370 --help` does not list `--sysparm=`, so the option was taken to be missing
and the value was injected through a patched copy of the macro on a private `-I`
directory ahead of `gate.sh`'s. That is exactly the hazard `macpath.py` exists to
prevent — a macro path that is not the gate's — and it survived only because
`docs/assembler-options.md` had already recorded the option as *"implemented,
undocumented, absent from `--help`"*. Both routes give the same 110. The
patched-macro route is gone from the tool.

## The partition of all 436

A win count on its own says nothing about what is left, so:

| | modules |
|---|---:|
| **identical once IBM's own `SYSPARM` is supplied** | **111** |
| a 2- or 4-byte insert found, still differs after it | 136 |
| length differs, no clean 2- or 4-byte insert | 167 |
| bytes differ, length equal | 18 |
| no usable reference | 4 |
| **identical today** | **0** |

**Nothing can be lost.** The last row is the one that matters and it was measured
twice, by two instruments that share no code: the sweep's own per-module
`cmplmd370` run, and `baseline-gate/overlay-vs-both.tsv`, where all 436 sit in
`len-differs` (362), `differs` (70) or `error` (4) and none in `identical`. A
per-module table can therefore only add. A *global* `SYSPARM` could not — it
would reach all 5,528 — which is why the value belongs in a table beside
`asmdate.tsv` and not in `gate.sh`'s pin.

## The acceptance test, and the control it needed

The `SCHEDULE` rule applies literally — compare the identical **sets** before and
after, never their sizes — and the first attempt at it was not a valid comparison.

Diffed against `obj_overlay12`, **118** decks moved where 110 were expected. The
eight extra were `IEFAB4F8 IEFAB4F9 IEFJACTL IEFJDIRD IEFJWRTE IGG019UN LINK
LOADGO`, and none of them has anything to do with `SYSPARM`: all eight are `src/`
repairs deposited at 20:45 on 2026-09-13, while `obj_overlay12` was cut at 18:21
and the overlay symlink tree rebuilt at 21:09. **The comparison base predated
eight source repairs** — the same eight TODO.md records as "measured, deposited
and uncounted".

So the run was made a second time as a proper control: the same source tree, the
same binary, the same date table, `SYSPARMS` pointed at an **empty file**. It
reproduces `rc0=4590` and `chosen=1491` to the module — the published figure —
which is what makes `SYSPARM` the only variable between the two deck sets.

| | control | with `SYSPARMS` |
|---|---:|---:|
| `rc 0` | 4,590 | 4,698 |
| decks whose hash moved | — | **110, every one in the table** |
| identical under the chosen baseline | **1,491** | **1,601** |
| identical to the DLIB | 1,516 | 1,626 |
| identical to the target | 1,341 | 1,451 |

**Gained 110, lost 0**, as sets and not as counts. `srccheck.py` still passes on
all 310 modules in `src/`.

The table was then re-cut with the second pass below and the whole sequence run
again: **gained 111, lost 0**, every gain in the table, `rc0=4699`,
**chosen = 1,602**. The control run is unchanged and is still the comparison base.

## The second pass, and why a right length with a wrong value is progress

`seclocate.py` anchors by agreement, and a weakly scored anchor lands the inserted
run in roughly the right place rather than exactly it. `IEDCSA` scored 90 % with a
margin of only 30 points over the runner-up, and the two bytes it reported were
`0010` where IBM holds `8117`.

But the first pass still assembles a deck of the **right length** with the wrong
value — and at equal length `cmplmd370` stops refusing to cluster. IBM's own bytes
are then readable at the exact offset:

```
IEDCSA   clusters=1   offset 0x000a   ours=0010   IBM=8117
--sysparm=00100000   DIFFER
--sysparm=81170000   IDENTICAL
```

So the sweep now feeds every 2-byte cluster back as a candidate half. It is the
same rule as before — the value comes out of IBM's object and is kept only when
`cmplmd370` exits 0 — applied to a measurement the first pass had to create first.

**It is worth one module, 110 -> 111**, and three more modules reach the same
value by this route that a later candidate reached by the first. The honest
reading is that the anchor was already good enough almost everywhere; this closes
the one case where it was not, and it costs nothing.

## The values

`work/measurements/baseline-gate/sysparm.tsv`, `module<TAB>sysparm<TAB>reference`.
They are per module and they repeat: `7033` in 21 modules, `6363` in 16, `7175`
and `7144` in 6 each, then a long tail of singletons.

**57 of the 111 carry an observable second half**; the other 54 are written
`0000` because their caller did not pass `HJN`, the macro never emits `&HJB`, and
**the bytes are therefore not measurable**. A recorded value that was never
measured would be the worst kind of number in this repository, so the placeholder
is visible rather than plausible. If one of those modules is ever assembled with
`HJN`, its second half becomes a real question again.

## The lever that does not exist: `IEDHJN` and `MODID` never meet

`MODID` emits the parameter as **plain text** — `DC CL9'&PARMC'` — so a module
expanding both macros would carry the same `&SYSPARM` twice in IBM's object, two
binary bytes and nine EBCDIC characters. That would settle the 53 unobservable
second halves and hand the 136 their value directly.

**It does not happen once.** Of the 436 `IEDHJN` callers, the number whose deck
also carries `MODID`'s expansion is **0**, and of the 111 proven modules likewise
**0**. The two macros serve disjoint sets — `IEDHJN` is TCAM, `MODID` is the
general MVS one. Recorded because it is the obvious next idea and it is dead;
`grep` for the macro name in the source says 101 modules mention both, and every
one of those is a comment. The measurement that counts is whether the expansion is
in the deck.

## `MODID` reads `&SYSPARM` too, and recovers nothing

`MODID` — `SYS1.AMACLIB` — takes the same option:

```
&PARMC   SETC  'R03700'
.CKPRM   AIF   ('&SYSPARM' EQ '').CKBR
&PARMC   SETC  '&SYSPARM'
.NOBR    DC    CL8'&LABELC'            MODULE NAME
         DC    CL9'&PARMC'             RELEASE OR PTF NUMBER
```

`CL9` is **length-neutral**, so this class is invisible to `lenlist.py` and shows
up only as differing bytes. 288 of our decks carry the default `R03700` where
IBM's object does not, and IBM's values are PTF numbers — ` UZ61918 `,
` UY35469 `, ` UZ18479 ` — or module-specific release strings like `ESC0R0200`.

It recovers **zero modules**:

| | modules |
|---|---:|
| length differs as well | 192 |
| the `CL9` differs **and** other clusters differ | 89 |
| already identical | 7 |
| **the `CL9` is the whole difference** | **0** |

Reported because "288 modules carry a wrong PTF number" reads like a recovery
class and is not one. It is still 9 correct bytes in 89 modules that need other
work anyway, and the PTF numbers are themselves evidence about maintenance level
— `IEAV1052` at `UZ61918`, `IEAVAD11` at `UY35469` — worth reading against
[`maintenance-level.md`](maintenance-level.md) rather than for recoveries.

## Two instruments that were wrong, and the controls that said so

- **`lenlist.py`'s docstring had the sign inverted.** The column is
  `ibm - ours`; the prose claimed a positive difference meant *our* CSECT was
  longer. Nothing downstream had used it — `what-is-left.md` states the correct
  direction — but an inverted sign turns a maintenance module into a Dave patch
  on sight. Corrected.
- **`grep -r` and `grep -R` both return zero over `work/src-states/overlay/`**,
  for any pattern, `CSECT` included. The tree is entirely symlinks (`overlay.py`
  writes them) and BSD grep 2.6 descends into none of them. The control that
  settled it: one directory holding a real file and a symlink to another real
  file, both containing the pattern — `-R` finds one. **Use a glob
  (`overlay/*.ASM`) or Python.** The first count taken here was "0 modules call
  `IEDHJN`", which is an artefact of the instrument and nothing else.

## The hazard this adds, and it is already live for `ASMDATE`

`SYSPARMS` **is** the second per-module assembly parameter living in
`gate-worker.sh`, and the first one has already drifted exactly the way
`macpath.py` was written to stop.

Twenty tools invoke `as370`. **Three know about `ASMDATES`** — `gate.sh`,
`gate-worker.sh` and `sysparm_sweep.py`. Ten hardcode the pin instead:

```
as370_messages.py  asmdate.py      asmdate_sweep.py  case_list.py  charfix.py
fillgaps.py        ifox_compare.py srccheck.py       where.py      worklist.py
```

`STAMP = dict(ASMDATE="09/07/26", ASMTIME="12.00")` — `fillgaps.py:60`,
`where.py:41`. So a module whose object carries its own assembly date is ranked,
repaired and *guarded* against a deck built with the wrong one.

**It costs nothing today, measured:** none of the 36 modules in `asmdate.tsv` is
in `src/`, so `srccheck.py` has no live failure, and exactly one of them appears
in `worklist16.txt`. It is a latent trap and not a present defect — and adding
`SYSPARMS` to the same one place would triple the exposure, because several of
the 110 will enter `worklist.py`'s and `fillgaps.py`'s reach for the first time
the moment their length stops differing.

The fix is the `macpath.py` fix: one module that returns the per-module
`(flags, env)`, and every assembling tool calls it. **Not done for the
parameters.** It *was* done for the deck directory, which had the same shape and
was already two generations stale — `tools/decks.py`, `CURRENT` and `CONTROL`.

## Reproducing

```sh
tools/sysparm_sweep.py --jobs 6          # -> baseline-gate/sysparm{,-rest}.tsv
tools/sysparm_sweep.py --only IEDQA1     # the control: must report 1 of 1
```

The sweep never guesses a value. `seclocate.py` anchors our section in the bound
member, the alignment names the inserted run, and only a run of exactly two or
four bytes becomes a candidate. A candidate is kept **only** when `cmplmd370`
exits 0 against the chosen baseline.
