# Dave Kreiss' build environment on `MVSCE-LAB` — install log

2026-09-09. Steps 1–5 of *Build MVS From Source Instructions* v2.1 are done. This
records what the document says, what it does not say, and what had to be different
here — so the next person does not re-derive it.

**Machine: `MVSCE-LAB`** — 3270 3272, FTP 2122, mvsMF 8082, Hercules console 8282,
tmux window `0:1` on `mvsdev`. **`MVSCE-EXP` is untouched on purpose**: it produced
all 5,528 IFOX00 reference decks, and an APPLY of Dave's 2,221 PTFs would destroy
the reference every gate figure since 2026-09-07 is measured against.

## What is on the machine now

| | |
|---|---|
| twelve 3390-1 volumes `BLDDLB`…`BLDWK2` at 192–19D | `PRIV/RSERV` |
| `BLDMVS.AWS`, 190 MB, SHA256 verified against the copy in `MVSSRC` | mounted at **0100** |
| `MVSSRC.BLD.*` — 15 datasets on `BLDSMP` | loaded, `COPY` step `CC 0000` |

```
MVSSRC.BLD.SMP.JCL   .JCL1 .JCL2 .JCL3 .JCL4 .JCL5
MVSSRC.BLD.SMP.LIB   .LIB1 .LIB2 .LIB3 .LIB4 .LIB5
MVSSRC.BLD.NEW.ASM   MVSSRC.BLD.MVT.ASM   MVSSRC.BLD.UTILITY.ASM
```

## Four things the document does not tell you

**1. No IOGEN is needed — the addresses are already there.** `D U,,,192,12` before
any change shows 192–19D as **3390 OFFLINE**. MVS/CE has them genned; they only
need Hercules devices behind them and the VATLST00 entries.

**2. `attach` works without a Hercules restart, but the volumes still need the
IPL.** Attaching all twelve live and issuing `V 192-19D,ONLINE` leaves them
`O … /REMOV` — online, label read, *not mounted*. Individual
`M unit,VOL=(SL,volser)` sometimes takes and sometimes does not
(`IEE335I MOUNT VOL PARAMETER MISSING`). **After the IPL all twelve come up
`PRIV/RSERV` by themselves**, from VATLST00. Dave's Step 4 is not optional; it is
just not explained.

**3. VATLST00 alignment: follow the file, not the PDF.** The document shows eight
spaces before `,N`; `SYS1.PARMLIB(VATLST00)` on this system uses four, with the
comma at **column 20** and the flag at **21**. Its own note says to watch the `,N`
alignment — so match the existing entries column for column, not the printed
example. Entries added as `BLDxxx,1,2,3390    ,N` (reserved, **private**).

**4. There is no device at 480.** Dave puts the install tape there and the JCL
says `UNIT=480`. On MVS/CE `D U,,,480,4` comes back **empty**, and the job fails
with

```
IEF210I BLDCOPY COPY JCLI - UNIT FIELD SPECIFIES INCORRECT DEVICE NAME
```

MVS knows tapes at **100–103** (2400, online) and 200–203 / 210–213 (offline);
Hercules has 3420s at 0100–0103 and 0310–0313. So: `devinit 0100 tapes/BLDMVS.AWS`
and `UNIT=480` → `UNIT=100` throughout the JCL. Fifteen occurrences.

## Two things about the job itself

**`MSGCLASS=H`.** Dave's card says `A`; with `A` the output is printed and purged
and the job cannot be read back through the API.

**`CC 0008` is the expected result of a first run.** The `DELETE` step is IDCAMS
deleting datasets that do not exist yet. The step that matters is `COPY`, and it
reports `CC 0000`.

## The mistake worth recording

I restarted Hercules **detached**, with `setsid nohup ./start_mvs.sh`, instead of
in its tmux window — so the instance ran where Mike could not see or drive it. It
belongs in `0:1`:

```sh
tmux send-keys -t 0:1 "cd ~/MVSCE-LAB && ./start_mvs.sh" C-m
```

And after every IPL, **`/S HTTPD` and `/S FTPD`** — `mvsce.rc` does not start them,
and without `HTTPD` there is no mvsMF on 8082 and no way to submit anything.

While chasing that I also convinced myself a stray Hercules was respawning from
`/home/mike`. It never existed: `pgrep -f "hercules -f conf/local.cnf"` **matched
its own command line** — the shell running the pgrep contained the pattern. Use
`ps -eo pid,args` and filter, or match on something the query cannot contain.

## Next

**Step 6** — the SMP build job streams, starting with the Basic phase. Per the
document the Basic phase *does not alter the running system*; it writes under
`MVSSRC.BLD`. Phase 1 onward updates `SYS1.LINKLIB` of the running system and is
the point at which `MVSCE-LAB` stops being restorable from anything but a backup.
