# The macros nobody here has

> ## ⚠️ Nine of the thirteen are now here — 2026-09-10
>
> | | |
> |---|---|
> | **found and installed** | `BTMHJN` `BTMIOBWA` `IECPDSCB` `$ASXB` `IEZCTGPL` `IHADECB` `IHADVCT` — and `LINEND` `HEX` `CONVT` `DSGEN` `LINE` `ROUTINE` `SPECIAL` `SUM` `IFCMACS` on the EREP side |
> | **still missing** | `ENTRIES` `ETEPILOG` `FREETAB` `SUMMARY` |
> | **found but the wrong macro** | `PROLOG` — every local copy takes no operands, every EREP caller writes `PROLOG NAME=` |
> | **still missing, unchanged** | `TABLE` (48 modules), `IQAERB`, and the single-module entries below |
>
> Where each one came from, and what it cost to establish, is in
> [`work/macros/found-2026-09-09/README.md`](../work/macros/found-2026-09-09/README.md)
> and [`work/macros/erep-instream2/README.md`](../work/macros/erep-instream2/README.md).
> **Two of the four "Group A" names were on this machine all along** and had been
> reported missing by a search that used exact names with no extension, over a
> scope that excluded the largest archive, with no control.
>
> **The four blocking the build are closed.** `EBT1102` and `EJE1103` apply again;
> `EDM1102` has its macros in place for the next run. That chain is in
> [`dave-install-log.md`](dave-install-log.md).

2026-09-07, measured against `as370` at the merge of cc370#174. **40 operations
cannot be resolved by either assembler, and they block 204 module–operation
pairs across the two source trees we build from.** Table:
[`missing-macros.tsv`](../work/measurements/missing-macros/missing-macros.tsv),
one row per operation with the module list.

> **Checked 2026-09-09 against `1112488`**: **204 modules still carry an
> `Undefined operation code` message**, so the headline has not decayed with the
> assembler's progress — the macros are missing from the libraries, not from
> `as370`. The *operation-level* breakdown below was not re-derived; treat the
> 40 as the figure of record and the module lists as indicative.
>
> The first attempt at that check reported **zero** operations, because the
> regex expected the operation name in a column that holds an aggregated
> message. A scan with no hits is a claim about the instrument until a control
> says otherwise; `grep -c` on the same file said 204 immediately.

This is a hunting list. Every one of these was searched for and not found — the
point of the document is that the searching is already done, so what is left is
to find the material somewhere else.

## 2026-09-08: the EREP macros are here after all — in the source, not in a library

**`DSGEN`, `LINE`, `ROUTINE`, `SPECIAL`, `SUM` and `LINEND` exist locally**, and
have all along. Not as members of any macro library — as **in-stream `MACRO`
definitions inside EREP modules that carry their own**:

| where | members defining `DSGEN` |
|---|---:|
| Jay Moseley's `MVSSRC.EREPSYM` | **144** |
| Dave Kreiss' `MVSBLD` | e.g. `IFCE0135`, `IFCE0155`, `IFCEOAK1` |

`IFCE0135` alone defines `BIN DSGEN HEX LABEL LINE LINEND LSTART ROUTINE` — eight
of the names on this list, in one member.

**The EREP family splits in two, and the list is the second half.** A module
either carries its macros or expects them; the 31 that need `DSGEN` are exactly
the ones that do not define it. Checked in both directions: none of the 125
module–operation pairs on this list defines its own macro, and the modules that
do define one are not on the list.

**The call shape matches.** `IFCE0115` — one of the 31 — calls

```
         DSGEN (RECTYP,8),(LEVEL,8),(FLAG1,8),(FLAG2,8)
```

and the prototype in `IFCE0135` is `&NAME DSGEN` with the body reading
`&SYSLIST(&OP,1)` — a macro with no declared operands, driven entirely by the
positional sublists. That is the macro these modules expect.

**What is not established** is the maintenance level. `ISDAFSPC` is the standing
warning: a macro is usable when its expansion is right, not when the assembly
falls silent. The test is the gate — supply it, and count modules that move
*toward* IFOX00, not modules that stop complaining.

## 2026-09-08, second sweep: 26,254 files, and Dave had already shipped the `IOS*` family

Every source collection scanned for **in-stream `MACRO` definitions**, not just
member names: `MVSBLD`, all nine datasets off `BLDMVS.AWS` (3,443 members,
extracted for this), `mvs38-ibmsrc`, Jay Moseley's 21 datasets, both web mirrors,
`ifox-src`, `lked-src`. **26,254 files.**

| | macros | module–operation pairs |
|---|---:|---:|
| **found** | **13** | **92 of 204** |
| still missing | 27 | 112 |

**The `IOS*` family was on Dave's own tape as SMP usermods.** `DSK0049` through
`DSK0058`, each a `++PTF(DSKnnnn)` carrying
`++MAC( IOSTRAP ) SYSLIB(PVTMAC) DISTLIB(APVTMAC)` and the macro body. He had
solved this part and shipped the answer; nobody had opened `SMP.LIB`. In
`work/macros/kreiss-smp/`, with `ILRAIA`, `IEAPPNIP`, `IECDCST` and eleven others
that came with them.

**A count corrected before it was reported.** Those libraries declare **2,329**
distinct macro names in `++MAC` elements — and **27 carry macro text**.
`FDM1133` is 17 KB, declares 73 macros and contains no `MACRO` card at all: the
text lives in RELFILEs that are not on this tape. Declarations are not a library,
and "391 names missing from our path" became **22**.

## `TABLE` is still missing, and a false hit is why that needs saying

`MVSSRC.SYM1-2(IGARPT01)` defines a macro called `TABLE`. **It is not this one.**

| | |
|---|---|
| Jay's `TABLE` | `&TABLE TABLE &A` — one positional operand, generates a 256-byte translate table from pairs |
| what the 48 `XTB*` need | `TABLE CGMID=(82),LOC=((40,00,0),(4B,0B,0),…)` — keyword operands |

Same name, different macro. The largest single entry on this list is unchanged,
and the near miss is worth recording: a name match is not a find.

## What was searched on 2026-09-08

| Searched | Result |
|---|---|
| Dave Kreiss' `MVT.ASM` (tape file 11, 3.27 MB) | **106 members, all of them modules, all 106 also in `MVSBLD`.** No macro of any name on this list, and no in-stream definition of one. |
| Jay Moseley's 21 datasets, **6,351 members**, by member name | no hit on any of the 40 |
| the same 6,351, by **in-stream `MACRO` definition** | `DSGEN` 144, `LINE` 145, `ROUTINE` 145, `SPECIAL` 81, `SUM` 79, `PROLOG` 2, `TABLE` 1 (the wrong one) |
| `mvs38-ibmsrc`'s 1,147 macros | no hit on any of the 40 |

`MVT.ASM` being 106 modules that all exist in `MVSBLD` is a **variant** finding
rather than a macro one: Dave carried a second copy of them, and whether the two
differ has not been measured.

## Where it has been searched

| Searched | Result |
|---|---|
| our eight macro libraries — `AMACLIB` `AMODGEN` `AGENLIB` `ATSOMAC` `ATCAMMAC` `APVTMACS` (566 + 288 + 243 + 100 + 139 + 242) plus Dave Kreiss' tape macros and the web mirrors, 1,822 members | not there |
| the IBM distribution tapes as extracted by the `mvssrc` sessions — 5,927 members, 615 macros | not there, except `ISDAFSPC` |
| `stben.net`'s maclib, 1,024 members; the HASP set, 181; `ext/`, 41 — 1,761 macros in total, searched by name **and** by prototype | not there |
| `mainframe.eu` | a proper subset of `stben`, nothing new |
| **`TABLE`, all five copies** | `IGARPT01` in `MVSBLD`, Jay, `mvs38-ibmsrc`, `stben.net`, `mainframe.eu` — **the same wrong macro five times** |
| **`PROLOG`, all eight copies** | `IEAVESC0`/`IEAVMWTO`, prototype `PROLOG` with no operands, where EREP calls `PROLOG NAME=` — **wrong one, eight times** |
| Dave Kreiss' own install tape, `NEW.ASM`, 848 members | not there |

Two independent derivations agree on the negative: ours from the module side,
the `mvssrc` sessions' from the manifest side.

## The list, largest first

| Operation | Modules | Where they are | Family |
|---|---:|---|---|
| **`TABLE`** (with `NAME`) | **48** | Kreiss' `NEW.ASM` | `XTB*` translate tables, all with a DLIB object |
| **`DSGEN`** | **31** | `MVSBLD` | EREP internals |
| `PROLOG` | 11 | `MVSBLD` | EREP |
| `LINE` | 11 | `MVSBLD` | EREP |
| `ROUTINE` | 10 | `MVSBLD` | EREP |
| `IQAERB` | 9 | `NEW.ASM` | |
| `IOSTRAP` | 8 | `MVSBLD` | IOS mapping |
| `IOSSIO` | 7 | `MVSBLD` | IOS |
| `IOSSCP` | 6 | `MVSBLD` | IOS |
| `IOSCPA` | 6 | `MVSBLD` | IOS |
| `SUMMARY` | 4 | `MVSBLD` | EREP |
| `IOSCKVOL` | 3 | `MVSBLD` | IOS |
| `DFHPC` `DFHSC` `DFHTC` | 3 each | `MVSBLD` | **CICS — out of scope**, those five modules are excluded |

The rest are single-module entries; the TSV has them all.

## What is worth knowing before searching

**The EREP family is one find, not five.** `DSGEN`, `PROLOG`, `LINE`, `ROUTINE`,
`SUMMARY`, `SPECIAL`, `FREETAB`, `BIN`, `HEX`, `CONVT`, `ENTRIES`, `ETEPILOG`,
`LSTART` all belong to the `IFCE*`/`IFCS*` error-recording programs and are
called by the same modules. Whatever library IBM shipped them in would bring the
whole set.

**`TABLE` is the single largest prize and it is not in `MVSBLD` at all** — the 48
modules that need it are `XTB*` translate tables on Dave Kreiss' install tape,
every one with a DLIB object to verify against. Three of them
(`XTB1GFC`, `XTB1GSC`, `XTB1GUC`) are already recovered because the IBM tape
happens to carry those three in expanded, macro-free form. The other 45 need the
macro.

**Two that were on this list are not any more, and both taught something.**
`IHANVT` and `UCBDADVC` no longer appear: with cc370#174 fixing a 63-character
clamp on operand fields, the modules that seemed to need them get far enough to
resolve them from a library we already had. Any earlier count of this list was
measuring `as370`'s truncated macro expansion, not the program. **A missing-macro
list is only as good as the assembler that produced it.**

**`ISDAFSPC` is on IBM's tape and is empty on purpose** — three cards with IBM's
own APAR marker `@Y30LB55`, a placeholder for a function this edition does not
build. Supplying it removes a diagnostic from 27 modules and changes no byte. It
is the one hit out of everything searched, and it is not worth much.

## What supplying one is worth

Nothing, by itself, unless the module then matches IBM's object. `ISDAFSPC` is
the warning: it resolves the diagnostic for 27 modules and leaves every one of
them exactly as wrong as before. The measurement to make after finding a macro is

```sh
tools/gate.sh /path/to/as370 <label>    # with the macro on the -I path
tools/retest.py obj_<label>
```

and the number that counts is modules reaching byte-identity with the DLIB
object, not modules that stop complaining.

## Seven more, found by the build rather than by an assembly — 2026-09-09

Every other entry on this list came from a module that would not assemble. These
six came from SMP: Dave's chain terminates the APPLY of `EBT1102` and `EDM1102`
with `SYSTEM UTILITY FAILURE`, and the IEBCOPY listing underneath says which
members it could not find.

| Macro | Wanted by | Anywhere we hold it? |
|---|---|---|
| `BTMHJN` | `EBT1102` (**BTAM**, not TCAM) | **nowhere** — `SYS1.ABTAMMAC` per IBM |
| `BTMIOBWA` | `EBT1102` (**BTAM**) | **nowhere** — same |
| `IECPDSCB` | `EDM1102` (DFP) | **nowhere** |
| `IEZCTGPL` | `EDM1102` | web mirror |
| `IHADECB` | `EDM1102` | web mirror |
| `IHADVCT` | `EDM1102` | web mirror **and MVS/CE's own `SYS1.MACLIB`** |
| `$ASXB` | `EJE1103` (JES2) | **nowhere** — not in `AMACLIB`, `MACLIB` or `HASPSRC` |

All six are absent from `SYS1.AMACLIB`, which is where the SYSMODs point
(`++MAC( ... ) TXLIB(OMACLIB)`, and `SYS1.PROCLIB(BLDSMP)` maps `OMACLIB` to
`SYS1.AMACLIB`).

**`IHADVCT` is the reason none of them should just be dropped in.** MVS/CE's
target `SYS1.MACLIB` has one and the web mirror has another, and they **differ in
11,648 of about 16,646 bytes**. Same name, unrelated levels. The rule at the top
of this file applies exactly: a macro is usable when its expansion is right, not
when the copy succeeds.

**And the counting is worth keeping.** SMP reported **161** failed copies across
the two jobs — 42 and 119. IEBCOPY had actually copied **1,047** members and
failed to find **6**: it returns 04 for the step, and SMP attributes the step's
return code to every element in it. An earlier note here repeated SMP's figure.
One missing macro reads as forty-two failures.

### Three of the seven are on IBM's own tape, and the pointer is what is wrong

Searched all **254 `MVSSRC.*` source libraries** on the SRC volumes — IBM's
distribution tapes as TK4- carries them:

| Macro | Found |
|---|---|
| `IEZCTGPL` `IHADECB` `IHADVCT` | **`MVSSRC.SYM601.F01`** |
| `BTMHJN` `BTMIOBWA` `IECPDSCB` `$ASXB` | nowhere |

`MVSSRC.SYM601.F01` is not an outside source. `SYS1.PROCLIB(BLDSMP)` already
mounts it, and Dave's own comment on the card says what it is:

```
//SYM60101 DD  DSN=MVSSRC.SYM601.F01,DISP=SHR              MACLIB
```

**And the same SYSMOD reads it 82 times without trouble.** `EDM1102` has 82
`++MAC` elements naming `TXLIB(SYM60101)`, all of which copy; the four that fail
are the four naming `TXLIB(OMACLIB)`, which `BLDSMP` maps to the running system's
`SYS1.AMACLIB`:

```
++MAC( IHADECB  ) TXLIB(OMACLIB ) SYSLIB(MACLIB  ) DISTLIB(AMACLIB ) .
```

So this is not a missing macro at all for three of them: **it is a pointer at a
library MVS/CE does not stock, for elements that are sitting in a RELFILE the job
already has open.** On Dave's TK3, `SYS1.AMACLIB` evidently carried them.

**Which copy is right is now answerable, and the web mirror is not the answer.**
Normalised to columns 1–72:

| | vs `SYM601.F01` |
|---|---|
| `IHADECB` mirror | **identical** |
| `IEZCTGPL` mirror | differs |
| `IHADVCT` mirror | differs |
| `IHADVCT` in MVS/CE's `SYS1.MACLIB` | differs from both |

Three copies of `IHADVCT`, three different levels. The tape is the one with the
same provenance as everything else in this build, so it is the one to use — and
the `ISDAFSPC` rule is satisfied by provenance rather than by hope.

### But supplying them does not unblock anything, and that is the finding

`EDM1102` also needs **`IECPDSCB`**, which is in none of the 254 libraries, none
of our eight macro collections, `mvs38-ibmsrc`, either web mirror, or Dave's
tape. `EBT1102` needs `BTMHJN` and `BTMIOBWA`; `EJE1103` needs `$ASXB`. All four
are absent everywhere reachable.

**So three SYSMODs cannot be applied from the material we hold**, and adding the
three findable macros changes none of that. What it does change is the shape of
the problem: it was "161 failed copies", then "seven missing macros", and it is
now **four macros that do not exist here** — one for TCAM, one for JES2, one for
DFP, and `IECPDSCB` unaccounted for.

Not yet searched: the CBT tape collections, and any other MVS 3.8 distribution.

## Which component each of the four belongs to — 2026-09-09, from IBM's own directory

The mailing-list search found no macro text, and produced something better: the
**MVS 3.8j Base Program Directory** and IBM's BTAM installation cookbook, which
say where each one lived. That turns four blind searches into four aimed ones,
and it corrected a claim of mine.

| macro | FMID | component | where IBM shipped it |
|---|---|---|---|
| `BTMHJN` `BTMIOBWA` | `EBT1102` | **BTAM** — *not TCAM, which is what I said* | `SYS1.ABTAMMAC`, merged into `SYS1.MACLIB` at install |
| `IECPDSCB` | `EDM1102` | Data Management | `EDM1102.F2`, an AMACLIB of 118 members |
| `$ASXB` | `EJE1103` | JES2 | `EJE1103.F1` is a **HASPSRC** library, *not* a MACLIB |

IBM's cookbook, verbatim:

```
++MAC(BTMHJN)   DISTLIB(ABTAMMAC) FROMDS(DSN(SYS1.ABTAMMAC) NUMBER(1))
++MAC(BTMIOBWA) DISTLIB(ABTAMMAC) FROMDS(DSN(SYS1.ABTAMMAC) NUMBER(1))
```

**Measured here as a consequence:** there is no `ABTAMMAC` or `BTAMMAC` on either
system, none in the build's own allocations, no BTAM DD in `SYS1.PROCLIB(BLDSMP)`,
and no `BTM*` member in any macro library we hold. So the search moves to
somebody else's complete `SYS1.MACLIB` — on a system where BTAM was installed,
the merge has already happened.

And Dave's own SYSMOD does not point at BTAM at all:

```
++MAC( BTMHJN   ) TXLIB(OMACLIB ) SYSLIB(MACLIB  ) DISTLIB(AMACLIB ) .
```

`DISTLIB(AMACLIB)` where IBM says `DISTLIB(ABTAMMAC)` — his reconstruction models
the post-merge state, which is consistent and worth knowing before anyone reads
that card as evidence of where the macro lives.

**`$ASXB` changes shape too.** A HASPSRC library is source, not macros, so it is
most likely a `MACRO` definition *inside* a HASP assembly member — the same shape
as `DSGEN` inside `IFCE0135`, and not something a member-name search would ever
find.

**And the eight of Group B change shape most of all.** `EER1400` is EREP and its
distribution files contain **no AMACLIB** — only object libraries, `APROCLIB` and
`AGENLIB`. So `LINEND CONVT HEX SUMMARY PROLOG FREETAB ETEPILOG ENTRIES` were
very likely never `SYS1.MACLIB` members: they are `COPY` members or in-stream
definitions inside the EREP source itself. That is exactly how `DSGEN`, `LINE`,
`ROUTINE`, `SPECIAL` and `SUM` were found, and it means the in-stream search is
the main line rather than the fallback.

Two named targets for it, from Dave Kreiss' own 2010 posts: **`EREPSY.F01`** and
**`SYM104.F06`–`F09`**, the two EREP source variants he was diffing.

---

## Correction, 2026-09-10: "found and installed" overstates it

Prompted by the cc370 session, which noticed that `gate.sh`'s `-I` path carries
`work/macros/mirror` but **not** `work/macros/found-2026-09-09`, and asked
whether the two sides of the gate could be using different macros. Measured, on
both sides at once:

| macro | in the oracle's `IBMUSER.PVTMAC` (MVSCE-EXP) | on `gate.sh`'s `-I` path | oracle's copy equals |
|---|---|---|---|
| `IEZCTGPL` | yes, 286 records | `mirror` | **`mirror`** — not `found-2026-09-09` |
| `IHADECB` | yes, 904 records | `mirror` | `mirror` = `found` = TK5, all three |
| `IHADVCT` | yes, 203 records | `mirror` | **`mirror`** and TK5 — not `found` |
| `BTMHJN` | **absent** | absent | — |
| `BTMIOBWA` | **absent** | absent | — |
| `IECPDSCB` | **absent** | absent | — |
| `$ASXB` | **absent** | absent | — |

**The gate is not asymmetric, and that was the thing worth checking.** Where the
oracle has a macro at all it has the `mirror` copy, which is exactly what
`gate.sh` passes. Where it does not, `gate.sh` does not either. Neither side has
ever seen `found-2026-09-09`.

**But "found and installed" is wrong for these four.** `BTMHJN`, `BTMIOBWA`,
`IECPDSCB` and `$ASXB` were found and committed to `work/macros/found-2026-09-09/`
and **installed into nothing**: not into the oracle's `IBMUSER.PVTMAC`, not onto
the assembler's include path. A module that needs one still fails, on both sides
equally. Found is not installed, and the word did the work of the deed for a day.

`IEZCTGPL` is the sharper case. The provenance analysis above concluded the
`SYM601.F01` copy — now `found-2026-09-09` — is the right one and the mirror copy
is at a different level. **The oracle assembled all 5,528 modules against the
mirror copy.** That is not a defect in the recorded decks — they are a consistent
reference and `as370` is measured against them fairly — but it does mean the
reference embeds a macro level this project has itself argued against, and
changing it would cost a corpus re-run.

TK5 does not settle it: `SYS1.MACLIB(IEZCTGPL)` on TK5 is 300 records against
286 on both local copies, and matches neither. **A third level, not an
arbiter.** For `IHADVCT` and `IHADECB` TK5 agrees with `mirror`.

---

## Correction to the correction, 2026-09-10, later: the gate *is* asymmetric

The section above says "the gate is not asymmetric, and that was the thing worth
checking." **It is asymmetric, and I established the opposite by looking at the
wrong library.**

Mike pointed out that TK5 carries more macro libraries than the seven I had
compared. Enumerating instead of assuming turned up eleven on both systems — and
with them the actual answer.

**The oracle's SYSLIB is a concatenation and the first DD wins.** It begins
`SYS1.AMACLIB`; `IBMUSER.PVTMAC` is the **seventh and last**. I checked the last
one. `SYS1.AMACLIB` on MVS/CE holds all six macros, and its copies are the ones
in `found-2026-09-09`:

| macro | `SYS1.AMACLIB` (CE) equals | on `gate.sh`'s path |
|---|---|---|
| `IEZCTGPL` | **`found-2026-09-09`** — not `mirror`, not `PVTMAC` | `mirror` — **different** |
| `IHADVCT` | **`found-2026-09-09`** — not `mirror` | `mirror` — **different** |
| `IHADECB` | `found` = `mirror` = `PVTMAC`, all the same | `mirror` — same |
| `BTMHJN` | `found` | **absent** |
| `BTMIOBWA` | `found` | **absent** |
| `IECPDSCB` | `found` | **absent** |

And the local macro tree is short by exactly those six:

```
AMACLIB   live 572   local 566   missing: BTMHJN BTMIOBWA IECPDSCB
                                          IEZCTGPL IHADECB IHADVCT
AMODGEN, AGENLIB, ATSOMAC, ATCAMMAC, APVTMACS   complete
```

**Six of 2,326 macro members are missing from the copy, and they are precisely
the six that four agents spent a day hunting for across GitHub, bitsavers,
Archive.org and the mailing lists in September.** They were in `SYS1.AMACLIB` on
our own systems the whole time. The provenance analysis that picked
`SYM601.F01` over the mirror copy was right, and `found-2026-09-09` *is*
`SYS1.AMACLIB` — which is why it was right.

### What the asymmetry is worth, measured — and my first figure was blind

Eighteen `MVSBLD` modules name `IEZCTGPL` or `IHADVCT` in their own source.
Assembled with the `AMACLIB` copy ahead of `mirror`, compared with the project's
own `ifox_compare.compare()` and the stamp pinned from `state.tsv`:

| | modules |
|---|--:|
| stays identical to IFOX00 | 17 |
| **loses identity** | **1** — `IGC018` |
| gains identity | 0 |

**The change costs one identity, not zero.** My first attempt at this figure
reported `0 / 0` and was measured with an instrument that could not see identity
at all: no stamp normalisation and no exclusion of the `END` card, so **all 18
came out "different"** — which should have been the tell, and was not. cc370
caught it by measuring the same thing properly.

`body()` in `ifox_compare.py` drops the `END` card entirely and truncates every
card at column 72. That is the fourth place today where **columns 73–80 decide
whether a number means anything**, after the macro comparison, the archive
source comparison, and the `AMACLIB` member counts.

### `IGC018` loses identity, and that is a finding rather than a regression

Separated one macro at a time:

| | `IGC018` |
|---|---|
| `mirror` only — today's gate | **identical** |
| `IHADVCT` swapped alone | **bytes** |
| `IEZCTGPL` swapped alone | identical |
| both swapped | bytes |

**`IHADVCT` is the whole effect and `IEZCTGPL` is none of it.**

Today's identity therefore rests on `as370` using a macro *the oracle did not
use*: `as370` + `mirror` agrees with IFOX00 + `AMACLIB`, and `as370` + `AMACLIB`
does not. Two divergences cancelling. cc370's reading, and it is the right one —
that is not identity, it is a coincidence hiding an `as370` defect. After the
correction `IGC018` belongs in `settled-against-as370`, not on a regression list.

### And the provenance claim does not hold for `IEZCTGPL`

cc370 compared the three copies byte for byte, columns 1–72:

| | `mirror` vs `found` |
|---|---|
| `IHADECB` | identical |
| `IEZCTGPL` | **one byte**, line 40 column 15 |
| `IHADVCT` | 204 lines against 197, **58 lines differ** |

```
mirror  *%IF CTGPL999 ^= ','      X'5E'
found   *%IF CTGPL999 ¬= ','      X'AC'
```

A **comment card**, and the difference is the NOT sign — transliterated one way
in one copy and the other way in the other. On MVS both are the same character.
So `mirror/IEZCTGPL` is not a different maintenance level, it is the same macro
down a different path off the host, and the measurement above confirms it: it
moves no deck. `IHADVCT` is a genuine content difference — one copy documents
`DVCBPSEC` and the other does not — and it is the one that matters.

`BTMHJN`, `BTMIOBWA` and `IECPDSCB` are named by no module in the corpus and
appear nowhere in `missing-macros.tsv`, so their absence costs nothing.

### What follows

Copying the six from `SYS1.AMACLIB` into `work/macros/` removes a confound that
should never have existed and moves no number. It **changes gate inputs**, so it
is a coordinated change with a re-gate, not a quiet edit — and the figure above
is what to expect from it.

What deserves keeping is the shape of the mistake: **I checked the last library
in a concatenation and reported on the first.** The correction above it, written
four hours earlier, is right about `IBMUSER.PVTMAC` and wrong about the oracle.

---

## The four cost 22 modules, and neither assembler can assemble them

2026-09-10, evening. Prompted by cc370's breakdown of the remaining divergence,
which set 19 `IFCE*`/`IFCS*` modules aside as EREP. They were right to set them
aside, and the reason is stronger than the family name.

**Both assemblers return rc 12 on all 22 modules that call one of the four.**

```
22 modules call ENTRIES, ETEPILOG, FREETAB or SUMMARY in their operation field
  18  as370 rc 12,  IFOX00 rc 0012,  decks differ in card count
   4  as370 rc 12,  IFOX00 rc 0012,  decks differ in bytes
  IFOX00 fails too: 22 of 22
```

So these are **not an `as370` defect**. The macros are absent from the oracle
system as well — not in `SYS1.AMACLIB` on either MVS/CE or TK5, not in
`IBMUSER.PVTMAC` on the oracle instance, and not defined in-stream by the modules
themselves (checked: `IFCE0115`, `IFCS0115`, `IFCE1017` define no in-stream macros
at all). Both assemblers produce a partial deck from a source they cannot
complete, and the two partial decks differ. That is all the divergence means.

**What that changes:** the four macros are worth **22 of roughly 110 remaining
divergent modules — a fifth of what is left**, and no amount of work on `as370`
recovers one of them. They are the single largest item on the list that is not an
assembler question.

**Where they are not**, established today rather than assumed:

| searched | result |
|---|--:|
| eleven macro libraries on TK5 and MVS/CE | not present |
| `IBMUSER.PVTMAC` on the oracle instance | not present |
| in-stream in the calling modules | none |
| TK5's CBT + source + SYSCPK download — 43,182 members over nine volumes | name collisions only |

The CBT hits are worth naming so nobody re-finds them: `CBT249.FILE032/ENTRIES`
is a general-purpose entry-point generator with the prototype
`ENTRIES &ENTPARM,&BRANCH,&REGNAME=,&MF=`, and it validates that a branch point
was supplied. Our modules call `ENTRIES PAGE` — one positional operand, no branch
point. Three `SUMMARY` members exist and ours is called `SUMMARY NAME=IFCS0115`,
a keyword form none of them takes. **Same name, different macro.**

Call forms, for whoever searches next:

```
ENTRIES PAGE            ETEPILOG                FREETAB
ENTRIES ,               ETEPILOG RLEN=70        SUMMARY NAME=IFCS0115
                        ETEPILOG NODUMP
```

Counted in the operation field from column 10, comment lines excluded:
`ETEPILOG` 22 modules, `ENTRIES` 14, `FREETAB` 6, `SUMMARY` 5. An earlier count
of 22 for `ENTRIES` was a regex that matched comment prose ("ENTRIES FOR NEXT
ROW").

**And not in the EREP source either.** `EER1400` ships no `AMACLIB` and Dave's
3,163-entry `++MAC` catalog lists none of the four, so the reasonable guess was
that they come with the EREP source itself. `MVSSRC.EREPSY.F01/F02/F03` are now
mounted on `MVSTK5-BLD` — **110 members across the three, and none of them is one
of the four.** Searched immediately after writing that sentence, and the sentence
is corrected rather than left standing.

So the four are absent from every library this project can reach: the eleven
macro libraries of two systems, the oracle's private macro library, the calling
modules themselves, TK5's full CBT and source download, and the EREP source
distribution. **Twenty-two modules are blocked on four macros that are, so far,
nowhere.**
