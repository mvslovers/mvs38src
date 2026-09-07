# `mvs-sysgen/` — macros out of the MVS-sysgen SOFTWARE collection

**Kept for the record, not in use.** What is here was measured and rejected.

| Macro | Source | Verdict |
|---|---|---|
| `ISDAFSPC` | [MVS-sysgen/SOFTWARE, `PVTMACS/macros/ISDAFSPC.MAC`](https://raw.githubusercontent.com/MVS-sysgen/SOFTWARE/4c35feacee951943adbc38aa8c05888fca741372/PVTMACS/macros/ISDAFSPC.MAC) | **genuine — my first verdict was wrong.** |

`ISDAFSPC.MAC` is three cards: `MACRO`, the prototype
`ISDAFSPC &OP,&LV=,&A=`, `MEND`. It generates nothing.

`ISDAAPR0` calls it twice, as `ISDAFSPC R,LV=(0),A=(1)` — a macro that is
expected to produce code. Measured against IBM's shipped object:

| | Diagnostics | Section |
|---|---:|---|
| without the stub | 2 | 2,191 B against IBM's 2,217 |
| **with the stub** | **0** | **2,191 B against IBM's 2,217** |

The stub silences the diagnostic and leaves the object **26 bytes short — 13
bytes for each of the two calls.** That is the worst possible outcome for this
project: Assembler XF would return `rc 0` and hand us a *clean reference deck for
code that is missing*, and every `as370` verdict measured against it would be
wrong in a way nothing else could see.

A macro is only usable here once its expansion is right, not once the assembly
falls silent.
