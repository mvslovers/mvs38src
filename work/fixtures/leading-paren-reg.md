# A register operand that begins with a grouping parenthesis

The control for cc370#350, and for the family it belongs to — #247 and #343 are
the same confusion at two other places in the code. **A leading parenthesis is a
group whose terms belong to the expression, not a subscript.**

`leading-paren-reg.s` holds six forms. Only the fourth may change; the other five
are what a fix to the fallback path must leave alone. Values from IFOX00 on
`MVSCE-LAB`, 2026-09-10:

| form | IFOX00 | before #350 | after |
|---|---|---|---|
| `LR 0,(3)` | `1803` | `1803` | `1803` |
| `LR 1,(A)` | `1813` | `1813` | `1813` |
| `LR 2,A` | `1823` | `1823` | `1823` |
| **`LR 3,(LINUM2+CTR)/TWO`** | **`1838`** | **`1830`** | **`1838`** |
| `LR 4,LINUM2+CTR/TWO` | `184c` | `184c` | `184c` |
| `LR 5,4` | `1854` | `1854` | `1854` |

`(8+8)/2` is 8, so register 8. Before the fix the operand merely *began* with a
parenthesis, the guard read it as a subscript, and it silently named register 0.

`LR 4` is the sharp neighbour: without the leading parenthesis, `8+8/2` is 12,
and it must stay 12.
