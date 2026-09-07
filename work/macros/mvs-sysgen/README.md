# `mvs-sysgen/` — macros out of the MVS-sysgen SOFTWARE collection

**Kept for the record, not in use.** And kept as the record of a verdict this
session had to correct twice.

| Macro | Source | Verdict |
|---|---|---|
| `ISDAFSPC` | [MVS-sysgen/SOFTWARE, `PVTMACS/macros/ISDAFSPC.MAC`](https://raw.githubusercontent.com/MVS-sysgen/SOFTWARE/4c35feacee951943adbc38aa8c05888fca741372/PVTMACS/macros/ISDAFSPC.MAC) | **genuine, and empty on purpose** |

## What it is

Three cards: `MACRO`, the prototype `ISDAFSPC &OP,&LV=,&A=`, `MEND`. It generates
nothing.

## What was measured

`ISDAAPR0` calls it twice, as `ISDAFSPC R,LV=(0),A=(1)`. Against IBM's shipped
object:

| | Diagnostics | Section |
|---|---:|---|
| without it | 2 | 2,191 B against IBM's 2,217 |
| with it | 0 | 2,191 B against IBM's 2,217 |

It silences the diagnostic and the object stays **26 bytes short**.

## What I concluded, and why it was wrong

I read that as a placeholder someone had written to get assemblies through,
called it measurably harmful and rejected it — the reasoning being that it would
earn `rc 0` from Assembler XF and hand us a clean reference deck for code that is
not there.

**IBM's own distribution tape carries `ISDAFSPC` as the same three cards.**
`sym7/FILE0001`, SSI 42480224 — and the tape copy has IBM's own APAR marker
`@Y30LB55` in column 65. An empty macro with a change-level marker on it is
neither an accident nor a forgery: it is a placeholder for a function this
edition does not build.

So the 27 modules that call it are *supposed* to generate nothing there, and
`ISDAAPR0`'s 26 missing bytes have another cause entirely. That one is still
open.

## What survives

- A macro is usable when its expansion is right, not when the assembly falls
  silent. That rule stands, and it is why the measurement was taken at all.
- **"Generates nothing" does not imply "not genuine."** The shape of a macro says
  nothing about where it came from. Only the tape could settle it, and it took
  the `mvssrc-20` session to look.

Corrected 2026-09-07. The APAR-marker reading is theirs.
