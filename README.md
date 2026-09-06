# mvs38src — MVS 3.8j from source

Recovering the MVS 3.8j source at **DLIB level**, so that MVS/CE can be built
from that source in future.

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
2. **Building MVS/CE from that source.** The seam is in the MVS-sysgen project's
   `sysgen.py`: `step_03_build_dlibs` produces the DLIBs from IBM's `zdlib1.het`
   tape, and everything after it derives from those DLIBs. If the DLIB content
   comes from our source, the rest of the chain builds on unchanged.

## Why this is work at all

The source IBM shipped does not match the object code IBM shipped. The object
carries maintenance levels the source never received. Closing that gap is the
task.

The success criterion is objective: **the assembled CSECT is byte-identical to
the DLIB object deck, or it is not.** That is precisely what makes the work
automatable.

## How it works

Recovery runs **on the host**; MVS is only an oracle and a runtime. Assembly is
done with `as370` from [cc370](https://github.com/mvslovers/cc370), comparison
with `cmplmd370` (to be built). An agent works through a module list; SMP only
comes in at the end of the chain.

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
