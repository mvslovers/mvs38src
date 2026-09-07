# TODO — MVS 3.8j source recovery

As of 2026-09-07, midday. The working list for [`docs/workplan.md`](docs/workplan.md).
The plan says *why* and *where to*; this list says *what next*.

**Key:** 🔒 blocks other work · ⚡ runs in parallel, blocks nothing ·
🚪 gate: the outcome decides how we proceed

---

## Start here tomorrow

*Written as a handover: a fresh session should be able to start from this section
alone.*

### Where the project stands

**The whole tree has been assembled twice** — once by `as370` here, once by the
real Assembler XF under MVS/CE, from the same source and the same 1,822 macros.
That separates the tool question from the source question for every module, and
it is done: [`docs/ifox-tree.md`](docs/ifox-tree.md).

- **`as370` and IFOX00 agree on 3,466 of 5,528 modules (62.7 %).**
- **2,112 modules are the assembler's problem** and are written out ready to hand
  over: [`work/measurements/ifox-run/for-cc370.tsv`](work/measurements/ifox-run/for-cc370.tsv)
  and `for-cc370.txt`.
- **3,416 are ours** — the two assemblers agree and only IBM's shipped object
  differs.
- On the population the earlier figures are about (as370 rc 0, DLIB counterpart,
  3,719 modules): source 1,357, tool 1,052, recovered 869, `DS` holes only 441.

### The class that only this comparison can see

**1,113 modules are a silent divergence**: both assemblers exit clean, neither
says a word, and the object code is different anyway. `IGG019PF` is the pattern —
IFOX00 emits 144 bytes, `as370` emits 265, first difference at `0x89`. Against
the distribution libraries alone this is indistinguishable from a source defect,
which is why it was never counted before.

### The next three things

**1. Hand the 2,112 to cc370 as cases, ordered.** The table gives each one the
offset where the two decks part, both section lengths, and both assemblers'
messages — [`module-table.tsv`](work/measurements/ifox-run/module-table.tsv), one
row per module, sorted so the hand-over block is contiguous. The classes, largest
first:

| | Modules |
|---|---:|
| silent divergence — both clean, object different | 1,113 |
| `as370` rejects what Assembler XF assembles | 512 |
| both flag, **and the decks differ** (of 849 that both flag) | 393 |
| IFOX00 flags, `as370` is silent | 84 |
| no deck on one side | 8 |
| `as370` does not terminate | 2 |

The third class is already broken down by message
([`as370-flags.tsv`](work/measurements/ifox-run/as370-flags.tsv)); on the first
900 modules it was 68 `Undefined symbol`, 25 `Addressability error — no active
USING covers the operand`, 6 `Undefined operation code`. Send the case, not the
diagnosis.

**2. The source work, now attributable with certainty.** Where `as370` == IFOX00
and the DLIB member still differs, the difference belongs to the source or to
IBM's maintenance and to nothing else. That is 1,357 modules, plus 441 that
differ only in `DS` holes. This no longer waits on the assembler.

**3. Re-run the comparison after every cc370 merge.** The pipeline is resumable
and the order is a fixed shuffle, so a partial re-run is still an unbiased
sample. `tools/ifox_run.py`, then `ifox_compare.py`, then `module_table.py`.

### What is settled and needs no more work

- **The assembly stamp.** 302 modules were under suspicion. Every module whose
  decks differ was re-assembled locally with the date and time *that* IFOX run
  used; **exactly one of 1,334 byte differences is the stamp**. No `--sysdate`
  option, no `difin` masking.
- **The macro question, for this comparison.** Both sides see the same libraries:
  equal member counts in all six distribution libraries, the 444 private macros
  identical by name, 25 members drawn at random identical byte for byte. It does
  not settle the *provenance* of the 319 mirror macros — that still waits on Dave
  Kreiss' tape — but no difference in this run can be blamed on the two sides
  reading different macros.

### Dave Kreiss' install tape holds source we were not measuring

`BLDMVS.AWS` has `NEW.ASM` as its own data set — 848 members, **321 of them not in
`MVSBLD`**. His package separates what he built (`NEW.ASM`), the MVT-era
originals (`MVT.ASM`, 106 members, all also in `MVSBLD`) and his own tools
(`UTL.ASM`, 64, none in `MVSBLD`). `MVSBLD` itself is flat and mixed: original
and repaired side by side, with nothing but his `*DSKnnnn` markers to tell them
apart.

Of the 321: **56 have a DLIB object**, so they were measurable all along and were
never measured.

- **7 are recovered immediately** — `HASPBLKS`, `HASPFMT0`–`FMT5`, byte-identical
  at the first attempt. These are exactly the seven the `mvssrc` sessions had
  reported as having no source anywhere, presumed to need a `HASPGEN` run.
- **48 are `XTB*` translate tables** blocked on a `TABLE`/`NAME` macro pair that
  is in none of our libraries, none of the IBM tapes and not in `NEW.ASM`. That
  makes them a 52nd and 53rd entry for the missing-macro inventory, and `TABLE`
  is now the second-largest single blocker after `IHANVT`.

  **Three of the 48 need no macro at all.** `mvssrc-20` found that their tape
  carries `XTB1GFC`, `XTB1GSC` and `XTB1GUC` in the expanded, macro-free form —
  `DC`/`DS`/`ORG` only, no call. Measured here: **all three assemble
  byte-identical to the DLIB object**, 288 bytes each, `rc 0`. Not deposited: the
  tape tree is held pending Mike's word, and these come from it.

  Their search for `TABLE`/`NAME` was exhaustive and negative — 1,761 macros
  across the tapes, stben's maclib, the HASP set and `ext/`, no member of that
  name and no definition with that prototype. The other 45 stay blocked.

Everything is kept in `work/kreiss-newasm/` unmeasured. Recovered goes 928 -> 935.

### The first recovered source — ten modules, and a class the IFOX comparison could not see

`src/` has its first entries. `MVSBLD` came through a transfer that read EBCDIC
as **cp1047**, where X'5F' is `^`; everything here reads **cp037**, where X'5F' is
`¬` and `^` is X'B0'. A constant written `C'^'` therefore assembled to the wrong
byte. 39 modules carry the character inside a constant, 78 occurrences.

**With the substitution, ten modules become byte-identical to the object IBM
shipped, and not one gets worse.** Repaired copies in `src/`, tool in
[`tools/caret_fix.py`](tools/caret_fix.py). Recovered goes 902 -> 912.

**Why this took a third instrument.** `as370` encodes cp037; the source reaches
MVS through mvsMF, which encodes cp037 as well. So IFOX00 received X'B0' too, and
the two assemblers agreed with each other perfectly. Every one of these sat in the
table as *"the assemblers agree, only IBM's object differs"* — booked to the
source, which was right, and unexplainable from either assembler. Only IBM's
shipped object could settle it.

Found by the `mvssrc-20` session as a case; measured here. `!` is X'5A' in both
code pages. `[`/`]` do differ but the two modules carrying them do not improve, so
that substitution stays unapplied — unproven.

**What follows from it, and it is not small:** every module whose verdict is
"assemblers agree, source differs" is now a candidate for a *transfer* defect
rather than a maintenance-level one. That is 3,507 modules, and this is the first
mechanism found in them.

### What the tape tree is for — the material Dave Kreiss started from

**Two projects, one goal, and they are not the same work.** What this repository
does is take over Dave Kreiss' project: bring the surviving sources up to the
maintenance level of the shipped object. The `mvssrc` sessions are not doing that
— they are **curating IBM's original sources for us** out of several archives, so
that we have one byte-exact, provenance-known starting point instead of a
handful of mirrors.

So the tape tree is not an alternative base to be compared against his. It is
**what he began with**, which means it finally makes his work visible as a delta:
what he changed, where he changed it, and what he never reached. The trial below
should be read for its 16 exceptions and not for its headline — that his tree
beats IBM's original is his project's definition, not a result.

What the tape does give, for the first time, is **which modules he worked on**.
His change markers (`*DSKnnnn`, or `DSKnnnn` in column 65) mark 783 modules:

| | Paired | identical + holes | |
|---|---:|---:|---:|
| **with his marker** | 744 | 108 | **14.5 %** |
| without | 4,284 | 1,289 | **30.1 %** |

**He worked on the hard ones** — that is what the inverted rate says, and it is
the right way round. The untouched modules are untouched because nobody needed to
look at them.

**634 modules carry his marker and still differ from the object.** They split in
a way that decides who does what:

- **364 wait on the assembler** — they are booked to `cc370`, so his source may
  already be right and unmeasurable until more fixes land. Every `as370` merge
  re-tests them for free.
- **270 are real source work**, and they are the best-documented modules in the
  tree: he left markers, and 44 of them carry `???` where he could not
  reconstruct what the code does. 142 differ in text, 107 in length.

**And inside it, a hard core of 25.** The `mvssrc` sessions list 116 modules
whose text matches no variant on any tape. 91 of them carry no marker of Dave's
and score 28.6 % — the tree's ordinary rate for unmarked modules, so their
provenance is open but their quality is not a problem. The other **25 carry his
marker and reach the object in 1 case out of 25** — against 14.5 % for marked
modules generally. Those are the hardest thing he touched: worked on, matching no
distribution text, and still not reaching the object.

`classes/kreiss-source-unfinished.txt` is that list. It is the most concrete
source-side work item this project has: modules with a known repair history, a
known author, and a measured gap.

### And the second: IBM's own source, measured against IBM's own object

`mvssrc-20` extracted the IBM distribution tapes byte-exact —
`~/repos/mvs/mvs38-ibmsrc`, 7,206 members, cp037, 80 columns. For **1,023**
modules where the assemblers agree, the object differs, and IBM's source is
unambiguously available *and different from Dave Kreiss'*, it was assembled here
instead:

| | Modules |
|---|---:|
| byte-identical to IBM's object | **16** |
| `DS` holes only | 19 |
| **worse** — a text difference became a length difference | **110** |

**Read this for the 16, not for the headline.** IBM's tree is the material he
started from, so "his is closer" is the definition of his project rather than a
result. The useful part is the exceptions: 16 modules where IBM's untouched text
reaches the object and his does not — places his repair either never happened or
went the wrong way — and 110 where his is better by a measurable margin.

The sixteen are in `src/`; recovered goes 912 -> 928. Full result in
[`ibm-source-trial.tsv`](work/measurements/ifox-run/ibm-source-trial.tsv).

⚠️ **A trap `mvssrc-20` measured and we must not walk into:** the FTP table is a
*swap*, X'5F' and X'B0' exchanging places, so `^` -> `¬` is only half a rule.
`MVSBLD` is not one pipeline: two members (`IFCDIP00`, `IFCIOHND`) are already
cp037 and never went through FTP, and `ICAPRTBL` carries a third encoding
(X'9B') that no substitution can repair — it has to come from the tape.
`caret_fix.py` cannot touch any of the three, which was checked and not assumed.

### Seven fixes in — 62.7 % to 69.2 % in one day

Baseline `126d8d3`. **as370 == IFOX00: 3,737 of 5,528 (67.6 %)**, recovered
against IBM's shipped object **902**, hand-over list **1,841** (from 2,107).

| merge | identical | lost | closer | further |
|---|---:|---:|---:|---:|
| #164 + #165 | +93 | 0 | — | — |
| #166 (diagnostics order) | 0 | 0 | 0 | 0 |
| #168 (parenthesised adcon) | +24 | 0 | 69 | 9 |
| #170 (index subscript, grouping parens) | +58 | 0 | **178** | **1** |
| #171 (`L'` of a value-length constant) | **+95** | 0 | 229 | 1 |
| #172 (three more call sites of the same guard) | **+86** | 0 | 177 | 5 |

Baseline `517161c`: **as370 == IFOX00 3,823 of 5,528 (69.2 %)**, recovered **915**,
silent divergences 1,169 -> 977, hand-over list 2,107 -> **1,756**.

#172's five are the same shape as before but at a larger scale, and were weighed
individually: `IEBVMS` 77 % wrong -> 80 %, `IGC0M05B` 90.5 % -> 94 %,
`IFG0191Y` 4.9 % -> 7.6 %. Every one is dominated by another defect; the fix
changes bytes inside a region that is wrong either way.

**Two defect classes neither instrument here can see**, reported by cc370's sweep
and worth keeping because the reason is structural:

- `set_canon()` takes the first `)` of a subscripted SET label. **Zero modules in
  our 5,528** — but twelve damaging labels in real IBM macro source
  (`ATCAMMAC/LINEGRP`, `INVLIST`, `INVLIST1..6`). No module in the corpus loads
  those members, so no deck can point at it. A TCAM-generation module added later
  would hit it silently at `rc 0`.
- The eight `IFC*` modules die on a fixed 4,096-entry global SET-symbol table
  ([cc370#173](https://github.com/mvslovers/cc370/issues/173)). They produce no
  deck, so they are invisible to every deck comparison — ours — and absent from
  every scan of as370 output — theirs. They sat in this table for a day as
  "aborts at rc 2" with no cause. IFOX00 assembles all eight at `rc 0`.

**#170's row is corrected**, and by cc370 finding the fault in a measure I had
built from their idea. The distance in `retest.py` walked the deck's *cards* and
charged a whole card for a card-count difference — so a fix that gives a section
its **correct** length read as a regression. `IFNX4S` went to exactly IFOX00's
length and scored +71. Measured on the address-keyed section image instead, #170
moved 178 decks closer and **one** further, not six.

**Nothing has been lost in any of them.** The "further" columns were weighed,
not netted: every one lands inside a TXT card already carrying 8 to 799 wrong
bytes, where a previously wrong value happened to coincide with IFOX00's byte.
The assembler computing the right value is the point; the coincidence was not
worth defending.

#170 also carried a second defect of the same family, found while fixing the
first: a displacement parenthesised for *grouping* was taken as a subscript
list. `SLL R11,24-(8*((A-B)-(((A-B)/4)*4)))` gave `ff fe 00 18` — not even a
valid instruction — where IFOX00 gives `89 b0 00 18`. Silent, and not in any
catalogue of ours.

cc370#168 (an address constant whose value starts with `(` is not zero) was the
first change accepted on more than the verdict counts: +24 identical, none lost,
**69 decks closer to IFOX00 and 9 one byte further**. The nine were weighed
rather than netted — each sits inside a region IFOX00 leaves as zeros and our
macro fills, so the new byte is the correctly computed value in a block that is
wrong for a different reason. `retest.py` now reports that distance, because a
change that improves wrong code without reaching identity is invisible in the
verdict counts.

**A guessed population is a subset.** My class file for #167 was the 35 modules
carrying `DC Y((` in their cards; the fix moved **79**, and the other 44 receive
the construct through a macro where no card shows it. The measured set replaces
the scanned one: `classes/parenthesised-adcon.txt`.

Two filed from the silent class, both with a three- or six-card reproducer
measured against IFOX00 on MVSCE-EXP:

- [cc370#169](https://github.com/mvslovers/cc370/issues/169) — an index register
  written as `((1),0)` is dropped, **and the base with it**. Byte signature:
  962 sites in 277 modules.
- [cc370#148](https://github.com/mvslovers/cc370/issues/148) gets its reach —
  `MVC` length from `L'symbol` comes out zero. 1,016 sites in 192 modules.

These two are the largest signatures in the silent class by some distance;
everything else visible there is under 50 modules.

### Three fixes in; the gate is now the release path

cc370#164, #165 and #166 are merged (`3d6a997`), each measured here before the
merge. **Mike delegated the merge decision to this session on 2026-09-07**, so a
cc370 PR is confirmed and merged here after a gate run, not escalated.

#166 (diagnostics in source order, statement named) is the first change accepted
on a *no movement* claim, and that needed a stricter test than the verdict
counts: **0 of 5,518 decks differ by sha256**, and all seven Package A class
memberships unchanged, both binaries built and classified here.

### The first two fixes are in, and re-baselined

cc370#164 (`.*` is a comment card in `parse()`) and cc370#165 (IPK and PTLB take
no operand) are merged as `879e86a`, confirmed here by an independent rebuild,
and everything is re-measured against that build.

- **+93 byte-identical to IFOX00, none lost** — 3,466 -> 3,559 (64.4 %)
- **+10 recovered**, all three decks agreeing — 869 -> 879
- **all 93 gained modules were rows this table had booked to the assembler**, not
  one to the source. The first independent evidence the ownership column means
  what it says.
- the hand-over list falls 2,107 -> 2,016

**A fix reclassifies as much as it removes.** Package A lost 146 modules: 93
became identical and **56 moved into the silent-divergence class**, which is
harder. Package D grew 84 -> 96. `Relocatable displacement` grew 29 -> 44,
because modules that used to fail earlier now reach it.

Two figures must not be inherited — see
[`regression-gate.md`](docs/regression-gate.md): the "56 modules" for the IPK
class is a superset, the traced number is 48; and the reach figures for the
fourteen unfixed mechanisms in cc370#153's comment are owned by a first
diagnostic and therefore unsound while as370's output is category-ordered.

### What is in the tree that is not in the system

[`docs/module-origin.md`](docs/module-origin.md) — per module, which
distribution library holds its object and whether MVS/CE carries a load module of
that name.

- **CICS: 5 modules excluded.** `BNGC3270`, `BNGCDISP`, `BNGCLOCL`, `BNGCMENU`,
  `BNGCRMOT` call `DFH*` macros; there is no CICS here and none of the five is
  installed. They keep their row with the reason in an `excluded` column and drop
  out of the hand-over list: **2,112 owned by the assembler, 2,107 handed over.**
- **Sort: 251 `IER*` modules, decision open.** No object in any distribution
  library, no member of any target library, and **there is no sort library on the
  instance at all**. They can never be verified. 243 of them already assemble
  identically between `as370` and IFOX00, so excluding them costs the hand-over
  list 8 modules and takes 4.5 % out of a denominator no measurement can settle.
- **The member-name test undercounts** and must not be read as "not installed": a
  CSECT is usually bound into a load module of another name.

### The second corpus, and what it can actually decide

`mvssrc` has `handover/not-in-mvsbld.tsv` ready: the 1,025 members their tapes
carry that `MVSBLD` does not, with tape, tape file, SSI, prefix and chosen
variant. **It is not 1,025 measurable modules and must not be quoted as one:**

| | Members |
|---|---:|
| **module — produces a CSECT, has a DLIB object: a byte verdict is possible** | **16** |
| module, no object to compare against | 169 |
| macro — meaningless standalone, needs a driver or a library | 590 |
| dsect / `COPY` member — no CSECT, but exercises the same expression evaluator | 250 |

**185 modules, not 428.** `mvssrc` first classified by the member's *first*
statement — not `MACRO`, therefore source — and PL/S members like `IHASPCT` open
with comment text and a `%GOTO` and carry their `MACRO` further down. 15 macros
were counted as source and 22 members with a real `CSECT` as macros. They found
it while re-deriving our blocker figure independently, and they say plainly what
let it through: their control only asked whether a *macro* had an object, never
whether a *source* was a macro. One-directional, so it could not see this.

The corrected classification is checked both ways: no macro and no dsect has an
object, and every member with an object is a module.

Worth running anyway: the **250 dsects**. They produce no CSECT and so admit no
verdict, but they drive the same expression evaluator, which is where most of
this session's defects were found.

⚠️ **And a trap they marked before we could walk into it.** 129 of the 1,025 are
the members with the missing comment star, 122 of them `kind=source` — 12.6 % of
this corpus against 2.2 % of the tree. A message count over it would show
`INVALID OPERATION CODE` heavily overrepresented and it would look like a finding
about the corpus. Filter on `blank_comment_marker = yes`.

**The blocker count is confirmed twice.** `mvssrc` re-derived our 51-operation
figure independently and got the same four hits: `ISDAFSPC` (27 modules),
`IHASPCT` (7), `IHASHDR` (1), `IECDSCD` (1). The largest of the 47 that are
missing there too: `IHANVT` (33), `DSGEN` (33), `LINE` (33), `UCBDADVC` (32),
`ILRAIA` (30), `ROUTINE` (28). Two computations from different data, one answer.

Nothing is taken from the tree until Mike releases it.

### The reference is not sound everywhere — and that is the next work here

**IFOX00 flagged 933 of the 5,528 modules at `rc 8` or worse, so their decks are
a doubtful reference.** 495 of the 3,466 `as370`==IFOX00 agreements and 477 of
the 2,112 cases handed to cc370 rest on one. The 869 recovered do not — IBM's
shipped object settles those independently.

Two classes of it are ours to fix, and fixing them opens a loop: a better
reference exposes differences that were hidden behind the flawed one, and those
are new cases for cc370.

- **197 modules, `IFO078` UNDEFINED OP CODE — 51 operations no library of ours
  has.** `IHANVT` (33 modules), `UCBDADVC` (32), `IECDCST` (11) were already
  listed as missing below; now their reach is known. A whole EREP family
  (`DSGEN`, `LINE`, `ROUTINE`, `BIN`, `HEX`, …) blocks 33 more.
- **225 modules, `IFO092` keyword undefined — macros at the wrong level.**

Written up as a standalone brief, meant to be worked in its own session:
[`docs/ifox-objections.md`](docs/ifox-objections.md).

### A source-side finding out of the same run, and it does not wait

**Our `MODID` is not the level the source was written against, and now it is
measured.** 112 modules call `MODID` with `DATE=` or `PTF=`. The only `MODID` we
have — MVS/CE 2.1.4 `AMACLIB`, the same library IFOX00 reads — has the prototype
`&LABEL MODID &BRANCH=,&BR=` and defines neither keyword, while its own comments
name the PTF that added `PTF=` support (`OZ15314`). IFOX00 flags every one of
those calls with `IFO092`; `as370` says nothing, which is
[cc370#162](https://github.com/mvslovers/cc370/issues/162), but the macro level
is ours.

`MODID` is also one of the macros that stamps the assembly date into the object,
so this sits directly on top of the 302 timestamp-bearing modules. Smallest case:
`IECVOID`, three cards.

### Waiting on other people

- **Dave Kreiss' rebuilt install tape** with his built `PVTMAC`/`APVTMAC`. That
  is the only route to settling the maintenance level of 319 of our macros, and
  until it is settled every length difference has two explanations.
- **mainframed767** on an MVS/CE 3.0.1 — sent 2026-09-06, follow up in ~4 weeks.

### Controls that must not be dropped

Every one of these caught a wrong finding today:

- **Pass all 80 columns** when feeding assembler source anywhere. Column 72 is
  the continuation; cutting at 71 produces `IFO035` everywhere and looks like a
  source defect.
- **Both sides must see the same macro libraries.** Local `-I` uses
  `SYS1.AMACLIB` (566 members); `SYS1.MACLIB` on MVS is the *target* library with
  742. The matched `SYSLIB` is in [`docs/ifox-oracle.md`](docs/ifox-oracle.md).
- **Check that a deck belongs to its module** — first section name against member
  name. `SYSPUNCH ... DISP=SHR` leaves the previous deck in place when a step
  fails, silently.
- **Never `SYSPRINT DD DUMMY`.** The diagnostics decide whether a deck is an
  authority at all.
- **In zsh, build flag lists as arrays** and pass `"${arr[@]}"`. An unquoted
  variable arrives as one argument.
- **`grep` here is `ugrep`, and it returns nothing on MVSBLD members** — no
  count, no error. Use `/usr/bin/grep`, `rg`, or Python. An empty result is not
  evidence of absence; it hid a `COPY` chain for half a day.
- **Pin `ASMDATE`/`ASMTIME` and drop the `END` card** before comparing decks from
  two runs. 381 decks carry the stamp; every deck carries the date.

### Small and named, still open

14 `AMACLIB` elements missing from `SYS1.AMACLIB`; `IHANVT`, `UCBDADVC`,
`IECDCST` with no `++MAC` element; `ACCESS`, `IQAMOD`, `IQAQAL` nowhere on this
machine; the 22 members carrying an `X'10'` scatter record, now readable but
never verified against a rebuild.

---

## Immediate

### 1. ✅ Licensing settled — Dave Kreiss answered on 2026-09-06

**Freeware, no copyright, no terms.** His words: *"it is ok to release it as
freeware with no copyright or terms — that is it is open to anyone to use as
desired."* The same goes for the utility source on the install tape.

- [x] Sent (2026-09-04), answered (2026-09-06)
- [x] **Publication is unblocked** — the repository may go public
- [ ] Credit him **by name and email** on the material and in the repo
- [ ] **Keep `UTL31` out of publication.** It descends from the CBT file 217
      disassembler (R. Thornton) and he does not know its terms either. He
      distributes it but does not assemble it, so nothing depends on it
- [x] **Replied on 2026-09-06.** It asks for his built `PVTMAC`/`APVTMAC` on the
      new install tape — and that request has since turned out to be the *only*
      route to those macros, see [`docs/private-macros.md`](docs/private-macros.md)

**What else his mail says:**

- All target libraries assemble to match TK3 **except `SYS1.LINKLIB` and
  `SYS1.LPALIB`**, the two largest. He has IPLed and run a system with the
  rebuilt libraries.
- **He is rebuilding the install tape**: current documentation, utility source,
  Tom Armstrong's SORT put into SMP format, and source for some compilers
  (COBOL and FORTRAN). Worth waiting for before any large re-baselining.
- The ask that goes with it: **`MVSSRC.BLD.PVTMAC` / `APVTMAC` on the new tape**,
  which would replace our 320 mirror macros with ones at a known level.

### 1a. ✅ Current BLDMVS package reconciled

The 2023 package is on disk and unpacked; the 2021 one is kept beside it.

| | old | new |
|---|---|---|
| location | `Dave Kreiss - MVS from Source/BLDMVS#2021/` | `…/BLDMVS/` |
| instructions | 2020-07-05 | **2023-08-06** |
| `BLDMVS.AWS` | 2021-09-16, 190 MB | **2023-12-01, 191 MB** |
| `NEW.ASM` on tape | 31 MB | **43 MB** — plausibly the DSS370 work |
| `UTL.ASM` on tape | 4.2 MB | **5.3 MB** |

The archive is `~/repos/MVSSRC_BAK/BLDMVS.7z`. No 7z tool is installed, but
**`tar -tf` / `tar -xf` read it** (bsdtar handles 7z).

**What changed in the instructions (762 lines differ):**

- **New: a TK5 section** — install the TK5 source and CBT option, RAKF profiles
  for `MVSSRC.BLD.*`, Hercules config for the build volumes.
- **`MAINT05F` no longer submits its successor.** The step that copies the new
  SMP into the running `SYS1.LINKLIB` is commented out; uncomment it or submit
  `MAINT05Z` by hand. Anyone replaying the build will trip over this.
- **The S106-F appendix is gone entirely** — 11 mentions in 2020, none in 2023,
  and "no failures except the occasional S106-F" became just "no failures". The
  sporadic build aborts seem to have gone away with newer Hercules.
- **Dave got more pessimistic:** "little chance of working correctly" became
  "**no** chance" for LINKLIB, LPALIB, VTAMLIB and TELCMLIB.
- **Newly tested:** 3350 *and* 3390 mod 1 as system residence.
- Appendix C statistics are **unchanged**, so no further modules were completed
  between 2020 and 2023.
- A documentation bug: the Phase 4/5 headings gained parenthetical labels that
  are swapped — "Phase 4 (LPALIB…)" describes `DSKK000` → LINKLIB. The body text
  is right.

### 1b. ✅ Instances run MVS/CE v3.0.0

`SYS1.PARMLIB(RELEASE)` on 2026-09-04: **LAB and EXP are v3.0.0**, `MVSCE-DEV` is
v2.1.4. mvsMF on LAB and EXP has been updated by the user and now reports
`zosmf_version: "1"` with a `plugins` field, like DEV.

- [ ] **Open decision:** the baseline for comparison. Our instances are 3.0.0;
      the pristine copy extracted on `mvsdev` (`~/tmp/mvs38src-work/`) is 2.1.4.
      If the DLIB hypothesis holds this hardly matters — but it should be settled
      rather than drifting.

### 1c. ✅ libc370 v1.0.4 released, all four packages relinked

Done 2026-09-06. The SYNAD fix is in — an I/O error used to end the address
space with `S001` instead of being passed up as `ferror()`+`EIO`.

- [x] Cut libc370 v1.0.4 and relink httpd, ufsd, ftpd, mvsmf
- [ ] Give mvsmf a stable `v1.0.0` rather than only the `v1.0.0-dev` pre-release

Never was on our critical path — we build no C programs for MVS — but it is the
precondition for item 1d, which is now sent.

### 1d. ✅ Asked mainframed767 for an MVS/CE 3.0.1 — sent 2026-09-06

Sent after 1c, so the version table names current releases rather than stale
ones. Draft kept in `~/repos/MVSSRC/WORK/doc/mail-mainframed767-mvsce-301.md`.

**The regression argument was withdrawn before sending** — there is no JES2
regression in v3.0.0, that was our own broken job cards. What went out is the
package-level lag plus three operational findings:

- `SCRIPTS/SHUTDOWN.RC` stops neither HTTPD nor FTPD
- nothing starts them either — no `S HTTPD` anywhere in the repository
- which HTTPD lands in the build is ambiguous: `MVP/desc/HTTPD` says 4.0.0,
  `MVS-sysgen/SOFTWARE/HTTPD` holds `HTTPD330` from 2025-02-13

- [ ] Follow up once after ~4 weeks, then let it rest

### 2. ✅ Repo created

- [x] `git init`, base structure
- [x] **`.gitattributes` with `* -text` and `*.asm binary`** — before the first
      commit. Forget it and Git normalizes the CRLF and the 80-column records,
      and from then on we compare artifacts of our own toolchain
- [x] `README.md`, `CLAUDE.md`
- [x] `.gitignore`: DASD images, `*.AWS`, web mirrors stay out
- [ ] Repo stays **private** (see item 1); no remote until then

### 2b. ✅ The cc370 toolchain — built, not just requested

What was five issues on 2026-09-04 is largely working code on 2026-09-06.

| # | | State |
|---|---|---|
| [#109](https://github.com/mvslovers/cc370/issues/109) | `libobj370` / `libmvs370` | **readers done**; the emitters remain and are on nobody's path |
| [#110](https://github.com/mvslovers/cc370/issues/110) | `cmplmd370` | **built and in use** — comparison, `--clearrld`, `--csect`, `--difin`/`--difout`, `--json`, hole classification |
| [#113](https://github.com/mvslovers/cc370/issues/113) | reading a foreign IEBCOPY unload | **solved**, and the format is documented in [`docs/private-macros.md`](docs/private-macros.md) |
| [#111](https://github.com/mvslovers/cc370/issues/111) | `idrdump370` | open — the 102-member dataset for it is committed |
| [#112](https://github.com/mvslovers/cc370/issues/112) | `dasm370` | open, and still not needed until case D is sized |

**Six `as370` defects closed the same day**, every one measured against IFOX00
rather than argued from the manual:

| | | modules unlocked |
|---|---|---:|
| #127 | `START` not implemented | 75 with #128 |
| #128 | `ISEQ` not implemented | " |
| #108 | `DC/DS` type `S` | 44 |
| #132 | **`&SYSECT` expanded to nothing, silently** | 39 — *and it corrected 80 decks that already assembled* |
| #133 | cross-section duplication factor silently zero | 0 — it changes a return code, not bytes |
| #136 | **each control section needs its own location counter** | ~80, and the `IDCCD*` family came back |
| #138 | base-register tie broken the wrong way | 3 |

`START`, `ISEQ`, `DC/DS` type `S` and the location counter behave like blockers —
close them and modules go through. **`&SYSECT` and the base-register tie
unlocked almost nothing and mattered most**, because they corrected object code
the assembler was already producing, silently and wrongly. See
[`docs/as370-gaps.md`](docs/as370-gaps.md).

One issue in that series, #131, was **wrong**: filed from an error message
without reproducing the case. It is closed with that stated.

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
- [x] **Get the members out of that unload — done, 2026-09-05.**
      [`tools/pdsunload.py`](tools/pdsunload.py) reads the unload member by
      member; `UTL.ASM` yields 64 members. cc370#113 stays open for `file370`,
      but it no longer blocks us. The header layout and the control case are in
      [`docs/private-macros.md`](docs/private-macros.md)
- [ ] Read `COMPLMD` before implementing #110 — especially how it decides what
      counts as a difference
- [ ] Keep the extract as reference material; **no MBT project, no port**
- [ ] Revisit `MVSSMP38` when M7 comes around

### 3. ✅ Tooling — extract on `mvsdev`, process on the Mac

Hercules **cannot be built on the Mac** (arm64): it compiles with
`--with-included-ltdl` and permissive CFLAGS, then fails to link because the
external packages ship prebuilt for x86 only and their CMake build script does
not work on this layout. Docker is not installed either. Abandoned deliberately.

**`mvsdev` has everything** in `/usr/local/hercules/bin`: `dasdls`, `dasdpdsu`,
`dasdseq`, `dasdcat`, `hetget`, `cckd*`. Reach it with `ssh mvsdev`.

The working split: **extract on `mvsdev`, process on the Mac.** Extraction needs
no running MVS, only the volume files, and happens once per artifact. Unpack a
pristine release into a scratch directory rather than reading a running
instance's volumes — `~/tmp/mvs38src-work/` holds one (2.1.4).

⚠️ **Two traps in `dasdpdsu` output**, both hit on 2026-09-04:

1. It writes **raw EBCDIC with no record separators**. Members are RECFM=FB 80,
   so split into 80-byte records first.
2. Convert to a **single-byte encoding** — `cp037` in, `latin-1` out. UTF-8 turns
   EBCDIC `X'5F'` (`¬`) into two bytes and shifts every column after it, which
   silently breaks column 72 and therefore the continuation rule.

Also useful: `BLDMVS.AWS` is a plain AWS tape and a 40-line host reader walks it
without Hercules at all.

- [x] Hercules utilities available (on `mvsdev`)
- [x] `as370` confirmed current — `as370/src/` unchanged since the installed build
- [ ] Build `cc370` freshly when `cmplmd370` lands

### 4. ◐ MVS/CE baseline — partly done

- [x] Pristine 2.1.4 unpacked on `mvsdev` at `~/tmp/mvs38src-work/MVSCE/DASD/`
- [x] **DLIBs confirmed on `smp000.3350`** — 34 `AOS*` libraries, exactly the set
      in Dave's appendix C. Also `SYS1.AMODGEN`, `SYS1.SMPCDS`, `SYS1.SMPPTS`,
      `SYS1.UMOD*`, `SYS1.HASPSRC`
- [x] Macro libraries extracted: `SYS1.MACLIB` (742), `SYS1.AMODGEN` (288),
      `SYS1.APVTMACS` (242)
- [x] `retcode` works — it needed a complete job card, nothing else
- [ ] Immutable snapshot with checksums → `baseline/checksums.txt`
- [ ] Inventory the baseline → `baseline/mvsce-*.md`: usermods, MVP packages,
      sysgen parameters, I/O gen
- [x] **Evaluate the SMP CDS: which sysmods are ACCEPTed?** — done, 2026-09-06,
      [`docs/accept-status.md`](docs/accept-status.md)
- [ ] Verify the runbook on a first full pass, raising 📄 to ✅

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

### 5. ✅ End-to-end test: done, and it went further than one module

Host-side extraction holds up. `dasdcat` reads distribution-library members with
no MVS running; `file370` walks them (CESD, IDR, control, text, MODEND); `as370`
produces object decks from Dave Kreiss' source; and the two sides can be compared
on section names and lengths **without a comparator existing yet**. 102 pairs
measured, 49 of them matching. [`docs/dlib-distance.md`](docs/dlib-distance.md).

The one correction it forced: the `AOS*` libraries hold **load modules**, not
object decks. Everything downstream follows from that.

The original checklist, with what actually happened:

- [x] Pull a module out with **no MVS running** — `dasdcat`, not `dasdpdsu`;
      the latter cannot read a RECFM=U library at all
- [x] `file370 -v` shows the record structure — CESD, IDR, control, text, MODEND
- [x] Read out sections and IDR records — done for 102 members
- [ ] Check one by hand against the same module on the running system — still
      worth doing once, as an independent check on the whole host-side chain

---

## What exists now that did not on 2026-09-04

Written up rather than remembered, because most of it is method rather than
result:

| Document | What it settles |
|---|---|
| [`docs/tree-wide-run.md`](docs/tree-wide-run.md) | the two tree-wide runs, and the numbers that count |
| [`docs/ifox-oracle.md`](docs/ifox-oracle.md) | how to ask the real Assembler XF a question, and every answer so far |
| [`docs/as370-gaps.md`](docs/as370-gaps.md) | six assembler defects, what each was worth, and one issue that was wrong |
| [`docs/private-macros.md`](docs/private-macros.md) | where the private macros are, and how to read an IEBCOPY unload |
| [`docs/complmd-spec.md`](docs/complmd-spec.md) | `COMPLMD` read as the specification for `cmplmd370` |
| [`docs/accept-status.md`](docs/accept-status.md) | the DLIBs carry the maintenance; MVS/CE modifies 28 modules |
| [`docs/dlib-distance.md`](docs/dlib-distance.md) | section lengths, `SPZAP` records, and whether another source copy fits better |
| [`docs/what-is-not-blocked.md`](docs/what-is-not-blocked.md) | how much of the backlog does *not* wait on Dave Kreiss' tape |

And the tooling in [`tools/`](tools): `awstape.py`, `pdsunload.py` (reads a real
MVS unload member by member), `measure-as370.sh`, `ebcdic2text.py`.

**A method worth carrying into every measurement here**, learned about ten times
in one day and in both sessions: *something delivers less than it should and does
not say so.* A truncated listing, an unquoted shell variable, a fixed array of
64, an implausible mutant, a listing that decides nothing because both hypotheses
give the same answer, `dasdcat` writing to stderr, `dasdpdsu` stopping at the
first illegal filename. **Every one was caught by a control case, never by the
tool.** Before a number is believed, construct the case whose answer is already
known and run it on both sides.

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
      (our side is measured now, see [`docs/accept-status.md`](docs/accept-status.md))
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

> **Partly answered 2026-09-06 without the 747 having been isolated.** The
> tree-wide run compared **all** 4,107 pairable modules, his marked ones among
> them: 832 are byte-identical and 431 differ only in `DS` holes. So the answer
> to "can we build on his work" is already **yes** — it turned out well, at a
> rate of roughly one module in three, and the toolchain is validated against
> known material. What identifying the 747 would still buy is the *split*: how
> much of that 30 % is his marked work and how much came right by itself.

### 6. Inventory and the two tables (M1)

- [ ] Inventory across all system libraries — **target libraries AND
      distribution libraries (`AOS*`)** (`dasdls`)
- [ ] CSECT, IDR and eyecatcher extraction, machine-readable as CSV
- [ ] Evaluate the SMP CDS on `smp000`: sysmod → element, plus ACCEPT status
- [ ] Index all local source pools: `MVSBLD/` (5,529), `IKJ/` (269),
      `www.stben.net/`, `mvssrc/mainframe.eu/`, `NEW.ASM`, `MVT.ASM`
- [ ] Join → table A (ported) and table B (missing)

### 7. ✅ as370 gap analysis (M2) — the gate is passed and the tool is fixed

**Measured tree-wide 2026-09-06: 4,510 of 5,528 modules assemble (82 %).**
The 150-module sample that opened this item is superseded; the numbers below are
the population.

| | first run | after the six fixes |
|---|---:|---:|
| assemble | 4,270 | **4,510** |
| paired against a DLIB member | 3,888 | **4,107** |
| **byte-identical** | 572 | **832** |
| only `DS` holes differ | 281 | **431** |
| length differs | 2,079 | 2,147 |
| only generated text differs | 589 | 433 |

**257 modules gained byte-identity, none lost it.** Full account in
[`docs/tree-wide-run.md`](docs/tree-wide-run.md), the assembler work in
[`docs/as370-gaps.md`](docs/as370-gaps.md).

- [x] Extract `SYS1.AMODGEN`, `SYS1.APVTMACS`, and the whole DLIB macro set
- [x] Recover the private macros — 433 of 436, tape and mirrors
- [x] Categorise failures by first cause over all 1,256 (now 1,018)
- [x] Close six `as370` gaps against IFOX00
- [x] **Cross-check against IFOX00 directly** — the pipeline exists and four of
      five sampled modules produce byte-identical decks
- [ ] Extend that cross-check to the whole assembling tree — item 3 of *Start
      here*
- [ ] Re-categorise the remaining 1,018 failures; the last categorisation was
      before the six fixes

**The gate verdict:** `as370` is not the bottleneck and is no longer a suspect.
What the remaining differences are made of is a source question.

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

> ⚠️ **Downgraded 2026-09-06 — this may not be an SMP defect at all.** Dave
> Kreiss writes that he and Fish diagnosed the intermittent I/O errors with
> Hercules traces and diagnostic builds, and that **Fish changed Hercules to
> eliminate them**. He believes the issue is history but wants to verify it on
> his rebuild. **Do not start the SMP source analysis** until that verification
> comes back — the whole strand may be chasing a fixed emulator bug.

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
