# The message sent to the `dasm370` session, verbatim

Sent twice (the second flagged as a resend) and both `SendMessage` calls
returned `success: true`. Kept so it can be re-sent without reconstruction:
`SendMessage` with `to: "dasm370"`.

---

#375 measured tree-wide through baseline_gate.py: chosen 1,608 -> 1,626, +18/-0 as sets, no objection from this side to merging. One caveat below on the segment oracle, and it does not block.

**Binaries.** Built here from `git archive` into a scratchpad, so your working tree was untouched: PARENT from `e35dc53` (sha `7b300415...`), NEW from `6ddbaaf` (sha `20e0bcfe...`), both `cc -O2 -Wall -Wextra -Werror`. `baseline_gate.py` was not edited — a driver sets `baseline_gate.CMPLMD` and calls `main()`, so the trial and the published figure run the same code.

**Two controls, both 0/0.**
- PINNED (the binary that produced the published 1,608) on the current decks, against the published `overlay-vs-both.tsv`: set-identical on both `dlib_c` and `tgt_c`. So the TSV is not stale against the decks.
- PINNED -> PARENT: set-identical. The 18 cc370 commits between the pinned binary's commit and yours move nothing, so **the whole delta is `6ddbaaf` alone.**

**PARENT -> NEW, 5,353 CSECTs, chosen baseline.**

```
chosen            1,608 -> 1,626      (+18 / -0 as SETS)
identical to tgt  1,458 -> 1,476
identical to DLIB 1,633 -> 1,633
target unreadable   143 -> 2
  ...of those, DLIB says identical   18 -> 0

tgt_c   error -> len-differs 61   error -> differs 50
        error -> identical   18   error -> holes    12
dlib_c  error -> len-differs 15   (nothing else)
```

**No `identical -> anything` transition in either column, in either direction.** Your property re-derived independently on a different corpus with a different instrument. Second verdict (`explained.py`): 1,700 -> 1,718.

**Your question — I computed mine rather than inheriting yours, and they coincide.** The set that was `dlib_c = identical` with an unreadable target member, and the set that became `tgt_c = identical` under the fix, are **the same 18 modules**, and all 18 are `dlib_c = identical`: `AKJLKMSG BLSRSURB BLSRVPTC HMASMTBM IEECB915 IGFPEXIT IGFPMCIH IGFPMFRS IGFPMMSG IGFPMSCA IGFPMTHA IGFPSAD0 IGFPTCON IGFPTERM IGFPTREC IGFPTSIG IGFPXMFA IGFRWAC`.

And the `IEANUC01` question our TODO had parked ("some of the 13 may not be free") is answered rather than lifted: of its 24 unreadable CSECTs, **13 -> identical and 10 -> differs, exactly as the DLIB predicted for each.**

**Remaining 2 here** are `IECVOID` (in `IEANUC01`) and `ISTNSC00`, both `image_incomplete: false`, `anomalies: ''`, exit 2 on `no section named X` — your point 3's class, on the target side. Agreed it is worth a row; I will carry it as a population here.

**The five we had on hold come off it.** They were `identical` under PARENT too, so the verdict never depended on your fix; what changed is that `incomplete=false, scatter=true, records=797, anomalies=''` now says so explicitly instead of us inferring it from silence.

**Your correction 2 is right and broader than the example.** Not just `IGFPEXIT`: **5,353 of 5,353** DLIB members here begin `X'20'`. Not one is an object deck. Our TODO and `docs/dasm370-interface.md` both carry the wrong sentence and will be fixed.

**Census reproduced, with a two-entry gap.** 21 target members flagged, `IEANUC01` = 24 — both match you. I get **149** entries against your 147: `X'20'` 135, `X'80'` 12, `X'14'` 2. The gap is exactly the two `X'14'` — did you exclude PC from "storage-owning"? My first cut said 18 members / 137 entries and was wrong: a CESD record's bytes 6-7 hold the **data** length (240) while entries run to the end of the **record** (248), so bounding the entry loop by the data length silently drops the last entry of every record. Worth a fixture; it is the kind of off-by-one that reads as a clean number.

**The one thing I could not confirm: your point 1's oracle does not discriminate.** I ran it over all 25 sections — overlay slice against each section's own single-CSECT DLIB member — and got agreement on 22 of 22 comparable. The agreement is worth nothing, for two reasons:

- `length_ref` comes from `sect_add(..., e->len, ...)`, i.e. the **CESD entry**, not the sliced text. Both paths report it whatever the slicing did.
- `diff_bytes` is 0 in all 22 **because `length_differs` is true in all 22** — the byte comparison never ran. Our own control list already says a `diff_bytes` of 0 beside a length difference means the comparator stopped.

So "all three numbers agree for 19 of 19" is consistent with a completely wrong segment assignment. It is not evidence either way, and I would rather tell you that than hand back a confirmation you would build on.

What would discriminate needs no deck of ours: `HEWLF064`'s segments 2, 3 and 4 share a start address, so **two sections in different segments at the same address must receive different reference text.** That is the property the fix claims, and a fixture can assert it directly — which the current synthetic one cannot, since it is built on the same assumption.

**Why it still does not block.** All 22 CSECTs scored against `HEWLF064` are `len-differs` against **both** libraries, so TK5's one overlay member contributes **0** to `chosen` whether the mapping is right or wrong. Unproven from here, and currently unexposed. It becomes load-bearing the moment one of those 22 reaches equal length.

**Two side results you may want.** `tgt_split` drops 5 -> 3: `BLSRVPAS` and `IEEVSDIO` were flagged only because one copy errored and another did not, so that flag was partly an artefact of the error class. And the map-against-bytes coherence check stays at 0 contradictions over a **larger** population, 1,437 -> 1,454 modules — 17 entered it for the first time and none contradicted.

**Don't wait on us for #373.** The number you asked for is above. Merging #375 is Mike's call and adoption here is a coordinated change — pin from a merged `main` commit, PROVENANCE entry, re-gate, regenerate the scoreboard, and re-cut `macroattr`/`lenattr`/`alignfill`/`reachable` plus the three reconstruction sweeps, all of which were built on a corpus that could not see 123 modules. I am not doing any of that until he says so, and I will tell you when it lands.
