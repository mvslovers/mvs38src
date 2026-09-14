#!/usr/bin/env python3
"""Which deck directory is current, in one place, because the last one went stale twice.

`obj_overlay12` was the default `--decks` of `lenlist.py`, `seclocate.py` and
`sysparm_sweep.py` on 2026-09-14, and by then it was **two generations behind**:
cut at 18:21 on 2026-09-13, before eight `src/` repairs landed at 20:45, and
before `gate.sh` learned `SYSPARMS`. Diffing against it showed 118 decks moved
where 110 were expected, and the eight extra were entirely the first of those two
gaps. A stale deck directory does not announce itself — it answers every question,
just about yesterday.

So the name lives here and the tools ask.

    from decks import CURRENT, CONTROL

`CURRENT` is the canonical state: the overlay source tree, the pinned stamp with
its per-module `ASMDATES` override, and the per-module `SYSPARMS` table. It is
what `work/measurements/baseline-gate/overlay-vs-both.tsv` was measured from and
what the README scoreboard counts.

`CONTROL` is the same thing with `SYSPARMS` switched off. It exists because it is
the only valid comparison base for a `SYSPARM` question, and because of a trap
worth stating plainly:

**`sysparm_sweep.py` must derive its candidates from `CONTROL`, never `CURRENT`.**
It reads the inserted run out of the difference between our deck and IBM's. In
`CURRENT` the 110 winners are already identical, so there is no insert to read,
so a re-run would report them as "no 2- or 4-byte insert" and **write a table with
110 fewer rows** — which the next gate run would then act on. The sweep would
delete its own result and every step would exit 0.

Re-cut both with:

    SRC_TREE=work/src-states/overlay tools/gate.sh <as370> sysparm1
    SRC_TREE=work/src-states/overlay SYSPARMS=/dev/null tools/gate.sh <as370> nosysparm
"""
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")

CURRENT = os.path.join(ROOT, "obj_sysparm1")
CONTROL = os.path.join(ROOT, "obj_nosysparm")

if __name__ == "__main__":
    for n, p in (("CURRENT", CURRENT), ("CONTROL", CONTROL)):
        print(f"{n:8s} {p}  {'ok' if os.path.isdir(p) else 'MISSING'}"
              f"  {len(os.listdir(p)) if os.path.isdir(p) else 0} files")
