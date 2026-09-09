# Adopting the EREP macros on both sides — 2026-09-09

Mike's decision, after the host-only measurement showed the question could not be
answered from here. This records what was changed, what it cost, and what it did
not do, because it **replaces part of the oracle** every figure in this
repository is measured against.

## What was done

Six members uploaded to `IBMUSER.PVTMAC` on `MVSCE-EXP`, which is in
`ifox_run.py`'s `SYSLIB` concatenation:

```
DSGEN  LINE  ROUTINE  SPECIAL  SUM        work/macros/erep-instream/
IFCMACS                                   work/macros/kreiss-smp/
```

`work/macros/erep-set/` is the exact set, kept so the change is reproducible.
Every upload was read back and compared over columns 1–72; all six round-tripped.

**Scope, derived twice and agreeing.** Gated on the host with only this set, the
decks of **33 modules** change and no return code does — `IFCE*` 27, `IFCS*` 6.
That is exactly the set IFOX00 itself named with `IFO068 COPY MEMBER IFCMACS NOT
FOUND IN LIBRARY`. The earlier run that used `kreiss-smp` entire moved 106
decks; the extra 73 were the `IOS*`, `ILRAIA` and `IEAPPNIP` macros, which are
not EREP and were deliberately left out.

Then `ifox_run.py run --only` replaced those 33 reference decks, and
`ifox_run.py diag --list` their diagnostics.

## What it bought

| | before | after |
|---|---:|---:|
| `IFO068 COPY MEMBER IFCMACS NOT FOUND` | **33 modules** | **0** |
| `IFO078 UNDEFINED OP CODE` | 3,119 | **668** |
| `IFO236 ILLEGAL CHARACTER IN EXPRESSION` | 1,828 | 631 |
| `IFO188 UNDEFINED SYMBOL` | 1,068 | 339 |
| total object across the 33 | 37,760 B | **75,120 B** |

**The reference is twice the object and a third of the diagnostics.** It is a
materially better reference for those 33 modules, which is the whole point: a
deck out of an assembly that ended `rc 12` on a missing `COPY` member was not
authoritative.

## What it did not do

**`as370` == IFOX00 did not move: 5,404, and `LOST : 0`.**

| | |
|---|---:|
| decks closer to IFOX00 | 9 |
| decks further from it | 24 |
| identities gained | **0** |
| identities lost | **0** |

IFOX00 still returns `rc 12` on all 33, because the macros it is *now* missing
are the next ones down: `LINEND CONVT HEX SUMMARY PROLOG FREETAB ETEPILOG
ENTRIES`. Both assemblers are still short of the same set, so both still fail,
and the class stays in `both flag`.

**That is the result, not a disappointment.** The adoption was worth doing on its
own terms — it removes a `COPY` failure from the oracle and doubles the object
those 33 modules are measured against — and it says precisely what is left: eight
more macro names, and until they are found this family cannot close.

## The stale cache that nearly reversed the reading

After the re-run, all 33 diagnostics still showed `IFO068`, which reads as *the
upload did not work*. `cmd_diag` skips any module whose `diag/<m>.txt` already
exists — a cache with no staleness guard, the same shape as `as370-messages.tsv`
before it got one. The decks had already doubled, which is what said the macros
had in fact landed. **A cache that silently answers for an older run is worse
than no cache**; the old files are in `work/measurements/erep-adoption/diag-before/`.

## Reversing it

`work/measurements/erep-adoption/` holds `pvtmac-before.txt` (the 444 members of
`IBMUSER.PVTMAC` before the change), `decks-before/` and `state-before.tsv` (the
33 replaced references), `diag-before/` and `affected.txt`. Restoring those three
directories and deleting the six members undoes it exactly.

⚠️ `ifox-decks.tar.gz` was re-made **in the same commit as these figures**, and it
now carries `state.tsv` as well as the decks, so a reader can reconstruct both the
references and their return codes.

## Round two: `LINEND`, `HEX`, `CONVT` — 2026-09-09, later the same evening

Three more of the eight turned out to be in `MVSBLD` all along, defined in-stream
by the modules that carry their own — 118, 112 and 24 copies. Adopted the same
way: uploaded to `IBMUSER.PVTMAC` on the oracle, added to `gate.sh`'s `-I` path,
and the affected reference decks replaced in the same step.

**Scope: 31 modules** — `IFCE*` 26, `IFCS*` 5, derived from the gate rather than
assumed.

| | before | after |
|---|---:|---:|
| deck bytes across the 31 | 66,480 | **132,320** |
| IFOX00 return code | `rc 12` on all 31 | **`rc 12` on all 31** |

**And identity did not move, exactly as with the six:**

```
as370 == IFOX00 : 5415 -> 5415   (+0)     LOST : 0
decks closer : 3     decks further : 28
DECK AND RC BOTH : 5414 -> 5414   (+0)
```

The reference doubled again and both assemblers now get twice as far — and both
still stop in the same place, because **four macros are still missing from both
sides**: `ENTRIES`, `ETEPILOG`, `FREETAB`, `SUMMARY`.

**That is the shape of the whole EREP problem in one line.** Every macro supplied
so far has bought a better reference and no identity, because the family only
closes when the *last* one is there. Nine of thirteen are in place; the class
moves when the count reaches thirteen, not before.

`PROLOG` is the fifth and it is a different case: two copies exist in `MVSBLD`
and **both are the wrong macro** — no operands, where every EREP caller writes
`PROLOG NAME=IFCE0115`. That one has to be found, not lifted.

⚠️ `ifox-decks.tar.gz` re-made in this commit, as the rule requires.
