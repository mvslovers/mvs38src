# The private macros — where they are, and what they are worth

2026-09-05. Answers the open question from item 7 of [`TODO.md`](../TODO.md):
`TXLIB(SYM20104)`. It also raises the as370 assembly rate on the standing
150-module sample from **49 % to 73 %**.

## `SYM20104` is a DD name, not a data set on the tape

The `++MAC` elements in `MVSSRC.BLD.SMP.LIB` carry `TXLIB(SYM20104)`, and the
assumption was that `SYM20104` is a library somewhere on `BLDMVS.AWS`. It is
not. `MVSSRC.BLD.SMP.JCL` resolves it in one line:

```
//SYM20103 DD  DSN=MVSSRC.SYM201.F03,DISP=SHR   SOURCE
//SYM20104 DD  DSN=MVSSRC.SYM201.F04,DISP=SHR   MACLIB
```

`SYM20104` is the DD name for **RELFILE 4 of the IBM function SYSMOD SYM201**
(the Assembler XF; its `ASSEM(...)` lists name `IFOX0x` and `IFNXxx`). Dave
Kreiss had the IBM distribution RELFILEs restored on his own system. They are
**not part of the delivered package** — the tape holds 15 files and none of
them is a `SYM*` RELFILE.

Fifteen further TXLIB DD names appear the same way (`SYM10101`, `SYM60101`,
`ET110201`, …), plus six that resolve to libraries the installing system already
has (`OMACLIB`, `OMODGEN`, `OGENLIB`, `OTSOMAC`, `OHELP`) and one that is on the
tape: `DISASM` → `MVSSRC.BLD.NEW.ASM`.

**Consequence:** yesterday's fallback route — copy the tape to `mvsdev`, mount it
on `MVSCE-EXP` and let MVS run `$$$LOAD` — would not have produced these macros
either. It loads the same 15 files. There is no reason to touch EXP's config for
this.

## What the tape does give: the inventory

`MVSSRC.BLD.SMP.LIB` contains **1,888 distinct `++MAC` elements**. Split by the
distribution library they are ACCEPTed into:

| DISTLIB | Elements |
|---|---:|
| `APVTMAC` | **623** |
| `AMACLIB` | 554 |
| `AMODGEN` | 285 |
| `AGENLIB` | 245 |
| `ATSOMAC` | 71 |
| `AHELP` | 58 |
| `ASAMPLIB` | 52 |

`PVTMAC` / `APVTMAC` are **Dave Kreiss' own libraries**, not IBM ones. His
instructions say so plainly: *"PVTMAC and APVTMAC libraries were created and
contain macros which are in none of the distributed maclibs."* He put the
component-private macros under SMP control so the build could reach them.

Every element also carries its `ASSEM(...)` list — which modules have to be
reassembled when the macro changes. That is a macro → module map for the whole
system, and it is in [`../work/macinv.txt`](../work/macinv.txt).

## Coverage of the 623

Against the 1,269 macros extracted from a pristine MVS/CE 2.1.4
(`SYS1.MACLIB` + `SYS1.AMODGEN` + `SYS1.APVTMACS`):

| | Macros |
|---|---:|
| already present | 187 |
| **missing** | **436** |

The 436 split by TXLIB into two groups, and both turned out to be locally
available:

| Origin | Macros | Where |
|---|---:|---|
| `TXLIB(DISASM)` | 116 | `MVSSRC.BLD.NEW.ASM`, tape file 3 — **114 extracted** |
| IBM RELFILEs (`SYM*`, `ET*`, …) | 320 | 319 in the web mirrors, 1 (`ACCESS`) nowhere |

So 433 of 436 are recovered. They are in
[`../work/macros/tape/`](../work/macros/tape) and
[`../work/macros/mirror/`](../work/macros/mirror), kept apart on purpose: the
tape set has Dave Kreiss' provenance, the mirror set does not.

**Caveat on the mirror set.** These macros come from `www.stben.net` and
`mvssrc/mainframe.eu`; nothing establishes that they sit at the maintenance
level of our DLIB object code. They are good enough to answer *"does as370
assemble this"*. They are **not** good enough for a byte-identity verdict — a
macro one PTF older generates a different instruction sequence. Where the
comparison later disagrees, the macro level is a suspect before the module is.

Roughly 40 % of both sets are not `MACRO`/`MEND` definitions but COPY members.
That is what `PVTMAC` is: whatever the assembly needs and no shipped MACLIB has.

## Reading the tape at member level

`file370` parses this unload to zero members
([cc370#113](https://github.com/mvslovers/cc370/issues/113)), so
[`../tools/pdsunload.py`](../tools/pdsunload.py) does it. Two things had to be
got right:

**1. `tools/awsread.py` had the AWS flags backwards.** The Hercules definition is
`0x80` NEWREC (start of record), `0x40` TAPEMARK, `0x20` ENDREC (end of record);
the old reader had start and end swapped and treated `0x20` as the tape mark. It
still found the file boundaries (a tape mark has length 0) and the byte stream
was intact, so the greps done with it hold — but every record boundary it
reported was wrong. [`../tools/awstape.py`](../tools/awstape.py) replaces it.

**2. The unload's block header is 12 bytes**, and it is not the layout that
suggests itself:

```
Byte  6..8   TTR
Byte  9      key length   (8 for directory blocks, 0 for data)
Byte 10..11  data length
```

A header with data length 0 is the **end-of-member mark**, not the end of the
record — more members can follow in the same record. The directory TTRs are
those of the original PDS and do not match the ones in the data headers; the
assignment runs over the sequence instead: members appear in ascending directory
TTR, separated by the end marks. One end mark sits behind the directory and has
to be skipped, or every member gets its predecessor's text.

**Control case.** 527 of the 848 members of `NEW.ASM` also exist as files in
`MVSBLD/`. **438 are byte-identical.** The 89 that differ are real differences,
not reading errors:

- different maintenance levels (`BLSRSUMM`: `79.284` on the tape, `78.058` in
  `MVSBLD/`),
- different module states (`HMASMULI`: an `ESTAE` active on one side, commented
  out on the other),
- and one systematic one worth noting: **`MVSBLD/` was converted with a
  different code page than we use.** EBCDIC `X'5F'` reads as `^` there and as `¬`
  here — IBM-1047 against cp037. Same byte, different character. Our chain is
  cp037 in, latin-1 out, and stays that way; but a comparison across the two
  sources has to normalise this or it reports noise.

## The measurement

Same 150 modules from `MVSBLD/` as on 2026-09-04, same as370 build, per module,
exit code 0 counts:

| Macro set | Macros | Assembled |
|---|---:|---:|
| A `SYS1.MACLIB` + `AMODGEN` + `APVTMACS` | 1,269 | 73 (49 %) |
| B + the tape macros | 1,383 | 83 (55 %) |
| **C + the mirror macros** | **1,702** | **110 (73 %)** |

A reproduces yesterday's 73 exactly, so the two runs are comparable.
**No regressions:** no module that assembled under A fails under C.

The remaining 40, by first cause per module:

| First cause | Modules |
|---|---:|
| undefined operation code (still a missing macro) | 11 |
| addressability — no active `USING` | 11 |
| undefined symbol | 7 |
| relocatable duplication factor | 3 |
| `DC/DS` type `S` — [cc370#108](https://github.com/mvslovers/cc370/issues/108) | 3 |
| single cases (`START`, `ISEQ`, continuation, IFO158, IFO231) | 5 |

Missing macros are no longer the dominant cause. What is left of them is also
not one pool: `IHADECB` and `IEZCTGPL` are `DISTLIB(AMACLIB)` — they belong in
`SYS1.MACLIB`, and **our extract of it is incomplete**. 79 of the 554 `AMACLIB`
elements are missing the same way. `IHANVT`, `UCBDADVC` and `IECDCST` have no
`++MAC` element at all and are not accounted for yet.

## What follows from this

- The as370 gate is passed more clearly than it was: **73 %**, and the rest is a
  list of named, individually small causes rather than one blocker.
- **`SYS1.MACLIB` should be re-extracted** before more is read into the numbers.
  If 79 members are missing there, that is a defect in our extraction, not in
  MVS/CE.
- The mirror macros carry an **unverified maintenance level**. Before the first
  byte-identity comparison they have to be replaced by DLIB-level ones, or the
  comparison has to be able to name them as the cause.
- `tools/pdsunload.py` also opens `MVSSRC.BLD.UTILITY.ASM` (64 members,
  Dave Kreiss' utilities, `COMPLMD` among them) and `MVSSRC.BLD.SMP.JCL` (274
  members). Both were blocked behind cc370#113.
