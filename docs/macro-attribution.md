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
| `SETFRR` | 28 | **one cause, 75 % of them.** A different expansion outright — and measured 2026-09-16 as a **two-level** macro, see below |
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

Different instructions and a different comparison. That is not a level of a macro
we have — and all three surviving copies are byte-identical, `MACDATE 75295` on
both of the two that carry one.

⚠️ **"an FRR stack entry of 8 bytes where ours computes 32" was written here and
it is wrong.** The `8` in IBM's `A R12,8(0,R9)` is `FRRSELEN-FRRS`, the
displacement of the entry-length field in the `IHAFRRS` header — `EMP 0`,
`LAST 4`, `ELEN 8`, `CURR 12`. **IBM's level reads the entry length out of the
header where ours hardcodes 32; the entry is still 32 bytes.** Caught by the
subagent that reconstructed the macro, not by the reading that produced the
sentence.

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

---

# 44 modules differ only in alignment fill, and nobody knows why

> ## ⚠️ Answered and inverted 2026-09-16 — and the worked case below does not reproduce
>
> **The bytes are not fill.** 338 differing bytes in 138 clusters, ours `00` in
> every one, IBM's with **114 distinct values**, 78 % printable EBCDIC; three
> clusters are 11, 14 and 16 bytes where a `DC 0D` pads at most 7; and for 47 of
> the 49, IBM's DLIB and target copies hold identical bytes in the same gaps, so
> they were in IBM's deck and not added at link time. **Alignment is the
> selection, not the cause** — a missing statement lands here only when its bytes
> fit inside a pad. Source fidelity, not assembler behaviour. Measured by the
> cc370 session; account in [`../TODO.md`](../TODO.md).
>
> ⚠️ **And `IGG019Q1` is not in `alignfill.tsv`.** Live it is *length-differs*,
> 964 against 968, failing `IFO117` at rc 8 on an empty `&SYSPARM`. The three
> bytes below need `--sysparm=03250000` from `sysparm-trial.tsv`, marked
> **`DERIVED-UNPROVEN`**. The case is real and its condition was never stated.


`tools/alignfill.py`. A `DC 0H'0'` has a duplication factor of zero: it emits
nothing and only moves the location counter to a boundary. The bytes in that gap
are fill, and `IGG019Q1` is **three bytes from identical** with all three of them
there:

```
000010 E4E9F3F4F6F6F4        DC    CL7'UZ34664'        seven bytes, ends 0x16
000017 00            START   DC    0H'0'               <- one byte of fill
000018 4140 1000             LA    R4,AVTEZERO(,R1)
```

Ours is `00` at `0x0017`; IBM's object holds `0C`. At `0x039A`, after a `BR R14`,
ours is `0000` and IBM's is `B25A`.

**44 modules differ in nothing else.** `IKJEHREN` is among them, and TODO.md
already knew about that one — *"the 'missing 0' is a pad byte; the target holds
`X'80'`, which is not printable"* — but the class had never been counted.

## Both obvious readings are refuted

**It is not the assembler.** 43 of the 44 carry `tool = identical` in
`verdicts.tsv`: `as370` reproduces IFOX00's deck exactly, so IFOX00 writes the
same `00`. The 44th is `BLSR3270`, already a `cc370` case.

**It is not an uncovered hole.** The deck's TXT card ranges were read directly
rather than through `deck_text()`, which cannot tell *covered with zero* from
*never defined*: `IGG019Q1`'s `0x0017` and `0x039A` are both **covered**, and the
section has **no uncovered gaps at all**.

So both assemblers deliberately write zero into the gap, and IBM's shipped module
holds something else. **Why is open.** That is the case to hand over — a question,
not a diagnosis — and it is worth up to 43 modules, which makes it the largest
single lever available without Dave Kreiss.

## The 22, and what each turned out to be

The 22 that became length-equal once their derived `SYSPARM` was applied, nearest
first:

| module | bytes | what it is |
|---|---:|---|
| `IGE0104G`, `IGE0304G` | 1 | `SCBCTLUN` — `TSCBD` at two levels, blocked |
| `IEDQNT` | 2 | `ST REG00,0(0,1)` → `0100`: the `GETMAIN` family, blocked |
| `IGG019Q1`, `IGG019R6` | 3 | alignment fill, above |
| `IEDQBH`, `IGC0J10D`, `IGG019TE` | 6 | mixed open code |
| the rest | 7–1,213 | |

Every one of the four nearest is a class already named. **That is the map working
as intended**: nothing here needed a new investigation, and three of the four are
blocked on something already recorded.


---

# `SETFRR` is two-level as well — 2026-09-16

Reconstructed and tried tree-wide, the same experiment as `GETMAIN`/`FREEMAIN`:
`work/measurements/macro-reconstruct/setfrr/`.

| | |
|---|---|
| gained | `AHLSBLOK ISTAPC56 ISTORFBQ ISTZFMFA` |
| **lost** | **33**, including `AHLMCIH` and `AHLTFOR` |
| chosen baseline | 1,608 → **1,579** |

## What the reconstruction actually is

Seven records, and it is not a patch but a coherent design change: **IBM's level
reads the entry length out of the `IHAFRRS` header and uses signed arithmetic
throughout where ours uses logical.**

```
104  CL -> C   &R2,FRRSEMP-FRRS(0,&R1)      delete path: is the stack empty
109  SL -> S   &R2,FRRSELEN-FRRS(0,&R1)     delete path: decrement
111  LA &R2,32(0,0)               -> L  &R2,FRRSCURR-FRRS(0,&R1)
112  AL &R2,FRRSCURR-FRRS(0,&R1)  -> C  &R2,FRRSLAST-FRRS(0,&R1)
113  CL &R2,FRRSLAST-FRRS(0,&R1)  -> BE PSALSFCC-PSA(0,0)
114  BH PSALSFCC-PSA(0,0)         -> A  &R2,FRRSELEN-FRRS(0,&R1)
117  AL -> A   &R2,FRRSELEN-FRRS(0,&R1)     replace path
```

`IHAFRRS` maps the header as `FRRSEMP 0`, `FRRSLAST 4`, `FRRSELEN 8`,
`FRRSCURR 12` — which is where the `8` comes from, and why the entry is still 32
bytes. **IBM's level emits no literal size at all.** The brief warned that
changing one occurrence of `32` and not another was a likely trap; it could not
bite, because `32` occurred exactly once in generated code and is gone, and the
`(32)` in the header comment is prose.

**Line 117 is not a guess**: `ISTAPC59` has a `SETFRR R` and its object shows
`55 → 59` at `0x188` and `5E → 5A` at `0x190` — the replace path's `CL` and
`.COMMON`'s `AL`, both confirmed independently of the add path.

## Four controls, and one of them is a prediction

- **The control reproduces the live measurement to the module**: 1,608 = 1,608,
  empty both ways. So the harness perturbs nothing and the −33 is the macro.
- **The edit reaches exactly what it should.** 239 of 5,538 decks changed; all 239
  are `SETFRR A/D/R` callers and **every** `A/D/R` caller changed. The three
  `P`/`F`-only callers (`IEAVEDS0`, `IEAVEEXP`, `IEAVESVC`) produce byte-identical
  decks, because the purge and flush paths emit no arithmetic.
- **Return codes and deck presence are identical in both sweeps** — `rc0 = 4,829`,
  5,538 decks — so no `LOST` entry is a transient failure.
- **The LOST list was predicted before the sweep ran.** Intersecting the 242
  `SETFRR` callers with the live identical set gives exactly those 33 modules. All
  33 lost; **none of the other 209 did.**

A side result worth keeping: control-vs-live is 0/0, so the 136 derived, unproven
`SYSPARM` values in `sysparm-trial.tsv` **move nothing on their own**.

**And this trial carried a control the earlier one did not**: the *unmodified*
`SETFRR` on the same prepended `-I` path with the same `SYSPARMS` reproduces the
live measurement exactly — 1,608, nothing gained, nothing lost. So the harness
itself perturbs nothing and the −33 is the macro. That control should be standard
for every trial of this shape from now on.

**The reconstruction is right where it applies.** `AHLREADR` goes from 23
differing bytes in 8 clusters to **8 bytes in 3, every one of them a `DS` hole** —
so all of its `SETFRR` bytes match IBM's.

**And the split is per module, not per component.** `AHLREADR`, `AHLTFOR` and
`AHLMCIH` are all GTF, `AHLREADR` and `AHLTFOR` are in the same library — and one
wants IBM's level while the other two are byte-identical with ours and break under
the trial. A per-caller census over 238 callers: **98 want ours, 22 want IBM's,
118 cannot be classified** (`levels.tsv`).

That is now three macros — `GETMAIN`/`FREEMAIN`, `SCHEDULE`, `SETFRR` — plus
`TSCBD`, measured two-level, with the split running **per module** each time. It
is not a component boundary, not a library boundary, and not a date. It is the
signature of modules assembled at different times against a macro library that
moved between them.

---

# `XCTL`/`IHBINNRB` — two levels as well, but the asymmetry is the other way

Third reconstruction trial. Unlike `GETMAIN`/`FREEMAIN` (3 : 18) and `SETFRR`
(4 : 33), this one **gains far more than it loses**:
`work/measurements/macro-reconstruct/xctl/`.

| | chosen | gained | lost |
|---|---:|---|---|
| control (macro byte-identical to the shipped one) | **1,608** | — | — |
| candidate 1 — insert the `EX` only | 1,616 | 9 | `IGCSW10D` |
| **candidate 2 — `EX` plus the base-form `LA`** | **1,621** | **14** | `IGCSW10D` |

Gained by candidate 2: `IGC0410D IGC0N10D IGCD510D IGCD710D IGCDC10D IGCFG10D
IGCI110D IGCM210D IGCM510D IGCMG10D IGCT110D IGCV310D IGCV710D IGCVG10D`.

**53 verdict changes, every one inside the 147-module `SF=(E,symbol)` population
and none outside it** — 14 to `identical`, **18 to `holes`**, **17 from
`len-differs` to `differs`**. The last 35 are the second-order gain: modules that
`cmplmd370` will now cluster, so `worklist.py` and `macroattr.py` can see them at
all. Going the other way: `IGCSW10D` `identical → len-differs`, and `IGG0197C`
`IGG0197D` `IGG0553E` `differs → len-differs`.

The base form is 133× `41f020cc` and once `41f03020`, in `IGCMM10D`; all 151 call
sites are in `AOS21`. `IGCFK10D` goes from 23 differing bytes in 13 clusters to
**2 bytes in 1 cluster, both in `DS` holes** — the expansion is IBM's byte for
byte, `41f020cc 44002020 0a07`, and the residual at `0x11a` is alignment residue
in the bound member rather than anything `as370` writes.

## Two levels, proven without the trial at all

Four modules, same statement, same construction, same library `AOS21`:

| module | source | IBM's bytes |
|---|---|---|
| `IGC0410D` | `XCTL SF=(E,OPCXCTL)`, `USING IEDQOPCD,ROPCAVT` | `41f020cc 44002020 0a07` |
| `IEDQCA` | `XCTL SF=(E,OPCXCTL)`, `USING OPCAVT,ROPCAVT` | `41f020cc 0a07` |
| `IGCFK10D` | `IEDQOPCD EQU 0`, `SF=(E,OPCXCTL(ROPCAVT))` | `41f020cc 44002020 0a07` |
| `IGCA110D` | `IEDQOPCD EQU 0`, `SF=(E,OPCXCTL(ROPCAVT))` | `41f200cc 0a07` |

**130 objects carry the `EX`, 21 do not**, over 151 non-register call sites. And
`IGCA110D` settles a second question at the same time: IBM emits the **index**
form there with **no `EX`**, from source identical to `IGCFK10D`'s, so the `LA`
form is part of the same split rather than a separate fault.

## What the reconstruction is, and what it is not

```
         LA    15,&SF(2)      LOAD SUP. PARM LIST
+        EX    0,32(,2)       TCAM HOOK BEFORE XCTL SVC
         AGO   .CONTA
```

**The operand is a literal, and that is the honest limit.** The `LA` takes its
`204` from `&SF(2)`; no expression over `&SF` yields `32`. `32` is `IEDQOPCD+32`,
the word `TOPCAVTD` carries as `DS A . UNUSED X03039`, and `2` is `ROPCAVT` in
every module of the family. **This is not a reconstruction of a general
`IHBINNRB` — it is the fingerprint of a TCAM-build-private macro**, and installing
it globally would put a TCAM hook into every `XCTL SF=(E,…)` in the tree. That it
costs only `IGCSW10D` is measured; that it is *right* for a non-TCAM caller is
not.

## A separate axis, measured but not yet tried

`IHBINNRB`'s `.ISAREGA` path, APAR `@ZA65467`: ours emits `LA 0,0(0,R)` +
`ST 0,0(0,15)`, IBM holds the single `ST R,0(0,15)`. **143 of our decks emit the
pair; IBM has the single `ST` in 138 and our pair in 1** (`IEFVFA`, and that one
is a `LINK`/SVC 6). `.ISAREGB`, the `DCB=(reg)` path, runs the **opposite** way:
42 of 65 IBM objects carry *our* pair and 2 the single `ST`. `.RFORM` has no call
sites in the tree.

That is its own trial with its own set diff. Bundling it with the `EX` would make
neither attributable.

## Controls

The control sweep — macro byte-identical to the shipped one, same everything else
— gives `chosen = 1,608` and is **set-identical** to
`baseline-gate/overlay-vs-both.tsv`, +0/−0. So `sysparm-trial.tsv`'s derived
values are not a confound and the difference is the macro alone. `IGC0410D` went
from `LENGTH differs −4` to `cmplmd370 IDENTICAL`, exit 0.

Four objects carry the `EX` but sit outside the source population and are excluded
rather than explained away: `IGCDM10D`, `IGCFR10D` and `IGCVK10D` have stub
sources with no `XCTL` at all, and `IGG01942`'s source uses the register form
`SF=(E,(15))`, which emits no `LA`.

---

# One CSECT in the target library has no name, and eighteen tools invent one

`org-tgt.txt` is read with `line.split()` by **eighteen** tools here —
`seclocate.py`, `macroattr.py`, `lenattr.py`, `baseline_gate.py`, `fillgaps.py`,
`worklist.py` and the rest. One of its 5,517 `INCLUDE` rows has a **blank CSECT
name**:

```
LPALIB   IGC0004{  INCLUDE   IGC0001D  0008FE 000000 0000000     7 fields
LPALIB   IGC0004{  INCLUDE             000032 000900 0002304     6 fields
```

`split()` collapses the empty field and shifts every later column left, so the
**length `000032` is read as the CSECT's name.** That phantom sits in all eighteen
maps.

**It is inert and it is still worth writing down.** Nothing in the tree is called
`000032`, so it never matches and never changes a verdict. What it does cost is
the real thing: **an unnamed control section of 8,964 bytes at offset `0x900` in
`LPALIB(IGC0004{)` is invisible to every instrument here**, because all of them key
on a CSECT name and it has none.

Found only because `tools/nosource.py` printed its corpus row by row instead of
counting it. A filter that drops awkward rows silently would never have surfaced
it — which is why that tool names its exclusions in a column rather than applying
them.

**Not fixed in the other seventeen.** One inert row does not justify editing
eighteen tools in a batch; it is recorded here so nobody rediscovers it, and
`nosource.py` skips six-field rows with the reason written at the skip.
