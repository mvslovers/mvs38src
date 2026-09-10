# The four that were blocking the build — found 2026-09-09

`IECPDSCB`, `BTMHJN`, `BTMIOBWA` and `$ASXB` blocked SYSMODs `EDM1102`,
`EBT1102` and `EJE1103`, and through them **599 load modules and every
maintenance job** in Dave Kreiss' chain. `docs/dave-install-log.md` has that
causal chain.

| macro | taken from | also seen at |
|---|---|---|
| `IECPDSCB` | `mvs38-ibmsrc/macros/maclib/IECPDSCB.asm` — **here all along** | 4 public copies, all the same MVS 3.8 level once sequence numbers are stripped |
| `$ASXB` | `mvs38-ibmsrc/macros/hasp/$ASXB.asm` — **here all along** | `moshix/tk4`, `mainframed/mvs38_sources` |
| `BTMHJN` | `moshix/MVS38j.SYS1.MACLIB` | `moshix/tk4`'s AMACLIB extract — **do not use that one, see below** |
| `BTMIOBWA` | `moshix/MVS38j.SYS1.MACLIB` | `moshix/tk4` (sequence numbers and change markers stripped) |

## Two of the four were on this machine, and I had reported all four missing

The search that produced *"nowhere reachable"* used exact names with no
extension — `-name '$ASXB'` does not match `$ASXB.asm` — over a scope that left
out `/Users/mike/repos/MVSSRC` entirely, **and ran no control**. It is the rule
this project keeps writing down and it was mine to break: *a zero result is a
claim about the instrument until a known positive proves otherwise.* The re-search
began with `IHADCB`, which is certainly present, and found two of the four in the
first pass.

## Where each one goes, from the SYSMOD rather than from IBM's directory

```
++MAC( $ASXB    ) TXLIB(OHASPSRC)                  DISTLIB(HASPSRC )
++MAC( BTMHJN   ) TXLIB(OMACLIB ) SYSLIB(MACLIB  ) DISTLIB(AMACLIB ) .
++MAC( BTMIOBWA ) TXLIB(OMACLIB ) SYSLIB(MACLIB  ) DISTLIB(AMACLIB ) .
++MAC( IECPDSCB ) TXLIB(OMACLIB ) SYSLIB(MACLIB  ) DISTLIB(AMACLIB ) .
```

Three to `SYS1.AMACLIB`, one to `SYS1.HASPSRC`. IBM's Program Directory had
already suggested `$ASXB` belonged in HASPSRC rather than a macro library; the
SYSMOD says it outright, and the SYSMOD is what SMP will read.

Installed on `MVSCE-LAB` 2026-09-09, each read back and compared over columns
1–72. Before-state in `work/measurements/groupa-adoption/` — `SYS1.AMACLIB` had
566 members, `SYS1.HASPSRC` 199.

## A corrupted mirror, checked rather than assumed

`moshix/tk4`'s AMACLIB extract has `BTMHJN` with every PL/S `||` concatenation
operator replaced by a stray `0xD7`, and the file typed as ISO-8859 rather than
ASCII. **The copy used here is from `moshix/MVS38j.SYS1.MACLIB` and was verified
clean**: no byte above 127, four intact `||` pairs, zero `0xD7`. Checked after the
upload rather than trusted, because "I used the other mirror" is not evidence.

## BTMHJN began life as TCAM's IEDHJN

Its own change activity says so:

```
TOOK MACRO IEDHJN FROM TCAM AND NAMED TO BTMHJN                @OY36208
REMOVED ALL REFERENCES TO TCAM, TCAM APARS, AND COMMENT LINES
THAT DO NOT APPLY TO BTAM                                      @OY42916
```

So calling it a TCAM macro was wrong for its identity and right about its
ancestry. Worth keeping: the correction stands, and the original mistake was not
baseless.

## Still missing: the eight EREP names

`LINEND CONVT HEX SUMMARY PROLOG FREETAB ETEPILOG ENTRIES` were not found on any
code host. What did come back is that they are real, that their call syntax is
now captured verbatim from ~190 call sites in the `IFCE*`/`IFCS*` family, and
that `EER1400` ships **no AMACLIB at all** — so they were probably never
`SYS1.MACLIB` members and live as `COPY` members inside the EREP source. Five
wrong same-named macros were found and rejected; the tally of wrong `PROLOG`s is
now eleven.

## The macros settled a disagreement between two searches

Two agents read IBM's BTAM cookbook and came back with different answers about
whether `BTMHJN` and `BTMIOBWA` carry maintenance: one, reading the PDF through
`pdftotext`, reported **no RMID** and concluded both were base-function; the
other, reading the same PDF page by page, reported `RMID(UY65386)` and
`RMID(UY85819)`.

**The macro text decides it and neither agent had looked there.** Ours carry
APAR markers in column 65:

```
BTMHJN     @OY36208  @OY42916
BTMIOBWA   @OY49630  @OY57753
```

Maintenance has been applied to both, so the RMID reading is the right one. The
PTF numbers themselves do not appear in the source — `RMID` is SMP's bookkeeping,
`@OYnnnnn` is the source-level flag — which is why the absence of `UY65386` in
the file is not evidence either way.

## `IECPDSCB` names its own FMID

The strongest provenance any of the four has, and it is inside the file:

```
.*$01=OZ74018,EDM1102,,FERJV: MAPPING MACRO OF PARTIAL DSCB       @01A*
```

`EDM1102` is exactly the SYSMOD that could not apply without it. After a `TABLE`
that was the wrong macro five times and a `PROLOG` that was wrong eleven, a macro
that cites the FMID it belongs to is a different quality of evidence.

## Group B: a fourth independent negative, and the grammar

All eight were found as **call sites** in `mainframe.eu`'s EREP folder, and a
`grep` for `^\s+MACRO\s*$` across all **192** members of that folder found **no
definition of any of them**. That is now four independent archives — Jay Moseley's
tape, `moshix/osvs2src`, `mainframe.eu`, and this machine — agreeing that the
`IFCE*`/`IFCS*` family calls these macros and none of them carries the source.

The call grammar, captured verbatim, which is what a found definition will have to
match:

| macro | how it is called |
|---|---|
| `PROLOG` | `PROLOG NAME=IFCE0125` — **always** `NAME=`, never bare |
| `SUMMARY` | `SUMMARY NAME=IFCS0115` — same shape, in the `IFCS*` half |
| `ETEPILOG` | `ETEPILOG RLEN=190`, `ETEPILOG NODUMP` |
| `CONVT` | `CONVT (IORETRY,2,5),(SIOCNT,4,8)` — field, offset, length |
| `HEX` | `HEX (DLOG20,0,4B),(DLOG21,B1,4B)` — same triples |
| `LINEND` `FREETAB` | bare, no operands |
| `ENTRIES` | `ENTRIES PAGE` |

**`PROLOG NAME=` is the discriminator.** Every wrong `PROLOG` found so far — and
there have been eleven — is a register-save prologue generator with no `NAME=`
keyword. A candidate that does not take `NAME=` is not this macro, and that can
be decided from the prototype line alone.

## The sharpest lead left

`UY65386` and `UY85819` are, per Jay Moseley's PTF cross-reference, contained in
`cumptfs.aws` — a cumulative-PTF AWS tape. A `++MAC` PTF carries the full macro
source, so that tape holds the BTAM pair at their applied level. Not needed now
that both are installed, but it is the shape of where the *eight* might also be:
**a PTF tape, not a macro library.**
