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
