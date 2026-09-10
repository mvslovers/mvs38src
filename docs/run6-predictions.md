# Run 6: what I expect, written before it happens

2026-09-11, 23:30, chain at job 161 of 260. Recorded now so the outcome is a
test rather than a story told afterwards — the same discipline as
`deck-vs-tk5-ce.md`. Whatever happens, this file is not edited; the result goes
underneath it.

## State at the time of writing

```
MVSSRC.BLD.MVSSRC     75% full   1 extent
MVSSRC.BLD.AMVSSRC    74% full   1 extent
MVSSRC.BLD.ASMPRINT    0% full   1 extent
```

Run 5 died from `MVSSRC.BLD.MVSSRC` reaching 100 % in one extent with no
secondary quantity. `bldrun.py` now supplies `S=50` at submit time, and the
job's own JESJCL confirmed MVS read it. So:

## Predictions

**1. `MAINT03B` (job 226) ends `CC 0000` or `CC 0004`.** No `IEC031I D37-04`.
This is the direct test of the fix; run 5 failed here.

**2. `MVSSRC.BLD.MVSSRC` reaches `extx` > 1 before the run ends.** This is the
stronger evidence and the one I actually want, because prediction 1 could also
be satisfied by the library simply not filling up this time. An extent count
above one proves the secondary was honoured rather than merely unneeded. If
`MAINT03B` passes while `extx` stays 1, the fix is **unproven**, not confirmed.

**3. `ZSTAGE2` (job 239) creates all six modules `$08STG1A` failed to produce** —
`IEFEDTTB` `DCM010` in `OBJPDS01`, `IEEMB850` in `OBJPDS02`, `IEAVBK00`
`IFGDEBCK` `IEECVSUB` in `OBJPDS03`. Currently absent (HTTP 404, checked against
a control that returns 200). This tests the claim that the chain self-heals and
that leaving `$08STG1A` unfixed was right.

**4. `$08STG1A` (job 7) still ends `CC 0020`.** Already observed — it did. Listed
because a fix I did not make must not appear to have happened.

**5. The chain stops at `MAINT05@` with a `LIB=` other than the base library**,
around job 260, on the driver's phase-1 guard rather than on an error.

## What would falsify the diagnosis

- `MAINT03B` failing again with `D37-04` → the secondary did not take, and the
  JESJCL evidence was necessary but not sufficient.
- `ZSTAGE2` failing to produce the six → the self-healing claim is wrong and
  `$08STG1A` needs the `BLKSIZE` fix after all.
- Any new `IEB100I` / `IEB171I` on a compress → another torn member, meaning the
  space problem is not the whole story.

---

# Result

## Predictions 1 and 2: confirmed, and 2 is the one that counts

`MAINT03B` ended `CC 0004` at job 226 — where run 5 died. No `IEC031I`, no
`D37`, no `IEB100I`, no `IEB171I`. The only non-zero step is the APPLY's own
`CC 0004`.

But prediction 2 is what makes it evidence rather than luck:

```
                        before (job 161)      after MAINT03B (job 226)
MVSSRC.BLD.MVSSRC       75% full, 1 extent    96% full, 17,430 tracks, 2 extents
MVSSRC.BLD.AMVSSRC      74% full, 1 extent    96% full, 17,430 tracks, 2 extents
```

**17,430 − 16,680 = 750 tracks = 50 cylinders.** Exactly the `S=50` supplied at
submit time, taken exactly once. So the library did run out of its primary — the
same wall run 5 hit — and this time MVS extended it instead of abending the
step. The fix is proven in the only way that counts: the failing condition
occurred and was survived.

Had `MAINT03B` passed at `extx 1` this would have been recorded as unproven.
It did not, so it is not.

## Still open

`ASMPRINT` is at 1 % in one extent, so its secondary is supplied but untested —
it never needed to grow. Untested, not unproven; there is no evidence either way
and the file should not claim more.

Both source libraries are at 96 % of their *new* size and will extend again.
`BLDSR1` has 15,330 tracks free, about 20 more extents of 50, against MVS's
limit of 16 per volume for a PDS — so roughly 15 usable. That is comfortable for
this run and is the number to watch if the chain is ever lengthened.

Predictions 3 to 5 are still ahead: `ZSTAGE2` at job 239 and the phase-1 stop.
