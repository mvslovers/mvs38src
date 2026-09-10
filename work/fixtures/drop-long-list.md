# A DROP with more registers than the parser took

The control for cc370#353, where the `DROP` operand list was split into four
fields and everything past the fourth stayed registered.

**The first version of this fixture did not discriminate.** `DROP 1,2,3,4,5,6,7`
under `USING`s 1 through 8 gives base 8 either way: with the truncation 5, 6, 7
survive, without it none do, and the highest remaining register is 8 in both
cases. Five test points, all three columns equal — which reads as a passing
control and measured nothing.

What discriminates is `IGC0001F`'s own shape: **the high registers late in the
list**, so the truncation is what keeps them alive.

```
         USING MYD,2 / 3 / 5 / 7 / 8 / 12 / 15
         L     0,FLD
         DROP  3,5,7,8,12,15
         L     0,FLD
```

IFOX00 on `MVSCE-LAB`, 2026-09-10:

| | IFOX00 | before #353 | after |
|---|---|---|---|
| `L` before the DROP | `5800f000` | `5800f000` | `5800f000` |
| `L` after `DROP 3,5,7,8,12,15` | **`58002000`** | **`5800f000`** | **`58002000`** |

With the truncation 12 and 15 survive and 15 wins the tie — the four bytes in
`IGC0001F`. The line above it is the counter-control: base 15 before the DROP,
unchanged, so the tie-break rule (#138, highest register wins) is untouched.

**A fixture the oracle rejects is not a reference.** cc370's first attempt
dropped registers with no active `USING`; IFOX00 answered `IFO195 INVALID USING
OR DROP STATEMENT` at rc 12, and the bytes from that failed run read as base 15
— the opposite of the right answer, and it would have looked like the fix was
refuted. The run behind the table above asserts on the return code first.
