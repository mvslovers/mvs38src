# The END literal pool when a section is resumed and grows

The control for cc370#356. The pool is reserved when a **second** section opens;
a section **resumed** after that grows, and the pool has to move with it.

**The narrow case is the whole point.** cc370's first fix asked `sect_hwm`
whether the section had grown — and `pool_reserve()` raises that mark itself, so
a growth *smaller than the reserved pool* stays underneath it and looks like no
growth at all. That fix moved a loose fixture and left `AMDPRUIM` untouched:
green fixture, green suite, oracle-confirmed, and `+0 / 0 closer` from the gate.
The gate line was the only thing that disagreed.

So this fixture grows the resumed section by six bytes under a four-byte pool.
IFOX00 on `MVSCE-LAB`, 2026-09-10:

| | `POOLA` length | `POOLB` origin |
|---|--:|---|
| IFOX00 | **28** | **`0x0020`** |
| before #356 | 20 | `0x0018` |
| after | **28** | **`0x0020`** |

Both fields move and both match. A fixture that only grows the section by *more*
than the pool passes either way.
