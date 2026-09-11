# Open decisions

2026-09-11, after the night shift. Everything here needs Mike, not me — because
it is his machine, because it reaches outside, or because it is a question of
direction. Ordered by how much it blocks.

> This file was written in German and committed as `entscheidungen-offen.md`.
> That breached this repository's own rule — "everything written into this
> repository is English", commit messages included — and I broke it twice in one
> commit. I had applied the *archive* repo's convention, which is the CLAUDE.md
> that sits in my context, to a repo that has its own and says the opposite.
> Found by the structural audit, which corrected the brief I had given it.

## 1. Pin the reference system — blocks stage 1

`MVSCE-LAB` has lost its value as a reference. Its `SYS1.AMACLIB(IHADVCT)` sits
at the level **before** APAR `@ZA40405`, while the 5,528 reference decks prove
IFOX00 read the maintained one. Re-running the oracle on LAB would not reproduce
the corpus. Evidence in `missing-macros.md`.

Since that was written, `MVSCE-EXP` has answered the question the corrections
left open. Stock MVS/CE does not ship `IHADVCT` in `SYS1.AMACLIB` **at all**
(HTTP 404, against a control member returning 5,832 bytes in the same batch), so
LAB's copy was *added* rather than degraded — and **`MVSTK5-REF` carries exactly
the level the decks demand**: 203 lines, `@ZA40405` nine times.

That turns pinning TK5 from an argument by elimination into a positive one.

`tools/systems.json` has `MVSTK5-REF` at `submit: false`, `oracle: false`. While
no system carries `oracle: true`, no oracle run is possible at all — deliberate,
and fail-closed.

What waits on this:

* stage 1 of the roadmap, the corpus run over 5,528 modules
* the single reference deck in item 2
* cc370's parked question, whether a literal blank `CSECT` card resumes its
  counter or restarts it — it needs one clean fixture through a pinned oracle

**To decide:** does `MVSTK5-REF` become the oracle? And if so, how is it frozen?
A snapshot of the libraries before anything writes to it is the minimum, or it
drifts the way LAB did.

## 2. cc370 PR #359 — option A or B

cc370 captured an oracle deck on `mvsdev.lan:8080` overnight. That is
`MVSCE-DEV`, your development machine. **The fault was mine**: I told cc370 which
systems were off limits and never which port was which. cc370 reported it
unprompted, before anything merged.

Footprint **as cc370 reports it, not verified by me** — I have not touched DEV
and will not: two spool entries (`ASMORCL` JOB00220/00221, MSGCLASS=H), one
`IFOX00` run against `SYS1.MACLIB` at `DISP=SHR`, and
`IBMUSER.CC370.ORACLE.OBJ` deleted in both cases. Nothing catalogued.

| | |
|---|---|
| **A** | drop the deck and listing from `#359`. The fix stays green, but `#290` loses its byte-exact acceptance test. |
| **B** | keep both, marked provisional, and recapture on the pinned oracle. |

cc370 and I both lean **B**, for the same reason: the deck is probably correct,
so A pays an acceptance test for a provenance question one job settles. Neither
of us has touched the branches.

Separately: `#290` is implemented, `IECVHDET` is byte-identical, and the
private-code fix gains **+3** with nothing lost. Parity on cc370's branch is
**5,431 of 5,528**. Both wait on a human merge.

## 3. Credentials in tracked files — convention, not exposure

Nine tracked files here carry `HERC01/CUL8TR` or `IBMUSER:SYS1` — four documents,
five tools, all predating yesterday.

The facts: these are the **published default credentials** of TK5 and MVS/CE on a
LAN-local emulator. Nothing is exposed that a reader could not look up in either
distribution's own documentation. Not an incident.

Still open, because `CLAUDE.md` gitignores `.env` for a reason, publication of
this repo still waits on a licensing answer, and history keeps the strings
whatever a later commit does.

**To decide:** pull them into an ignored `.env` (five tools, four documents to
touch) — or leave them, on the record that they are published defaults. I did not
do it unprompted because it is convention rather than urgency, and because
rewriting five tools during a build run is how a running build stops.

## 4. Smaller things

* **Two spool entries on DEV** from item 2, if you want them gone.
* **`TODO.md` is German**, and has been since the repository's first commit on
  2026-09-04, across 95 commits. That is an established exception to the language
  rule rather than a slip, so I have left it alone — but it is either an
  exception worth writing into `CLAUDE.md` or a file worth translating, and only
  you can say which.
* **`bldrun.py` is now in the repository** (`eb3a73e`); it existed only on mvsdev
  before. The FTP fallback (`da807f2`) is tested and deployed.
* **`$02ASM` and `$08STG1A`** still end `CC 0024` and `CC 0020`. Both are
  demonstrably harmless, reasoning in `dave-install-log.md`. I suggest leaving
  them: one builds a utility nothing uses, the other heals itself nine jobs later.
