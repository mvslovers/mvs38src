# What is not waiting on Dave Kreiss' tape

2026-09-06, evening. The request for his built `PVTMAC`/`APVTMAC` blocks one
question: whether the 2,079 length differences are our own macro provenance or
genuine source gaps. That is a real blocker for *those* modules. It is not a
blocker for the project, and this is the measurement that says how much.

## Two thirds of the length differences do not depend on it at all

For every module whose section length differs, does its source actually invoke
one of the 319 macros we took from web mirrors?

| | Modules | |
|---|---:|---:|
| uses at least one mirror macro | 719 | 35 % |
| **uses none** | **1,360** | **65 %** |

**Those 1,360 cannot be explained by our macro provenance.** Whatever their
length difference is, we introduced no unknown into them. They are workable now,
and the list is in
[`../work/measurements/len_clean.txt`](../work/measurements/len_clean.txt).

**And a control that keeps the worry proportionate:** of the 572 modules that
came out **byte-identical**, 32 also use mirror macros. So the mirror set is not
uniformly at the wrong level — parts of it demonstrably produce identical object.
The enrichment is real (35 % against 5.6 %, roughly six-fold) and it justifies
the request; it does not justify treating every mirror macro as suspect.

## The 1,256 that do not assemble, by first cause

| First cause | Modules |
|---|---:|
| undefined operation code | 327 |
| undefined symbol | 299 |
| addressability error | 268 |
| **relocatable duplication factor** | **205** |
| **`DC/DS` type `S`** ([cc370#108](https://github.com/mvslovers/cc370/issues/108)) | **52** |
| **relocatable displacement with an explicit base** | **40** |
| **duplication factor using a forward symbol** (IFO231) | **23** |
| card consumed as a continuation | 16 |
| single cases (IFO158, symbol > 8 characters, …) | 26 |

Full table in [`../work/measurements/causes.txt`](../work/measurements/causes.txt).

### 79 of the 327 "missing macros" are not macros

`START` (51), `ISEQ` (25) and `REPRO` (3) are **assembler directives `as370`
does not implement**. They are counted as undefined operation codes because that
is what an unknown mnemonic looks like.

Together with the four gaps marked above, **399 modules fail first on something
`as370` could implement** — the largest single block in the failures, and it
needs no material from anyone.

### The rest of the missing macros

38 genuinely missing macro names. Twelve were found in the web mirrors and are
now in the corpus: `AMCBS` `ICBVARY` `IEZCTGPL` `IHADECB` `IHADVCT` `IHAEXLST`
`IHASHDR` `IHASPCT` `IKJEGSIO` `IKJOCMTB` `ISDAGSPC` `ISDAPSPC`.

**They unlocked 14 modules, not 327.** That is worth recording as a caution about
first-cause counting: most failing modules have several causes, and removing the
first exposes the second. Every number in the table above is an upper bound on
what fixing that cause yields.

26 remain nowhere, and four of them — `DFHCOVER`, `DFHFC`, `DFHPC`, `DFHSC` —
are **CICS** macros, which says something about what is in `MVSBLD/` that nobody
had noticed: not all of it is MVS.

## So the order of work while the tape is awaited

1. **The 589 that differ only in generated text.** Right length, real
   differences, no hole excuse — the recovery work proper, smallest cluster
   count first.
2. **The 1,360 length differences that use no mirror macro.** Not blocked, and
   the largest untouched pool.
3. **The `as370` gaps**, which belong to cc370 and are named above.
4. Only then the 719 that do depend on the macro question.

---

## How much of the remainder is still the assembler?

2026-09-06, late. After six `as370` defects were closed, 2,147 length and 433
text differences remain. cc370 asked the question that decides whether an eighth
round is worth it: **how many of those are still the tool, and how many are the
source?**

The discriminator is the direct comparison: assemble the same source with
`as370` here and with IFOX00 on MVS, and compare the decks. Where they agree,
the difference against the DLIB member belongs to the source or to IBM's
maintenance. Where they disagree, it is ours.

### Sample of 30, and it took three readings to get right

Thirty differing modules under 400 lines — twenty from the length bucket, ten
from the text bucket — assembled both ways.

**First reading: 16 of 30 differ**, so half the remainder is the assembler.

**Second reading**, after repeating twelve of the sixteen with `SYSPRINT` kept
instead of `DUMMY`: eight of them do not assemble cleanly on IFOX00 either, some
with 25 to 33 flagged statements. So most of the difference was neither source
nor tool but modules that fail on both.

**Third reading, and this one is right.** The dominant diagnostic was
`IFO035 QUOTES NOT PAIRED`, in almost every flagged module. The JCL that fed the
source to IFOX00 cut it with `cut -c1-71` — **which drops column 72, the
continuation column.** Every continued statement lost its continuation, and a
quoted string spanning two cards came apart. The correlation is exact:

| continuation cards | 0 | 1 | 2 | 4 | 5 | 8 | 10 | 16 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| diagnostics | 0–3 | 2 | 7 | 13 | 15 | 27 | 32 | 34 |

Repeated with the full 80-column record, **ten of the twelve assemble cleanly**.
`IFDMSG03` went from 34 diagnostics to none.

### The fourth reading, and the first one measured on equal footing

The third reading still compared unequal things. Locally `as370` sees eight
libraries; the MVS job saw four — and one of them was `SYS1.MACLIB`, the
**target** library with 742 members, where the local run uses `SYS1.AMACLIB`,
the **distribution** library with 566. Different macros on the two sides means
the comparison attributes nothing, exactly as it did for the truncated column.

All six distribution macro libraries exist on `MVSCE-EXP`. The matching
concatenation is:

```
//SYSLIB   DD  DSN=SYS1.AMACLIB,DISP=SHR
//         DD  DSN=SYS1.AMODGEN,DISP=SHR
//         DD  DSN=SYS1.AGENLIB,DISP=SHR
//         DD  DSN=SYS1.ATSOMAC,DISP=SHR
//         DD  DSN=SYS1.ATCAMMAC,DISP=SHR
//         DD  DSN=SYS1.APVTMACS,DISP=SHR
//         DD  DSN=IBMUSER.PVTMAC,DISP=SHR
```

`IBMUSER.PVTMAC` holds the 444 recovered macros, uploaded by FTP. With that, and
with the full 80-column record:

| | Modules of 30 |
|---|---:|
| **`as370` == IFOX00** — the difference belongs to the source | **14** |
| **`as370` differs** — a genuine tool gap | **11** |
| **IFOX00 flags it too, `as370` is silent** | **5** |

So the assembler still accounts for about **a third** of what remains, the source
for about half, and five modules of thirty are the class where **`as370` returns
0 on something the real assembler refuses** — cc370#140.

`IKJTTRM0 IEAVDSEG IEFAB4M5 IFDMSG03 IGG019OK IFDMSG61 IFFANA IGFPMRTM
BLSRCOHD IGFPTSIG IGG3HN` are the tool gaps; `IGG01945 IGCM510D IEDAYD IEDQWAA
IEDQE2` the silent-acceptance class, three to four diagnostics each.

### What this cost, and it is the lesson

Two of the three readings were wrong, and both times **my own pipeline delivered
less than it should and did not say so** — first the discarded diagnostics, then
the truncated column. The second was the more dangerous: it produced a coherent,
plausible finding ("a third category nobody had counted") that would have sent
the other session to open eight modules that have nothing wrong with them.

What caught it was noticing that one diagnostic, `IFO035`, dominated everything —
a *shape* in the data that no single measurement would have shown.

**When feeding fixed-format assembler anywhere, pass all 80 columns.** Column 72
is the continuation; 73–80 the sequence number, which the assembler ignores.
Cutting at 71 looks harmless and is not.

### Caveats on this measurement

- Only modules under 400 lines were sampled, so it is biased towards the simple.
- All thirty were re-run on equal footing for the fourth reading, so no module
  is left unconfirmed — but it took four readings to get there, and three were
  wrong.
- `as370` accepts what IFOX00 flags in at least some of these cases — that is
  cc370#133 in a wider form, and it is worth measuring on its own: **where
  `as370` returns 0 and IFOX00 does not, our pipeline records a clean assembly
  that is not one.**

## The eleven tool gaps, sorted by what they share

`as370` produces a different deck from IFOX00 for eleven of the thirty. They are
not one cause, and the byte counts are not comparable across the groups:

| Module | differing bytes | of those, base-register nibble | IFOX00 uses base 0 |
|---|---:|---:|---:|
| `IKJTTRM0` | **1** | 0 | 0 |
| `IGFPMRTM` | 5 | **5** | **5** |
| `IGFPTSIG` | 5 | **5** | **5** |
| `BLSRCOHD` | 31 | 0 | 0 |
| `IGG3HN` | 164 | 0 | 0 |
| `IEAVDSEG` | 35 | 5 | 2 |
| `IFDMSG61` | 12 | 2 | 2 |
| `IFFANA` | 213 | 37 | 13 |
| `IFDMSG03` | 548 | 53 | 22 |
| `IEFAB4M5` | 390 | 88 | 53 |
| `IGG019OK` | 566 | 96 | 21 |

**Four groups:**

1. **`IKJTTRM0` — one byte in 752**, same length, not a base register. The
   smallest isolated case in the whole set.
2. **`IGFPMRTM` and `IGFPTSIG` — five bytes each, every one a base-register
   nibble, and IFOX00 writes base 0 every time.** `D2 03 03 94` against
   `D2 03 43 94`: same displacement, but IFOX00 does not resolve through the
   `USING` at all. This is cc370#108's `S(0)` finding generalised from
   constants to instruction operands — only a *relocatable* expression goes
   through a `USING`; an absolute one is the displacement with base 0.
3. **`BLSRCOHD` and `IGG3HN`** — same length, no base nibbles, cause unknown.
4. **The six with a length difference**, where `as370` always emits **more**.
   `IGG019OK` has one section on IFOX00's side and **two** on ours — that is not
   a byte, it is a section too many.

> ⚠️ **The byte counts for group 4 are meaningless.** Once the lengths differ,
> everything after the first insertion is shifted and compares unequal; 566
> differing bytes is not 566 defects. Those need an analysis of the *first*
> divergence, not of the total. The counts are kept in the table only to show
> that they cannot be ranked against groups 1–3.

The sample material — the module list and the IFOX00 decks — is in
[`../work/measurements/ifox-sample/`](../work/measurements/ifox-sample).

### One of the eleven reduced to a single statement

`IEAVDSEG` differs from IFOX00 by 16 bytes, and they are all one macro
expansion. The source line is:

```
RECDERR  DS    0H
         ABEND X'C0D',,,SYSTEM
```

`as370` expands it to 24 bytes — `CNOP`, `B *+8`, `DC AL4`, `L 1,*-4`, `SLL`,
`SRL`, `SVC 13`. IFOX00 does it in 8. The macro is the same on both sides,
`ABEND` from `SYS1.AMACLIB`, so conditional assembly *inside* the macro decides
differently.

It is not the shared cause of its group: of the six modules that differ in
length, only this one uses `ABEND` at all. What they share is a direction —
`as370` always emits more.

### And a control that belongs in every deck comparison

**Two of the thirty decks did not belong to their module.** `IEFAB4M5`'s member
held `IEDQWAA`'s deck and `IGG019OK`'s held `IGG01945`'s — stale content from an
earlier run, because `SYSPUNCH ... DISP=SHR` only replaces a member if the step
actually punches. A step that fails leaves the previous deck in place, and
nothing says so.

The check is one line: **does the first section name in the deck match the module
name?** It caught both. Without it, `IGG01945`'s deck would have been cited as
evidence about `IGG019OK` — and it had already produced one false finding, an
empty `PC` section that looked like an `as370` quirk. With the correct deck,
IFOX00 emits that same empty `PC` section.
