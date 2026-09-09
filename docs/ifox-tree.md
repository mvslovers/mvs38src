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

Throughput, measured: 3.6 minutes per 150 modules over FTP, 4.9 over REST. IFOX00
itself needs about **0.4 s per module** — 50 to 60 s of each batch. The transfers
dominate, and so does one deliberate limit: `DISP=OLD` on the punch library
serialises the assemblies, so a fourth initiator would add nothing. Measured on
the job start times, which form a staircase rather than overlapping.

## How the source gets there, and why not the other ways

**Not through the reader.** mvsMF closes the connection on a 2.9 MB submission;
twenty modules with their source in-stream is already that big. The sources go up
into a PDS and the job reads `SYSIN` from there, which makes a 25-module job
12 KB of JCL.

**Uploaded serially.** Three FTP sessions storing into one PDS put 47 of 150
members there and reported success. Uploads are serial ever since, over either
transport, and the PDS directory is read back and compared against the batch.

**Punched with `DISP=OLD`.** Six jobs punching into one object PDS with
`DISP=SHR` filed **20 of 244 decks under the wrong member name** — the member
`AHLMCIH` held the object of `IEE4803D`. `DISP=OLD` makes MVS serialise the data
set per step; the assembly time went from 43 s to 60 s per 150 modules, which is
the whole price.

**Fetched byte-exact, first over FTP and then over REST.** A deck must come back
byte for byte; the *spool* route cannot do it, and after the FTP server wedged
mid-run the transfers moved to the REST files API, which can — see *What broke*
below.

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

**The localiser checked against a second tool.** `ifox_cluster.py` rebuilds each
section from the TXT cards to say where the two decks part company. `cmplmd370`,
written independently, reports the same section lengths on the cases checked:
`IGG019PF` 265 against 144, `IGG019MY` 343 against 216, `IDCLC01` 16,548 both
with four differing bytes.

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

## What it found

*Figures below are against `as370` at cc370 **3d6a997** — distance **123** from
`main` — #164, #165 and #166 merged, re-baselined 2026-09-07. #166 changed the
diagnostics path only and moved **no deck: 0 of 5,518 differ by sha256**, so every
figure here is the same as at `879e86a` (distance 126). The run that established
the method was against `ee1090b` (distance 130); both numbers are given where the
change matters. **This is the founding run and its figures are kept as that
record — none of them is current.** On `7a0cd90`, distance 0 at writing, the same
comparison gives 5,424 of 5,528 (98.1 %) on `1112488`; the map is
[`what-is-left.md`](what-is-left.md).
[`work/measurements/ifox-run/as370-baseline.txt`](../work/measurements/ifox-run/as370-baseline.txt)
records which build every figure belongs to. The IFOX00 side does not move.*

All 5,528 modules assembled both ways, 5,518 with a deck on the host side.

**`as370` and IFOX00 produce the same object for 3,559 of 5,528 modules —
64.4 %**, up from 3,466 (62.7 %) before the two fixes landed. Of the rest, 1,242
differ in bytes at the same length, 717 differ in the number of cards, and 10
produced no deck locally.

**The ten without a deck, so the gap is never read as new:** eight EREP modules
abort at `rc 2` — `IFCED155`, `IFCEG155`, `IFCEL155`, `IFCEM155`, `IFCEXXXH`,
`IFCSGUS1`, `IFCSXXXF`, `IFCSXXXH` — and two never terminate, `HEWLDIOC` and
`IFNX1A` ([cc370#163](https://github.com/mvslovers/cc370/issues/163)). IFOX00
assembles all ten at `rc 0`.

| Return codes | IFOX 0 | IFOX 4 | IFOX 8+ |
|---|---:|---:|---:|
| **as370 0** | 4,195 | 21 | **96** |
| **as370 8+** | **376** | 3 | 837 |

### Whose problem each module is

| | Modules | before the merge |
|---|---:|---:|
| **the assembler — for cc370** | **2,021** | 2,112 |
| — silent divergence: both clean, object different anyway | 1,169 | 1,113 |
| — both flag, and the decks differ | 380 | 393 |
| — as370 rejects what Assembler XF assembles | 366 | 512 |
| — IFOX00 flags, as370 is silent | 96 | 84 |
| — no deck on one side | 8 | 8 |
| — as370 does not terminate | 2 | 2 |
| **the source — ours** | 3,507 | 3,416 |

**A fix does not only remove cases, it reclassifies them.** `as370 alone flags`
fell by 146 — 93 of those became byte-identical, and **56 moved into silent
divergence**, which is the harder class. `IFOX00 alone flags` rose from 84 to 96
for the same reason: as370 fell silent where XF still objects. The
`Relocatable displacement` class grew from 29 modules to 44 because modules that
used to fail earlier now reach it.

### On the population the project's own figures are about

Modules `as370` assembled cleanly that have a DLIB counterpart — 3,877 of them:

| | Modules | | before |
|---|---:|---:|---:|
| source | 1,432 | 36.9 % | 1,357 |
| **tool** | **1,118** | **28.8 %** | 1,052 |
| **recovered — all three agree** | **879** | **22.7 %** | **869** |
| source, `DS` holes only | 448 | 11.6 % | 441 |

**Ten more modules are byte-identical to IBM's shipped object** than before the
merge. That is what the two fixes were worth where it counts.

**The attribution predicted correctly.** All 93 modules the fixes turned
byte-identical to IFOX00 were rows this table had booked to the assembler — not
one to the source. It is the first independent evidence that the ownership column
means what it says.

## What broke, and what it cost

**The MVS FTP server wedged after 3,900 modules.** It accepted the connection
and never sent a banner again — to `tnftp` and to `ftplib` alike — and killing
every client did not free it. The stall was not the worst of it: the session it
left behind held `IBMUSER.IFOXOBJ`, so every `DISP=OLD` allocation on that
library waited for ever, and the assemblies stopped with it. Measured rather
than guessed: the same job punching into a fresh data set finished in under a
second.

The run continued without restarting anything on the system, because **the REST
files API does what the spool route could not**:

| | |
|---|---|
| deck download | `X-IBM-Data-Type: binary` — byte-exact. **Without that header a 320-byte deck comes back as 96 bytes, and nothing says so** |
| source upload | `PUT .../ds/PDS(member)` — controlled: the same source uploaded this way assembles to a deck identical to the one from the FTP-uploaded source |

The earlier note that REST cannot return an object deck byte-exact
([`ifox-oracle.md`](ifox-oracle.md)) is about **spool files** and stands; for a
data set on DASD it does not apply.

Cost of the switch: upload 1.8 s a member against 0.7 over FTP, download three
times faster, 4.9 minutes a 150-module batch against 3.6.

## The per-module table

[`work/measurements/ifox-run/module-table.tsv`](../work/measurements/ifox-run/module-table.tsv)
carries one row per module: what each assembler returned, how many statements it
flagged, its highest severity, its messages, the deck verdict, the offset where
the two decks part company, both section lengths, and the DLIB verdict. The rows
are sorted so the hand-over list is one contiguous block at the top;
`for-cc370.tsv` and `for-cc370.txt` are that block on its own.
