# TODO — MVS 3.8j source recovery

As of 2026-09-06 (evening). The working list for [`docs/workplan.md`](docs/workplan.md).
The plan says *why* and *where to*; this list says *what next*.

**Key:** 🔒 blocks other work · ⚡ runs in parallel, blocks nothing ·
🚪 gate: the outcome decides how we proceed

---

## Start here tomorrow

**572 modules are byte-identical to the shipped object code**, and 281 more
differ only in `DS` holes — 853 of 3,888, measured tree-wide. See
[`docs/tree-wide-run.md`](docs/tree-wide-run.md). The question is no longer how
to compare. It is what the **2,079 length differences** are made of.

**1. Rule out our own macro provenance first.** 319 of our macros come from web
mirrors with an unestablished maintenance level, and a macro one PTF behind
generates a different length from perfectly correct source. That is the one
variable we introduced ourselves, and until it is closed every length difference
has two possible explanations. The route is Dave Kreiss' built `PVTMAC`/
`APVTMAC` on his rebuilt install tape — asked for on 2026-09-06.

**2. Then the 589 that differ only in generated text.** Real differences at the
right length: the recovery work proper. Sorted by cluster count, the smallest
first.

**3. And the 1,256 that do not assemble** are outside the measurement entirely.
Their first causes were categorised on the 150-module sample; that categorisation
should be redone on the full set now that it is cheap.

Still open and unchanged: the 14 `AMACLIB` elements missing from
`SYS1.AMACLIB`; `IHANVT`, `UCBDADVC`, `IECDCST` with no `++MAC` element;
`ACCESS`, `IQAMOD`, `IQAQAL` nowhere on this machine.

---

## Immediate

### 1. ✅ Licensing settled — Dave Kreiss answered on 2026-09-06

**Freeware, no copyright, no terms.** His words: *"it is ok to release it as
freeware with no copyright or terms — that is it is open to anyone to use as
desired."* The same goes for the utility source on the install tape.

- [x] Sent (2026-09-04), answered (2026-09-06)
- [x] **Publication is unblocked** — the repository may go public
- [ ] Credit him **by name and email** on the material and in the repo
- [ ] **Keep `UTL31` out of publication.** It descends from the CBT file 217
      disassembler (R. Thornton) and he does not know its terms either. He
      distributes it but does not assemble it, so nothing depends on it
- [x] **Replied on 2026-09-06.** It asks for his built `PVTMAC`/`APVTMAC` on the
      new install tape — and that request has since turned out to be the *only*
      route to those macros, see [`docs/private-macros.md`](docs/private-macros.md)

**What else his mail says:**

- All target libraries assemble to match TK3 **except `SYS1.LINKLIB` and
  `SYS1.LPALIB`**, the two largest. He has IPLed and run a system with the
  rebuilt libraries.
- **He is rebuilding the install tape**: current documentation, utility source,
  Tom Armstrong's SORT put into SMP format, and source for some compilers
  (COBOL and FORTRAN). Worth waiting for before any large re-baselining.
- The ask that goes with it: **`MVSSRC.BLD.PVTMAC` / `APVTMAC` on the new tape**,
  which would replace our 320 mirror macros with ones at a known level.

### 1a. ✅ Current BLDMVS package reconciled

The 2023 package is on disk and unpacked; the 2021 one is kept beside it.

| | old | new |
|---|---|---|
| location | `Dave Kreiss - MVS from Source/BLDMVS#2021/` | `…/BLDMVS/` |
| instructions | 2020-07-05 | **2023-08-06** |
| `BLDMVS.AWS` | 2021-09-16, 190 MB | **2023-12-01, 191 MB** |
| `NEW.ASM` on tape | 31 MB | **43 MB** — plausibly the DSS370 work |
| `UTL.ASM` on tape | 4.2 MB | **5.3 MB** |

The archive is `~/repos/MVSSRC_BAK/BLDMVS.7z`. No 7z tool is installed, but
**`tar -tf` / `tar -xf` read it** (bsdtar handles 7z).

**What changed in the instructions (762 lines differ):**

- **New: a TK5 section** — install the TK5 source and CBT option, RAKF profiles
  for `MVSSRC.BLD.*`, Hercules config for the build volumes.
- **`MAINT05F` no longer submits its successor.** The step that copies the new
  SMP into the running `SYS1.LINKLIB` is commented out; uncomment it or submit
  `MAINT05Z` by hand. Anyone replaying the build will trip over this.
- **The S106-F appendix is gone entirely** — 11 mentions in 2020, none in 2023,
  and "no failures except the occasional S106-F" became just "no failures". The
  sporadic build aborts seem to have gone away with newer Hercules.
- **Dave got more pessimistic:** "little chance of working correctly" became
  "**no** chance" for LINKLIB, LPALIB, VTAMLIB and TELCMLIB.
- **Newly tested:** 3350 *and* 3390 mod 1 as system residence.
- Appendix C statistics are **unchanged**, so no further modules were completed
  between 2020 and 2023.
- A documentation bug: the Phase 4/5 headings gained parenthetical labels that
  are swapped — "Phase 4 (LPALIB…)" describes `DSKK000` → LINKLIB. The body text
  is right.

### 1b. ✅ Instances run MVS/CE v3.0.0

`SYS1.PARMLIB(RELEASE)` on 2026-09-04: **LAB and EXP are v3.0.0**, `MVSCE-DEV` is
v2.1.4. mvsMF on LAB and EXP has been updated by the user and now reports
`zosmf_version: "1"` with a `plugins` field, like DEV.

- [ ] **Open decision:** the baseline for comparison. Our instances are 3.0.0;
      the pristine copy extracted on `mvsdev` (`~/tmp/mvs38src-work/`) is 2.1.4.
      If the DLIB hypothesis holds this hardly matters — but it should be settled
      rather than drifting.

### 1c. ⚡ libc370 release and the four relinks — not on our critical path

Deprioritized 2026-09-04. This entered the list as a prerequisite for asking
mainframed767 for newer packages, which in turn was driven by the retcode
problem. That problem turned out to be our own job cards, so the chain is gone.

**We build no C programs for MVS.** libc370's fixes matter to httpd/mvsMF/ftpd —
good ecosystem hygiene, and the SYNAD fix is real (an I/O error used to kill the
address space with S001) — but nothing here waits on it.

- [ ] Cut libc370 v1.0.4 and relink httpd, ufsd, ftpd, mvsmf **when convenient**
- [ ] Give mvsmf a stable `v1.0.0` rather than only the `v1.0.0-dev` pre-release

### 1d. ⚡ Ask mainframed767 for an MVS/CE 3.0.1 — weaker case now

Draft in `~/repos/MVSSRC/WORK/doc/mail-mainframed767-mvsce-301.md`.

**The regression argument is withdrawn.** There is no JES2 regression in v3.0.0;
that was our broken job cards. What remains is worth reporting but is not urgent:

- [ ] Package levels lag the current releases (update the version table first)
- [ ] `SCRIPTS/SHUTDOWN.RC` stops neither HTTPD nor FTPD
- [ ] Nothing starts them either — no `S HTTPD` anywhere in the repo
- [ ] Which HTTPD actually lands in the build: `MVP/desc/HTTPD` says 4.0.0, but
      `MVS-sysgen/SOFTWARE/HTTPD` holds `HTTPD330` from 2025-02-13

### 2. ✅ Repo created

- [x] `git init`, base structure
- [x] **`.gitattributes` with `* -text` and `*.asm binary`** — before the first
      commit. Forget it and Git normalizes the CRLF and the 80-column records,
      and from then on we compare artifacts of our own toolchain
- [x] `README.md`, `CLAUDE.md`
- [x] `.gitignore`: DASD images, `*.AWS`, web mirrors stay out
- [ ] Repo stays **private** (see item 1); no remote until then

### 2b. ✅ cc370 issues filed for the tools we need

Five issues in `mvslovers/cc370`, so another agent can pick them up:

| # | Tool | Note |
|---|---|---|
| [#108](https://github.com/mvslovers/cc370/issues/108) | as370: `DC/DS` type `S` | measured gap; #53 fixed the silent failure, the type is still unimplemented |
| [#109](https://github.com/mvslovers/cc370/issues/109) | `libobj370` / `libmvs370` | roadmap phase 0 — **the other three depend on it** |
| [#110](https://github.com/mvslovers/cc370/issues/110) | `cmplmd370` | the comparator; our success criterion |
| [#111](https://github.com/mvslovers/cc370/issues/111) | `idrdump370` | IDR records + eyecatchers per CSECT |
| [#112](https://github.com/mvslovers/cc370/issues/112) | `dasm370` | disassembler + alignment-diff mode |

Only #109 and #110 are on the critical path for the measurements in items 5b–5d.
#112 can wait until we know how large case D actually is.

### 2c. Dave Kreiss' utilities — extract, read, do not port

His nine utilities are **not** among the 5,529 `.ASM` files in `MVSBLD/`. They
live only on the `BLDMVS.AWS` tape, in `MVSSRC.BLD.UTILITY.ASM` (file 5).

**We do not need to port them.** They are MVS-side tools that our host-side chain
replaces:

| Dave's tool | Replaced by |
|---|---|
| `COMPLMD` | `cmplmd370` (#110) |
| `LOADLMD`, `MAPLMD` | `libobj370` / `file370` (#109) |
| `LMDXRF38`, `LMDRPT38` | our own inventory pipeline |
| `MVSASM38`, `MVSLKD38` | only needed if we run SMP builds ourselves |
| `MVSSMP38` | possibly useful in M7 — it parses SMP output for per-step errors |
| `MACCVT` | prior art for making case-D modules readable; Dave calls it "a twisted piece of code" |

**But the source is worth reading as a specification.** `COMPLMD` defines the
`DIFIN`/`DIFOUT` semantics and `CLEARRLD` that #110 has to reproduce, and
`MACCVT` documents the PL/S conversion rules. Extracting them costs one `hetget`
run and gives the comparator a reference implementation to check against.

- [x] **The tape is readable without Hercules.** `BLDMVS.AWS` is a plain AWS
      tape; a 40-line host reader walks it. Structure confirmed: standard labels,
      15 data files, `UTL.ASM` is file 5 (914 blocks, 4.19 MB, an IEBCOPY unload)
- [x] **Get the members out of that unload — done, 2026-09-05.**
      [`tools/pdsunload.py`](tools/pdsunload.py) reads the unload member by
      member; `UTL.ASM` yields 64 members. cc370#113 stays open for `file370`,
      but it no longer blocks us. The header layout and the control case are in
      [`docs/private-macros.md`](docs/private-macros.md)
- [ ] Read `COMPLMD` before implementing #110 — especially how it decides what
      counts as a difference
- [ ] Keep the extract as reference material; **no MBT project, no port**
- [ ] Revisit `MVSSMP38` when M7 comes around

### 3. ✅ Tooling — extract on `mvsdev`, process on the Mac

Hercules **cannot be built on the Mac** (arm64): it compiles with
`--with-included-ltdl` and permissive CFLAGS, then fails to link because the
external packages ship prebuilt for x86 only and their CMake build script does
not work on this layout. Docker is not installed either. Abandoned deliberately.

**`mvsdev` has everything** in `/usr/local/hercules/bin`: `dasdls`, `dasdpdsu`,
`dasdseq`, `dasdcat`, `hetget`, `cckd*`. Reach it with `ssh mvsdev`.

The working split: **extract on `mvsdev`, process on the Mac.** Extraction needs
no running MVS, only the volume files, and happens once per artifact. Unpack a
pristine release into a scratch directory rather than reading a running
instance's volumes — `~/tmp/mvs38src-work/` holds one (2.1.4).

⚠️ **Two traps in `dasdpdsu` output**, both hit on 2026-09-04:

1. It writes **raw EBCDIC with no record separators**. Members are RECFM=FB 80,
   so split into 80-byte records first.
2. Convert to a **single-byte encoding** — `cp037` in, `latin-1` out. UTF-8 turns
   EBCDIC `X'5F'` (`¬`) into two bytes and shifts every column after it, which
   silently breaks column 72 and therefore the continuation rule.

Also useful: `BLDMVS.AWS` is a plain AWS tape and a 40-line host reader walks it
without Hercules at all.

- [x] Hercules utilities available (on `mvsdev`)
- [x] `as370` confirmed current — `as370/src/` unchanged since the installed build
- [ ] Build `cc370` freshly when `cmplmd370` lands

### 4. ◐ MVS/CE baseline — partly done

- [x] Pristine 2.1.4 unpacked on `mvsdev` at `~/tmp/mvs38src-work/MVSCE/DASD/`
- [x] **DLIBs confirmed on `smp000.3350`** — 34 `AOS*` libraries, exactly the set
      in Dave's appendix C. Also `SYS1.AMODGEN`, `SYS1.SMPCDS`, `SYS1.SMPPTS`,
      `SYS1.UMOD*`, `SYS1.HASPSRC`
- [x] Macro libraries extracted: `SYS1.MACLIB` (742), `SYS1.AMODGEN` (288),
      `SYS1.APVTMACS` (242)
- [x] `retcode` works — it needed a complete job card, nothing else
- [ ] Immutable snapshot with checksums → `baseline/checksums.txt`
- [ ] Inventory the baseline → `baseline/mvsce-*.md`: usermods, MVP packages,
      sysgen parameters, I/O gen
- [x] **Evaluate the SMP CDS: which sysmods are ACCEPTed?** — done, 2026-09-06,
      [`docs/accept-status.md`](docs/accept-status.md)
- [ ] Verify the runbook on a first full pass, raising 📄 to ✅

### 4b. ⚡ Set up the instances on `mvsdev.lan`

Three MVS/CE instances, each Hercules in its own tmux session (roles and
rationale in [`docs/runbook.md`](docs/runbook.md), section 6):

| Instance | Purpose |
|---|---|
| `mvsce-lab` | all other projects, permanently available — **off limits to the agent** |
| `mvsce-src` | this project: PTFs, APPLY/ACCEPT, IPL test |
| `mvsce-exp` | this project: experiments, above all SMPWRK3 reproduction |

- [ ] Decide the port allocation for three instances — **the reader ports are the
      known collision trap** (`MVP/MVP.ini`, see `~/repos/mvs/REFCARD.md`)
- [ ] tmux session names and start scripts per instance
- [ ] Write and test the "recreate an instance from the template" procedure
- [ ] Set up mvsMF access over the network for the agent
- [ ] Decide where the baseline template lives (Mac or `mvsdev.lan`) and how the
      checksums stay consistent across both

**Not on the critical path.** The instances are needed only from M7 on. M0 and M1
need the volume files, not a running system — so the end-to-end test in item 5
works with the local 2.1.4 already.

### 5. ✅ End-to-end test: done, and it went further than one module

Host-side extraction holds up. `dasdcat` reads distribution-library members with
no MVS running; `file370` walks them (CESD, IDR, control, text, MODEND); `as370`
produces object decks from Dave Kreiss' source; and the two sides can be compared
on section names and lengths **without a comparator existing yet**. 102 pairs
measured, 49 of them matching. [`docs/dlib-distance.md`](docs/dlib-distance.md).

The one correction it forced: the `AOS*` libraries hold **load modules**, not
object decks. Everything downstream follows from that.

The original checklist, with what actually happened:

- [x] Pull a module out with **no MVS running** — `dasdcat`, not `dasdpdsu`;
      the latter cannot read a RECFM=U library at all
- [x] `file370 -v` shows the record structure — CESD, IDR, control, text, MODEND
- [x] Read out sections and IDR records — done for 102 members
- [ ] Check one by hand against the same module on the running system — still
      worth doing once, as an independent check on the whole host-side chain

---

## Then: inventory and feasibility

### 5b. 🚪 Measure the DLIB hypothesis: MVS/CE against TK5

**Cheap, early, and the outcome changes the statics of the project.**

Hypothesis: all turnkey distributions sit on the same IBM DLIBs. Differences
arise only through sysgen and usermods — and those affect the *target*
libraries, not the DLIBs. The one exception: sysmods installed by **ACCEPT**.

Both sides are available locally:

| System | DLIB volume |
|---|---|
| MVS/CE | `smp000.3350` |
| TK5 | `tk5dlb.392` (`~/Downloads/mvs-tk5/dasd/`, 30.5 MB) |

- [ ] `dasdls` over both volumes: which `AOS*` libraries exist, same member
      counts?
- [ ] Cross-check at the root: did both process the same `ptfs.het` level and the
      same Morrison usermods? (see the plan, section 5)
- [ ] Extract the object decks and compare CSECT by CSECT
- [ ] Hold divergences against both systems' SMP CDS — are they ACCEPTed sysmods?
      (our side is measured now, see [`docs/accept-status.md`](docs/accept-status.md))
- [ ] Record the outcome in `baseline/dlib-comparison.md`

**If the hypothesis holds**, our output is source for **MVS 3.8j**, not for our
MVS/CE — distribution-independent. The reference-release question then largely
dissolves, and Dave's DLIB-level results do carry after all.

**If it does not hold**, we get a list of affected elements instead of an
uncertainty — also a usable result.

### 5c. 🚪 Examine `ptfs.het` — the measurement with the greatest leverage

**Correcting an earlier assumption:** the IBM PTFs are not lost. The MVS-sysgen
project ships `tape/ptfs.het` with **1,482 PTFs for MVS 3.8j**, and
`jcl/smpjob03.jcl` ("ACCEPT FMIDS/PTFS") installs them into the DLIBs via
`ACCEPT G(fmid)`. So the object code carries them — the source does not.

The decisive question: **do these PTFs contain `++SRC`, or only `++MOD`?**

- [ ] Obtain `ptfs.het` (in the sysgen repo, 14.2 MB) and unpack it on the host
- [ ] Count: how many of the 1,482 PTFs contain `++SRC` elements?
- [ ] If any: which modules do they touch, and do they overlap our
      `DIFF-UNKNOWN` cases?
- [ ] Record the outcome in `baseline/ptfs-analysis.md`

**Why this is worth so much:** every PTF carrying source closes part of the gap
**mechanically** — no disassembly, no alignment loop, no agent. If there are
many, the backlog shrinks considerably. If there are none, we have the
explanation for why source and object drifted apart at all — also a result.

Both are cheap to get and should be settled before the large comparison campaign.

### 5d. 🚪 Dave's 747 modules against the MVS/CE DLIBs

**The single most important measurement of the project** — it answers whether we
can build on Dave's work or have to redo it.

`MVSBLD/` is not his input material but his **working state**. Counted, the
modules he actually touched:

| Series | Area | Modules |
|---|---|---:|
| `DSK0` | base cleanup | 235 |
| `DSK1` | NUCLEUS | 158 |
| `DSK2` | SVCLIB | 32 |
| `DSK3` | JES2 + SMP | 36 |
| `DSK9` | macro modernization | 12 |
| `DSKC` | CMDLIB | 203 |
| `DSKK` | LINKLIB (incomplete) | 61 |
| `DSKL` | LPALIB (incomplete) | 55 |
| | **total** | **747** of ~5,500 |

- [ ] Identify the 747 modules (marker `DSKnnnn` in column 65, or `*DSKnnnn` in
      column 1)
- [ ] Assemble all of them with `as370` and compare against the MVS/CE DLIB
      elements
- [ ] Evaluate: mostly `IDENTICAL`, a systematic residual difference, or
      scattered and unsystematic?
- [ ] **Flag for special handling:** 50 modules carry `???` (Dave could not
      reconstruct the purpose), 16 carry `!!!` (a compare workaround). No agent
      may tidy up there on its own initiative

**If it turns out well**, the backlog is 747 modules smaller and the toolchain is
validated against known material. **If it turns out badly**, his actual PTFs are
on the `BLDMVS.AWS` tape as `MVSSRC.BLD.SMP.LIB` through `.LIB5` — in IEBUPDTE
form, so re-appliable. In no case do we have to redo his work.

### 6. Inventory and the two tables (M1)

- [ ] Inventory across all system libraries — **target libraries AND
      distribution libraries (`AOS*`)** (`dasdls`)
- [ ] CSECT, IDR and eyecatcher extraction, machine-readable as CSV
- [ ] Evaluate the SMP CDS on `smp000`: sysmod → element, plus ACCEPT status
- [ ] Index all local source pools: `MVSBLD/` (5,529), `IKJ/` (269),
      `www.stben.net/`, `mvssrc/mainframe.eu/`, `NEW.ASM`, `MVT.ASM`
- [ ] Join → table A (ported) and table B (missing)

### 7. 🚪 as370 gap analysis (M2)

> **Measured 2026-09-05 — the gate holds clearly. 73 % assemble cleanly.**
>
> Same 150 modules drawn at random from `MVSBLD/`, same as370 build, counted per
> module on exit code 0:
>
> | Macro set | Macros | Assembled |
> |---|---:|---:|
> | `SYS1.MACLIB` + `AMODGEN` + `APVTMACS` | 1,269 | 73 (49 %) |
> | + the private macros off Dave Kreiss' tape | 1,383 | 83 (55 %) |
> | **+ the private macros from the web mirrors** | **1,702** | **110 (73 %)** |
>
> The first row reproduces the 2026-09-04 measurement exactly, so the runs are
> comparable. **No regressions** — no module that assembled with the small macro
> set fails with the large one. Details, provenance and the caveat on the mirror
> macros: [`docs/private-macros.md`](docs/private-macros.md).
>
> ### What the remaining 40 failures are made of
>
> Counted **per module**, by first cause.
>
> | First cause | Modules |
> |---|---:|
> | undefined operation code (still a missing macro) | 11 |
> | addressability — no active `USING` | 11 |
> | undefined symbol | 7 |
> | relocatable duplication factor | 3 |
> | `DC/DS` type `S` — [cc370#108](https://github.com/mvslovers/cc370/issues/108) | 3 |
> | single cases (`START`, `ISEQ`, continuation, IFO158, IFO231) | 5 |
>
> **Missing macros are no longer the dominant cause.** What is left of them is
> not one pool either: `IHADECB` and `IEZCTGPL` are `DISTLIB(AMACLIB)`, so they
> belong in `SYS1.MACLIB` — **our extract of it is missing 79 of 554 elements.**
> That is a defect in our extraction, not in MVS/CE, and it is the first item
> for tomorrow.
>
> ### The two extraction traps, still valid
>
> **1. `dasdpdsu` writes raw EBCDIC with no record separators.** The members are
> RECFM=FB 80, so the output must be split into 80-byte records and translated.
> Feeding it raw makes the rate *drop* to 28.
>
> **2. Convert to a single-byte encoding, never UTF-8.** Writing the members as
> UTF-8 turns EBCDIC `X'5F'` (`¬`) into two bytes, and every column after it
> shifts right. In `WTO` that pushed a comment's last character into byte column
> 72 — the continuation column — and as370 correctly reported a continuation
> that consumed the next statement. The fix is latin-1, where `¬` stays one
> byte. **Column positions are the whole contract in fixed-format assembler.**
>
> A third one found on 2026-09-05: **`MVSBLD/` was converted with a different
> code page than ours.** `X'5F'` is `^` there and `¬` here — IBM-1047 against
> cp037. Same byte, different character; a comparison across both sources has to
> normalise it.

- [x] **Extract `SYS1.AMODGEN` and `SYS1.APVTMACS`** — done on `mvsdev`
- [x] Reconcile `SYS1.MACLIB` from MVS/CE against `~/repos/mvs/sys1.maclib` —
      both have 742 members, so the local copy was genuine
- [x] Repeat the measurement with the full macro set — 43 %
- [x] **Located Dave Kreiss' `PVTMAC`** — the missing macros are all on his tape,
      as `++MAC(…) SYSLIB(PVTMAC)` elements in `MVSSRC.BLD.SMP.LIB`
- [x] **`TXLIB(SYM20104)` resolved** — a DD name for `MVSSRC.SYM201.F04`, an IBM
      RELFILE Dave Kreiss had locally. Not on the tape, and not reachable by
      loading the tape under MVS either
- [x] **Extracted the private macros** — 114 from `NEW.ASM` on the tape, 319 from
      the web mirrors; 433 of 436. In `work/macros/`, kept apart by provenance
- [x] **Re-measured: 49 % → 73 %**, no regressions
- [x] **Corpus moved to DLIB level** (2026-09-06). The old one mixed target and
      distribution libraries. 111 of 150 now, no regressions; the `AMACLIB` gap
      went from 79 to 14
- [ ] The mirror macros **cannot** be replaced from any MVS/CE — the private
      macros are not in the DLIBs (3 of 623). Only Dave Kreiss' built `APVTMAC`
      or the IBM RELFILEs can settle their level
- [ ] Re-measure again after cc370#115
- [ ] Implement `DC/DS` type `S` in as370 — the only gap reported by name in the
      pre-measurement
- [ ] Run as370 over a cross-section of `MVSBLD/*.ASM` and `IKJ/*.asm`
- [ ] Categorize failures: missing directive, macro, expression syntax,
      addressing, other
- [ ] Check the known gaps specifically: `START`, `PUNCH`, `REPRO`, `ICTL`,
      `OPSYN`, `DXD`
- [ ] Close the "frequent and cheap" ones in as370 straight away
- [ ] Cross-check one module against IFOX00 on MVS

**Gate.** If the rate comes out poorly, as370 takes priority over everything
else — this item then becomes the main project for a while.

### 8. Re-check Dave's "finished" modules (M3)

Dave's "verified" holds against **TK3**, not against MVS/CE. That has to be
re-established.

- [ ] Build `cmplmd370`: `DIFIN`/`DIFOUT` semantics, `CLEARRLD`, JSON output,
      **exit code 0 only on byte-identity**
- [ ] Pilot: one CMDLIB module through the whole chain — **`as370` OBJ against
      the DLIB element**, with no `ld370` in between. There we know the expected
      answer
- [ ] Cross-check against the target load module; the delta is the
      usermod/sysgen layer
- [ ] Then **completely** across all libraries
- [ ] Assign verdicts, keeping `DIFF_DLIB` and `DIFF_TGT` separate
- [ ] Fill table A with real numbers

Expectation: the hit rate against the DLIBs should be considerably higher than
against the target libraries — usermods, sysgen configuration and the linkage
editor all drop out as sources of noise there.

---

## Tool building

### 9. dasm370 and the round trip (M4)

- [ ] Extract `libobj370` from as370/ld370/file370 (cc370 roadmap phase 0).
      Validation: the existing tools still produce byte-identical output
- [ ] `dasm370` v1 — based on **as370's opcode tables**, not the Waterloo code
      (licensing, see the plan, section 6)
- [ ] **Round-trip test** `dasm370 → as370 → cmplmd370` must yield `IDENTICAL`.
      That is the disassembler's self-test and the precondition for case D
- [ ] Alignment-diff mode: recognise insertions and deletions as such, not as
      byte noise. Without it the agent cannot classify differences
- [ ] Output quality: labels, `USING` reconstruction, literals, address constants

### 10. 🚪 The orchestrator (M5)

- [ ] `mvsrec`: queue, state machine, budget, `work/state/` with resume,
      `evidence/`, escalation reports
- [ ] Enforce the guardrails technically, not just in prose (plan, section 2.4)
- [ ] Write `AGENT.md` — the work contract an agent reads at the start
- [ ] Dry run over case-A modules: a verdict **without any iteration**
- [ ] First autonomous run over five case-B modules

**Gate for the target picture.** This is where it is decided whether the autonomy
carries. Everything before is preparation, everything after is scaling.

---

## Establishing breadth

### 11. Coverage at DLIB level (M6)

No longer a targeted raid but a systematic sweep. The aim is coverage, sorted by
effort rather than by topic.

- [ ] Work outward from Dave's verified areas: NUCLEUS, SVCLIB, JES2, SMP,
      CMDLIB — his source-level maintenance already exists there
- [ ] Then table B from the bottom up, sorted by `DIFF_DLIB`
- [ ] Case D alongside: bring modules with no source to `IDENTICAL-RAW`
      mechanically
- [ ] **Calibrate on the `IKJEFT` group.** Dave's 2024 CSECT compare provides a
      ready-made scale there: `IKJEFT40`, `52`, `53`, `54`, `56` differing by 2
      to 10 bytes at identical length, `IKJEFT35` (1,456), `IKJEFT45` (1,441),
      `IKJEFT55` (4,012), up to `IKJEFT01` (6,867) and `IKJEFT02` (10,899).
      Known numbers from easy to hard — ideal for calibrating the agent
- [ ] **Freeze before the first change of our own:** Git tag on the `IDENTICAL`
      state, with the objects stored as a reference. That is the branch point
      between recovery and development

**No longer the goal:** the BREXX integration. It was the occasion for the
original correspondence and still serves as a proving ground, but it is not a
project goal any more. `IKJ/REXX_INTEGRATION_PLAN.md` is history.

### 12. Back to MVS (M7)

- [ ] Generate `++PTF`/`++USERMOD` with JCLIN from the Git source — templatable
- [ ] Transport via `xmit370` and `RECV370`
- [ ] APPLY/ACCEPT on an MVS/CE **clone**, driven through mvsMF
- [ ] IPL and function test **autonomously on the clone**, per
      [`docs/runbook.md`](docs/runbook.md), with a mandatory wall-clock cap.
      Promotion to anything other than the clone stays with the user

### 13. Build MVS/CE from source (M8) — the end state

Not "apply PTFs" but "produce the system from our source".

The seam is in `sysgen.py`: **`step_03_build_dlibs`** produces the DLIBs from
`tape/zdlib1.het`; `step_04_system_generation` and everything after derive from
them. If the DLIB content comes from our source, the rest of the chain builds on
unchanged.

- [ ] Read `step_03_build_dlibs` in detail — the form and structure of its output
- [ ] Produce DLIB content from our source tree
- [ ] Run a sysgen with step 03 replaced
- [ ] IPL the result and compare it against a regular MVS/CE

**Acceptance:** an IPLable MVS/CE whose DLIBs came from our source.

---

## A strand of its own: SMPWRK3 analysis

⚡ Blocks nothing until M7 and needs no running MVS. Can run alongside at any
time.

> ⚠️ **Downgraded 2026-09-06 — this may not be an SMP defect at all.** Dave
> Kreiss writes that he and Fish diagnosed the intermittent I/O errors with
> Hercules traces and diagnostic builds, and that **Fish changed Hercules to
> eliminate them**. He believes the issue is history but wants to verify it on
> his rebuild. **Do not start the SMP source analysis** until that verification
> comes back — the whole strand may be chasing a fixed emulator bug.

The finding from Dave's mail of 2022-06-08: SMP resets the `SMPWRK3` directory
in the middle of APPLY/ACCEPT, does not notice, and carries on assembling; the
link-edit then produces non-executable load modules. The first FUNCTION affected
is APPLY of `EBB1102`.

**We have the SMP source locally** — 119 `HMASM*` modules in
`Dave Kreiss - MVS from Source/MVSBLD/`. The analysis can start immediately.

Concrete entry points from a first pass:

- [ ] **`HMASMIO`** (plus `HMASMIO1`, `HMASMION`) — the central I/O layer. Every
      SMP module calls it with a function code in `IOPFUNCT`; `IOPSTOWR` is "STOW
      replace". This is where directory handling converges, and the most likely
      place to find the defect
- [ ] The three modules that reference `SMPWRK3` by name: **`HMASMCMP`** (closes
      `SMPWRK3` to set the DEB for the interface module — conspicuous),
      **`HMASMDC2`**, **`HMASMPIN`**
- [ ] The four modules with `STOW` involvement: `HMASMDC1`, `HMASMDR2`,
      `HMASMCRW`, `HMASMRCC`
- [ ] Answer Dave's own open question: **can `STOW` clear a directory under
      MVS 3.8?** The STOW routine is SVC 21 = **`IGC0002A`** ("FIRST LOAD OF BPAM
      STOW ROUTINE"), in `MVSBLD/IGC0002A.ASM` and as a listing on
      `www.stben.net`. Follow the subsequent loads from there
- [ ] Form a hypothesis, then reproduce it deliberately

**A false trail to avoid:** `HMASMPIN` is one of the modules for which no source
existed and which Dave rewrote. That makes it look suspicious — it is not. Dave
reproduced the failure on a **fresh TK3 system with original SMP modules**. The
cause is in the original SMP, not in his reconstruction.

A second thought worth testing: the failure appears only on **large** APPLYs.
That smells of a limit — directory blocks, an extent boundary, a counter
overflowing. Dave's attempt to allocate `SMPWRK3` with a larger directory did not
help, which argues against plain directory size and for something else that
scales with volume.

---

## Decided

- [x] **Re-baselining is complete**, all libraries, comparison included
- [x] **Yardstick:** primarily the DLIB object deck, secondarily the target load
      module; the delta is the usermod/sysgen layer and is measured, not guessed
- [x] **Iteration budget staggered:** case B ≈ 30, case D ≈ 50, case C ≈ 150,
      plus a wall-clock cap
- [x] **The agent may IPL on the clone**, operational knowledge in
      [`docs/runbook.md`](docs/runbook.md)
- [x] **Repository language is English** — documents, issues, PRs, commits.
      German reference copies of the plan and the project analysis stay in
      `~/repos/MVSSRC/WORK/doc/`

## Still open

- [ ] **MVP packages:** a list only, or inventory their contents too?
- [ ] **Wall-clock caps** for IPL and jobs — will fall out of the first run
- [ ] **Reference release of MVS/CE** — proposal: v3.0.0, see item 1b
- [ ] **`IDENTICAL-RAW`:** do case-D modules stay as they are with absolute
      offsets, or does making them readable become a goal of its own later?
