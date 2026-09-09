# The source volumes Dave's build reads, against our corpus

2026-09-09. Dave Kreiss' build on `MVSCE-LAB` assembles from IBM's distributed
source on four volumes attached at 350–353 — `SRC000`, `SRC001`, `SRC002`,
`SRCCAT`, from TK4-'s `tk4-source.zip`. `mvs38-ibmsrc` is supposed to hold the
same thing, extracted from the distribution tapes. This document measures whether
it does.

**It does.** All 7,206 members on the volumes are byte-identical to a member of
the corpus — over all 80 columns, not merely over 1–72. Nothing on the volumes is
absent from the corpus, and no version the volumes carry is missing from it. The
local corpus is what the build consumes.

## What was compared

| | |
|---|---|
| volume images | `src000.348`, `src001.349`, `src002.34a`, `srccat.34b` |
| read from | `/tmp/tk4src/` on `mvsdev` (the unpacked zip) **and** `~/MVSCE-LAB/DASD/` |
| extraction | `dasdpdsu`, fixed-length EBCDIC, no ASCII translation |
| data sets | 254, plus one VSAM data space (`Z9999994.VSAMDSPC.…`) not unloaded |
| members | 7,206 in 5,927 distinct names |
| records | 11,321,571 |
| corpus | `~/repos/mvs/mvs38-ibmsrc` — `ibm/` 5,927, `variants/` 526, `macros/` 1,146, `ext/` 143 |
| comparison | SHA-256 over columns 1–72 of each 80-byte record, and over all 80 |

The volume side stays raw EBCDIC end to end; nothing is decoded before hashing.
The corpus side is 80-character CRLF latin-1 and is encoded back with `cp037` to
meet it. That round trip was checked separately: for all 7,608 non-`ext` corpus
files, `latin-1 → cp037 → latin-1` returns the original bytes, 0 exceptions.

### The LAB images and the zip are the same content

`md5sum` differs between `~/MVSCE-LAB/DASD/src000.348` and the unpacked
`/tmp/tk4src/src000.348`, which would matter — the question is what the *build*
reads. Both were unloaded and hashed. The two extractions are identical in all
7,206 members: same names, same record counts, same bytes. The `md5` difference
is CCKD container metadata from Hercules having the volume open, not content. The
`/tmp/tk4src` extraction stands for both.

## Result

| verdict | members |
|---|---:|
| byte-identical to the corpus default in `ibm/` | 6,719 |
| byte-identical to a preserved variant in `variants/tape/` | 487 |
| **differing from every corpus copy of the name** | **0** |
| **present on the volumes, absent from the corpus** | **0** |

Full table: [`src-volumes-vs-corpus.tsv`](src-volumes-vs-corpus.tsv), one row per
member with its data set, tape, tape file, record count, verdict and the corpus
path it matched.

Reverse direction:

| | names |
|---|---:|
| `ibm/` names absent from the volumes | **0** |
| `variants/` names absent from the volumes | **0** |
| `macros/` names absent from the volumes | 1,146 |
| `ext/` names absent from the volumes | 12 of 143 |

The 1,146 `macros/` are stben.net's `maclib` and the JES2 `$…` macros — by
construction not on the tapes, so not on the volumes. `ext/` is Gorlinsky's
IFOX00 distribution and the SLAC linkage editor; 131 of its names collide with
tape members and 12 do not. Neither is a gap.

## The data sets map one-to-one onto the tape files

Each data set is named `MVSSRC.<tape>.F<nn>`. The mapping to tape and tape file
was not assumed from the names — it was derived from content and then checked
against them.

Keyed on the set of `(member, record count)` pairs, 246 of the 254 data sets are
forced to exactly one tape file. The remaining 8 are `MVSSRC.SYM501.F01`–`F04`
and `MVSSRC.TIOCOP.F01`–`F04`: tapes `sym5` and `tiocopt` carry those four files
byte-identically, so no content can separate them. The name-based reading
(`SYM101` → `sym1-1`, `SYM501` → `sym5`, `TIOCOP` → `tiocopt`, …) agrees with the
content-forced mapping on all 246, is bijective, and every pair it names exists
in the tape inventory. It is used for the 8.

Table: [`src-volumes-dataset-map.tsv`](src-volumes-dataset-map.tsv).

An earlier version of this mapping keyed on member *names* alone and silently
mis-assigned `MVSSRC.ET1102.F02` to `tiocopt/FILE0002`, because `etc1102`,
`sym5` and `tiocopt` share that file's member list. The error surfaced as seven
record-count mismatches and is why the key now carries the record counts. The
content comparison above never used the mapping — it joins on member name across
the whole corpus — so it was unaffected.

## Where the volumes and the corpus *default* diverge

487 members match a variant rather than the file in `ibm/`. That is not
disagreement: the corpus holds the volume's exact bytes, filed under
`variants/tape/`, and its README says why — for 333 member names the tapes carry
different content and the corpus records the conflict instead of deciding it.

| variant directory | members |
|---|---:|
| `variants/tape/sym5` | 128 |
| `variants/tape/etc1102` | 114 |
| `variants/tape/evt1202` | 87 |
| `variants/tape/sym1-4` | 78 |
| `variants/tape/source` | 68 |
| `variants/tape/sym3` | 11 |
| `variants/tape/tiocopt` | 1 |

**The 11 in `sym3` are the ones that matter operationally.** They are the HASP
CSECTs — `HASPACCT`, `HASPCOMM`, `HASPCON`, `HASPINIT`, `HASPMISC`, `HASPNUC`,
`HASPPRPU`, `HASPRDR`, `HASPRTAM`, `HASPSSSM`, `HASPXEQ` — where the corpus
deliberately took stben.net's version over the tape's. `MVSSRC.SYM301.F01` on the
volumes carries the tape version, and for `HASPXEQ` that is 200 records against
the corpus default's 6,164:

```
   1|XEQ      TITLE 'HASP EXECUTION SERVICES PROLOG'                @OZ18212 40002000|
   2|*********************************************************************** 40004000|
   4|* MODULE NAME -- HASJES2 (HASPXEQ CSECT)                              * 40008000|
 199|* DESCRIPTIVE NAME -- JES2 JCL CONVERSION PROCESSOR                   * 40464000|
 200|*                                                                     * 40466000|
```

It ends in the middle of a prologue. A build reading the volumes for the HASP
modules gets a prologue and no code; the corpus's substitution is not a
preference, it is the difference between having the source and not having it.
This is the single place where "read `SRC00x`" and "read `ibm/`" are not
interchangeable, and any host-side build has to take the corpus version.

## The 333 conflicts, counted from the volumes

The corpus records 333 names as `conflict`. Counting the same thing from the
volume extraction alone — distinct byte-versions per member name across the 254
data sets — gives 5,594 names with one version, 241 with two, 92 with three:
**333 names carrying more than one version**, and the split into

| | names |
|---|---:|
| versions differing only in columns 73–80 | 43 |
| versions differing in columns 1–72 | 290 |

matches the corpus's own split exactly. Two countings, one from DASD and one from
the tape extraction, arriving at the same 333 and the same 43/290.

**The 43 are sequence numbers only.** `IEDAYI` is on `etc1102/FILE0003`,
`sym5/FILE0003` and `tiocopt/FILE0003`, 1,453 records each, columns 1–72
byte-identical throughout. Three records differ, all in columns 73–80, and only
in the last two digits:

```
etc1102  rec 56  1-72 |*A343700                             @OY19848|  73-80 |03078186|
sym5     rec 56  1-72 |*A343700                             @OY19848|  73-80 |03078182|
```

For an assembly that reads columns 1–72 these are the same member. The 43 names
are listed in the sidecar with `verdict=identical-elsewhere` and identical 1–72
hashes.

**The 290 are maintenance.** `IGG019Q9` is 743 records on `etc1102/FILE0005` and
808 on `etc2402/FILE0002`; 726 records are common, in 14 hunks. What the longer
version adds is stamped APARs:

```
+ |* $N1=2        JTC2412  81.02.10 398332: MULTIPLE TCAM HIT         @N1A|
+ |* $21=OZ52350  JTC2402  81.09.10 076195: SCB ERROR                 @21A|
…
+ |         TM    SCBBSCFM,SCBMLMTN        MESSAGE LIMIT REACHED      @21A|
+ |         BZ    NOLMT                    NO, BRANCH                 @21A|
```

That is the base distribution against the distribution with a selectable unit
applied, which is what the corpus README says the 333 are. It is also why the
487 variant matches are not a defect to be fixed: which version is right is a
question about the level being targeted, answered against the DLIB objects, not
about whether the volumes and the corpus agree.

## Does the corpus hold every version the volumes carry?

Measured directly, without the manifest: for each member name, the set of
distinct 80-byte hashes on the volumes, against the set of distinct hashes in the
corpus for that name.

- volume versions the corpus does **not** hold: **0**
- corpus versions the volumes do not carry: **101**

The 101 are fully accounted for: 90 in `variants/stben/` (mirror versions of tape
members, which is what that directory is for) and 11 in `ibm/HAS/` (the HASP
substitution above). None claims to come from tape.

## Controls

Every figure above is a zero or a total match, so each was checked against a case
whose answer was known in advance.

**The column 73–80 mask does mask, and does not mask more.** Blanking columns
74–80 of record 1 of `IHACSD` leaves the 1–72 hash unchanged and changes the
80-column hash; incrementing the byte in column 6 changes the 1–72 hash. Without
this, "identical" and "identical because the mask is a no-op" are the same
observation. It matters here because the mask turned out to be unnecessary: all
7,206 members match on all 80 columns, so the comparison never needed it.

**The classifier can say "differs" and "volume-only".** Fed a real member's name
with a corrupted hash it returns `differs`; fed a name in no corpus area
(`ZZZQQ`) it returns `volume-only`. Both verdicts came back empty from the real
data, which is only informative if they were reachable.

**A known difference is detected.** The 11 `replaced` HASP members must *not*
match the `ibm/` default, because the corpus deliberately put a different file
there. All 11 come back as not matching the default. A pipeline that called them
identical would be broken.

**A known-clean prediction holds.** The 28 members the corpus records as FTP
line-break damage (`handover/ftp-damaged.tsv`) should be clean when read from
DASD rather than pulled through FTP. All 28 are `identical-default`, and their
record counts on the volumes equal the tape extraction's exactly — 341 for
`IEDQWI5U` where the FTP copy has 342 lines, 329 for `IDCCDAL` where it has 343.

**Record counts, independently.** All 7,206 volume members join to
`mvs38-ibmsrc/work/raw/inventory.tsv` by `(tape, file, member)` with **0**
record-count mismatches. Against `MANIFEST.tsv`, 5,927 members have a row naming
that very tape and file, with 10 mismatches — the `replaced` HASP rows, where the
row keeps the tape provenance of the name but the record count describes the
stben file substituted for it. Expected, not a defect. And the volumes' total,
11,321,571 records, is the figure `mvs38-ibmsrc/README.md` reports for the tape
extraction.

**A third, independent inventory.** `mvs38_sources/sha256/tk4.hashed.csv` is a
2020s FTP mirror of these same volumes, made by different tooling through MVS's
own FTP server. Its 7,206 `(data set, member)` pairs are exactly the 7,206 that
`dasdpdsu` produced: 0 on either side alone.

## What this does not show

**Both sides descend from the same tapes.** The corpus was extracted from
`mvs38_sources/tapes/*.aws.gz` with `xmi.py`; the volumes were loaded into MVS by
whoever built `tk4-source.zip`, years earlier and by other means. The two paths
are independent of each other, and their agreement is evidence that both are
faithful. It is not evidence that the tape images are IBM's — a defect in the
tapes themselves would appear identically on both sides and this comparison
cannot see it. Nothing here was checked against IBM's object code.

**The volumes were compared, not the build.** That `MVSCE-LAB` has these volumes
at 350–353 and that the build reads them is taken from the build's setup, not
measured; no job was submitted and nothing on the MVS machines was written. What
was measured is the content of the four images, from the LAB copies as well as
the zip.

**`macros/` and `ext/` are unverified by this measurement.** They are not on the
volumes and nothing here says whether they are right.

**One VSAM data space was not read.** `Z9999994.VSAMDSPC.T8590A68.TCBF2E90` on
`SRCCAT` holds the user catalogue, not source. `dasdpdsu` unloads PDSs; the 254
source data sets are all of them.

## Consequence

The premise the plan rests on holds. Everything measured locally against
`mvs38-ibmsrc` — the IFOX00 tree comparison, the `as370` gate, the module
tables — is measured against the same bytes Dave's build assembles from. A
host-side build with `as370` and `ld370` can read the local corpus and be reading
the distribution.

Two things carry over into that build:

1. **The HASP modules must come from the corpus, not the volumes.** Tape `sym3`
   carries prologues; `ibm/HAS/` carries the code.
2. **For the 290 real conflicts the corpus's default is a recorded choice, not a
   fact.** The volumes carry every version; which one a build should take is
   decided against the DLIB objects, and the sidecar says which tape file holds
   which.
