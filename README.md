# mvs38src — MVS 3.8j from source

**MVS 3.8j at maintenance level 8505, built from source.**

The object code IBM shipped carries maintenance the shipped source never
received. Recovering that source therefore means answering one question, module
by module — **which sources do not yet assemble to the object in TK5's
distribution libraries?** — and then closing the gap. Dave Kreiss got part of
the way; this continues his work rather than restarting it.

## The goal, as reformulated on 2026-09-16

**Every module explained, as many as possible byte-identical, and a system that
builds and runs from those sources.**

Two verdicts, and **both are machine-decidable**. Nothing else counts.

| | |
|---|---|
| **recovered** | `cmplmd370` exits 0 — the assembled CSECT is byte-identical to the object IBM shipped |
| **explained** | every differing byte is attributed to a named, accepted class, and none is left unattributed |

**Why a second verdict.** Five macros — `SCHEDULE`, `TSCBD`, `GETMAIN`/`FREEMAIN`,
`SETFRR`, `XCTL`/`IHBINNRB` — are measured to exist at **two levels**, with the
split running **per module** every time. The only model that fits is that IBM
assembled its modules over years against a macro library that moved between
assemblies, so **no single macro library reproduces them all** and for some
modules byte-identity is unreachable with any surviving material
([`docs/macro-attribution.md`](docs/macro-attribution.md)).

**"Explained" is a measurement, not a reading.** A module with one unattributed
byte is not explained, however convincing a disassembly of it looks. The accepted
classes are a macro at a level we do not have, alignment fill in the bound member,
the assembly date or `SYSPARM`, and displacements shifted as a consequence of one
of those. `tools/macroattr.py` and `tools/lenattr.py` do the attributing.

> **`8505` is measured, as of 2026-09-12, and it holds for 98.1 % of the
> corpus.** The IDR records in all 3,988 distribution-library members were read —
> 3,988 of 3,988 readable — and **3,912 carry a link/translate date of 1985 or
> earlier.** The remaining **76 carry service after 1985**, running to 1990 and
> concentrated in TSO (`IKJ*`, 33 of the 76). So the goal is the right
> description with a named exception, and a tree that reached 8505 everywhere
> would still miss those 76.
> [`docs/maintenance-level.md`](docs/maintenance-level.md).

<!-- scoreboard:start -->

### How much of MVS 3.8j rebuilds byte-identical to what IBM shipped

The assembled CSECT is byte-identical to IBM's, or it is not. Nothing else counts.

| | CSECTs built | **identical to IBM's** | |
|---|---:|---:|---:|
| `SYS1.LPALIB` | 2,343 | **290** | 12.4 % |
| `SYS1.LINKLIB` | 1,721 | **468** | 27.2 % |
| `SYS1.CMDLIB` | 753 | **229** | 30.4 % |
| `SYS1.NUCLEUS` | 354 | **334** | 94.4 % |
| `SYS1.TELCMLIB` | 192 | **32** | 16.7 % |
| `SYS1.VTAMLIB` | 63 | **10** | 15.9 % |
| `SYS1.SVCLIB` | 59 | **59** | 100.0 % |
| **total** | **5,485** | **1,422** | **25.9 %** |

Measured a second time from the other side, on the host against TK5's distribution libraries: **1,221 of 5,353** — 22.8 %. Two different programs, two different populations, two machines.

**With the source recovered so far**, the same measurement reads **1,561 of 5,353** — 29.2 %. The first figure says how far Dave Kreiss got; this one says where the project is. Both are wanted.

> **`src/` no longer contributes +1 apiece to this figure, and that is deliberate.** It held until 2026-09-12, when every module in `src/` was repaired against the DLIB. **7** are now repaired against the **target** instead and therefore differ from the DLIB by exactly the amount they used to differ from the target — one source cannot reach two different objects. The figure that counts `src/` under the chosen baseline is the next one down.

### Under the baseline the project chose on 2026-09-13

Dave Kreiss: *"target not DLIB is the version of code you should compare to since target is what the running system uses."* Measured ([`docs/baseline-dlib-vs-target.md`](docs/baseline-dlib-vs-target.md)), the two baselines **disagree about 57 modules** of the 4,512 that have a member in both, so the yardstick is now **TK5's target library where the CSECT has one, its DLIB where it does not**:

| | modules | |
|---|---:|---:|
| **recovered under the chosen baseline** | **1,626 of 5,353** | **30.4 %** |

The figures above it are not withdrawn and do not contradict it: the same decks are identical to **1,633** DLIB members, **1,476** target members, and **1,451** of both. **2 modules are counted as not recovered because `cmplmd370` does not pair their target member** — the deck names a CSECT the member does not carry. **None of them is called identical by the DLIB either**, so nothing is being withheld from the count by the instrument. A further **839** have no target counterpart at all, and for those the DLIB is the only object there is.

### The second verdict, since the goal was reformulated on 2026-09-16

**Every module explained, as many as possible byte-identical.** A module is *explained* when every differing byte is attributed to a named, accepted class and none is left over — a measurement, not a reading ([`tools/explained.py`](tools/explained.py)).

| | modules | |
|---|---:|---:|
| `recovered` — `cmplmd370` exits 0 | 1,626 | 30.4 % |
| `reachable` — identical under a named macro reconstruction | 21 | 0.4 % |
| `blocked` — attributed, but no reconstruction exists to prove it | 72 | 1.3 % |
| **explained** | **1,719 of 5,353** | **32.1 %** |
| unexplained | 3,634 | 67.9 % |

**The `blocked` rule is narrow on purpose.** One differing byte in open code and the module is unexplained, however obvious its cause looks. That is why the tier is small and why the figure can be trusted.

> **Not to be confused with the tool figure.** `as370` reproduces IFOX00's deck for **5,471 of 5,528** modules — that says our assembler is trustworthy, not that the source carries the object's maintenance level. A module is routinely in that 98 % and not in the table above, and that gap is what this project is about.

<!-- scoreboard:end -->

Built on **Dave Kreiss'** *Build MVS from Source* — his reconstructed source,
his `DSK*` PTFs, his build jobstreams and his utilities. He answered on
2026-09-06 that this work may be released as **freeware, with no copyright and
no terms**, and asked to be credited by name and email:
**Dave Kreiss, davekreiss@gmail.com**. Without his fifteen years on it there
would be nothing here to recover.

## The goal, in two stages

1. **A source tree at the DLIB level of MVS 3.8j** — distribution-independent,
   so not "source for our MVS/CE" but source for MVS 3.8j. That is the trunk;
   everything beyond — a BREXX integration, 3390 extensions, whatever comes — is
   development branching off from there.
2. **Building a distribution from that source.** The seam is in the MVS-sysgen project's
   `sysgen.py`: `step_03_build_dlibs` produces the DLIBs from IBM's `zdlib1.het`
   tape, and everything after it derives from those DLIBs. If the DLIB content
   comes from our source, the rest of the chain builds on unchanged. MVS/CE is
   the distribution that seam was written for; **the object baseline this
   project measures against is TK5**, decided on 2026-09-10 in
   [`docs/fahrplan.md`](docs/fahrplan.md). Those are not in conflict — the
   source tree is meant to be distribution-independent, and TK5 is the
   yardstick, not the destination.

## Why this is work at all

The source IBM shipped does not match the object code IBM shipped. The object
carries maintenance levels the source never received. Closing that gap is the
task.

The success criterion is objective: **the assembled CSECT is byte-identical to
its counterpart in the distribution library, or it is not.** That is precisely what makes the work
automatable.

## How it works

Recovery runs **on the host**; MVS is only an oracle and a runtime. Assembly is
done with `as370` from [cc370](https://github.com/mvslovers/cc370), comparison
with `cmplmd370` from the same toolchain. An agent works through a module list;
SMP only comes in at the end of the chain.

**The traffic goes both ways.** cc370's own test corpora are, without exception,
cc370 output — necessary, and unable to find a gap in cc370's own format
readers. The material here is not: 5,252 distribution-library members bound by
IBM's linkage editor, and 3,904 compared pairs in
[`work/measurements/tree-run.jsonl.gz`](work/measurements/tree-run.jsonl.gz).
Running it against the tools found four real defects on 2026-09-06 alone. When
something breaks, **send the case, not the diagnosis** — twice that day the
diagnosis was wrong and the case was not.

## Layout

| Directory | Contents |
|---|---|
| `docs/` | plan, runbook, analysis of Dave Kreiss' project, message drafts |
| `baseline/` | MVS/CE baseline: inventories, checksums, DLIB comparisons |
| `src/` | the recovered source, by target library |
| `tables/` | generated tables: ported / missing |
| `tools/` | pipeline and orchestrator |
| `work/` | derived material: the macro corpus, measurements, extracted utilities |
| `evidence/` | per-module chain of evidence: diffs, iteration history, reports |
| `ptf/` | SMP packaging: `++PTF`/`++USERMOD`, JCLIN |

**Raw material does not live here** but in `~/repos/MVSSRC`: Dave Kreiss'
install package and his working state (`MVSBLD/`, 5,529 modules), the
correspondence as PDFs, the TSO sources and two web mirrors.

## Start here

1. [`TODO.md`](TODO.md) — what to do next
2. [`docs/workplan.md`](docs/workplan.md) — why and where to
3. [`docs/kreiss-project.md`](docs/kreiss-project.md) — what we are building on
4. [`docs/runbook.md`](docs/runbook.md) — how things actually work

## Provenance and terms

- **Dave Kreiss' material** — freeware, no copyright, no terms, credited as
  above. `UTL31`, `LOADLMD` and `MAPLMD` are **deliberately not here**: they
  descend from the disassembler on CBT tape file 217 (R. Thornton) and their
  terms are unknown to him too.
- **IBM MVS 3.8 material** — macros and source extracted from a running MVS/CE
  and from public mirrors of MVS 3.8 source. It is distributed the way the
  hobbyist community has distributed it for decades.
- **Our own work** — tools, documents, measurements. Take it and use it.

## Language

Everything in this repository is **English** — documents, issues, pull requests,
commit messages, comments. German reference copies of the plan and the project
analysis are kept outside the repository, in `~/repos/MVSSRC/WORK/doc/`.
