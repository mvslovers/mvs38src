# The cmplmd370 reader verification — 2026-09-16

The tree-wide acceptance run for cc370 **#375** (issue #372), made at the
`dasm370` session's request before they opened it, and the basis for merging it.
`RESULT-cmplmd-reader-6ddbaaf.md` is the account; everything else here is its
evidence.

| file | what it is |
|---|---|
| `RESULT-cmplmd-reader-6ddbaaf.md` | the measurement, its controls, and the corrections it forces |
| `gate-PINNED.tsv` | `baseline_gate.py` with the pinned comparator — reproduces the published figure |
| `gate-PARENT.tsv` | the same with a comparator from `e35dc53`, the commit before the fix |
| `gate-NEW.tsv` | the same from `6ddbaaf`, the fix |
| `gate-HEAD.tsv` | the same from `795de6c`, the PR head — set-identical to `gate-NEW` |
| `explained-OLD.tsv`, `explained-NEW.tsv` | `explained.py` over the old and the new gate |
| `gate_with.py` | runs `baseline_gate.py` with a different comparator, **without editing it** |
| `cmp_gates.py` | two gate TSVs compared as SETS, plus `chosen` via `scoreboard.py`'s own rule |
| `PEER-MESSAGE.md` | the report sent to the `dasm370` session, verbatim |

## The result

```
control  PINNED vs published overlay-vs-both.tsv   set-identical, 0/0
control  PINNED -> PARENT                          set-identical, 0/0
control  6ddbaaf -> 795de6c (PR head)              set-identical, 0/0
             -> the whole delta is the reader change alone

PARENT -> NEW, 5,353 CSECTs, chosen baseline
  chosen              1,608 -> 1,626     (+18 / -0 as SETS)
  target unreadable     143 -> 2
  explained           1,700 -> 1,718
  NO identical -> anything transition, either column, either direction
```

## Status

**Merged** as `63f372f` on cc370 `main`. The binary built from it is byte-identical
to the one measured (`faa151cceee15d739bf42727153dffb26ae10c19fc306b455d88ae860e5f49b5`),
so the acceptance run transfers to the merged commit exactly.

⚠️ **The published figure is still 1,608 and that is correct.** The comparator here
is not re-pinned yet, so the +18 is **measured and not counted**. Adoption is a
coordinated change, not a copy:

1. pin the binary from the merged `main` commit, with a `PROVENANCE.txt` entry;
2. re-gate into `work/measurements/baseline-gate/overlay-vs-both.tsv`;
3. regenerate the scoreboard — `scoreboard.py --check` fails until then;
4. re-cut `macroattr`, `lenattr`, `alignfill`, `reachable` and the three
   macro-reconstruction sweeps. **123 modules became comparable** that none of
   those maps has ever seen.

## Rebuilding a comparator (seconds, and it touches nothing)

Binaries are deliberately not committed. cc370's working tree belongs to another
session and must not be disturbed, so use `git archive`:

```sh
C=63f372f
mkdir -p /tmp/cc-$C && git -C ~/repos/mvs/cc370 archive $C | tar -x -C /tmp/cc-$C
(cd /tmp/cc-$C && make cmplmd370/cmplmd370 && shasum -a 256 cmplmd370/cmplmd370)

python3 work/measurements/cmplmd-reader/gate_with.py /tmp/cc-$C/cmplmd370/cmplmd370 \
        --decks obj_sysparm1 --out /tmp/gate.tsv --jobs 8
python3 work/measurements/cmplmd-reader/cmp_gates.py /tmp/a.tsv /tmp/b.tsv
```

## Two questions put to the peer, unanswered

1. Their CESD census is 147 entries against ours 149 — the gap is exactly the two
   `X'14'` (PC) entries. Did they exclude PC from "storage-owning"? Member count
   (21) and `IEANUC01` (24) agree exactly.
2. Their oracle for the overlay segment mapping **does not discriminate**, and we
   told them so rather than confirming it. It is recorded as a known limitation on
   the PR. Exposure today is 0.
