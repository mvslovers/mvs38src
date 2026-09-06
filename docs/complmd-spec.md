# COMPLMD, read as the specification for cmplmd370

2026-09-06. Promised on [cc370#110](https://github.com/mvslovers/cc370/issues/110)
and possible since the tape can be read at member level. Source:
[`../work/utility/COMPLMD.asm`](../work/utility/COMPLMD.asm), 1,845 lines,
Dave Kreiss, first version 2015-06-06, nineteen revisions to 2017.

Everything below is from the module's own documentation and change log, not from
inference.

## The shape of the thing

**COMPLMD compares two load modules, not two object decks.** `OLDLIB` and
`NEWLIB` are load libraries; both members are brought in by a companion program
`LOADLMD` and then compared. `COMPLMD` = COMPare Load MoDule, literally.

```
//        EXEC PGM=COMPLMD,PARM='lmodname,csectname,...'
//OLDLIB   DD  DSN=SYS1.CMDLIB,DISP=SHR            the shipped one
//NEWLIB   DD  DSN=MVSSRC.BLD.CMDLIB,DISP=SHR      the rebuilt one
//DIFIN    DD  DSN=difference table,DISP=SHR
//DIFOUT   DD  DSN=additional differences,DISP=SHR
//DC       DD  DSN=generated DC statements,DISP=SHR
```

**This has a consequence for `cmplmd370` that is worth settling early.** Our side
is an `as370` object deck; the DLIB side is a load module. Dave's pipeline binds
first and compares load module against load module. Two options:

1. **Bind our deck with `ld370`, then compare load module against load module.**
   Dave's shape, and it reuses code that is already byte-validated.
2. **Compare deck text directly against load-module text.** Avoids depending on
   `ld370` reproducing IBM's layout, but the comparator then carries the
   difference between the two identity rules itself.

Option 1 is the lower-risk reading of the reference implementation. It is a
decision for the implementer, not something to leave implicit.

## The `DIFIN` format, exactly

A sequence of headers and difference records, fixed columns:

```
header       column 1     '>'
             columns 2-9  CSECT name
difference   columns 1-6  offset of the difference, hex
             columns 7-8  length of the difference, hex
```

Verbatim from the module:

```
//DIFIN    DD  *
>IEFBR14
00000201
>HASPACCT
00015C04
00016404
```

So `00015C04` is offset `X'00015C'`, length `X'04'`. `DIFOUT` is written in the
same format, and since v01.19 it **copies and merges the existing `DIFIN`** — a
reviewed run seeds the next one without hand-editing.

## What `CLEARRLD` is actually for

The question worth asking was not what it does but why it earns its place, and
the module answers it:

> CLEAR RELOCATABLE CONSTANTS OPTION. **Useful when load modules with multiple
> CSECTs contain CSECTs which are different in length.** This is default if
> CLEARRLD isn't specified.

It is about the **ripple**. If one section changes length, every section after it
moves, and every address constant pointing into them changes value. Without
clearing, a single length change produces a difference at every adcon in the
module and buries the real one. **The default is YES.**

That also explains why it is not merely a convenience for us: 9.9 % of decks
carry more than one section, and the DLIB member is a bound module where exactly
this ripple happens.

## The third mechanism, which the issue does not mention

There is a `DC` DD statement, added in v01.10:

> Optional data set containing assembler `DC` statements for all "new"
> mismatches which are zero. This is used for matching up `DS` statements which
> have random data during load module compare.

So COMPLMD does not only *tolerate* the `DS`-statement holes — it **emits the
source fix for them**. Where the rebuilt module has `X'00'` and the shipped one
has whatever the assembler left behind, it writes the `DC` statements that would
make the two agree. That is the mechanical half of what Dave's instructions
describe as "I attempted to update the source code to generate `X'00'` in those
holes".

For `cmplmd370` this is a `--emit-fill` counterpart to `--difout`: one records the
difference to ignore, the other proposes the source change that removes it.
Worth having; not worth blocking the first version on.

## The full parameter set

| | |
|---|---|
| 1st positional | load module name |
| 2nd positional | CSECT name |
| `NEWLMD=` | new load module name, defaults to the first positional |
| `OPTION=DETAIL\|SUMMARY` | detail is the default |
| `CLEARRLD=YES\|NO` | **YES is the default** |
| `OFFSET=` | CSECT offset, "used when multiple CSECTs are assembled in a source module" |
| `MAXERR=n` | stop reporting after n, default 10 |
| `LIST` | list the `DIFIN` ignore table |
| `RC=5` | report 5 instead of 4, so it stands out as a maximum condition code |
| `DEBUG=YES\|NO` | |

## What the change log says about where the difficulty was

Nineteen revisions over two years, and the pattern in them is the interesting
part:

| | |
|---|---|
| 01.02 | clear relocatable constants |
| 01.04 | change format of the differences |
| 01.07 | handle differences of different length |
| 01.09 | count differences that are `X'00'` in new |
| 01.10 | add DD `DC` for creating differences source |
| 01.12 | new longer than old, character formatting |
| 01.14 | add ignore table |
| 01.17 | add `DIFOUT` for any differences |
| 01.19 | copy and merge existing `DIFIN` to `DIFOUT` |

**Almost every revision is about the tolerance machinery, not about comparing
bytes.** Comparing is trivial; deciding what may be ignored, recording it,
carrying it forward and generating the fix for it is where two years went. A
`cmplmd370` that implements the comparison and treats `--difin` as an extra has
built the easy tenth of this.

## What still cannot be read from the source

How often `CLEARRLD` was the difference between a compare that closed and one
that did not. The source says what it does and why it exists; it does not say how
much of the work it carried. That question is with Dave Kreiss, in the mail of
2026-09-06.
