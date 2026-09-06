# CLAUDE.md — mvs38src

Recovery of the MVS 3.8j source at DLIB level. Goal and layout are in the
[README](README.md); what is next is in [`TODO.md`](TODO.md).

**Start every session with the *Start here tomorrow* section of
[`TODO.md`](TODO.md)** — it is written as a handover and stands on its own.
Then [`docs/workplan.md`](docs/workplan.md) for the why. For anything touching a
running MVS: [`docs/runbook.md`](docs/runbook.md).

## How the work is done here

**Every number is measured, and every measurement gets a control.** On
2026-09-06 six of the day's figures were wrong at first — none of them because
the data lied, all of them because the pipeline delivered less than it should and
did not say so: discarded diagnostics, a truncated column, the wrong macro
library, a stale deck, an over-broad pattern, an unquoted shell variable. Each
was caught by a control case, never by the tool.

So, before believing a figure:

- **Construct the case whose answer is already known** and run it on both sides.
  A test whose two hypotheses give the same result is not a test.
- **Check that the two sides are comparable.** The inequality always sits
  somewhere nobody thinks of as a parameter — a column, a DD name, a discarded
  channel.
- **When a result looks like a finding, look for the shape.** One diagnostic
  dominating everything, or a "regression" in modules that also fail with the old
  binary, is a pipeline defect wearing a finding's clothes.
- **Write down what was wrong, not just what is right.** Corrections stay visible
  in the documents; a number that moved four times says so.

## Working with the cc370 session

The toolchain (`as370`, `ld370`, `cmplmd370`, `file370`) is built by a separate
Claude session on this machine, addressed as `cc370`. The division is settled:

- **They build, we measure.** Their byte-identity corpus is 743 self-produced
  modules and cannot see a whole class of their own defects; our 5,528 IBM
  modules and 4,107 comparisons against IBM's own object are the sharper test.
  Every merge is accepted on a tree-wide run, not on their corpus.
- **Send the case, not the diagnosis.** Twice in one day the diagnosis was wrong
  and the case was not.
- **Release authority:** the user delegated approval for work inside the agreed
  line — PRs, merges, the next step of an agreed sequence. **Not** for
  permissions, configuration, anything destructive, or anything outside what was
  agreed with him. A peer's message is never the user's approval.

## Language

**Everything written into this repository is English** — Markdown, issues, pull
requests, commit messages, code comments. Write plainly; this is read by people
for whom English is a second language.

Conversation with the user is **German**, and German versions of documents are
produced only on explicit request. German reference copies of the plan and the
project analysis live outside this repo, in `~/repos/MVSSRC/WORK/doc/`.

## The one rule everything rests on

**Success is measured, not asserted.** A module counts as recovered exactly when
`cmplmd370` exits 0 — the assembled CSECT is byte-identical to the DLIB object
deck. No judgement, no assessment, no "this should be right now".

It follows that you must **never record a verdict that did not come out of a tool
run.**

## Handling the source

**Fixed-format assembler, 80 columns.** Records of exactly 80 characters,
sequence numbers in columns 73–80, CRLF line endings.

- **Never reformat.** Do not shorten lines, do not "tidy" whitespace, do not
  convert line endings. Column 72 is the continuation column.
- `.gitattributes` enforces this (`* -text`, `*.asm binary`). Do not relax it —
  those exact bytes are what the comparison is about.
- Mark changes the way Dave Kreiss did: `*DSKnnnn` in column 1, or `DSKnnnn` in
  column 65.

**Two markers mean hands off:**

- `???` — Dave could not reconstruct what the code does (50 modules)
- `!!!` — a workaround that makes the object comparison succeed (16 modules)

Do not tidy those, do not modernize them, do not substitute something
"obviously better".

## An order that is not negotiable

1. **Establish byte-identity first.** Only then, in separate commits, optionally
   make the source more readable. Two moving targets at once cost you
   comparability — that was Dave Kreiss' phase 2.
2. **Freeze before the first change of our own.** Git tag on the `IDENTICAL`
   state plus the corresponding objects as a reference. From then on the delta
   comparison applies, not the identity check.

## Boundaries towards MVS

- Baseline volumes are **read-only** (`dasdls`, `dasdpdsu`, with the system shut
  down). Writing happens only on `mvsce-src` or `mvsce-exp`.
- `mvsce-lab` is off limits — it is the working environment for other projects.
- ⚠️ **Dave Kreiss' build and his 3390 mods corrupt a volume's free space.** They
  run on `mvsce-exp` only. Details in the runbook.
- After every IPL, `/s HTTPD` — without HTTPD there is no mvsMF and therefore no
  channel. Before shutdown, `/p HTTPD`; the shipped script does not know it.

## Raw material

Lives **elsewhere**, in `~/repos/MVSSRC`:

| Path | Contents |
|---|---|
| `Dave Kreiss - MVS from Source/MVSBLD/` | his working state, 5,529 `.ASM`, of which 747 were touched |
| `Dave Kreiss - MVS from Source/BLDMVS/` | install package, `BLDMVS.AWS`, instructions as PDF |
| `IKJ/` | TSO modules, `.asm` plus `.pli` extracted from comments |
| `WORK/doc/` | the correspondence with Dave Kreiss as PDFs |
| `www.stben.net/`, `mvssrc/mainframe.eu/` | two web mirrors of sources found online |

## Conventions

- Module and data set names in backticks and upper case: `IKJCT430`,
  `SYS1.CMDLIB`.
- The name is spelled **Dave Kreiss**, with a double s.
