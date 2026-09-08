# The remaining 690 — where they are and what each block needs

2026-09-08, against merged cc370 `7bb7796`. **`as370` == IFOX00 on 4,831 of
5,528 (87.4 %)**, from 3,465 (62.7 %) this morning, across 46 merges with **no
identity lost**.

This is the map for the last 12.6 %.

## Where they are

| block | modules | status |
|---|---:|---|
| **length wrong, too short** | 200 | 123 of them carry a bit-length modifier — **cc370#240** |
| **length wrong, too long** | 121 | 77 by a multiple of eight — **cc370#241**, new |
| shape right, 9–64 bytes wrong | 83 | unattributed |
| shape right, ≤ 8 bytes wrong | 70 | the byte-histogram hunting ground |
| shape right, 65+ bytes wrong | 67 | unattributed |
| image identical, deck differs | 22 | **cc370#199**, seven signatures |
| different section set | 4 | unattributed |

**Two identified mechanisms account for 200 of the 690.** The rest is
unattributed, and that is the honest headline.

## The two named blocks

**#240 — a bit-length modifier reserves nothing.** `DC AL.12(1)` produces no
bytes and does not advance the location counter, so everything after it is early
by exactly what was never reserved. 123 modules carry the construct in their own
source, 85 of them are among the short ones, and `IFCE0155`'s instances are
macro-generated so a card scan under-counts. Rules pinned against the oracle;
lands in the `DC` emitter, which is the most identity-sensitive code there is.

**#241 — 121 modules generate more than IFOX00, 77 by a multiple of eight.**
Commonest deltas 16, 8, 40, 24, 32; 29 of 40 sampled diverge inside the first 64
bytes. Alignment is the reading and it is not yet confirmed by opening a module.

## Three instruments, and each found what the others could not

This is the method statement, and it is worth more than any single class.

| instrument | found this week |
|---|---|
| **byte histogram** over remaining divergences | `EQU C''''` → 0 (#238, +12) — a `0x7D → 0x00` pair |
| **source pairs** — two readers of one syntax | `dc_split` (#218), `expr_sect` (#215), `join_cont` (#183) |
| **length deficit** | the bit-length modifier (#240) — no *wrong* bytes at all, only absent ones |

The third is the one that matters for the remainder: **321 of the 690 are length
problems, and a byte comparison cannot see them as anything but noise.** A module
missing 400 bytes scores as 400 bytes wrong at every address after the gap, which
looks like catastrophe and is one construct.

## What the rate says

| merge | gain |
|---|---:|
| #175 absolute `EQU` section | +282 |
| #187 RLD length clobber | +160 |
| #231 `CNOP` | +57 |
| #191 absolute `USING` | +57 |
| #204 SS base | +47 |
| #198 `L'` of an `EQU` | +38 |
| … | |
| #238 `EQU C''''` | +12 |
| #237 `AIF` clamp | +9 |
| #213 CCW `*` | +7 |
| #188 third splitter | +2 |

**The wide-reach mechanisms are gone.** What is left yields tens, not hundreds,
per fix — except #240, which is the last block with three digits behind it.

## What "100 %" would require

Nothing structural forbids it: the goal is `as370` == IFOX00 on identical input,
and IFOX00's own return code does not enter into it. But two things will make the
tail expensive:

- **321 length problems** are each "material missing or extra", and the two named
  mechanisms will not cover all of them;
- **220 shape-right modules** have correct sizes and wrong content, which is
  where single-instruction defects live — small reach each.

The realistic sequence is **#240, then #241, then keep clustering the 220 from
the byte side** — and expect the last few hundred to cost one merge each.
