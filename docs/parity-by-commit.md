# Parity, re-derived on this host — three commits, one macro path

Same measure the file already uses (deck body, END card excluded, `ASMTIME`
pinned), same macro path as the promoted baseline, so all three are comparable.

| commit | | identical to IFOX00 |
|---|---|---:|
| `b799ae0` | #306, the figure TODO.md records | **5,379** |
| `b67af3d` | #337, end of 2026-09-09 | **5,415** |
| `fd287d3` | #357, `origin/main` now | **5,427** |

`b799ae0` reproduces the recorded 5,379 exactly, which is what makes the other
two comparable to everything already written down.

- **2026-09-09, second half (#311…#337, twelve merges): +36, none lost.**
  Unrecorded in TODO.md — the day's close-out entry stops at #306.
- **2026-09-10 (#340…#357, thirteen merges): +12, none lost.**

On the *current* gate path (`amaclib-live` first) `fd287d3` measures 5,426; the
one-module difference is `IGC018` and it is a macro-level question, not an
assembler one — see [igc018-macro-path.md](igc018-macro-path.md).
