# Paul Gorlinsky's IFOX00 source, measured against ours

2026-09-09. Jay Moseley distributes a reconstructed source set for the MVS 3.8j
Assembler XF, put together by Paul Gorlinsky in January 2007 from PTF object
decks and disassembled load modules. The question was whether that source
corresponds to the `IFOX00` our 5,528 reference decks came from.

**It does not, and the difference is measurable in both directions.** Gorlinsky's
source is at a *later* maintenance level than the assembler running on MVS/CE,
and it additionally carries two changes that are his own and were never IBM's.
The decks in `work/measurements/ifox-run/decks/` were produced by MVS/CE-EXP's
`SYS1.LINKLIB(IFOX00)`; that module is IBM's base level plus one TK4- usermod,
and it is not a build of Gorlinsky's tree.

## What was already here

`~/repos/mvs/ifox-src/ifoxdist.tgz` **is** Moseley's archive. Downloaded fresh,
its MD5 is `ddd13c5feaa83fe951f989d8eb35cb39` — the checksum in the release
notes, byte for byte. `ifoxjcl.tgz` also verifies
(`fe4320e6de3250d30878d08627e8c680`). Nothing had to be re-fetched, and the two
copies of the extracted source we hold are byte-identical to each other:

| Copy | Members | |
|---|---:|---|
| `~/repos/mvs/ifox-src/all/` | 111 | |
| `~/repos/mvs/mvs38-ibmsrc/ext/ifox-gorlinsky/` | 111 | identical, member for member |

All 111 are recorded in `MANIFEST.tsv` with origin `gorlinsky`. `ext/`'s README
says "111 members"; a directory listing appears to show 112 because `eza` prints
a header row. There is no missing member.

The `.het` tape holds 14 files. `tools/awstape.py` cannot read it — HET is AWS
framing with per-block zlib, and the reader has no decompression — so it was read
with a throwaway script that adds one `zlib.decompress` call. Nothing on the MVS
machines was touched to get at it.

| Tape file | Contents |
|---|---|
| 1 | the memo |
| 2, 3 | source, TAPE DUMP and VMFPLC2 |
| 4, 5 | listings |
| **6** | **IEBUPDTE, 37 ASSEMBLE members** |
| **7** | **IEBUPDTE, 74 MACRO/COPY members** |
| **8** | **IEBUPDTE, the update logs** |
| 9–14 | listings and the two disassembly sets |

File 8 is the one that mattered and had never been opened.

The memo describes 16 files and the reader found 14. Files 1–8 align with the
memo exactly — file 8's content and its 97-byte records match its `Update Logs`
row — and every claim below rests on 6, 7 and 8. Beyond that the numbering may
drift: the throwaway reader skips an empty file without incrementing its index,
so a double tape mark shifts everything after it. The 9+ rows are named from
their content, not from trusting the count.

## Member for member against the IBM tapes

Normalised to columns 1–72 with trailing blanks stripped and trailing empty
lines dropped — the IBM side is 80 columns CRLF, Gorlinsky's is 72 columns LF,
so the raw bytes cannot be compared directly. The result reproduces
`ext/ifox-gorlinsky/README.md` exactly (111 / 108 / 69 / 39), which is the
control on the normalisation.

**Identical to the IBM tape — 69:**

    CONTAINS CONTENTS DBV DCDSWORK DSW EVALWORK GENERR GENTAB GOIF GOIF1
    GOIF3 GOTO IFNX1J IFNX1K IFNX1S IFNX3B IFNX3K IFNX3N IFNX4D IFNX4E
    IFNX4M IFNX4N IFNX4S IFNX4T IFNX4V IFNX5C IFNX5F IFNX5V IFNX6C IFOX0E
    IFOX0G JCALL JCHECK JCSECT JENTRY JEXTRN JFIND JFRECORE JGEN JGENERR
    JGENIN JGETCORE JGETL JHEAD JINPUT JINST JMODID JNOTE JNOTELB JPATCH
    JPOINT JPOINTLB JPRINT JPUNCH JPUTL JPUTM JREAD JRELSE JRETURN JSAVE
    JTPRINT JTRUNC JWRITE OP SET TBLGEN XDCDS XEVAL XSTBL

**Differing — 39**, with the size of each difference and whether Gorlinsky's own
update log records it:

| Member | Tape file | Logged | IBM lines | Gorlinsky | Lines changed |
|---|---|---|---:|---:|---:|
| `IFOX0B` | ASSEMBLE | yes | 341 | 523 | 193 |
| `IFOX0D` | ASSEMBLE | yes | 710 | 798 | 96 |
| `IFNX6A` | ASSEMBLE | yes | 1563 | 1578 | 59 |
| `IFNX5M` | ASSEMBLE | yes | 1638 | 1677 | 47 |
| `IFNX2A` | ASSEMBLE | yes | 1970 | 1991 | 30 |
| `IFNX3A` | ASSEMBLE | yes | 2713 | 2721 | 19 |
| `IFNX1A` | ASSEMBLE | yes | 5292 | 5289 | 9 |
| `IFNX5D` | ASSEMBLE | yes | 1364 | 1370 | 8 |
| `IFOX0I` | ASSEMBLE | **no** | 356 | 362 | 6 |
| `IFNX5L` | ASSEMBLE | yes | 155 | 158 | 4 |
| `IFNX6B` | ASSEMBLE | yes | 1212 | 1212 | 3 |
| `IFOX0C` | ASSEMBLE | yes | 176 | 178 | 3 |
| `IFNX5A` | ASSEMBLE | yes | 1511 | 1513 | 2 |
| `IFOX0F` | ASSEMBLE | yes | 305 | 303 | 2 |
| `IFOX0H` | ASSEMBLE | yes | 352 | 352 | 2 |
| `IFNX5P` | ASSEMBLE | yes | 737 | 738 | 1 |
| `IFOX0A` | ASSEMBLE | yes | 440 | 440 | 1 |
| `IFOX0J` | ASSEMBLE | yes | 54 | 55 | 1 |
| `X5ERRL` | MACRO | **no** | 10 | 151 | 141 |
| `XFOUR` | MACRO | yes | 1164 | 1175 | 34 |
| `ICOMMON` | MACRO | yes | 264 | 271 | 9 |
| `GENOP` | MACRO | yes | 539 | 545 | 6 |
| `X5COM` | MACRO | yes | 229 | 233 | 5 |
| `GENCOM` | MACRO | yes | 182 | 185 | 3 |
| `JCOMMON` | MACRO | yes | 329 | 332 | 3 |
| `JERMSGCD` | MACRO | **no** | 293 | 294 | 2 |
| `BMDSECTS` `EDSECT` `ERMS` `JERRCD` `JFLEBLK` `JINCOM` `JOUTCOM` `JPARM` `JTEXT` `JTMTXT` `RSYMRCD` `RXLFMTS` `XDICT` | MACRO | `JPARM`/`XDICT` yes, rest **no** | | | 1 each |

702 lines changed in total.

**On Gorlinsky's side only — 3:** `IEZBITS`, `IEZIOB`, `IFOXMACS`. The memo
explains the first two: they are OS macros he had to include "because they are
not found in any of the CMS MACLIBs". They are not on the IBM *tapes*, but they
are in our corpus — `macros/maclib/`, from stben.net. `IEZBITS` is identical
there; `IEZIOB` is not (stben 1467 lines, Gorlinsky 628), which is the stben
mirror carrying a fuller version, not a maintenance difference in the assembler.
`IFOXMACS` is Gorlinsky's own and exists nowhere else. The README's "exists
nowhere else" is correct for `IFOXMACS` and too strong for the other two.

**On the IBM side only — none.** All 37 assembler modules (`IFOX0A`–`IFOX0J`,
`IFNX1A`–`IFNX6C`) are present in both sets. The module inventory is complete on
both sides; only content differs.

The IBM side here is the copy `mvs38-ibmsrc` *chose*, and 333 members have
competing tape versions kept in `variants/`. **None of the 111 does** — no
`IFOX*`, `IFNX*` or `IEZ*` member appears anywhere under `variants/tape/` or
`variants/stben/`, so no row above is a verdict against one arbitrary choice.
The first scan written for this returned zero because `variants/tape/` is nested
by tape name and the scan listed directories; the control caught it. Re-run
against all 526 variant files, `IDCCDEC` (a member known to be there) is found
and the 39 still return zero.

## The 39 explained — the README's open item is closed

`ext/ifox-gorlinsky/README.md` recorded 24 members carrying his `FX0000` marker
and **15 differing with no marker, "not been looked at one by one"**. The update
log on tape file 8 covers 34 of the 37 ASSEMBLE members and settles all of it.

- **25 of the 39 are logged changes.** Every logged member differs, and no
  identical member is logged — the correspondence holds in both directions, so
  the log is neither over- nor under-reporting.
- **The log covers ASSEMBLE members only.** 13 of the 14 unlogged members are
  MACRO/COPY, outside its scope entirely. That is a boundary in the log, not an
  undocumented change.
- **11 of those 13 differ by exactly one added line**, and it is always the same
  line: a `*COPY <membername>` header. That is CMS packaging, not code.
  `BMDSECTS EDSECT ERMS JERRCD JFLEBLK JINCOM JOUTCOM JTEXT JTMTXT RSYMRCD
  RXLFMTS`.
- **`JERMSGCD`** has the `*COPY` header plus one real line, and it is one of his
  two additions: `ERR264 EQU 264 ESDID NUMBER HAS EXCEEDED THE LIMIT OF 399`
  becomes `... THE LIMIT OF 768`. (768, where the message text he wrote says 512
  and the memo says 512 — his own three statements of the new limit do not
  agree with each other.)
- **`X5ERRL`** looks like the largest unlogged change at 141 lines. It is not a
  change at all: the macro body is byte-identical for all 10 lines, and the
  extra 141 lines are **JCL that leaked into the member** after `MEND`.
- **`IFOX0I`** is the same class — 6 lines of JCL appended after `END START`.
  The assembler code is identical.

That leaves the discrepancy between the README's 24/15 and this 25/14. It is
`IFOX0F`, and the reason is precise: his change there **deletes** two lines,

    TM    DCBRECFM,BIT0+BIT1  UNDEFINED LRECL   @AX19477
    BO    XTIN05              BRANC IF YES      @AX19477

and a deletion leaves no `FX0000` behind for a marker scan to find. The log
catches it because the log records deletions. Note what those two lines are:
IBM's shipped source carries APAR `@AX19477` and Gorlinsky **removed** it,
because the object he was matching did not have it. That is the project's
central theme appearing inside the assembler itself, and pointing the other way
from usual — here the shipped source is *ahead* of the shipped object.

## Which IFOX00 produced our decks

`tools/ifox_run.py:34` names the instance: `HOST, PORT, FTPPORT = "mvsdev",
8083, 2123 # MVSCE-EXP`. Everything below was measured against that system's
`SYS1.LINKLIB(IFOX00)`, read-only, via `AMBLIST` and assemblies.

### Two behavioural fingerprints, each with a control

Gorlinsky's memo names two changes that are his own and in no IBM assembler:
the ESD table raised from 400 to 512 entries, and `M` accepted as a megabyte
suffix on `WORKSIZE`. Both are directly observable.

**ESD table size.** Assemble *n* `EXTRN`s and see where it breaks.

| Symbols | Result |
|---:|---|
| 380 | **CC 0000** — control, must pass, and does |
| 395 | **CC 0000** |
| 405 | CC 0016, `IFO264 TOO MANY ESD ENTRIES` |
| 420 | CC 0016, `IFO264 TOO MANY ESD ENTRIES` |
| 520 | CC 0016, `IFO264 TOO MANY ESD ENTRIES` |

The measured bracket is 396–405. **400** is IBM's value and comes from the
source, two ways: `ICOMMON` allocates `NOTELIST DS 25XL9` blocks of `16XL20`
entries, 25 × 16 = 400, and `JERMSGCD` reads `ESDID NUMBER HAS EXCEEDED THE
LIMIT OF 399`. Gorlinsky's build would take 512.
And the message text is IBM's: his `IFNX6B` reads `MAXIMUM OF 512 ESD ENTRIES
EXCEEDED`, IBM's reads `TOO MANY ESD ENTRIES`, and the oracle prints IBM's.

**`WORKSIZE` megabyte suffix.**

| `PARM.ASM` | Result |
|---|---|
| `WORKSIZE(200K)` | CC 0000, echoes `WORKSIZE(204800)` — control, must pass, and does |
| *(omitted)* | CC 0000, echoes `WORKSIZE(2097152)` — the default |
| `WORKSIZE(1M)` | CC 0016, `IFO258 INVALID ASSEMBLER OPTION ON EXEC CARD -- OPTION IGNORED`, falls back to `WORKSIZE(2097152)` |

The default control matters: without it, `WORKSIZE(2097152)` on the `1M` run
could be misread as "1M was accepted and scaled". It was not accepted; the
option was rejected and the default stood.

Two independent fingerprints, four controls, same answer: **the oracle's
`IFOX00` is not built from Gorlinsky's source.**

### The maintenance level, from the module itself

`AMBLIST LISTIDR` over all 16 `IFOX*` modules in `SYS1.LINKLIB`:

- **No IMASPZAP data in any of them.** Nothing was superzapped.
- Link-edited by VS Linkage Editor `5752SC104` level 03.07 on **day 213 of year
  26** — the MVS/CE build, as expected for a sysgen.
- `IFOX00` carries the aliases **`ASMBLR` and `IEUASM`**, both entering at
  `000008`. This confirms on the running system what the option table's note
  asserts: under MVS, `IEUASM` is an alias of the `IFOX00` load module.
- Most CSECTs carry translator date `77/171` and IDR user data `RSI7171xxxx` —
  the untouched 1977 base.
- The serviced CSECTs carry these stamps: `Z23668 Z31800 Z31801 Z32460 Z32461
  Z34598 Z34601 Z35490 Z35791 Z36471 Z36971 UZ36111`, with translator dates
  from `78/185` to `82/113`.
- Three CSECTs — `IFNX1KUN`, `IFNX3KUN`, `IFNX5M00` — carry `ZP60025` with
  translator date **`08/251`**, i.e. 2008. `ZP60nnn` is the TK4- usermod family
  (`docs/kreiss-project.md:555` lists `ZP60031`, `ZP60005`, `ZP60013` and others
  in exactly that role). This is a hobbyist usermod applied after Gorlinsky's
  work, not IBM maintenance.

Read the `Z…`/`UZ…` stamps as PTF numbers and compare with the memo's list:

> `UY77102, UZ49959, UZ52227, UZ56206S, UZ57269, UZ57526, UZ57881S, UZ58330,
> UZ61763S, UZ65533S, UZ68355S, UZ69166S, UZ69418S, UZ70679S, UZ70940S,
> UZ71064, UZ71545S, UZ73741, UZ73839, UZ80273, UZ80274S, UZ81148`

**Not one of the oracle's stamps appears in Gorlinsky's list, and every one of
them is numerically below his lowest (`UZ49959`).** PTF numbers run roughly
chronologically, so the oracle is at a strictly earlier level. That is a
consistent second reading of the same conclusion the ESD and `WORKSIZE` tests
reached from behaviour.

The reading of `Z34601` as `UZ34601` is an interpretation, not a measurement —
`IFNX2A00` records `UZ36111` with its `U` and the others do not. The comparison
does not depend on it: whichever way the prefix is read, none of these numbers
is in the memo's list.

## So: is it a better IFOX00 source than ours?

**For matching MVS/CE's object, no — it is the wrong level, in both directions.**
It is ahead of the oracle by his 22 PTFs (11 of them marked `S`, SUSP'd, in the
memo), behind it by the `ZP60025` usermod, and
apart from IBM entirely by two changes Gorlinsky made himself. A CSECT assembled
from his source would not compare byte-identical against MVS/CE's distribution
library, and that is this project's success criterion.

**As a source artefact, it is better than IBM's shipped source at what it claims
to be.** He matched source to object deck by deck and logged every edit with a
date; `IFOX0F` shows him removing an APAR that IBM's source carries and IBM's
object does not. That is the same work this project does, done once already for
one component, and the update log on tape file 8 is a worked example of how to
record it.

The open question about macro and source maintenance levels is **not** closed by
this set. It is narrowed: for the assembler specifically, we now know the
shipped source and the running object differ, we know at least one place where
the source is ahead of the object (`@AX19477`), and we have a second
independent reconstruction to compare against when the assembler's own modules
come up for recovery.

## What was not checked, and one operational note

- **The `RSI7171xxxx` stamps were not decoded.** They are read here as base-level
  markers on the evidence of the matching `77/171` translator date, not from
  documentation.
- **Gorlinsky's source was not assembled.** The claim that his tree would not
  reproduce MVS/CE's object rests on the behavioural fingerprints and the IDR
  stamps, not on a byte comparison of a built CSECT.
- **The disassembly sets on tape files 13 and 14 were extracted but not
  compared.** `DISASM IBM BAS` and `DISASM HRC BAS`, 32,920 and 33,107 records —
  two disassemblies of the same modules, IBM's and Hercules'. If the assembler's
  modules are ever recovered, that is a ready-made third witness.
- **`IEF722I ... FAILED - INVALID PASSWORD GIVEN` on MVSCE-EXP is intermittent.**
  Four jobs out of fourteen died on it before running a step, twice on identical
  JCL that then succeeded verbatim under a different job name. It is not
  content-related and not a JCL error despite JES2 reporting `JCL ERROR`. Any
  automated run against `:8083` needs to treat it as a retryable failure rather
  than a result.
