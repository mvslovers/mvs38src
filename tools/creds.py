#!/usr/bin/env python3
"""Where the tools get their credentials, so the repository does not carry them.

These are the published default credentials of TK5 and MVS/CE on a LAN-local
emulator, so nothing here was ever a secret a reader could not look up. The
reason they left the tracked files anyway is convention: `CLAUDE.md` gitignores
`.env` for a reason, publication of this repository waits on a licensing answer,
and git history keeps a string whatever a later commit does. Better to not put
them in than to explain later why they are there.

Resolution order, first hit wins:

  1. `MVS_CRED` in the environment -- one pair for one-off runs
  2. `MVS_CRED_<SYSTEM>` in the environment, e.g. `MVS_CRED_MVSTK5_REF`
  3. `<SYSTEM>_CRED=user:pass` in `.env` at the repository root
  4. `DEFAULT_CRED=user:pass` in the same `.env`

System names come from `tools/systems.json` and are normalised the obvious way:
`MVSTK5-REF` and `ref` and `mvstk5_ref` all reach the same entry.

There is no built-in fallback pair on purpose. A tool that cannot find a
credential must stop and say so; one that quietly tries a default produces a 401
loop, and a 401 loop is indistinguishable from an outage from the outside.
"""
import os

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ENV = os.path.join(HERE, ".env")


def _norm(name):
    return name.strip().upper().replace("-", "_").replace(".", "_")


def _dotenv():
    out = {}
    if not os.path.exists(ENV):
        return out
    for line in open(ENV):
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        out[_norm(k)] = v.strip().strip('"').strip("'")
    return out


def _resolve(name):
    """Short alias to full system name. 'ref' -> 'MVSTK5-REF'.

    Written because the first version of this file documented the aliasing and
    did not implement it -- `cred('ref')` went looking for `REF_CRED`. The test
    found it; reading the docstring would not have.
    """
    import json
    try:
        with open(os.path.join(HERE, "tools", "systems.json")) as f:
            names = list(json.load(f)["systems"])
    except Exception:
        return name
    n = _norm(name)
    exact = [k for k in names if _norm(k) == n]
    if exact:
        return exact[0]
    ends = [k for k in names if _norm(k).endswith("_" + n) or _norm(k) == n]
    return ends[0] if len(ends) == 1 else name


def cred(system):
    """Return 'user:pass' for a system name, or raise with what to do about it."""
    n = _norm(_resolve(system))
    if os.environ.get("MVS_CRED"):
        return os.environ["MVS_CRED"]
    if os.environ.get(f"MVS_CRED_{n}"):
        return os.environ[f"MVS_CRED_{n}"]
    env = _dotenv()
    for key in (f"{n}_CRED", f"MVS_CRED_{n}", "DEFAULT_CRED"):
        if env.get(key):
            return env[key]
    raise SystemExit(
        f"no credential for {system!r}.\n"
        f"  set MVS_CRED='user:pass' for a one-off, or\n"
        f"  put {n}_CRED=user:pass in {ENV}\n"
        f"  (copy .env.example; it is gitignored)")


def pair(system):
    """Same, split into (user, password)."""
    u, _, p = cred(system).partition(":")
    return u, p
