# Which of the no-source CSECTs can be disassembled and read — 2026-09-17

`work/measurements/reach/triage-trustworthy.tsv` — **104 of the 649** CSECTs with
no source, holding **68,374 code bytes**, where `dasm370`'s traversal reaches
**90 % or more** of what its own decoder called code.

This is what `cc370#406` is for on this side. The applied form of reachability is
held ([`CENSUS-772.md`](CENSUS-772.md)); the **report** is usable today, and this
is the use.

```
families   IKJ 32   IGC 16   IEH 8   IEA 6   IED 6   IEF 5   AMD 4   HEW 4
median     text_frac 0.14      section length 444 bytes
largest    IEHLISTD 4,716 code bytes (SELF 93.5 %)   HEWLRELO 3,946 (92.8 %)
           IEFSD061 2,834 (98.7 %)                   IKJEGFLT 2,290 (93.9 %)
```

## ⚠️ What a high `SELF` does and does not say

**It says**: the traversal, from the code roots and the two base assumptions,
arrives at nearly every byte the decoder treated as an instruction. So the
disassembly is not one where the walk lost its base at the first branch and the
rest is decode-by-position.

**It does not say the disassembly is right.** Nothing here checks the base
registers, the code/data split, or the labels. The 30 control CSECTs — which have
source, and where all of that *can* be checked — are the evidence for how much
else can still be wrong, and it is not small. `SELF` is a **necessary** condition
for reading a disassembly, not a sufficient one.

**And the 545 below 90 % are not condemned.** A module at 40 % may be perfectly
disassemblable with a hint file naming its base; `SELF` measures what the
traversal found unaided. The list is a place to start, not a verdict on the rest.

## How it was built

```
tools/reachcensus.py --binary <dasm370 with --reach-report>
```

over `reachgate.corpus("nosource")`, which resolves the load module through Dave
Kreiss' `LMDXRF` cross-reference. `SELF` is `reached ∩ code / code`, where `code`
is what the disassembly called an instruction **without** reachability — the
denominator that needs no source, named in `dasm370`'s own man page since
`cc370#407`.
