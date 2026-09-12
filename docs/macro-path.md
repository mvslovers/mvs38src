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
