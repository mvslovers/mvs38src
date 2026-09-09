# Where the 236 `MVSSRC.*` source libraries come from

Dave Kreiss' build stops at

```
IEF212I BLDUCLIN SMP UCLIN EREPSY01 - DATA SET NOT FOUND
```

`SYS1.PROCLIB(BLDSMP)` names 325 `MVSSRC.*` data sets. 89 of them are
`MVSSRC.BLD.*` — Dave's own, loaded from `BLDMVS.AWS` in install step 5. The
other **236 are IBM's distributed source libraries**, and none of them exists on
`MVSCE-LAB`. Dave's document says the build "reads from the distributed MVSSRC
source libraries found on the SRC*** volumes"; those volumes are not in his
install package.

**Answer: the SRC*** volumes are the four DASD images in TK4-'s optional
`tk4-source.zip`** — `SRC000`, `SRC001`, `SRC002`, `SRCCAT`, inherited from
Volker Bandke's Turnkey 3. They carry 254 data sets named exactly the way
`BLDSMP` names them, and **all 236 are among them. Nothing is missing.**

## 1. What the names are

`BLDSMP` allocates one DD per data set, DD name and DSN carrying the same
information:

```
//SYM10101 DD  DSN=MVSSRC.SYM101.F01,DISP=SHR              MACLIB
//SYM10114 DD  DSN=MVSSRC.SYM101.F14,DISP=SHR       SOURCE
//EREPSY01 DD  DSN=MVSSRC.EREPSY.F01,DISP=SHR       SOURCE
```

The second qualifier is an IBM **source tape**, the third its **file number on
that tape**. `SYM101.F14` is file 14 of tape `sym1-1`. `DISP=SHR` with no
`UNIT`/`VOL` means they must be catalogued. SMP reaches them by DD name:
Dave's SMPMCS carries `++SRC( IEBUPDTE ) TXLIB(SYM20215) DISTMOD(AOSU0)`, so
each one has to be a **PDS whose member name is the element name**.

This settles a premise in the assignment: `MVSSRC.SYM1-1` is **Jay Moseley's**
name for a whole tape and is **not** on the required list. The list contains no
hyphenated name at all — checked, and checked against a file that does contain
hyphens so the zero is not the grep's.

## 2. The measurement chain

Four independent artefacts, none of them derived from another, agree:

| Source | What it says |
|---|---|
| **Peter Stockdill's distribution reference summary** ([`mvstapes.pdf`](https://www.jaymoseley.com/hercules/downloads/pdf/mvstapes.pdf)) | 21 optional source tapes, all NL, with a file count each: `sym1-1` 20, `sym1-2` 19, `sym1-3` 20, `sym1-4` 9, `sym2-1` 33, `sym2-2` 34, `sym3` 4, `sym4-1` 14, `sym4-2` 12, `sym4-3` 11, `sym5` 10, `sym6-1` 16, `sym6-2` 13, `sym7` 13, `erepsym` 3, `ess1102sym` 4, `etc1102` 6, `etc2402` 2, `evt1202` 3, `source` 3, `tiocopt` 5 — **254 files** |
| **The tape images** in `~/repos/MVSSRC/mvs38_sources/tapes/` | the same 21 tapes, the same 254 files. Parsed the AWS block headers directly: unlabelled, one tape mark per file, `RECFM=FB LRECL=80 BLKSIZE=12000` |
| **Jay Moseley's 3380-K volume** ([VTOC listing](https://www.jaymoseley.com/hercules/installMVS/mvssrc.vtoc.htm)) | 21 PDSes, one per tape. Every directory count equals the member count of that tape in our extraction — 21 of 21, `SYM1-1` 725, `SYM2-2` 698, `EREPSYM` 110, and so on |
| **The TK4- source volumes** (this hunt) | 254 data sets named `MVSSRC.<tape>.F<nn>` |

Dave's own evidence points the same way. His trouble report quotes

```
IEB139I I/O ERROR DURING READ - EBB1102B,SMP ,348,DA,SYM10114,00- OP,PROGRAM CHECK
```

`SYM10114` is the DD name for `MVSSRC.SYM101.F14`, and **348** is the address
TK4- gives `src000.348`. `MVSSRC.SYM101.F14` is on `SRC000` — unit and data set
agree, not just the number. His build was reading these volumes.

The mapping from Dave's qualifier to Jay's tape name is not a guess about
spelling; it is fixed by the file counts above, which are distinct enough to
identify each tape:

```
EREPSY→erepsym  ES1102→ess1102sym  ET1102→etc1102  ET2402→etc2402  TIOCOP→tiocopt
SYM101→sym1-1  SYM102→sym1-2  SYM103→sym1-3  SYM104→sym1-4
SYM201→sym2-1  SYM202→sym2-2  SYM301→sym3
SYM401→sym4-1  SYM402→sym4-2  SYM403→sym4-3
SYM501→sym5    SYM601→sym6-1  SYM602→sym6-2  SYM701→sym7
```

Jay drops the `-1` where a tape group has only one reel; TK4- keeps the
`SYM<group><reel>` form throughout.

## 3. Coverage: 236 of 236

`dasdls` over the four volumes lists **254** `MVSSRC.*` data sets. Compared with
`work/dave-build/required-source-libraries.txt`:

| | |
|---|---:|
| required by `BLDSMP` | 236 |
| present on the volumes | **236** |
| **missing** | **0** |
| further data sets the volumes carry | 18 |

Per volume: `SRC000` 77 data sets (64 required), `SRC001` 108 (106), `SRC002`
61 (58), `SRCCAT` 8 (8). 64+106+58+8 = 236. Full table in
[`work/dave-build/src-volume-map.tsv`](../work/dave-build/src-volume-map.tsv).

**Controls for the zero.** A name that must be absent, `MVSSRC.SYM999.F01`, is
absent; a name that must be present, `MVSSRC.SYM101.F01`, is present. And the
254 names read off the volumes are **set-equal** to the 254 in
`~/repos/MVSSRC/mvs38_sources/sha256/tk4.hashed.csv`, which an earlier session
obtained by FTP from these same volumes under TK4- — nothing only on the
volumes, nothing only in the hash list.

The 18 extras are not slack. They are exactly the 18 tape files `BLDSMP` does
not reference, identified independently from the tape extraction before the
volumes were ever downloaded:

```
ES1102.F02 F03 F04    ET1102.F02 F03 F05 F06    EV1202.F01 F02 F03
SOURCE.F01 F02 F03    SYM202.F17    SYM301.F01    SYM501.F02 F03 F04
```

`EV1202` (ACF/VTAM V1R2) and `SOURCE` (VPSS) are whole tapes Dave does not use;
`SYM301.F01` is the JES2 file whose `HASPXEQ` we already know to be a stub.
Attaching the volumes brings all 254 — that is Dave's environment, not sloppiness.

The 236 together hold **6,488 members**, the same figure the tape extraction
gives for the same 236 files.

## 4. What the other candidates are, and why they are not it

- **`~/repos/mvs/mvs38-ibmsrc`** has the *content* — 5,927 members, extracted
  from these tapes, normalised to 80 characters. It is a flat corpus by prefix,
  not 236 PDSes at tape-file granularity, and it deliberately resolves the 333
  conflicting members to one version. Useful for reading and comparing, not for
  feeding SMP.
- **Jay Moseley's `mvssrc.tgz`** (3380-K volume `MVSSRC`, 147.3 MB, MD5
  `c56ee75d5621de2e3c52658bcd02511d` — **downloaded and verified**) is the same
  material merged into **21** PDSes, one per tape. The merge is lossless: for
  every tape, the sum of members over its files equals Jay's directory count and
  no member name occurs in two files of the same tape. But the names and the
  granularity are wrong for `BLDSMP` — it cannot supply `MVSSRC.SYM101.F14` —
  and its user catalog cataloges `MVSSRC.SYM1-1`, which would collide with the
  names we need. Content-complete, route-inferior.
- **`~/repos/MVSSRC/www.stben.net/`, `mvssrc/mainframe.eu/`, Dave's `MVSBLD/`**
  are mirrors and reconstructions, not distribution libraries.
- **`work/macros/`** holds macro libraries only.

There is also a reason to prefer the TK4- volumes over rebuilding from Jay's
tapes: the two lineages are not byte-identical. The earlier `mvs38_sources`
comparison found `IBCDMPRS` differing by one character, and a member TK4- calls
`MSSCVXIT` in `SYM701.F08` where Jay has `IEECVXIT` in `SYM1-1`. Dave built
against the TK4-/TK3 lineage — unit 348 — so that is the lineage to use.

## 5. Negatives, recorded

- **`wotho.ethz.ch` no longer resolves.** `curl` fails with
  `Could not resolve host` over http and https. TK4-'s home site is gone.
- **`www.prince-webdesign.nl` served nothing** matching TK4- or a source archive.
- **`mdickinson.dyndns.org/hercules/downloads/`** carries utilities, not the
  source volumes.
- **No copy of TK4- exists on this Mac or on `mvsdev`** — searched for
  `src00*`, `srccat*`, `tk4*`; nothing.
- The archive therefore came from the **Wayback Machine**, snapshot
  `20230322170033` of `https://wotho.ethz.ch/tk4-/tk4-source.zip`.
  **There is no published checksum to verify it against** — the site that would
  have carried one is dead. What was verified instead is in §6.
- **Dave's install package contains no job that creates these data sets.**
  `BLDMVS.AWS` mentions `MVSSRC.SYM101.F01` once, in the `BLDSMP` proc, and
  carries no IEBUPDTE step that would load a source library. He assumed the
  volumes were already there.

## 6. Verifying the archive without a checksum

- `unzip -t`: no errors. Seven entries — four DASD images and
  `conf/source_dasd.cnf`.
- `dasdls` opens all four as `3350-1, 555 cylinders, 30 heads` with volume
  labels `SRC000`, `SRC001`, `SRC002`, `SRCCAT`, matching the config file
  shipped inside the zip.
- The 254 data set names read out of the VTOCs are set-equal to the independent
  FTP-derived inventory in `tk4.hashed.csv` (§3).

Member-level hashes are **not** comparable: `tk4.hashed.csv` was produced by FTP
in ASCII mode, so it records translated text, not the EBCDIC on the volume. Name
and count level is the honest offline check and it passes.

Hashes of what was actually downloaded, so the next person can confirm they hold
the same bytes — [`work/dave-build/src-volumes-sha256.txt`](../work/dave-build/src-volumes-sha256.txt):

```
0d134fe3b6249414e65084c732c2c24e83ef9e855bbc27e32aad5512c7d60937  tk4-source.zip
4a298157c51c471bd7b426595974d108811e67c46679b6f6ba2c14b4a4cf740f  src000.348
0e8e826513680516020ef5ccba7230d95805fdbf78b30ea1f162fb3f6105976a  src001.349
073201531548bcc687c1e803f545aea64cb1223510df23838ae38dfb80163c34  src002.34a
8960860cbebc3e3fe4864499a92d8c002fd088a1e5f346590c65d5e1ebbd50b5  srccat.34b
```

Copies: `~/repos/mvs/tk4-source.zip` and `mvsdev:~/tk4-source.zip`; the four
images are unpacked on `mvsdev` in `/tmp/tk4src/`.

## 7. The route onto `MVSCE-LAB`

**Nothing below has been done. `MVSCE-LAB` was only read.**

### 7.1 The addresses are 350–353, not 348–34B

TK4- puts the volumes at 348–34B. On `MVSCE-LAB` those are **not genned**:
`D U,,,348,4` answers with the next genned units instead —

```
UNIT TYPE STATUS  VOLSER VOLSTATE   UNIT TYPE STATUS  VOLSER VOLSTATE
350  3350 OFFLINE                   351  3350 OFFLINE
352  3350 OFFLINE                   353  3350 OFFLINE
```

Four 3350 UCBs at **350–353**, offline, and `conf/local.cnf` has no device
behind them. That is exactly what is needed. The control for that display is
`D U,,,150,4`, which correctly shows `MVSRES/MVS000/PAGE00/SPOOL1` online — so
the empty answer at 348 is a real gap in the gen, not a broken command.

The install log's finding that "no IOGEN is needed" was about the 3390s at
192–19D and does **not** carry over; it happens to hold here for a different
reason.

### 7.2 Steps

1. Copy the four images into `~/MVSCE-LAB/DASD/`
   (`unzip -j ~/tk4-source.zip 'dasd/*' -d ~/MVSCE-LAB/DASD/`). +140 MB.
2. Add to `conf/local.cnf` —
   [`work/dave-build/src-volumes-hercules.cnf`](../work/dave-build/src-volumes-hercules.cnf):

   ```
   0350    3350    DASD/src000.348
   0351    3350    DASD/src001.349
   0352    3350    DASD/src002.34a
   0353    3350    DASD/srccat.34b
   ```

   The file names keep TK4-'s `.348`–`.34b` suffixes; they are names, not
   addresses. Renaming them to `.350`–`.353` would read better and costs nothing.
3. Add to `SYS1.PARMLIB(VATLST00)` —
   [`work/dave-build/src-volumes-vatlst00.txt`](../work/dave-build/src-volumes-vatlst00.txt).
   Columns taken from the live member, not from any document: volser 1–6,
   comma 7, mount attribute 8, use attribute 10, device type 12–15, comma **20**,
   flag **21**.

   ```
   SRC000,1,2,3350    ,N        350 MVS SOURCE
   SRC001,1,2,3350    ,N        351 MVS SOURCE
   SRC002,1,2,3350    ,N        352 MVS SOURCE
   SRCCAT,1,2,3350    ,N        353 MVS SOURCE
   ```

   Reserved and **private**, like the `BLD***` entries — read-only source packs
   should not be picked for scratch allocation.
4. IPL. The install log's second finding applies unchanged: `attach` brings the
   devices up but leaves the volumes `/REMOV`; only the IPL mounts them from
   VATLST00. Afterwards `/S HTTPD` and `/S FTPD`.
5. Submit
   [`work/dave-build/catalog-src-libraries.jcl`](../work/dave-build/catalog-src-libraries.jcl)
   — 254 IDCAMS `DEFINE NONVSAM` statements, generated from the VTOCs, each with
   the volume the data set actually sits on. Required 236 first, the other 18
   after, so a partial run is still useful.
6. Restart the build at `$01SMPAL`.

### 7.3 The trap: do not import the catalog on SRCCAT

`SRCCAT` carries a VSAM user catalog — TK4- connects it from
`SYS1.SETUP.CNTL(MVS0200)` and Dave's document calls it `SYS1.UCAT.SRC`.
**Do not import it and do not define an `MVSSRC` alias here.**

There is no `SYS1.UCAT.*` on `MVSCE-LAB`: `dslevel=SYS1.UCAT.**` returns zero
rows, and the control `dslevel=SYS1.**` returns 97 with no `.UCAT` among them.
So the catalog Dave's document names is not there.

**What could not be established:** whether `MVSCE-LAB` has *any* user catalog,
or an `MVSSRC` alias. mvsMF's `dslevel` does not accept a leading wildcard —
`*.VSAMDSPC.**`, `*.UCAT.**`, `SYSCTLG.**` all answer zero, but so do the
controls `*.BLD.**` and `*.PARMLIB`, which must match. Those four zeros are the
API refusing the pattern, not an empty system. An earlier draft of this document
read them as a clean negative; they are not.

That is why `DEFINE NONVSAM` is the recommendation and not `IMPORT CONNECT`. It
puts each entry in whatever catalog `MVSSRC` already resolves to — master
catalog or a user catalog, whichever it turns out to be — which is exactly where
the 213 existing `MVSSRC.BLD.*` entries are. It is correct under either state,
and needs no decision about which catalog owns `MVSSRC`.

Importing `SRCCAT`'s catalog is not, under either state. An alias
`MVSSRC → SYS1.UCAT.SRC` routes every `MVSSRC.*` request to that user catalog and
makes the 213 existing entries unreachable — the build would then fail on its own
data sets instead of on IBM's.

`SRCCAT` still has to be **attached**, because eight of the 236 —
`MVSSRC.SYM701.F06` through `.F13` — live on it. Only its catalog is left alone.

### 7.4 Contingency, if the archive is ever doubted

Everything can be rebuilt locally from the tapes in
`~/repos/MVSSRC/mvs38_sources/tapes/`, which is where Jay's copies already are.
Each tape file is a sequential IEBUPDTE stream — the first record of
`sym1-1` file 1 is `./  ADD  SSI=63440084,NAME=AMDDATA` — so one step per file
turns it into the PDS `BLDSMP` wants:

```
//S001   EXEC PGM=IEBUPDTE,PARM=NEW
//SYSPRINT DD  SYSOUT=*
//SYSUT2   DD  DSN=MVSSRC.SYM101.F01,DISP=(NEW,CATLG),
//             UNIT=3390,VOL=SER=MVSSR1,
//             SPACE=(CYL,(20,5,20)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=27920)
//SYSIN    DD  UNIT=100,DISP=OLD,LABEL=(1,NL),VOL=SER=SYM101,
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=12000)
```

`LABEL=(n,NL)` with the measured DCB — the tapes are unlabelled and every data
block is 12000 bytes. 236 such steps, one per line of
[`work/dave-build/source-library-coverage.tsv`](../work/dave-build/source-library-coverage.tsv),
which carries the tape, the file number and the member count for each.

This is the fallback, not the recommendation: it rebuilds from the Moseley
lineage, and §4 shows that lineage differs from the one Dave built against.

## 8. Left open

- `BLDMVS.AWS` references three further non-`BLD` data sets — `MVSSRC.NEW.AOSD0`,
  `MVSSRC.NEW.NUCLEUS`, `MVSSRC.ORG.NUCLEUS`. They are **not** in
  `SYS1.PROCLIB(BLDSMP)`; they appear in other job streams (DD names `SYSLIB`,
  `BNUCLEUS`, `ONUCLEUS`), evidently a nucleus comparison. Whether they are
  created by the build or are a further prerequisite has not been established.
- Whether MVS/CE's security (MVP) needs an entry for the new volumes, the way
  TK4- needs `SYS1.SECURE.CNTL(PROFILES)` updated for `MVSSRC.BLD.*`.

## 9. What was run against `MVSCE-LAB`

Read-only, and that is all:

- `GET /zosmf/restfiles/ds?dslevel=` for `MVSSRC.**` (213 rows, all
  `MVSSRC.BLD.*`), `SYS1.**` (97 rows — the control: `LINKLIB`, `PROCLIB`,
  `MACLIB`, `NUCLEUS` all present), `SYS1.UCAT.**` (0), `Z9999994.**` (0),
  and four leading-wildcard queries that turned out to be meaningless (§7.3).
- `GET /zosmf/restfiles/ds/SYS1.PARMLIB(VATLST00)`.
- Two console **display** commands, `D U,,,348,4` and `D U,,,150,4`.

No job was submitted, no device attached, no data set written.
