# How large is the `DS 0F` / `DS CL1` ambiguity — 2026-09-17

`cc370#385` specifies a repair contract with five fields per divergence. Three of
them are **listing facts with no machine-readable export**, and the sharpest is
whether a statement **reserves** bytes (`DS CL1`) or only **aligns** (`DS 0F`) —
because in an object both are uncovered bytes, and getting it backwards decides
replace against insert.

The cc370 session says the distinction is a **source fact and not an object fact**.
This measures how much of the population it touches, over the 30 control CSECTs
where there is real source.

## Two object-side signatures, and they disagree by a factor of twenty

```
gaps with NO object code, across the 30:  13,161 bytes

signature A -- the gap follows an explicit zero-duplication DS (0F/0D/0H)
     alignment       89 bytes in    32 gaps     1 %
     reservation 13,072 bytes in 1,960 gaps

signature B -- the gap is SMALLER than the alignment it ends on
     alignment    1,788 bytes in   839 gaps    14 %
     reservation 10,990 bytes in 1,134 gaps
```

**Both are defensible and they differ twentyfold.** A implicitly requires the
padding to have been written as a `DS 0F`, and misses alignment the assembler
inserted on its own. B counts any short gap ending on a boundary, and a `DS CL1`
sitting just before an aligned statement is indistinguishable from padding by that
test.

🔑 **The disagreement is the finding.** Two reasonable object-side methods cannot
agree on the size of the population, which is what *"the distinction is a source
fact"* means when it is measured rather than asserted. **This side cannot separate
them either.**

## What that bounds

The ambiguous population is **between 1 % and 14 % of uncovered bytes**, and
uncovered bytes are about 15 % of section bytes — so **roughly 0.2 % to 2 % of the
corpus**. Real, and not the largest thing in the contract.

## And one cost of the object-side shape is OURS to remove

The cc370 session's objection to shape 2 is that `macroattr.py`'s `owner()`
returns the nearest emitting statement at or below an address, so padding is
attributed to whatever precedes it. **That is true, and it is the identical defect
already fixed once in this repository** — `alignfill.py` gained an arithmetic guard
on 2026-09-16 because one `DC 0D'0'` was owning clusters of 52, 14 and 33 bytes in
`IEBWSAM`; the fix moved 49 modules to 44 and `explained` from 1,724 to 1,719.

So *"shape 2 ships the known-bad attribution on your side"* is accurate about today
and not about what today has to stay. Fixing `owner()` the same way is our work,
has a worked precedent, and does not need anything from `dasm370`.
