# The RLD-offset acceptance — 2026-09-17

The tree-wide acceptance run for cc370 **#404** (issue #403), and the basis for
merging it as `210ec3a` and moving the `cmplmd370` pin.
`RESULT-rld-offset-9233d0f.md` is the account; everything else here is its
evidence.

| file | what it is |
|---|---|
| `RESULT-rld-offset-9233d0f.md` | the measurement, its controls, and the claim it forced a correction to |
| `gate-PINNED.tsv` | `baseline_gate.py` with the comparator that was pinned — reproduces the published figure |
| `gate-NEW.tsv` | the same with the comparator from the PR head `9233d0f` |
| `explained-OLD.tsv`, `explained-NEW.tsv` | `explained.py` over the old and the new gate |
| `cmp-PUBLISHED-PINNED.txt` | the control: the pinned run against the published `overlay-vs-both.tsv` |
| `cmp-PINNED-NEW.txt` | the measurement: old against new, compared as SETS |
| `ctlorder-census.txt` | `tools/ctlorder.py` over our own members — the diagnosis, verified here before the PR existed |

The harness itself is next door in
[`../cmplmd-reader/`](../cmplmd-reader/) — `gate_with.py` runs `baseline_gate.py`
with a different comparator without editing it, and `cmp_gates.py` compares two
gate TSVs as sets.

## The result

```
control  parent build (057ab3f) vs the pinned binary   BYTE-IDENTICAL
control  PINNED vs published overlay-vs-both.tsv       set-identical, 0/0
control  30 dasm370 control CSECTs, both binaries      27/3, none moved
control  merged build (210ec3a) vs measured binary     BYTE-IDENTICAL

PINNED -> NEW, 5,353 CSECTs, chosen baseline
  recovered   1,626 -> 1,628     (+2 / -0 as SETS)    IEAVTSL2, IEAVTSLS
  explained   1,719 -> 1,721
  disagree       57 ->    55
  dlib_c      set-identical
  identical -> differs            0    <- the control that decided it
```
