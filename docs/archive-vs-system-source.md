# Dave's archived source against the source his own build left behind

2026-09-11. Roadmap point 1, answered in full for the first time. Both sides
were produced by the run-6 chain that completed on `MVSTK5-BLD`; the partial
pull from run 5 was set aside as an invalidated build state rather than resumed
onto, because `$01SMPAL` deletes and re-creates every build library and a
resumable puller would have mixed two builds in one directory.

## What was compared

`MVSSRC/Dave Kreiss - MVS from Source/MVSBLD/*.ASM`, the archive, against
`MVSSRC.BLD.AMVSSRC` on `MVSTK5-BLD` after his SMP chain had run — the state his
own DSK SYSMODs produced. **5,528 modules in the archive, 5,528 members on the
system.** All 5,528 read clean: no absent members, no empty-200s.

The only formatting difference is line endings — the archive is CRLF, a member
read over mvsMF comes back LF, and the sequence numbers in columns 73-80 are
present and identical on both sides. Measured on `IEFBR14` before the comparison
was written, the same way the macro comparison was.

## The result

| | modules | |
|---|---:|---|
| identical | **2,503** | 45.3 % |
| differ only in columns 73-80 | 2 | 0.0 % |
| differ only in comment cards | **2,093** | 37.9 % |
| **a statement differs** | **930** | **16.8 %** |

**83.2 % agree on every statement.** The comment-only class is large and it is
not noise to be waved away: the PL/S transcription artefacts that explain the
macro collisions live in comment cards, and so do the build's own change flags
(`*DSKnnnn` in column 1, `DSKnnnn` in column 65). A module in that class is one
nobody needs to look at twice.

The 930 are the work, and they are not evenly sized:

```
  1-9 differing lines     258
  10-99                   118
  100-999                 387
  1000+                   167
```

The largest are not edits, they are different documents. `BLSRSUMM` is 2,472
lines in the archive and 5,881 on the system; `IGG0CLBX` 2,956 against 5,526;
`ILROPS00` 2,663 against 5,180. That shape — the system roughly twice the
archive — says the archive carries a stub or an earlier level where the system
carries the SMP-applied full source, rather than that someone edited 3,000
lines. Which of those it is per module is the next question and this file does
not answer it.

## What this does not say

It does not say which side is right. The archive is Dave's working copy at some
point; the system is what his chain produced here, on TK5, in September 2026.
Where they differ, either may be the better source for the recovery, and the
adjudicator is the object code — `docs/deck-vs-tk5-ce.md` and the `COMPLMD`
reports from the run-6 comparison jobs, not this table.

Reproduce with `tools/srccmp.py`; the per-module verdicts are in
`work/measurements/archive-vs-system.tsv`.
