# The tree-wide IFOX00 comparison

2026-09-07. Every module in `MVSBLD/` is assembled twice — once by `as370` here,
once by the real Assembler XF (`IFOX00`) under MVS/CE — and the two object decks
are compared. This document is the method and its controls;
[`ifox-oracle.md`](ifox-oracle.md) is where the method was found on thirty
modules.

## What the comparison is for

A difference between an `as370` deck and a distribution library member has two
possible causes, and against the DLIB alone they cannot be told apart:

1. `as370` does not assemble the way IFOX00 does — **a tool question**
2. Dave Kreiss' source is not what IBM assembled — **the project question**

Assembling the *same source* with both assemblers, against the *same macro
libraries*, removes the first from the second. What differs there is the tool and
nothing else; where the two agree, every remaining difference against the DLIB
belongs to the source or to IBM's maintenance.

## The run

| | |
|---|---|
| modules | all 5,528 in `MVSBLD/`, in randomised order after five controls |
| local assembler | `as370` at cc370 `ee1090b`, built from a `git worktree`, pinned for the whole run |
| remote assembler | `IFOX00` on `MVSCE-EXP`, `PARM='DECK,NOLOAD,NOLIST'`, `REGION=1024K` |
| comparison | columns 1–72, `END` card excluded |
| driver | [`tools/ifox_run.py`](../tools/ifox_run.py), resumable, state in `work/measurements/ifox-run/state.tsv` |
| attribution | [`tools/ifox_compare.py`](../tools/ifox_compare.py) |
| localisation | [`tools/ifox_cluster.py`](../tools/ifox_cluster.py) |

Throughput, measured: 150 modules per 3.5 minutes — 95 s to upload the sources,
60 s to assemble them, 55 s to fetch the decks. IFOX00 itself needs about
**0.4 s per module**; the transfers dominate.

## How the source gets there, and why not the other ways

**Not through the reader.** mvsMF closes the connection on a 2.9 MB submission;
twenty modules with their source in-stream is already that big. The sources go up
by FTP into `IBMUSER.SRC` and the job reads `SYSIN` from the PDS, which makes a
25-module job 12 KB of JCL.

**Uploaded serially.** Three FTP sessions storing into one PDS put 47 of 150
members there and reported success. Every batch is now uploaded in one session
and the PDS directory is read back and compared against the batch.

**Punched with `DISP=OLD`.** Six jobs punching into one object PDS with
`DISP=SHR` filed **20 of 244 decks under the wrong member name** — the member
`AHLMCIH` held the object of `IEE4803D`. `DISP=OLD` makes MVS serialise the data
set per step; the assembly time went from 43 s to 60 s per 150 modules, which is
the whole price.

**Fetched over FTP in binary.** `SYSPUNCH` does not come back byte-exact through
the REST API, not even with `X-IBM-Data-Type: binary`.

## The controls

Each of these has caught a wrong reading, most of them in this run:

**The five hand-measured modules run first.** `IGG026DU`, `IEFJDSNA`,
`BLSUZZ2R`, `IGG019JP` identical, `AHLMCIH` differing in one TXT card — the
verdicts recorded on 2026-09-06 reproduce byte for byte. Their decks also
reproduce across two runs on different days, once the two rules are applied.

**A deck must belong to its module.** The first section name in the IFOX deck is
compared against the one `as370` produced from the same source. Not against the
member name: `IFNX5P` legitimately assembles a section called `IFNX5P00`, and a
check against the member name would have called that a fault while missing the
real ones. This is the control that found the misfiled decks.

**Both sides see the same macros.** The seven libraries in `SYSLIB` are the seven
`-I` directories `gate.sh` passes, in the same order. Verified: member counts
equal in all six distribution libraries (566, 288, 243, 100, 139, 242), the 444
private macros identical by name on both sides, and 25 members drawn at random
across the six libraries identical byte for byte.

**All 80 columns.** The upload is checked by a round trip — one member fetched
back in binary, 1,255 records identical including the sequence numbers.

**`NOLIST` is not `SYSPRINT DD DUMMY`, but it is close.** Measured: Assembler XF
writes **nothing at all** to `SYSPRINT` under `NOLIST` — not even the
diagnostics. So this pass records the return code per step, which is what
separates "IFOX00 flags" from "IFOX00 is content", and a second pass with `LIST`
fetches the messages for the modules whose verdict needs them. Controlled:
`LIST` and `NOLIST` produce the identical object deck for the same module.

**The assembly stamp is settled by re-assembling, not by masking.** A module
whose decks differ is assembled again locally with the date and time *that* IFOX
run used — the date from the deck's own `END` card, the time from the step's
start in `JESYSMSG`. Control: a source of `DC C'&SYSDATE'`/`DC C'&SYSTIME'`
assembled with two different `ASMTIME` values produces two different decks, so
the mechanism is known to work.

**The two comparison rules.** The `END` card is excluded — each assembler names
itself there, `15741SC103` against `ASM370`, and the card also carries the
assembly date, so two IFOX runs on different days differ in it. Columns 73–80 are
excluded — they are the card sequence number, and `BLSUZZ2R` first showed all
five cards "differing" entirely there.

## What the run records

`work/measurements/ifox-run/`:

| File | Contents |
|---|---|
| `order.txt` | the module order: five controls, then a fixed shuffle (seed 20260907) |
| `state.tsv` | per module: IFOX return code, step start time, deck size, job |
| `verdicts.tsv` | per module: `as370` rc, IFOX rc, tool verdict, verdict after re-stamping, DLIB verdict |
| `tool-diffs.tsv` | per differing section: both lengths, the first differing offset, how many bytes |
| `msg/` | every job's `JESYSMSG`, gzipped — the return codes and step times come from here |
| `decks/`, `as370/`, `restamp/` | the object decks; reproducible, so not in git |

Because the order after the controls is a fixed shuffle, **any prefix of the run
is an unbiased sample of the tree**: the split can be read off before the run
finishes, and it does not move systematically as it completes.
