# IGC018 — the identity the 2026-09-10 gate lost is a macro, not an assembler

Measured at `origin/main` = `fd287d3` (#357), one binary, two macro paths.

    base   (promoted baseline, f1cec11 = #344, pre-amaclib-live path)  5418 / 5528
    old    (fd287d3, SAME macro path as the baseline)                  5427 / 5528
    new    (fd287d3, current gate.sh with amaclib-live first)          5426 / 5528

    code effect   base -> old : +9,  none lost
    macro effect  old  -> new : +0,  -1  (IGC018)

So the 2026-09-10 code is a clean **+9 with no regression**. The one lost
identity is produced by `mvs38src` commit `25679ba`, which put
`work/macros/amaclib-live` at the head of the `-I` path.

## The mechanism

`IGC018` codes `LH R0,DVCBPSEC` (line 1693) and `LH R15,DVCBPSEC` (line 1719).

    as370  000BFA  0000 0000     ERROR: Undefined symbol - DVCBPSEC
    IFOX00 000BFA  48F0 9012

`DVCBPSEC` comes from `IHADVCT`, and the two copies on the path are different
maintenance levels:

    macros/mirror/IHADVCT        203 lines, defines DVCBPSEC  (APAR @ZA40405)
    macros/amaclib-live/IHADVCT  196 lines, does NOT define it

`amaclib-live` now wins the search, so as370 assembles against the older macro
and correctly reports the symbol undefined. **as370 is right on the input it is
given.**

## What it means for the gate

`amaclib-live/README.md` argues the six members were read from the live
`MVSCE-LAB` library, that `SYS1.AMACLIB` is first in the oracle's SYSLIB, and
that the oracle therefore "resolved these six out of it". For `IHADVCT` the
reference deck contradicts that: `48F0 9012` can only come from the
`@ZA40405`-level macro, and the live copy is not at that level. So either the
live library changed after the 2026-09-07 IFOX00 run, or the oracle resolved
`IHADVCT` from somewhere else in the concatenation.

Until that is settled, the honest parity figure at `fd287d3` is **5,427 of
5,528 on the baseline's macro path, 5,426 on the current one**, and the whole
difference is this one member. It is a question for the macro inventory, not
for as370 — and it is a second instance of the rule `gate.sh` already states:
whatever is added must be the same on both sides.

## Return codes at the same commit

    return code agrees   5524 / 5528
    as370 alone flags       0
    IFOX00 alone flags      4
    deck AND rc both     5425

## Re-derived for #140 at the same commit

`as370 alone flags` is **0**. `IFOX00 alone flags` is **5**, four of them at
severity 8 and one at 4:

    IBCDASDI   as370 rc 0   IFOX00 rc 8
    IBCDMPRS   as370 rc 0   IFOX00 rc 8
    IEAVEXS    as370 rc 0   IFOX00 rc 8
    IEAVRTI0   as370 rc 0   IFOX00 rc 8
    BLSR3270   as370 rc 0   IFOX00 rc 4

So #140's headline count of four is still exactly right at `fd287d3`, and the
fifth is the severity-4 `BLSR3270` the issue thread already knows about.
