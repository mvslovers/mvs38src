# One macro path, and it had drifted eight ways

2026-09-12. `gate.sh` decides the `-I` path, because it produces the decks every
other tool judges. A tool that assembles with a different path is not measuring
the same thing.

**Eight tools disagreed with it.** `gate.sh` passed ten directories; all seven
Python tools that assemble passed eight, every one of them missing `erep-set`
and `amaclib-live`. The gate gained those on 2026-09-09, when the six EREP
macros were uploaded to `IBMUSER.PVTMAC` on the oracle and 33 reference decks
were re-cut against them ([`erep-adoption.md`](erep-adoption.md)). None of the
consumers followed, and nobody looked.

| | `-I` directories |
|---|---:|
| `tools/gate.sh` | **10** |
| `as370_messages.py` `first_divergence.py` `ifox_compare.py` `ifox_offdiag.py` `rebuild_classes.py` `setc95_reach.py` `witness.py` | 8 |

## The reach, measured by cc370 before it was fixed

One binary, both paths, all 5,528 modules, everything else held fixed:

```
decks that differ between the ten- and eight-directory paths : 33
  every one EREP (IFCE* / IFCS*)
return codes that differ                                     :  0
```

Scored against the reference decks:

| | 10 dirs | 8 dirs |
|---|---:|---:|
| card count equals the reference | **9** of 33 | 1 of 33 |
| card count within 2 | **21** of 33 | 2 of 33 |

**The short-path decks are not subtly wrong, they are starved.** `IFCE0115`
assembles to 15 cards against a 107-card reference; `IFCE0125` to 29 against
195. The macros are simply absent, so the deck is the assembler running out of
input rather than the assembler being wrong.

**The sharpest instance is `IFCE33XX`: 1 differing card of 97 on the gate's
path, 61 on the starved one.** Same binary, same source, same reference.

## The fix closes the class, not the instance

`tools/macpath.py` parses `MACFLAGS` out of `gate.sh` and every assembling tool
imports it. **`gate.sh` is now the only file in `tools/` that states the path**,
verified by grep. `macpath.py` does not even name the directories — it reads
them.

This is the same shape as two earlier fixes and the third time the rule has had
to be learned: `macrosnap.py` restating credential resolution instead of using
`creds.py`, and the system list living in five `.env` files before
`systems.json` existed. **A rule restated in a second place is a rule that will
drift**, and here it had drifted seven times from one authority.

## What is NOT fixed, and it is a caveat on a table people read

**No numbers have been re-derived.** The pipeline was not re-run, so
`work/measurements/ifox-run/module-table.tsv` still contains rows computed on
the eight-directory path.

- **No headline moves.** All 33 carry an IFOX00 reference at rc 12, so they sit
  inside the 933 excluded from the case list
  ([`cc370-cases.md`](cc370-cases.md)) and were never in it.
- **What is affected is class work.** `first_diff`, the cluster a module lands
  in, and any residue counted from those are, for these 33 rows, a description
  of the wrong input. One of them is one card from identical.
- **Which 33 is cc370's measurement, not ours.** We have not enumerated them
  here, and saying "the EREP modules" is the shape rather than the list. A
  re-run of `ifox_compare.py` — now on the correct path — settles it.

That re-run is a deliberate act with a cost: it rewrites a table other sessions
read and figures that appear in several documents. It is Mike's call, not a
tidy-up to be slipped in.

---

## The re-run, 2026-09-12 — and it surfaced a second, larger inequality

Mike's call, so it was run. `ifox_compare.py` on the corrected path with the
binary from cc370 `98d0cb8` (both #365 and #367 merged; `sha256 bdef7470…`,
pinned by copy at `work/src-states/bin/as370-main`), then `module_table.py`.

### What moved

**`verdicts.tsv`: 26 rows. `module-table.tsv`: 14 rows.**

| `tool` | | |
|---|---|---:|
| `cards` → `bytes` | the macro path | **8** |
| `bytes` → `identical` | the two merged `as370` fixes | **6** |

| | before | after |
|---|---:|---:|
| `identical` | 5,465 | **5,471** |
| `cards` | 34 | 26 |
| `bytes` | 29 | 31 |
| **`silent divergence`** | **8** | **2** |

`as370 == IFOX00` is now **5,471 of 5,528 — 99.0 %**, and the attribution says
**4 tool cases** tree-wide.

**Fewer rows moved than the 33 decks cc370 measured**, and that is consistent
rather than contradictory: most of the 33 sit at IFOX00 rc 12, where the `tool`
verdict was already `bytes` or `cards` for other reasons, so a changed deck does
not necessarily change a column. `first_diff` moved on none of them.

### The second inequality, and it is bigger than the macro path

While confirming which DLIBs the tool compares against:

```
work/measurements/dlib  vs  dlib-bytes/tk5  vs  dlib-bytes/ce
  members where TK5 and CE agree anyway : 3,369
  divergent members, dlib == TK5        :     0
  divergent members, dlib == CE         :   491
```

**`ifox_compare.py` scores against MVS/CE's distribution libraries** — the
baseline this project superseded on 2026-09-10
([`fahrplan.md`](fahrplan.md) §1). Its `recovered: 1,202` is a figure against
`CE`, while the scoreboard's is against TK5.

Quantified on one deck set, so the only variable is the baseline:

| verdict | against TK5 | against CE |
|---|---:|---:|
| identical | **1,084** | **1,094** |
| holes-only | 506 | 527 |
| differs | 2,398 | 2,367 |
| **modules whose verdict changes with the baseline** | **81** | |

1,084 against 1,094 is the founding measurement of the baseline decision,
reproduced here by accident — `deck-vs-tk5-ce.md` records exactly that pair and
the fahrplan's argument that the two are "ten modules apart in 3,988 because
87 % of the corpus carries the same object on both". **The total barely moves
and 81 individual verdicts do**, which is the whole reason the decision was made
on divergent modules rather than on the raw count.

**This is not fixed here.** `srcstate_vs_dlib.py` takes `--base tk5|ce` so the
question can be asked; `ifox_compare.py` still points at `CE` and its
attribution numbers are CE numbers. Switching it is a larger decision than the
macro path was: it changes what `module-table.tsv` means about the source rather
than about the tool, and the tool question — `as370` against IFOX00, 5,471 of
5,528 — does not involve a DLIB at all and is unaffected either way.
