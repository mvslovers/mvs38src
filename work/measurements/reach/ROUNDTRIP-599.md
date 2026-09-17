# The round trip passes on modules the traversal reaches 1 % of — 2026-09-17

`cc370#383` says reachability is conservative and therefore byte-safe and
therefore **invisible to the round trip**, and this repository has repeated that
all day as the reason the applied form had to be held. It had never been counted.

Every measured no-source CSECT, disassembled with `dasm370` from its bound member,
re-assembled with `as370`, and compared to the member with `cmplmd370`:

```
SELF >= 90 %   104 modules   identical 104
SELF 30-90 %    91 modules   identical  91
SELF <  30 %   404 modules   identical 403,  differing 1

total 599                    identical 598
```

**403 of the 404 modules the traversal reaches less than 30 % of — some of them
1.5 % — reproduce their own object byte for byte.** The round trip is not a weak
test of a disassembly's quality. **It is not a test of it at all**, and that is now
a number on this corpus rather than an argument.

It is also why the triage list ([`TRIAGE.md`](TRIAGE.md)) says what it says: a
module round-tripping tells a reader nothing, and `SELF` is the only thing that
separates a disassembly worth reading from one that is decode-by-position.

## The one that does not round-trip is a real case

`IFNX5M00` in `LINKLIB(IFOX51)`, 2,781 bytes, **two bytes at offset 2,588**:

```
disassembly   000A18  SVC   36            0A24
              000A1A  PTLB                B20D ....     <- the operand halfword
              000A1E  LPR   2,9           1029

member        B20D 28B2        our round trip   B20D 0000
```

`PTLB` is `S`-format: `B20D` plus a `D(B)` halfword the hardware ignores. The
member carries `28B2` there; `dasm370` emits `PTLB` with **no operand**, so
`as370` assembles `B20D 0000` and the two bytes are gone. Two lines above,
`STPT 1970(2)` is emitted **with** its operand — so the operand-less form is the
odd one, not the rule.

Sent to the cc370 session as a case, and fixed as `cc370#412`.

**It was `F_S0` — an S-format opcode with no operand — and `reencode_ok()` was
comparing the input with itself.** The check set bytes 0–1 from the opcode and
**left 2–3 as read**, so any tail passed. The rule it violates was already written
two lines above it in that source, for `IEAVTCR1`'s `SSM`: *the comparison must be
against what the statement assembles to, never against the bytes it was read
from.* The same defect, two bytes further out.

Gated here:

```
null control   745 runs, EXACTLY 1 moved -- and it is IFNX5M00
round trip     649 of 649 no-source sections identical
```

**One module changes, it is the one that was broken, and the exception in the
population is gone.** That is the sharpest shape a correction can take, and the
cc370 session's own "1 of 649 moves" is confirmed by running it rather than by
re-deriving their number.

Two things they found in themselves while building it, both worth more than the
fix. **The first version's guard sat in a branch that never runs** — an `F_S0`
opcode is two bytes wide, so the `opw == 2` arm claims it first: the binary
changed, the module still said `PTLB`, and no instrument objected. *A guard in a
branch that never runs is a guard that reports success.* And **the first fixture
could not fail**: the bad and good four bytes were adjacent, and a `DC` run
swallows sixteen, so the good `PTLB` went into the same `DC` and the control could
not fire. It needs an address constant between them to break the run.
