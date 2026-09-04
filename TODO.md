# TODO — MVS 3.8j source recovery

As of 2026-09-04. The working list for [`docs/workplan.md`](docs/workplan.md).
The plan says *why* and *where to*; this list says *what next*.

**Key:** 🔒 blocks other work · ⚡ runs in parallel, blocks nothing ·
🚪 gate: the outcome decides how we proceed

---

## Immediate

### 1. ✅ Asked Dave about licensing — awaiting reply

- [x] Review and adjust the draft
- [x] **Sent** (2026-09-04)
- [ ] Follow up once after ~4 weeks, then let it rest

Blocks **publication only**, not the work.

**A data point on licensing, from an earlier mail:** Dave distributes
`BLDMVS.7z` publicly himself, through the turnkey-mvs group's file area, and
calls it *"freely downloadable"*. That is not a grant of licence, but it does
show an intent to share freely — useful if no answer comes.

### 1a. 🔒 Fetch the current BLDMVS.7z and reconcile

Dave names this as the **current level of the build process**:

```
https://groups.io/g/turnkey-mvs/files/MVS%203.8J%20Source%20Recovery/BLDMVS.7z
```

Our local copy is older: `BLDMVS.AWS` of 2021-09-16, instructions as PDF at
version 2.1 of 2020-07-05.

- [x] **Downloaded** — it is on disk as `~/repos/MVSSRC_BAK/BLDMVS.7z`, and
      readable with `tar -tf` (bsdtar handles 7z; no 7z tool is installed).
      It is **newer than our unpacked copy**: instructions 2023-08-06 against
      2020-07-05, `BLDMVS.AWS` 2023-12-01 against 2021-09-16. `NEW.ASM` grew from
      31 to 43 MB — plausibly the DSS370 work Dave mentioned in 2024 — and
      `UTL.ASM` from 4.2 to 5.3 MB
- [ ] Reconcile against `Dave Kreiss - MVS from Source/BLDMVS/`: newer
      instructions? newer tape? additional PTF series?
- [ ] If newer: refresh the `MVSBLD/` extract and re-run the 747 count
- [ ] Work through its precautions and its guidance on applying the 3390 changes
      to a running system

Should happen **before** item 5d — otherwise we measure against a stale working
state.

### 1b. 🔒 Move to MVS/CE v3.0.0

**Largely settled already** — mainframed767 was quicker. Current is
**v3.0.0 "UNEXPECTED SLOTH"** of 2026-08-01 (`MVSCE.release.v3.0.0.tar`,
199 MB). Locally we still have 2.1.4 of 2026-07-08.

The decisive part: `jcl/customize.jcl` now installs **OPNTERSE, UFSD, FTPD,
HTTPD and MVSMF** by default at sysgen time. The agent's main channel therefore
ships with the system; nothing has to be added.

- [ ] Download v3.0.0 and make it the **reference release**
- [ ] Confirm HTTPD and MVSMF really are in the release tarball (so far only the
      build recipe in the repository is evidence, not the artifact)
- [ ] **Check the levels:** which HTTPD, MVSMF, UFSD and FTPD versions are
      actually installed? See item 1c — the suspicion is that they lag. If so,
      update them through MVP ourselves
- [ ] Re-check [`docs/runbook.md`](docs/runbook.md) against v3.0.0 — device
      addresses, scripts, paths

### 1c. 🔒 First: release libc370, then relink all four packages

**The trigger is not in the four projects but one level below.** libc370 is the
base library of the whole ecosystem — a defect there is a defect in httpd, mvsMF,
ftpd and ufsd at once. libc370's own `TODO.md` puts it plainly:

> *"With #145/#147 done, every multitasking consumer wants a relink on the next
> release — now for four reasons, not one."*

#### libc370 status

Last release **v1.0.3 of 2026-08-23**. Since then `main` carries, among others:

| Date | Change |
|---|---|
| 08-26 | `fix`: `puts()` one critical section, `fclose()` teardown under the lock, `DEQ` keeps its scope bits (#147, items 2/1/4) — `sysunlock()` could never release before |
| 08-26 | `fix`: **SYNAD on the BSAM DCBs** — a genuine I/O error is now `ferror()`+`EIO` instead of an address-space-killing **S001** (#147 item 3) |
| 08-27 | `fix`: four duplicate externals removed (#151) |
| 08-30 | `feat(sysmac)`: `SPIE`, `TIME`, `WTOR`, `PUTX` added (#155) |

Plus #145 (internal writers, ownership-aware wrappers), merged before v1.0.3.

#### Status of the four consumers

All four were built against **libc370 v1.0.3** and need the relink:

| Project | Last release | Date | Own unreleased changes |
|---|---|---|---|
| httpd | v4.0.1 | 2026-08-25 | only the bump to `4.0.2-dev` + TODO notes |
| ufsd | v1.2.1 | 2026-08-23 | only the bump to `1.2.2-dev` |
| ftpd | v1.0.1 | 2026-08-23 | only the bump to `1.0.2-dev` |
| mvsmf | v1.0.0-**dev** (pre-release) | 2026-08-25 | **one real fix** (PR #359 / issue #210) |

Open PRs: none, in any of the four.

That three of them carry nothing of their own is therefore **not an argument
against a release** — the reason for the rebuild sits in libc370.

#### Order

- [ ] **Cut libc370 v1.0.4** — the fixes have been on `main` since 08-26 and are
      in no release
- [ ] Rebuild and release **httpd, ufsd, ftpd** against the new libc370
- [ ] Same for **mvsmf** — and take the opportunity to cut **a stable v1.0.0**
      rather than a pre-release. So far the only tag is `v1.0.0-dev`, while
      `MVP/desc/MVSMF` already says `Version: 1.0.0`, a version that does not
      exist upstream
- [ ] Update the version table in
      `~/repos/MVSSRC/WORK/doc/mail-mainframed767-mvsce-301.md`

### 1d. ⚡ Ask mainframed767 for an MVS/CE 3.0.1

Draft in `~/repos/MVSSRC/WORK/doc/mail-mainframed767-mvsce-301.md` (kept
outside the repository — it names a person and is not part of the work product).
**Send only after 1c**, otherwise the request names stale versions. The carrying
argument is then not "there are newer versions" but: *the base library had four
fixes every consumer needs a relink for — including one where an I/O error took
the address space down with S001.*

- [ ] Update the version table in the draft to the state after 1c
- [ ] Review, adjust, send as an issue or a mail
- [ ] Ask alongside: **which HTTPD actually lands in the build?** The MVP
      descriptor says 4.0.0, but `MVS-sysgen/SOFTWARE/HTTPD` still holds
      `HTTPD330` with a `build.log` of 2025-02-13. With 3.3.0 the mvsMF console
      services cannot work (they need `httpd ≥ 4.0.0-dev`, the `cgictx` API)
- [ ] Report two smaller points: `SCRIPTS/SHUTDOWN.RC` does not stop HTTPD or
      FTPD, and nothing starts them either (no `S HTTPD` anywhere in the
      repository; `COMMND00` has only `S NET` and the JES2 parms)
- [ ] Offer pull requests — and deliver them if accepted

**Not blocking.** If no answer comes we update the four packages through MVP
ourselves and document that as a step of baseline setup.

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
- [ ] Get the members out of that unload — currently blocked on
      [cc370#113](https://github.com/mvslovers/cc370/issues/113): `file370`
      recognises the container but parses zero members from a real MVS unload of
      an FB source library
- [ ] Read `COMPLMD` before implementing #110 — especially how it decides what
      counts as a difference
- [ ] Keep the extract as reference material; **no MBT project, no port**
- [ ] Revisit `MVSSMP38` when M7 comes around

### 3. 🔒 Build and test the tooling

> **Attempted 2026-09-04 on the Mac (arm64) — blocked.** Hercules itself
> compiles once `--with-included-ltdl` and permissive CFLAGS are used
> (`-Wno-implicit-function-declaration -Wno-int-conversion`, needed because
> modern clang rejects what this code assumes). It then **fails to link**: the
> external packages (crypto, decNumber, SoftFloat, telnet) ship prebuilt for x86
> only, and `BUILDING` confirms they must be built per architecture. Their
> CMake `build` script mis-constructs the source path on this layout
> (`<parent>/crypto64.Release/crypto does not exist`) and was not made to work.
>
> Docker is not installed on the Mac either.
>
> **Recommended way around it:** Hercules already works on `mvsdev.lan`. Run the
> extraction there and bring the artifacts back — macro libraries, load modules,
> DLIB object decks. The Mac then does what it is good at: as370, the comparator,
> the pipeline. That also matches where the instances are going to live, and it
> removes the arm64 build from the critical path entirely.
>
> If a local build is still wanted, the open question is simply how Hercules was
> built on `mvsdev` — the same recipe should work here.

- [ ] **Decide: extract on `mvsdev`, or make the local build work.** This is the
      one thing blocking items 5, 5b, 5c and the macro extraction in 7
- [ ] Build the Hercules DASD utilities: `dasdls`, `dasdpdsu`, `dasdseq`,
      `dasdcat`, plus `hetget` for the tapes
- [ ] Check they read the MVS/CE volume formats — the volumes are a mix of 3350,
      3380 and 3390
- [ ] Build and install cc370 freshly (`make && make install`), record the version
- [ ] Try `file370 -v` on a known load module

### 4. 🔒 Set up MVS/CE and freeze the baseline

- [ ] Unpack `MVSCE.release.v3.0.0.tar`
- [ ] IPL it, smoke-test JES2, TSO, SMP
- [ ] Take an **immutable snapshot** of the volumes with checksums →
      `baseline/checksums.txt`
- [ ] Get mvsMF running against MVS/CE — already installed in v3.0.0, only to be
      started and checked for level
- [ ] Adopt `/s HTTPD` after IPL and `/p HTTPD` before shutdown into the routine
      (`SHUTDOWN.RC` does not know HTTPD)
- [ ] Confirm `SYZJ201` is applied (`retcode` then arrives over the REST API;
      mvsMF adds `NOTIFY=` itself)
- [ ] Inventory the baseline → `baseline/mvsce-v3.0.0.md`: installed usermods,
      MVP packages, sysgen parameters, I/O gen
- [ ] **Confirm the DLIBs (`AOS*`) are on `smp000.3350`** — the whole yardstick
      depends on it. If not: load `zdlib1.het`
- [ ] **Evaluate the SMP CDS: which sysmods are ACCEPTed?** That decides how
      clean the DLIBs are as an oracle (see the plan, section 5)
- [ ] Enable the Hercules web console as a fallback (`conf/local/custom.cnf`:
      `HTTP PORT 8038 NOAUTH` / `HTTP START`)
- [ ] Verify [`docs/runbook.md`](docs/runbook.md) on the first pass — raise every
      procedure from 📄 to ✅, or correct it

Without this inventory nobody can later tell `DIFF-USERMOD` from `DIFF-UNKNOWN` —
the agent would grind itself down on explainable differences.

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

### 5. 🚪 End-to-end test: a single load module

- [ ] Pull one load module out of `mvsres.3350` with `dasdpdsu` — **with no MVS
      running**
- [ ] `file370 -v` shows its ESD dictionary
- [ ] Read out CSECTs, IDR records and eyecatcher
- [ ] Check the result by hand against the same module on the running system

**The most important early item on this list.** It answers whether host-side
extraction holds up at all. If it does, much of what follows is legwork. If it
does not, we replan before effort has gone in.

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

> **Measured 2026-09-04 — the gate holds. 49 % assemble cleanly.**
>
> 150 modules drawn at random from `MVSBLD/`, assembled with `as370 V1.0`
> (confirmed current: no change under `as370/src/` since that build):
>
> | Macro set | Assembled cleanly |
> |---|---:|
> | `SYS1.MACLIB` only (742 macros) | 56 (37 %) |
> | **+ `SYS1.AMODGEN` + `SYS1.APVTMACS` (1,269 macros)** | **73 (49 %)** |
>
> Macros extracted from a pristine MVS/CE 2.1.4 on `mvsdev` with `dasdpdsu`.
>
> ### Two traps in the extraction, both hit and both worth writing down
>
> **1. `dasdpdsu` writes raw EBCDIC with no record separators.** The members are
> RECFM=FB 80, so the output must be split into 80-byte records and translated.
> Feeding it raw makes the rate *drop* to 28.
>
> **2. Convert to a single-byte encoding, never UTF-8.** This one cost a
> wrongly-filed issue. Writing the members as UTF-8 turns EBCDIC `X'5F'` (`¬`)
> into two bytes, and every column after it shifts right. In `WTO` that pushed a
> comment's last character into byte column 72 — the continuation column — and
> as370 correctly reported a continuation that consumed the next statement. The
> fix is latin-1, where `¬` stays one byte. **Column positions are the whole
> contract in fixed-format assembler; any multi-byte encoding destroys them.**
>
> as370 catching this is worth noting rather than resenting: its deliberate
> stance that a statement-losing continuation is an error and not a severity-4
> warning (`270b22d`) surfaced a data-corruption bug in our conversion. A warning
> would have let 150 modules assemble against mangled macros and be compared in
> good faith.
>
> ### What the remaining 77 failures are made of
>
> Counted **per module**, by first cause — not per message. (An earlier note
> counted error lines and badly overstated `GOIF`: one module can raise it 79
> times. Only **two** modules fail on `GOIF`/`SET`/`DSW`, and both are the
> assembler itself, `IFNX3A` and `IFOX0I`.)
>
> | First cause | Modules |
> |---|---:|
> | missing macro `IEDHJN` (TCAM) | 10 |
> | undefined symbol | 7 |
> | missing macro `SMPPI` | 5 |
> | missing macro `BLSUALLS` (IPCS) | 4 |
> | addressability — no active `USING` | 4 |
> | relocatable duplication factor | 3 |
> | `DC/DS` type `S` — [cc370#108](https://github.com/mvslovers/cc370/issues/108) | 3 |
> | missing macros `JHEAD`, `IGGDEBD`, `IEEVRSWA`, `HMASMMGP` | 3 each |
> | missing macros `IHANVT`, `IEHPRE`, `HEWAPT`, … | 2 each |
>
> It is a **long tail of component-private macros**, not one blocker.
>
> **And all of them are on Dave Kreiss' tape.** Spot-checked ten of the missing
> names against `MVSSRC.BLD.SMP.LIB` in the 2023 package: every one appears as
> `++MAC(name) … SYSLIB(PVTMAC) DISTLIB(APVTMAC)`. His `PVTMAC` library is the
> answer for the whole tail, exactly as his documentation says — macros "which
> are in none of the distributed maclibs".
>
> **One catch:** the elements carry `TXLIB(SYM20104)`, so the macro text is not
> inline in the MCS. Where `SYM20104` lives still has to be found.
>
> **Conclusion:** as370 is not the bottleneck. The dominant cause is macros we do
> not have yet — an extraction problem, not a development problem.

- [x] **Extract `SYS1.AMODGEN` and `SYS1.APVTMACS`** — done on `mvsdev`
- [x] Reconcile `SYS1.MACLIB` from MVS/CE against `~/repos/mvs/sys1.maclib` —
      both have 742 members, so the local copy was genuine
- [x] Repeat the measurement with the full macro set — 43 %
- [x] **Located Dave Kreiss' `PVTMAC`** — the missing macros are all on his tape,
      as `++MAC(…) SYSLIB(PVTMAC)` elements in `MVSSRC.BLD.SMP.LIB`
- [ ] **Find `TXLIB(SYM20104)`** — the elements reference it rather than carrying
      the macro text inline, so the text is somewhere else on the tape
- [ ] Extract the macros and re-measure. This is the single biggest lever on the
      rate: missing macros are the first cause for roughly half the failures
- [ ] Re-measure once those macros are in, and again after cc370#115
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
