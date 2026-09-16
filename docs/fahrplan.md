# Fahrplan — the baseline is decided, and what follows from it

> ## ⚠️ The goal was reformulated on 2026-09-16, and this page predates it
>
> **The five stages below still hold as a sequence.** What changed is the target
> they run at: the project no longer aims at byte-identity alone but at **every
> module explained, as many as possible byte-identical, and a system that builds
> and runs from those sources.** There are two measured verdicts now —
> [`../README.md`](../README.md), [`../CLAUDE.md`](../CLAUDE.md).
>
> **And the reason is a finding this page could not anticipate.** Five macros are
> measured to exist at **two levels**, with the split running **per module**:
> `SCHEDULE`, `TSCBD`, `GETMAIN`/`FREEMAIN`, `SETFRR`, `XCTL`/`IHBINNRB`, touching
> 332 modules. IBM assembled over years against a macro library that moved between
> assemblies, so **no single macro library reproduces them all and no archive can
> supply one** ([`macro-attribution.md`](macro-attribution.md)).
>
> Stage 5 below is therefore no longer the last stage. **See §7.**

> **Overtaken in three places on 2026-09-11, corrected inline below rather than
> rewritten.** Stage 1's capture system, §4's account of run 5, and stage 3's
> status all moved after this was written. Each correction is marked
> **`2026-09-11:`** where it applies. The direction — TK5 as the object
> baseline, and the five stages — stands.

2026-09-10. **Supersedes the direction of [`workplan.md`](workplan.md)** (2026-09-04)
on one point only: that document left the object baseline open and assumed MVS/CE.
Its host-side recovery machinery — the extract / assemble / compare cycle on the
Mac, the requirement that everything be machine-decidable — is unchanged and still
governs.

## 1. The decision

**The object baseline is TK5.**

> **2026-09-13: which library WITHIN TK5 is now also decided — the TARGET, with
> the DLIB as the fallback.** Dave Kreiss reversed the assumption this document
> was written under ([`kreiss-reply-2026-09-12.md`](kreiss-reply-2026-09-12.md)):
> the DLIBs are back level wherever maintenance was never ACCEPTed, and both
> sides are linkage-editor output, which refutes the stated reason for preferring
> a DLIB. Measured in [`baseline-dlib-vs-target.md`](baseline-dlib-vs-target.md):
> the two are 167 verdicts apart and 23 of the 66 recovered TSO modules are
> recovered against the back-level copy. Mike chose target-primary on 2026-09-13.
> **§1 below is unaffected** — it decides *which system*, and that is still TK5 on
> the evidence given. The paragraph that this DOES touch is the one after it.

Measured, not argued ([`deck-vs-tk5-ce.md`](deck-vs-tk5-ce.md)): over 3,988
modules, where TK5 and MVS/CE both carry maintenance Dave Kreiss' source hits TK5
**15 times to 1**, and it is byte-identical to a maintained object MVS/CE does not
carry at all in **7 modules against 0** the other way.

**And the decision is smaller than it looks.** In raw match count the two systems
are ten modules apart in 3,988 — 1,084 against 1,094 — because 87 % of the corpus
carries the same object on both and cannot distinguish them at all. What the
choice buys is a baseline that is never *behind*: TK5 is at base FMID in none of
the 515 divergent modules, MVS/CE in 127.

Three things the decision does **not** rest on, recorded so nobody re-derives
them:

- not on lineage-by-assertion (TK3 → TK4- → TK5), which was the *prediction*, not
  the evidence;
- not on the raw count, which points the other way and is the wrong grouping;
- not on TK5 being "more complete" — neither deck is a superset of the other
  ([`dlib-distance-tk5-ce.md`](dlib-distance-tk5-ce.md)).

### What must be said out loud when TK5 becomes the reference

The goal is a source tree at **MVS 3.8j DLIB level, distribution-independent** —
not "source for TK5". TK5 carries 115 USERMODs, so non-IBM object code in it has
to be named rather than inherited silently. It is a short list:

| | modules |
|---|--:|
| TK5 modules changed by a USERMOD in the **distribution** zone | **4** |
| of those, in this corpus | 2 — `IEFVHE`, `IEFVHF` (`#DYP005`, `#DYP003`) |
| TK5 modules changed by a USERMOD in the **target** zone only | 49 |

The 49 are the running system and never reach a DLIB. Four objects is the whole
non-IBM surface of TK5's distribution libraries, and both of ours show it: same
RMID as MVS/CE, same length, different bytes.

> **2026-09-13: and this is the price of the target decision, stated where it
> belongs.** Choosing the target libraries as the yardstick brings those **49
> USERMOD-changed modules into the measurement**, where the DLIB kept them out.
> The project's stated goal is a source tree at MVS 3.8j level,
> *distribution-independent*; the target library is TK5's running system, Rob
> Prins' modifications included. So the goal and the yardstick now pull in
> slightly different directions for up to 49 modules out of 4,809.
>
> That is a real tension and it is not a reason to reverse the decision: Dave's
> argument is about *IBM's* un-ACCEPTed maintenance, which is the larger effect,
> and the DLIB is demonstrably behind. But it names the next measurement — **of
> the 38 modules that differ between the two baselines, how many differ because
> of a TK5 USERMOD rather than IBM service?** That needs the target zone's
> SYSMOD-to-module mapping out of the SMP CDS, and until it is run, every one of
> the 38 is *assumed* to be IBM maintenance. `IKJEFF53` is already a known
> usermod target on MVS/CE, and it is in the 38.

## 2. The other axis — which source tree, and a finding that reshapes the question

The baseline decides the **right-hand** side of every comparison. The left-hand
side is a separate choice and must not be folded into it. Three candidates were
on the table:

1. Dave Kreiss' source as it sits in the archive — `MVSSRC/Dave Kreiss - MVS from
   Source/MVSBLD/`, 5,528 `.ASM` members, and **the copy all 5,528 reference decks
   were assembled from**;
2. Dave's source "as patched" — what the build chain has on the system;
3. IBM's delivery level — `~/repos/mvs/mvs38-ibmsrc`.

**Candidates 1 and 2 are the same tree at two different states, and they are not
equal.** `MVSSRC.BLD.AMVSSRC` on `MVSCE-LAB` holds 5,529 members against the
archive's 5,528. Over a random sample of 400, comparing columns 1–72 only and
normalising the `^` that the archive extraction produced where the source carries
the PL/S `¬` (`X'AC'`):

| | modules | |
|---|--:|--:|
| source identical | 213 | 53.2 % |
| **differ only in comment lines** | 127 | 31.8 % |
| **differ in code** | **60** | **15.0 %** |

The comment-only class is Dave's own disabled lines. `IGFPMMSG` is 204 records in
the archive and 1,477 on the system; the extra 1,273 are all of the form

```
*DSK1231 @01      EQU   01
```

— statements he commented out, marked with his own `DSK` tag, which the archive
copy simply does not carry. Assembled with `as370`, **the two versions produce
byte-identical decks**. For that class the archive has lost Dave's record of what
he disabled, and nothing else.

The 15 % that differ in code are a different matter, and they are **not
cosmetic**. Some are large — `BLSSLPDE` has 556 code lines in the archive against
2,046 on the system, `ISTSDCSU` 828 against 2,936 — but size is not the test. The
test is whether they assemble to the same object, and that was measured: a second
sample of 300, restricted to modules IFOX00 assembles cleanly (`asm_ok`, so both
sides can be put through `as370`):

| | modules |
|---|--:|
| source identical | 164 |
| differ only in comment lines | 95 |
| **differ in code** | **41** |
| — of those, **same deck** | 8 |
| — of those, **different deck** | **31** |
| — not comparable (one side `rc != 0`) | 2 |

**Three quarters of the code differences change the object.** Over the tree that
is on the order of one module in ten where *which copy of Dave's source you use*
decides what comes out — including `BLSUPRTA`, `BLSFVRFY` and `IKJEFA42`, and a
row of modules like `BLSFSD00` and `BLSEAUTH` where the line counts are identical
and the decks still differ.

**All 5,528 reference decks were assembled from the archive copy.** That does not
invalidate them — they are a consistent reference and `as370` is measured against
them fairly — but it does mean the figure "Dave's source assembles to 1,084 of
3,988 shipped objects" is a statement about *the archive copy*, and the other
copy has not been measured at all.

### What that means for the plan

**"Dave's source" has not been a well-defined phrase, and every figure this
project quotes about it was taken against the archive copy.** That is not
retroactively wrong — the archive is a real state of his tree — but it has to be
named from here on, and the two states have to be told apart.

Three consequences:

- **A source snapshot without its SMP state is unpinned.** Dave designed the
  thing as an SMP-maintained tree; `AMVSSRC` on LAB has had four partial build
  runs ACCEPT into it, so it is not the tape state either. Any measurement of
  "Dave's source" records the library *and* the SYSMOD list.
- **The pristine tape state is reachable off-host and does not need a build.**
  `BLDMVS.AWS` is in the archive, and `tools/awstape.py` plus `tools/pdsunload.py`
  already read AWS tapes at member level. That gives candidate 2's true origin as
  a third column for the cost of an extraction, not a build.
- **Candidate 3 stays a control, not a base.** `dlib-distance.md` already
  measured the web mirrors as an alternative source and found they almost never
  match where Dave's does not — 2 of 300. IBM's delivery level is worth the same
  treatment, and for the same reason: to know whether it is a lever, not because
  anyone expects it to be.

**So the choice is not made by argument.** The instrument that answered the
baseline question answers this one unchanged — same decks, same comparator, one
more column. Run it against all three source states and read the number.

## 3. The systems, and what each one is for

| system | mvsMF | Hercules | credentials | role |
|---|---|---|---|---|
| `MVSCE-DEV` | `:8080` | — | `see .env` | **tabu** — the user's own |
| `MVSCE-LAB` | `:8082` | — | `see .env` | the IFOX00 oracle that produced the 5,528 reference decks; build runs 1–4 |
| `MVSCE-EXP` | `:8083` | — | `see .env` | untouched MVS/CE reference. **Run it.** On 2026-09-11 one request to it settled a question a full day of work had not: stock MVS/CE ships no `IHADVCT` in `SYS1.AMACLIB` at all, so LAB's pre-APAR copy was added rather than degraded. A control that is never run is not a control |
| `MVSTK5-REF` | `:8084` | `:8484` | `see .env` | **the object baseline. Read-only.** |
| `MVSTK5-BLD` | `:8085` | `:8585` | `see .env` | where Dave's build runs from here on |

The pair differs by system and lives in `.env`; see `tools/creds.py`. The wrong pair returns
401, and a 401 loop is indistinguishable from an outage from the outside.

**After every IPL: `/S HTTPD` and `/S FTPD`.**

## 4. Where the work stands

| | |
|---|---|
| `as370` == IFOX00 | **5,427 of 5,528 decks** at cc370 `fd287d3`; `as370` alone flags 0 |
| Dave's source == shipped object (TK5) | 1,084 of 3,988 |
| Dave's build | **run 6 completed** 2026-09-11 on `MVSTK5-BLD` — 260 jobs to the phase-1 boundary, two non-clean and both documented harmless. Runs 4 and 5 died of space; see `run6-predictions.md` |
| EREP macros still missing | 4 — `ENTRIES` `ETEPILOG` `FREETAB` `SUMMARY` |

Run 4 is not worth restarting on LAB. It was always going to move to
`MVSTK5-BLD`, and restarting it there costs the same and produces the thing the
next step needs.

> **2026-09-11: the table's "runs 4 and 5 died of space" is wrong about run 5.**
> Run 5 reached job **235 of 260 and was stopped deliberately**
> ([`dave-install-log.md`](dave-install-log.md)). What happened in it was worse
> than dying: `MAINT03B` ended `IEC031I D37-04` mid-write and every later APPLY
> added another torn member, so the run produced a *complete-looking* build on
> damaged libraries — and every TK5 figure taken before run 6 rests on it.

**The parity figure is pinned to a commit on purpose.** It was 5,418 at the
promoted baseline (`f1cec11`, cc370#344) and is 5,427 at `fd287d3` — measured
tree-wide by cc370 with a three-way control: `amaclib-live` last and
`amaclib-live` absent give the *same set* of modules, +0/-0, while
`amaclib-live` first gives 5,426. An unattributed parity number is a number
that has already started going stale; see `docs/missing-macros.md` for what the
macro path did to this one.

**And the reference itself is no longer trustworthy on `MVSCE-LAB`.** Its
`SYS1.AMACLIB` is not in the state that produced the 5,528 reference decks on
2026-09-07 — proved from IFOX00's own diagnostics, not inferred. Re-running the
oracle there would not reproduce the corpus we measure against. That is the
argument for a pinned reference system, and `MVSTK5-REF` is it.

## 5. The stages

> **Status, 2026-09-12.** Stages 2 and 3 are done; stage 1 is the only blocker
> in the plan and it holds stage 4; stage 5 has not begun and is, by this
> document's own words, "the actual project".
>
> | | stage | state |
> |---|---|---|
> | 1 | is TK5's IFOX00 the same assembler? | **open** — the run died in its first job on a missing `IBMUSER.PVTMAC`, and its `SYSLIB` would have named TK5's own macro libraries, which moves 68 modules for reasons no assembler question can explain |
> | 2 | Dave's build on `MVSTK5-BLD` | ✅ runs 5, 6, 7 |
> | 3 | `ZLMDRPTD`/`ZLMDRPTT` against TK5 | ✅ 2026-09-11, on the clean run-6 build: 1,420 of 5,448 CSECTs equal |
> | 4 | re-cut the reference against TK5 | not begun; depends on 1 |
> | 5 | the 459 matching neither system | not begun |
>
> **And §2's question is half answered.** The three source states were measured
> against TK5's object on one instrument
> ([`source-states.md`](source-states.md)): archive 1,084, applied-phase-1 1,076,
> **applied-phases-3-5 1,089** — the applied state wins on identity *and* on
> distance. Two of §2's assumptions fell with it: the third column does not
> exist off the tape (`BLDMVS.AWS` carries no source tree), and 486 modules
> still lack their `DSK` markers because SMP rejects `./ DELETE` on RECEIVE
> ([`dave-install-log.md`](dave-install-log.md)).
>
> **Distance to the goal, stated plainly: 1,089 of 3,988 reference modules are
> byte-identical. 2,899 are not.** That is the work.


### Stage 1 — is TK5's IFOX00 the same assembler? *(blocks stage 4, not stage 2)*

Every recorded figure is against **MVS/CE's** IFOX00, which is IBM's XF plus part
of Greg Price's `ZP60` family ([`ifox-lineage.md`](ifox-lineage.md)). TK5 carries
115 USERMODs against MVS/CE's 37, so the two assemblers may not be the same
program.

The cheap version has been asked: `BAS 14,TGT` assembles to `4DE0 F004` at
severity 0 on both, so `ZP60025` is applied on both. **One instruction is not an
assembler.** The real test is the corpus: run `tools/ifox_run.py` on
`MVSTK5-BLD` and compare the decks against the recorded 5,528.

> **2026-09-11: the capture system is `MVSTK5-REF`, not `MVSTK5-BLD`.** REF was
> pinned as the oracle that day — frozen, DASD copied to
> `~/MVSTK5-REF-frozen-20260911`, macro snapshots 2,332 of 2,332 identical
> across three assemblies — and `tools/systems.json` carries `oracle: true` on
> it and nowhere else. `ifox_run.py --system ref` writes to
> `work/measurements/ifox-run-tk5ref/`. §6's "nothing is submitted to REF" is
> superseded by the same decision: an oracle that takes no work cannot produce a
> deck, and what keeps it honest is the frozen copy plus `tools/macrosnap.py`.
>
> **A first attempt ran at 10:33 and died in its first job**, `IEF212I IFX0000
> S01 SYSLIB +006 - DATA SET NOT FOUND`: `IBMUSER.PVTMAC`, the 444 private
> macros, exists on `MVSCE-EXP` and not on REF. `IBMUSER.IFOXOB2`, `IFOXLST` and
> `SRCD` are missing there too, and `IBMUSER.SRC2` holds only the 25 members of
> the abandoned first batch.
>
> **And the `SYSLIB` in that job would have given a wrong answer even so.** It
> names the six `SYS1.A*` libraries, which on REF are *TK5's own*.
> [`macro-tk5-vs-ce.md`](macro-tk5-vs-ce.md) measured that 129 of the differing
> macros sit on the `-I` path and move **68 modules**, and states the rule this
> run has to obey: the corpus run must hold the macros constant and carry MVS/CE's
> across. Uploading them as `IBMUSER.*` data sets leaves REF's frozen `SYS1`
> libraries and the macro snapshot untouched.

- decks identical → the reference is not MVS/CE-specific, everything transfers;
- decks differ → the reference belongs to MVS/CE and re-baselining costs a full
  corpus run, exactly as [`erep-adoption.md`](erep-adoption.md) had to pay.

**Two things must move with the reference, not after it.**

*The stamp table.* Every normalised figure — `as370 == IFOX00` at 5,444 rather
than the raw 5,418 — is computed by re-assembling with the timestamp the IFOX00
run itself recorded, per module, in `work/measurements/ifox-run/state.tsv`. Cut a
new reference on TK5 without re-cutting that table and every normalised number
afterwards quietly measures against MVS/CE's clock **and looks entirely
plausible while doing it**. Raised by the cc370 session, which named the class
correctly: a frozen file and a stable measurement are indistinguishable from the
outside.

*The macro libraries.* A deck difference between the two systems is only an
assembler difference if both assembled the same macros. **They do not start from
the same member list.** `SYS1.MACLIB` on TK5 carries five members MVS/CE has
none of — `BTMHJN` `BTMIOBWA` `IECPDSCB` `IEZCTGPL` `IHADECB` — and `SYS1.AGENLIB`
one more, `OLDCARD`. Four of those five are macros this project had to hunt for
across GitHub, bitsavers and the mailing lists in September
([`missing-macros.md`](missing-macros.md)); **TK5 had them all along.** The four
EREP macros still outstanding — `ENTRIES` `ETEPILOG` `FREETAB` `SUMMARY` — are on
neither system, which is a believable zero precisely because the same query found
the five that are there. TK5 and MVS/CE have not
been compared at the macro level at all, and `dlib-distance.md` already warns that
319 of our private macros come from mirrors at an unestablished level. **Compare
`AMACLIB`, `AMODGEN`, `AGENLIB`, `ATSOMAC`, `ATCAMMAC` and `APVTMACS` across the
two systems before reading anything into a deck difference** — same instrument as
the DLIB pull, `tools/dlibpull.py` with a different dataset list. If they are
identical the confound is gone for everything downstream; if not, the macro delta
is itself a result.

**A cheap first probe exists, and it is sharper than it first looked.** cc370
offers ten modules — `IFNX1A` `1J` `3N` `5A` `5C` `5D` `5V` `6B`, `IFOX0A` `0D` —
where the two assemblers produce an **image-identical** module and the same number
of RLD entries at the same addresses, differing only in the **`R` field**: the
ESDID the relocation points at. `as370` puts it on the enclosing `SD` where
IFOX00 names the `LD` or `ER` entry, and the ESD cards are byte-identical on both
sides, so both IDs exist either way. (`IFFAHA16` is not in this class — there only
the card encoding differs — and `IFNX5C`/`IFNX5D` also differ in addresses, so it
is 10 + 1, not 11 alike.)

That is a **discrete value**, not a byte count: it does not depend on the stamp or
the clock, which is what makes it a good first probe. Same `R` fields out of TK5's
IFOX00 as out of MVS/CE's ⇒ the divergence is `as370`'s; different ⇒ a lineage
answer for a fraction of a corpus run. Still worth running *after* the macro
comparison, for the reason above.

Corrected from cc370's first report, which said `as370` emitted *fewer* RLD
entries. Their parser stepped a fixed 8 bytes and ignored the **RLD continuation
bit `X'01'`**; `as370` uses the continuation form and IFOX00 here does not, so the
stride drifted and invented entries. The tell was `@0x404040` in the output —
three EBCDIC blanks, not an address.

**One family will need `state.tsv` most.** 21 of the 26 stamp-dependent modules in
the whole corpus are `IFNX*`/`IFOX*`: **Assembler XF assembles itself** and stamps
its own build time into its own object. If the reference moves to TK5, that is
exactly the family where a missing stamp table would silently poison the numbers.

### Stage 2 — run Dave's build on `MVSTK5-BLD`

**Back it up first.** TK5 brings its own shutdown, and it is the right way in:

```
/S SHUTFAST          the fast one -- use this
/S SHUTDOWN          the same thing with a 30-second pause and a slower drain
```

Both drive `scripts/shutdown` under HAO: `$PJES2`, then `Z EOD`, then quiesce,
then power off, each step triggered by the message the previous one produces. The
console is reachable over the Hercules web server (`:8585` for `MVSTK5-BLD`,
`:8484` for `REF`) — an MVS command goes in with a leading `/`:

```sh
curl -s -X POST --data-urlencode "command=/S SHUTFAST" \
     --data "msgcount=8&norefresh=1" \
     "http://mvsdev.lan:8585/cgi-bin/tasks/syslog"
```

The DASD is **1.5 GB** in `~/MVSTK5-BLD/dasd` — measured 2026-09-13; the 275 MB in the first version of this line was wrong or the build volumes have grown into it. `mvsdev` had 28 GB free, so `cp -a` fits, once Hercules has exited. There is already a `dasd.backup-20260910-1410` beside it.
**Restart is `cd ~/MVSTK5-BLD && ./mvs` in tmux window `0:4`** — `0:3` is `REF`,
`0:0` is `MVSCE-DEV` and stays untouched. Then `/S HTTPD` and `/S FTPD`.


**Run the driver on `mvsdev`, not from a session here.** The chain is 259 jobs
and hours long; a driver started as a background task on this machine is bound
to the session's task lifetime and was killed at job 20 with `EBB1102D` still
running. Copy `tools/bldrun.py` over, point `SNAPDIR` at a local directory, and
start it under `nohup`:

```sh
scp tools/bldrun.py mvsdev:~/
ssh mvsdev 'cd ~ && nohup python3 bldrun.py --start "$01SMPAL" --max 300 > bld.log 2>&1 &'
```

Restarting after an interruption: **do not restart on the member that is still
`ACTIVE`** — that submits it twice. Read its `EXEC BLDSUB,MBR=` card and start
from the successor.

Four things had to exist on TK5 before the chain would run at all, none of them
on Dave's tape:

1. **His five procedures** — `BLDCLR` `BLDCOPY` `BLDPRT` `BLDSMP` `BLDSUB` — copied
   from `MVSSRC.BLD.SMP.JCL` into `SYS2.PROCLIB`, which is in TK5's JES2
   concatenation (`S SHUTDOWN` proves it).
2. **The twelve build volumes**, in `local_conf/01`. `BLDDLB` carries address 192
   in the package and 192 is TK5's `TSO003`; since Dave's JCL addresses volumes
   only by `VOL=SER`, it sits at `19E` without consequence.
3. **The IBM source distribution** — `BLDSMP` references **224 datasets** under
   `MVSSRC.SYM*`, `EREPSY`, `TIOCOP`, `ES1102`, `ET1102`, `ET2402`. They live on
   the source volumes, which TK5 ships as a separate download together with CBT
   (`srccbt.zip`, and its `conf/source_dasd.cnf` names exactly `348`–`34B` plus
   `0247`). TK5 gens those addresses; MVS/CE does not, which is why `MVSCE-LAB`
   carries the same volumes at `350`–`353`.
4. **A catalog entry for each of them.** They are in the *master* catalog on
   `MVSCE-LAB`, not a user catalog, so 254 `DEFINE NONVSAM` statements. One
   IDCAMS job, `CC 0000`.

`tools/bldrun.py` with `--system bld`, from `$01SMPAL`. What run 4
learned carries over: SMPSCDS `DR=4500`, SMPPTS `1000`, `MSGCLASS=H`, purge the
spool before starting (`$HASP355 SPOOL VOLUMES ARE FULL` killed a run at job 41),
and the nine EREP macros staged.

Expect new failures: run 4's fixes were made against MVS/CE, and TK5 is a
different system. That is the point of running it.


### The volume geometry, and the limit that decides it

The first run died of space: `BLDSR1`, `BLDSR2`, `BLDLS1` and `BLDWK1` were at
**zero free tracks**, `MAINT04E` ended `IEC031I D37-04` writing `AMVSSRC`, and
about a hundred members of the source library became unreadable — `MVSMF106E I/O
ERROR READING` on the console, `451 Read error on data set after 0 bytes` over
FTP, two independent readers agreeing.

> **Correction, 2026-09-11: volume geometry was half the story.** The same
> `IEC031I D37-04` came back on the new 3390-2 volumes at `MAINT03B`, for a
> different reason: four of `$01SMPAL`'s 189 allocations carry no secondary
> quantity — `S=,` — at a primary sized to fill a whole 3390-1. Making the
> volumes bigger did nothing for the datasets, because those come off Dave's tape
> and out of `$01SMPAL` at their original sizes, and every build volume stood
> exactly half empty while the library on it filled up. `tools/bldrun.py` now
> supplies `S=50` at submit time. The geometry below is necessary and was not
> sufficient.

**MVS 3.8j stores a track address in a signed halfword, so a volume may not
exceed 32,767 tracks** ([Jay Moseley on modern
DASD](https://www.jaymoseley.com/hercules/installMVS/modernDASD/modernDASD.htm)).
That is the whole story:

| model | cylinders | tracks | |
|---|--:|--:|---|
| 3390-1 | 1,113 | 16,695 | what Dave ships |
| **3390-2, custom** | **2,184** | **32,760** | **seven under the limit** |
| 3390-3 | 3,339 | 50,085 | **rejected by MVS** |

A 3390-3 was tried first and MVS answered `IEF193I SPACE NOT OBTAINED BECAUSE OF
PERMANENT I/O ERROR` on every allocation. The wrong limit (65,535, from a guess
about halfword addressing) was in play for an hour before the source settled it
at 32,767 signed.

**And a `dasdinit` volume is not usable; a `dasdload` one is.** `dasdinit -a`
produces the right geometry and MVS still refuses to allocate on it. `dasdload`
with a two-line control file writes a VTOC MVS accepts:

```
BLDSR2 3390-2 2184
sysvtoc vtoc trk 60
```

Neither ICKDSF can repair the difference: the base level answers
`ICK30712I DEVICE TYPE VERIFICATION FAILED` for a 3390, and TK5's own
`Packages/ICKDSF13` — release 13, installed as `ICKDSF13` in `SYS2.LINKLIB` —
answers `ICK31851I EXTENDED CKD FUNCTIONS CANNOT BE ACTIVATED`, because ECKD
channel programs arrived with MVS/XA and this system has none.

`IEHLIST` reports **0 free cylinders** on a fresh `dasdload` volume, because
`dasdload` writes no Format-5 free-space DSCBs. That is not the truth: an
`IEFBR14` allocation of five cylinders succeeds. **Test the allocation, not the
report.**

The twelve 3390-1 originals are kept in `~/MVSTK5-BLD/dasd-3390-1-alt/` and
Dave's pristine copies in `~/blddasd-orig/`.

### Stage 3 — `ZLMDRPTD` and `ZLMDRPTT` on `MVSTK5-BLD`

> **2026-09-11: done, on run 6.** `RPTDLB/JOB00815` and `RPTTGT/JOB00816`, both
> `CC 0000`, against the clean build. 81 missing load modules became 2, and
> equal CSECTs went 1,003 → 1,420 on the distribution side and 1,286 → 1,419 on
> the targets. The run-5 figures it replaces came off the `D37`-damaged build,
> and the published `equal` row on both was counted from the `SUMMARY` page
> rather than the detail — see
> [`build-vs-original-tk5.md`](build-vs-original-tk5.md).

**This closes the original ask.** `ZLMDRPTD` compares the build's DLIBs against
the system's own DLIBs, and on `MVSTK5-BLD` those are TK5's — so it is the same
job that ran on 2026-09-09 ([`build-vs-original.md`](build-vs-original.md)),
against the baseline that was chosen today. `tools/lmdreport.py` already replaces
the two `PGM=SORT` steps TK5 also lacks.

Then, and only then, the two figures are comparable: 2,619 of 4,337 CSECTs
against MVS/CE, and whatever it is against TK5.

### Stage 4 — re-cut the reference against TK5

Depends on stage 1. If the assemblers agree, only the *right-hand* side moves and
the 5,528 decks stand.

### Stage 5 — the 459

**459 of the 515 divergent modules match neither system.** Concentrated in
`AOSU0` (94), `AOSD0` (77), `AOSA0` (75), `AOS20` (42). No baseline decision
moves them; they are the maintenance that never reached any source, and they are
the actual project.

## 7. Stages 6 to 8 — added 2026-09-16 with the reformulated goal

Stages 1–5 are about getting a *comparison* that means something. These three are
about what to do with the 68 % it leaves, and they exist because the macro finding
closed the road stages 1–5 were pointing down.

### Stage 6 — the per-module macro path *(decision 5, and its premise has changed)*

Decision 5 defers this until there is "a real macro rather than a constructed
one". **A real macro library would still be one level**, and the objects need
several — so the per-module path is not a workaround for missing material, it is
the only model that matches how the object was built.

**Measured worth today: +21.** `tools/reachable.py` takes the identical sets of
the three tree-wide reconstruction trials and unions them: our macros give 1,608,
`XCTL` 1,621, `SETFRR` 1,579, `GETMAIN`/`FREEMAIN` 1,593, **union 1,629** — and
*the union loses nothing* where two of the three lose 29 and 15 on their own. The
`wants-trial` lists from those trials are the table the mechanism needs.

### Stage 7 — disassembly, for the 772 CSECTs that have no source at all

`dasm370`, cc370 #112, being planned now in a sibling session. 800 CSECTs have an
object and no source — 598 of them distinct, 154 of them `IKJ` — and **no amount
of editing recovers a module whose source does not exist.**
`work/measurements/nosource-corpus.tsv` is stage 1's acceptance corpus.

Two rules agreed with that session and worth carrying here:
**a macro call is emitted only where `dasm370 → as370 → cmplmd370` exits 0 for
that module**, never as a mode; and **an inferred `USING` is never applied
silently**, because a wrong one produces plausible false symbolics that the round
trip cannot see — the bytes are identical either way.

### Stage 8 — a system that builds and runs

The verdict the reformulated goal actually names, and the only one that is not a
proxy. Nothing here measures it yet.

## 6. Rules this Fahrplan carries forward

- **A source snapshot without its SMP state is unpinned.** Dave's design is an
  SMP-maintained tree ("SMP als Wartungsvehikel"), so "Dave's source" names a
  library *and* a SYSMOD list. Any measurement records both.
- **`MVSTK5-REF` is read-only.** Nothing is submitted to it, nothing allocated on
  it. Assembler probes go to `MVSTK5-BLD`.
- **Purge what you submit.** Four runs left 809 jobs on LAB's spool and the fifth
  died of it.
- **A new instrument needs a case with a known answer** before its first real
  number. Every measurement in this Fahrplan's basis has one, and each one caught
  something.
