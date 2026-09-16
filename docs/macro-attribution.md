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

---

# The same question asked of open code — 2026-09-14, late

`tools/opencode_families.py` over the 605 modules whose every differing byte is
open code: **4,972 clusters, and no family.**

The biggest `(our bytes, IBM's bytes)` cell covers **15 modules of 605**, and it
is `00 -> 40` on a `DC 0D'0'` — alignment fill, not a defect class. The next are
`00 -> 80` (14) and `0000 -> 4040` (13), the same thing. Below that it is a long
tail of singletons.

**So from here it is one module at a time, and that is now a measured statement
rather than a feeling** — the same instrument found four real macro families the
same day and rejected two false ones.

## What the population is made of

By the operation field of the owning statement, and by distinct modules:

| | clusters | modules |
|---|---:|---:|
| `DC`, a real constant | 696 | **159** |
| `DC`, zero duplication factor — **alignment fill** | 470 | 131 |
| `L` | 627 | 78 |
| `MVC` | 236 | 56 |
| `ST` | 504 | 47 |
| `TM` | 207 | 41 |
| `LA` | 323 | 40 |
| `OI` | — | 38 |

**Data, not instructions.** The largest single class is a constant somebody
assembled differently, which is exactly what option A was decided for.

And **alignment fill is 470 clusters across 131 modules, 9 % of the population.**
`cmplmd370` counts it as text — TODO.md's control list already says so — and it is
not a source defect. A module whose only differences are there is not a module
with a bug.

## A second date format, and six modules hanging on it

`asmdate_sweep.py` hunts `mm/dd/yy`, which is what `&SYSDATE` produces. It cannot
see this:

```
AHLVCOFF   ours 'AHLVCOFF  73.241'      IBM 'AHLVCOFF  79.137'
BLSRVPCP   ours 'BLSRVPCP  78.059'      IBM 'BLSRVPCP  79.288'
```

A Julian `yy.ddd` in the eyecatcher, and it **differs per module**, so it is a
constant in the source rather than the assembler's stamp — maintenance level
written into the module and left behind by whatever archive we have.

`tools/julian_dates.py`, over the 988:

| | modules |
|---|---:|
| decks carrying a `yy.ddd` date | **430** |
| the date matches IBM's, other bytes differ | 358 |
| the date differs **and** so does other code | 66 |
| **the date is the whole difference** | **6** |

The six are `AMDUSRF9`, `IEECB801`, `IEFAB820`, `IEFJCNTL`, `ISTCFCR2`,
`ISTZCF1B`, each one `DC C'<name>  yy.ddd'`:

| module | ours | IBM |
|---|---|---|
| `AMDUSRF9` | `76.352` | `78.272` |
| `IEECB801` | `75.325` | `77.235` |
| `IEFAB820` | `76.328` | `77.279` |
| `IEFJCNTL` | `76.190` | `80.261` |
| `ISTCFCR2` | `78.062` | `78.312` |
| `ISTZCF1B` | `78.100` | `78.265` |

**Not repaired**, and the reason is a marking question rather than a measurement
one — see TODO.md. That 358 of 430 already match is the control that says the
class is real and the archive is mostly at IBM's level here.

---

# The length-differing block, mapped — 2026-09-15

`macroattr.py` cannot see the 2,231 CSECTs that differ in **length**, 41.7 % of
the whole, because `cmplmd370` reports no clusters while the sizes differ.
`tools/lenattr.py` supplies what is missing: `seclocate.py` anchors our section in
the bound member and the alignment locates the insert or delete, and that offset
goes into the same listing attribution.

**Reach is the limit and it is stated rather than hidden.** `lenlist.tsv` covers
the modules within 64 bytes of IBM's length — **1,221 of the 2,231** — and
`seclocate` anchors most but not all of those.

| | modules |
|---|---:|
| mixed | 474 |
| **every length-changing run in open code** | **361** |
| not anchored | 281 |
| every run inside a macro expansion | 77 |
| no usable reference / no listing | 28 |

Owners, **by distinct modules** — the weighting that exposed `WTO` as a false
family, and it does the same job here: `LINE` owns 325 clusters and does not reach
the top eighteen, because they sit in a handful of `IFCE*` modules:

| owner | modules | | owner | modules |
|---|---:|---|---|---:|
| `<open code>` | 835 | | `GETMAIN` | 33 |
| `XCTL` | **107** | | `DEQ` | 32 |
| `IEDHJN` | **90** | | `SDUMP` | 30 |
| `MODID` | 46 | | `ESTAE` | 26 |
| `GSPACE` | 39 | | `MODESET` | 23 |
| `XCTLTABL` | 35 | | `LINK` | 22 |
| `FREEMAIN` | 34 | | `SAVE` | 21 |

**Two numbers are bigger than the equal-length map said.** `XCTL` is 107 here
against 31 there — the `IHBINNRB` family is more than four times what hand
analysis found. And **`IEDHJN` is 90**: those are `&SYSPARM` modules the sweep
could not prove a value for, still short their eyecatcher bytes, and they are the
population `sysparm-rest.tsv` describes from the other side.

`GSPACE` and `DSCAN` are real macros not seen before. **`LSTART` is not a macro in
the path at all** — an attribution artefact, and a reminder that a name in this
column is a hypothesis until the macro is found.

## The correction the control forced

An `insert` has no span of ours. The first version attributed it to `i1`, the
statement the missing bytes would **precede**, and on the control that turned
`IGCFK10D`'s missing `IEDHJN` eyecatcher into an open-code `LR` and the module
into a false `mixed`. The question being asked is *which expansion came up short*,
so an insert is attributed to `i1 - 1`, the statement it follows. With that,
`IGCFK10D` reads `IEDHJN` for the eyecatcher and `XCTL` for the other two, and its
verdict is `all in macro expansions` — which is the right answer for a module
whose both causes are macros.

## What the two maps say together

| | modules |
|---|---:|
| equal length, every differing byte in open code | 605 |
| length differs, every length-changing run in open code | 361 |
| **workable without a macro in the way** | **966** |

Against 281 the anchor cannot reach and 1,010 of the length block outside
`lenlist`'s 64-byte window, which remain unmapped.

---

# What is under the missing eyecatcher — the 136, re-mapped

`sysparm_sweep.py` derives a value for 136 modules and keeps none of them, because
`cmplmd370` does not exit 0: a **second cause** sits on top. Until now that second
cause was invisible, and for a reason worth stating — the modules are still
length-differing, so `cmplmd370` clusters nothing, and `lenattr.py`'s first pass
ran **without** their derived value, so every map named `IEDHJN` and stopped
there. `IEDHJN` owned a length-changing run in **90** of the length block, and 84
of those the sweep had already tried.

So the map was re-cut with the derived values applied — a trial table of proven
plus unproven, `SYSPARMS` pointed at it, the real table untouched.
`work/measurements/lenattr/the136-with-sysparm.tsv`.

**95 of the 136 were length-differing and could be re-mapped:**

| | modules |
|---|---:|
| mixed | 43 |
| **now equal length** — they leave this population entirely | 22 |
| every remaining run in open code | 17 |
| every remaining run in a macro expansion | 10 |
| not anchored | 3 |

And what is actually left once the eyecatcher is accounted for, by distinct
modules: `<open code>` **60**, **`XCTL` 41**, `IEDHJN` 11, `BLDL` 3, `DCB` 2,
`WTO` 2, `MODESET` 2.

**`XCTL` is the second cause in 41 of them.** The `IHBINNRB` family runs through
the whole TSO `IGC*10D` set and is by a wide margin the largest single blocker
under the eyecatcher.

**`IEDHJN` still owns a run in 11, which means the derived value is wrong for
them** — and the shape says how: six show a `replace +8` (`IEDAYL`, `IEDLUS`,
`IEDQWO`, `IGCFI10D`, `IGCFL10D`, `IGCT010D`, `IGG01934`), so IBM's expansion
emits eight bytes more rather than the two or four the sweep reads. That is a lead
the second pass does not cover and nobody has followed.

The 22 that became length-equal are now `macroattr.py`'s population and their
remaining difference is byte-level: `IEDQBH IEDQBL IEDQNT IEDSAI IGC0I10D
IGC0J10D IGC0K10D IGC0N10D IGCA710D IGCDD10D IGCFG10D IGCFK10D IGCFQ10D IGCVG10D
IGE0004G IGE0004H IGE0104G IGE0304G IGG019Q1 IGG019R6 IGG019TE IGG019TI`.

## `asmparams.py` reads the environment now

`gate.sh` writes `: ${ASMDATES:=…}` and `: ${SYSPARMS:=…}`, so both tables can be
overridden from outside. `asmparams.py` ignored that and a trial run could not be
made without editing the real table. It honours both now, which is what made this
measurement possible at all.

## The zsh trap, for the second time in one day

```sh
MODS=$(awk … )
for m in $MODS; do rm -f …/$m.lst; done      # ONE filename, 3 kB long
python3 tools/lenattr.py --only $MODS         # ONE argument, 0 jobs matched
```

`rm` said *File name too long* and the tool reported **0 modules** and exited 0.
TODO.md's control list has said *"in zsh a variable is not word-split, use
xargs"* since 2026-09-13. Write the list to a file and pipe it through `xargs`.
