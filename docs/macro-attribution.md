# Where the differing bytes come from — macro expansion, or code we can edit

Three of the four investigations on 2026-09-14 ended at the same wall: a macro at
a level no surviving copy carries. `ESTAE`, `STAX`, `SCHEDULE`, `TSCBD` and
`IHBINNRB` are five of them, ≥35 modules sit behind them, and decision 5 makes
Dave Kreiss' macro libraries a precondition rather than a convenience. Nobody knew
how big that wall is.

**The listing already said it.** `as370` marks every macro-generated statement
with a `+` after the statement number, and `where.py`'s regex has been capturing
that column since it was written — into `m.group(4)`, which it throws away. The
measurement needed no new information, only the column nobody read.
`tools/macroattr.py`.

## The answer

**988 CSECTs differ at equal length or only in holes** — the population where
`cmplmd370` reports clusters at all:

| | modules |
|---|---:|
| **every differing byte in open code** | **605** |
| mixed | 293 |
| every differing byte inside a macro expansion | **90** |

So the macro wall is not what dominates this population. Two thirds of it has at
least some differing bytes in code that is ours to read and change.

## The macros that own the rest

Ranked by differing clusters in **generated text**, with holes shown separately —
`work/measurements/macroattr/text-vs-holes.txt`:

| owner | text clusters | modules | hole clusters | modules |
|---|---:|---:|---:|---:|
| `<open code>` | 12,931 | 558 | 3,453 | 477 |
| `IEAPMNIP` | 218 | 21 | 8 | 2 |
| `MODID` | 195 | **48** | 0 | 0 |
| `SETFRR` | 157 | 28 | 0 | 0 |
| `XCTLTABL` | 145 | **43** | 14 | 13 |
| `IECPDINI` | 99 | 4 | 7 | 3 |
| `XCTL` | 95 | **31** | 0 | 0 |
| `HMASMMGP` | 70 | 30 | 0 | 0 |
| `FREEMAIN` | 52 | 31 | 0 | 0 |
| `GETMAIN` | 46 | 21 | 0 | 0 |
| `WTO` | 42 | 11 | 139 | 40 |

**`MODID` at 48 modules and `XCTLTABL` at 43 are the validation.** Both were
measured by hand the same day, from the `&SYSPARM` side, and the tool found them
without being told they existed — 288 decks carrying `MODID`'s `R03700` default
and 174 carrying `XCTLTABL`'s `Y02080`. `XCTL` at 31 is the `±4` family, which
hand analysis had put at 11.

## Four defects, and every one of them changed the answer

The first ranking this tool produced was led by `WTO` with 45 modules. It was
wrong four times over, and the corrections are the reason the table above is worth
reading.

1. **The macro CALL is not in the address list.** `XCTL SF=(E,…)` generates no
   code of its own, so it has no address and never appears among emitting rows.
   Walking back through those alone named the previous open-code instruction:
   every cluster in the XCTL expansion came back as `LR`. The walk-back has to run
   in **listing order**, over every statement, emitting or not.
2. **The text field must not be left-stripped.** The listing preserves the
   source's own columns, so a leading blank is exactly what says "no label here",
   and that is how the operation field is found. Stripping it made the tool answer
   `SF=(E,OPCXCTL(ROPCAVT))` where the answer is `XCTL`.
3. **A line with no address can still carry an effective-address field.**
   `                            00001  1750+CVTSDTRC EQU   X'01'` was read as
   statement `00001`, leaving `1750+CVTSDTRC` as a macro name. Column indent does
   not separate them — the two fields sit one column apart — so the field itself
   has to be described in the pattern.
4. **A DSECT has its own location counter and it starts at zero.** Its rows
   therefore collide with the CSECT's addresses and the lookup takes whichever
   sorts last. The ranking that came out of that was led by `CVT` with 806
   clusters across 104 modules, then `IHAPSA`, `IECDSECT`, `IEFUCBOB` — **every
   one of them a mapping macro that emits no bytes at all.** Excluding DSECT rows
   moved the partition from 508/351/129 to 605/293/90.

And one that is not a defect but was read as a finding: **`WTO`'s 45 modules were
139 hole clusters against 19 in text.** Holes are `fillgaps.py`'s population and
were swept in September; ranking by raw cluster count was naming an answered
question. Text is emitted code, holes are reserved storage, and only the first is
a difference in what a module *does*.

## One question per family, asked and answered

For each owner: collect every **text** cluster it owns and group by
`(our bytes, IBM's bytes)`. A family with one cause shows one dominant cell; a
family that is really N unrelated modules shows N singletons. That is the test
that killed the `+8` cell and confirmed the `×`/`|` one.

**And every one of these was checked against `verdicts.tsv` first.** `IGCFK10D`,
`HMASMDRV`, `HMASMDSU`, `AHLREADR` and `IEAVNIPX` all carry `tool = identical`:
`as370` reproduces IFOX00's deck for each. **None of these is an assembler
difference**, which matters because three of the families differ in the same
way — an index register where IBM has a base, or the reverse — and that shape
invites exactly the wrong diagnosis.

| family | modules | answer |
|---|---:|---|
| `SETFRR` | 28 | **one cause, 75 % of them.** A different expansion outright |
| `GETMAIN` + `FREEMAIN` | 52 | **one cause, shared across both.** `ST R2,0(0,1)` against IBM's `ST R2,0(1)` |
| `XCTL` / `IHBINNRB` | 31 | the `±4` family, already on the wall |
| `IEAPMNIP` | 21 | **ours emits zeros where IBM emits instructions** |
| `MODID`, `XCTLTABL`, `IECPDINI` | 95 | `&SYSPARM`, measured, **0 recoveries** ([`sysparm.md`](sysparm.md)) |
| `HMASMMGP` | 30 | no shared cause — biggest cell is 1 module of 30 |
| `SETLOCK` | 10 | no shared cause — biggest cell is 3 of 10 |

`SETFRR` is the clearest and the most sobering. Ours:

```
LA  R12,32          AL R12,FRRSCURR(,R9)    CL R12,FRRSLAST(,R9)    BH  …
```

IBM's:

```
L   R12,FRRSCURR(,R9)   C  R12,FRRSLAST(,R9)   BE …   A R12,8(,R9)
```

Different instructions, different comparison, and an FRR stack entry of 8 bytes
where ours computes 32. That is not a level of a macro we have — and all three
surviving copies are byte-identical, `MACDATE 75295` on both of the two that carry
one.

**A grep said stben's copy differed and it does not.** Two different regexes were
used on the two files and only one of them could match `LA &R2,32(0,0)`; a
`diff` of columns 1–71 shows 167 identical records. Compare the files, not two
greps of them.

## What that leaves

| | modules |
|---|---:|
| touched by a blocked macro family (`SETFRR`/`GETMAIN`/`FREEMAIN`/`IEAPMNIP`/`XCTL`) | 112 |
| …of those, whose differences are **only** in macro expansions | **11** |
| touched by `HMASMMGP`/`SETLOCK`, which have no shared cause | 40 |
| touched by the `&SYSPARM` families | 95 |
| **no named macro family at all** | **755** |
| …of those, every differing byte in open code | **605** |

So the blocked families bind 112 modules but stop only **11** of them outright:
the other 101 have open-code differences as well and need that work regardless.
**605 modules are workable today**, with no macro in the way of a single differing
byte.

## Two limits, and the second matters more

It runs only where `cmplmd370` reports clusters, so the **2,231 length-differing
CSECTs are out of reach** — 41.7 % of the whole, and the largest single block.
`seclocate.py` would have to supply the mapping there, and that is a second tool.

And **open code is not the same as our problem.** `IGE0104G`'s one differing byte
is emitted by `OI SCBERR4,SCBCTLUN`, an ordinary open-code instruction — and the
cause is `TSCBD` shipping `SCBCTLUN` at two levels ([`sysparm.md`](sysparm.md)).
The byte is open code; the defect is a macro. So **`macro` is a lower bound on the
macro wall and `open` means "could be either"**, never "ours to fix".

## Reproducing

```sh
tools/macroattr.py --jobs 6      # -> baseline-gate/macroattr.tsv
tools/macroattr.py --only IGCFK10D   # the control: every cluster owned by XCTL
```

It assembles through `tools/asmparams.py`, which returns the per-module
`ASMDATE` and `--sysparm` that `gate-worker.sh` applies — added here because ten
tools hardcode the pin instead and this one must not become the eleventh.
