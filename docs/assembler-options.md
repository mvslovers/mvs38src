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
