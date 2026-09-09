# The 699 nobody can see — silent divergences, ranked

> ⚠️ **The ranking below is against the state of 2026-09-08 and its counts are
> superseded.** The method — ask IBM's object which deck it agrees with — is the
> durable part; the populations are not.
>
> **Re-derived against cc370 `1112488`, distance 0 at writing**, from the promoted
> gate run `g323r`: the class is **36 modules** by the `signal()` reading, and it
> no longer has families — the largest cluster in it is **two**. It was 48 on
> `7a0cd90` and 1,113 on 2026-09-07. Split by the third opinion, on the 46 of the
> `7a0cd90` reading:
>
> | | modules | this page said |
> |---|---:|---:|
> | neither matches IBM | 26 | 464 |
> | no distribution member | 17 | 82 |
> | both match IBM | 2 | 27 |
> | **IFOX00 matches IBM, `as370` does not** | **1** — `IFCEA155` | 136 |
> | `as370` matches IBM, IFOX00 does not | 0 | 1 |
>
> **The sharp cell is down to one module.** The cell that "should have been
> empty" is down to two and the explanation below still stands for them: two decks
> can carry the same image and still differ.

2026-09-08. Of the 1,242 modules handed to cc370, **710 are silent divergences**:
both assemblers assemble without a word and the decks differ anyway. No
diagnostic points at any of them. They are the majority of the remaining work,
and they are the class that decides the question the project actually asks — an
assembler is dependable where nothing complains, or it is not dependable.

This document is how they were ranked and what fell out of the ranking.

## Ranking by a third opinion

Every module has an object in a distribution library, so IBM can be asked which
deck it agrees with. `tools/silent_split.py` does that; the table is
[`silent-split.tsv`](../work/measurements/ifox-run/silent-split.tsv).

| | Modules | |
|---|---:|---|
| **neither matches IBM** | 464 | still cc370's — at `rc 0` IFOX00 is the oracle — but no recovery behind it |
| **IFOX00 matches IBM, `as370` does not** | 136 | the sharpest cases: the reference is independently confirmed and a fix is an immediate recovery |
| no distribution member | 82 | cannot be settled by anyone |
| **both match IBM** | 27 | see below — this cell should be empty |
| `as370` matches IBM, IFOX00 does not | 1 | an anomaly in the oracle |

**The split ranks the list; it does not shrink it.** The hand-over rule is
`as370 != IFOX00`, and that does not stop being true because IBM's object is out
of reach as well. A figure that quietly loses rows stops being checkable.

## The cell that should have been empty, and what was behind it

27 modules came back as *both decks identical to IBM's object, and different from
each other*. That is impossible, so one of the three comparisons is answering a
different question — and it is `cmplmd370`, which rebuilds the loadable image.
**Two decks can carry the same image and still differ**, and every one of the 27
did.

Chasing it produced the largest single case still on the list.

## `RLD` flag byte: 173 modules, one bit

Classifying all 1,242 by *which card type* diverges:

| | Modules |
|---|---:|
| different card count | 437 |
| `TXT` only | 305 |
| **`RLD` only** | **173** |
| `ESD`+`RLD`+`TXT` | 127 |
| identical once the `END` card is excluded | 73 |
| `ESD`+`TXT` | 55 |
| `RLD`+`TXT` | 52 |
| `ESD` only | 7 |
| `ESD`+`RLD` | 4 |

**173 modules differ from IFOX00 in nothing but their relocation dictionary.**
Their `ESD` is identical, their `TXT` is identical, and the decks would be
byte-identical if the `RLD` agreed. Decoded entry by entry across all 173 —
847 entries, 175 of them differing:

| | Entries |
|---|---:|
| **the flag byte alone differs** | **163** |
| `R`/`P`/address differ as well | 12 |

and of those 163, every single one differs by **exactly one bit, `0x04`**:

| IFOX00 | `as370` | |
|---|---|---:|
| `0x18` | `0x1c` | 107 |
| `0x08` | `0x0c` | 44 |
| `0x1c` | `0x18` | 7 |
| `0x0c` | `0x08` | 4 |
| `0x09` | `0x0d` | 1 |

**And it is positional: 152 of the 163 are the last `RLD` entry in the deck**,
the rest the last but one or two. `0x04` is the low bit of the length field, so
the two assemblers disagree about the length of the address constant in the final
relocation item and agree about every item before it.

`IEAVELCR` is the whole case in three entries. Same `ESD`, same `TXT`, three
`RLD` items at `P=1` for `GLBRANCH`, `IEAVGWSA`, `GMBRANCH`:

```
IFOX00   0017 0001 18 000105   0018 0001 18 000109   0019 0001 18 00010d
as370    0017 0001 18 000105   0018 0001 18 000109   0019 0001 1c 00010d
```

Three identical constants, and only the last one is flagged differently.
**`as370` disagrees with itself, not just with IFOX00** — which is the argument
that this is one code site and not 173 source questions.

Filed as cc370#186 with [`rld-flag-cases.tsv`](../work/measurements/ifox-run/rld-flag-cases.tsv)
— one row per module, the entry counts, the flags, and whether the last entry
alone is affected. The class list is
[`classes/rld-flag.txt`](../work/measurements/ifox-run/classes/rld-flag.txt).

**Fixed in cc370#187: +160 identities, none lost, zero decks closer and zero
further.** The zero in both directions is the signature of a defect that was
never partial — each affected deck differed in exactly this one bit, so it moves
to identical or not at all.

The cause was the call idiom, not arithmetic. Every site wrote the width *after*
the call:

```c
add_reloc(lc, r, 1); rels[nrel - 1].len = blen;
```

`add_reloc` bails on `in_dsect`, so the write then lands on the **previous**
entry. `IEAVELCR` calls it 24 times for real and 138 times from dummy sections,
and the last real relocation was overwritten 138 times, keeping the width of the
final DSECT constant. That is the one bit, and it is why 152 of 163 were the last
entry: the clobber target is always `rels[nrel-1]`.

**Which assembler was right needed no oracle.** `IEAVELCR`'s table is `VL3`
constants; `as370` emitted length 3 for twenty-three of them and 4 for the last.
It disagreed with itself, so IFOX00 is right and nothing goes to
`ifox-objections.md`. *"It disagrees with itself"* was the load-bearing
observation — not *"IFOX00 is the oracle"*, which would have decided the same
question on authority rather than evidence.

`RLD`-only fell from 173 to **13**, the impossible cell from 27 to **1**.

And no diagnostic could ever have found it: both assemblers are silent by
construction, both decks load to the right image, and the difference survives
every instrument except a byte comparison of the deck.

## What the recovery figure does and does not say

`cmplmd370` compares the loadable image. So **"byte-identical to the object IBM
shipped" means the image is identical, not the deck** — a module counted as
recovered can still carry a relocation dictionary that differs from IBM's, and
some of the 1,015 do. That is not a retraction: the image is what runs, and it is
the right criterion for *this code is correct*. It is a limit on what the figure
proves, and it is written here because the 27 impossible cells are what exposed
it.

## How to re-run it

```sh
tools/silent_split.py            # the ranking; --all for every module
```

It needs `cmplmd370` on the path, the IFOX00 decks unpacked, and
`module-table.tsv` current — so it runs *after* the post-merge chain in
[`regression-gate.md`](regression-gate.md), never before.
