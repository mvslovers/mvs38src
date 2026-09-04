# Rebuilding MVS 3.8j from Source — Restart Workplan

As of 2026-09-04. This plan resumes Dave Kreiss' project, but changes the target
system, the tooling and the way of working.

Basis: [kreiss-project.md](kreiss-project.md)
(status of the Kreiss project) and `Build MVS From Source Instructions.pdf`.

> A German reference copy is kept outside this repository, in
> `~/repos/MVSSRC/WORK/doc/arbeitsplan.de.md`.

**Supersedes** `MVSSRC_BAK/SYSGEN-UND-SOURCE-BUILD-ARBEITSPLAN.md` (2026-09-03),
which assumed a self-performed Jay Moseley SYSGEN. That falls away: MVS/CE **is**
a finished Moseley sysgen. Its warnings about mixing the Moseley baseline with
the Kreiss build remain valid and are carried into section 5.

---

## 1. Where this is going

Two sentences:

**Recovery runs on the host; MVS is only the oracle and the runtime.** And: **in
the end an AI agent is handed a module list and works through it autonomously.**

The second sentence is the actual requirement, and it governs every design
decision in the rest of this document. Everything must be machine-readable,
deterministic, and decidable without human judgement.

Dave ran the assemble / disassemble / compare cycle on MVS — every pass an SMP
job, every iteration minutes to hours. For an agent that needs hundreds of
iterations per module, that is unaffordable. So the cycle moves to the Mac:

```
                    ┌─────────────────── HOST ───────────────────┐
                    │                                            │
  MVS/CE volumes ──►│  dasdls/dasdpdsu ──► LMOD extract          │
  (mvsres, mvs000)  │                          │                 │
                    │                          ▼                 │
                    │  file370/idrdump370 ──► CSECT + IDR +       │
                    │                         eyecatcher         │
                    │                          │                 │
                    │        ┌─────────────────┴──────────┐      │
                    │        ▼                            ▼      │
                    │  dasm370 (new)              existing        │
                    │  LMOD ──► assembler         source          │
                    │        │                    (MVSBLD, IKJ,   │
                    │        │                     stben, MVT)    │
                    │        └──────────┬─────────────────┘       │
                    │                   ▼                         │
                    │            as370 ──► OBJ                    │
                    │                   │                         │
                    │                   ▼                         │
                    │   cmplmd370: OBJ vs. DLIB OBJ (primary)     │
                    │              or vs. LMOD CSECT              │
                    │                   │                         │
                    │             ┌─────┴──────┐                  │
                    │        identical      difference            │
                    │             │              │                │
                    │             ▼              └──► agent       │
                    │        git commit               iteration   │
                    │             │                               │
                    └─────────────┼───────────────────────────────┘
                                  ▼
                        SMP PTF (xmit370 / RECV370)
                                  │
                                  ▼
                    ┌────────── MVS/CE ──────────┐
                    │  APPLY / ACCEPT            │
                    │  IPL and function test     │
                    │  (driven via mvsMF)        │
                    └────────────────────────────┘
```

The purpose is **not a single feature but a foundation**, and the goal has two
stages:

1. **A source tree at DLIB level** — the trunk, distribution-independent.
2. **Building MVS/CE from that source** in future — instead of from IBM's tapes.

Only the second stage makes the first durable. A source tree that merely sits
beside the system goes stale; one the system is actually built from cannot.

### Where this plugs into MVS/CE

MVS/CE is built by `sysgen.py`, and its step sequence names the seam itself:

```
step_01_build_starter        starter system
step_02_install_smp4         install SMP4             ← tape/zdlib1.het
step_03_build_dlibs          build the DLIBs          ← tape/zdlib1.het   ◄── HERE
step_04_system_generation    stage 1 / stage 2 from the DLIBs
step_05_usermods             Moseley's usermods
…
step_13_customize            MVP packages (UFSD, FTPD, HTTPD, MVSMF …)
```

**`step_03_build_dlibs` produces the DLIBs from IBM's distribution tape
`zdlib1.het`. Everything after it derives from those DLIBs.**

That outlines the route to the goal: if we can **produce the DLIB content from
our source**, it takes the place of step 03's output — and steps 04 onward build
a complete MVS/CE from it, with nothing else changed.

It is also the reason the DLIB level rather than the target level is the
yardstick (section 5): **it is exactly the level MVS/CE itself builds on.**

*Caveat: the step sequence is read from the function names and the `devinit`
calls in `sysgen.py`. The details of `step_03` need reading before this becomes a
build plan.*

> **A note on the history:** across the 2020–2024 mails, integrating BREXX/370
> into TSO (`IKJCT430`, `IKJEFT55`, the TMP modules) is the reason for
> everything. **It is not any more.** It remains useful as a proving ground,
> because Dave's 2024 CSECT compare gives known targets of varying difficulty
> there — but it is not a goal of this project.
> `IKJ/REXX_INTEGRATION_PLAN.md` is history now, not direction.

### Why this routes around the blocker

Dave's project has been stuck since 2022 on the SMPWRK3 directory reset (summary,
section 6). The failure hits **large** APPLY/ACCEPT runs, first in `EBB1102`.
When assembly and comparison happen locally, SMP only does what we actually need
it for: applying small, finished PTFs and managing the libraries. The mass
APPLYs that trigger the bug disappear.

That does not fix the bug — but it stops it from blocking progress.

---

## 2. The target picture: the autonomous module agent

### Why this can work at all

Autonomy usually fails because an agent cannot know for certain whether it is
done. Here it is different: **the success criterion is objective and
machine-checkable.** The assembled CSECT is byte-identical to the CSECT in the
load module, or it is not. No discretion, no interpretation, no self-deception
possible.

That is the decisive property of this project, and it has to be protected: **the
agent must never report a module as finished on its own assessment, only on the
exit code of `cmplmd370`.** Everything else in this section is mechanics; this
is the principle.

### The per-module work order

The agent gets a list. An entry is minimally a module name; it determines the
rest itself:

```yaml
# work/queue.yaml
- lmod: IKJPTGT
  csect: IKJEFT40
  lib: LPALIB
  prio: 1
- lmod: IKJPTGT
  csect: IKJEFT55
  lib: LPALIB
  prio: 1
- lmod: IKJEFT02
  csect: IKJEFT02
  lib: LPALIB
  prio: 2
  budget: 200        # optional: per-module iteration budget
```

### The state machine

```
                          ┌─────────┐
                          │   NEW   │
                          └────┬────┘
                               │ dasdpdsu + file370 + idrdump370
                               ▼
                        ┌──────────────┐
                        │  EXTRACTED   │  LMOD, CSECT, length,
                        └──────┬───────┘  eyecatcher, IDRs known
                               │ index across all source pools
                               ▼
                     ┌───────────────────┐
                     │ CANDIDATE SEARCH  │
                     └─────────┬─────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        ▼                      ▼                      ▼
  ┌───────────┐         ┌────────────┐         ┌─────────────┐
  │ case A/B  │         │  case C    │         │   case D    │
  │ source ok │         │ source far │         │  no source  │
  └─────┬─────┘         └─────┬──────┘         └──────┬──────┘
        │                     │                       │
        │                     │                       │ dasm370
        │                     │                       ▼
        │                     │              ┌─────────────────┐
        │                     │              │  RAW DISASSEMBLY│
        │                     │              └────────┬────────┘
        │                     │                       │
        └─────────┬───────────┴───────────────────────┘
                  ▼
        ┌───────────────────────┐
        │   ALIGNMENT LOOP      │◄────────────┐
        │   (section 2.3)       │             │
        └───────────┬───────────┘             │
                    │ as370 + cmplmd370       │
                    ▼                         │
             ┌─────────────┐                  │
             │ DIFF_BYTES? │                  │
             └──────┬──────┘                  │
                    │                         │
       ┌────────────┼────────────┐            │
       │ = 0        │ decreasing │ stalled    │
       ▼            └────────────┘            │
 ┌────────────┐          │                    │
 │ IDENTICAL  │          └────────────────────┘
 └─────┬──────┘                    │ budget exhausted
       │                           ▼
       │                    ┌─────────────┐
       │                    │  ESCALATED  │──► report, next module
       │                    └─────────────┘
       ▼
 ┌────────────┐   templating    ┌──────────────┐   mvsMF    ┌───────────────┐
 │ git commit │────────────────►│ PTF GENERATED│───────────►│ MVS-VERIFIED  │
 └────────────┘                 └──────────────┘            └───────────────┘
```

**Important: `ESCALATED` ends work on that module, not the run.** The agent
writes a report, sets the module aside and takes the next one. That is what "as
long as it can without my intervention" means: the run ends when the list is
empty, not at the first hard case.

### 2.1 Determining the version — and its limit

"Determine the version" concretely means pulling three facts from the load module.

| Fact | From | What it says |
|---|---|---|
| Eyecatcher | text scan in the CSECT, e.g. `IKJCT431 87.344` | which source level was assembled |
| Translator IDR | IDR record, subtype `X'04'` | with what, and when, it was assembled |
| HMASPZAP IDR | IDR record, subtype `X'01'` | whether and how it was zapped afterwards |

Important for the toolchain: **these three facts live in the target load module,
not in the DLIB object deck** — object decks carry no IDR records. So version
determination reads the load module, while the byte compare then runs against the
DLIB element. Both sides are needed, for different things.

**The trap the agent must know about:** a matching eyecatcher proves nothing.
Fixes applied through `IMASPZAP` do not change the eyecatcher — the module still
carries its old level and is nevertheless modified. Conversely a differing
eyecatcher may just be a re-assembly with no substantive change.

Therefore: **the version check is a pre-filter for candidate selection, never a
result.** It ranks candidates; the decision comes solely from the byte compare.
When the HMASPZAP IDR shows zap traces, the agent records that as an explanatory
hypothesis for later differences — that is frequently the reason for a handful of
differing bytes.

### 2.2 The four cases

| Case | Situation | Approach | Automatability |
|---|---|---|---|
| **A** | Source present, assembles byte-identical immediately | build, compare, done | **complete** — pure verification |
| **B** | Source present, small difference (tens of bytes, same length) | alignment loop | **high** — small search space |
| **C** | Source present, large difference (thousands of bytes, different length) | disassembly as reference, alignment loop against the existing source | **medium** — this is where the real work is |
| **D** | No source | `dasm370` → assemble → compare | **byte-identical: high. Readable: low.** |

On case D, an honesty Dave learned firsthand: once the round trip
`dasm370 → as370 → cmplmd370` closes, byte-identity for a module without source
is nearly trivial. But the result is assembler with absolute offsets instead of
DSECT references — exactly what Dave left open in `IECVTCCW`, `IGC121`,
`IGG019P2`, `IGG019QE`, `IGG019Q0` and `IGG019RC`. The agent delivers a
buildable, correct, but hard-to-read module.

**That is a stage, not a defect.** Byte-identity first, readability as a
separate, optional second step (decision 5 in section 3). The agent marks such
modules `IDENTICAL-RAW`.

### 2.2b Two routes to bring the source up to the object level

"Bring the source up to the object level" is the goal — but there are two
fundamentally different routes there, and the choice is made **per module**:

| | Patch forward | Regenerate |
|---|---|---|
| **Method** | Align the existing source until it produces the object | Disassemble the object; the result is the new source |
| **Cost** | high, per module | low, once the round trip closes |
| **Result** | the original, with comments, labels, DSECT references, PL/S provenance | correct but structureless: absolute offsets, no comments |
| **Cases** | A, B, C | D |

Technically, route 2 would suffice for **every** module. Once
`dasm370 → as370 → cmplmd370` closes, any module could be brought to object level
mechanically — fully automatically, with no alignment loop at all.

**It would still be wrong.** What makes source valuable is not the bytes but the
comments, the names and the structure — the part that explains *what* the code
does. A disassembled `IKJCT430` produces the right module but is no basis for
changing anything in it — and changeability is the whole point of the exercise. Dave left exactly that state behind:
`IECVTCCW`, `IGC121`, `IGG019P2`, `IGG019QE`, `IGG019Q0` and `IGG019RC` are
correct and unusable at the same time, and he flagged them explicitly as
unfinished.

**Rule:** route 2 only where route 1 cannot go — case D, and wherever the
alignment loop escalates. The verdict is then `IDENTICAL-RAW`, an intermediate
state rather than a goal.

### 2.2c When the oracle goes away

A point that reaches beyond recovery itself, and that was missing from this plan.

Byte-identity is the oracle for **recovery**. The moment we **change** a module —
say a hook in `IKJCT430`, or any other change we want to make — it is gone.
Changed source necessarily produces different object code. This is a one-way
door.

Two things follow.

**First: freeze before the first change.** The state with verdict `IDENTICAL`
gets a Git tag, and the corresponding object is stored alongside as a reference.
That is the last point at which source and system demonstrably agree. Without
that fixed point it becomes impossible to tell later whether a divergence came
from us or from a flaw in the recovery.

**Second: the oracle weakens but does not vanish.** The question shifts from *"is
it identical?"* to *"does it differ exactly as I intended?"*:

```
  Δ_source := diff(source_frozen, source_changed)
  Δ_object := cmplmd370(object_frozen, object_new)

  Check:  does Δ_source fully account for Δ_object?
          unexpected bytes outside the changed regions = defect
```

That is machine-checkable and therefore still agent-suitable — just as a *delta
comparison* rather than an identity check. A change inserting three instructions
may shift things there and only there.

**Third, and this stays with the human:** from that point on no byte comparison
says anything about correctness. Whether a change actually works is shown only by
a test on a running system. Recovery ends with a provable result; development does
not.

Dave's marking convention fits precisely here: flagging changes in column 1 as
`*DSKnnnn` or in column 65 as `DSKnnnn` makes the delta visible in the source
itself — and therefore findable by an agent that has to hold Δ_source against
Δ_object.

### 2.3 The alignment loop — the heart of it

This is where Dave's handwork becomes mechanical. He described his approach on
2024-07-03 in a clear order, and that order becomes the iteration strategy:

```
  D_ref  := dasm370(DLIB OBJ)                reference from IBM's object code
                                             (falling back to the LMOD CSECT
                                             where no DLIB element exists)
  D_src  := dasm370(as370(source))           the same from our source
  Δ      := align_diff(D_ref, D_src)         instruction-wise alignment

  for each divergence in Δ, in this priority:
    1. shift         → instructions missing or surplus
    2. displacement  → base register / DSECT reference wrong
    3. constant      → DC/DS content or length
    4. layout        → DSECT displacement, usually a GETMAINed work area

  apply patch → as370 → cmplmd370 → re-measure DIFF_BYTES
```

The comparison runs **instruction-wise, not byte-wise**. That is the difference
between "3 bytes differ at offset 0x4B2" and "an `LA R1,x` is missing here, which
shifts everything after it". Only the second is actionable for an agent. Hence
`dasm370` needs an alignment-diff mode that recognises insertions and deletions
as such rather than as byte noise.

**Convergence rule:** `DIFF_BYTES` must decrease over a sliding window of N
iterations. Stalling or increasing is a stop condition — not a reason to try
again differently. The agent then escalates with its best intermediate state.

### 2.4 Guardrails

Without these an autonomous run is dangerous:

| Rule | Reason |
|---|---|
| **One module, one file, one branch.** The agent edits only its own module's source file. | Prevents one failure from damaging other modules |
| **Every iteration is committed**, with `DIFF_BYTES` in the commit message. | Progress is visible, every state recoverable |
| **No write access to MVS/CE volumes.** Read-only extraction. | The baseline must stay immutable |
| **No network access inside the module loop.** | Reproducibility |
| **Per-module budget**: max iterations and max wall-clock, configurable. | Cost ceiling, no endless spinning |
| **Success only by exit code.** The agent may not assert `IDENTICAL`. | The central anti-hallucination rule |
| **The reference load module is read-only and verified.** Checksum in the manifest. | Without a trustworthy oracle everything else is worthless |
| **`ESCALATED` is a normal outcome**, not a failure. | Otherwise the agent optimises for avoidance instead of truth |

### 2.5 The escalation report

When a module is given up, the report is the product. It must let you (or another
agent) pick it up in five minutes:

```
module:           IKJEFT02 (in IKJEFT02, LPALIB)
situation:        case C — source from MVSBLD/, eyecatcher differs
start:            DIFF_BYTES = 10,899
best iteration:   #147, DIFF_BYTES = 2,203
last 20 iter.:    no improvement
hypothesis:       shifted DSECT references from offset 0x1A40; probably a
                  different work-area length after the GETMAIN at 0x0C18
remaining
divergences:      3 clusters, see evidence/IKJEFT02/iter147.diff
what is needed:   confirmation of the work-area layout hypothesis
```

### 2.6 What the agent can do reliably — and what it cannot

Drawing this line honestly is part of the plan.

**It can:** extract, read versions, index candidates, assemble, compare, classify
differences, perform mechanical alignments (shifts, displacements, constants),
close case D mechanically, generate PTFs from templates, submit and evaluate jobs
via mvsMF, and keep the books.

**It cannot without you:** decide whether an unexplained difference is
acceptable. Judge whether a module is functionally correct (byte-identity says
nothing about having pulled the wrong reference module). Sign off an IPL. And the
semantic reconstruction wherever Dave himself wrote `???` — if nobody knows what
the code does any more, the agent does not either.

---

## 3. Assumptions and decisions taken

Everything here is settled, not an open question. Push back where it does not fit.

| # | Decision | Reason |
|---|---|---|
| 1 | **Target system is MVS/CE**, not TK3/TK4-. The reference release is to be **v3.0.0** (2026-08-01); 2.1.4 is what we still have locally. | A finished Moseley sysgen without turnkey scaffolding. Includes SMP (`smp000.3350`), JES2, TSO and the MVP package manager. From v3.0.0 on, **FTPD, HTTPD and MVSMF are installed by default** — so the agent's main channel ships with the system (though not started; see the [runbook](runbook.md)). |
| 2 | **A new, curated Git repo** for the recovery source; MVSSRC stays an unversioned raw-material archive. | Your decision. Separates found material from working state. |
| 3 | **`dasm370` is built inside cc370**, not standalone. | Your decision; matches `cc370/docs/tool-roadmap.md`: extract `libobj370` first, then build tools as thin frontends. |
| 4 | **The acceptance criterion is CSECT byte-identity** against the MVS/CE load module, with tolerated "holes" (Dave's `DIFIN`). | Without that yardstick autonomy is impossible — see section 2. |
| 5 | **Dave's modernization (MACCVT) is not adopted up front.** Byte-identity first, readability optional and separate, in distinct commits. | Chasing both at once was Dave's Phase 2, and that is exactly where he lost comparability. For an agent it would be fatal: two moving targets, no unambiguous success criterion. |
| 6 | **The repo stays private** until the licensing question is settled. | Dave never answered your 2021-05-27 question about publishing on GitHub. |
| 7 | **The pilot is a Dave-verified CMDLIB module**, not IKJEFT. | There we know the answer. You test a toolchain against a known result, not an unknown one. |
| 8 | **`dasm370` is based on as370's opcode tables**, not the Waterloo disassembler. | Licensing problem, see section 6. |
| 9 | **Every tool gets machine-readable output (JSON) and defined exit codes.** | Not optional. An agent that has to parse prose output is unreliable. |
| 10 | **The primary oracle is the DLIB object deck, not the target load module.** | See section 5 — it answers the question of a "clean" reference system without performing a sysgen of our own. |
| 11 | **Re-baselining is complete**: all system libraries, comparison included. | Your decision. After that, Dave's status is no longer hearsay. |
| 12 | **Iteration budget staggered by case**: B ≈ 30, D ≈ 50, C ≈ 150, plus a per-module wall-clock cap. | Your decision. Easy cases run through cheaply, hard ones get a real chance. |
| 13 | **The agent may also IPL — on a clone.** The operational knowledge for that lives in the [runbook](runbook.md). | Your decision. The boundary stays: never the baseline, never your working system. |

---

## 4. What changes relative to Dave

| | Dave (2015–2024) | Us |
|---|---|---|
| Target system | TK3, later TK4- as well | **MVS/CE v3.0.0** |
| Assembling | IFOX00 on MVS, via SMP | **as370 on the host** |
| Disassembling | CBT tape 217 disassembler on MVS | **dasm370 on the host** (to be built) |
| Comparing | `COMPLMD`/`LOADLMD` on MVS | **cmplmd370 on the host** (to be built) |
| Source keeping | SMP FUNCTIONs and PTFs in MVS data sets | **Git**; SMP only at the end of the chain |
| Iteration cycle | SMP job, minutes to hours | **seconds**, locally |
| Who iterates | Dave, by hand | **the agent**, per state machine |
| SMP's role | build engine for everything | **packaging and installing finished PTFs** |
| History | PTF numbers `DSKnnnn` in the source | **Git commits**; PTF IDs only at packaging time |

What stays: the principle. The running system's object code is the truth and the
source must measure up to it. Dave's marking conventions (`???`, `!!!`), his PTF
numbering scheme and his `DIFIN` idea for tolerated differences carry over
unchanged — they proved themselves. His working order from the 2024-07-03 mail
becomes the agent's iteration strategy (section 2.3).

---

## 5. The yardstick: what exactly do we compare against?

Your question — *shouldn't we really compare against a Moseley sysgen without
PTFs and usermods?* — goes to the heart of it. The answer is yes. And there is a
route there that **requires no sysgen of our own**.

### The problem

Dave's entire "verified" status is against **TK3 object code**. MVS/CE is a
different sysgen with its own usermod baseline (Moseley's ~69 usermods) and its
own I/O generation. If recovered source is compared against MVS/CE's **target
load modules**, every difference has at least four possible explanations:

1. Our source is wrong.
2. A usermod changed the module.
3. Sysgen parameters went into it.
4. The linkage editor reordered, relocated or packed things differently.

Four explanations for one finding is a poor starting position for an autonomous
agent. It cannot decide whether to keep working or give up.

### The answer: the DLIB object deck as the primary oracle

An MVS system has two sets of libraries. The **target libraries**
(`SYS1.LINKLIB`, `SYS1.LPALIB`, …) hold the linked, runnable load modules. The
**distribution libraries** (the `AOS*` libraries) hold the **object decks as IBM
shipped them** — before any sysgen, before any link-edit.

That is exactly the "clean reference level" you asked about — and in all
likelihood it is already present in MVS/CE. No sysgen needed.

> ⚠️ **To be confirmed in M0.** Moseley's sysgen process places the DLIBs on
> `SMP000`, and `smp000.3350` ships with MVS/CE — but this has not been verified.
> A `dasdls` over the volume settles it in a minute. If MVS/CE omitted the DLIBs,
> the strategy is not lost: the distribution tapes (`zdlib1.het`) are publicly
> available and can be loaded separately.

It is the better yardstick for three reasons:

1. **No usermod layer** — provided the usermods were only APPLYed and not
   ACCEPTed. SMP APPLY updates the target libraries, ACCEPT updates the DLIBs.
   Which sysmods were ACCEPTed is recorded in the SMP CDS on `smp000`, so this is
   **something to look up rather than guess**.
2. **No linkage editor in between.** An object-deck comparison knows nothing of
   RLD relocation, ESDID renumbering or CSECT packing inside a multi-CSECT load
   module. The cc370 roadmap names exactly those three as the reason a *tolerant*
   comparison is needed. At OBJ level the problem disappears instead of being
   tolerated.
3. **Like against like.** `as370` produces an object deck. A DLIB element *is* an
   object deck. Verification does not need `ld370` at all — the loop gets shorter
   and loses a source of error.

### The three-layer model

| Layer | What | Role |
|---|---|---|
| **DLIB object deck** (`AOS*`) | IBM's shipped level | **Primary oracle.** Compare the `as370` OBJ directly against it |
| **Target load module** | What the system actually runs | **Secondary oracle.** For modules with no DLIB counterpart, and as a cross-check |
| **The delta between them** | Sysgen configuration plus usermods | **Measured, not guessed.** Yields the usermod layer as a by-product |

The four explanations above become two separate, individually answerable
questions: *does our source reproduce IBM's object code?* (against the DLIB) and
*what did this system make of it?* (delta DLIB → target).

**Important context:** the source we hold lags not only the target load module
but already the **DLIB object deck** — the source IBM shipped was never in sync
with the object code it shipped (see the [summary](kreiss-project.md),
section 2, "What exactly is Dave's baseline?"). Closing precisely that gap is
what Dave's `DSKnnnn` PTFs do — which makes them, for us, not incidental but
usable source-level maintenance in IEBUPDTE form.

This is not speculation: Dave built exactly that separation into `LMDRPT38`.
Appendix C of his documentation carries **separate statistics for distribution
libraries and target libraries** — 5,126 LMODs / 5,454 CSECTs on the DLIB side
against 2,365 / 5,453 on the target side.

### The hypothesis: the DLIBs are the same across distributions

Every turnkey system — TK3, TK4-, TK5, MVS/CE — descends from the same IBM
distribution tapes. What separates them arises **after** the DLIBs:

| Difference | Affects |
|---|---|
| Sysgen parameters (stage I) | target libraries |
| Usermods via APPLY | target libraries |
| Add-on software, packages | libraries of their own |
| Usermods via **ACCEPT** | **the DLIBs too** ← the one exception |

Hence the hypothesis: **the `AOS*` libraries should be identical across all
distributions**, save for ACCEPTed sysmods — and each system's SMP CDS says which
those are.

**This is cheap to test and, if confirmed, changes the statics of the whole
undertaking.** Both sides are available locally: MVS/CE has `smp000.3350`, and
TK5 carries a dedicated DLIB volume in `tk5dlb.392`.

### Why it matters this much

If the hypothesis holds, the output of this project is **not** "source for our
MVS/CE" but **source for MVS 3.8j** — distribution-independent. Concretely:

1. **The reference-release question largely dissolves.** MVS/CE 2.1.4, 3.0.0 or
   3.0.1: the DLIBs do not change between them. We stop chasing a moving target.
2. **Dave's results do carry after all.** My earlier concern was that his
   "verified against TK3" is worthless for MVS/CE. At **target** level that is
   true. At **DLIB** level it is not — and he measured there too; Appendix C
   carries a separate DLIB statistic.
3. **The target libraries become secondary.** They are the product of sysgen and
   usermods, i.e. a derivation. We do not have to reproduce them.
4. **The artifact becomes useful to others.** A source tree at DLIB level serves
   any MVS 3.8j system, not just ours. That incidentally raises the stakes on the
   open licensing question.

### The goal, stated precisely

> **A source tree that reproduces the DLIB level of MVS 3.8j.**
> That is the trunk. Everything beyond — a BREXX integration, 3390 extensions,
> whatever comes — is development branching off from there.

This also locates the transition from section 2.2c exactly: the frozen
`IDENTICAL` state at DLIB level is the branch point. Recovery with a provable
result before it, our own development after it.

### If the hypothesis does not hold

The measurement is still useful, because a difference is not diffuse but
attributable: it comes from ACCEPTed sysmods, and both systems' CDS says which.
We would get a list of affected elements instead of an uncertainty — and the
hypothesis would still hold for everything else.

### Limits to be aware of

- **Sysgen-generated modules** — nucleus tables, configuration-dependent modules
  — have no meaningful DLIB counterpart. There the target module is the only
  oracle, and the sysgen parameters must be in the baseline.
- **ACCEPTed sysmods** are in the DLIBs too. The CDS says which elements are
  affected, so the information is not lost — it just has to be evaluated.
- **The old warning still applies**, now at a different point: when merging the
  Moseley baseline with recovered source, every third-party usermod has to be
  checked for whether it overwrites a module we built. That is where silent
  regressions come from.

### Reusing Dave's work — what does it rest on?

Before anything gets redone, it is worth establishing what already exists.

**His basis was:**

| | What |
|---|---|
| Source input | The MVS source IBM shipped, from the `SRC*` volumes (TK3; on TK4- from `source.zip`) |
| Object oracle | The DLIBs **and** target libraries of the running TK3 system |

**And his result is in our hands** — `MVSBLD/` in this repository is not his
input material but his **working state**, with his markings in it. Counted:

| Series | Area | Modules |
|---|---|---:|
| `DSK0` | base: macros, printability, assemblability | 235 |
| `DSK1` | NUCLEUS to TK3 maintenance level | 158 |
| `DSK2` | SVCLIB | 32 |
| `DSK3` | JES2 and SMP | 36 |
| `DSK6` | the SMP 4.48 → 4.49 extension itself | 1 |
| `DSK9` | phase 2, macro modernization | 12 |
| `DSKC` | CMDLIB | 203 |
| `DSKK` | LINKLIB (incomplete) | 61 |
| `DSKL` | LPALIB (incomplete) | 55 |
| | **modules touched in total** | **747** |
| | of those carrying `???` (purpose unclear) | 50 |
| | of those carrying `!!!` (compare workaround) | 16 |

So of roughly 5,500 modules Dave touched **747** — about 13 %. The rest is the
shipped source, unchanged.

### Why his work transfers

The decisive point: **his deltas are text edits, not binary patches.** The
`DSKnnnn` PTFs are IEBUPDTE updates against source. What matters for reuse is
therefore not whether TK3 and MVS/CE share an object level, but only whether we
start from the same source text.

And even that need not be settled up front, because `MVSBLD/*.ASM` is already
**the result**, not the delta. We can feed it straight into the toolchain and
measure.

> **Hence the first and most important measurement campaign:**
> **Dave's 747 touched modules against the MVS/CE DLIBs.**
>
> The result answers directly how much of his work carries — and is at the same
> time the hard test of the whole toolchain, on material whose expected answer we
> roughly know.

Three outcomes are conceivable, and all three are useful:

| Outcome | Meaning |
|---|---|
| mostly `IDENTICAL` | TK3 and MVS/CE DLIB levels agree. His work carries fully and we build on it |
| a systematic residual difference | The two DLIB levels differ in a defined way. Determine that difference once and it holds for all modules |
| scattered, unsystematic | The levels do not match; then his deltas from `SMP.LIB*` must be re-applied to our source |

Even the worst case does not mean redoing his work: the PTFs themselves are on
the `BLDMVS.AWS` tape in this repository as `MVSSRC.BLD.SMP.LIB` through `.LIB5`
— in IEBUPDTE form and therefore applicable outside SMP as well.

**The 66 marked modules deserve special handling.** The 50 carrying `???` are
places where Dave himself could not reconstruct what the code does; the 16 with
`!!!` are workarounds that make the object compare succeed. Neither is somewhere
an agent may tidy up on its own initiative.

### The verdicts

| Verdict | Meaning | Consequence |
|---|---|---|
| `IDENTICAL` | OBJ is byte-identical to the DLIB element | done, freeze in Git |
| `IDENTICAL-RAW` | identical, but from disassembly, with absolute offsets | buildable and correct, not yet readable |
| `DIFF-USERMOD` | matches the DLIB but not the target — the delta is the usermod/sysgen layer | demonstrated, not suspected; resolve only when it blocks |
| `DIFF-UNKNOWN` | does not match the DLIB either | the agent's work queue |
| `NO-SOURCE` | no candidate exists | case D |

The usermod question from the original version of this plan largely settles
itself: `DIFF-USERMOD` is no longer a suspicion but a measurement.

## 6. Tools

### Available

| Tool | Location | Role |
|---|---|---|
| **as370** | `~/repos/mvs/cc370`, installed under `~/.local/bin` | **The decisive component.** An Assembler-XF clone, per its README byte-identical to IFOX00 across a 950-module corpus. It is what makes the local cycle possible. |
| **ld370** | ditto | Linkage-editor replacement, `-xmit`/`-iebcopy` as the transport path. |
| **file370** | ditto | Inspector for OBJ, LMOD, IEBCOPY unload, XMIT. Already knows the ESD dictionary. |
| **xmit370** | ditto | Packs host directories as TSO TRANSMIT. |
| **mvsMF** | `~/repos/mvs/mvsmf` | z/OSMF REST API on MVS 3.8j. **The interface through which the agent drives MVS:** submit jobs, poll status, fetch spool, read/write data sets. |
| **Hercules DASD utilities** | sources in `~/repos/hyperion` (`dasdls.c`, `dasdpdsu.c`, `dasdseq.c`, `dasdcat.c`), not yet built | **The second key:** read load modules straight off the MVS/CE volumes without starting MVS. |
| **cc370 format docs** | `~/repos/mvs/cc370/docs/` | `load-module-format.md` describes the IDR records down to the byte — the source for version determination. |

### To be built

| Tool | Purpose | Agent requirement |
|---|---|---|
| **dasm370** | LMOD CSECT → re-assemblable source | Plus an **alignment-diff mode** (section 2.3): recognise insertions/deletions as such, not as byte noise |
| **cmplmd370** | CSECT compare with tolerated differences | JSON output with `diff_bytes`, clusters and offsets. **Exit code 0 only on identity** — this is the agent's success signal |
| **idrdump370** | Extract IDR records and eyecatchers | JSON. Can become a `file370` mode |
| **libobj370** | Shared format library | **Phase 0 of the cc370 roadmap.** The three above should be thin frontends, not a fourth copy of the format logic |
| **`mvsrec`** (working title) | The orchestrator: queue, state machine, budget, bookkeeping, escalation reports | This is the tool that drives the agent, not the other way round |

### Licensing note on dasm370

`~/repos/Waterloo Disasm/dasm370.c` carries in its header:

> *"Copyright (C) 1985, 1991 by the University of Waterloo, Computer Systems
> Group. All rights reserved. No part of this software may be reproduced in any
> form or by any means […] except with the written permission of the copyright
> owner."*

Unusable as the basis for an mvslovers tool intended for publication. The cc370
roadmap itself proposes the clean route: **invert as370's opcode tables.** Then
the code is ours, and it is consistent with the assembler by construction —
exactly the property the round trip depends on. The Waterloo code serves as a
reference to consult, not as a code base.

### The risk in as370

as370's byte-identity is demonstrated over C-ecosystem code (libc370, rexx370,
HTTPD, UFSD). **MVS system source is a different animal:** PL/S-generated
assembler, heavy system macros from `SYS1.MACLIB` and `AMODGEN`, sysgen macros. A
review of the implemented directives shows:

- **Present:** `DSECT`, `ORG`, `CNOP`, `PUSH`/`POP`, `PRINT`, `TITLE`, `EJECT`,
  `SPACE`, `EXTRN`/`WXTRN`, `CXD`, `COM`, `LTORG`, literals, a
  macro/conditional-assembly preprocessor with `AIF`/`AGO`/`SETx`/attributes.
- **Not found:** `START`, `ICTL`, `ISEQ`, `OPSYN`, `PUNCH`, `REPRO`, `DXD`.

`PUNCH` and `REPRO` matter because sysgen macros use them to emit cards. `START`
appears in old source more often than `CSECT`.

**Consequence:** the as370 gap analysis against real system source is an early
milestone of its own (M2) and a **feasibility gate**. If it comes out badly, the
effort belongs in as370 first.

---

## 7. The tables — which are also the agent's work queue

The two tables you want are not just reporting: **table B is the queue.** Both
are generated, not hand-maintained. The main output of M1.

### Shared schema

| Column | Content | Source |
|---|---|---|
| `LMOD` | load module name | `dasdls` |
| `CSECT` | CSECT name | `file370` ESD |
| `LIB` | target library | data set of the extract |
| `LEN` | CSECT length | ESD |
| `EYECATCHER` | e.g. `IKJCT431 87.344` | text scan in the CSECT |
| `IDR_XLATOR` | translator ID and date | translator IDR (`load-module-format.md` §10.3) |
| `IDR_LKED` | link-edit date | linkage-editor IDR (§10.2) |
| `IDR_ZAP` | zap history | HMASPZAP IDR (§10.1) — **the trail for PTFs, usermods and sysmods** |
| `SYSMOD` | associated SMP sysmod | SMP CDS on `smp000` |
| `SRC_CANDIDATE` | where found in the raw material | index over `MVSBLD/`, `IKJ/`, `www.stben.net/`, `mvssrc/mainframe.eu/`, `NEW.ASM`, `MVT.ASM` |
| `CASE` | `A`/`B`/`C`/`D` | derived from the first compare |
| `VERDICT` | `IDENTICAL` / `IDENTICAL-RAW` / `DIFF-USERMOD` / `DIFF-UNKNOWN` / `NO-SOURCE` / `ESCALATED` | `cmplmd370` |
| `DIFF_DLIB` | bytes differing from the DLIB object deck — **the primary measure** | `cmplmd370` |
| `DIFF_TGT` | bytes differing from the target load module | `cmplmd370` |
| `ACCEPTED` | whether a sysmod was ACCEPTed into the DLIB | SMP CDS |
| `ITER` | iterations to reach this state | orchestrator |
| `ASOF` | date of the last run | orchestrator |

On the version question: the version lives in three places, and all three belong
in the table because they say different things — details and the eyecatcher trap
in section 2.1. The **SMP CDS** on `smp000.3350` supplies the other direction:
which sysmod touched which element. Both sides together give a trustworthy
picture.

### Table A — modules with usable source

Verdict `IDENTICAL`, `IDENTICAL-RAW` or `DIFF-USERMOD`. The progress indicator.

**Expected starting position** from Dave's statements — a hypothesis M1 tests:

| Area | Dave's TK3 state | Expectation against MVS/CE |
|---|---|---|
| `SYS1.NUCLEUS` | identical, IPL-tested | partly `DIFF-USERMOD` — different I/O gen, Moseley usermods |
| `SYS1.SVCLIB` | identical | mostly `IDENTICAL` expected |
| JES2 | identical | `DIFF-USERMOD` |
| SMP | identical | `DIFF-USERMOD` |
| `SYS1.CMDLIB` | identical | good chance of broad `IDENTICAL` — **hence the pilot** |
| the rest | incomplete | table B |

### Table B — missing modules, sorted by effort

Verdict `DIFF-UNKNOWN`, `NO-SOURCE` or `ESCALATED`. Additionally:

| Column | Content |
|---|---|
| `REASON` | `no source` / `source ≠ object` / `disassembled only` / `dictionary` |
| `EFFORT` | `S`/`M`/`L`, estimated from `DIFF_BYTES` and CSECT length |
| `PRIO` | follows from the goal — TSO/IKJ first |
| `BUDGET` | iteration budget for the agent |

Dave's IKJEFT table already implies the priority for our actual goal: `IKJEFT40`,
`52`, `53`, `54`, `56` differ by 2 to 10 bytes at identical length — case B,
ideal first agent tasks. `IKJEFT01`, `02`, `03`, `04`, `05` differ by thousands —
case C, the heavy ones.

### Generation pipeline

```
MVS/CE volumes ──dasdls──► inventory of target libs AND DLIBs (CSV)
                              │
                 dasdpdsu ────┴──► LMOD and OBJ files in a host directory
                                      │
              file370/idrdump370 ─────┴──► CSECT + IDR + eyecatcher (CSV)
                                             │
raw-material folders ──index──► source candidates (CSV)
                                             │
                                    join + as370 + cmplmd370
                                             │
                                             ▼
                                 tables A and B (Markdown + CSV)
                                             │
                                             ▼
                                    work/queue.yaml for the agent
```

The Markdown tables are generated artifacts; the CSVs are the truth.

### Comparing on MVS — when it really must happen

The host compare is the rule. For doubtful cases Dave's toolchain remains
available as a second opinion: `COMPLMD`/`LOADLMD` for CSECT compare,
`LMDXRF38`/`LMDRPT38` for library-wide reconciliation with CSV output, plus his
ready-made jobs `ZCMPNUC*`, `ZCMPSVC`, `ZCMPJES`, `ZCMPSMP` — all from
`MVSSRC.BLD.UTILITY.ASM`.

The agent submits these through **mvsMF** and fetches the output back. On return
codes: MVS/CE already ships the JES2 usermod `SYZJ201`, so the REST API does
return a `retcode`. The condition is a `NOTIFY=` on the job card — `HASPSSSM`
writes `JCTCNVRC` only for jobs that requested a notify. The agent need not
handle that: mvsMF adds `NOTIFY=$MVSMF` automatically to any job card that
carries none. M0 only has to confirm that `SYZJ201` is actually applied in the
baseline.

---

## 8. Repo layout

A new, curated repo. Proposed name `mvs38-source-recovery`:

```
mvs38-source-recovery/
├── README.md
├── CLAUDE.md                 # rules for the agent
├── AGENT.md                  # the per-module work contract (section 2)
├── .gitattributes            # NO text normalization, see below
├── baseline/
│   ├── mvsce-v3.0.0.md       # usermods, MVP packages, sysgen parameters
│   ├── lmod-inventory.csv    # generated
│   ├── idr-inventory.csv     # generated
│   └── checksums.txt         # checksums of the reference load modules
├── src/
│   ├── ikj/                  # by target library and prefix
│   ├── cmdlib/
│   └── nucleus/
├── tables/
│   ├── ported.md             # table A (generated)
│   ├── missing.md            # table B (generated)
│   └── *.csv
├── work/
│   ├── queue.yaml            # the module list for the agent
│   └── state/                # per-module state, resumable
├── evidence/                 # per module: diffs, iteration history, reports
├── tools/                    # pipeline and orchestrator
├── ptf/                      # SMP packaging: ++PTF/++USERMOD, JCLIN
└── doc/
```

`work/state/` matters: the agent must be able to **resume** an interrupted run
without starting over. `evidence/` is the chain of evidence — without it the
results cannot be verified.

**`.gitattributes` is critical here, not cosmetic:**

```
* -text
*.asm binary
*.ASM binary
```

The source has 80-character records with sequence numbers in columns 73–80 and
CRLF line endings. Those exact bytes are what is being compared. Git must not
normalize anything about them — otherwise we end up comparing artifacts of our
own toolchain. That diffs are noisy in columns 73–80 is a display problem, solved
in the diff tool, not in storage.

**Stays out:** `BLDMVS.AWS` (190 MB), the DASD volumes, the web mirrors
(`www.stben.net` 856 MB, `mvssrc/mainframe.eu` 125 MB). They remain in MVSSRC. If
versioned after all: Git LFS.

**Private** until the licensing question is settled.

---

## 9. Milestones

### M0 — build the workbench

- [ ] Build the Hercules DASD utilities from `~/repos/hyperion`: `dasdls`,
      `dasdpdsu`, `dasdseq`, `dasdcat`. Check they read the MVS/CE volume formats
      (3350 mixed with 3380/3390).
- [ ] Unpack MVS/CE v3.0.0, IPL it, smoke-test JES2/TSO/SMP. Then take an
      **immutable baseline snapshot** of the volumes, with checksums.
- [ ] Inventory the MVS/CE baseline: usermods, MVP packages, sysgen parameters,
      I/O gen → `baseline/mvsce-v3.0.0.md`.
- [ ] **Confirm the distribution libraries (`AOS*`) are present on
      `smp000.3350`** — the yardstick from section 5 depends on it. If not: load
      `zdlib1.het` separately.
- [ ] Obtain the macro libraries: extract `SYS1.MACLIB`, `SYS1.AMODGEN`,
      `SYS1.APVTMACS`; reconcile against `~/repos/mvs/sys1.maclib`.
- [ ] Get mvsMF running against MVS/CE; confirm `SYZJ201` is applied in the
      baseline.
- [ ] Create the new repo, set `.gitattributes`, build the raw-material index.
- [ ] Enable the Hercules web console as a fallback (`conf/local/custom.cnf`) and
      raise the [runbook](runbook.md) from 📄 to ✅ on the first pass.

**Acceptance:** a load module can be pulled from `mvsres.3350` without a running
MVS, and `file370 -v` shows its ESD dictionary.

### M1 — inventory and tables

- [ ] Inventory across all system libraries — **target libraries and
      distribution libraries (`AOS*`)**.
- [ ] CSECT, IDR and eyecatcher extraction.
- [ ] Evaluate the SMP CDS: sysmod → element, and **which sysmods were ACCEPTed**
      (this decides how clean the DLIBs are as an oracle).
- [ ] Index all local source pools, keyed on CSECT name plus eyecatcher.
- [ ] Join; first version of tables A and B.

**Acceptance:** both tables are generated and reproducible. For every CSECT in
MVS/CE it is known whether a source candidate exists.

### M2 — as370 gap analysis (feasibility gate)

- [ ] Run as370 over a representative cross-section of real system source:
      `MVSBLD/*.ASM` and `IKJ/*.asm`, with the real MACLIBs.
- [ ] Categorize failures: missing directive, macro problem, expression syntax,
      addressing, other.
- [ ] Prioritized gap list; close the "frequent and cheap" ones in as370 straight
      away.
- [ ] Cross-check: assemble one module with existing source locally and verify
      against IFOX00 on MVS.

**Acceptance:** a defensible figure for what fraction of system source assembles
locally. **This is a gate** — if the rate is poor, as370 takes priority over
everything else.

### M3 — compare pipeline, pilot on CMDLIB

- [ ] Build `cmplmd370`: `DIFIN`/`DIFOUT` semantics, `CLEARRLD`, JSON output,
      exit code 0 only on identity.
- [ ] Pilot: run one Dave-verified CMDLIB module through the whole chain —
      `as370` OBJ **against the DLIB element**, with no `ld370` in between.
- [ ] Cross-check against the target load module; the delta is the
      usermod/sysgen layer.
- [ ] Fill the verdict columns automatically.
- [ ] Then **completely** across all libraries (decision 11).

**Acceptance:** for at least one module the path from Git source to verdict
`IDENTICAL` is reproducible — entirely on the host.

### M4 — dasm370 and the round trip

- [ ] Extract `libobj370` from as370/ld370/file370 (cc370 roadmap phase 0).
      Validation: the existing tools still produce byte-identical output.
- [ ] `dasm370` v1: LMOD CSECT → assembler that as370 consumes directly.
- [ ] **Round-trip test** `dasm370 → as370 → cmplmd370` against the original must
      yield `IDENTICAL`. That is the disassembler's self-test and the
      precondition for case D.
- [ ] Alignment-diff mode (section 2.3) — without it the agent cannot classify
      differences.

**Acceptance:** the round trip closes for a selection of modules of varying size.

### M5 — the orchestrator

- [ ] `mvsrec`: read the queue, state machine, budget, `work/state/`, resume,
      `evidence/`, escalation reports.
- [ ] Enforce the guardrails from section 2.4 technically, not just in prose.
- [ ] Write `AGENT.md`: the work contract an agent reads at the start.
- [ ] Dry run over case-A modules: there the agent must reach a verdict **without
      any iteration**.
- [ ] First real autonomous run over a small case-B list.

**Acceptance:** a list of five case-B modules is worked through without
intervention; each ends in `IDENTICAL` or a usable escalation report.

### M6 — establish breadth

From here it is no longer a targeted raid but a systematic sweep. The aim is
coverage: as many modules as possible with verdict `IDENTICAL`, so the
foundation carries.

- [ ] **Work outward from Dave's verified areas.** At DLIB level, NUCLEUS,
      SVCLIB, JES2, SMP and CMDLIB are the most promising candidates — his work
      already exists there as source-level maintenance.
- [ ] **Then by effort, not by topic.** Table B is sorted by `DIFF_DLIB`; the
      agent works from the bottom up. Small same-length differences first, the
      heavy ones last.
- [ ] **Case D in the background.** Modules with no source can be brought to
      `IDENTICAL-RAW` mechanically once the round trip closes. That can run
      alongside and costs little attention.
- [ ] **Still useful as a proving ground:** the `IKJEFT` group. Dave's 2024 CSECT
      compare lists modules there differing by 2 to 10 bytes at identical length
      (`IKJEFT40`, `52`, `53`, `54`, `56`) next to ones differing by several
      thousand (`IKJEFT01`, `02`). A ready-made scale from easy to hard, against
      known numbers — good for calibrating the agent.
- [ ] **Freeze before the first change of our own:** Git tag on the `IDENTICAL`
      state, with the corresponding objects stored as a reference
      (section 2.2c). That is the branch point between recovery and development.

**Acceptance:** defensible coverage at DLIB level, a frozen reference point — and
with it a foundation that makes changes to the operating system possible in the
first place.

### M7 — back to MVS: the SMP part

- [ ] Generate SMP-ready `++PTF`/`++USERMOD` from the Git source, including
      JCLIN — templatable and therefore agent-suitable.
- [ ] Transport via `xmit370` and `RECV370`.
- [ ] APPLY/ACCEPT on an MVS/CE **clone**, driven through mvsMF.
- [ ] IPL and function test **autonomously on the clone** (decision 13), per the
      procedures in the [runbook](runbook.md). A wall-clock cap is mandatory: a
      hung IPL manifests as an *absence* of messages, not as an error.
      **What stays with you** is promotion to anything other than the clone.
- [ ] Watch whether the SMPWRK3 failure occurs at all with these small APPLYs. If
      it does: follow Dave's open lead — read the SMP source, establish whether
      `STOW` under MVS 3.8 can clear a directory.

**Acceptance:** a locally produced change is installed through SMP on MVS/CE and
runs.

### M8 — build MVS/CE from source

The second stage of the goal from section 1. No longer "apply PTFs to an existing
system" but "produce the system from our source".

- [ ] Read `step_03_build_dlibs` in `sysgen.py` in detail: what exactly does it
      produce, in what form, and what do the later steps depend on?
- [ ] **Produce DLIB content from our source tree** — object decks in the shape
      step 04 expects.
- [ ] Run a sysgen in which step 03 is replaced by our output.
- [ ] IPL the resulting system and compare it against a regular MVS/CE.
- [ ] Name the difference: what matches, what does not, and why.

**Acceptance:** an IPLable MVS/CE whose DLIBs came from our source.

*This is the actual end state.* Everything before it is a precondition — and
everything after it is development of the operating system, no longer recovery.

---

## 10. Risks

| Risk | Impact | Mitigation |
|---|---|---|
| **as370 cannot digest system source** | The whole host-first approach collapses | M2 is early and designed as a gate |
| **MVS/CE differs from TK3 more than expected** | Dave's "verified" carries little | M1 measures early; `DIFF-USERMOD` captures the explainable part |
| **The disassembler round trip does not close** | Case D impossible, dasm370 untrustworthy | The round-trip test is M4's acceptance criterion |
| **The agent reports success that is not one** | Silent errors, worthless results | Success only by exit code; checksums on the reference modules; `evidence/` per iteration |
| **The agent spins in circles** | Cost without progress | Convergence rule plus a hard per-module budget |
| **The agent optimises for the compare rather than correctness** | Byte-identical but meaningless source | Only case D is exposed to this; there `IDENTICAL-RAW` is its own verdict and not a final state |
| **Wrong reference module pulled** | Everything downstream is worthless | Baseline checksums; LMOD provenance in the manifest |
| **Licensing question stays open** | No publication possible | Repo private; ask Dave again independently |
| **The SMPWRK3 bug also hits small APPLYs** | M7 blocked | Only relevant in M7; until then the value is created host-side |
| **Dave's 3390 mods corrupt free space** | volume unusable | His phases 4/5 contain them. His build runs on `mvsce-exp` only, never on a system whose volumes matter (see the runbook) |
| **Scope** | 5,500 modules, project peters out | Not all 5,500 are needed — nobody wants MSS, VPSS or probably TCAM. The priority is coverage where the system actually runs, sorted by effort rather than by topic |

---

## 11. Next steps

Concretely, in this order:

1. Build the Hercules DASD utilities and try them on an MVS/CE volume.
2. Unpack MVS/CE, IPL it, take a baseline snapshot with checksums.
3. Create the new repo, set `.gitattributes`.
4. **Run one single load module all the way through** — from `dasdpdsu` to
   `file370 -v`.
5. Only then start M1.

Step 4 matters more than it looks: it answers early whether host-side extraction
holds up. If it does, the rest is legwork. If it does not, we replan before
effort has gone in.

The same logic applies to autonomy at a larger scale: **M5 is the point where it
is decided whether the target picture works.** Everything before is preparation,
everything after is scaling.

---

## 12. Open questions for you

The questions on baselining depth, usermod handling, iteration budget and M7
autonomy are answered and recorded as decisions 10 to 13 in section 3. What
remains:

1. **MVP packages:** MVS/CE ships a package manager with many extra programs.
   They do not change `SYS1` modules, but the baseline should record what is
   installed. Is a list enough, or should their contents be inventoried too?
2. **Wall-clock caps** for IPL and for jobs — probably falls out of the first
   run, and then belongs in the [runbook](runbook.md).
3. **What happens to `IDENTICAL-RAW`?** Case-D modules are buildable and correct
   but carry absolute offsets instead of DSECT references. Does that stand, or is
   making them readable (Dave's MACCVT approach) a goal of its own later?
