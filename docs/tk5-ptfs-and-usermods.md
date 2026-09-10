# What TK5 carries that MVS/CE does not — PTFs and USERMODs

2026-09-10. If TK5 becomes the object baseline
([`smp-tk5-vs-ce.md`](smp-tk5-vs-ce.md), [`dlib-distance-tk5-ce.md`](dlib-distance-tk5-ce.md)),
the recovered source inherits its maintenance. This is the inventory of that
maintenance — every PTF and USERMOD TK5 holds — with, where the system still
carries it, what each one does and where it came from. It answers two questions:
what would we be taking on, and why was it never carried into CE.

The two lists in full:
[`tk5-ptf-list.tsv`](../work/measurements/smp-inventory/tk5-ptf-list.tsv) (712
PTFs) and
[`tk5-usermod-list.tsv`](../work/measurements/smp-inventory/tk5-usermod-list.tsv)
(115 USERMODs), each with component, applied/accepted state, whether CE has it,
and — for USERMODs — source and description.

## The gap is almost entirely PTFs, not USERMODs

The framing "TK5 has all these mods CE never pulled in" is only half right. The
USERMODs largely **overlap**: of TK5's 115, CE has 96; only 31 are TK5-only and
12 are CE-only. The two turnkey lineages share their base modification set (the
3380/3390 DASD support, RAKF, the Greg Price collection, Winkelmann's core).

The real divergence is the **PTFs**: TK5 carries 712, CE 89. **625 PTFs are on
TK5 and not on CE**; only 2 are the other way. That is the maintenance CE never
pulled in, and it is IBM's own component service, not community modification.

## The PTFs — IBM component maintenance

These are IBM APAR corrections to the base components. TK5's 625-PTF lead, by
component:

| PTFs (TK5-only) | Component |
|--:|---|
| 239 | Data Management (EDM1102) |
| 94 | Base Control Program (EBB1102) |
| 52 | Mass Storage System (EMS1102) |
| 44 | Utilities (EUT1102) |
| 33 | MVS Processor Support 2 (FBB1221) |
| 28 | BTAM (EBT1102) |
| 12 | Device Support Facility / ICKDSF (FDZ1610) |
| 12 | Program Management (EPM1102) |
| 11 | XF Assembler (EAS1102) |
| … | (17 more components, full split in the TSV) |

Every PTF's component, applied/accepted state and the modules it replaces are in
[`tk5-ptf-list.tsv`](../work/measurements/smp-inventory/tk5-ptf-list.tsv). The
per-PTF APAR text is **not** recoverable from the system — SMP purges the PTS
cover letter on ACCEPT, and only 3 PTFs (the RAKF `RRKF00x`) still have theirs.
The authoritative per-APAR descriptions live in Jay Moseley's
[PTF cross-reference](https://www.jaymoseley.com/hercules/mvs_ptfs/ptfxref.htm),
keyed by the same `UZ…`/`UY…` numbers; joining the full 625 against it is a
separate task, offered but not done here.

**These are not optional.** A PTF is IBM fixing IBM's own defect. A faithful
"MVS from source" at TK5's level *is* the serviced level — leaving 625 IBM
corrections out would recover an OS that IBM had already superseded. The
recommendation is to take the PTF set wholesale; the only real work is ensuring
each stays installable (see [`smp-tk5-vs-ce.md`](smp-tk5-vs-ce.md)).

### Getting per-PTF descriptions — what works and what does not

The obvious source, Jay Moseley's
[PTF cross-reference](https://www.jaymoseley.com/hercules/mvs_ptfs/ptfxref.htm),
**does not work for this**, and the control says why. It is a *multi-release*
index (MVS 3.8, MVS/SP, MVS/ESA, OS/390, z/OS): each row is `PTF | FMID |
records | tape`, one FMID per PTF, and for our PTF numbers that FMID is usually a
**later release's**. Joining TK5's 712 PTFs by number: 409 appear in the index,
but only **86** carry an FMID that matches the MVS 3.8 FMID measured on TK5 — the
other 323 resolve to `HBB2102`, `JBB1313`, `JDM1138`, … (MVS/SP and later). So
`UZ61346`, which TK5 holds against `EDM1102` (MVS 3.8 Data Management), shows in
the index under `JDM1138`. Matching by PTF number alone pulls the wrong release's
row four times out of five; a description taken from it would be wrong. The join
was attempted and discarded.

What *is* authoritative is already in the list: the **component** and the
**modules each PTF replaces** are read from TK5's own SMP zones
([`tk5-ptf-list.tsv`](../work/measurements/smp-inventory/tk5-ptf-list.tsv)), so
"which part of the OS, which modules" is answered per PTF. What is missing is the
APAR prose, and the only reliable source for it is the **++PTF cover letter** on
the original IBM MVS 3.8 PTF tapes — purged from both running systems on ACCEPT
(only the 3 RAKF `RRKF00x` still carry theirs). Recovering the prose means
obtaining those tapes and reading the cover letters out; that is a separate
acquisition task, not a lookup, and is deliberately left open rather than filled
with a mismatched index.

## The USERMODs — community modification

Here the "take all, or leave to the user" question is real, because these are
enhancements, not corrections, and they group by author and purpose. The
families (full list with descriptions in
[`tk5-usermod-list.tsv`](../work/measurements/smp-inventory/tk5-usermod-list.tsv)):

| Family | Source | On CE? | What it is |
|---|---|:--:|---|
| `M023xxx` / `M024xxx` (27) | community | yes | **3380 / 3390 large-DASD support** — the modern-disk enablement the whole ecosystem depends on |
| `ZP60xxx` (41) | **Greg Price** (Prycroft Six) | mostly | low-level system & assembler enhancements: XF assembler extensions (blank lines, BAS/BASR, larger ESD), CLIST extensions, `&SYSUID` in JCL, indirect cataloging, GETMAIN `LOC=`, JES2 status, SIO/SVC tracing, LOGREC fixes |
| `ZJWxxxx` (10) | **Jürgen Winkelmann** (TK4-/TK5) | partly | the turnkey core: TSO pre-logon exit, WTO automation, SNA LU1/2 fixes, subsystem-name regen, **24 PFKeys on 3270 consoles** |
| `SYZJ201/202` | **Brian Westerman** (Syzygy) | yes | JES2 maximum-condition-code SYSMODs |
| `TC01xxx` (5) | community | no | **TSO/TCAM 3270 full-screen** — 3278 mod-4 / alternate screen size / SNA LU2 fullscreen |
| `RP000x` (4) | **Rob Prins** (TK5) | no | fixes: AMDPRDMP dump, IEAVTSDH dump count, 3380/3390 cylinder count, a RAKF RACDEF return code |
| `ZBP000x` (3) | community | no | VM/JES2 integration: VM CP CLOSE on JES2 printers, `VMCPCMD` utility, VTAM logmode tables |
| `RRKFxxx`, `RAK0001` | RAKF | split | RAKF security enhancements (unsorted profile members, tooling) |
| `ZUMxxxx` (6) | community | partly | miscellany incl. Michael Koehne's **Y2K** patch (`ZUM0007`) |
| `#DYPxxx` (5), `SLBxxx`, `AY12275`, `VS49603`, `WM00017`, `MS00100` | community / IBM APAR | mostly | assorted single fixes (e.g. `VS49603`: the `IEE331A` disabled-spin-loop fix; `WM00017`: JES2 `$DP`/`$U` commands) |

The 31 USERMODs unique to TK5 are mostly **Winkelmann's TSO/console enhancements
(`ZJW0004`–`ZJW0012`)**, the **TCAM 3270 full-screen family (`TC01xxx`)**, the
**VM/JES2 mods (`ZBP`)**, **Rob Prins' fixes (`RP`)** and a few Greg Price items.
CE's 12 unique ones are a different curation — `JLM000x`, `NJE0001` (NJE
networking), `RAK0001`, `TIST801`/`TTSO801`/`TMVS804`.

### Take, or leave to the user?

Three tiers, by nature rather than by author:

- **Essential infrastructure — take.** 3380/3390 DASD support (`M02xxxx`), RAKF,
  the Y2K patch. Without these the system is not usable on modern Hercules; both
  turnkeys already carry them, and CE has them too.
- **Broadly-relied-on enhancements — take, but they are a choice.** Greg Price's
  `ZP60` collection and Winkelmann's core. Much of the MVS 3.8j world assumes
  these are present (the XF assembler blank-line fix, for one, matters directly
  to *this* project's assembler work). Leaving them out is defensible only if the
  recovery deliberately targets stock IBM behaviour.
- **Site conveniences — reasonable to leave to the user.** TCAM 3270 full-screen,
  VM/JES2 integration, the JES2 command add-ons. These change how an operator
  works, not what the OS computes, and can sit in an optional layer.

## Why did CE never pull the PTFs in?

Not an oversight — a build philosophy. MVS/CE is a **fresh Jay Moseley sysgen**:
it assembles the base MVS 3.8 from source and applies a **deliberately small,
curated** SYSMOD set (39 accepted PTFs) plus the mvslovers stack. Its DLIB
objects are dated 2026 because it built them; it started near stock MVS 3.8 and
added only what the sysgen needs.

TK5 is the opposite: the **accumulated** state of the TK3 → TK4- → TK5 turnkey
lineage, twenty years of the community applying every IBM PTF and every useful
modification on top of the last. Its DLIB objects keep their **original 1984**
dates because they were never re-assembled — they are the shipped, serviced
objects carried forward.

So CE did not "fail to pull in" 625 PTFs; it was never built to include them. It
is a lean, reproducible-from-source system. TK5 is a maintained, accreted one.
For a recovery whose oracle is TK3-level object code
([`kreiss-project.md`](kreiss-project.md)), TK5's accreted state is the closer
match — which is the argument for the base decision that
[`dlib-distance-tk5-ce.md`](dlib-distance-tk5-ce.md) leaves to the source probe.
