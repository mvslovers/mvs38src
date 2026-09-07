#!/usr/bin/env python3
"""Assemble MVSBLD modules with the real IFOX00 under MVS/CE and bring the decks back.

The point of this run is separation. A difference between an `as370` deck and a
distribution library member has two possible causes -- the tool or the source.
Assembling the *same* source with IFOX00 splits them: what differs here is the
tool and nothing else.

Design, and the reason for each part:

  * source goes up as a PDS, not through the reader. mvsMF closes the connection
    on a 2.9 MB submission; from the PDS a 25-module job is 12 KB of JCL.
  * SYSLIB is the same seven libraries `gate.sh` passes as -I, in the same order.
    Different macro libraries make every difference unattributable.
  * PARM=NOLIST. Assembler XF writes *nothing* to SYSPRINT under NOLIST -- not
    even the diagnostics -- so pass 1 keeps the return code per step, and the
    modules that need the messages are re-run with LIST in pass 2.
  * decks come back over FTP in binary. The REST route transcodes them.
  * the deck is kept whatever the return code is: seven modules assemble
    byte-identical to IBM's object while returning non-zero.

State lives in a TSV and every step is resumable; a module already carrying a
deck and a return code is skipped.

  ifox_run.py plan  [--seed N]     write the module order
  ifox_run.py run   [--limit N]    work the list, batch by batch
  ifox_run.py status
"""
import argparse, gzip, json, os, random, re, subprocess, sys, time
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

HOST, PORT, FTPPORT = "mvsdev", 8083, 2123          # MVSCE-EXP
USER, PW = "IBMUSER", "SYS1"
BASE = f"http://{HOST}:{PORT}/zosmf/restjobs/jobs"
SRC = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
OUT = os.path.expanduser("~/repos/mvs/mvs38src/work/measurements/ifox-run")
DECKS = os.path.join(OUT, "decks")
AS370 = os.path.join(OUT, "as370")
STATE = os.path.join(OUT, "state.tsv")
ORDER = os.path.join(OUT, "order.txt")

SYSLIB = ["SYS1.AMACLIB", "SYS1.AMODGEN", "SYS1.AGENLIB", "SYS1.ATSOMAC",
          "SYS1.ATCAMMAC", "SYS1.APVTMACS", "IBMUSER.PVTMAC"]
SRCPDS, OBJPDS = "IBMUSER.SRC", "IBMUSER.IFOXOBJ"
PER_JOB, PER_BATCH, FTPJOBS = 25, 150, 3

import base64, urllib.request


def _req(method, url, data=None, ctype=None, extra=None, retries=3):
    for attempt in range(retries):
        try:
            r = urllib.request.Request(url, data=data, method=method)
            r.add_header("Authorization", "Basic " +
                         base64.b64encode(f"{USER}:{PW}".encode()).decode())
            r.add_header("X-CSRF-ZOSMF-HEADER", "x")
            if ctype:
                r.add_header("Content-Type", ctype)
            for k, v in (extra or {}).items():
                r.add_header(k, v)
            with urllib.request.urlopen(r, timeout=180) as f:
                return f.read()
        except Exception as e:
            if attempt == retries - 1:
                raise
            time.sleep(2 + 3 * attempt)


def submit(jcl):
    d = json.loads(_req("PUT", BASE, jcl.encode("latin-1"), "text/plain",
                        {"X-IBM-Intrdr-Mode": "TEXT"}))
    return d["jobname"], d["jobid"]


def wait(jobname, jobid, poll=3, limit=1800):
    t0 = time.time()
    while time.time() - t0 < limit:
        s = json.loads(_req("GET", f"{BASE}/{jobname}/{jobid}"))
        if s.get("status") == "OUTPUT":
            return s
        time.sleep(poll)
    raise TimeoutError(f"{jobname}/{jobid}")


def jesysmsg(jobname, jobid):
    return _req("GET", f"{BASE}/{jobname}/{jobid}/files/4/records").decode("latin-1")


def purge(jobname, jobid):
    try:
        _req("DELETE", f"{BASE}/{jobname}/{jobid}", retries=1)
    except Exception:
        pass


def ftp(lines):
    p = subprocess.run(["ftp", "-n", HOST, str(FTPPORT)],
                       input="\n".join([f"user {USER} {PW}"] + lines + ["quit"]) + "\n",
                       capture_output=True, text=True)
    return p.stdout + p.stderr


def members(pds):
    """The member names in a PDS, as the FTP server lists them."""
    out = ftp([f"cd '{pds}'", "ls"])
    names = set()
    for line in out.splitlines():
        t = line.split()
        # a PDS without ISPF statistics lists one bare name per line -- the first
        # version of this required two fields, found nothing, and made every
        # upload run three times while reporting success
        if t and t[0] != "Name" and re.fullmatch(r"[A-Z@#$][A-Z0-9@#$]{0,7}", t[0]):
            names.add(t[0])
    return names


def upload(modules):
    """Serially -- three FTP sessions storing into one PDS lose members: the
    first attempt at this put 47 of 150 there and said nothing."""
    todo = list(modules)
    for _ in range(3):
        ftp(["quote site RECFM=FB LRECL=80 BLKSIZE=19040", "ascii"] +
            [f'put "{SRC}/{m}.ASM" \'{SRCPDS}({m})\'' for m in todo])
        have = members(SRCPDS)
        todo = [m for m in modules if m not in have]
        if not todo:
            return []
    return todo


def download(modules):
    """Serially, and checked. Three parallel sessions reading one PDS brought
    back 45 of 135 members and reported nothing."""
    on_mvs = members(OBJPDS)
    want = [m for m in modules if m in on_mvs]
    for _ in range(3):
        ftp(["binary"] + [f"get '{OBJPDS}({m})' {DECKS}/{m}.obj" for m in want])
        want = [m for m in want if not os.path.exists(f"{DECKS}/{m}.obj")]
        if not want:
            break
    return want


def realloc_src():
    jcl = f"""//IFXSRC   JOB (ACCT),'MVS38SRC',CLASS=A,MSGCLASS=H,NOTIFY=IBMUSER
//DEL     EXEC PGM=IDCAMS
//SYSPRINT DD  SYSOUT=H
//SYSIN    DD  *
  DELETE '{SRCPDS}' NONVSAM PURGE
  SET MAXCC=0
/*
//ALLOC   EXEC PGM=IEFBR14
//D2       DD  DSN={SRCPDS},DISP=(,CATLG),UNIT=SYSDA,
//             SPACE=(CYL,(150,60,400)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040)
"""
    n, i = submit(jcl)
    wait(n, i)
    purge(n, i)


def asmjob(name, modules, parm="DECK,NOLOAD,NOLIST"):
    L = [f"//{name} JOB (ACCT),'MVS38SRC',CLASS=A,MSGCLASS=H,NOTIFY=IBMUSER"]
    for k, m in enumerate(modules, 1):
        L.append(f"//S{k:02d}     EXEC PGM=IFOX00,PARM='{parm}',REGION=1024K")
        for j, lib in enumerate(SYSLIB):
            L.append(f"//SYSLIB   DD  DSN={lib},DISP=SHR" if j == 0
                     else f"//         DD  DSN={lib},DISP=SHR")
        for ut in ("SYSUT1", "SYSUT2", "SYSUT3"):
            L.append(f"//{ut}   DD  UNIT=SYSDA,SPACE=(CYL,(5,2))")
        L.append("//SYSPRINT DD  SYSOUT=H")
        # DISP=OLD, not SHR: with SHR, six jobs punching into one PDS put
        # another module's object under the member name -- 20 of the first 244
        # decks, silently. OLD makes MVS enqueue the data set per step.
        L.append(f"//SYSPUNCH DD  DSN={OBJPDS}({m}),DISP=OLD")
        L.append(f"//SYSIN    DD  DSN={SRCPDS}({m}),DISP=SHR")
    return "\n".join(L) + "\n"


STEP_RC = re.compile(r"IEF142I \S+\s+(S\d+) - STEP WAS EXECUTED - COND CODE (\d+)")
STEP_ABEND = re.compile(r"IEF450I \S+\s+(S\d+) \S*\s*-\s*ABEND=(\S+)")
STEP_NOTRUN = re.compile(r"IEF272I \S+\s+(S\d+) - STEP WAS NOT EXECUTED")
STEP_START = re.compile(r"START TIME:\s+(\d\d:\d\d:\d\d).*?STEP NAME:\s+(S\d+)", re.S)


def parse_rc(msg, modules):
    """{module: (rc, start time)}.

    Three outcomes, and they must not be confused: a step that ran has a COND
    CODE, one that abended has none, and one JES2 never started (a missing
    SYSIN member, say) is NOTRUN -- which is a defect of this driver, not a
    finding about the module."""
    rc = dict(STEP_RC.findall(msg))
    ab = {s: "ABEND " + a for s, a in STEP_ABEND.findall(msg)}
    nr = {s: "NOTRUN" for s in STEP_NOTRUN.findall(msg)}
    st = {name: t for t, name in STEP_START.findall(msg)}
    out = {}
    for k, m in enumerate(modules, 1):
        s = f"S{k:02d}"
        out[m] = (rc.get(s) or ab.get(s) or nr.get(s) or "?", st.get(s, ""))
    return out


def esd_name(path):
    """The first section name in an object deck."""
    d = open(path, "rb").read()
    for i in range(0, len(d), 80):
        c = d[i:i + 80]
        if c[1:4] == b"\xc5\xe2\xc4":            # 'ESD'
            return c[16:24].decode("cp037").strip()
    return None


def check_decks(modules):
    """A deck belongs to its module when its first section name is the one
    `as370` produced from the same source. Anything else is a member the
    punch put in the wrong place."""
    bad = []
    for m in modules:
        p, q = f"{DECKS}/{m}.obj", f"{AS370}/{m}.obj"
        if not (os.path.exists(p) and os.path.exists(q)):
            continue
        a, b = esd_name(p), esd_name(q)
        if a and b and a != b:
            bad.append(m)
            os.remove(p)
    return bad


def load_state():
    st = {}
    if os.path.exists(STATE):
        for line in open(STATE):
            f = line.rstrip("\n").split("\t")
            if len(f) >= 5 and f[0] != "module":
                st[f[0]] = f
    return st


def append_state(rows):
    new = not os.path.exists(STATE)
    with open(STATE, "a") as f:
        if new:
            f.write("module\tifox_rc\tstart\tdeck_bytes\tjob\n")
        for r in rows:
            f.write("\t".join(str(x) for x in r) + "\n")


def cmd_plan(args):
    os.makedirs(DECKS, exist_ok=True)
    mods = sorted(m[:-4] for m in os.listdir(SRC) if m.endswith(".ASM"))
    ctrl = ["IGG026DU", "IEFJDSNA", "BLSUZZ2R", "IGG019JP", "AHLMCIH"]
    rest = [m for m in mods if m not in ctrl]
    random.Random(args.seed).shuffle(rest)
    open(ORDER, "w").write("\n".join(ctrl + rest) + "\n")
    print(f"{len(mods)} modules, controls first, the rest shuffled (seed {args.seed})")


def cmd_run(args):
    os.makedirs(DECKS, exist_ok=True)
    os.makedirs(f"{OUT}/msg", exist_ok=True)
    order = open(ORDER).read().split()
    st = load_state()
    done = {m for m, f in st.items()
            if f[1] not in ("NOTRUN", "?") and (f[3] != "0" or f[1].startswith("ABEND"))}
    todo = [m for m in order if m not in done]
    if args.limit:
        todo = todo[:args.limit]
    print(f"{len(done)} done, {len(todo)} to go")
    t00 = time.time()
    for b in range(0, len(todo), PER_BATCH):
        batch = todo[b:b + PER_BATCH]
        t0 = time.time()
        realloc_src()
        upload(batch)
        tup = time.time() - t0
        jobs, rows = [], []
        for k in range(0, len(batch), PER_JOB):
            chunk = batch[k:k + PER_JOB]
            name = f"IFX{(b + k) // PER_JOB % 10000:04d}"
            n, i = submit(asmjob(name, chunk))
            jobs.append((n, i, chunk))
        tas = time.time()
        for n, i, chunk in jobs:
            wait(n, i)
            msg = jesysmsg(n, i)
            gzip.open(f"{OUT}/msg/{n}_{i}.txt.gz", "wt").write(msg)
            rc = parse_rc(msg, chunk)
            for m in chunk:
                rows.append([m, rc[m][0], rc[m][1], "", f"{n}/{i}"])
            purge(n, i)
        tas = time.time() - tas
        t1 = time.time()
        download(batch)
        wrong = check_decks(batch)
        for r in rows:
            p = f"{DECKS}/{r[0]}.obj"
            r[3] = os.path.getsize(p) if os.path.exists(p) else 0
        append_state(rows)
        n_ok = sum(1 for r in rows if r[3])
        print(f"[{b + len(batch)}/{len(todo)}] up {tup:.0f}s  asm {tas:.0f}s  "
              f"down {time.time() - t1:.0f}s  decks {n_ok}/{len(batch)}  "
              f"misfiled {len(wrong)}  total {(time.time() - t00) / 60:.1f}min", flush=True)


LSTPDS = "IBMUSER.IFOXLST"


def cmd_diag(args):
    """Second pass, with LIST: the diagnostics for a named set of modules.

    Assembler XF writes nothing at all to SYSPRINT under NOLIST, so the run
    that produced the decks could not also produce the messages. This one is
    for the modules whose verdict needs them -- where IFOX00 flags and as370
    is silent, above all."""
    mods = [m.strip() for m in open(args.list) if m.strip()]
    os.makedirs(f"{OUT}/diag", exist_ok=True)
    todo = [m for m in mods if not os.path.exists(f"{OUT}/diag/{m}.txt")]
    print(f"{len(mods)} modules, {len(todo)} to go")
    for b in range(0, len(todo), 50):
        batch = todo[b:b + 50]
        realloc_src()
        upload(batch)
        for k in range(0, len(batch), 10):
            chunk = batch[k:k + 10]
            L = [f"//IFXD{k // 10:04d} JOB (ACCT),'MVS38SRC',CLASS=A,MSGCLASS=H,NOTIFY=IBMUSER"]
            for j, m in enumerate(chunk, 1):
                L.append(f"//S{j:02d}     EXEC PGM=IFOX00,PARM='NODECK,NOLOAD,LIST',REGION=1024K")
                for x, lib in enumerate(SYSLIB):
                    L.append(f"//SYSLIB   DD  DSN={lib},DISP=SHR" if x == 0
                             else f"//         DD  DSN={lib},DISP=SHR")
                for ut in ("SYSUT1", "SYSUT2", "SYSUT3"):
                    L.append(f"//{ut}   DD  UNIT=SYSDA,SPACE=(CYL,(5,2))")
                L.append(f"//SYSPRINT DD  DSN={LSTPDS}({m}),DISP=OLD")
                L.append("//SYSPUNCH DD  DUMMY")
                L.append(f"//SYSIN    DD  DSN={SRCPDS}({m}),DISP=SHR")
            n, i = submit("\n".join(L) + "\n")
            wait(n, i)
            purge(n, i)
        on_mvs = members(LSTPDS)
        for m in batch:
            if m not in on_mvs:
                continue
            ftp(["ascii", f"get '{LSTPDS}({m})' {OUT}/diag/{m}.full"])
            if os.path.exists(f"{OUT}/diag/{m}.full"):
                txt = open(f"{OUT}/diag/{m}.full", errors="replace").read()
                cut = txt.rfind("ASSEMBLER DIAGNOSTICS AND STATISTICS")
                open(f"{OUT}/diag/{m}.txt", "w").write(txt[cut:] if cut >= 0 else txt[-8000:])
                os.remove(f"{OUT}/diag/{m}.full")
        print(f"[{b + len(batch)}/{len(todo)}]", flush=True)


def cmd_status(args):
    st = load_state()
    order = open(ORDER).read().split() if os.path.exists(ORDER) else []
    rc = {}
    for f in st.values():
        rc[f[1]] = rc.get(f[1], 0) + 1
    print(f"{len(st)} of {len(order)} modules run")
    for k in sorted(rc):
        print(f"  rc {k:>10s}: {rc[k]}")
    print(f"  decks present: {sum(1 for f in st.values() if f[3] not in ('0', ''))}")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("plan"); p.add_argument("--seed", type=int, default=20260907); p.set_defaults(fn=cmd_plan)
    p = sub.add_parser("run"); p.add_argument("--limit", type=int, default=0); p.set_defaults(fn=cmd_run)
    p = sub.add_parser("diag"); p.add_argument("--list", required=True); p.set_defaults(fn=cmd_diag)
    p = sub.add_parser("status"); p.set_defaults(fn=cmd_status)
    a = ap.parse_args()
    a.fn(a)
