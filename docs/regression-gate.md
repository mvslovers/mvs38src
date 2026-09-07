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
as370 == IFOX00 : 3465 -> 3478   (+13)
  gained  : 15  AHLMCIH BLSRESAR ...
  LOST    : 2   IEFJDSNA ...
  length -> bytes : 41
```

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

```sh
tools/ifox_compare.py /path/to/as370     # attribution, tool against source
tools/module_table.py                    # the per-module table and for-cc370.tsv
tools/ifox_cluster.py                    # where the decks part company
tools/ifox_offdiag.py /path/to/as370     # the two disagreement cells
```

That regenerates [`cc370-cases.md`](cc370-cases.md)'s figures. The IFOX side does
not have to be re-run unless the *source* changes — and if it does, only for the
modules that changed: `ifox_run.py` skips what it has.
