# Re-testing an `as370` change — the gate, and it no longer needs MVS

2026-09-07. Every `as370` change is accepted or rejected on a tree-wide run
against IBM's own assembler. Until today that meant an hour on MVS; it now takes
ten minutes on the host, because **the 5,528 IFOX00 decks are recorded**.

## Why this works

The decks in `work/measurements/ifox-run/decks/` were produced by the real
Assembler XF under MVS/CE from the sources in `MVSBLD/` and the seven macro
libraries `gate.sh` passes. Same input, recorded output. Nothing about them
changes when `as370` changes, so they are a fixed reference — the expensive half
of the measurement was paid once.

The decks themselves are 30 MB and stay out of git, but **the reference is
archived**: `work/measurements/ifox-run/ifox-decks.tar.gz`, 8.5 MB, all 5,528.
Unpack it before the first gate:

```sh
tar xzf work/measurements/ifox-run/ifox-decks.tar.gz -C work/measurements/ifox-run
```

Re-running `tools/ifox_run.py run` would also produce decks — but from *that
day's* MVS/CE, not this one. The archive is the reference the recorded figures
belong to; a re-run is a new reference and has to be re-baselined.

## Before anything: check the PR's own CI

```sh
gh -R mvslovers/cc370 pr checks <n>
gh pr view <n> --json baseRefName         # is it stacked on another PR?
/opt/homebrew/bin/gcc-16 -O2 -Wall -Wextra -Werror \
    -Ias370/include -Icommon/include -o /dev/null \
    as370/src/as370.c common/src/mvs370.c common/src/obj370.c
```

**Real gcc is on this machine** — `/opt/homebrew/bin/gcc-16`. `/usr/bin/gcc` is
Apple clang and emits none of the diagnostics CI fails on. I first wrote that
this class was "structurally blind" to my gate; it was not, I had probed
`gcc-14`, `gcc-13`, `gcc-12` and stopped. **A tool absent from three guessed
names is not an absent tool.**

**Check the base branch before merging with `--delete-branch`.** cc370#213 was
stacked on #212, and deleting #212's branch on merge **closed** #213 — GitHub
will not reopen a pull request whose base branch is gone, and the base of a
closed one cannot be retargeted. It had to be re-opened as a new PR (#214) from
the same commit. Either retarget the child to `main` first, or merge without
`--delete-branch`.

**Do not merge a PR whose own run is failing, whatever the tree-wide numbers
say.** This gate measures object decks produced by *this* machine's compiler, and
that is structurally blind to a portability or warnings failure: `/usr/bin/gcc`
here is Apple clang and does not emit `-Wstringop-truncation` at all, so a
`-Werror` build that CI rejects passes clean locally.

cc370#208 was merged with its PR run already red — `strncpy(r->name, b, 19)`
flagged as a possible truncation — and `main` stayed broken until it was noticed
from outside. The source file already carried a comment about the previous
instance of the same class, in the same file, written after it happened the first
time.

## The recipe

```sh
cd ~/repos/mvs/mvs38src

# 1. build the candidate from a worktree -- never from a branch checked out in
#    ~/repos/mvs/cc370, that tree belongs to a live session
git -C ~/repos/mvs/cc370 worktree add /tmp/wt-<sha> <sha> --detach
make -C /tmp/wt-<sha> as370/as370

# 2. assemble the whole tree with it, keeping the deck whatever the return code
export ASMDATE=09/07/26 ASMTIME=12.00      # or 381 decks differ on the clock alone
tools/gate.sh /tmp/wt-<sha>/as370/as370 <label>

# 3. compare against the recorded IFOX00 decks
tools/retest.py obj_<label>
```

About ten minutes for step 2, seconds for step 3.

## What the output means

```
as370 == IFOX00 : 3910 -> 4192   (+282)
  gained  : 282  BLSCCLSE ...
  LOST    : 0
  decks closer to IFOX00 : 452
  decks FURTHER from it  : 2   IFCE2880(+1) IFNX1J(+1)
```

**The example is a real run** — cc370#175, the largest single change so far.
Every figure in this document names the run it came from, and the baseline moves
with each merge: it was 3,465 when this gate was written and 3,910 before #175.
A quoted figure without its build is worthless here.

**Report both numbers, always.** New agreements is the headline; modules that
moved out of the length bucket is the other half, and on cc370#142 it was five
times larger. A change can be worth taking on the second number alone.

**An identity lost is a regression**, whatever the total says. Two gained and one
lost is not "+1"; it is a gain and a break, and the break has a module name.

## The rules this gate had to learn

- **Keep the deck of a module the assembler calls failed.** Seven modules
  assemble byte-identical to IBM's object while returning non-zero. Earlier runs
  deleted those decks unseen.
- **Pin `ASMDATE` and `ASMTIME`.** 381 decks carry the assembly stamp; without
  pinning they differ between two runs on the same source.
- **Gate one commit at a time.** On `fix/as370-open-code-setc` the end-to-end
  figure hid which of two fixes carried the yield, and it was not the one the
  branch is named after. [`opencode-gate.md`](opencode-gate.md).
- **Compare columns 1–72 and exclude the `END` card.** Columns 73–80 are the card
  sequence number; the `END` card is where each assembler names itself and dates
  the assembly.

## A listing is not a deck, and it is reliable for different things

Three findings this week came out of an `as370` listing. **The two that were
wrong were the two where the listing was the only thing read.**

| | read from | verdict |
|---|---|---|
| cc370#224, `DC L'4.0'` misaligned | listing address column | **withdrawn** — the object images are identical, `L'4.0'` is doubleword-aligned at `x'08'` exactly as IFOX00 puts it |
| my `PREFL EQU` evaluating to zero | listing address column | **withdrawn** — `PREFL` is 4; the column shows the *location counter* at that card, not the symbol's value |
| cc370#223, `DC E'…'` giving `rc 8` | listing message and return code | **stood**, and was merged |

The pattern is not "listings mislead". It is that a listing is **faithful for what
it reports** — messages, statement numbers, return codes — and **not a substitute
for the object**: it prints at most eight bytes per statement, its address column
is the location counter rather than a value, and it renders alignment padding on
its own line in one assembler and folded into the next in the other.

**So take the verdict from the deck whenever the claim is about bytes, addresses
or values, and from the listing only when the claim is about what the assembler
said.** Both of us captured deck and listing and then reasoned from the wrong one.

## A completeness claim needs the list, not the count

cc370's `TODO.md` carried the sentence *"every other scanner in as370 already
special-cases the attribute apostrophe."* It sat above the defect that disproved
it for months: `dc_split` never tested for it, and #218 was worth +2 identities
on a construct **neither assembler diagnoses** — `rc 0` on both sides, and only
the bytes differ.

**A stale number invites recounting. A false claim of completeness forecloses the
question.** Nothing could contradict *"every other X"* until a defect did,
because there was no enumeration to check it against. When the sweep finished,
the readers were six, carrying three different letter sets — and **two of the
differences were correct**, which no count would have said either.

So a claim about a population carries its **list**. A count is already better
than a bare "all of them", and it is still unfalsifiable without the members.

## Names, not counts — the third and cleanest instance

Three population disagreements this week were settled by listing the members
instead of arguing the total, and each took one step:

| | |
|---|---|
| 17 against 32 | cc370's split had no `TXT` bucket; every module they listed, I listed |
| 1,642 against 1,271 | my RLD comparison keyed on ESDID, and mishandled `LD` |
| **126 against 135** | my regex `^\S+\s+EQU\s+\(` matched `*SZD` — **nine comment cards counted as code**, all in one module that already contributed real ones, so the module counts agreed and hid it |

The last is the sharpest: the totals differed, the module counts did not, and no
amount of comparing the two numbers would have found a `*` in column 1.

## A clean headline is not a clean gate

cc370#209's first gate read **`+1 IEDCSA, LOST 0`** — correct, and blind to the
fact that two modules had stopped assembling *at all*. `IFCE0115` and `IFCE0125`
assemble in 0 s on the baseline and never terminate on the candidate: an infinite
loop in a scan that the change was the first to reach. The identity figure was
right and had nothing to say about it, because a module with no deck cannot lose
an identity it never had.

**A deck that was produced and is not is a regression**, and `retest.py` now says
so in the same register as a lost identity. It is worse than a lost identity:
there is no object at all to compare, so every other line in the report silently
excludes the module.

**And the tool's own hint nearly caused the miss.** `retest.py` prints *"a deck
that comes and goes is usually the worker's alarm"* — true in general, learned
from `IFCEE155` and `IFCEL155`, and wrong here. What saved it was following the
rest of the sentence: *time the module alone*. Thirty seconds turned a dismissed
footnote into a hang. **A hint that is right most of the time is exactly the kind
that gets followed instead of the procedure it recommends.**

## Any count cancels — including the ones that look like inventories

`no-as370-deck : 10 -> 10` across cc370#182, and `retest.py` reported that
nothing had moved. `IFNX1A` had gained a deck and `IFCEE155` had lost one:

| | before | after |
|---|---|---|
| `IFNX1A` | does not finish in 240 s | 0.06 s, deck produced |
| `IFCEE155` | deck | killed by a 20 s alarm it needs 11.4 s to beat |

One was the largest single behavioural change in that merge and the other was an
artefact of this gate's own timeout. The count showed neither. The section below
had already made this argument about verdict counts — it applies to *every*
aggregate here, and the one that lied was two lines further down the same output.

**A deck that appears or disappears is a timeout until proved otherwise — and
"otherwise" has to stay reachable.** `HEWLDIOC` was written down here as a module
that "does not terminate in 300 s and never will within any alarm". The 300 s was
measured; the rest was a conclusion, and cc370#215 shows it was wrong. The module
was **hung** — an expression walk with no progress guard, live on `main` for
eleven months — and with the guard it assembles in 0 s, its image 4 bytes from
IFOX00's out of 5,056. Both of us had it in our runbooks as a fact about the
module. **A limit written down as a property of the thing measured stops being a
question.** An alarm cannot tell *slow* from *broken*; only sampling the running
process can.

Time the module alone, against a build from before the change, before believing it
is the code. `IFCEE155` and `IFNX1A` looked identical in the gate table — both
`rc 142`, both no deck — and one was a race while the other was real.

## Verdict counts are not enough to accept a "moves nothing" change

`retest.py` compares verdicts. A change that swapped two modules in opposite
directions would leave the identical count unchanged and pass. For a PR whose
claim is *no deck moves*, compare the decks themselves:

```python
import hashlib, os
h = lambda p: hashlib.sha256(open(p, "rb").read()).hexdigest()
base = "work/measurements/ifox-run/as370"
diff = [m for m in (f[:-4] for f in os.listdir(base) if f.endswith(".obj"))
        if h(f"obj_<label>/{m}.obj") != h(f"{base}/{m}.obj")]
```

cc370#166 was accepted on that test: **0 of 5,518 decks changed**, and the
membership of all seven Package A classes was unchanged as well — checked by
building both binaries and running the classification twice, rather than assuming
it from the diff.

## A documentation-only PR is checked on the binary, not the diff

A change that claims to touch no source is verified by building it and comparing
the binary against the current build byte for byte. cc370#176 and #179 were both
accepted that way. Reading the file list tells you what the diff touched; the
binary tells you what the compiler saw.

```sh
git -C ~/repos/mvs/cc370 worktree add /tmp/wt-pr <ref> --detach
make -C /tmp/wt-pr as370/as370
cmp /tmp/wt-pr/as370/as370 /path/to/current/as370   # must be identical
```

## Populations are provisional while the assembler moves

Any class list derived from `as370`'s own behaviour is a snapshot of the
assembler, not an inventory of the work, and it wants re-deriving after every
merge. Three instances in one day:

- **#174** removed a 63-character clamp on operand fields, and `IHANVT` (33
  modules) and `UCBDADVC` (32) — two of the three largest entries on the
  missing-macro hunting list — **dissolved entirely**. The modules that appeared
  to need them resolve them from a library we already had.
- **#154's reach** was read here as evidence about the `USING` table. It was
  evidence about `EQU` section attribution, and the wrong reading nearly buried a
  +282 fix inside a +108 one.
- **#178** took `as370 alone flags` from 233 to 236 while the three new entries'
  decks improved tenfold. The residual they expose is #154's class, previously
  hidden behind the defect that has just been fixed.

So a class count belongs next to the binary that produced it, the same way an
identity figure does — **and the file has to be re-derived, not just the number
in the prose.**

**Class proper, not symptom.** These lists hold the modules where `as370` flags
and IFOX00 is silent. Counting every module whose output carries the message
gives more than twice as many: 96 against 42 for addressability, because a module
dominated by another defect emits the message downstream — `IFCE0115` has 128
undefined-opcode and 100 undefined-symbol messages ahead of its 53 addressability
ones. The two numbers answer different questions and these files answer the
first.

## What must not be carried across a merge

Figures a peer derives from `as370`'s message output are not counts, and cc370
said so themselves on 2026-09-07:

- **A "modules carrying this construct" figure is not causation.** Their 56 for
  the IPK/PTLB class was modules that carry the construct, return rc 0 and differ
  from IFOX00. The number where the divergence was actually traced to that site
  is **48**, measured here by taking the gate's gained set and reading its case
  class. Take the traced number.
- **"Reach" figures owned by a first diagnostic are unsound** while as370 dumps
  its diagnostics by category rather than by source line. Fourteen mechanisms in
  cc370#153's comment carry reach figures of that kind: read them as isolation
  evidence with a witness each, not as counts. Only what a gate run measured is a
  count.

The rule underneath both: **a number enters this repository when a tool run
produced it, and it says which run.**

## After a merge

**First, promote the gate run.** Everything below reads
`work/measurements/ifox-run/as370/` and `as370-gate.tsv`, which are *the current
decks*, not the ones the gate just produced. Copy them across before measuring:

```sh
cd ~/repos/mvs/mvs38src/work/measurements/ifox-run
rm -rf as370 restamp && cp -R /path/to/obj_<label> as370
cp /path/to/<label>.tsv as370-gate.tsv
```

**`restamp/` goes with them.** It is a cache keyed by module name and nothing
else, so a stale entry is silently a different build's deck.

Skipping this does not fail — it reports. `ifox_compare.py` compares the stored
decks *and* re-assembles the differing ones with the binary on its command line,
so a run against last merge's decks with this merge's binary gave 4,340 where
both instruments, used properly, say 4,352. A figure from two builds at once, and
nothing in the output says so.

```sh
tools/as370_messages.py /path/to/as370   # both assemblers' messages, per module
tools/ifox_compare.py /path/to/as370     # attribution, tool against source
tools/module_table.py                    # the per-module table and for-cc370.tsv
tools/ifox_cluster.py                    # where the decks part company
tools/rebuild_classes.py /path/to/as370  # the case-class lists the issues link at
```

**An emptied class is the one it used to get wrong.** It collected into a
`defaultdict`, so a class with no members was never written and its file kept its
last non-empty contents. After cc370#182 took `relocatable-displacement` to zero,
the file still named the two modules the fix had repaired — the one file the tool
never rewrote was the one where a fix had succeeded completely. Every class is
seeded now and an emptied one prints `EMPTY -- close the issue by hand`.

**`rebuild_classes.py` is not optional and was added because it was skipped.**
After #175 and #178 the class files still held their pre-merge counts —
`addressability.txt` said 156 where the class was 42, and cc370#154 linked at it
the whole time. Six of the ten files were stale by up to a factor of four.

That regenerates [`cc370-cases.md`](cc370-cases.md)'s figures. The IFOX side does
not have to be re-run unless the *source* changes — and if it does, only for the
modules that changed: `ifox_run.py` skips what it has.

## `as370 -v` before believing a timing — 2026-09-09

`~/.local/bin/as370` is an **installed copy** and it goes stale. The gate runs
whatever binary it is given, which since the first tree run has been the freshly
built `~/repos/mvs/cc370/as370/as370`; the one on `PATH` was three weeks of
merges behind and nobody noticed, because nothing else uses it.

It cost ten minutes and nearly cost a wrong verdict. Re-timing `HEWLDIOC` for
cc370#163 with the `PATH` copy, it ran past 600 s — which would have said the
issue was still open. The current build assembles it in **0.066 s**, and the deck
the gate promoted at 23:17 that same evening is 8160 bytes with `rc 0`.

```sh
as370 -v                       # as370 V1.0 - Sep  7 2026   <- stale
~/repos/mvs/cc370/as370/as370 -v   # as370 V1.0 - Sep  8 2026
```

**A stale install answers every question with yesterday's assembler**, and it
answers confidently. Print the build date before any single-module measurement,
and use the repo path for everything the gate does.

## The three counts, and saying which one you mean — 2026-09-09

"What is left" has three legitimate values and they differ by fifteen:

| | |
|---:|---|
| 539 | decks that differ card-for-card |
| 531 | after the `&SYSTIME` restamp settles 8 of them |
| **524** | after the 7 excluded modules |

`module-table.tsv`'s `tool` column already carries the restamped verdict, so a
tool reading that column gets 531 and 524 for free. A script that compares the
decks itself gets 539 and looks like it has found eight regressions. **Both were
written in this repository, and for one evening they disagreed with no note
saying why.** Quote the third one, and name the filter whenever a figure is not
it.

**The three above are against `89fb177`, distance 29. On `7a0cd90` (distance 0 at
writing) they are 149 / 135 / 128** — the clock settles fourteen there, not eight.
The three-way shape is the durable part of this section; the values are not, and
they moved by a factor of four in two days.

## A cached input nobody re-derived — 2026-09-09

`module_table.py` reads `as370-messages.tsv`, and **nothing regenerated it for a
day.** It was eleven merges behind the promoted decks, so every signal split
reported from that table — silent vs `as370` alone vs both flag — described
yesterday's assembler.

It surfaced through a single module. `module-table.tsv` said `IEFVEA` returned
`rc 8` on a deck that had become byte-identical; the promoted `as370-gate.tsv`
said `rc 0`. **The gate row was right and the derived table was a day old.**

| what I reported | what it actually was |
|---|---|
| 149 silent / 62 `as370` alone / 76 both flag / 9 IFOX00 alone | **161 / 50 / 75 / 10** |

And the claim that grew out of it — *the silent group has not moved through eleven
merges* — was an artefact of a frozen file. It moved: 149 → 161, which is what a
silent-success class does as loud modules lose their diagnostics and keep a deck
difference.

**`module_table.py` now refuses to run** when `as370-messages.tsv` is older than
`as370-gate.tsv`:

```
STALE: as370-messages.tsv is older than as370-gate.tsv.
  Run  python3 tools/as370_messages.py <as370-binary>  first.
```

**The promote sequence is four steps, not three:**

```sh
rsync -a --delete obj_<label>/ work/measurements/ifox-run/as370/
cp <label>.tsv work/measurements/ifox-run/as370-gate.tsv
python3 tools/as370_messages.py <binary>      # <-- the one that was missing
python3 tools/ifox_compare.py <binary>
python3 tools/module_table.py
python3 tools/rebuild_classes.py <binary>
```

`rebuild_classes.py` is downstream of this too: it picks its population from
`module-table.tsv`'s `signal` column, so a stale messages file quietly selects
the wrong modules for every class.

## A class list cannot see a false diagnostic on a correct deck

`classes/*.txt` select modules where the deck **differs** *and* `as370` alone
flags. Two failure modes are invisible to that, and both are real:

| | example |
|---|---|
| the complaint goes, the deck stays | the eight `IFNX*` after cc370#262 |
| the deck goes, the complaint stays | `IEAVTRTH`, `IEAVTRTR`, `IEAVTRTS` |

The second needs a **census of the message across the whole tree with no deck
filter**. Taken that way, on merged `9606b53`:

| | modules |
|---|---:|
| IFOX00 clean and `as370` returns `rc 8+` | **62** |
| …of which the deck is already byte-identical | **9** |
| …of which the deck also differs | 53 |

`continuation-consumed` (cc370#158) is the pure case: **8 modules, all 8 with
byte-identical decks.** Fixing it gains no identities and removes a false `rc 8`
from eight modules — which the identity count cannot show and which is still a
divergence from the oracle.

## The other stacked-PR failure, and it is the quiet one — 2026-09-09

This document already says: **check the base branch before merging a stacked PR**,
because deleting the parent's branch on merge *closes* the child (cc370#213 →
#214, which had to be re-opened from the same commit).

Today the sibling happened, and it is worse because nothing complains.

cc370#274 and #276 were stacked, #276 based on #274's branch. I merged #274 first
— which is correct — **without** `--delete-branch`, so the child stayed
mergeable. Merging it then squashed it **onto its parent branch**, not onto
`main`. `gh pr view` said `state=MERGED`; `main` did not have the change.

```sh
git log --oneline origin/main --grep="USING operand beginning"   # empty
```

**A merged PR whose commit is not on `main` looks exactly like a merged PR.** The
only thing that caught it was checking `origin/main` for the fix by name after
merging — which I did because the promote step needs the binary, not because I
suspected anything.

Re-opening a PR from that branch does not work either: it comes up `CONFLICTING`,
because the branch predates the parent's squash. The repair is a **clean branch
cut from `main` with the same diff applied** — cc370#278, whose build was
byte-identical to the tree the gate figures came from, which is what made it safe
to merge on the existing measurement.

**The rule, in the form that covers both failures**: *retarget a stacked child to
`main` before merging its parent.* Deleting the branch loses the child loudly;
keeping it loses the change silently. Same omission, and only one of the two tells
you.

### And check the fix is in `main` by name

```sh
gh pr merge <n> --squash
git fetch -q origin
git log --oneline origin/main --grep="<a phrase from the title>" | head -1
```

Three lines, and they are the difference between a merge and the appearance of
one.

## The gate is not a well-formedness check — `deck_lint.py` — 2026-09-09

cc370 built a change for #290 that produced a **structurally malformed deck**: a
section chained at the wrong origin, its TXT landing on top of another section's,
its ESD entry gone while the TXT remained. The gate line read

```
+0    closer 1    LOST 0
```

**Green, on a deck no linkage editor would accept.** `retest.py` compares our
bytes with IFOX00's; it has no opinion about whether the deck is a deck. Every
merge tonight leaned on that line, and nothing anywhere was asking the other
question.

`deck_lint.py` asks it of one deck alone, with no reference:

1. every TXT card names an ESDID the ESD defines as SD, PC or CM
2. every TXT byte lies inside its section's declared origin..origin+length
3. no two sections overlap
4. every RLD position and relocation ESDID exists
5. no ESDID is defined twice

```
work/measurements/ifox-run/decks   5528 decks, 0 with a complaint
work/measurements/ifox-run/as370   5528 decks, 5 with a complaint
                                     sections overlap: BNGC3270 BNGCDISP
                                     BNGCLOCL BNGCMENU BNGCRMOT
```

**All five are the CICS modules in `excluded.tsv`**, which cannot resolve their
macros at all. Every one of the other 5,523 decks `as370` produces is well formed.

### The control caught two wrong rules before it caught anything real

**IFOX00's 5,528 recorded decks must pass.** They did not, twice, and both times
the rule was wrong rather than the deck:

| version | "found" | the actual error |
|---|---:|---|
| first | 1,855 IFOX00 decks | RLD continuation: `RRPP FAAA`, and bit `0x01` of the flag means the next item repeats R/P and is `FAAA` alone |
| second | 476 IFOX00 decks | an **LD** entry carries no ESDID and does not advance the counter, so every module with an `ENTRY` looked as though it defined an id twice |
| third | **0** | — |

Without the control, the first version reports 1,861 defective `as370` decks and
every one of them is a lie. **A validator with no known-good corpus is a random
number generator with good manners.**

## The gate measures the deck. It now measures the return code too — 2026-09-09

`as370 == IFOX00` has always been read off the deck. Mike asked the obvious
question — *if it is an error, as370 has to report it with the same RC as IFOX00*
— and the measurement says that is not a detail:

| | modules | of those, deck **byte-identical** |
|---|---:|---:|
| `as370` flags, IFOX00 clean | 33 | 9 |
| **IFOX00 flags, `as370` clean** | **118** | **115** |

**151 disagree and 124 of them have an identical deck**, so every deck-based
figure in this repository counts them as finished.

`retest.py` now prints both halves:

```
  return code agrees : 5377 -> 5377   (+0)
    as370 alone flags : 33 -> 33
    IFOX00 alone flags: 118 -> 118
  DECK AND RC BOTH   : 5210 -> 5210   (+0)
```

**`DECK AND RC BOTH` is the honest headline**: 5,210 of 5,528, against 5,348 on
the deck alone. *Those two, and the 33/118 above, are the figures on the day the
return code entered the goal. On `1112488`, distance 0 at writing: **5,403** deck
and return code, **5,424** on the deck alone (5,404 raw), `as370` alone flags
**3**, IFOX00 alone flags **4**, and `flagged-or-silent agrees` **5,517**.*

It takes the run's own `<label>.tsv` (or `--rc`), and compares *clean against not
clean* rather than the exact number — IFOX00 counts in multiples of four and a
severity is a severity.

### The 118 are almost one thing

```
105  IFO092 KEYWORD PARAMETER DATE UNDEFINED IN MACRO DEFINITION
103  IFO092 KEYWORD PARAMETER PTF  UNDEFINED IN MACRO DEFINITION
  9  IFO092 KEYWORD PARAMETER ALIGN UNDEFINED IN MACRO DEFINITION
```

The source calls `MODID DATE=…,PTF=…` and `SYS1.AMACLIB(MODID)` has the prototype
`&LABEL MODID &BRANCH=,&BR=`. IFOX00 is right to complain — the macro is an older
maintenance level than the source. **`as370` swallows it without a word**, and
that is cc370#162.

**It is the largest single item on the board and it looks like nothing**: the gate
will score it `+0` on decks, because 115 of the 118 are already byte-identical. It
took a stricter definition of the goal to make it visible at all.

## A net count cannot report a regression it is outnumbered by — 2026-09-09

cc370#304 took three modules from `rc 0` to `rc 8` — `IFNX1K`, `IFNX3K`,
`IFNX5V` — and **I merged it.** The gate line read

```
LOST : 0        as370 alone flags : 23 -> 19
```

and **both were true.** The three decks were already non-identical, so the deck
measure could not see them; seven other modules improved in the same run, so the
net moved the right way. Nothing in the output was wrong. It simply could not
carry the signal.

`retest.py` now prints, unconditionally and **by name**, next to `LOST`:

```
  rc CLEAN -> FLAGGED: 3  IFNX1K IFNX3K IFNX5V
  rc flagged -> clean : 4
```

Two lines, off two `.tsv` files that were already on disk. **The control**: run
against `g301.tsv` and `g303.tsv` — the gates either side of #304 — it names
exactly those three. A check that cannot reproduce the failure it was written for
is not a check.

### The shape, third instance

| | the aggregate that hid it |
|---|---|
| `AMASPZAP` | module totals, while one section was 16 bytes and two were absent |
| `diag_cap` / `libmac_mend` | a green test that had stopped testing its subject |
| **cc370#304** | **a net verdict count outnumbering three regressions** |

Every input correct, every figure honest, and the thing you needed to see gone.
cc370 found it by asking *when* the `IFNX` family broke, not *whether* — the
family was suspiciously uniform, and uniformity is a question about history.

## A PR worktree in `/tmp` breaks cc370's test suite, and it looks like a regression

2026-09-09. Gating a PR from `git worktree add /tmp/wtNNN`, `tests/run.sh`
reported five samples as `ASSEMBLE FAILED` — `sample2 sample7 sample8 sample9
dcb` — where the same suite on `main` passed. That reads as a regression the PR
introduced, and it is not one.

```sh
LIBC370=${LIBC370:-../../libc370}      # tests/run.sh, relative to the repo root
```

From `/Users/mike/repos/mvs/cc370/as370` that resolves to
`/Users/mike/repos/mvs/libc370` and exists. From `/tmp/wt322/as370` it resolves
to `/libc370` and does not, so the PDP macros are missing and five samples that
need them fail. **Set it explicitly whenever the suite is run outside the
checkout:**

```sh
cd /tmp/wtNNN/as370 && LIBC370=/Users/mike/repos/mvs/libc370 sh tests/run.sh
```

With that, all samples are byte-identical to IFOX00.

**The control said "regression" because it varied more than one thing.** `main`
passing and the PR failing looks decisive until you notice the two runs also
differed in working directory — the very variable the failure depended on. A
control has to differ from the test in exactly the one thing under examination,
and this one differed in two. `run.sh`'s own comment names the symptom
(*"the suite failed with `Undefined operation code ... PDPPRLG` wherever it was
absent"*); reading the instrument would have been quicker than re-deriving it.

## Build `main` from a worktree — the cc370 checkout belongs to the other session

Same day, worse mistake. Promoting a merge, I ran `git checkout main` **in
`~/repos/mvs/cc370` while cc370 was working in it** — the session had
`feat/as370-ifo220-alignment` checked out with uncommitted changes to
`as370/src/as370.c`. Git refused, which is the only reason nothing was lost.

There was never a reason to touch it: every gate already builds from
`git worktree add /tmp/wtNNN`, and the only thing the checkout was being used for
was a current `main` binary for the measurement chain. So:

```sh
git -C ~/repos/mvs/cc370 worktree add /tmp/main-cc370 main
cd /tmp/main-cc370 && git fetch -q origin && git checkout -q --detach origin/main
```

`--detach origin/main`, not the local `main` branch — the local ref lags whenever
a pull was skipped, and moving it with `git branch -f` would reach into a ref the
other session may be standing on. A detached worktree touches nothing shared.

**Two sessions, one checkout, is a shared mutable resource with no lock.** The
convention is: the checkout is cc370's, `/tmp` worktrees are mine.

## Never pass a `gh` comment body inline

`gh pr close 321 -c "... \`pool.s\` is already on main ..."` — the shell ran
`pool.s` as a command and substituted its empty output, so the published comment
read `** is already on main.**`. It had to be corrected in a follow-up.

Use `--body-file` with a quoted heredoc (`<<'MDEOF'`) for every comment, without
exception. Backticks are how one writes code in Markdown and how the shell
substitutes commands, and a comment is published before anyone reads it back.

## Never chain a promotion behind unrelated commands with `&&`

2026-09-09, and it is the sharpest instance of *stale by content* yet, because
nothing failed and nothing looked wrong.

```sh
gh pr close 321 -c "..." && git checkout -q main && git pull -q && \
  make -C as370 && cd .../ifox-run && rm -rf as370 restamp && \
  cp -R obj_g322 as370 && cp g322.tsv as370-gate.tsv && echo promoted
```

`git checkout` aborted — the other session had uncommitted work in that checkout
— so **every command after it was skipped, including the promotion**. The word
`promoted` never printed and I did not notice, because the failure message was
about a checkout and I was reading it as a git problem, not as a promotion
problem.

Consequences, both silent:

- the measurement chain launched next ran the **new binary against the previous
  merge's decks**, which is precisely the two-builds-at-once figure this document
  already warns about;
- `retest.py`'s rc rows compared against `g319` while claiming to compare against
  the promoted state — which is how the `flagged-or-silent` row read
  `5494 -> 5503 (+9)` for a merge that had already landed.

**It was caught by a control, not by noticing.** Re-running `retest.py` on the
already-promoted run must print `+0` on every line; it printed `+9`, and the only
explanation was that the baseline was not what it claimed to be.

So: **a promotion is its own command, run on its own, and its output is read.**
Never `&&`-chained behind a merge, a build, or anything that can fail for an
unrelated reason. And after promoting, `retest.py <the same objdir>` should print
zeros — a one-line check that the promoted state is the run it is supposed to be.

## `gh issue close` has no `--body-file`

It takes `-c/--comment` inline only, which collides directly with the rule above
about never passing a body inline. Two issues appeared to close and did not,
because `--body-file` was accepted as an unknown flag and the command did
nothing visible.

Two commands, not one:

```sh
gh issue comment 153 --body-file /tmp/c153.md && gh issue close 153
```

And **check the state afterwards** — `gh issue view <n> --json state -q .state`.
A close that silently failed looks exactly like one that worked.

## A flag chain in a shell variable is one argument, and it invalidated a result

2026-09-09, and it is in my memory notes already, which is the annoying part.

```sh
extra=""
[ "$lbl" = all ] && extra="-I $M/kreiss-smp -I $M/erep-instream"
$B $MAC $extra -o /tmp/isi.$lbl.obj "$SRC/IFCSI115.ASM"
```

`$extra` reached `as370` as **one argument**, so both directories were ignored and
the run was identical to the one without them. I reported that as *"supplying the
EREP macros changes nothing — same rc, same 166 diagnostics, same 480-byte deck"*.

Written out explicitly, the same module gives:

| | rc | diagnostics | deck | still undefined |
|---|---:|---:|---:|---|
| through the variable | 8 | 166 | 480 B | `DSGEN LINE ROUTINE SPECIAL SUM` + 8 more |
| paths written out | 12 | 172 | **1,680 B** | `LINEND CONVT HEX SUMMARY PROLOG FREETAB ETEPILOG ENTRIES` |

**3.5× the object, and five of the thirteen undefined operations resolved.** The
opposite of what I said.

The control that should have run first is three lines:

```sh
printf 'T        CSECT\n         DSGEN (A,8)\n         END\n' > /tmp/dsg.s
as370 -I .../erep-instream -o /tmp/dsg.obj /tmp/dsg.s   # rc 0
as370                      -o /tmp/dsg.obj /tmp/dsg.s   # Undefined operation code - DSGEN
```

It takes seconds and it distinguishes *"the macro does not help"* from *"the macro
was never on the path"*. **A negative result about a supplied file is a claim
about the supply until the supply is demonstrated.** `gate.sh` is not affected —
its `MACFLAGS` is expanded by `sh`, which does word-split — but every ad-hoc
measurement typed at the prompt is.
