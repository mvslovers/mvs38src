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

## The damage is gone too, and by three independent signals

`MAINT04@` — the `IEBCOPY` compress that failed in run 5 — ended `CC 0000`, and
it genuinely ran rather than merely returning zero: `IEB161I` starting it,
`IEB167I` reporting members actually moved, 203 × `IEB152I` compressed in place,
and **zero `IEB100I`, zero `IEB171I`**. In run 5 those two were the unreadable
member and the directory warning.

And the member itself:

```
run 5   MVSSRC.BLD.MVSSRC(IEAVEE3R)   HTTP 200,      0 bytes   <- torn
run 6   MVSSRC.BLD.MVSSRC(IEAVEE3R)   HTTP 200, 16,524 bytes
```

The empty-200 signature from `PM-2026-003` is absent. That is the damage
indicator gone, which is not the same as the member being verified correct —
there is no reference to check it against, and this file does not claim one.

Space recovered by the compress is modest: 96 → 95 % and 96 → 91 %. The libraries
are living off their secondary extent now, which is exactly what it is for.

## A third costume for the same trap: `HTTP 000`

Taking the baseline for prediction 3 with a plain shell loop, all six members
came back `HTTP 000, 0 Bytes` — while the control in the same loop returned
`200, 720`. I nearly wrote that down as "absent".

`HTTP 000` is not a server answer. It is curl reporting that it never got one:
six rapid requests with a 20-second timeout, against a REST endpoint the build
chain is hammering at the same moment. Repeated with `-sS` and a longer timeout,
the same member answers `404` in 0.22 s.

So the family now has three members, and they are worth naming together because
each looks like a result:

| signature | means |
|---|---|
| `HTTP 200`, 0 bytes | read error reported as success — `PM-2026-003` |
| `HTTP 404` | genuinely not there |
| `HTTP 000` | no answer at all; the measurement failed, not the thing measured |

**Probes taken while the chain is running need retries.** The baseline above was
re-taken with five attempts and backoff, and two controls of different sizes —
720 and 66,160 bytes — so a size-dependent failure would also show.

## Prediction 3: confirmed, six of six

`ZSTAGE2` ended `CC 0004` — run 5 gave `CC 0039` — and the six modules
`$08STG1A` could not produce now exist:

```
                        before ZSTAGE2      after
OBJPDS01  IEFEDTTB      HTTP 404            200,  7,440 bytes
OBJPDS01  DCM010        HTTP 404            200,  4,800
OBJPDS02  IEEMB850      HTTP 404            200,    240
OBJPDS03  IEAVBK00      HTTP 404            200, 37,120
OBJPDS03  IFGDEBCK      HTTP 404            200,  1,840
OBJPDS03  IEECVSUB      HTTP 404            200,  1,120
controls  IEFWMAS1      200, 720            200,    720
          IEAASU00      200, 66,160         200, 66,160
```

Both baselines were taken with retries and two controls of different sizes, so
neither reading is a load artefact. The self-healing claim holds, and leaving
Dave's `$08STG1A` unfixed was the right call: a `BLKSIZE` fix there would have
changed the archive to produce objects the chain produces anyway.

## The chain did not finish on its own, and the reason is worth more than the interruption

`bldrun.py` died submitting `ZSTAGE2`, twice, with `RemoteDisconnected` after
exhausting all its retries. The retries were not the problem and the network was
not either. The console says what is:

```
MVSMF006E STORAGE ALLOCATION FAILED FOR THE JCL LINE TABLE
```

`ZSTAGE2.jcl` is **14,167 lines**, the largest member in the chain that runs.
mvsMF cannot build a line table for it, fails, and drops the connection — which
reaches the client as a transport error and looks transient. It is not. Every
resubmit fails identically, and a retry loop against a deterministic failure
just spends the retries.

**The route around it is FTP.** `SITE FILETYPE=JES` and `STOR` put the same JCL
in as `JOB00793` on the first attempt, because the internal reader does not
build a line table. Prepared with `bldrun.py`'s own `prepare()` so `MSGCLASS=H`
and the disabled `BLDSUB` card are identical to what the driver would have sent.

Sizes of the remaining 21 members: all under 2,700 lines, most under 1,000. So
this is one member, not a pattern, and the driver handled the rest.

Two things for later, neither urgent enough to do during a run:

* **`bldrun.py` should fall back to FTP** when a submit fails this way, or at
  minimum recognise `MVSMF006E` in the console and stop calling it transient.
* **The retry message is misleading.** It prints `(transient: RemoteDisconnected,
  retry 6/11, 60s)` for a failure that will never succeed. A retry loop should
  say what it is retrying, not just that it is.

## Predictions 4 and 5: confirmed. The run is complete.

`$08STG1A` still ended `CC 0020` — the fix I did not make did not happen.

And the chain stopped itself, on its own guard rather than on an error:

```
20 ZCMPSMP1   SMPCHK1/JOB00814  CC 0000
STOP: ZCMPSMP1 hands on to LIB=1 (MAINT05@). That is the Phase-1 boundary
      and it updates the running system.
```

All five predictions held. Two non-clean jobs in 260, both documented as
harmless, and one manual intervention — `ZSTAGE2` by FTP, for a reason now fixed
in `bldrun.py`.

# What the build actually produced

Dave's chain ends in its own comparison jobs, and they are the point of the
whole exercise. Two instruments, and they must not be quoted as one number.

## CSECT level — `LMDRPT38`, "Original vs Build CSECT/LMOD Report"

| library | equal | **not equal** | length different | missing CSECT | missing LMOD | total |
|---|---|---|---|---|---|---|
| NUCLEUS | 344 | **0** | 10 | 1 (ignored) | 2 | 354 |
| SVCLIB | 59 | **0** | 0 | 0 | 0 | 59 |

**Not a single CSECT differs in content.** Every difference is a length, a
missing CSECT, or a missing load module. The three that are missing are named:
`IEANUC01/IECVXTPT` (28 bytes, ignored), `IEAVNPF1/IEAVNPF1`, `IEAVNP15/WILDCRD`.

## Load-module byte level — `COMPLMD`, offset by offset

| job | compared | identical | differing | difference records |
|---|---|---|---|---|
| NUCCHK1 | 155 | 29 | 126 | 2,085 |
| NUCCHK2 | 156 | 36 | 120 | 1,279 |
| NUCCHK3 | 51 | 7 | 44 | 2,238 |
| NUCCHK4 | 163 | 31 | 132 | 496 |
| NUCCHK5 | 162 | 57 | 105 | 311 |
| SVCCHK | 116 | 54 | 62 | 224 |
| JESCHK | 28 | 1 | 27 | 3,735 |
| SMPCHK | 238 | 16 | 222 | 1,888 |
| **total** | **1,069** | **231** | **838** | **12,256** |

`COMPLMD` compares `SYS1.SVCLIB` against `MVSSRC.BLD.SVCLIB` and so on, at fixed
offsets, with `CLEARRLD=NO`. A module whose code is right but sits at a different
address scores as wrong throughout.

## The two numbers are not in conflict, and the gap between them is the work

`0` CSECTs unequal against `838` load modules differing is not a contradiction:
one instrument compares what was assembled, the other compares where it landed
after link-edit. The gap is displacement, maintenance stamps and alignment holes
— exactly the material `docs/what-is-left.md` already classifies, and exactly
what stage 5 is about.

**Quote them together or not at all.** "21.6 % byte-identical" on its own is
true and misleading; "no CSECT differs in content" on its own is true and
flattering. The pair is the honest statement.
