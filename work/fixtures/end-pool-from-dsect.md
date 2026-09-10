# The END pool when the resuming CSECT card falls inside a DSECT

The control for cc370#357, and the companion to
[`end-pool-after-resume.md`](end-pool-after-resume.md).

`pool_reserve()` took `lc` — whatever location counter happened to be current
when the pool was reserved. With **one** named section the reservation falls at
the very end, and if a `DSECT` is current there, the pool lands on the DSECT's
counter and the section comes out as long as the DSECT.

```
ONESECT  CSECT
         L     1,=F'7'
         DS    XL8
DPRC     DSECT
         DS    XL256
         CSECT
         TRT   0(2,1),0(1)
         END
```

IFOX00 on `MVSCE-LAB`, 2026-09-10:

| | `ONESECT` length | unnamed section origin |
|---|--:|---|
| IFOX00 | **20** | **`0x0018`** |
| before #357 | 260 | `0x0108` |
| after | **20** | **`0x0018`** |

260 is 256 (`DPRC`) plus 4. That is the whole defect in one number.

**Why five earlier fixtures missed it** (cc370#349): they varied the resumption —
named, unnamed, with a bare `ORG`, inside a macro, all four together — and none
of them had a **literal pool**, nor `IFDOLT39`'s single named section. With two
named sections the reservation happens early, from the right counter, and
nothing goes wrong: `end-pool-after-resume.s` is exactly that case and it must
stay unchanged.

And the reason the five looked right: **the resumption is in a macro expansion,
not in the source.** The module reads as one shape and assembles as another.
