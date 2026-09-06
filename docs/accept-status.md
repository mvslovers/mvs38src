# Was the maintenance ACCEPTed into the distribution libraries?

2026-09-06. Open since the workplan was written, because the answer decides how
much noise sits between our yardstick and the truth.

## Why it matters

SMP `APPLY` updates the **target** libraries, `ACCEPT` updates the
**distribution** libraries. The workplan chose the DLIBs as the yardstick partly
on the assumption that they carry no usermod layer — *"provided the usermods
were only APPLYed and not ACCEPTed"*, and it said explicitly that this is
recorded in the SMP CDS and should be looked up rather than guessed.

This is the lookup.

## The answer

**The distribution libraries carry essentially the full IBM maintenance.** They
are not at base FMID level.

| Identifier class | Distribution zone | Target zone | target only |
|---|---:|---:|---:|
| `UZ` PTFs | 5,529 | 5,655 | 126 |
| `AZ` APARs | 6,588 | 6,893 | 305 |
| `UR` PTFs | 47 | 47 | 0 |
| `AR` APARs | 329 | 329 | 0 |
| `UY` PTFs | 0 | 13 | 13 |
| `AY` APARs | 1 | 15 | 14 |

38 function SYSMODs are known to both zones — `EBB1102`, `EAS1102`, `EJE1103`,
`EER1200`… the MVS 3.8 base.

**Nothing is in the distribution zone that is not also in the target zone**, as
expected. In the other direction, **139 PTFs (126 `UZ` plus 13 `UY`) appear only
in the target zone** — roughly **2.5 %** of the maintenance.

## What follows

1. **The DLIB yardstick is sound, and better than assumed.** Not because it is
   unmaintained, but because it is maintained *almost identically* to the target
   libraries. The delta between the two is 139 PTFs plus the sysgen and usermod
   layer — a small, bounded and now countable amount of noise.
2. **Our source has to carry that maintenance too.** Comparing against DLIB
   object means comparing against maintained object. Source at base level will
   not match, and the gap this project exists to close is real at DLIB level, not
   only at target level.
3. **The 52 length differences are unlikely to be explained away as
   distribution effects.** That was the hope; with the two zones this close, it
   does not carry. Those differences are more likely to be genuine source gaps.

## How this was measured, and how far to trust it

Both consolidated data sets were read off `smp000.3350` with `dasdcat` and
scanned for SYSMOD-shaped identifiers.

**This is a text scan, not a parse of SMP entry types.** An identifier counted
here appears *somewhere* in that zone's CDS — as a SYSMOD entry, as a supersede
reference, as the APAR a PTF fixes. So the absolute numbers are an upper bound on
"installed" and the `AZ`/`AR` counts are APAR references rather than installed
sysmods at all. What the method does support is the **comparison between the two
zones**, because both were read the same way.

Refining it means parsing the CDS entry structure. Worth doing before any number
here is quoted as "n PTFs are installed"; not worth doing to answer the question
this document was written for.

## A trap that cost the first answer

`dasdpdsu` **cannot read the SMP control data sets.** Their member names are
binary keys, and it derives file names from them: it aborts on the first key
containing a byte that is illegal in a filename.

```
HHC02468E File g:?/k?.mac; fopen error: No such file or directory
HHC00007I Previous message from function 'process_member' at dasdpdsu.c(289)
```

It stops there and reports no failure of its own. The first run of this analysis
therefore ran on **318 of 19,904 members** of `SMPACDS` and **44 of 22,982** of
`SMPCDS` — 1.6 % and 0.2 % — and produced a confident, entirely wrong answer:
26 PTFs in the distribution zone and none at all in the target zone.

What caught it was the shape of the result, not a tool message: a target zone
with zero PTFs is not a finding, it is a broken measurement.

**Use `dasdcat` for anything whose member names are not plain text.** It writes
to standard output and never touches a file name:

```sh
dasdcat -i smp000.3350 "SYS1.SMPACDS/*"     > acds.bin    # all members
dasdcat -i smp000.3350 "SYS1.SMPACDS/*:?"                 # the member list
```

---

## Addendum: the local modification layer, and a route that closes

2026-09-06, later. Two questions followed from the section-length work: how large
is MVS/CE's own usermod layer, and can the SPZAP records be turned from a
correlation into a cause.

### MVS/CE modifies 28 modules, all of them nameable

`SYS1.SMPPTS` holds 3,089 members. Reading them out with `dasdcat` and picking
the sysmod headers:

| | |
|---|---|
| `++ZAP` | **22**: `HEWLFAPT` `HEWLFINT` `HEWLFOUT` `IEAVAD51` `IEAVPRT0` `IECIOSAM` `IEECVETV` `IEFAB4A2` `IEFSD263` `IEFVEA` `IEFVJA` `IFOX0F` `IKJEFF52` `IKJEFLA` `IKJEFT25` `IKT0009C` `IKTCAS41` `IKTIIOM` `IKTLOGR` `IKTVTPUT` `ILRSLOTC` `ISTZBF0L` |
| `++USERMOD` | 1: `ZP60018` |
| `SYS1.UMODSRC` | 5: `IEFACTRT` `IEFU29` `IKJEFF53` `IKJEFTE2` `IKJEFTE8` — SMF and TSO exits |

That is the whole local layer: **28 modules**, listed in
[`../work/measurements/mvsce-local-mods.txt`](../work/measurements/mvsce-local-mods.txt).
The workplan treated it as a large unknown ("Moseley's ~69 usermods"). It is
small and enumerable, and **none of the 28 appears among our 102 pairs** — so
nothing measured so far is affected by it.

### The zap hypothesis cannot be settled from this system

`SYS1.SMPPTS` also carries the zap data itself — `NAME` / `VER` / `REP`
statements with offsets. If a `REP` offset fell on a byte where our deck and the
member disagree, the difference would have a named cause instead of a
correlation.

It does not. **25 CSECTs carry zap instructions, and not one of them is among
the 17 modules that differ.** The zaps in `SMPPTS` are the local layer above; the
IBM-era zaps that left the `X'04'` IDR records in 71 % of the members happened
during IBM's own service process, and their data is not on this system.

So the correlation stays a correlation. Among the length-equal modules, 9 of 11
that differ only inside generated text are zapped, against a base rate of 57 % —
suggestive, mechanistically plausible, and on eleven modules not more than that.

**And it names a limit of the project.** Where IBM changed shipped object with a
zap and never changed the source, no source can assemble to that object. Those
modules are not recoverable in the strict sense; they can only be identified and
their zap reproduced as a separate layer. How many there are is not known — 71 %
of members carry a zap record, but a zap record does not prove the instructions
were changed.

### A note on method

Both readings came out of `dasdcat` over whole data sets. `dasdpdsu` cannot read
`SMPPTS` or the CDS data sets at all — see the trap above — and it silently
truncates rather than failing.
