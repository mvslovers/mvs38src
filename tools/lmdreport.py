#!/usr/bin/env python3
"""Run Dave's load-module cross-reference report without a sort product.

`ZLMDRPTD` and `ZLMDRPTT` compare what the build produced against the original
DLIBs and against the original targets -- the comparison this whole exercise
exists to make. Each begins with two `PGM=SORT` steps over `SYS1.SORTLIB`, and
MVS/CE has no sort at all: no `SYS1.SORTLIB`, no `SORT` in `SYS1.LINKLIB`,
`SYS2.LINKLIB` or `MVSSRC.BLD.LOAD`, and no distribution library behind the
`SORTLIB` the build allocates. So the job ends

    IEF212I RPTDLB SORT1 SORTLIB - DATA SET NOT FOUND

before `LMDRPT38` ever runs.

This does the two sorts on the host with `lmdsort.py` -- in EBCDIC collating
order, see its docstring for why that is not a detail -- writes them to real
data sets, and submits the rest of Dave's job with `&BLD` and `&ORG` pointing at
those instead of at the passed temporaries. **Nothing else in the job is
touched**: the twenty-odd `B*` DD cards that name the build libraries, the
`SYSIN` from `MVSSRC.BLD.UTILITY.ASM(LMDSKIP)` and the `DIFIN` control cards are
Dave's, and the report is his program reading his input.

    lmdreport.py --member ZLMDRPTD [--dry-run]
"""
import argparse, json, os, re, subprocess, sys, time, urllib.parse, urllib.request, base64

HOST = "http://mvsdev.lan:8082"          # see bldrun.py on why not the bare name
USER, PW = "IBMUSER", "SYS1"
LIB = "MVSSRC.BLD.SMP.JCL"
HERE = os.path.dirname(os.path.abspath(__file__))


def req(method, path, body=None, ctype=None, extra=None):
    r = urllib.request.Request(HOST + path, data=body, method=method)
    r.add_header("Authorization", "Basic " +
                 base64.b64encode(f"{USER}:{PW}".encode()).decode())
    if ctype:
        r.add_header("Content-Type", ctype)
    for k, v in (extra or {}).items():
        r.add_header(k, v)
    return urllib.request.urlopen(r, timeout=300).read().decode("latin-1")


def sortin_of(jcl):
    """The two SORTIN data sets, in the order the job sorts them.

    Read out of the JCL rather than hardcoded: `ZLMDRPTD` sorts the DLIB pair
    and `ZLMDRPTT` the target pair, and a tool that assumed one would quietly
    report the wrong comparison for the other.
    """
    return re.findall(r"^//SORTIN\s+DD\s+DSN=([A-Z0-9.$#@]+)", jcl, re.M)


def rewrite(jcl, bld, org):
    """Drop the two SORT steps and point BLD/ORG at the sorted data sets."""
    out, skipping = [], False
    for line in jcl.replace("\r\n", "\n").split("\n"):
        if re.match(r"^//SORT\d\s+EXEC\s+PGM=SORT", line):
            skipping = True
            out.append("//* " + line[2:].rstrip()[:69])
            continue
        if skipping:
            # a step ends at the next EXEC that is not one of the SORT steps
            if re.match(r"^//\S*\s+EXEC\s", line) and "PGM=SORT" not in line:
                skipping = False
            else:
                continue
        if re.match(r"^//BLD\s+DD\s+DSN=&BLD", line):
            out.append(f"//BLD      DD  DSN={bld},DISP=SHR"); continue
        if re.match(r"^//ORG\s+DD\s+DSN=&ORG", line):
            out.append(f"//ORG      DD  DSN={org},DISP=SHR"); continue
        if re.match(r"^//SUB\s+EXEC\s+BLDSUB", line):
            out.append("//* " + line[2:].rstrip()[:69]); continue
        if "MSGCLASS=" in line:
            line = re.sub(r"MSGCLASS=\w", "MSGCLASS=H", line)
        out.append(line[:72].rstrip())
    return "\n".join(l for l in out if l.strip()) + "\n"


def allocate(dsn):
    """IEFBR14 with a DD that creates it. mvsMF will not create on PUT."""
    jcl = (f"//ALLOC    JOB  (BLD),'ALLOC',CLASS=A,MSGCLASS=H\n"
           f"//S1     EXEC PGM=IEFBR14\n"
           f"//D       DD  DSN={dsn},DISP=(,CATLG),UNIT=SYSDA,\n"
           f"//            SPACE=(CYL,(10,5)),\n"
           f"//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=4080)\n")
    d = json.loads(req("PUT", "/zosmf/restjobs/jobs", jcl.encode("latin-1"),
                       "text/plain", {"X-IBM-Intrdr-Mode": "TEXT"}))
    return wait(d["jobname"], d["jobid"])


def wait(jobname, jobid, limit=3600):
    t0 = time.time()
    while time.time() - t0 < limit:
        d = json.loads(req("GET", f"/zosmf/restjobs/jobs/{jobname}/{jobid}"))
        if d.get("status") == "OUTPUT":
            return d.get("retcode") or "?"
        time.sleep(10)
    return "TIMEOUT"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--member", default="ZLMDRPTD")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()

    jcl = req("GET", f"/zosmf/restfiles/ds/{LIB}({urllib.parse.quote(a.member)})")
    ins = sortin_of(jcl)
    if len(ins) != 2:
        sys.exit(f"{a.member}: expected two SORTIN data sets, found {ins}")
    bld_in, org_in = ins
    bld = bld_in + ".SORTED"
    org = org_in + ".SORTED"
    print(f"{a.member}: sorting\n  {bld_in}\n  {org_in}")

    if a.dry_run:
        print(rewrite(jcl, bld, org))
        return 0

    for src, dst in ((bld_in, bld), (org_in, org)):
        rc = allocate(dst)
        print(f"  allocate {dst}: {rc}")
        r = subprocess.run([sys.executable, f"{HERE}/lmdsort.py", src, dst])
        if r.returncode:
            sys.exit(f"sort of {src} failed")

    body = rewrite(jcl, bld, org)
    d = json.loads(req("PUT", "/zosmf/restjobs/jobs", body.encode("latin-1"),
                       "text/plain", {"X-IBM-Intrdr-Mode": "TEXT"}))
    print(f"  submitted {d['jobname']}/{d['jobid']}")
    rc = wait(d["jobname"], d["jobid"])
    print(f"  {d['jobname']}/{d['jobid']}  {rc}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
