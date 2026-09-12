# Not finished, and why — repaired source that does not yet meet the criterion

`src/` holds source that assembles **byte-identical to its TK5
distribution-library member**; `tools/srccheck.py` enforces it. These three did
not, and each for a different reason. They are kept because each is a measured
result, not because they are close.

| module | archive → TK5 | this text → TK5 | this text → MVS/CE |
|---|---|---|---|
| `ACMDLIB/IKJEHREN` | text 1, holes 6 | **text 0**, holes 6 | text 37 |
| `AOSC5/IDA019S4` | text 5 | **text 0**, length differs | **identical** |
| `AOST4/IKJRBBCM` | **identical** | text 3 | **identical** |

## `IKJEHREN` — progress, not completion

The stamp `DC C' UZ45173 08/27/85'` was one character short; the missing one is
`'0'`, established by assembling three candidates against the object
([`../../docs/tso-and-smp.md`](../../docs/tso-and-smp.md)). That closes the
single differing text byte and the first CSECT becomes identical. **Six hole
bytes remain in `IKJEHRN2` and `IKJEHRN4`** and [`ds-holes.md`](../../docs/ds-holes.md)
established those are real defects, so the module is not finished.

## `IDA019S4` — content right, length wrong

After the repair, **zero differing text bytes against TK5** and a section length
that still differs. Content and length are separate problems and this one has
only the first solved. Note it is *identical* against MVS/CE, so the repair was
almost certainly made against that baseline.

## `IKJRBBCM` — repaired against the wrong object

`IKJ56589I` → `IKJ55083I`. **Identical against MVS/CE and 3 bytes from TK5**,
while Dave's archive text is identical against TK5. The repair was correct when
it was made and the baseline moved underneath it on 2026-09-10.

The change is line 49 of 54, a message table:

```
archive  M20D0    IKJTSMSG  ('IKJ56589I BROADCAST DATA SET INITIALIZED AND SYNCHX
ours     M20D0    IKJTSMSG  ('IKJ55083I BROADCAST DATA SET INITIALIZED AND SYNCHX
```

Its neighbours are `IKJ55081I`, `IKJ55082I`, then this one, then `IKJ56593I`.
Dave's `IKJ56589I` breaks the local run where `IKJ55083I` would continue it, so
the change looks exactly like the repair of a transcription slip. **It is not
one.** The two systems carry different numbers here: TK5's object says
`IKJ56589I`, MVS/CE's says `IKJ55083I`, and the three differing bytes are
`6`/`5`, `5`/`0`, `9`/`3`.

**And this module is one of the seven that chose the baseline.**
[`../../docs/deck-vs-tk5-ce.md`](../../docs/deck-vs-tk5-ce.md) names it in the
table *"Dave's source is byte-identical to a maintained object the other system
does not carry at all"* — seven on TK5, zero the other way, which is the lineage
argument for TK5 stated as a measurement. So the repair moved the *evidence for
the decision* toward the rejected baseline.

**It is not a candidate for `src/` at all**: the archive already satisfies the
criterion, so `IKJRBBCM` is recovered and always was. Nothing needs to change
for it to count.

**Kept rather than deleted**, and not out of caution — the variant is itself a
measurement. It establishes that MVS/CE's object carries `IKJ55083I` where TK5's
carries `IKJ56589I`, which is a fact about the two systems worth having written
down with the bytes that prove it.
