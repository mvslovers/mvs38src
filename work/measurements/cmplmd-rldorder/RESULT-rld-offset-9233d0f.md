# cc370 #404 — the RLD offset in a bound member's control record

The tree-wide acceptance run for cc370 **#404** (issue #403), head
`9233d0f3d3560a923f5c1f3f0570c7dac87e9af6`. It was the basis for merging it and
for moving the `cmplmd370` pin.

## Status — adopted 2026-09-17

Merged as **`210ec3a`**, and the pin names that commit. The build from `210ec3a`
is **byte-identical** to the binary the acceptance was measured on
(`e28156442704fcad95f7622c7a0537f90bfd3735c7ed56279cec1e51591c2fa9`), so the run
transfers to the merged commit instead of being re-argued, and the official gate
re-run under the new pin is **set-identical** to `gate-NEW.tsv`, 0/0 on both
columns. CI is green on the PR head **and** on the merged commit, and both were
checked — cc370#375 was merged with a red gcc job because `gh pr checks` was never
run.

## Why this one needed the tree-wide run more than most

`cmplmd370` is this project's verdict instrument: **recovered** is defined as it
exiting 0, and every figure in the README scoreboard rests on that. The defect is
in how it reads a bound member's RLD information, and a desynchronised RLD parse
leaves a relocated field unmasked. **An unmasked relocated field reads as an
ordinary text difference** — so the defect is a mechanism for calling an identical
module `differs`, in the one tool whose answer the project treats as final.

It is also quiet in the way that matters: it only ever *loses* RLD items, never
invents them, and a lost address constant round-trips through `DC X'..'` to its
own bytes. cc370's own suites stayed green over it for as long as it existed.

## The defect

A control record carrying both an ID/length list and RLD information holds the
**RLD information first and the list after it**. Both `cmplmd370` and `dasm370`
computed the RLD offset as `16 + idlen`, so the parse began on the first item's
flag and address, took them for an R/P pair, and desynchronised from there.

`docs/load-module-format.md` §4 put the list at offset 16 unconditionally. That is
right for every record carrying no RLD information (`X'01'`, `X'05'`, `X'0D'`),
which is exactly the case where the two orders produce identical bytes. **Both
tools were reimplemented from the prose, which is how they got the same bug.**

## The diagnosis, verified here before the PR existed

[`tools/ctlorder.py`](../../../tools/ctlorder.py) walks our own member images and
applies the loader's own arbiter: bytes 14–15 are the CCW count, the number of
text bytes the loader is about to read, and the ID/length list's lengths must sum
to it. A closed check on a single record — no reference module, no second tool, no
assumption about what an RLD item means.

```
7,748 of 7,749 members walked        802 carry such a record
  1,668  records with both lists
  1,668  agree with the list AFTER the RLD info
      0  agree with the list AT OFFSET 16
```

The one member that does not walk is named and not swallowed: `HEWLF064`, the
linkage editor, reads 33 records and then has 28 bytes that are not a record —
`cmplmd370`'s own `trailing_bytes`. It carries none of the records counted here.

The cc370 session's independent census over a larger population — 13,102 members,
1,339 carriers, **2,489 records, 2,489 after-RLD, 0 at-offset-16** — agrees. Their
first figure was 2,488; they corrected it themselves before it was compared,
having used `X'04'` as the module-end bit where `X'08'` is right. **An undercount
of a 2,488-to-0 result reads exactly as convincing as the true one**, and it was
found by a fixture that needed the bit, not by anything looking wrong.

## Controls

| control | result |
|---|---|
| build from the PR's **parent** (`057ab3f`) against the pinned binary | **byte-identical**, `8e73a789…9065a45` — the whole delta is this PR |
| the pinned run against the published `overlay-vs-both.tsv` | **set-identical**, 0/0 both columns, `chosen` 1,626 either way |
| null control, the 30 `dasm370` control CSECTs, both binaries | 27 identical / 3 differing, **before and after, none moved** |
| CI on `9233d0f` | green, clang **and** gcc |
| **direction control** | the fix can only mask *more* bytes as relocated, so `identical → differs` refutes the diagnosis on a single module — **zero of them** |
| moved modules whose member carries no such record | **none** — both carriers, 2 such records each |

The parent-build control is the strongest form this can take: it is not that the
parent measures the same, it is that the parent **is** the pinned binary, so no
second run is needed to attribute the delta.

## The measurement

```
5,353 CSECTs, chosen baseline, obj_sysparm1 decks, one comparator changed

  dlib_c      set-identical, no transitions
  tgt_c       differs -> identical    2    IEAVTSL2, IEAVTSLS
              identical -> differs    0

  recovered   1,626 -> 1,628      (+2 / -0 as SETS)
  explained   1,719 -> 1,721
  disagree       57 ->    55      (DLIB and target now agree about two more)
```

Both moved modules live in `LPALIB(IEAVTSLP)`, whose member carries 2 control
records with both lists — 2 of 2 agreeing with the after-RLD reading.

## What it does not say

**+2 is small, and the reason is measured rather than reasoned.** The first
version of this passage said *"the defect could only hide a difference that was
entirely a relocated field, so a module it could rescue had to be otherwise
already right — rare in this corpus by construction."* The second half is wrong.
**2,170 modules have a target member carrying such a record** — exposure is not
rare at all — and 665 of them (30.6 %) were already `identical`, which is the
corpus rate of 32.7 % to within noise. So the defect was in play for **1,505
modules that were not identical, and it was the whole story for 2 of them:
0.13 %.** What is rare is not the exposure but the module whose *only* remaining
difference is an unmasked relocated field.

The number that mattered was the one in the other direction, and it is zero.

The attribution maps (`reachable.tsv`, `alignfill.tsv`, `macroattr.tsv`,
`lenattr.tsv`) were cut under the old comparator and are **not** re-cut here; the
`explained` figure above uses them unchanged, so the +2 in it is the +2 in
`recovered` and nothing else.
