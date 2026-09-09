# Why IFOX00 was not content — and why that limits the reference

2026-09-07. The tree-wide comparison ([`ifox-tree.md`](ifox-tree.md)) treats the
5,528 IFOX00 decks as the reference against which `as370` is measured. That
argument holds only where IFOX00 assembled cleanly. **It did not, for 933 of
them.**

This document is the work list for that. It is written to be picked up on its
own.

## What is at stake

A deck out of an assembly Assembler XF flagged at `rc 8` or worse is not
authoritative. If the reason is on our side — a macro missing, or at the wrong
maintenance level — then supplying it gives a *different and better* deck, and
every `as370` verdict against the old one has to be taken again.

| | Modules |
|---|---:|
| IFOX00 `rc 0` — the reference is sound | 4,571 |
| IFOX00 `rc 4` | 24 |
| **IFOX00 `rc ≥ 8` — the reference is doubtful** | **933** |

How far the doubt reaches into what has been claimed:

| Claim | Resting on a flagged assembly |
|---|---:|
| 3,559 modules where `as370` == IFOX00 | 498 |
| 2,021 modules owned by the assembler | 476 |
| **879 recovered — all three decks agree** | **0** |

*Against `as370` at cc370 `879e86a` — distance **126** from `main`. The 933 does
not move with an `as370` change: it is a property of the IFOX00 side, and it is
the one figure on this page that is still current. The three rows above it are
not: on `7a0cd90`, distance 0 at writing, `as370` == IFOX00 on 5,379, the
assembler owns 128, and 1,211 modules are byte-identical to IBM's object.*

The last row is the important one: **the recovery figure is clean.** A module
whose `as370` deck matches both IFOX00 *and* IBM's shipped object cannot be
resting on a bad reference — IBM's object settles it independently.

And it is not mostly foreign code: of the 933, **891 are MVS proper**, 36 are
EREP (`IFC*`) and 6 are CICS (`DFH*`, `BNG*`).

## The loop this opens

1. A module IFOX00 flags is investigated here — is the cause ours or the source's?
2. Where it is ours (a macro), the macro is supplied and the module re-assembled
   on MVS. Its reference deck is replaced.
3. The new deck is the better one — and `as370` is compared against it again.
4. **Differences that were hidden behind the flawed reference now surface**, and
   they are new cases for cc370.

So this work does not compete with the ticket list; it feeds it.

## What IFOX00 objected to

[`ifox-objections/by-code.tsv`](../work/measurements/ifox-run/ifox-objections/by-code.tsv),
and one module list per code beside it.

| Code | Modules | Message | What it points at |
|---|---:|---|---|
| `IFO178` | 456 | SYNTAX ERROR NEAR OPERAND COLUMN n | pairs with `IFO117` |
| `IFO117` | 455 | FIRST EXPRESSION IN SUBSTRING NOTATION EXCEEDS THE LENGTH OF THE STRING | the empty `&SYSPARM` class — **`as370` reports the same thing on 460 modules**, so here the two assemblers agree and the source is the question |
| `IFO188` | 304 | *symbol* IS AN UNDEFINED SYMBOL | |
| `IFO092` | 225 | KEYWORD PARAMETER *name* UNDEFINED IN MACRO DEFINITION | **macro maintenance level** — see `MODID` below |
| `IFO078` | 197 | UNDEFINED OP CODE | **a macro we do not have** |
| `IFO217` | 75 | RELOCATABILITY ERROR | |
| `IFO226` | 47 | BASE REGISTER OF MACHINE INSTRUCTION NOT ABSOLUTE | |
| `IFO197` | 47 | `*** MNOTE ***` | the macro itself is complaining |
| `IFO236` | 33 | ILLEGAL CHARACTER IN EXPRESSION | |
| `IFO209` | 31 | ADDRESSABILITY ERROR — BASE AND DISPLACEMENT CANNOT BE RESOLVED | |
| `IFO108` | 20 | CHARACTER STRING USED AS AN ARITHMETIC TERM CONTAINS NON-DECIMAL CHARACTERS | |
| `IFO185` | 19 | BLANK EXPECTED AS A DELIMITER | |
| `IFO225` | 14 | RELOCATABLE LENGTH FIELD IN MACHINE INSTRUCTION | |

26 codes in all.

## The two classes that are ours to fix

### Macros we do not have — `IFO078`, 197 modules

`as370` names what it could not resolve, and IFOX00 agrees by flagging the same
statement. **51 distinct operations**, of which 25 exist in none of our eight
macro libraries:
[`undefined-ops.tsv`](../work/measurements/ifox-run/ifox-objections/undefined-ops.tsv)
gives each one with its module list.

| Operation | Modules | Family |
|---|---:|---|
| `IHANVT` | 33 | MVS mapping — **already listed as missing in `TODO.md`, now with its reach** |
| `UCBDADVC` | 32 | MVS mapping — the same |
| `IECDCST` | 11 | MVS mapping — the same |
| `ILRAIA` | 30 | auxiliary storage manager |
| `ISDAFSPC` | 27 | |
| `IEAPPNIP` | 12 | NIP |
| `IHASPCT`, `IOSTRAP`, `IOSSIO`, `IOSSCP`, `IOSCPA` | 6–8 each | IOS |
| `DSGEN`, `LINE`, `ROUTINE`, `BIN`, `HEX`, `CONVT`, `PROLOG`, `ENTRIES`, `ETEPILOG`, `LSTART`, `SUMMARY`, `SPECIAL`, `FREETAB` | up to 33 | **EREP internals** — one coherent family, `IFCE*`/`IFCS*` |
| `DFHPC`, `DFHFC`, `DFHTC`, `DFHSC`, `DFHCOVER` | 5–6 | **CICS** — not MVS, expected to be missing |

The three at the top were already known to be absent; what is new is that they
block 76 modules between them.

### Macros at the wrong level — `IFO092`, 225 modules

`MODID` is the measured instance. 112 modules call it with `DATE=` or `PTF=`;
the `MODID` in `SYS1.AMACLIB` — the same library IFOX00 reads — has the
prototype `&LABEL MODID &BRANCH=,&BR=` and defines neither, while its own
comments name the PTF that added `PTF=` support (`OZ15314`). `IECVOID` is the
whole case in three cards. Other keywords flagged in this class include `ALIGN`.

This is the macro-provenance question with evidence instead of suspicion, and it
is the same question Dave Kreiss' rebuilt tape is expected to answer.

## What is probably not ours

`IFO117` + `IFO178` on ~455 modules is the empty-`&SYSPARM` substring class, and
**`as370` reports the same thing on 460 modules**. Where both assemblers object
in the same place, the source is the question, not the tooling. Check one by hand
before spending effort here.

## Two macros tried, 2026-09-07 — and what they taught

### `ISDAFSPC` — I called it a stub, and IBM's tape says otherwise

Found in the MVS-sysgen collection. Three cards: `MACRO`, the prototype
`ISDAFSPC &OP,&LV=,&A=`, `MEND`. It generates nothing.

`ISDAAPR0` calls it twice as `ISDAFSPC R,LV=(0),A=(1)`. Against IBM's shipped
object:

| | Diagnostics | Section |
|---|---:|---|
| without | 2 | 2,191 B against IBM's 2,217 |
| **with the stub** | **0** | **2,191 B against IBM's 2,217** |

**Corrected.** IBM's own distribution tape carries `ISDAFSPC` as the same three
cards. It is genuine and it really does generate nothing, so the 26 missing bytes
have another cause — the measurement was right and my reading of it was not. I
inferred "not genuine" from "generates nothing", and the shape of a macro says
nothing about where it came from.

The rule that survives: a macro is usable when its expansion is right. The one
that does not: that a macro which emits nothing must be a placeholder.

### `IHANVT` — real, partial, and not adopted

From CBT tape file 405. A genuine `NVT` mapping, and it helps: on `IEAVAP00` the
diagnostics fall from 380 to 312. But **39 `NVT` symbols stay undefined**
(`NVTPAREA` alone is used 26 times), and the module's dominant undefined symbols
are not `NVT` at all — `RENTRY` (96), `RNVT` (48), `REXIT` (48), `RPARM` (45),
register conventions out of a further macro we do not have.

Adopted on the host side alone and measured tree-wide, it **loses two identities
and gains none** (`IEAVNP07`, `IEAVNPM2`). That is not a verdict on the macro: it
is the two sides seeing different macro libraries, which is the one inequality
that makes every difference unattributable. Both modules call `IHANVT`, and MVS
has no `IHANVT` in `SYS1.AMACLIB` or `IBMUSER.PVTMAC`.

**So a macro can only be adopted on both sides at once**, host and MVS, with the
reference decks of the affected modules replaced in the same step. The recipe
below does that; the two lost identities are what happens when it is not
followed.

### And the reason all of this matters more than it looks

Of the 33 modules blocked on `IHANVT`, **13 currently count as
`as370` == IFOX00 identical.** Both assemblers fail on the same missing macro in
the same way and produce the same wrong object. **Not one of the 33 is identical
to its DLIB member.**

Agreement between the two assemblers is not correctness when both are missing the
same thing. That is the sharpest statement of what this document is for.

## Measured for the `mvssrc` sessions: the missing comment star

129 members of their tape tree carry lines that begin with a blank and `/*`
instead of `*/*` — the comment star is missing in column 1, and `jay` has the
same lines, so it comes off the tape rather than out of their extraction. They
have no assembler to ask what it costs. Asked here, 2026-09-07:

```
 /*   MACRO NAME = IDAAMBL                              */
```

| | |
|---|---|
| IFOX00 | `rc 8`, **`IFO054 INVALID OPERATION CODE`** on that statement |
| `as370` | `rc 8`, `Undefined operation code - /*` |
| object | **unaffected** — the statement generates nothing and assembly continues |

So it is invalid assembler on both sides and the two agree about it. A member
with 26 such lines earns 26 diagnostics and a correct deck. It costs a return
code, not bytes — but it will put a module in the "both flag" class for a reason
that has nothing to do with its code.

None of the 129 is in `MVSBLD`; they are DSECT macros that live in Dave Kreiss'
macro libraries rather than in his `.ASM` tree.

## How to work an entry

```sh
cd ~/repos/mvs/mvs38src

# 1. what is blocked by one operation
grep -P '^IHANVT\t' work/measurements/ifox-run/ifox-objections/undefined-ops.tsv

# 2. find the macro (Dave Kreiss' tape, the web mirrors, another DLIB), put it
#    into work/macros/<source>/ and upload it to MVSCE-EXP the way the others
#    went up -- see tools/ifox_run.py, PUT /zosmf/restfiles/ds/IBMUSER.PVTMAC(NAME)

# 3. replace the reference decks of exactly the modules it unblocks
printf 'IEAVAP00\nIEAVNIP0\n' > /tmp/refresh.txt
python3 tools/ifox_run.py run --only /tmp/refresh.txt

# 4. measure again -- as370 against the new reference
python3 tools/ifox_compare.py <as370>
python3 tools/module_table.py
```

Step 3 deletes those modules' decks and state rows and runs them again, so the
reference is replaced rather than added to. **Whatever it changes has to be said
in both directions**: modules that now agree, and modules that no longer do.

⚠️ **The archived reference and the live one must not drift apart.** The recorded
figures belong to `ifox-decks.tar.gz`. If reference decks are replaced, re-make
the archive in the same commit as the new figures, or the gate in
[`regression-gate.md`](regression-gate.md) measures against a reference nobody
can reconstruct.

## Where the data is

| File | Contents |
|---|---|
| `ifox-objections/by-code.tsv` | every IFOX00 code, its module count, its message |
| `ifox-objections/IFO0nn.txt` | the module list per code |
| `ifox-objections/undefined-ops.tsv` | the 51 unresolved operations, whether we have them, and where they occur |
| `diag/<module>.txt` | the diagnostics section of that module's IFOX00 listing |
| `module-table.tsv` | one row per module, both assemblers' return codes and messages |

## `IBCDASDI` and `IBCDMPRS`: an exclusion withdrawn, 2026-09-09

Both were set aside here as *source torn by an FTP transfer*. **That reason was
wrong and the exclusion is withdrawn.** cc370 noticed it from the other side:
with `REPRO` implemented (cc370#316), `IBCDASDI`'s deck came out identical to
IFOX00's — and a deck that matches cannot have come from torn source.

What is actually the case, measured rather than inferred:

| | |
|---|---|
| MVSBLD members that are **not** a clean 80+CRLF grid | **2 of 5,528** — these two, and nothing else |
| where each leaves the grid | record 11, the first embedded binary `REPRO` card, in both |
| by how much | **exactly one byte**, in both |
| what IFOX00 read | **5,957 records where the grid holds 5,955**, and two `IFO053 OP CODE NOT FOUND ON FIRST OR ONLY CARD` |
| what that cost | **`rc 8` and not one byte of object** |

So the damage is real, it is in our copy, and it is worth a return code only.
That is the same shape as the missing comment star above: invalid input both
assemblers step over.

**`IBCDASDI` is identical to IFOX00** — 404 cards, one of which differs, and that
one is the END card's identification field, where each assembler writes its own
name (`ASM370` against `1574ASC103`). `ifox_compare.py` excludes that field by
design. **`IBCDMPRS` differs in 2 of 335 cards** and is an ordinary case for
cc370, which is the reason the exclusion had to go: a skipped module is a case
nobody looks at.

### IBM's tape copy is clean and is *not* the repair

Both members exist in `mvs38-ibmsrc` as perfect grids. It is tempting to swap
them in. Measured, that moves the wrong way:

| assembled from | cards differing from IFOX00 |
|---|---:|
| Dave Kreiss' MVSBLD (off-grid) | **1** (`IBCDASDI`), 2 (`IBCDMPRS`) |
| IBM's tape copy (clean grid) | **7**, both |

The binary cards differ from **index 2 onward**, not by the one byte. Dropping
the stray `CR` from Dave's card does not reconstruct IBM's. These are two
different levels of the same member, and only one of them is what IFOX00 read.

**Which binary card values belong in MVS 3.8j's `IBCDASDI` and `IBCDMPRS` is
open.** IBM's tape says one thing, Dave's tree another, and the DLIB object is
the only thing that could settle it.
