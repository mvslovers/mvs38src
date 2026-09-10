# The six members `mvsce-2.1.4-dlib/AMACLIB` is short of

2026-09-10. The local copy of `SYS1.AMACLIB` has 566 members; the live library on
`MVSCE-LAB` has 572. These are the six, read from the live library.

```
BTMHJN  BTMIOBWA  IECPDSCB  IEZCTGPL  IHADECB  IHADVCT
```

**They matter because `SYS1.AMACLIB` is the FIRST library in the oracle's
SYSLIB concatenation.** The IFOX00 run that produced all 5,528 reference decks
resolved these six out of it. Locally `gate.sh` had `mirror` copies for three of
them and nothing at all for the other three, so `as370` and the oracle were being
given different macro input — the one asymmetry `gate.sh`'s own comment warns
about, carried since 2026-09-07.

They are kept in a directory of their own, ahead of everything else on the `-I`
path, so the provenance stays visible in the path instead of disappearing into
`mirror`.

See [`../../../docs/missing-macros.md`](../../../docs/missing-macros.md) — the
same six are what four agents spent a day hunting for in September, and they were
in `SYS1.AMACLIB` on our own systems the whole time.
