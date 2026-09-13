# Not finished, and why — repaired source that does not yet meet the criterion

`src/` holds source that assembles **byte-identical to TK5's object**;
`tools/srccheck.py` enforces it. These did not, and each for a different reason.
They are kept because each is a measured result, not because they are close.

| module | archive → TK5 | this text → TK5 | this text → MVS/CE |
|---|---|---|---|
| `ACMDLIB/IKJEHREN` | text 1, holes 6 | **text 0**, holes 6 | text 37 |
| `AOSC5/IDA019S4` | text 5 | **text 0**, length differs | **identical** |
| `AOST4/IKJRBBCM` | **identical** | text 3 | **identical** |
| `AOST4/IKJEFF02` | see below | — | — |

## `IKJEFF02` — the module was recovered before anyone touched it

2026-09-13. One marked line, `DC X'F321'`, transcribed out of the DLIB member by
`fillgaps.py` under a guard that only ever asked the DLIB. Against the baseline
the project chose that same day — the **target** library, `LINKLIB(IKJEFF04)` —
**Dave's archive text is identical** and this text differs by 2 bytes.

So there was nothing to repair, and the repair is what broke it. Removing the file
is what recovers the module: the overlay falls back to the archive and
`cmplmd370` exits 0.

Third occurrence of the same shape, after `IKJRBBCM` here and `IKJEGMSG`, which
was rebuilt rather than removed because it needed one genuine line of the hundred
it had. [`../../docs/two-baselines-as-a-control.md`](../../docs/two-baselines-as-a-control.md)
is what the three of them are evidence for.

## `IKJEHREN` — progress, not completion

> **2026-09-13: the premise below is withdrawn.** TK5's target member holds
> `X'80'` at `0x23` where the DLIB holds `X'F0'`, and `X'80'` is not a printable
> character — so the byte is the pad byte of `BRID DC 0H'0'` and the stamp is not
> short at all. The measurement is intact, the reading of it was wrong. See
> [`../../docs/tso-and-smp.md`](../../docs/tso-and-smp.md) and
> [`../../docs/two-baselines-as-a-control.md`](../../docs/two-baselines-as-a-control.md).
> The six hole bytes in `IKJEHRN2`/`IKJEHRN4` are a separate matter and unaffected.

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

---

## `AOST4/IKJEFLLM` — one mechanism, and then the boundary

Added 2026-09-12. The second TSO case, one differing text byte, and it is a
better find than `IKJEHREN` because the table states its own rule.

### The rule is in the data

`IKJEFLLM` is a message-descriptor table: `AL2(length)`, `H'0'`, `CLn'text'`,
sometimes a `DS CL1`. Across all nine descriptors:

| | `AL2` | text | `AL2` − text |
|---|---:|---|---:|
| `STRTMSG1` | 11 | `CL7` | 4 |
| `STRTMSG2` `STRTMSG3` | 12 | `CL8` | 4 |
| `STRTMSG4` | 22 | `CL18` | 4 |
| **`STRTMSG5`** | **7** | **`CL3`** | **4** |
| `START1D` | 8 | `CL4` | 4 |
| `START2D` | 9 | `CL5` | 4 |
| `START3D` `START4D` | 10 | `CL6` | 4 |

**`AL2` = text + 4, nine times out of nine.** So `AL2(7)` with `CL3` obeys the
rule — Dave's arithmetic is not wrong. IBM's object has **8** at that offset,
which under the same rule means IBM's text was `CL4`.

And that predicts a second difference: with `CL4` the `DS CL1` filler at `0x49`
disappears, and IBM's object carries `X'40'` — a blank — exactly there. **One
change, two differences, and the second was predicted before it was checked.**

```
STRTMSG5 DC    AL2(8)
TEXT5    DC    CL4'    '        (was CL3'   ' plus DS CL1)
```

Measured: text `1 → 0`, holes `15 → 14`, section length unchanged at 516.

### And then it stops, which is the part worth writing down

The remaining 14 hole bytes are one mechanism and it is **not** the one above:

| | IBM's bytes |
|---|---|
| `0x02`, 6 bytes — the `@DATA DS 0H` prolog gap | `f0 16 10 c9 d2 d1` |
| `0x13` `0x5b` `0x7b` `0xc7` `0x103` `0x18b` `0x1e3` `0x1f5` — eight `DS CL1` | `f2` `a0` `f0` `e0` `f0` `68` `e0` `34` |

Controlled the way [`ds-holes.md`](../../docs/ds-holes.md) requires: **9 of 9
clusters carry identical bytes on TK5 and MVS/CE**, so they are real content and
not linkage-editor residue.

But `X'40'` at `0x49` was recoverable *because the table's own rule said what
belonged there*. `a0`, `e0`, `68`, `34` are not blanks, not printable, and no
rule in this module predicts them. They can only be obtained by **copying them
out of the object**.

**That is the boundary, and crossing it is a different activity.** A source line
reading `DC X'A0'` because the object has `A0` there reproduces the bytes and
recovers no meaning — it is disassembly wearing source clothes. Dave Kreiss
marked exactly this with `!!!`: *"a workaround that makes the object comparison
succeed"*, 16 modules of it. **Whether this project writes such lines is a
decision about what the deliverable is**, not a technique to be applied because
it works.

**Mike decided, the same day: option A, the way Dave does it.** So the bytes are
transcribed and marked, and `IKJEFLLM` is finished — it moved to
[`../../src/AOST4/IKJEFLLM.ASM`](../../src/AOST4/IKJEFLLM.ASM) and
`tools/srccheck.py` passes over it.

Dave's marker, copied exactly rather than reinvented: the text
`!!! SOURCE COMPARE FIX !!!` in **columns 46–71**, which is where he puts it in
`BLSVCVT2` and `AMDSYS06`. (`ICFBDF00`'s rows of `!!!` are IBM's own comment
banners and not a marker — worth checking before imitating.)

Nine lines carry it:

```
         DC    X'F01610C9D2D1'               !!! SOURCE COMPARE FIX !!!
         DC    X'F2'                         !!! SOURCE COMPARE FIX !!!
         DC    X'A0'                         !!! SOURCE COMPARE FIX !!!
         DC    X'F0'                         !!! SOURCE COMPARE FIX !!!
         DC    X'E0'                         !!! SOURCE COMPARE FIX !!!
         DC    X'F0'                         !!! SOURCE COMPARE FIX !!!
         DC    X'68'                         !!! SOURCE COMPARE FIX !!!
         DC    X'E0'                         !!! SOURCE COMPARE FIX !!!
         DC    X'34'                         !!! SOURCE COMPARE FIX !!!
```

**`verdict=identical`, text 0, holes 0, length 516/516.** The module is
recovered, and nine of its lines say plainly that a value in them came from the
object rather than from understanding. That is the deal option A makes, and the
marker is what keeps it honest: `grep '!!!'` finds every one.

### `IKJEHREN` is still here, and its holes are a different shape

Six bytes in three clusters, and they are **not** `DS CL1` fillers:

| section | offset | bytes | IBM |
|---|---|---:|---|
| `IKJEHRN2` | `0x04de` | 2 | `c5a0` |
| `IKJEHRN2` | `0x0fea` | 2 | `c2b4` |
| `IKJEHRN4` | `0x01b6` | 2 | `40c4` |

Confirmed against the deck's own TXT coverage: two 2-byte gaps mid-section in
`IKJEHRN2` (at load addresses `0x8d6` and `0x13e2`, section base `0x3f8`) and
one in `IKJEHRN4`. So they are alignment gaps inside code rather than declared
fillers, and the statement that produces each has not been located — the
listing's offsets are section-relative and the naive mapping put them on
instructions, which cannot be right for a byte the deck does not cover.

The recipe applies once the three statements are found. That is the next step on
this module, and it is locating them, not deciding anything.
