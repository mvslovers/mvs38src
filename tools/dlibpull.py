import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from creds import cred as _cred      # credentials live in .env, not here
#!/usr/bin/env python3
"""Pull distribution-library members off a live MVS, byte for byte, resumably.

The measurement this feeds asks which system's object code Dave Kreiss' source
actually assembles to -- TK5's or MVS/CE's.  Both sides have to be read the same
way or the answer is about the reader, so this is the only reader: one code
path, one header set, both systems.

**Binary, not text.**  `X-IBM-Data-Type: binary` returns the member's exact
bytes.  Without it mvsMF translates EBCDIC to ASCII and frames records, and a
load module -- which is what a `SYS1.AOS*` member is, RECFM=U -- does not
survive that.  `foo`'s TK5-vs-CE distance measurement established this; the
header is not an optimisation.

Resumable by construction: a member already in the cache is not re-read.  ~8,000
reads take the better part of an hour and a driver that starts over after a
network blip is a driver nobody runs twice.

    dlibpull.py --system tk5 --modules mods.tsv
    dlibpull.py --system ce  --modules mods.tsv [--cache macro-bytes]

`mods.tsv` is `member<TAB>library`, no header, and the library is the part after
`SYS1.` -- so it reads distribution libraries (`AOSD0`) and macro libraries
(`AMACLIB`) with the same code.  `--cache` keeps the two kinds apart on disk.
"""
import argparse, base64, http.client, json, os, sys, time

SYSTEMS = {
    # Credentials differ by system and that is not a detail; they come from .env is
    # MVS/CE and another for TK5; see .env.  The wrong pair returns 401, and
    # a 401 loop looks exactly like an outage from the outside.
    # cred is resolved from .env through creds.py at use time, keyed on `label`.
    # It used to be a literal None with creds.py imported and never called, so
    # the first read died on `NoneType.encode`. Third instance of the same shape
    # in two days -- macrosnap.py, then this -- so it is resolved here rather
    # than restated: see docs/macro-path.md on rules stated in a second place.
    "ce":  dict(host="mvsdev.lan", port=8082, label="MVSCE-LAB"),
    "tk5": dict(host="mvsdev.lan", port=8084, label="MVSTK5-REF"),
}
def _credof(cfg):
    """user:pass for a SYSTEMS entry, from .env via creds.py."""
    return cfg.get("cred") or _cred(cfg["label"])


ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
CACHE = os.path.join(ROOT, "work", "measurements", "dlib-bytes")


class Reader:
    """One kept-alive connection, reopened on any failure."""

    def __init__(self, cfg):
        self.cfg, self.c = cfg, None
        self.auth = "Basic " + base64.b64encode(_credof(cfg).encode()).decode()

    def _conn(self):
        if self.c is None:
            self.c = http.client.HTTPConnection(self.cfg["host"], self.cfg["port"],
                                                timeout=90)
        return self.c

    def get(self, path, tries=6):
        for attempt in range(tries):
            try:
                c = self._conn()
                c.request("GET", path, headers={"Authorization": self.auth,
                                                "X-IBM-Data-Type": "binary"})
                r = c.getresponse()
                body = r.read()
                if r.status == 200:
                    return body
                if r.status == 404:
                    return None            # a real answer: no such member
                raise RuntimeError(f"HTTP {r.status}")
            except Exception as e:
                try:
                    self.c.close()
                except Exception:
                    pass
                self.c = None
                if attempt == tries - 1:
                    raise
                time.sleep(min(30, 3 * (attempt + 1)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--system", required=True, choices=sorted(SYSTEMS))
    ap.add_argument("--modules", required=True)
    ap.add_argument("--cache", default="dlib-bytes",
                    help="subdirectory of work/measurements to cache into")
    a = ap.parse_args()

    cfg = SYSTEMS[a.system]
    out = os.path.join(os.path.dirname(CACHE), a.cache, a.system)
    rd = Reader(cfg)

    todo = []
    for line in open(a.modules):
        line = line.rstrip("\n")
        if not line:
            continue
        mod, dlib = line.split("\t")[:2]
        todo.append((mod, dlib))

    got = miss = skip = 0
    t0 = time.time()
    for i, (mod, dlib) in enumerate(todo, 1):
        p = os.path.join(out, dlib, mod + ".bin")
        if os.path.exists(p) or os.path.exists(p + ".404"):
            skip += 1
            continue
        b = rd.get(f"/zosmf/restfiles/ds/SYS1.{dlib}({mod})")
        os.makedirs(os.path.dirname(p), exist_ok=True)
        if b is None:
            open(p + ".404", "w").close()
            miss += 1
        else:
            open(p, "wb").write(b)
            got += 1
        if i % 200 == 0:
            el = time.time() - t0
            print(f"  {i}/{len(todo)}  got={got} miss={miss} skip={skip} "
                  f"{el:.0f}s", flush=True)

    man = dict(system=a.system, label=cfg["label"],
               endpoint=f"http://{cfg['host']}:{cfg['port']}", user=_credof(cfg).split(":")[0],
               modules=len(todo), read=got, absent=miss,
               finished=time.strftime("%Y-%m-%dT%H:%M:%S"))
    os.makedirs(out, exist_ok=True)
    json.dump(man, open(os.path.join(out, "manifest.json"), "w"), indent=2)
    print(f"{a.system}: {got} read, {miss} absent, {skip} already cached "
          f"({time.time() - t0:.0f}s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
