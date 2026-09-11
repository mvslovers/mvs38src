#!/usr/bin/env python3
"""Checksum every member of a system's macro libraries, so drift is detectable.

This exists because of `IHADVCT`. `MVSCE-LAB` cut the 5,528 reference decks on
2026-09-07; by 2026-09-10 its `SYS1.AMACLIB` held a copy of `IHADVCT` that the
oracle demonstrably had not read, and MVS 3.8j keeps no member statistics that
could date the change. A full day went into establishing that from the decks
backwards. A checksum taken on the day the corpus was cut would have answered it
in one diff.

So: before a system is pinned as the oracle, snapshot it. After anything is
suspected, snapshot it again and compare. The output is a TSV a human can read
and `diff` can chew.

    macrosnap.py --system ref                  take one, write it under work/snapshots/
    macrosnap.py --system ref --out foo.tsv
    macrosnap.py --compare a.tsv b.tsv         what moved between two snapshots

`IBMUSER.PVTMAC` is in the list because it was in the oracle's SYSLIB. It does
not exist on every system; a library that is not there is recorded as absent
rather than skipped, because "the library is gone" is exactly the kind of change
worth catching.
"""
import argparse, base64, hashlib, json, os, sys, time, urllib.error, urllib.request

# The oracle's SYSLIB, in its order, plus SYS1.MACLIB -- which is not in the
# concatenation but is where the maintained level of a macro lives, and is
# therefore where a difference from the distribution level shows up.
LIBS = ["SYS1.AMACLIB", "SYS1.AMODGEN", "SYS1.AGENLIB", "SYS1.ATSOMAC",
        "SYS1.ATCAMMAC", "SYS1.APVTMACS", "IBMUSER.PVTMAC", "SYS1.MACLIB"]

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def systems():
    with open(os.path.join(HERE, "tools", "systems.json")) as f:
        return json.load(f)["systems"]


def take(name, sysinfo, cred):
    host = f"http://{sysinfo['host']}:{sysinfo['mvsmf']}"
    auth = base64.b64encode(cred.encode()).decode()

    def get(path, tries=5):
        for n in range(tries):
            try:
                r = urllib.request.Request(host + path)
                r.add_header("Authorization", "Basic " + auth)
                return urllib.request.urlopen(r, timeout=120).read()
            except urllib.error.HTTPError as e:
                return e.code            # a server answer is a result
            except Exception:
                if n == tries - 1:
                    return None          # no answer at all is NOT a result
                time.sleep(2 * (n + 1))

    rows, absent = [], []
    for lib in LIBS:
        b = get(f"/zosmf/restfiles/ds/{lib}/member")
        if not isinstance(b, bytes):
            absent.append((lib, b if b else "no answer"))
            print(f"  {lib:16} absent ({b if b else 'no answer'})", flush=True)
            continue
        members = [m["member"] for m in json.loads(b).get("items", [])]
        print(f"  {lib:16} {len(members):5} members", flush=True)
        for i, m in enumerate(members, 1):
            d = get(f"/zosmf/restfiles/ds/{lib}({m})")
            if not isinstance(d, bytes):
                # An unreadable member is a finding, not a gap to skip over:
                # PM-2026-003 is exactly this, reported as HTTP 200 with no body.
                rows.append((lib, m, -1, f"UNREADABLE:{d if d else 'no answer'}"))
                continue
            rows.append((lib, m, len(d), hashlib.sha256(d).hexdigest()))
            if i % 250 == 0:
                print(f"    {i}/{len(members)}", flush=True)
    return rows, absent


def write(path, name, rows, absent):
    with open(path, "w") as f:
        f.write(f"# macro snapshot of {name}, {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        for lib, why in absent:
            f.write(f"# absent\t{lib}\t{why}\n")
        f.write("library\tmember\tbytes\tsha256\n")
        for r in sorted(rows):
            f.write("\t".join(str(x) for x in r) + "\n")


def load(path):
    out = {}
    for line in open(path):
        if line.startswith("#") or line.startswith("library\t"):
            continue
        lib, mem, size, sha = line.rstrip("\n").split("\t")
        out[(lib, mem)] = (size, sha)
    return out


def compare(a, b):
    A, B = load(a), load(b)
    gone = sorted(set(A) - set(B))
    new = sorted(set(B) - set(A))
    moved = sorted(k for k in set(A) & set(B) if A[k][1] != B[k][1])
    print(f"{os.path.basename(a)} -> {os.path.basename(b)}")
    print(f"  {len(set(A) & set(B)) - len(moved)} unchanged")
    print(f"  {len(moved)} CHANGED, {len(gone)} gone, {len(new)} new")
    for k in moved:
        print(f"    changed {k[0]}({k[1]})  {A[k][0]} -> {B[k][0]} bytes")
    for k in gone:
        print(f"    gone    {k[0]}({k[1]})")
    for k in new:
        print(f"    new     {k[0]}({k[1]})  {B[k][0]} bytes")
    return 1 if (moved or gone or new) else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--system")
    ap.add_argument("--cred", help="user:pass; else taken from the environment")
    ap.add_argument("--out")
    ap.add_argument("--compare", nargs=2, metavar=("OLD", "NEW"))
    a = ap.parse_args()

    if a.compare:
        return compare(*a.compare)
    if not a.system:
        ap.error("--system or --compare")

    s = systems()
    key = [k for k in s if k.lower().endswith(a.system.lower())]
    if len(key) != 1:
        ap.error(f"--system {a.system!r} matches {key or 'nothing'}")
    name = key[0]
    cred = a.cred or os.environ.get("MVS_CRED")
    if not cred:
        ap.error("credentials: pass --cred user:pass or set MVS_CRED")

    print(f"snapshot of {name}")
    rows, absent = take(name, s[name], cred)
    out = a.out or os.path.join(
        HERE, "work", "snapshots",
        f"{name}-{time.strftime('%Y%m%d-%H%M')}.tsv")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    write(out, name, rows, absent)
    bad = sum(1 for r in rows if str(r[3]).startswith("UNREADABLE"))
    print(f"\n{len(rows)} members, {len(absent)} libraries absent, "
          f"{bad} unreadable\n{out}")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
