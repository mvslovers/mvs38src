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
    macrosnap.py --dir work/macros/mirror      the same, for a local -I directory
    macrosnap.py --compare a.tsv b.tsv         what moved between two snapshots

**Two hashes per member, and the second is the one that compares across sides.**
cc370's point, and it is the right one: the drift that reaches `as370` is not
between two systems, it is between a live library and the local `work/macros/`
directory the gate actually feeds it. Those must be diffable member by member.

They are not byte-comparable raw. Measured on `SYS1.AMACLIB(IHADVCT)`: the REST
read is 16,443 bytes with 203 LF; the local copy is 16,646 with 203 CRLF. The
difference is exactly 203 bytes, one CR per line, and after CRLF -> LF the two
are **identical** -- sequence numbers in columns 73-80 included, so no further
normalisation is needed or wanted. `sha256` is the raw bytes and catches any
change at all; `sha256_nl` is after that one substitution and is what a
cross-side diff must use.

`IBMUSER.PVTMAC` is in the list because it was in the oracle's SYSLIB. It does
not exist on every system; a library that is not there is recorded as absent
rather than skipped, because "the library is gone" is exactly the kind of change
worth catching.
"""
import argparse, base64, hashlib, json, os, sys, time, urllib.error, urllib.request

def _nl(b):
    """CRLF -> LF. The one difference between a dataset read and a local file."""
    return b.replace(b"\x0d\x0a", b"\x0a").replace(b"\x0d", b"\x0a")


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
                rows.append((lib, m, -1, f"UNREADABLE:{d if d else 'no answer'}", "-"))
                continue
            rows.append((lib, m, len(d), hashlib.sha256(d).hexdigest(),
                         hashlib.sha256(_nl(d)).hexdigest()))
            if i % 250 == 0:
                print(f"    {i}/{len(members)}", flush=True)
    return rows, absent


def take_dir(root):
    """Same shape, for a local -I directory. Members are the files in it."""
    rows = []
    name = os.path.basename(os.path.normpath(root))
    files = sorted(f for f in os.listdir(root)
                   if os.path.isfile(os.path.join(root, f)) and not f.startswith("."))
    print(f"  {name:16} {len(files):5} files", flush=True)
    for f in files:
        b = open(os.path.join(root, f), "rb").read()
        rows.append((name, f, len(b), hashlib.sha256(b).hexdigest(),
                     hashlib.sha256(_nl(b)).hexdigest()))
    return rows, []


def write(path, name, rows, absent):
    with open(path, "w") as f:
        f.write(f"# macro snapshot of {name}, {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        for lib, why in absent:
            f.write(f"# absent\t{lib}\t{why}\n")
        f.write("library\tmember\tbytes\tsha256\tsha256_nl\n")
        for r in sorted(rows):
            f.write("\t".join(str(x) for x in r) + "\n")


def load(path):
    out = {}
    for line in open(path):
        if line.startswith("#") or line.startswith("library\t"):
            continue
        f = line.rstrip("\n").split("\t")
        lib, mem, size, sha = f[0], f[1], f[2], f[3]
        out[(lib, mem)] = (size, f[4] if len(f) > 4 else sha)
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
    ap.add_argument("--dir", help="a local -I directory instead of a system")
    ap.add_argument("--cred", help="user:pass; else taken from the environment")
    ap.add_argument("--out")
    ap.add_argument("--compare", nargs=2, metavar=("OLD", "NEW"))
    a = ap.parse_args()

    if a.compare:
        return compare(*a.compare)
    if a.dir:
        rows, absent = take_dir(a.dir)
        name = os.path.basename(os.path.normpath(a.dir))
        out = a.out or os.path.join(HERE, "work", "snapshots",
                                    f"dir-{name}-{time.strftime('%Y%m%d-%H%M')}.tsv")
        os.makedirs(os.path.dirname(out), exist_ok=True)
        write(out, name, rows, absent)
        print(f"\n{len(rows)} files\n{out}")
        return 0
    if not a.system:
        ap.error("--system, --dir or --compare")

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
