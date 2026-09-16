# Reconstructing a macro from IBM's object — the GETMAIN/FREEMAIN trial

**Result: +3 / −18. Not applied, and it must not be.**

Our `GETMAIN`/`FREEMAIN` emit `ST …,0(0,1)` — base register 1. IBM's shipped
object shows `ST …,0(1)` — index register 1. One character per line, six lines in
each macro. `GETMAIN` and `FREEMAIN` here are that change and nothing else;
record width and sequence numbers are asserted unchanged by the script that wrote
them.

Rebuilt all 5,538 modules with the reconstruction prepended to the macro path
(`gmsweep.py`; `gate.sh` appends `EXTRA_MACS` at the END of the `-I` list, so a
trial that must win cannot go through the gate), then `baseline_gate.py` and a set
diff against the live measurement:

| | |
|---|---|
| gained | `HMASMIO`, `HMASMRDS`, `IEDQNT` |
| **lost** | `IDA0192G IEAVAD09 IEAVAD71 IEBFDANL IEDQNV IEDQW42 IEDQWAJ IEFAB480 IKJEBELE IKJEBESC IKJEFT54 IKTCAS40 IKTCAS41 IKTCAS42 ISDAGET0 ISTCC011 ISTINCCC ISTINCRR` |
| chosen baseline | 1,608 → 1,593 |

**`IEDQNT` gains and `IEDQNV` loses.** Neighbouring modules in the same library,
each needing the other's form.

## What it proves, and it is not what it was meant to prove

The **method** works: a macro line read back out of IBM's object made three
modules byte-identical, and `IEDQNT` went from two differing bytes to zero.

The **macro** is at two levels, like `SCHEDULE` and `TSCBD`. Eighteen modules
want `0(0,1)` and at least three want `0(1)`, and no single file is both. So
reconstruction does not unblock `GETMAIN`/`FREEMAIN` — it *identifies* them as a
third two-level case, and what they need is the per-module macro path of decision
5, with a reconstructed macro as its content.

**The `SCHEDULE` rule held for the third time**: +3 and −10 there, +3 and −18
here. The net alone would have said "wrong" without saying why. Comparing the
identical **sets** is what says which modules want which level, and that list is
the input to a per-module table.
