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

**A deck that appears or disappears is a timeout until proved otherwise.** Time
the module alone, against a build from before the change, before believing it is
the code. `IFCEE155` and `IFNX1A` looked identical in the gate table — both
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
