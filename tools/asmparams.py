#!/usr/bin/env python3
"""The per-module assembly parameters, in one place, because there are two now.

`gate.sh` pins a stamp and then overrides it per module from `ASMDATES`; since
2026-09-14 it also passes `--sysparm` per module from `SYSPARMS`. A tool that
assembles without those is not building the deck the gate built, and the whole
project judges decks the gate built.

**This is the `macpath.py` fix applied to the parameters, and it is late.**
Measured 2026-09-14: twenty tools invoke `as370`, three knew about `ASMDATES`,
and ten hardcode `STAMP = dict(ASMDATE="09/07/26", ASMTIME="12.00")` —
`fillgaps.py:60`, `where.py:41` and `srccheck.py` among them. It costs nothing
today (none of the 37 dated modules is in `src/`, one is in `worklist16.txt`) and
it is a trap that grows with every table added.

    from asmparams import params
    flags_extra, env = params(mod)
    subprocess.run([BIN] + flags_extra + flags() + ["-o", obj, src],
                   env=dict(os.environ, **env))

Retrofitting the other ten is a separate change and is NOT done here — this
module exists so the next tool does not add an eleventh.
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
GATE = os.path.join(ROOT, "work/measurements/baseline-gate")

PINNED_DATE = "09/07/26"
PINNED_TIME = "12.00"
ASMDATES = os.path.join(GATE, "asmdate.tsv")
SYSPARMS = os.path.join(GATE, "sysparm.tsv")


def _table(path):
    out = {}
    if os.path.exists(path):
        with open(path) as fh:
            for line in fh:
                f = line.rstrip("\n").split("\t")
                if len(f) >= 2 and f[1] and f[0] != "module":
                    out[f[0]] = f[1]
    return out


_dates, _sysparms = None, None


def params(mod):
    """(extra argv, env overrides) for one module, exactly as gate-worker.sh does.

    A module in neither table gets the pin and no `--sysparm`, which is the state
    every measurement before 2026-09-13 was taken in, so an empty or missing table
    changes nothing.
    """
    global _dates, _sysparms
    if _dates is None:
        _dates, _sysparms = _table(ASMDATES), _table(SYSPARMS)
    argv = []
    if mod in _sysparms:
        argv.append(f"--sysparm={_sysparms[mod]}")
    return argv, dict(ASMDATE=_dates.get(mod, PINNED_DATE), ASMTIME=PINNED_TIME)


if __name__ == "__main__":
    import sys
    for m in sys.argv[1:] or ["IEDQA1", "IEFBR14"]:
        a, e = params(m)
        print(f"{m:10s} argv={a}  env={e}")
