# TSO first, SMP second — the two components that matter most

2026-09-12. Mike's priority, and it changes what "the work" means: **TSO is
where he intends to build his own development on top**, so its recovery is worth
more than its share of the module count. SMP is second, and it is the
maintenance vehicle the whole project design rests on.

Both profiled on the same instrument as everything else: the run-7 source state,
one pinned `as370`, against TK5's distribution libraries.

## TSO — `IKJ*` and `IKT*`, 228 modules in the reference corpus

| | modules | |
|---|---:|---:|
| **byte-identical** | **44** | 19.3 % |
| holes-only | 29 | |
| differs | 155 | |
| **`as370` disagrees with IFOX00** | **0** | |

**Not one tool case in 155.** Whatever is wrong in TSO is the source.

### And the shape is unusually favourable at the base level

| link year | open | identical | holes |
|---|---:|---:|---:|
| **1978** | 21 | **36** | 27 |
| 1979 | 17 | 1 | 0 |
| 1980 | 18 | 0 | 1 |
| 1981 | 7 | 1 | 1 |
| 1982 | 10 | 0 | 0 |
| 1984 | 10 | 0 | 0 |
| **1985** | **43** | 2 | 0 |
| 1986–89 | 29 | 4 | 0 |

**At base level TSO is largely recovered** — 36 identical and 27 holes-only
against 21 open. The problem is concentrated where IBM kept servicing it:
**43 open modules at 1985**, and a 29-module tail out to 1989 that is the
longest in the whole corpus ([`maintenance-level.md`](maintenance-level.md)).

By distribution library: `AOST4` 64, `ACMDLIB` 48, `AOST3` 42.

**22 differ at the same length**, which is the tractable shape, and the smallest
are very small: `IKJEFA42` and `IKJEFLLM` at **1 byte**, `IKJEFE16` and
`IKJEFLGH` at 2, `IKJEFL00` at 4.

## SMP — `HMA*`, 109 modules, and a different shape entirely

| | modules | |
|---|---:|---:|
| **byte-identical** | **19** | 17.4 % |
| holes-only | **0** | |
| differs | 90 | |
| **`as370` disagrees with IFOX00** | **0** | |

| link year | open | identical |
|---|---:|---:|
| **1978** | **1** | **11** |
| 1979 | 10 | 2 |
| 1980 | 10 | 0 |
| **1981** | **28** | 2 |
| 1982 | 7 | 0 |
| **1985** | **28** | 4 |
| 1986–87 | 6 | 0 |

**SMP's base level is essentially done** — 11 identical against 1 open at 1978 —
and everything open is maintenance, in two blocks: 1981 (28) and 1985 (28). All
90 sit in one distribution library, `AOS12`.

**And 82 of the 90 differ at the same length.** That is a far better shape than
`LPALIB`, where two thirds differ in length: same size and different content
usually means a patch rather than a rewrite. The smallest are `HMASMTSB` at
2 bytes and `HMASMDC1` at 6.

## Why these two are worth taking before the big libraries

`LPALIB` has 2,343 CSECTs and is 93 % unmarked by Dave — a body of work
([`lpalib.md`](lpalib.md)). TSO and SMP are **337 modules together**, both with
zero tool involvement, both already recovered at base level, and both with their
remaining work concentrated in two or three maintenance years rather than spread
across everything.

| | modules | identical | same-length differences | tool cases |
|---|---:|---:|---:|---:|
| TSO | 228 | 44 | 22 | **0** |
| SMP | 109 | 19 | **82** | **0** |
| `LPALIB` for contrast | 2,343 | 290 | 393 of 1,423 | 1 |

**SMP's 82 same-length differences are the single most tractable block found so
far**, and SMP is the vehicle the project's own design depends on — Dave built
the whole thing around SMP as the maintenance mechanism, and we have just spent
two days discovering that his chain cannot deliver 485 of his own SYSMODs
because of one statement SMP refuses.

## What has not been done

The per-module diagnosis. This says where the work is and what shape it has; it
does not say what any individual difference *is*. The next step on TSO is the
22 same-length cases, smallest first, because a 1-byte difference in a module
nobody has looked at is where a mechanism gets found — that is exactly how the
`^`/`¬` code-page substitution turned up and recovered ten modules at once.

---

## The first TSO repair: `IKJEHREN`, one character — 2026-09-12

Re-cut on the full 5,353-module reference: TSO is **256 modules, 50 identical
(19.5 %), 30 holes-only, 173 differing, 3 without a deck — and still zero cases
where `as370` disagrees with IFOX00.** 35 differ at the same length.

The two smallest were `IKJEFLLM` and `IKJEHREN`, one differing text byte each.

### What it was

`IKJEHREN`'s first CSECT differs in exactly one byte, at `0x23`: we emit `00`,
IBM has `X'F0'` — EBCDIC `'0'`. The source, and the marker on it is Dave's own:

```
265 |         B     BRID                BRANCH AROUND ID            @ZA01485 |
266 |         DC    C'IKJEHREN'         MODULE ID                   @ZA01485 |
267 |         DC    C' UZ45173 08/27/85'                             DSKC022 |
268 |BRID     DC    0H'0'                                            DSKC022 |
```

`C'IKJEHREN'` lands at `0x0A`–`0x11`, the stamp at `0x12`–`0x22` — **17
characters** — and `BRID DC 0H'0'` then aligns to `0x24`, padding `0x23` with
`00`. **Section lengths are equal**, so 17 characters plus one pad byte is as
long as 18 characters with none: the stamp is one character short and the
missing one is what IBM initialised `0x23` with.

### Measured rather than argued

Three candidates for the 18th character, assembled and compared against IBM's
object:

| 18th character | differing text bytes |
|---|---:|
| `' '` | 1 |
| `'5'` | 1 |
| **`'0'`** | **0** |

`DC C' UZ45173 08/27/850'`. It reads oddly and the object is not interested in
that. Deposited at [`../src/ACMDLIB/IKJEHREN.ASM`](../src/ACMDLIB/IKJEHREN.ASM),
one line changed, columns 73–80 untouched, 2,510 CRLF and no bare LF, byte count
unchanged at 205,820.

**What the object cannot tell us** is whether Dave's constant is one character
short or whether a following `DC C'0'` was dropped. Both produce the same bytes,
so both are consistent with the evidence and the source cannot be recovered
beyond the object's own resolution.

### What it is worth, stated exactly

| CSECT | before | after |
|---|---|---|
| `IKJEHREN` | text, 1 byte | **identical** |
| `IKJEHRN2` | holes, 4 | holes, 4 |
| `IKJEHRN4` | holes, 2 | holes, 2 |
| `IKJEHRN3` `IKJEHPDL` `IKJEHMSG` | identical | identical |

**The module does not become recovered.** Its verdict goes from `text` to
`holes`, because six bytes in two other CSECTs are still uninitialised where
IBM's object carries content — and [`ds-holes.md`](ds-holes.md) established that
those are real. One of eight CSECTs closed, and the scoreboard will not move.

---

## Four more, three recovered, and a boundary inside option A — 2026-09-12

`tools/where.py` turns the offset-to-statement hunt into a command, so these
went quickly. **The 35 same-length TSO cases are not one class**, and that is the
finding:

| shape | modules | outcome |
|---|---|---|
| a declared filler (`DS CL1`) in a data table | `IKJEFLLM` | **recovered** |
| a per-entry byte missing from a reconstructed table | `IKJEGSTA` | **recovered** |
| an alignment gap (`DC 0F'0'`) in a data area | `IKJEFF02` `IKJEFF50` | **recovered** |
| an alignment gap inside a **macro expansion** | `IKJEHREN` | not reachable from the module |
| a **different instruction** | `IKJEFE16` | option A would break it |

`src/` is now **38 modules, `srccheck.py` exits 0.**

### The three that worked

`IKJEGSTA` is the clearest. Its command-name table is Dave's own reconstruction
— the lines carry `DSKC128` in column 65 — and each entry is `X'nn'` length plus
the name. `ASSIGN`'s entry ends at `0x6c0`, so `DEFERNM DC 0H'0'` pads `0x6c1`,
and IBM's object has `X'20'` there; the same one byte after `TEST` is `X'59'`.
Two marked `DC X'..'` lines and the module is identical.

`IKJEFF02` and `IKJEFF50` are one 2-byte `DC 0F'0'` alignment gap each,
`X'F321'` and `X'5910'`. One marked line apiece.

### `IKJEHREN` cannot be fixed in its own source

Its remaining gap at `0x8d6` sits **inside the `STAX DEFER=NO` expansion**,
between the generated `B 20(0,1)` and `IHB0045 DS 0F`. There is no source line
to put a `DC` in front of — the statement is macro-generated.

And it is not a macro *level* problem either: TK5's `SYS1.MACLIB(STAX)` and
MVS/CE's `ATSOMAC(STAX)` are **byte-identical over columns 1–72**, same sha256.
So IBM assembled this module against a `STAX` that neither system now ships.
That is a macro-provenance case, and it belongs with the 319 mirror macros
waiting on Dave Kreiss' tape — not with the transcription work.

### The boundary that was not one — `IKJEFE16`, retracted

> **This section claimed option A would break `IKJEFE16`. It would not, and Mike
> caught the flaw in one question: would that not mean IBM's own module is
> already defective?** It would, and IBM shipping a module that never returns is
> not credible — so the assumption was wrong, not IBM. Kept below with the
> correction, because the reasoning error is the useful part.
>
> **`@EL01` appears exactly once in the whole listing: at its own definition.**
> Nothing branches to it. `IKJEFE16` is a message table — `PROC
> OPTIONS(DONTSAVE,CODEREG(0),NOSAVEAREA)`, and its body is 17 `DC C'...'`
> constants — and the `BCR 15,@E` is a PL/S epilogue on a module nothing calls
> into. It is the last two bytes of a data module and **it is never executed.**
>
> So IBM's `1859` there is not IBM's code either. Replacing the dead epilogue
> with `@EL01 DC X'1859'` makes the module **identical**, and breaks nothing,
> because there was nothing to break.
>
> **What survives of the distinction:** filling a gap is safe, and overwriting an
> instruction *that is executed* would not be. The error was asserting the second
> case without checking whether the instruction is reachable — one grep of the
> listing answers it, and it is now the check to run before calling anything a
> boundary.

### The original claim, for the record: `IKJEFE16`

Two bytes at `0x12e`: we emit `07FE`, IBM has `1859`. `07FE` is
`BCR 15,14` — **the module's return instruction**. `1859` is `LR 5,9`.

Option A says: write `DC X'1859'`. That produces byte-identity and **a module
that no longer returns.** The cost is not cosmetic here, and it is a distinction
option A was chosen without being shown:

- filling an **alignment gap or a declared filler** adds bytes the code never
  executes. Byte-identity gained, nothing broken.
- overwriting an **instruction** replaces executable code with data. Byte
  identity gained, the module broken.

`IKJEFE16` is left alone. Whether the second kind is also acceptable is a
question that has not been asked yet, and it should be asked with this example
rather than in the abstract.

---

## Automated, and the control earned its keep — 2026-09-12

`tools/fillgaps.py` does what the five hand cases did: find the statement that
owns each gap, put the object's bytes there with Dave's marker, **measure**, and
write to `src/` only when `cmplmd370` calls the module identical. The guard is
the measurement rather than the logic, so a wrong offset-to-statement mapping
cannot deposit a wrong file — it can only fail to produce identity.

### The control found two real bugs before a single module was written

Run first against the five already done by hand, where the answer was known:

1. **`DS CL1` must be replaced, not preceded.** It reserves a byte; inserting
   one in front of it makes the section two bytes longer. The symptom was
   `IKJEFLLM` coming back `text=0 holes=0` **and not identical** — a length
   change and nothing else.
2. **The owning statement is the greatest address at or below the cluster**, not
   the last row in listing order. Taking the last row put `IKJEGSTA`'s owner on
   an `SDWA` macro expansion in a different part of the module.

A third followed from the fix: an `ALIGN` statement carries pad bytes in the
listing — as370 prints `00` on the `DC 0H'0'` that pads an odd address — so pad
bytes must not disqualify it, while *real* bytes must. `IKJEFE16`'s dead
epilogue sits at the same address as a `DS 0H`, and preferring the `DS` inserted
two bytes and grew the section.

After that the control reproduces three of the five exactly — `IKJEGSTA` 2
lines, `IKJEFF50` 1, `IKJEFF02` 1 — and correctly declines the other two:
`IKJEFLLM` needs the `AL2`/`CL4` reasoning no tool can derive, and `IKJEFE16`
needs a reachability check before an instruction is overwritten.

### 17 of 60

| | modules |
|---|---:|
| **recovered** | **17** |
| a real instruction differs — a text difference, hand work | 25 |
| the gap is inside a macro expansion | 9 |
| the fix applied and was not enough | 6 |
| the owner is a `CSECT` or `ORG`, not a filler | 3 |

`src/` is **56 modules**, `srccheck.py` exits 0, all 56 hold 80-column records
with CRLF and no bare LF, and **152 lines across 22 modules carry the marker.**

`IKJEGMSG` took **100 marked lines** — a message table almost entirely made of
alignment fillers. `IKJEFA31` took 16. Thirteen took one line each.

### What the 43 say about where the work goes next

**25 are text differences at a real instruction or constant** — the largest
group, and none of them is fillable by definition. Those need the `IKJEFE16`
treatment one at a time: find the statement, work out what IBM had, check
reachability before overwriting anything.

**9 are macro expansions**, which is `IKJEHREN`'s class: not reachable from the
module's own source at all, and pointing at macro provenance rather than at the
module.
