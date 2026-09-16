# Assembler options: IFOX00, and what `as370` does with them

The option table below is from **Jay Moseley's** MVS/MVT assembler pages
(<https://www.jaymoseley.com/hercules/>), preserved here as work items.

`IEUASM` (Assembler F, MVT) and `IFOX00` (Assembler XF, MVS 3.8j) are **not the
same assembler**. Under MVS, `IEUASM` is an alias of the `IFOX00` load module —
confirmed on the running system: `AMBLIST LISTIDR` on
`MVSCE-EXP:SYS1.LINKLIB(IFOX00)` reports aliases `ASMBLR` and `IEUASM`, both
entering at offset `000008`. Assembler F does **not** recognise `ESD/NOESD`,
`FLAG(n)`, `LIBMAC/NOLIBMAC`, `MCALL/NOMCALL`, `SYSPARM(x)` or
`XREF(FULL)/XREF(SHORT)`.

**Our oracle is `IFOX00`**, so `IFOX00`'s list is the one that binds.

## The options

| Option | Meaning |
|---|---|
| `ALGN` / `NOALGN` | diagnose operands not on their natural boundary |
| `DECK` / `NODECK` | object deck to `SYSPUNCH` |
| `ESD` / `NOESD` | external symbol dictionary in the listing |
| `FLAG(n)` | suppress diagnostics below severity *n* and exclude them from the return code. Severities 0, 2, 4, 8, 12, 16, 20; `MNOTE` 0–255. Default `FLAG(0)` |
| `LIBMAC` / `NOLIBMAC` | embed library macro definitions in the listing before their first use, numbered as if they stood in the source |
| `LINECNT=nn` | lines per listing page, default 55 |
| `LIST` / `NOLIST` | the assembly listing |
| `MCALL` / `NOMCALL` | inner macro calls in the listing |
| `NUM` / `NONUM` | TSO: line numbers to `SYSTERM` |
| `OBJECT` / `NOOBJECT` | object module to `SYSGO` |
| `RENT` / `NORENT` | check for re-enterable code |
| `RLD` / `NORLD` | relocation dictionary in the listing |
| `STMT` / `NOSTMT` | TSO: statement numbers in `SYSTERM` diagnostics |
| `SYSPARM(x)` | up to 255 characters into `&SYSPARM` |
| `TERM` / `NOTERM` | TSO: progress and diagnostics to `SYSTERM` |
| `TEST` / `NOTEST` | `SYM` records for TSO TEST |
| `XREF` / `XREF(FULL)` / `XREF(SHORT)` / `NOXREF` | symbol cross-reference; `SHORT` omits unreferenced symbols |

### What IFOX00 actually accepts

Measured 2026-09-09 on MVSCE-EXP, one `ASMFC` step per option, each source
carrying a `*PROBE nn <option>` card so every listing identifies itself.

**All 33 forms above are accepted — not one raised `IFO258`.** That zero is a
real negative, not a silent scan: `PARM.ASM='WORKSIZE(1M)'` on the same system
*does* raise `IFO258 INVALID ASSEMBLER OPTION ON EXEC CARD -- OPTION IGNORED`
with CC 0016, so the diagnostic fires when an option is genuinely unknown.

Three refinements the table does not record, taken from IFOX00's own echo line:

- `ALGN` is an abbreviation — the echo prints `ALIGN`, and `ALIGN`/`NOALIGN`
  are accepted spellings too.
- `LINECNT=40` is accepted and echoes as `LINECOUNT(40)`; `LINECOUNT(40)` is
  accepted directly.
- IFOX00 has options beyond this table: its default echo line is
  `ALIGN, ALOGIC, BUFSIZE(STD), NODECK, ESD, FLAG(0), LINECOUNT(55), LIST,
  NOMCALL, YFLAG, WORKSIZE(2097152)`. `ALOGIC`, `BUFSIZE`, `YFLAG` and
  `WORKSIZE` are all accepted and none appears above.

Note that the echo line is not exhaustive — `LIBMAC`, `NUM`, `OBJECT`, `RENT`,
`RLD`, `STMT`, `TERM`, `TEST` and `XREF` are accepted without being echoed, so
absence from that line is not evidence of no effect.

## `as370` measured against it

Binary: `cc370` `main`, built in a detached worktree
(`git worktree add /tmp/wt-opt main --detach && make -C /tmp/wt-opt as370/as370`).

`as370` does not implement the MVS `PARM=` option syntax at all. Its interface is
Unix-style, and `--help` lists exactly:

    -- -m              accept any valid HLASM option (not yet implemented)
    -a[sub-options]    turn on listings   (e r g i m s x, =FILE)
    --help  -I dir  -o OBJFILE  -v

The full option parser is `as370/src/as370.c:5320-5347`: `--help`, `-v`,
`-o FILE`, `-d FILE` (accepted, no-op), `-I dir`, `--sysparm=TEXT`, `-m OPT`
(accepted, no-op), `--strict-cont`, `--`, `-E`, `-L`, `-a…`, and **anything else
becomes the input file name**.

### The headline: unknown options are silently swallowed

There is no "unrecognised option" diagnostic. A word `as370` does not know is
taken as the source file:

```
$ as370 XREF
XREF: No such file or directory          rc=16

$ as370 XREF t.asm -o p.obj
                                         rc=0   — assembles t.asm, XREF ignored
```

The second case is the dangerous one. `src` is simply overwritten by the last
non-option argument, so every MVS option name — `ALGN`, `NODECK`, `FLAG(4)`,
`LINECNT=40`, `RENT`, `XREF(SHORT)`, all of them, with or without a leading
dash — is accepted with **rc=0 and no message**, and has no effect. Anyone
porting a JCL `PARM` string to an `as370` command line gets silence, not an
error.

The control that makes this reading sound is the first case: run the same word
with no source file and it reports `No such file or directory` with rc=16,
proving it was parsed as a file name rather than as an option.

### Option by option

| Option | `as370` | Measurement |
|---|---|---|
| `ALGN` / `NOALGN` | **absent** | swallowed as file name, rc=0, no diagnostic |
| `DECK` / `NODECK` | **partial** | `-o FILE` writes the object; there is no `SYSPUNCH`/`SYSGO` distinction, so `DECK` vs `OBJECT` has no meaning |
| `ESD` / `NOESD` | **implemented** | `-ae` produces `EXTERNAL SYMBOL DICTIONARY`; default off |
| `FLAG(n)` | **absent** | swallowed; no severity filter, no effect on the return code |
| `LIBMAC` / `NOLIBMAC` | **absent** | swallowed |
| `LINECNT=nn` | **absent** | swallowed. The page length is the compile-time constant `A_SRC_LINECOUNT 55` (`as370.c:5162`) — it matches IFOX00's *default* but cannot be changed |
| `LIST` / `NOLIST` | **partial, default inverted** | `-a` turns the listing on, `-a=FILE` directs it. Default is **off**; IFOX00's default is `LIST`. With no `-a`, `as370` writes nothing at all (0 bytes on stdout and stderr) |
| `MCALL` / `NOMCALL` | **absent** | swallowed. `-am` is listed in `--help` as "macro and copy code source summary (not yet implemented)" and measurably does nothing |
| `NUM` / `NONUM` | **absent** | swallowed. No `SYSTERM` concept |
| `OBJECT` / `NOOBJECT` | **partial** | `-o FILE`; no `SYSGO`, and no way to ask for no object other than omitting `-o` |
| `RENT` / `NORENT` | **absent** | swallowed; no re-enterability checking |
| `RLD` / `NORLD` | **implemented** | `-ar` produces `RELOCATION DICTIONARY`; default off |
| `STMT` / `NOSTMT` | **absent** | swallowed |
| `SYSPARM(x)` | **implemented, undocumented, short** | `--sysparm=TEXT` works — `--sysparm=HELLO` assembles `DC C'&SYSPARM'` to `C8C5D3D3D6`. It is **not in `--help`**. It is **capped at 95 characters** (`scopy(g_sysparm, argv[ai]+10, 95)`, `as370.c:5329`); a 255-character value is truncated to 95, measured in the listing |
| `TERM` / `NOTERM` | **absent** | swallowed |
| `TEST` / `NOTEST` | **absent** | swallowed; no `SYM` records |
| `XREF` / `XREF(FULL)` / `XREF(SHORT)` / `NOXREF` | **absent** | swallowed. `-as` ("ordinary symbol and literal cross-reference") and `-ax` ("DSECT cross-reference") are listed in `--help` as not implemented and measurably produce nothing |

The `-a` sub-options measured directly, same source each time — 12 lines is the
bare source listing with no extra section:

| | lines | section produced |
|---|---:|---|
| `-ae` | 16 | `EXTERNAL SYMBOL DICTIONARY` |
| `-ar` | 15 | `RELOCATION DICTIONARY` |
| `-ag` `-ai` `-am` `-as` `-ax` | 12 each | none |

## Work items

Ordered by how likely each is to cost a real measurement.

1. **Diagnose unrecognised options instead of treating them as file names.**
   Everything else on this list is a missing feature; this one silently
   mis-parses correct input. A `PARM` string pasted onto an `as370` command line
   assembles successfully with every option ignored.
2. **Document `--sysparm=` in `--help`,** and raise its 95-character cap. IFOX00
   takes 255. (In practice the MVS `EXEC PARM` field caps the whole string near
   100 characters, so 95 is close to what can be passed *through JCL* — but
   `as370` is not invoked through JCL, and nothing in it enforces or explains
   the 95.)
3. **`FLAG(n)`** — it changes the return code, not just the listing, so a gate
   that compares return codes cannot express `FLAG` at all today.
4. **`XREF` / `XREF(FULL)` / `XREF(SHORT)`** — `-as` already has the slot.
5. **`LINECNT=nn`** — the constant is already isolated at `as370.c:5162`.
6. **`LIBMAC`, `MCALL`** — listing content; `-am` has the slot.
7. **`RENT`** — a real check, not a listing option.
8. **`ALGN`** — alignment diagnostics.
9. **`TEST`** (`SYM` records), and the TSO group `NUM`/`STMT`/`TERM`, which need
   a `SYSTERM` equivalent and may not be worth having off the mainframe.

`LIST/NOLIST` and `DECK/OBJECT` are deliberately excluded: `-a` and `-o` cover
them, and the inverted `LIST` default is a reasonable choice for a command-line
assembler rather than a defect. It is recorded above so nobody reads a missing
listing as a bug.

## What was not checked

- **`RLD`/`NORLD` was not discriminated on IFOX00.** The probe source
  (`TESTOPT CSECT / BR 14 / END`) contains no relocatable constants, so no RLD
  section appears either way. The option is accepted; whether it suppresses a
  section that would otherwise be there was not measured on the oracle. It *was*
  measured on `as370`, where `-ar` produces the section from a source that has
  RLD items.
- **`XREF(SHORT)` produced no cross-reference section on IFOX00** while `XREF`
  and `XREF(FULL)` did. That is consistent with `SHORT` omitting unreferenced
  symbols on a source whose only symbols are unreferenced, but it was not
  confirmed against a source with referenced symbols.
- **The TSO options were not exercised as TSO options.** `NUM`, `STMT` and
  `TERM` were submitted as batch `PARM` values and accepted; their `SYSTERM`
  behaviour was not observed.

---

## 2026-09-13: the pinned `ASMDATE` was marking 36 correct modules as wrong

`gate.sh` pins `ASMDATE=09/07/26` so a run is reproducible, and the comment beside
it says *"381 decks carry it"*. Carrying it is the problem. PL/S output routinely
stamps the assembly date into the module's own eyecatcher, so for those modules the
pinned date is simply **the wrong date**, and the module is reported as differing
from IBM's object over a value that was never in its source.

`BLSUSTAE` is the clean case — four differing bytes, every one a digit:

```
ours   f9 . f7 . f2f6   ->  0 9 / 0 7 / 2 6
IBM    f3 . f1 . f7f8   ->  0 3 / 0 1 / 7 8
```

Our source is right. IBM assembled it on **03/01/78**.

### How the date is decided, and why not by arithmetic

The stamp's position is known in the deck, the deck is card images,
`cmplmd370`'s clusters are section-relative, and the bound member has a third
layout. Mapping between those is what `where.py` got wrong once already. So
`tools/asmdate_sweep.py` does not compute an offset: it collects every
date-shaped byte sequence in the module's own object, assembles against each, and
keeps the one `cmplmd370` exits 0 on. 691 decks carry the pinned stamp, 15,095
assemblies, and **36 modules come back identical.**

`gate.sh` takes `ASMDATES`, a `module<TAB>mm/dd/yy` table, and `gate-worker.sh`
applies it per module. A module not in the table keeps the pin, so a missing table
changes nothing.

**1,445 -> 1,474 under the chosen baseline, `rc 0` unchanged at 4,590, control 0
disagreements.**

### This is not a source repair and must not be counted as one

Nothing was written to `src/`. The 36 modules were already correct; the instrument
was reporting its own pinned constant as their defect. The same is true of the
`ASMTIME` caveat already in `TODO.md` — one pinned time cannot match 38 modules
whose jobs ran at 29 distinct times — and that one is still open, because time is
harder: it is not in the object in a form this method can read.

**What is not claimed:** that 36 is the whole class. 691 decks carry the stamp and
655 did not come back identical, because a wrong date is rarely a module's *only*
difference. Every one of those 655 is now one difference closer, and they are in
`worklist.py`'s ranking with the date no longer on the list.

---

# Is there an option we do not know about? — 2026-09-16

The question Mike asked after `&SYSPARM` turned out to be worth 111 modules: are
there **other** assembler options, or global SET symbols, that IBM supplied and we
do not? Three measurements, and together they close the question.

## What a macro can even see from outside

Only three things: `&SYSPARM`, `&SYSDATE`, `&SYSTIME`. All three are handled —
`SYSPARM` per module since 2026-09-14, `ASMDATE` per module since 2026-09-13,
`ASMTIME` pinned and **unsolved** for 38 decks. Everything else a macro branches on
comes from its own call parameters or from global SET symbols.

## The nine wrong-level macros read no external global

Measured directly. `XCTL` declares `&IHBSWA` and `&IHBSWB` and **sets them
itself**; `IHBINNRB` declares `&IHBNO`, which is only an error-message number.
`SETFRR`, `GETMAIN`, `FREEMAIN`, `ESTAE`, `SCHEDULE`, `IEAPMNIP`, `TSCBD` and
`STAX` declare **no globals at all** and branch purely on their own operands.

`SGGBLPAK` — the SYSGEN global SET symbol package, which the starter tape's
stage-1 deck `COPY`s and which the tape itself does not carry — **we do have**, in
`work/macros/mvsce-2.1.4-dlib/AGENLIB`, and it is already on `gate.sh`'s path.
It is irrelevant here twice over: **no source in the tree `COPY`s it** (0 of
5,538), and **none of the nine reads any global it declares**.

So for these nine it is not a hidden switch. It is a different macro.

## What the starter tapes record, and what that proves

`SYS1.PROCLIB` on `START1`, read through its own PDS directory — 35 members, six
of which assemble:

```
ASMFC    //ASM      EXEC  PGM=IFOX00,REGION=128K                   <- no PARM
ASMFCL   //ASM      EXEC PGM=IFOX00,PARM=OBJ,REGION=128K
ASMFCLG  //ASM      EXEC PGM=IFOX00,PARM=OBJ,REGION=128K
ASMFCG   //ASM      EXEC PGM=IFOX00,PARM=OBJ,REGION=128K
ASMS     //A  EXEC  PGM=ASMBLR,COND=(4,LT),REGION=768K             <- no PARM
HASPASM  //ASM     EXEC PGM=&ASMBLR,PARM='DECK,XREF(SHORT)',REGION=256K
```

`ASMS` is the SYSGEN assembly proc — the one whose `SYSLIB` is the distribution
libraries themselves:

```
//SYSLIB  DD  DSN=SYS1.AMODGEN,DISP=(SHR,PASS)
//    DD  DSN=SYS1.AMACLIB,DISP=(SHR,PASS)
```

**and it passes no PARM at all.** `SYSPARM` appears **zero times** on either
volume, measured on the raw flat byte stream of all four tape files so nothing can
hide at a record boundary. `++JCLIN`: zero. No generated stage-2 JCL anywhere; no
SMP `ASM` entry recoverable from `SYS1.CDS`.

### The conclusion, and it is the useful one

We have **proved** IBM passed a per-module `SYSPARM` — 111 modules go
byte-identical when it is supplied, with values like `7033` and `SDC=VS2-R2`. The
customer-facing SYSGEN passes **none**.

**So the shipped object modules were not built by the customer SYSGEN.** They were
assembled in IBM's own build environment, with its own macro libraries and its own
PARMs, and no customer tape carries either. That is why every archive we find sits
at or before the base level and none runs in the direction we need.

**This closes the "search another tape" avenue.** What is left is reconstruction
from the object, and asking people who might have kept something IBM-internal.
