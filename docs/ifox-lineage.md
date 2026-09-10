# Three Assembler XF lineages, and nobody has merged them

2026-09-10. Not needed to finish Dave Kreiss' build, and worth writing down
anyway: **there are three distinct lines of descent from IBM's Assembler XF in
this project's material, and no one has ever put them side by side.**

| | what it is | where it is |
|---|---|---|
| **1. IBM's XF** | the 1974 assembler plus IBM's own PTFs | the base of everything below |
| **2. Greg Price's `ZP60*`** | hobbyist USERMODs, applied on our running systems | `SYS1.SMPPTS` on both MVS/CE machines, 37 of them |
| **3. Paul Gorlinsky's source** | a 2007 reconstruction from PTF decks and disassembly, plus two changes of his own | `~/repos/mvs/ifox-src/ifoxdist.tgz`, via Jay Moseley |

The running assembler is **1 + part of 2**. Gorlinsky's tree is **1 at a later
maintenance level + his own**. Neither contains the other, and the source for a
merged assembler does not exist anywhere.

## The running one is not stock, and it took two instruments to be sure

`MVSCE-EXP` and `MVSCE-LAB` each carry 37 `ZP60*` USERMODs. Three name the
assembler in their own header:

```
ZP60003   /* XF ASSEMBLER */
ZP60022   /* SUPPORT FORMAT 1 STAX PLIST */
ZP60025   /* ADD BAS AND BASR TO ASSEMBLER XF */
```

`ZP60024` — raising the ESD limit — is in the family too, per the TK5 inventory
in [`tk5-ptfs-and-usermods.md`](tk5-ptfs-and-usermods.md).

**Being in `SMPPTS` only means received.** Asked whether they are *applied*, a
name lookup in `SYS1.SMPCDS` said "received only" for all three — and that is
wrong, because SMPCDS members are not named after the SYSMODs that create them.
The behavioural test settles it in five cards:

```
ZPTEST   CSECT
         USING ZPTEST,15
         BAS   14,TGT
TGT      BR    14
         END

IFOX00 on MVSCE-EXP:   000000 4DE0 F004    HIGHEST SEVERITY WAS 0
```

Stock XF has no `BAS`. **`ZP60025` is applied**, and
[`ifox-gorlinsky.md`](ifox-gorlinsky.md) had already found it from the other
end — three CSECTs of the running module carry `ZP60025` with translator date
`08/251`. Two independent instruments, the IDR stamps and the assembler's own
behaviour, agreeing.

## The two hobbyists solved one of the same problems, separately

**Both raise the ESD limit.** `ZP60024` does it as a USERMOD against the object;
Gorlinsky did it in source, 400 → 512 entries — and his memo, his README and his
own code state the new limit as three different numbers. Neither knew about the
other, and the two fixes have never been compared.

Gorlinsky's second private change, `M` accepted as a megabyte suffix on
`WORKSIZE`, has no counterpart in the `ZP60` family at all.

## Why this matters beyond curiosity

**Every figure this project quotes is against lineage 1 + 2.** `as370 == IFOX00`
has always meant *the IFOX00 on our system*, which is the right target — it is
what Dave's build uses and what produced the 5,528 reference decks. But:

- a figure from here is **not** comparable to one taken against a stock XF;
- `as370` implements `BAS` identically (`4d e0 f0 04 07 fe` on the same source),
  so it already matches an enhancement nobody had noticed it was matching;
- and **`as370` is arguably a fourth lineage** — a clean-room reimplementation
  measured against 1 + 2, which now agrees with it on 98.4 % of a 5,528-module
  corpus.

## What a merge would need, if anyone wanted one

Not proposed, only scoped:

1. **Establish what lineage 2 actually changes.** 37 usermods, three or four of
   which touch the assembler; only their SMP elements are here, not a narrative.
2. **Establish what lineage 3 is at.** `ifox-gorlinsky.md` did most of this —
   it is at a later IBM level than ours, and the delta is measured in both
   directions.
3. **Decide what the merged thing is for.** A source-buildable XF at the union of
   both would be a better *reference* than a load module nobody can rebuild — but
   it would no longer be the assembler that produced our reference decks, so
   adopting it means re-running the oracle for all 5,528.

That last point is the one that makes this a separate project rather than a task:
**changing the reference is not free, and this project has already paid that
price twice today** for nine EREP macros
([`erep-adoption.md`](erep-adoption.md)) — 64 reference decks replaced, and
identity moved by zero.

## Provenance

The `ZP60` question came from the `foo` session's TK5-vs-MVS/CE comparison, which
raised it as a caveat about TK5 and turned out to apply to our own systems. The
Gorlinsky measurement is [`ifox-gorlinsky.md`](ifox-gorlinsky.md). The
`BAS` test and the `SMPCDS` correction are from this session, 2026-09-10.
