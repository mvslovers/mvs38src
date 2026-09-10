# The floating-point RR opcodes, against their RX forms

The control for cc370#352, where `AWR` and `AUR` carried each other's opcode.

**The invariant the table proves out of itself:** a floating-point RR opcode is
its RX counterpart minus `0x40`. IFOX00 on `MVSCE-LAB`, 2026-09-10:

| | RR | RX | RX − RR |
|---|---|---|---|
| `ADR` / `AD` | `2a` | `6a` | `40` |
| `AER` / `AE` | `3a` | `7a` | `40` |
| **`AWR` / `AW`** | **`2e`** | `6e` | `40` |
| **`AUR` / `AU`** | **`3e`** | `7e` | `40` |
| `SWR` / `SW` | `2f` | `6f` | `40` |
| `SUR` / `SU` | `3f` | `7f` | `40` |

Before the fix `AWR` was `3e` and `AUR` was `2e` — the invariant held for four of
the six pairs and the two exceptions were the defect.

**Why the corpus could never have caught it.** `AWR` appears in one of the 5,528
modules; `AUR` in none. A swap is only visible from the side that gets used, and
nothing exercised the other side to contradict it. That is why this fixture
writes out all six pairs rather than the one guilty instruction: the oracle is
the only witness `AUR` has.

The mirror image of the same blind spot is `work/measurements/macro-bytes` — 158
macro members that differ between TK5 and MVS/CE and say nothing, because they
are present on both sides. Present-and-wrong is as invisible as never-called.
