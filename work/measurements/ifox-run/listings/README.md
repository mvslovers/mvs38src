# IFOX00 listings — the oracle at statement level

Full `PARM=LIST` listings from `MVSCE-EXP`, captured module by module. **These are
the only IFOX00 listings that exist for these modules**, and a capture costs one
MVS round trip each.

| module | size | captured for |
|---|---:|---|
| `IEAVEXS` | 304 KB | cc370#241 — 4 bytes longer than IFOX00 |
| `IEAVESC0` | 506 KB | cc370#241 — 4 bytes longer |
| `IEAVITAS` | 407 KB | cc370#241 — 8 bytes longer |

`ifox-155.txt` beside this directory is a fourth, captured by cc370 for #205.

## Why they were captured

For a module that is *longer* than IFOX00's, the deck cannot say where the
surplus enters: the first differing byte is a displacement, so every later
displacement shifts with it and 4 surplus bytes read as 110 differing ones. cc370
searched for a split where `mine[:s] == ifox[:s]` and `mine[s+delta:] == ifox[s:]`
and **found no insertion point in any of the three** — the bytes after differ too.

A listing gives every statement its address, so the divergence point falls out of
a comparison instead of having to be searched for.

## Format, and the trap in it

`RECFM=FBA`: **the first character of every record is the ASA carriage control**
(`1`, `-`, `0`, blank), so the location counter starts in **column 2**, not
column 1. A parser written against `as370`'s listing — which has no control
character — finds zero addressed lines and reports nothing rather than failing.

```python
addr = re.match(r"^([0-9A-F]{6})\s", line[1:])     # IFOX00
addr = re.match(r"^([0-9A-F]{6})\s", line)         # as370
```

## What is not done

**Aligning the two listings is harder than it looks and my first attempt is not
trustworthy.** IFOX00 lists 952 addressed lines for `IEAVEXS` where `as370` lists
114 — the two do not agree on what to print for a macro expansion, so a
text-keyed alignment matches the wrong statements and reports a divergence that
is an artefact of the pairing. The naive result it produced (`Δ-18` at a `BALR`)
should not be believed.

An alignment that works has to key on something both listings agree about —
source statement number, most likely — and that is a piece of work rather than a
one-liner.

## How to capture another

```python
import sys; sys.path.insert(0, "tools")
import ifox_run as I
# upload the source to I.DIAGSRC first (ifox_run.py diag does this), then:
#   PGM=IFOX00, PARM='NODECK,NOLOAD,LIST'
#   //SYSPRINT DD DSN=IBMUSER.LSTn,DISP=(NEW,CATLG),
#   //         UNIT=SYSDA,SPACE=(CYL,(40,15))
```

Three things cost attempts, all of them JCL rather than logic:

- **`ifox_run.py diag` deletes the full listing** after extracting the
  diagnostics section — it is not a capture path, it is a message path.
- **A DD statement must end by column 71.** A one-line `SYSPRINT` DD with
  `DSN`, `DISP`, `UNIT` and `SPACE` is too long and fails with
  `IEF618I OPERAND FIELD DOES NOT TERMINATE IN COMMA OR BLANK` — which does not
  say "too long".
- **`DISP=(NEW,CATLG)` fails silently-ish on a name already catalogued** from a
  previous attempt. Use a fresh name per run.
