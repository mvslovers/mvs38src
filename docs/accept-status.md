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
