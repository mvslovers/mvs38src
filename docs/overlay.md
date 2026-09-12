# Nothing measured our own repairs, and the first run that did found a regression

2026-09-12. `src/` holds the recovered source — 37 modules, including the ten
the `^`/`¬` code-page substitution recovered, which the documents credit as
*"recovered 902 -> 912"*.

**Not one of them was on any measured path.** `gate.sh` assembles
`MVSSRC/.../MVSBLD`, the archive; a grep of `tools/` finds no reader of `src/` at
all. So a repair could rot, or be made against the wrong reference, and no run
would say so.

`tools/overlay.py` closes that: a symlink tree where `src/` shadows the archive
and the archive fills in the rest, for `gate.sh`'s `SRC_TREE`. It also links the
**ten modules that are in `src/` and in no archive** — the seven `HASP*` and
three `XTB1G*` off Dave's install tape — so the tree is 5,538 rather than 5,528.
A module nobody assembles is a module whose recovery nobody can check.

## What the repairs are worth

Same binary, same macro path, same pinned stamp, TK5 as the baseline:

| | archive | **overlay** |
|---|---:|---:|
| `rc 0` | 4,576 of 5,528 | **4,590 of 5,538** |
| byte-identical to TK5's object | 1,221 | **1,254** |
| identical or holes-only | 1,798 | 1,832 |

**+34 gained, 1 lost, net +33.**

```
GENRMT HASPBLKS HASPFMT0..FMT5 HMASMVLU ICKTSAN0 ICKTSTP0 IDCTSTP0
IEAVTABI IEBFDANL IFCSCHAR IGCT010E IGFPINIT IGG08116 IGG1PN IGG1QN
IGG1QNC IGG1SN IGG2G11 IGG2P11 IGG3PN IGG3QN IGG3QNC IGG3TN ILRSRT
ILRSRT01 SYS3CNVT XTB1GFC XTB1GSC XTB1GUC
```

And `IKJEHREN` moves `differs` → `holes`, as [`tso-and-smp.md`](tso-and-smp.md)
predicted it would.

## The one that was lost, and it explains itself completely

**`IKJRBBCM`.** Measured both source versions against both object baselines:

| source | against **TK5** | against MVS/CE |
|---|---|---|
| archive (Dave's) | **identical** | 3 bytes differ |
| `src/AOST4/IKJRBBCM.ASM` (ours) | 3 bytes differ | **identical** |

Perfectly symmetric. The repair changed a message number —
`IKJ56589I` → `IKJ55083I` — and it is **correct against MVS/CE and wrong against
TK5.** It was made against the baseline this project superseded on 2026-09-10
([`fahrplan.md`](fahrplan.md) §1), and against the chosen one **Dave's archive
text was already right.**

Nothing was wrong with the repair when it was made. What was wrong is that the
baseline moved and nothing re-checked the repairs, because nothing read `src/`.

### That is not a decision this file takes

The measured answer is unambiguous — `cmplmd370` exits 0 on the archive text and
not on ours — so by this project's one rule the archive version is the recovered
one. **But reverting it retracts another session's recorded recovery**, and the
message number may have been changed for a reason that is not byte-identity. The
file is left as it is, the measurement is on this page, and the call is Mike's.

### What it costs to leave it

One module, and the overlay figure already accounts for it: +34 −1 = +33.

## The two figures are both wanted

The archive measurement says **how far Dave Kreiss got**: 1,221 of 5,353.
The overlay says **where the project is**: 1,254. Neither replaces the other, and
the scoreboard quotes the archive one because that is the inherited state — the
overlay is the answer to a different question and now has a number for the first
time.
