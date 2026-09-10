# The macro libraries: TK5 against MVS/CE

2026-09-10. The control that has to pass before anything is read into a deck
difference between the two systems — [`fahrplan.md`](fahrplan.md) stage 1. A deck
difference is an *assembler* difference only if both sides expanded the same
macros, and the two systems had never been compared at the macro level at all.

2,326 members over seven libraries, read from both systems by `tools/dlibpull.py`
in binary mode, compared byte for byte.

## Columns 73–80 are not source, and the raw number is a trap

Compared raw, **242 of 242 `APVTMACS` members differ** — and most of them at
identical length. That is not maintenance:

```
TK5  '         MACRO                                                          10000000'
CE   '         MACRO                                                                  '
```

TK5's macro members carry sequence numbers, MVS/CE's do not. The assembler
ignores columns 73–80 entirely, so those are not differences it can see.
`IHADECB` is the same trap one digit wide: 904 differing bytes, all of them
column 80.

Every figure below masks columns 73–80. **The raw count is 358 and means
nothing; the real one is 158.**

## Result

| library | common | identical | differ | only on TK5 |
|---|--:|--:|--:|--:|
| `AMACLIB` | 572 | 553 | 19 | 0 |
| `AMODGEN` | 288 | 274 | 14 | 0 |
| `AGENLIB` | 243 | 205 | 38 | 1 (`OLDCARD`) |
| `ATSOMAC` | 100 | 87 | 13 | 0 |
| `ATCAMMAC` | 139 | **139** | **0** | 0 |
| `APVTMACS` | 242 | 197 | 45 | 0 |
| `MACLIB` | 742 | 713 | 29 | 5 |
| **total** | **2,326** | **2,168** | **158** | 6 |

**93.2 % identical.** `ATCAMMAC` — the TCAM macros — is identical member for
member, which is a useful shape: whatever moved the other libraries did not touch
that one at all.

The five `MACLIB` members TK5 has and MVS/CE has not are `BTMHJN`, `BTMIOBWA`,
`IECPDSCB`, `IEZCTGPL`, `IHADECB` — four of them macros this project spent a day
hunting for in September ([`missing-macros.md`](missing-macros.md)).

## What the 158 are, and what still has to be established

Not all of them are maintenance. **`AGENLIB` is the sysgen library**, and 30 of
its 38 are `SG*` members — stage-1 sysgen macros that encode a system's own
device configuration. Two differently-configured systems *must* differ there, and
it says nothing about maintenance level. `APVTMACS`'s 45 are mostly `IRA*` (SRM
control blocks) and `IHA*` (system control blocks); those are not configuration
and are the interesting half.

**This does not yet clear stage 1.** What it establishes is the size and shape of
the confound: on 93 % of the macro surface there is none, `ATCAMMAC` is clean
throughout, and the residue is concentrated and named. The remaining step is to
check whether any of the 158 is reached by a module in the corpus — the same
distinction [`missing-macros.md`](missing-macros.md) turns on, and one a source
scan cannot answer, because a macro invoked from inside another macro appears on
no module's card. cc370 established that the hard way on 2026-09-10 with a
control (`IDACB2`, certainly used, counted 0).

Raw member bytes are cached under `work/measurements/macro-bytes/` and are not in
git.

---

## The 158 do reach the corpus — 68 modules, measured

2026-09-10. The open question above was whether any of the differing macros is
actually expanded by a module in the corpus. cc370 had established that a source
scan cannot answer it (a macro called from inside another macro appears on no
module's card), and the proposed instrument was `-am`, a listing option that does
not exist yet.

**It did not need a new instrument.** Of the 158, **129 are in the six libraries
`gate.sh` puts on the `-I` path** (`MACLIB`'s 29 are not). Put those 129 TK5
copies first on the path and run the corpus against the recorded MVS/CE decks:

```
as370 == IFOX00 : 5417 -> 5350   (-67)
  LOST    : 68        gained : 1
  decks FURTHER from IFOX00 : 72
  return code agrees : 5524 -> 5524   (+0)
```

**Sixty-eight modules change their object.** Not a handful — the utilities are
hit hardest (`IEBGENRT` `IEBUPDTE` `IEHLIST1` `IEHDASDS` `IEBISF` …), then TSO
(`IKJEFA00` `IKJCT436` `IKJEBEFC`), then Data Management (`IGG0325*` `IGG0553*`).
Full list: `work/measurements/ifox-run/retest-obj_tk5macs.tsv`.

Every return code stayed the same, so this is not a macro that fails to expand —
these all assemble cleanly and produce **different code**.

### What that settles

**Stage 1's corpus run must hold the macros constant.** Running
`tools/ifox_run.py` on TK5 against TK5's own libraries would put 68 modules on
the difference list for macro reasons, and they would be indistinguishable from
an assembler difference. The run has to carry MVS/CE's macro libraries across,
the way the twelve-module probe carried `IBMUSER.PVTMAC`
([`ifox-tk5-vs-ce.md`](ifox-tk5-vs-ce.md)).

**And it makes the macro delta a first-class part of the baseline decision.**
If the reference is ever re-cut on TK5, these 68 modules are where TK5's macro
level, not TK5's object level, changes the answer.

### For `-am` (cc370#345)

The reach question is answered without it, and the list of affected modules came
for free. What `-am` would add is **which** of the 129 macros is responsible for
each of the 68 — useful for diagnosis, no longer the only way to know whether
anything is affected. It is justified and it is not blocking.

`IGC018` is the one module that goes the other way: TK5's `IHADVCT` matches the
`mirror` copy, so it recovers the identity it lost when the correct `AMACLIB`
copy went on the path. Two wrongs, again.
