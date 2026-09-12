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

**It is not a candidate for `src/` at all** — the archive already satisfies the
criterion. It is kept here as the record of a retracted recovery, and because
the message number may have been changed for a reason that is not
byte-identity. Deciding that is Mike's, not this file's.
