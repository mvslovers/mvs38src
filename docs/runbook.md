# Runbook — how things actually work

Operational knowledge for this project: starting MVS/CE, IPLing, issuing
commands, submitting jobs. Written for a human **and** an agent — what stands
here, an agent may carry out without asking.

Supplies the *how* to the [workplan](workplan.md).

> **Status marks.** This document was written before the first run. Every
> procedure carries a status:
> **✅ verified** · **📄 derived from the configuration** (plausible, not yet
> executed) · **❓ open**
>
> Whoever runs a procedure for the first time corrects it here and raises its
> status to ✅. That is part of the job, not an afterthought.

> **Reference release: still 2.1.4, but it should become v3.0.0.** Every
> configuration detail below comes from `MVSCE.release.v2.1.4.tar`, the copy we
> have locally. The current release is **v3.0.0 "UNEXPECTED SLOTH" of
> 2026-08-01** (`MVSCE.release.v3.0.0.tar`, 199 MB). Release order: 2.1.4
> (2026-07-08) → 2.1.5 (2026-07-13) → 3.0.0 (2026-08-01).
>
> **The move is worth it:** as of the current level, `jcl/customize.jcl`
> installs **OPNTERSE, UFSD, FTPD, HTTPD and MVSMF** by default at sysgen time —
> so the agent's main channel is already aboard. **Re-check this document when
> changing release**: device addresses, scripts and paths may differ.

---

## 1. How MVS/CE 2.1.4 is laid out

📄 *read from `MVSCE.release.v2.1.4.tar`*

```
MVSCE/
├── conf/
│   ├── local.cnf              # main Hercules configuration — do not edit
│   ├── mvsce.rc               # start script: IPL + hao automation
│   └── local/custom.cnf       # ► our own additions go HERE
├── DASD/                      # mvsres.3350, mvs000.3350, smp000.3350,
│                              # work00/01.3350, syscpk.3350, spool1, page00,
│                              # pub000.3380, pub001.3390, sortw1-6.2314
└── MVP/                       # package manager with add-on software
```

As shipped, `conf/local/custom.cnf` holds only the comment *"This conf file can
be used to add custom configs"* — that is the intended place for everything we
add. `local.cnf` stays untouched so an MVS/CE update does not collide with our
changes.

### Device addresses that matter

| Address | Type | Purpose |
|---|---|---|
| `0010` | 3270 | master console (via `CNSLPORT 3270`) |
| `0009` | 3215-C | alternate console — **required for automation** |
| `0015` | 1403 | hardcopy of the master console → `mvslog.txt` |
| `000C` | 3505 | card reader, sockdev `localhost:3505`, **ASCII** |
| `001A` | 3505 | card reader, sockdev `localhost:3506`, **EBCDIC** |
| `000D` | 3525 | JES2 card punch → `punchcards/pch00d.txt` |
| `0150` | — | IPL volume (`mvsres`) |

Further essentials from `local.cnf`: `ARCHMODE S/370`, `MAINSIZE 16`,
`NUMCPU 2`, `CODEPAGE 819/1047`, `OSTAILOR QUIET`.

---

## 2. Starting and IPLing

📄 *derived from `conf/mvsce.rc`*

MVS/CE ships a start script for this:

```sh
cd /path/to/MVSCE
./start_mvs.sh          # = hercules -f conf/local.cnf -r conf/mvsce.rc -o hercules.log
```

`mvsce.rc` performs the IPL itself:

```
facility enable HERC_TCPIP_EXTENSION
facility enable HERC_TCPIP_PROB_STATE
facility enable herc_370_extension
IPL 150
hao tgt input for console 0:0009
hao cmd /
hao tgt $HASP426 SPECIFY OPTIONS - HASP-II, VERSION JES2 4.1
hao cmd /r 0,noreq
```

What is notable here — and the reason an agent can achieve anything at all at
this level: **`hao` is the Hercules Automatic Operator.** It reacts to console
messages with predefined commands. MVS/CE already uses it to answer `$HASP426`
with `/r 0,noreq`. The same mechanism is open to us for our own automation.

### When a CLPA is needed

After any change to `SYS1.LPALIB` — following `ZCPYJES`, say — the next IPL has
to rebuild the link pack area. Answer the `IEA101A` message with:

```
/r 0,clpa
```

📄 Whether `mvsce.rc` already catches this is **❓ open** — check on the first
IPL and record it here.

### After the IPL: start HTTPD

⚠️ **This is the most important step after every IPL.**

```
/s HTTPD
```

MVS/CE does not start the web server by itself, and **mvsMF runs as a CGI module
under HTTPD**. While HTTPD is down the agent has no main channel: no submitting
jobs, no status, no spool.

This is not an oversight on our side but the project's intent. The MVS-sysgen
documentation says so explicitly: the packages are installed *"but not
started"*. There is no `S HTTPD` anywhere in the repository — not in `COMMND00`
(which holds only `S NET` and the JES2 parms), not anywhere else. Starting them
is left to the operator.

An ordering follows from this that an agent must know: immediately after the IPL
**only** the Hercules console is available. So the fallback in section 3b is not
merely a contingency — it is the only route by which HTTPD can be started at
all. Without the web console enabled, nothing can be automated after an IPL.

### Accepting an IPL as successful

An agent needs a machine-checkable criterion, not a look at the screen.
Proposal, **❓ to be confirmed on the first run**:

1. Check `mvslog.txt` (the hardcopy from device `0015`) for the startup messages
2. JES2 is up once `$HASP492` has appeared
3. TSO is up once the `TSO` procedure has started
4. `/s HTTPD` issued and acknowledged
5. Cross-check: an mvsMF request answers — **that is the real acceptance
   criterion**, because only then is the agent's channel open

**The negative criterion matters more than the positive one:** a wait state or a
hung IPL shows up as an *absence* of messages. The agent therefore needs a
**wall-clock cap** — if no expected message arrives within n minutes, the IPL
counts as failed and is escalated rather than waited out.

---

## 3. Three ways to issue commands

### a) mvsMF — the normal route for the agent ✅ *procedure documented, setup ❓*

The z/OSMF REST API. It covers submitting jobs, polling status, fetching spool
output, reading and writing data sets, and issuing console commands.

For an agent this is the preferred route: structured answers, no screen content
to parse.

Two things to know:

- **`retcode` needs `NOTIFY=` on the job card.** `HASPSSSM` writes `JCTCNVRC`
  only for jobs that requested a notify. MVS/CE ships the usermod `SYZJ201`
  needed for that.
- **Nobody has to handle it:** mvsMF adds `NOTIFY=$MVSMF` automatically to any
  submitted job card that carries none. A card with its own `NOTIFY` is left
  alone.

### b) The Hercules web console — the fallback 📄 *syntax from the Hercules source*

When mvsMF is not running — not installed, crashed, or the system has only just
come up — Hercules' HTTP console remains.

**It is not enabled in MVS/CE 2.1.4.** Add to `conf/local/custom.cnf`:

```
HTTP PORT 8038 NOAUTH
HTTP START
```

Then `http://localhost:8038/` in a browser. Optionally with authentication:
`HTTP PORT 8038 AUTH <user> <password>`.

A constraint from `httpserv.c`: the port must be **≥ 1024** (the only exception
is 80). A lower port is rejected.

This route carries Hercules commands (`ipl 150`, `devinit`, `devlist`,
`stopall`) and, with a `/` prefix, MVS and JES2 commands.

### c) tn3270 to the master console — manual operation

`CNSLPORT 3270`, device `0010`. For anything a human wants to see.

### Hercules command or MVS command?

At the Hercules console:

| Input | Goes to |
|---|---|
| `ipl 150`, `devinit`, `devlist` | Hercules |
| `/d a,l`, `/r 0,clpa`, `/$dj1` | MVS or JES2 |

The `/` prefix is the difference. Forget it and you are talking to the wrong
recipient — usually harmless, occasionally not.

---

## 4. Submitting jobs

📄 *derived from `local.cnf`*

**Through mvsMF** (preferred): `PUT /zosmf/restjobs/jobs`.

**Through the card reader** as a fallback: MVS/CE has two sockdev readers —
`000C` on `localhost:3505` (ASCII) and `001A` on `localhost:3506` (EBCDIC). JCL
is simply written to the port:

```sh
cat job.jcl | nc localhost 3505
```

**Through `devinit`** from the Hercules console, as is usual in Dave's
instructions and at Moseley:

```
devinit 000C /path/to/job.jcl
```

---

## 5. Mounting a tape

📄 Needed for Dave's `BLDMVS.AWS`.

```
devinit 0480 /path/to/BLDMVS.AWS
```

❓ Whether MVS/CE has a tape drive at `0480` is **still to be checked** — Dave's
instructions assume it for TK3/TK4-. If not present, add it in
`conf/local/custom.cnf`.

---

## 6. Instances on `mvsdev.lan`

✅ *set up 2026-09-04; ports verified reachable from the Mac*

Three MVS/CE instances run on **`mvsdev.lan`**, each Hercules in its own tmux
session, plus an older `~/MVSCE`.

| Instance | 3270 | FTP | HTTP (mvsMF) | Herc console | Access |
|---|---|---|---|---|---|
| `MVSCE-DEV` | — | — | — | — | **OFF LIMITS.** The user's development box |
| `MVSCE-LAB` | 3272 | 2122 | **8082** | 8282 | ours |
| `MVSCE-EXP` | 3273 | 2123 | **8083** | 8383 | ours |
| `~/MVSCE` | — | — | — | — | **OFF LIMITS.** An older instance, running |

> ⚠️ **Note the naming.** Earlier drafts of this plan spoke of `mvsce-src` and
> declared `mvsce-lab` off limits. That is obsolete and reversed: **`MVSCE-DEV`**
> is the untouchable one, and `LAB` belongs to this project.

All eight ports answer from the Mac. mvsMF responds on both HTTP ports:

```
$ curl -u IBMUSER:SYS1 -H "X-CSRF-ZOSMF-HEADER: x" http://mvsdev:8082/zosmf/info
{"zosmf_version":"1.0.0-dev","api_version":"1","zos_version":"MVS 3.8j", ...}
```

Credentials are the MVS/CE defaults: `IBMUSER`/`SYS1`, `MVSCE01`/`CUL8TR`,
`MVSCE02`/`PASS4U`. Without them `/zosmf/info` answers 401, which is a useful
liveness signal in itself — 401 means mvsMF is registered, 404 means only HTTPD
is up.

### ⚠️ `retcode` is null on LAB/EXP — the mvsMF level in MVS/CE

Measured 2026-09-04. A job submitted to `MVSCE-LAB` reaches `status: OUTPUT` but
`retcode` stays `null`. Across the whole system: **0 of 14 jobs have a retcode.**

The same test against the user's `MVSCE-DEV` (`:8080`) returns
**430 of 576 jobs with a retcode** — `MBTDEPL JOB02605 OUTPUT retcode='CC 0000'`.
On DEV the ones without are STCs and TSU sessions, which carry no `NOTIFY`; that
is the documented behaviour.

So the difference is the **mvsMF build**, and the two report themselves
differently:

| | DEV `:8080` | LAB `:8082` |
|---|---|---|
| `zosmf_version` | `"1"` | `"1.0.0-dev"` |
| `plugins` field | present | absent |

What was ruled out along the way:

- **Not the client.** curl, the card reader (`000C` on `localhost:3525`, entirely
  bypassing mvsMF) and `zowe zos-jobs submit --wait-for-output` all return null.
- **Not a one-step query.** Individual job status polled in a second step returns
  `{"status":"OUTPUT","retcode":null}`.
- **Not the missing `NOTIFY` auto-injection.** The mvsMF level in MVS/CE does not
  add `NOTIFY` by itself, but the test job carried one explicitly and `JESJCL`
  confirms JES2 saw it:

  ```
  //TSTZOWE  JOB (ACCT),CLASS=A,MSGCLASS=H,NOTIFY=IBMUSER,
  //         USER=IBMUSER,PASSWORD=   GENERATED BY MVSMF
  ```

- **Not a missing usermod in the sysgen.** `SYZJ2001` is in `sysgen.py`'s
  `usermods` list and has been since 2021.

**Why it matters:** `retcode` is how an agent learns whether an MVS job
succeeded. Until LAB and EXP run a current mvsMF, every job needs its spool
output parsed instead — workable, but fragile and slow.

**The fix is the one already planned:** update mvsMF (and HTTPD) on these
instances through MVP, or move to an MVS/CE that ships a current one. See
`../TODO.md` items 1b–1d.

### Why two instances for this project

Because the two jobs would block each other. The SMPWRK3 analysis consists of
**deliberately running large APPLYs until the failure appears** — for Dave a run
took a good two hours, and the result is a broken system. Running that on the
same instance where we verify PTFs would stall verification constantly.
`MVSCE-EXP` is the throwaway; `MVSCE-LAB` is where verification happens.

### The baseline is not an instance

⚠️ **An important distinction.** The baseline from M0 is a **frozen,
checksummed set of volume files that never runs** — no running system, no tmux
session.

The reason: every IPL changes the volumes. SMF writes, page data sets are used,
JES2 updates its checkpoint, the catalog changes. A system that runs is no
longer an immutable oracle. The instances are created **from** the template; the
template itself stays untouched.

It follows that **resetting has to be cheap and scriptable.** The agent will
break `MVSCE-LAB` regularly — a failed ACCEPT, a hung IPL, a wait state.
"Recreate an instance from the template" therefore belongs here as a procedure,
not as manual work.

### Access rules for the agent

| Instance | Agent |
|---|---|
| `MVSCE-DEV`, `~/MVSCE` | **no access.** The user's own systems |
| `MVSCE-LAB` | full access, may break |
| `MVSCE-EXP` | full access, is meant to break |
| baseline template | **read-only** |

### Where do the tools run?

The toolchain (`as370`, `cmplmd370`) runs on the **Mac**; Hercules and its DASD
utilities live on **`mvsdev`** (`/usr/local/hercules/bin`). Building Hercules on
the Mac (arm64) failed — the external packages ship prebuilt for x86 only.

That split works well: **extract on `mvsdev`, process on the Mac.** Extraction
needs no running MVS, only the volume files, and it happens once per artifact.
Unpack a pristine release into a scratch directory rather than reading a running
instance's volumes.

### ⚠️ Dave's 3390 mods corrupt free space

Dave's own words: the 3390-2 and -3 modifications on his install tape carry **at
least one defect in the free-space calculation that corrupts a volume's free
space**. His advice: do not put them on a production system.

Concretely, for us:

- His phases 4 and 5 (`DSKK7xx`–`9xx`, `DSKL7xx`–`9xx`) contain exactly those
  extensions. Anyone running his build brings them along.
- The most likely occasion is the **SMPWRK3 reproduction** — which is what
  `MVSCE-EXP` is for.
- Dave's build and his 3390 mods have **no business** on `MVSCE-LAB`, and
  certainly none on `MVSCE-DEV`.
- Our actual way of working is unaffected: we read his **source** and assemble on
  the host.

### Still to be settled

- [ ] tmux session names and start scripts per instance
- [ ] Write and test the "recreate an instance from the template" procedure
- [ ] Decide where the baseline template lives and how checksums stay consistent

## 6b. Creating an instance from the template

Everything that writes — APPLY, ACCEPT, `ZCPY*`, IPL — runs on an instance,
never on the template.

```sh
cp -R MVSCE-template MVSCE-LAB   # copy DASD/ along
```

Use a separate Hercules configuration in the copy so the template volumes are
never picked up by accident — that is the most common way to destroy a baseline.

**Rule for the agent:** read from the template (`dasdls`, `dasdpdsu`, shut
down), write exclusively to `MVSCE-LAB` or `MVSCE-EXP`.

---

## 7. Fetching load modules without a running MVS

📄 The core of the host-side way of working. Tools from `~/repos/hyperion`
(still to be built).

```sh
dasdls   -info mvsres.3350                      # data sets on the volume
dasdpdsu mvsres.3350 SYS1.LPALIB                # extract members individually
dasdcat  mvsres.3350 "SYS1.PARMLIB(IEASYS00)"   # look at one member
file370 -v IKJPTGT                              # ESD, CSECTs, IDRs
```

⚠️ **Only with Hercules shut down.** A running MVS and a `dasd*` tool reading the
same file at the same time give inconsistent results.

---

## 8. Shutting down

📄 *read from `MVSCE/SCRIPTS/SHUTDOWN.RC`*

⚠️ **Stop HTTPD first — `SHUTDOWN.RC` does not know it.**

```
/p HTTPD
```

The shipped script brings down neither HTTPD nor FTPD nor mvsMF. Without this
step the web server is run over by the quiesce.

This holds for **the project's current level too**: `HTTPD`, `FTPD` and `MVSMF`
appear nowhere in `SCRIPTS/SHUTDOWN.RC` in the MVS-sysgen repository. The
packages are installed by default now, but the shutdown script knows nothing
about them. Worth reporting upstream (see [`../TODO.md`](../TODO.md), item 1d).

Then the shipped script — **do not shut down by hand**, MVS/CE brings a complete
procedure. At the Hercules console:

```
script SCRIPTS/SHUTDOWN.RC
```

The script first sets `hao` rules that steer the rest of the sequence, then
kicks off the quiesce steps:

| Trigger | Reaction |
|---|---|
| `HASP099` | `script SCRIPTS/pjes2` — stop JES2 |
| `HASP085` | `script SCRIPTS/zeod` — `Z EOD` |
| `IEE334I` | `script SCRIPTS/quiesce` |
| `HHC00814I … SIGP Stop` | `script SCRIPTS/poweroff` |
| `nn IKT010D` | `/R nn,FSTOP` |

The quiesce steps before that, in order: `$CA,ALL` (cancel automatic commands),
`SWITCH SMF`, `MODIFY TSO,USERMAX=0` (no new logons), `$PI` (initiators),
printers/punch/readers individually, `STOP TSO`, `HALT net,quick`.

**This is also the template for our own automation.** MVS/CE shows exemplary use
of `hao` here: wait for a message, react to it, rather than setting blind pauses.
Anyone building sequences for the agent should do the same.

⚠️ At the Hercules console, `quit` ends the emulator immediately — the equivalent
of pulling the plug if MVS was not shut down cleanly first.

---

## 9. What an agent may do

| Allowed | Not allowed |
|---|---|
| **Read** baseline volumes (`dasdls`, `dasdpdsu`, `dasdcat`) | Write to baseline volumes |
| Start a clone, IPL it, submit jobs, read the console | Work on the human's working system |
| APPLY/ACCEPT on the clone | Promote to anything other than the clone |
| Escalate after the wall-clock cap when an IPL does not succeed | Wait indefinitely for a message |
| `/s HTTPD` after IPL, `/p HTTPD` before shutdown | Run the shutdown without stopping HTTPD first |
| Anything on `MVSCE-LAB` and `MVSCE-EXP` | **Touch `MVSCE-DEV` or `~/MVSCE`** — those are the user's own systems |
| Dave's build and his 3390 mods **only** on `MVSCE-EXP` | Put them on any system whose volumes matter — they corrupt free space (see above) |
| Recreate a broken instance from the template | Write to the baseline template |
| Correct this file when a procedure turns out wrong | Silently run a procedure differently from what is written here |

---

## 10. Still to be settled

- [ ] Does `mvsce.rc` already catch `IEA101A`, or is `/r 0,clpa` needed manually?
- [ ] Is there a tape drive at `0480`?
- [ ] Define the machine-checkable acceptance criterion for a successful IPL and
      record it here
- [ ] Define the wall-clock caps for IPL and for jobs
- [ ] Collect `hao` rules for our own automation cases — `SHUTDOWN.RC` is the
      template
- [ ] Go through the scripts under `MVSCE/SCRIPTS/`; more operational knowledge
      probably sits there and belongs here
- [ ] Document the mvsMF setup on the local MVS/CE (port, start, check)
- [ ] **Extend `SHUTDOWN.RC` with HTTPD** rather than issuing `/p HTTPD` by hand
      every time — either our own copy of the script or an additional `hao` rule.
      Until that is done, the manual step belongs in every shutdown procedure
- [ ] Check whether `/s HTTPD` can be hung off the IPL via `hao`, so the agent's
      channel opens without intervention
- [ ] Move to **v3.0.0** and re-check this document
- [ ] After the move, establish **which HTTPD and mvsMF levels** are baked in.
      mvsMF's console services need `httpd ≥ 4.0.0-dev` (the `cgictx` API) per its
      own README

## Related documents

- `~/repos/mvs/REFCARD.md` — operations cheat sheet for the **public demo
  systems** (TK5 and MVS/CE on the Hetzner server). A different setup from this
  one, but the commands and the console logic are the same.
- `~/repos/mvs/jes2-commands.md` — the complete JES2 operator command reference,
  extracted from `HASPCOMM`.
