# cmplmd370's reader fix, measured tree-wide — 2026-09-16

Verification of cc370 `feat/obj370-scatter-overlay` `6ddbaaf` at the request of
the `dasm370` session, before they open the PR. Tree-wide on 5,353 CSECTs, the
`CURRENT` decks (`obj_sysparm1`), the chosen baseline.

## The binaries, and why there are three

| | sha256 | what it is |
|---|---|---|
| PINNED | `c907e52c…8237d43` | `work/src-states/bin/cmplmd370`, produced the published 1,608 |
| PARENT | `7b300415…8ad192e` | built here from `e35dc53`, the commit before the fix |
| NEW | `20e0bcfe…9483dcc8` | built here from `6ddbaaf`, the fix |

PARENT and NEW built from `git archive` into the scratchpad, so cc370's working
tree was never touched. `cc -O2 -Wall -Wextra -Werror`, the repo's own rule.

`baseline_gate.py` pins the comparator by path. It was NOT edited: a driver in
the scratchpad sets `baseline_gate.CMPLMD` and calls `main()`, so the trial and
the published figure run the same code.

## Two controls, both passed

**Control zero — PINNED on `CURRENT` against the published
`overlay-vs-both.tsv`: set-identical, 0/0 on both `dlib_c` and `tgt_c`**, and
every published figure reproduces (`chosen` 1,608, `dlib` 1,633, `tgt` 1,458,
`unread` 143, of which 18 the DLIB calls identical). The TSV is not stale
against the decks, so what follows is attributable.

**Control one — PINNED -> PARENT: set-identical, 0/0.** The 18 cc370 commits
between the pinned binary's commit and the fix move nothing. **The whole delta
below is `6ddbaaf` alone**, not three weeks of other work.

## The result — PARENT -> NEW

| | PARENT | NEW |
|---|---:|---:|
| **recovered under the chosen baseline** | 1,608 | **1,626** |
| identical to the target | 1,458 | 1,476 |
| identical to the DLIB | 1,633 | 1,633 |
| **target member unreadable** | **143** | **2** |
| …of those, DLIB says identical | 18 | 0 |

**+18 / −0 as sets.** Not as counts: there is **no `identical -> anything`
transition in either column, in either direction.** Nothing was lost.

Transitions, `tgt_c`: `error -> len-differs` 61, `error -> differs` 50,
`error -> identical` 18, `error -> holes` 12. `dlib_c`: `error -> len-differs`
15 and nothing else.

Second verdict, `explained.py` over the same gate: **1,700 -> 1,718** (31.8 % ->
32.1 %). `reachable` and `blocked` carry over unchanged at 21 and 71 — both were
derived with the old comparator, so 1,718 is a **lower bound**; the three
reconstruction sweeps would have to be re-cut to say whether they also gain.

## The "18 free modules", re-derived rather than inherited

The peer asked not to inherit their 18, and the two are **the same 18 modules**:

```
AKJLKMSG BLSRSURB BLSRVPTC HMASMTBM IEECB915 IGFPEXIT IGFPMCIH IGFPMFRS
IGFPMMSG IGFPMSCA IGFPMTHA IGFPSAD0 IGFPTCON IGFPTERM IGFPTREC IGFPTSIG
IGFPXMFA IGFRWAC
```

The set that was `dlib_c = identical` with an unreadable target member, and the
set that became `tgt_c = identical` under the fix, are identical. **All 18 are
`dlib_c = identical` too**, so the independent path corroborates every one.

**And TODO.md's warning — "stop quoting 18 free modules" — is now answered by
measurement rather than lifted.** The worry was that of `IEANUC01`'s 24
unreadable CSECTs, the 13 whose DLIB said identical might not be free and the 10
whose DLIB said differs might be real. Measured: **13 -> `identical`, 10 ->
`differs`, exactly as the DLIB predicted for each.** The DLIB's verdict was right
about all 24.

Two target members remain unreadable: **`IECVOID`** (inside `IEANUC01`, DLIB says
`len-differs`) and **`ISTNSC00`** (DLIB says `error` too).

## The five held on the ±5 scatter caveat come off hold

`IDA019S4 IECVERPL IECVESIO IECVRRSV IGC121` are `tgt_c = identical` under both
PARENT and NEW — the verdict never depended on the fix. What has changed is that
the reason for holding them is now measured absent rather than merely
unsuspected: NEW reports per comparison

```
identical=True  incomplete=False  scatter=True  records=797  anomalies=''
```

so the image the verdict rests on is explicitly complete. **The headline no longer
carries ±5.**

## Correction 2 is right, and it is broader than the example given

TODO.md and `docs/dasm370-interface.md` say a DLIB row is *"an extracted object
deck, not a load module, so it never enters `load_lmod`"*. Measured over the
whole corpus: **5,353 of 5,353 DLIB members begin `X'20'` — a CESD. Not one is an
object deck.** The sentence is wrong for the entire corpus, not just for
`IGFPEXIT`.

So the 60/5 corroboration argument rested on a false premise. **The corroboration
itself still holds, for the narrower reason the peer gave**, and that is measured
here independently:

| | members | flagged CESD entries |
|---|---:|---:|
| DLIB (5,353) | **0** | 0 |
| TARGET (2,396) | **21** | 149 (`X'20'` 135, `X'80'` 12, `X'14'` 2) |

`IEANUC01` holds 24 of them. That reproduces the peer's 21 members and their 24;
their 147 against this 149 is the two `X'14'` (PC) entries.

⚠️ **The first cut of this census said 18 members / 137 entries and was wrong.**
A CESD record's bytes 6–7 hold the **data** length (240) while the entries run
from +8 to the end of the **record** (248), so bounding the entry loop by the
data length drops the last entry of every record. Caught only by the disagreement
with the peer's figure — a census with no second opinion would have stood.

## What this does not settle

- `reachable.tsv`, `macroattr.tsv`, `lenattr.tsv`, `alignfill.tsv` and the three
  macro-reconstruction sweeps were all cut with the old comparator. 61 + 50 + 12
  modules newly became comparable, so those maps have a population they have
  never seen. They need re-cutting before their figures are quoted again.
- Nothing here was promoted into `work/measurements/` and no document was
  edited. The gate TSVs are in this scratchpad.

---

# Added after the PR message — 2026-09-16, later

## The last two unreadable members are not reader failures

Both report `image_incomplete: false`, `anomalies: ''`, and exit 2 on
**`no section named X`** — the deck names a CSECT the member does not carry.

| | records | what it says |
|---|---:|---|
| `IECVOID` in `NUCLEUS(IEANUC01)` | 797 | `no section named IECVOID` |
| `ISTNSC00` in `VTAMLIB(ISTNSC00)` | 7 | `no section named ISTNSC00` |

That is the same class as the 204 the peer reports remaining on their DLIB
sweep, and it is pre-existing rather than anything this branch introduced. **The
reader no longer fails on any target member in this corpus.**

## `tgt_split` drops 5 -> 3, and the old flag was partly an artefact

`baseline_gate.py` sets `tgt_split=Y` when a CSECT's several target copies give
different verdicts. `BLSRVPAS` and `IEEVSDIO` stop being flagged: one of their
copies used to `error` and the other did not, which the tool counted as a
disagreement. With both readable the copies agree. `IEFAB4E1`, `IKJEFF02` and
`IKJEGMSG` remain and are real.

## The map-against-bytes coherence check holds over a larger population

0 contradictions in both runs, over **1,437 modules under PARENT and 1,454 under
NEW**. 17 modules entered that check for the first time and none contradicted —
an independent corroboration that the newly readable members are being read
right.

## ⚠️ The segment-mapping oracle does not discriminate, and their 19-of-19 has the same gap

The peer proposes `HEWLF064`'s sections in their own single-CSECT DLIB members as
the oracle for per-segment slicing, on the grounds that a mis-assigned segment
would show thousands of differing bytes on the overlay side and zero on the DLIB
side. Run over all 25 sections, the overlay slice and the DLIB member agree on
**22 of 22 comparable** — and the agreement is worth nothing, for two reasons
measured here:

- **`length_ref` is read from the CESD entry, not from the sliced text.**
  `sect_add(..., e->len, ...)` takes it off the ESD item, so both paths report
  the same length whatever the slicing did.
- **`diff_bytes` is 0 in all 22 because `length_differs` is true in all 22.**
  TODO.md's control already says a `diff_bytes` of 0 beside a length difference
  means the comparator stopped, not that the bytes agree. **The byte comparison
  never ran.**

So "all three numbers agree for 19 of 19" is consistent with a completely wrong
segment assignment. It is not evidence either way.

**What it would take**: two sections in *different* segments that share a start
address must receive *different* reference text. `HEWLF064` has three such
segments (2, 3, 4 all begin at the same address) — that is the property the fix
claims and the one a fixture can assert directly, without any deck of ours.

**And the exposure here is zero, which is why this does not block the PR.** All
22 CSECTs scored against `HEWLF064` are `len-differs` against **both** libraries,
so the one overlay member in TK5 contributes **0** to `chosen` whether the
segment mapping is right or wrong. The claim is unproven from this side and
currently unexposed; it becomes load-bearing the moment one of those 22 reaches
equal length.

---

# The acceptance run extended to the PR head — 2026-09-16, later still

**The measurement above was cut at `6ddbaaf`, and PR #375 had moved past it.**
`795de6c` ("test(obj370): the incomplete-image refusal, and insurance for a
section with no segment") adds 8 lines to `cmplmd370/src/cmplmd370.c`, so the
tree-wide run no longer covered the head — and this project's rule is that a
merge is accepted on a tree-wide run, which means on the head and not on the
commit that happened to be measured first.

Re-run at `795de6c` (sha256 `faa151cc…e5f49b5`), same decks, same driver:

```
6ddbaaf -> 795de6c    set-identical, 0/0 on both dlib_c and tgt_c
                      chosen 1,626 = 1,626
```

`gate-HEAD.tsv` is beside `gate-NEW.tsv`. **The acceptance run now covers the PR
head.**

## Why it is set-identical, checked rather than assumed

The added lines are guarded insurance:

```c
if (nseg >= 1)
    for (i = 0; i < sd->n; i++) if (!sd->s[i].seg) sd->s[i].seg = 1;
```

They fire only for a **storage-owning section carrying `CESDSEG` 0** in a module
that has segments. Counted independently over both corpora with the corrected
record framing: **0 such entries in 2,396 target members and 0 in 5,353 DLIB
members.** So the line cannot fire here, which is what the set-identical gate
then confirms from the other side. The peer states it as insurance rather than a
fix, and on this corpus that is exactly what it is.

⚠️ One caveat on that census: the "has segments" column was derived as the
maximum `CESDSEG` over the entries, which is **not** how `lmod_scan` computes
`nseg`, and it reports every member as segmented. The figure that carries the
argument is the **zero**, and that does not depend on the proxy — no entry
anywhere carries `CESDSEG` 0 with a storage-owning type, so the guard's body is
unreachable either way.
