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
| 3,466 modules where `as370` == IFOX00 | 495 |
| 2,112 modules handed to cc370 | 477 |
| **869 recovered — all three decks agree** | **0** |

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
