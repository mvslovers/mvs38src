# Dave Kreiss' answer — and it contradicts two of our premises

Received 2026-09-12, written before he had read that day's mail, so it answers
the *previous* one. It is the most consequential message from him so far: it
corrects our object baseline, corrects where our source should come from, and
almost certainly explains the `./ DELETE` blocker we spent a day on.

Recorded here in full effect rather than summarised, because two of the items
reverse decisions this repository has written down as settled.

---

## 1. He says compare against **TARGET**, not DLIB — and our reason for DLIB was wrong

His words, twice:

> *"Using the current MVS 3.8 DLIBs is not what is on the running system because
> not all PTFs have been accepted so therefore the DLIBs are back level to the
> running system. Also both DLIB and Target libraries are load libraries created
> by the linkage editor."*

> *"Let me emphasize that target not DLIB is the version of code you should
> compare to since target is what the running system uses. Target and DLIB are
> out of sequence … The reason for difference is some of the maintenance has
> never been ACCEPTED. Plus there are some USERMODS also in the APPLY (target)
> side."*

**Our stated reason for choosing DLIBs is refuted.** [`workplan.md`](workplan.md)
and the early framing argued that `AOS*` holds *"IBM's object as it shipped, with
no linkage editor in between, so no RLD relocation, no ESDID renumbering, no
CSECT packing to see through."*

That is not what a DLIB member is. Dave: both sides are linkage-editor output;
a DLIB member is each element *"assembled and linked as a separate load
module"*, mostly not executable because external references are unresolved.

**And we had already half-measured this without drawing the conclusion.**
`work/measurements/dlib-bytes/tk5/AOSB3/IEFJDSNA.bin` is 549 bytes — **not a
multiple of 80** — with control records at the front. That is a load module, not
a card-image object deck, and it was noted on 2026-09-12 in
[`ds-holes.md`](ds-holes.md) while establishing something else. The premise was
never revisited.

### What that does and does not change

- **It does not invalidate a single measurement.** Every figure we quote is
  "source assembles to the DLIB member", which remains a true and machine-decided
  statement. What changes is what it *means*: the DLIB is one maintenance level,
  not the definitive one.
- **It does re-open the baseline question**, and the person re-opening it built
  the thing. `deck-vs-tk5-ce.md` chose TK5 over MVS/CE; it never asked DLIB
  versus Target.
- **The single-CSECT advantage of DLIBs is real and survives.** A DLIB member
  holds one element; a target library member is a packed load module with several
  CSECTs relocated into it. That is harder to compare, not impossible —
  `cmplmd370` descends from `COMPLMD`, which Dave uses on targets.

**The test, and it is cheap:** pull TK5's target libraries with `dlibpull.py`
(the same reader, a different data-set list) and score the same source against
both. If the two baselines agree on most modules the question is academic; where
they differ, Dave's argument says the target is right. **Not run yet.**

## 2. Where our source should come from — and here he is right but it costs us nothing

> *"Long story made short use the target source libraries that result from the
> build job streams instead of using the source of the build job streams."*

So: not `NEW.ASM`, not `MVT.ASM`, not the `MVSSRC.SYM*` RELFILEs, not the
`MVSBLD` directory — the **source libraries the build produces**.

We had arrived at the neighbouring answer by a different route
([`source-states.md`](source-states.md)): the archive copy is not the same tree
as what his chain produces, and the applied state beats it. But we extracted
`MVSSRC.BLD.AMVSSRC`, the **distribution** source library, where he names the
**target** one, `MVSSRC.BLD.MVSSRC`.

**Measured, 25 modules drawn at random, columns 1–72: identical, 25 of 25.**
Both libraries hold 5,529 members. So on *our* run-7 build the two source
libraries agree, and the extraction we have is the one he recommends in all but
name.

That is consistent with his own explanation: a **fresh install** ACCEPTs
everything and the two sides are in sync — *"Because all jobs do an ACCEPT of all
functions and PTFS the Target and DLIBs of the install are in sync"*. It is *his
working system*, carrying un-ACCEPTed maintenance, where they diverge. Ours is a
fresh install.

## 3. He explains the `./ DELETE` blocker, without having seen the question

> *"There is a step you may not be following. First I use a copy of my TK3 system
> because the last MAINT job modifies the running system. **It copies a modified
> SMP program to SYS1.LINKLIB. That step is needed in order to complete the
> build.** It is my guess that is cause of some failures. I disable that step
> since copying once is sufficient."*

That step is **`MAINT05Z`, "COPY SMP TO LINKLIB"** — the one job of the 83 past
his own stop that writes to `SYS1.LINKLIB`, and **the one we deliberately
skipped** on 2026-09-12 to avoid touching the running system
([`dave-install-log.md`](dave-install-log.md)).

And his SMP is not stock:

> *"because SMP had some functionality missing I updated SMP to have that
> functionality"*

> *"The biggest difference is that my version of SMP manages the source side as
> well as the object side."*

**So the most likely explanation of `HMA3462 INVALID IEBUPDTE CONTROL STATEMENT`
on 485 of his SYSMODs is that we ran them through TK5's stock SMP instead of
his.** `./ DELETE` is a source-side operation, and source-side management is
precisely the functionality he says he added.

The two-sided case we ran on 2026-09-12 stands as a measurement — stock SMP here
takes `./ CHANGE` and refuses `./ DELETE` — and its interpretation flips: that is
not a fact about `./ DELETE`, it is a fact about *which SMP* was asked.

**This reverses the decision.** Skipping `MAINT05Z` was presented as the careful
choice; it was the one that broke the chain. Running it needs `MVSTK5-BLD`
backed up first — the backup that the classifier blocked on 2026-09-12 and that
Mike has since authorised.

## 4. The `^`/`¬` class was his deliberate work

> *"One of the things I did was to update all source which contain any character
> which EBCDIC to ASCII conversion changed the character so that those characters
> never lost their value with to / from ASCII. Many of the early PTFs were just
> for that purpose. Some source actually contained long DC statements with hex
> values. Those were converted from `DC C'hex stuff'` to `DC X'hex digits'`."*

That is the class we found independently as the `^`/`¬` code-page substitution —
ten modules recovered by one change, `tools/caret_fix.py`. **His `DSK0nnn` PTFs
already do this**, which means the modules where we still see it are ones his
early PTFs have not reached in the copy we hold, and it is another argument for
taking the built libraries rather than the archive.

## 5. He offers the thing that would settle the macro question

> *"Another thing I can do is create a zip file of all the resulting source
> (including all assembler code and macro libraries) for you to use."*

**That is better than the tape and better than the `PVTMAC`/`APVTMAC` request in
our own mail.** It is built output at a known level, and it would close the 319
mirror macros at an unestablished maintenance level in one step — the single
largest unknown we introduced ourselves.

## 6. Things he confirms or reports

- He rebuilt the install tape and ran the complete build several times. The
  `SMPWRK3` intermittent I/O errors were **a back-level Hercules**, now fixed.
- He works modules **outside** SMP: edit, assemble, `COMPLMD`, loop. *"The manual
  process of figuring what the inserted/deleted instructions is very time
  consuming."*
- The blocker he names is not speed: *"Doing the rebuild process on the PC won't
  speed me up much unless I can get some tools on the PC to address the process
  of figuring out what changed based upon the disassembly of the module and the
  assembled version."*
- Sometimes **IBM's DSECTs are missing**, and references to them make rebuilding
  hard.
- He is out of town and will answer our 2026-09-12 mail in a few days.

### What he is asking for, read plainly

A tool that takes the difference between the disassembled object and the
assembled source and says **what changed** — not a faster loop. `tools/where.py`
is the first thing we have that does part of that: every differing byte with the
source statement that owns it. It is worth telling him, with an example.

## What to do about all of it, in order

| | |
|---|---|
| 1 | **Run `MAINT05Z` and the chain past it**, after backing up `MVSTK5-BLD`. It is the named cause of the `./ DELETE` failures and the 486 missing `DSK` markers. |
| 2 | **Pull TK5's target libraries and score against both baselines.** Cheap, same reader, and it settles item 1 of this document rather than arguing it. |
| 3 | **Accept the zip when it comes.** It supersedes the tape request and closes the macro-provenance question. |
| 4 | **Tell him about `where.py`**, because it is the thing he said he needed and he does not know it exists. |

Nothing here invalidates a measurement. Two of the four reverse a decision, and
both decisions were ours rather than his.
