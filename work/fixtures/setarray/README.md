# SET-array fixtures — what must stay true after cc370#173

Five cases behind the finding that **a subscripted SET array costs one table
entry per assigned subscript** (cc370#173). Two of them assert things that must
remain true after any change to the SET store; three establish the defect itself.

Run each with the `as370` under test and no macro libraries:

```sh
as370 -o /dev/null <case>.s
```

| file | asserts | today (`88b0e54`, `MAXLSET` 512) |
|---|---|---|
| `arr-declare.s` | declaring `LCLB &SW(4000)` costs nothing | rc 0 |
| `arr-assign-400.s` | 400 distinct subscripts fit | rc 0 |
| **`arr-assign-600.s`** | **600 distinct subscripts** | **`local SET-symbol table full (512)`** |
| `no-duplicate-entries.s` | repeated assignment does not accumulate — 5,000 `SETA`s to two symbols | rc 0 |
| `no-nested-leak.s` | an inner macro's locals do not leak outward — 20 locals, 60 nested invocations | rc 0 |

**The last two are the important ones.** They killed the two hypotheses that would
otherwise have been reached for — duplicates accumulating, and inner locals
leaking into the outer context — and that is why the entry-per-subscript reading
is a finding rather than a preference. They must keep passing whatever replaces
the store.

**`arr-assign-600.s` is the regression test that a fix is real rather than a
raised bound.** If the storage model changes so that an array is one row holding
a vector, this passes at any `MAXLSET`. If the bound is merely raised, it passes
at 1,024 and a 2,000-subscript version fails — so re-run it with the subscript
count above whatever the new bound is.
