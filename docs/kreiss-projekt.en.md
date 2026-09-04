# Building MVS 3.8j from Source — Project Summary

Summary of the correspondence between **Mike Großmann**, **Dave Kreiss** and
**Greg Price** (Dec 2020 – July 2024) together with the documentation
*"Recovering and Building MVS 3.8j from SOURCE using SMP", Version 2.1,
updated 5 July 2020, by Dave Kreiss*.

Sources: `WORK/doc/*.pdf` and
`Dave Kreiss - MVS from Source/BLDMVS/Build MVS From Source Instructions.pdf`.

> German version: [kreiss-projekt.de.md](kreiss-projekt.de.md)

---

## 1. Goal and Core Idea

Dave Kreiss has pursued the goal of **rebuilding MVS 3.8j completely from
source** for years — using **SMP (System Modification Program) as the
maintenance vehicle**, i.e. the traditional mainframe process rather than
external source management tooling.

His reasoning (mail 2020-12-22 and the documentation): every change to MVS
executables has to reach the target libraries through SMP as a PTF or USERMOD
anyway. External tooling would only defer that step, not remove it.

The baseline is a **Turnkey TK3 system** (TK4- is covered by a dedicated
appendix). The definition of "correct" is the object code of the shipped TK3
libraries: recovered source counts as correct when it produces
**CSECT-identical object code**.

Scale: roughly **5,500 source modules** and **2,000 macros**.

---

## 2. Source Recovery Methodology

Dave describes his approach most fully in the mail of 2024-07-03:

> "The process is basically slow, first I try to isolate inserted/deleted
> instructions/data and fill them as best as I can. Then get all instruction
> displacements right then the storage/constants. Often DSECT displacements are
> different and that has to be fixed, usually related to getmained work areas
> and their layout."

So, in order:

1. Isolate inserted/deleted instructions and data, fill them as best as possible.
2. Get all instruction displacements right.
3. Align storage and constants.
4. Fix differing DSECT displacements — usually in GETMAINed work areas and
   their layout.

**Greg Price** (2020-12-19) describes the classic loop serving the same purpose:
assemble the source you have, disassemble the current object code, compare,
make a few instructions match — and repeat. Adding the `REUSE` operand to
`ALLOCATE` forced him to disassemble about eight modules; individual modules
cost him weeks.

### What exactly is Dave's baseline?

This is where his setup is easy to misread, because there are **two** baselines
— and the gap between them is the entire project.

| | What | Role |
|---|---|---|
| **Source baseline** | The MVS source IBM shipped, on the turnkey system's `SRC*` volumes (on TK4- from `source.zip`) | The starting point he improves |
| **Object baseline** | The DLIBs and target libraries of the **running TK3 system** | The oracle everything is measured against |

The decisive sentence sits in the documentation's introduction:

> *"None of these builds will create total matching target system libraries as
> **the source distributed isn't in sync with the distributed
> distribution/target libraries**."*

**The shipped source does not match the shipped object code.** The object
carries maintenance levels the source never received. That gap is the problem —
and it exists regardless of which turnkey system you pick.

### So why does Dave build PTFs?

Because his `DSKnnnn` PTFs **are not IBM PTFs**. They are self-written, synthetic
PTFs with exactly one purpose: **to raise the source text to the level the object
code already has.**

The documentation says so twice, unambiguously:

> *"DSK1nnn – Modifications to NUCLEUS to **bring those modules up to TK3
> maintenance level**."*

> *"The resulting PTFs update the elements so they will **match the object code
> in the target libraries**."*

So a `DSK1164` adds no function to the system. It only changes the source text so
that assembling it yields the module **that is already running**.

### The two obvious follow-up questions

**"But on TK3/TK4- most PTFs are already applied, surely?"** — Yes, **in the
object code**. And that is the starting position, not the way around it. The
maintenance sits in the load modules and object decks; it does not sit in the
source. The system being current does not help the source at all.

**"Couldn't we just apply the existing IBM PTFs?"**

A correction is needed here: **the PTFs do survive, and they have long since been
applied.** The MVS-sysgen project ships `tape/ptfs.het`, a collection of **1,482
known PTFs for MVS 3.8j**, and the sysgen applies them — `jcl/smpjob03.jcl` is
titled *"ACCEPT FMIDS/PTFS"* and issues `ACCEPT G(fmid)` for each FMID, i.e. the
group comprising the function **and** its associated PTFs, into the distribution
libraries.

So the object code in the DLIBs already carries that maintenance. The source
still lags — exactly the finding Dave describes.

**Why remains an open but measurable question.** The obvious explanation: MVS
PTFs of that era largely shipped **finished object modules** (`++MOD`) rather
than source (`++SRC`). Applying them would then update the object code and leave
the source untouched — precisely producing the observed gap.

That is not proven. `ptfs.het` is 14.2 MB and publicly available; checking how
many of those 1,482 PTFs contain `++SRC` is a modest measurement with large
leverage: **every PTF carrying source closes part of the gap mechanically.**
Recorded as a measurement point in the workplan.

Which leaves the road both Dave and Greg Price took: disassemble, compare, bring
the source forward by hand — and record the result as a PTF of your own.

### Why SMP and custom FUNCTIONs at all?

The running TK3 system's SMP environment manages **object code**. Dave wanted the
**source** under SMP management. So he built a **second, parallel SMP
environment** under `MVSSRC.BLD` and re-created the IBM FUNCTIONs there under
their original FMIDs — `EBB1102` for the Base Control Program, `EAS1102` for the
assembler, `EJE1103` for JES2 and so on — this time carrying the collected source
as their content:

> *"First all source code was collected and SMP FUNCTIONS were created to manage
> the code **at the source level** as close as I could determine to the current
> TK3 SMP environment."*

From that environment SMP assembles and links into **its own** DLIB and target
libraries — which he then compares against the real ones. Hence the separate
statistics in Appendix C.

**One practical consequence for us:** Dave's DSK PTFs are not incidental, they
*are* the output of his work. They are the source-level maintenance for NUCLEUS,
SVCLIB, JES2, SMP and CMDLIB, in IEBUPDTE form and therefore usable outside SMP
as well.

### Automated mass changes (MACCVT)

Much of MVS was originally written in **PL/S**; the shipped "source" is the
assembler emitted by the PL/S compiler. Dave built `MACCVT` to make that code
readable at scale:

- **Standardize register equates** to `R0`–`R15` (instead of `@00`–`@15`,
  `@0`–`@F` and other styles). Motive: a single module often has many different
  symbols for the same register.
- **Replace PL/S inline structure definitions with system DSECTs**:
  `L R10,LCCACPUS(,R8)` becomes `L R10,LCCACPUS-LCCA(,R8)`; the commented-out
  PL/S EQUs give way to the proper mapping macro.
- **Convert bit settings** from the PL/S format to the flags of the system
  DSECTs.

Dave calls the program "a twisted piece of code" himself — it grew far beyond
its original design but does essentially what is needed. He also flags its
limit: the `LABEL-DSECT(Rx)` technique is not the cleanest solution, but it is
the only one that can be applied automatically.

### Further interventions to make the compare succeed

- Non-printable characters removed from comments; `DC C'…'` constants holding
  hex data (IDCAMS and ICKDSF parser dictionaries among others) converted to
  `DC X'…'`.
- `END [label],(C'PL/S',nnnn,nnnnn)` stripped of the compiler version parameter.
- Alignment: `DS CL3` → `DC 0F'0'`, slack bytes `DS CLn` → `DC XLn'0'`, so that
  bytes the assembler does not generate don't show up as random data in the
  object compare.
- Back-level macros: some modules were assembled with older macros and therefore
  produce different instruction sequences. Workarounds: `ORG` back over the
  expansion, comment out the macro and inline its expansion, or include the old
  macro inline. Marked with `!!!` or `!!! SOURCE COMPARE FIX !!!`.
- Where Dave could not reconstruct what the code does, absolute offsets remain,
  marked `???` (some 20+ modules, mostly in SMP). Example from `IGFTMC00`:
  `NI 67(R9),255-X'80'   ??? DSK1164`.

### PTF numbering scheme

Changes are marked `*DSKnnnn` in column 1 or `DSKnnnn` in column 65.

| Range | Meaning |
|---|---|
| `DSK0001`–`DSK0099` | Macro changes |
| `DSK0100`–`DSK0999` | Fix source so it assembles cleanly |
| `DSK1nnn` | NUCLEUS up to TK3 maintenance level |
| `DSK2nnn` | SVCLIB up to TK3 maintenance level |
| `DSK3nnn` | JES2 and SMP up to TK3 maintenance level |
| `DSK5000`/`6000`/`7000`/`8000` | Phase 1: remove commented-out code |
| `DSK6000` | the SMP modification itself (see below) |
| `DSK9000` | Phase 2: replace inline macro expansions with real macro calls |
| `DSKCxxx` | Phase 3: SYS1.CMDLIB |
| `DSKKxxx` | Phase 4: SYS1.LINKLIB |
| `DSKLxxx` | Phase 5: SYS1.LPALIB |

### SMP extension 4.48 → 4.49

SMP has no way to delete source statements. Since cleaning up the PL/S output
leaves a great deal of commented-out code, Dave extended SMP to accept the
IEBUPDTE statements **`./ REPL` and `./ DELETE`**. This moves the SMP version
from **4.48 to 4.49**. That change (PTF `DSK6000`, installed into
`SYS1.LINKLIB` by job `MAINT05Z`) is a **prerequisite for every phase from
Phase 1 onwards**.

---

## 3. Structure of the Build Process

The build is organised as **Basic + five phases**. All jobs are chained: each
job submits the next and checks return codes; on failure the chain halts.

| Phase | Content |
|---|---|
| **Basic** | Does not touch the running MVS; works only under `MVSSRC.BLD`. `DSK0000`–`DSK0099` macros, `DSK0100`–`DSK0999` source cleanup, `DSK1000` identical IPLable NUCLEUS, `DSK2000` identical SVCLIB, `DSK3000` identical JES2 and SMP. |
| **Phase 1** | Applies the SMP PTF (4.48 → 4.49), **updating the running system's `SYS1.LINKLIB`**. Then `DSK5000`–`DSK8000` remove the commented-out PL/S EQUs. All modules stay object-identical — except the three modified CSECTs in the SMP load module. |
| **Phase 2** | `DSK9000`: replaces inline expansions of old macros with real macro calls. From here on many modules are **no longer object-identical**, but functionally equivalent. |
| **Phase 3** | `DSKCxxx`: `SYS1.CMDLIB`. **Complete** — all CMDLIB modules match the TK3 object code. |
| **Phase 4** | `DSKKxxx`: `SYS1.LINKLIB`. **Incomplete.** Also carries support for 3350, 3380 and 3390 mod 1/2/3 (IEHDASDR among others). |
| **Phase 5** | `DSKLxxx`: `SYS1.LPALIB`. **Incomplete**, likewise with the DASD extensions. |

> ⚠️ **Do not run Phase 1 on your production system** — it contains IEBCOPY
> steps against running system libraries. The documentation requires a cloned
> system (TK3: separate `MVSBLD` DASD directory and Hercules config; TK4-: a
> copy of the entire TK4- directory).

### Installation prerequisites

- **12 empty, labelled 3390-1 volumes** at addresses `192`–`19D`: `BLDDLB`,
  `BLDTGT`, `BLDSMP`, `BLDSR1`, `BLDSR2`, `BLDLS1`–`BLDLS5`, `BLDWK1`,
  `BLDWK2` — to be added to the Hercules config and to
  `SYS1.PARMLIB(VATLST00)`.
- On **TK4-** additionally: `source.zip` installed, the MVS source catalog
  connected (`SYS1.SETUP.CNTL(MVS0200)`), RAKF profiles in
  `SYS1.SECURE.CNTL(PROFILES)` extended by `DATASET MVSSRC.BLD.* ALTER` and
  `DATASET SYS1.UCAT.TSO UPDATE`.
- Mount the install tape `BLDMVS.AWS` on device `480` and run the load job
  `$$$LOAD`. It creates `MVSSRC.BLD.SMP.JCL`, `.SMP.LIB`, `.NEW.ASM`,
  `.MVT.ASM`, `.UTILITY.ASM` plus `.SMP.JCL1`–`.JCL5` and
  `.SMP.LIB1`–`.LIB5`.
- `$00SMPPR` creates the PROCs `BLDSMP`, `BLDSUB`, `BLDCLR`, `BLDCOPY`,
  `BLDPRT` in `SYS1.PROCLIB` once (needs HERC01 or update authority).
- `$01SMPAL` starts the build and is also the **restart point** — it deletes
  every data set on the BLD volumes except those loaded from tape, so the
  volumes need not be replaced for a restart.

**Runtime:** a good two hours (Dave's reference: Windows 10, i7 3.4 GHz,
Hercules 4.0.0.8497; TK4- ran comparably).

### What a Basic build produces

1. A set of **distribution libraries** with object code, macros and parameters,
   plus the generated MVS source library — structurally near-identical to the
   existing SMP environment.
2. A set of **target libraries** with the executables, likewise plus source.
3. A **listing library** holding the source listings created during APPLY and
   ACCEPT — outside SMP control, since SMP does not manage utility output.

Newly created are the SMP-managed source libraries `MVSSRC` / `AMVSSRC` and
`PVTMAC` / `APVTMAC` for macros not present in any shipped MACLIB.

---

## 4. Utilities (Appendix B of the documentation)

Source in `MVSSRC.BLD.UTILITY.ASM`.

| Program | Function |
|---|---|
| `COMPLMD` | **The key verification tool.** Compares two load module CSECTs. `DIFIN`/`DIFOUT` let you ignore known "holes" (random data from `DS` statements); `DC` emits matching assembler `DC` statements; `CLEARRLD=YES` neutralizes relocatable constants. |
| `LOADLMD` | Loads a CSECT from a load module into storage without relocating. The basis for `COMPLMD`. Derived from the disassembler on CBT tape file 217 (R. Thornton). |
| `MAPLMD` | Builds a table of all CSECTs in a load module, private CSECTs included. |
| `MACCVT` | The PL/S conversion described above. Control cards in `#MACCVTX`, FMID table in `#MACCVTF`, register-only conversion in `#MACCVTR`. |
| `MVSASM38` | Splits APPLY/ACCEPT output into individual assembly listing members. |
| `MVSLKD38` | The same for linkedit listings. |
| `LMDXRF38` | Reads the directory of a DLIB/target library and emits records per load module and CSECT. |
| `LMDRPT38` | Evaluates the `LMDXRF38` records and reports differences between original and build libraries (`SUMMARY`, `COMPARE`, `ERRORS`, `MISSING`, CSV output). |
| `MVSSMP38` | Checks SMP output for errors; configurable maximum return codes per step (`ASMRC=`, `LKDRC=`, `SMPRC=` …). |

---

## 5. Project Status

### Done and tested

| Area | Status |
|---|---|
| `SYS1.NUCLEUS` | Source produces identical object code; **IPLable and successfully tested** |
| `SYS1.SVCLIB` | identical |
| **JES2** | identical |
| **SMP** | identical (except the three deliberately modified CSECTs) |
| `SYS1.CMDLIB` | identical — functional testing outstanding |
| Assembler `IFOX00` | the build-generated version has been used successfully |

Dave has done "various TSO work" with these libraries and run the build many
times without failures.

### Unfinished

`SYS1.LINKLIB`, `SYS1.LPALIB`, `SYS1.VTAMLIB` and `SYS1.TELCMLIB` are **not
complete**. Dave's own assessment in the documentation: the code currently
generated for these libraries stands "little chance of working correctly".
Reason for stopping (mail 2020-12-22): LINKLIB, LPALIB and VTAM are simply too
big. He switched to the DASD topics instead.

### Compare statistics (Appendix C)

> The documentation itself notes: "This has changed but I haven't had time to
> update the differences column." The figures are therefore not current.

**Target libraries**

| Library | Original LMODs | Original CSECTs | Build LMODs | Build CSECTs | Differences |
|---|---|---|---|---|---|
| CMDLIB | 212 | 753 | 213 | 753 | 234 |
| LINKLIB | 660 | 1,683 | 660 | 1,721 | 688 |
| LPALIB | 1,203 | 2,346 | 1,200 | 2,343 | 1,344 |
| NUCLEUS | 26 | 355 | 26 | 354 | **0** |
| SVCLIB | 58 | 59 | 58 | 59 | **0** |
| TELCMLIB | 188 | 192 | 188 | 192 | 88 |
| VTAMLIB | 18 | 65 | 15 | 63 | 17 |
| **Total** | **2,365** | **5,453** | **2,360** | **5,485** | **2,371** |

**Distribution libraries:** 5,126 LMODs / 5,454 CSECTs in the original against
5,126 / 5,456 in the build, 2,379 differences across 34 AOS* libraries.

### Side branches

- **3390 support.** Standalone IPL from a pure 3390 SYSRES works (created via
  USERMOD/PTF through the build process). For **3390 mod 2/3** a **problem in
  the DEB** remained unsolved (mails 2020-12-22 and 2021-05-27).

  > ⚠️ **Dave's warning about the 3390 mods.** The 3390-2 and -3 modifications
  > are on the install tape but carry **at least one defect in the free-space
  > calculation that corrupts a volume's free space**. His explicit advice: do
  > **not** put these mods on a production system; the instructions say so in
  > several places. He has also tested the build **on TK3 only**.
  >
  > In practice: Dave's phases 4 and 5 (`DSKK7xx`–`9xx`, `DSKL7xx`–`9xx`) contain
  > exactly those 3390 extensions. Anyone running his build — to reproduce the
  > SMPWRK3 failure, say — brings them along.
- **Up to 32,760 tracks (3390-27).** Code was written by 2024 but ran "with some
  errors"; Dave had no time to diagnose them (mail 2024-07-02).
- **DSS370.** The MVS 3.8 debugger used by IBM was **built completely** but
  **never tested**. Source: `IQA`-prefixed modules in `MVSSRC.BLD.NEW.ASM`,
  load module `NDSS370` in `SMP.LIB` (mail 2024-07-02).

### Modules still needing work

Disassembled NUCLEUS modules that still need converting to DSECT references
(they currently use absolute offsets only):
`IECVTCCW`, `IGC121`, `IGG019P2`, `IGG019QE`, `IGG019Q0`, `IGG019RC`.

SMP modules for which no source existed and which were rewritten from scratch:
`HMASMADD`, `HMASMEFR`, `HMASMMDR`, `HMASMMPA`, `HMASMMPL`, `HMASMPIN`,
`HMASMULI`, `HMASMULK`.

Not reconstructable: the **IDCAMS and ICKDSF parameter dictionaries** — pure hex
constants produced by a process (probably `COMGEN`) that is not available. Dave
decoded parts of the layout from the parser code but never finalized it.

---

## 6. The Blocker: SMPWRK3 Directory Reset

This is the single most important open question in the project. It brought
everything to a halt in 2022 (mails 2022-06-03 and 2022-06-08).

**Symptom:** SMP **resets the directory of `SMPWRK3` in the middle of APPLY or
ACCEPT** — the very data set where object decks are stored.

**How the failure unfolds:**

1. During the assembly stage SMP stores object decks into `SMPWRK3`.
2. At some point the `SMPWRK3` directory is reset.
3. SMP does not notice and blindly carries on assembling and storing.
4. Object decks end up missing from `SMPWRK3`.
5. The subsequent link-edit produces **non-executable versions** of every load
   module whose element object decks are missing.

**Established** via a GTF trace and by examining a permanently allocated
`SMPWRK3` data set.

**First FUNCTION affected:** APPLY of **`EBB1102`** (Base Control Program) and
its associated PTFs. By 2022 other FUNCTIONs were being hit too.

**What Dave tried without success:**

- Allocating `SMPWRK3` with a larger directory.
- Splitting up the FUNCTION in question — unsuccessful and hard to manage.
- Older versions of the build install tape — same problem.
- A fresh TK3 installation, to rule out corrupted HMASMP modules — same error.

**What demonstrably used to work:** a complete generated system built and
successfully IPLed, and likewise the PTFs he wrote for a 3390 IPLable SYSRES and
for the IEBUPDTE `./ DELETE` extension to SMP.

**Open lead:** Dave has not yet gone through the SMP source. He frames the core
question this way — how is the directory being reset at all, if not by
overwriting it with an `X'FF'` member, and does the `STOW` macro under MVS 3.8
even support clearing a directory?

Mike offered to pass the problem to **Jay Maynard** in the community; Dave agreed
to have his address forwarded (2022-06-09). No outcome is recorded in this
correspondence.

---

## 7. TSO / IKJ Findings

Mike's actual interest is integrating **BREXX/370** into TSO — having REXX execs
invoked like CLISTs, both implicitly (`%rexx`) and explicitly (`EXEC …`). The
suspected hook point is `IKJCT430`. From the correspondence:

### Updated IKJCT modules (mail 2020-12-24)

Dave reconstructed the source of all CMDLIB modules so they match the shipped
TK3 object code. Of the `IKJCT` modules, these needed **updating**:

`IKJCT430`, `IKJCT431`, `IKJCT432`, `IKJCT435`, `IKJCT464`, `IKJCT466`, `IKJCT469`

All other `IKJCT` modules already matched as distributed.

The updates to `IKJCT431` are additionally available in member **`DSKC191`** of
`MVSSRC.BLD.SMP.LIB3`, in IEBUPDTE format — so the original source can also be
brought up to date by hand (mail 2020-12-22).

Background to Mike's original question: the sources found on the net
(`www.stben.net`) do not match MVS 3.8j — there `IKJCT431` carries
`DC C'IKJCT431 78.048'`, while Greg Price's usermod has
`DC C'IKJCT431 87.344'`.

### The currency rule of thumb (mail 2021-05-27)

> "So any module not in VTAMLIB, LINKLIB or LPALIB are current."

Anything **not** in `VTAMLIB`, `LINKLIB` or `LPALIB` is up to date in Dave's
source holdings. For the `IKJEFF` modules that means: presumably current, unless
their target library is one of those three.

### CSECT compare of the IKJEFT modules (mail 2024-07-03)

Dave ran `COMPLMD` over the roughly 25 `IKJEFT` source elements. His comment:
there appear to be "some big changes not incorporated in the version of source
we have". He also notes that the TMP message module is linked in four places
and apparently exists in **two versions**, depending on which PTFs were applied.

| Library | LMOD | CSECT | Status | Diff # | Comment |
|---|---|---|---|---:|---|
| LPALIB | IKJEFT02 | IKJEFTE2 | | | Auth cmds |
| LPALIB | IKJEFT02 | IKJEFTE8 | | | Auth pgms |
| LPALIB | IKJEFT02 | IKJEFTNS | Equal | | No bg cmds |
| LPALIB | IKJEFT01 | IKJEFTSC | Length equal | 15 | Disasm |
| LPALIB | IKJEFT01 | IKJEFT01 | | 6,867 | TMP initialize |
| LPALIB | IKJEFT02 | IKJEFT02 | | 10,899 | TMP mainline |
| LPALIB | IKJEFT02 | IKJEFT03 | | 1,637 | TMP attention |
| LPALIB | IKJEFT04 | IKJEFT04 | | 2,477 | TMP STAI exit |
| LPALIB | IKJEFT04 | IKJEFT05 | | 5,200 | TMP STAE exit |
| LPALIB | IKJEFT02 | IKJEFT06 | Duplicate | 1,363 | TMP messages |
| LPALIB | IKJEFT01 | IKJEFT06 | Duplicate | 1,362 | TMP messages |
| LPALIB | IKJEFT04 | IKJEFT06 | Duplicate | 1,363 | TMP messages |
| LPALIB | IKJEFT07 | IKJEFT06 | Duplicate | 1,351 | TMP messages |
| LPALIB | IKJEFT07 | IKJEFT07 | Equal | | TMP STAE retry |
| LPALIB | IKJEFT02 | IKJEFT08 | | 75 | TMP call |
| LPALIB | IKJEFT09 | IKJEFT09 | Length equal | 7 | Disasm |
| LINKLIB | IKJEFT25 | IKJEFT25 | | 878 | TIME command |
| LPALIB | IKJPTGT | IKJEFT30 | | 4,116 | Stack service |
| LPALIB | IKJPTGT | IKJEFT35 | | 1,456 | IO service messages |
| LPALIB | IKJPTGT | IKJEFT40 | Length equal | 10 | Putline |
| LPALIB | IKJPTGT | IKJEFT45 | | 1,441 | Put Get |
| LPALIB | IKJPTGT | IKJEFT52 | Length equal | 7 | Chain out routine |
| LPALIB | IKJPTGT | IKJEFT53 | Length equal | 4 | Unchain routine |
| LPALIB | IKJPTGT | IKJEFT54 | Length equal | 6 | Text insert |
| LPALIB | IKJPTGT | IKJEFT55 | | 4,012 | Getline |
| LPALIB | IKJPTGT | IKJEFT56 | Length equal | 2 | Terminal out |
| CMDLIB | TERMINAL | IKJEFT80 | Equal | | Terminal command |
| CMDLIB | PROFILE | IKJEFT82 | Length equal | 54 | Profile command |

How to read it: the TMP core modules (`IKJEFT01`, `IKJEFT02`, `IKJEFT03`,
`IKJEFT04`, `IKJEFT05`) diverge massively — several thousand bytes of
difference. The available source is far from the TK3 object code there. By
contrast `IKJEFTNS`, `IKJEFT07` and `IKJEFT80` already match, and several of the
`IKJPTGT` CSECTs (`IKJEFT40`, `52`, `53`, `54`, `56`) differ by only a handful of
bytes at identical length — those are closable with modest effort.

Greg Price already noted in 2020 that Dave had **not yet processed the TSO
commands and TMP modules** — which this table confirms.

---

## 8. Known Build Pitfalls

### S013-18 in job BLDIMAG (mails 2022-06-08 / 06-09)

Mike's first attempt failed with:

```
IEC141I 013-18,IGG0191B,BLDIMAG,GEN,SYSIN,194,BLDSMP,MVSSRC.BLD.NEW.ASM
IEF450I BLDIMAG GEN - ABEND S013 U0000
```

**Cause:** a member is missing from the SYSIN data set — specifically,
`MVSSRC.BLD.NEW.ASM` was **completely empty**. That library is populated by the
first load job (`$$$LOAD`, file 3 of the tape). With this symptom, check the
**load job**, not the build.

### Sporadic S106-F and IEBCOPY program check (Appendix H)

SMP-initiated assemblies occasionally abend with **S106-F** (uncorrectable I/O
error during program load), and SMP-initiated IEBCOPY runs with a **program
check at CCW command X'00'**:

```
IEA703I 106- F EBB1102B SMP MODULE ACCESSED IFOX62
IEB139I I/O ERROR DURING READ - EBB1102B,SMP ,348,DA,SYM10114,00- OP,PROGRAM CHECK
```

**SD2D** was later added to the list (program fetch found an incorrect record
type for an overlay segment), for both `IEWL` and `IEBCOPY`.

- Mostly on large APPLY/ACCEPT runs, usually in `EBB1102`.
- Reproduced on Hercules 3.12 and 4.00, on TK3 as well as TK4-.
- Dave considers it an **MVS 3.8 bug, not a Hercules bug**, and suspects a
  timing issue around PCI (both program fetch and IEBCOPY use PCI), possibly
  triggered by Windows dispatching.
- Setting Hercules to realtime priority did not help.
- **The failure is sporadic — restarting the build from the beginning usually
  succeeds.**

### Regression of your own USERMODs

If you have applied PTFs or USERMODs to your TK3 system that touch NUCLEUS,
SVCLIB, JES2 or SMP, they are lost in the MVSBLD libraries: the new SMP
environment knows nothing of your TK3 updates. Such USERMODs have to be
reworked — in particular every `PRE` has to be repointed at the PTFs used by
the build process.

### TK4- specifics (Appendix A)

- Because of **RAKF**, `MAINT05Z` fails updating `SYS1.LINKLIB` with **913-38**:
  jobs submitted by another job do not inherit the submitter's userid and run
  under the default user `PROD`. Fix: submit `MAINT05Z` manually as **HERC01**.
- TK4- has a different I/O configuration, so an **I/O gen** is required
  (`TK4IO1` through `TK4IO2B`), prepared by `ZJW0011` (24 PF keys for consoles)
  and `DSK0044`.
- The TK4- mods are then reapplied as source PTFs: `ZP60031`,
  `AY12275`/`OY12275`, `VS49603`, `ZP60005`, `ZP60013`, `ZP60017`, `ZP60023`,
  `SYZJ20X`, `TJES801`, `WM00017`, `ZJW0008`, `ZP60015`.
- After `ZCPYJES` the next IPL needs a **CLPA** (`R 0,CLPA` to `IEA101A`),
  because `SYS1.LPALIB` was changed.

---

## 9. Correspondence Timeline

| Date | From | Key content |
|---|---|---|
| 2020-12-18 | Mike → Greg Price | BREXX/370 V2R3 shipped, V2R4 in progress (`ADDRESS ISPEXEC` done, IRXEXCOM 90%, custom host command environments). Question: the sources found online don't match MVS 3.8j (`IKJCT431` 78.048 vs 87.344). |
| 2020-12-19 | Greg Price → Mike | Describes the assemble / disassemble / compare loop. `ALLOCATE REUSE` required disassembling ~8 modules. Points to Dave Kreiss. |
| 2020-12-21 | Greg Price → Mike, cc Dave | Introduces Dave: extensive mass changes to MVS source, friendlier register convention, system DSECTs instead of PL/S mappings. Notes that TSO commands and TMP modules are still outstanding. |
| 2020-12-22 | Dave → Greg, Mike | **First project overview.** SMP as maintenance vehicle; NUCLEUS done and IPLable, then SVCLIB, CMDLIB, plus SMP and JES2. SMP mod for IEBUPDTE delete. LINKLIB/LPALIB/VTAM too big → switched to 3390 topics: IPL works, mod 2/3 has a DEB problem. Points at `DSKC191`. Dropbox and OneDrive links. |
| 2020-12-24 | Dave → Mike | Has worked with MVS as a systems programmer since the early 1970s, but little with TSO internals. All CMDLIB modules reconstructed and object-identical. List of updated `IKJCT` modules. Sends `ikjct.zip`. |
| 2021-05-25 | Mike → Dave | Looking for `IKJEFF*` sources; the GitHub repo `mvs38/MVS3.8-Source-Recovery` has disappeared. |
| 2021-05-27 | Dave → Mike | Link to **the complete MVS source**: 7z archive, ~52 MB packed, 756 MB unpacked, **5,528 members**. Deleted the GitHub presence — couldn't work out git and had no time or desire to learn it. |
| 2021-05-27 | Mike → Dave | Asks about currency and **whether the sources may be published on GitHub** (`mainframed/mvs38_sources`, `mvslovers`). |
| 2021-05-27 | Dave → Mike | "Any module not in VTAMLIB, LINKLIB or LPALIB are current." Standalone 3390 IPL working, some problems still unresolved. **The publication question goes unanswered.** |
| 2022-06-03 | Dave → Mike | Heavy workload, plus an SMP bug: SMP resets the object module directory mid-APPLY/ACCEPT, links then fail. Tried various smaller FUNCTIONs and PTFs, verified the SMP load modules. "In other words stalled…." |
| 2022-06-08 | Mike → Dave | First own build attempt: `$01SMPAL` abends with S013-18, `MVSSRC.BLD.NEW.ASM` is empty. Asks for a crisp description of the SMP problem for Jay Maynard. |
| 2022-06-08 | Dave → Mike | S013-18 = missing SYSIN member. **Detailed analysis of the SMPWRK3 directory reset** (see section 6). |
| 2022-06-09 | Dave → Mike | Fine to forward his address to Jay Maynard. For the empty `NEW.ASM`, check the first load job. |
| 2024-07-01 | Mike → Dave | Asks for current status and the latest sources. |
| 2024-07-02 | Dave → Mike | Not much has happened. **32,760-track support (3390-27)** written but erroneous and undiagnosed. **DSS370 built completely but untested** (`IQA*` in `NEW.ASM`, `NDSS370` in `SMP.LIB`). Dropbox link to the last install package. |
| 2024-07-02 | Mike → Dave | Asks how exactly he goes about updating the sources. |
| 2024-07-03 | Dave → Mike | **Describes the methodology** (see section 2), mentions `COMPLMD`, and supplies the **CSECT compare table for the IKJEFT modules** (see section 7). |

---

## 10. Artifacts and Downloads

The links mentioned in the mails (as of the date of each mail; availability not
verified):

| Date | Content | Link |
|---|---|---|
| 2020-12-22 | `BLDMVS.7z` — install package | `https://www.dropbox.com/s/y1g31sll213vdgb/BLDMVS.7z?dl=0` |
| 2020-12-22 | the same on OneDrive | `https://1drv.ms/u/s!Ajp_FMPdPVCkk2pMvzHkFTVAQ4Ib?e=kHSXWn` |
| 2021-05-27 | **Complete MVS source**, 52 MB packed / 756 MB unpacked / 5,528 members | `https://1drv.ms/u/s!Ajp_FMPdPVCklgD6hVrav5ce-aAt` |
| 2024-07-02 | `BLDMVS.7z` — install tape and documentation | `https://www.dropbox.com/scl/fi/rsb9vzg0z9gm3vchovyaw/BLDMVS.7z?rlkey=kt4bimi1y4dz6cz07fps4eyfp&st=tm63bku5&dl=0` |
| ongoing | **`BLDMVS.7z` — the current level**, described by Dave as *"freely downloadable"* | `https://groups.io/g/turnkey-mvs/files/MVS%203.8J%20Source%20Recovery/BLDMVS.7z` |

The groups.io file area is Dave's own public distribution point and therefore
authoritative. Our local copy (`BLDMVS.AWS` of 2021-09-16, instructions version
2.1 of 2020-07-05) is presumably older and should be reconciled.

No longer reachable: `https://github.com/mvs38/MVS3.8-Source-Recovery` — Dave
deleted the repository (mail 2021-05-27).

Present locally in this repository:

- `Dave Kreiss - MVS from Source/BLDMVS/` — the install package: `BLDMVS.AWS`
  (190 MB tape), `$$LOAD$$.JCL`, the twelve empty DASD volumes and the
  instructions as PDF.
- `Dave Kreiss - MVS from Source/MVSBLD/` — 5,528 `.ASM` members.

---

## 11. Open Points

1. **SMPWRK3 directory reset** — the actual blocker. The obvious next step is
   the one Dave named but never took: read the SMP source to find how the
   directory gets reset, and establish whether `STOW` under MVS 3.8 permits
   clearing a directory at all.
2. **Licensing and publication status unresolved.** Mike explicitly asked on
   2021-05-27 whether the sources are for private use only or may be put on
   GitHub. Dave **did not address the question** in his reply. This should be
   settled before any publication.
3. **LINKLIB and LPALIB** are barely started and, per the documentation,
   functionally doubtful. **VTAMLIB and TELCMLIB** were never touched.
4. **3390 mod 2/3** — DEB problem unsolved.
5. **3390-27 / 32,760 tracks** — code exists, errors undiagnosed.
6. **DSS370** — built completely, never tested.
7. **CMDLIB** is object-identical but its **functionality was never verified**.
8. **IDCAMS/ICKDSF parameter dictionaries** — the generating process (`COMGEN`)
   is missing, the layout only partly decoded.
9. **The outcome of the enquiry to Jay Maynard** is not recorded in this
   correspondence.
