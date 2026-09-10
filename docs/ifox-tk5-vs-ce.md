# Is TK5's IFOX00 the same assembler as MVS/CE's?

2026-09-10. [`fahrplan.md`](fahrplan.md) stage 1, first probe. Every recorded
figure in this project is against **MVS/CE's** Assembler XF; TK5 carries 115
USERMODs against MVS/CE's 37, so the two may not be the same program. If they are
not, moving the baseline to TK5 costs a re-run of all 5,528 reference decks.

## The probe, and why it is the RLD `R` field

cc370 measured that `as370` and MVS/CE's IFOX00 produce an **image-identical**
module for ten `IFNX*`/`IFOX*` modules and differ only in the RLD `R` field — the
ESDID the relocation points at. `as370` names the enclosing `SD` where IFOX00
names the `LD` or `ER` entry.

That field is a **discrete value**. It depends on neither the assembly stamp nor
the clock, which matters here more than anywhere else in the corpus: **21 of the
26 stamp-dependent modules in the whole tree are this same family**, because
Assembler XF assembles itself and writes its own build time into its own object.
A whole-deck comparison of these modules against a deck recorded three days
earlier *must* differ. The `R` field does not.

## Setup

Assembled on **`MVSTK5-BLD`** (`:8085`). `MVSTK5-REF` was not written to.

The macro input is held constant: `MVSCE-EXP`'s `IBMUSER.PVTMAC`, all 453
members, copied byte for byte to `HERC01.PVTMAC` and used as the seventh SYSLIB,
exactly as the oracle run does. **The question is whether the assemblers differ,
so the macros must not.**

### The first attempt was a failure that looked like a finding

Run without that seventh library, `IFOX0A` came back `CC 0012` with 527
diagnostics — `R1`, `R3`, `R13` undefined, the register equates — and the RLD
comparison dutifully reported **TK5 1 entry, MVS/CE 3, different**. That reads
exactly like a lineage result. It is the return code of a failed job. The probe
now refuses to compare a deck whose job did not end `0000` or `0004`.

## Result

| module | rc TK5 | RLD entries TK5 / CE | RLD | deck |
|---|---|---|---|---|
| `IEFBR14` *(control)* | 0000 | 0 / 0 | same | **byte-identical** |
| `IEDUSSTB` *(control)* | 0000 | 2 / 2 | same | **byte-identical** |
| `IFNX1A` | 0000 | 38 / 38 | **same** | stamp only |
| `IFNX1J` | 0000 | 1 / 1 | **same** | stamp only |
| `IFNX3N` | 0000 | 1 / 1 | **same** | stamp only |
| `IFNX5A` | 0000 | 11 / 11 | **same** | stamp only |
| `IFNX5C` | 0000 | 4 / 4 | **same** | stamp only |
| `IFNX5V` | 0000 | 2 / 2 | **same** | stamp only |
| `IFNX6B` | 0000 | 3 / 3 | **same** | stamp only |
| `IFOX0A` | 0008 | — | — | rc 0008 on MVS/CE too |
| `IFOX0D` | 0008 | — | — | rc 0008 on MVS/CE too |
| `IFNX5D` | 0008 | — | — | rc 0008 on MVS/CE too |

**Two controls came back byte-identical**, which is what says the probe is
measuring anything at all. **Seven modules: every RLD entry identical** — `R`,
`P` and address, continuation bit honoured. **Three failed, and failed the same
way on both systems** (`ifox_rc 0008` in `state.tsv`), so even the failures agree.

"Stamp only" was verified, not assumed:

```
IFNX5C  TXT card 26, cols 44-54   TK5 'IFNX5C00 11.40 09/10/26'
                                  CE  'IFNX5C00 02.40 09/07/26'
        END card 29, col 52       TK5 ...26253    CE ...26250
```

Five differing bytes in the whole 2,400-byte deck: the eyecatcher's build time in
the module's own text, and the julian date on the `END` card. `IFNX1J` is the same
shape, seven bytes.

## What this settles

**For cc370:** the `R`-field divergence is **`as370`'s**, not a lineage
difference. TK5's IFOX00 places the relocation exactly where MVS/CE's does.
cc370#186 has a direction of cause, not only a membership rule.

**For the Fahrplan:** on this sample the two assemblers are indistinguishable —
identical decks where nothing is stamped, identical RLDs where something is,
identical return codes where both fail. Together with `BAS 14,TGT` assembling to
`4DE0 F004` at severity 0 on both ([`ifox-lineage.md`](ifox-lineage.md)), TK5's
IFOX00 looks like MVS/CE's.

**What it does not settle.** Twelve modules are not 5,528, and they are drawn from
one family — the assembler's own source, which is the family most likely to be
identical because both systems build it from the same maintenance. The corpus run
is still the test. What this buys is the right to expect a null result from it,
and a probe cheap enough to repeat.

It also does not clear the macro question:
[`macro-tk5-vs-ce.md`](macro-tk5-vs-ce.md) counts 158 differing members, and this
probe sidestepped them by carrying MVS/CE's `IBMUSER.PVTMAC` across rather than
resolving them.
