# SMP inventory: TK5 vs MVS/CE

2026-09-10. A full comparison of the SMP4 state of the two candidate systems for
the "MVS from source" object baseline:

| Short name | System | Endpoint (mvsMF) |
|---|---|---|
| **TK5** | `drnmig3a` — Turnkey MVS 3.8j, Rob Prins' TK5 | `drnmig3a.neunetz.it:80` |
| **CE** | `mvsdev` — MVS/CE (Jay Moseley sysgen, distribution 2.1.x/3.0.0) | `mvsdev.lan:8080` |

The question behind it: **which system becomes the object oracle** for the
recovery, and **which PTFs must stay installable** whichever one we pick. Dave
Kreiss' own baseline was the object code of a **shipped Turnkey TK3** system
([`kreiss-project.md`](kreiss-project.md)) — a heavily maintained turnkey, so how
close each candidate sits to a TK-level maintenance state is the crux.

## How this was measured

The same read-only job was submitted to **both** systems — identical JCL, no
proc (TK5's `SMPAPP` does not exist on CE, so the proc route would already make
the samples non-comparable), `SMPLOG DD DUMMY`, no target/DLIB DD allocated:

```
//SMPDSL   JOB ...
//LIST    EXEC PGM=HMASMP,PARM='DATE=U',REGION=5120K
//SMPLIST  DD  DSN=<hlq>.SMPLIST.DATA,DISP=(,CATLG,CATLG),
//             UNIT=SYSDA,SPACE=(CYL,(80,40),RLSE),
//             DCB=(RECFM=FBA,LRECL=121,BLKSIZE=6050)
//SMPCDS/SMPACDS/SMPSCDS/SMPCRQ/SMPACRQ/SMPPTS/SMPMTS/SMPSTS  DD DISP=SHR,...
//SMPCNTL  DD  *
 LIST ACDS SYSMOD .
 LIST CDS  SYSMOD .
 LIST ACDS MOD .
 LIST CDS  MOD .
```

`LIST <zone> SYSMOD .` and `LIST <zone> MOD .` are the only valid forms —
`SYSMODS`, `ALLSYSMOD`, `DLIB`, `DLIBS` all return `HMA2033` (measured on CE).
LIST output goes to **SMPLIST**, not SMPOUT. `CDS` is the applied (target) zone,
`ACDS` the accepted (DLIB) zone.

**Controls that were run** before believing the numbers:

- `LIST ACDS SYSMOD(EBB1102)` on CE returns `TYPE=FUNCTION, STATUS=REC ACC RGN`,
  as expected for the base BCP — the case whose answer is already known.
- The output was collected two independent ways (JES spool stream and a
  catalogued dataset read) on CE; both delivered **exactly** 165,959 lines and
  parsed to identical counts. TK5's older mvsMF returns the huge spool as a
  0-byte body, so the **dataset** path is the one that works on both.
- Every fetch is checked against the record count the file listing declares, and
  against the SMP end-of-run message, so a truncated read cannot pass as a
  finding.
- A dataset carries an ASA carriage-control byte in column 1 that the spool does
  not; the parser strips it (`strip_cc`) and the dataset parse then matches the
  spool parse on all four zone counts.

Raw parsed data is under
[`../work/measurements/smp-inventory/`](../work/measurements/smp-inventory/):
`tk5-sysmod.tsv`, `ce-sysmod.tsv`, `tk5-mod.tsv`, `ce-mod.tsv` (full parses),
plus the comparison tables named below.

## "Level 8505" is branding, not a measured level

TK5's logon screen reads *"MVS 3.8j Level 8505 - Update 5"*. **That string does
not appear anywhere in the SMP inventory.** There is no `SOURCEID` field in
either system's data (zero lines), and the only `8505` substrings in the dump
are inside PTF ids such as `AZ48505` and `UZ68505`. "8505" is Rob Prins' TK5
version label — *"OS/VS2 MVS 3.8j Service Level 8505 - Turnkey Level 5"*, a claim
that PTFs to a ~1985 currency are applied, inherited from the TK3/TK4 lineage. It
is not in Jay Moseley's documents as a measured level either. **Only the actual
PTF/SYSMOD inventory below says anything verifiable about the maintenance state.**

## 1 — FMID inventory

31 IBM FMIDs are installed **identically** on both systems — the whole MVS 3.8
base plus 3800 support:

```
EAS1102 EBB1102 EBT1102 EDE1102 EDM1102 EDS1102 EER1400 EGA1102 EGS1102
EIP1102 EJE1103 EMF1102 EMI1102 EML1102 EMS1102 EPM1102 EST1102 ESU1102
ESY1400 ETC0108 ETI1106 ETV0108 EUT1102 EVT0108 EXW1102
FBB1221 FDM1133 FDS1122 FDS1133 FDZ1610 FUT1133
```

The product name behind each FMID is in
[`../work/measurements/smp-inventory/fmid-comparison.tsv`](../work/measurements/smp-inventory/fmid-comparison.tsv);
the mapping is from the *Base Program Directory for MVS 3.8J* and IBM APAR
II06271, cross-checked against the module names each FMID owns.

The FMIDs that differ:

| FMID | Product | TK5 | CE |
|---|---|:--:|:--:|
| `TRKF120` | RAKF — RACF-compatible security **v1.2.0** | ✅ | — |
| `TRKF126` | RAKF — RACF-compatible security **v1.2.6** | — | ✅ |
| `MINIGEN` | TK5 mini-sysgen marker (customizations, no modules) | ✅ | — |
| `TUFS120` | UFSD — Unix-like VFS (mvslovers) | — | ✅ |
| `THTP400` | HTTPD — HTTP server (mvslovers) | — | ✅ |
| `TFTP100` | FTPD — FTP server (mvslovers) | — | ✅ |
| `TSMP100` | SMP4 self-test / sample (`SMPTEST`) | — | ✅ |

Two things to read from this. **RAKF is on both, but CE carries the newer
release** (1.2.6 vs 1.2.0) — confirmed by identical module names
(`ICHRIN00`, `ICHSEC00`, `IGC00130`, `RAKFPROF/PWUP/USER`, `CJYRCVT`). And the
**mvslovers stack (ufsd/httpd/ftpd) is SMP-installed only on CE**; TK5 runs the
same servers (mvsMF answers there) but they were installed outside SMP4, so they
carry no FMID. Neither of these bears on the IBM object baseline — they are
add-ons layered on top of it.

`MINIGEN` and the deleted predecessors (`HJE1104` deleted by `EJE1103`, the
earlier `EER11xx` levels deleted by `EER1400`, etc.) are FUNCTION *stubs* — they
carry no status and own no modules. Both systems have 31 real IBM FMIDs; TK5 adds
`MINIGEN` + RAKF, CE adds RAKF + the four mvslovers/test FMIDs.

## 2 — Maintenance depth (applied vs accepted)

`applied` = present in the target zone (CDS). `accepted` = pushed down into the
distribution libraries (ACDS). The DLIB/accepted side is the one that matters for
the object oracle, because that is where the object decks the recovery compares
against live.

| | **TK5** | **MVS/CE** |
|---|--:|--:|
| PTF applied (CDS) | **712** | 89 |
| PTF **accepted (ACDS)** | **709** | 39 |
| USERMOD applied | 114 | 96 |
| USERMOD accepted | 33 | 32 |

**TK5 is deeply and consistently serviced; CE is not.** TK5 has 709 PTFs accepted
into its DLIBs against CE's 39. CE's 89 applied PTFs are mostly target-only — they
were never accepted into its distribution libraries.

Set comparison of the **accepted** PTFs
([`ptf-comparison.tsv`](../work/measurements/smp-inventory/ptf-comparison.tsv)):

| | count |
|---|--:|
| accepted on **both** | 38 |
| accepted **TK5 only** | **671** |
| accepted **CE only** | **1** (`UZ61025`) |

The one accepted USERMOD unique to TK5 is `ZJW0011`; CE has none TK5 lacks.

## 3 — Object versions, module by module

The decisive table for the base decision. Every DLIB module (accepted/ACDS zone)
with its RMID — the SYSMOD that last replaced it — on each system
([`module-versions.tsv`](../work/measurements/smp-inventory/module-versions.tsv)):

| | modules |
|---|--:|
| same RMID on both | 4,508 |
| **RMID differs** | **804** |
| only on TK5 | 2 (`IEFJESNM`, `IFG0199I`) |
| only on CE | 11 (the mvslovers stack + `SMPTEST`) |

And the **direction** of the 804 that differ:

| | modules |
|---|--:|
| TK5 at a PTF level, CE still at base FMID | 193 |
| CE at a PTF level, TK5 still at base FMID | **0** |
| both PTFed, but to different PTF levels | 611 |

**TK5 is never behind CE.** There is no module where CE carries maintenance and
TK5 does not. In 193 modules TK5 is patched where CE is still base; in 611 more
both are patched but to different SYSMOD levels; nowhere is it the other way
round. Per-DLIB counts are in
[`dlib-compare.txt`](../work/measurements/smp-inventory/dlib-compare.txt) — the
DLIB sizes are identical on both systems (same base), only the PTFed fraction
differs, TK5 ≥ CE in every library.

## What this means for the base decision

Dave Kreiss measured against **TK3 object code**, and on TK3/TK4- "most PTFs are
already applied" ([`kreiss-project.md`](kreiss-project.md)). TK5 is the direct
descendant of that TK3 lineage and is the heavily-maintained system here; CE is
the lightly-maintained one. On maintenance currency alone, **TK5 is the closer
match to Dave's oracle** — it is a superset of CE's maintenance at the module
level, never behind it.

But "closer" is not "identical". 611 modules are patched to *different* PTF
levels on the two systems, so neither system's DLIB deck can be assumed to equal
the object Dave's source assembles to. That is a byte-level question, not a
SYSMOD-level one, and it is measured in the companion probe
([`dlib-distance-tk5-ce.md`](dlib-distance-tk5-ce.md)): for the modules that
differ, which DLIB deck — TK5's or CE's — does Dave's assembled source actually
match.

## Installability of the important PTFs

Choosing a base is only half of it: whichever object oracle we pick, the PTFs the
*other* one carries must stay installable, or a later minor cannot be cut. The
concrete lists:

- Pick **TK5** as the base → the one accepted PTF unique to CE (`UZ61025`) must
  be re-applicable, plus CE's target-only PTFs if any are wanted.
- Pick **CE** as the base → **671** accepted PTFs live only in TK5's DLIBs and
  would have to be re-applied to reach TK5 currency. That is the larger and
  riskier gap.

The full applied/accepted matrix for every PTF and USERMOD is in
[`ptf-comparison.tsv`](../work/measurements/smp-inventory/ptf-comparison.tsv) and
[`usermod-comparison.tsv`](../work/measurements/smp-inventory/usermod-comparison.tsv)
(`sysmod`, `tk5_applied`, `tk5_accepted`, `ce_applied`, `ce_accepted`).

## Corrections logged here

- The first pass read "Level 8505" off the TK5 logon screen and presented it as a
  maintenance level. It is branding; it is not in the SMP data. Removed.
- The first pass counted 45 FMIDs on CE; 9 of those are deleted-predecessor stubs
  with no status and no modules. The installed count is 36 on CE, 33 on TK5.
