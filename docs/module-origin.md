# Where each module comes from, and whether MVS/CE has it

2026-09-07. The tree is 5,528 assembler sources. Not all of them belong to the
system we are rebuilding, and a module that has no counterpart anywhere can never
be verified against anything. This is the inventory.

Per module: which distribution library holds its object, and whether the running
MVS/CE carries a load module of that name —
[`module-origin.tsv`](../work/measurements/ifox-run/module-origin.tsv).

## The three groups

| | Modules |
|---|---:|
| object in a distribution library **and** a member of a target library | 2,197 |
| object in a distribution library, **no member of that name** in a target library | 2,859 |
| **no object in any distribution library** | 472 |

**The middle group is not a finding.** A control section is link-edited into a
load module that usually has a different name, so a member-name test undercounts
by design. `IEAVNP01` and `IEAVNIPM` are members of `SYS1.NUCLEUS` and are found;
`IEFVMLS1` is not a member of anything and is nevertheless in the system, bound
into a larger module. Read the column as *"a load module of this name exists"*,
never as *"this code is not installed"*.

The distribution libraries and the target libraries are both on the instance —
36 `SYS1.AOS*` next to `LINKLIB`, `LPALIB`, `SVCLIB`, `NUCLEUS`, `CMDLIB`,
`VTAMLIB`, `TELCMLIB`, `IMAGELIB`, `DCMLIB`, `UMODLIB`.

## The families that have no counterpart at all

### `IER*` — 251 modules, and MVS/CE has no sort at all

| | |
|---|---|
| object in a distribution library | **none of the 251** |
| member of a target library | **none of the 251** |
| a sort library on the instance | **there is none** — no `SYS1.SORTLIB`, nothing matching `SORT` among the 97 `SYS1` data sets |

OS/VS Sort is a separate program product and MVS/CE does not carry it. These 251
modules can never be compared against IBM's object, because there is no IBM
object here to compare them with.

They are consistent in themselves — **243 of the 251 assemble byte-identical
between `as370` and IFOX00** — so they cost the hand-over list only 8 modules.
What they do cost is the denominator: they are 4.5 % of the tree that no
measurement can ever settle.

**Not excluded.** Unlike CICS this has not been decided; it is written down so it
can be.

### CICS — 5 modules, excluded

`BNGC3270`, `BNGCDISP`, `BNGCLOCL`, `BNGCMENU`, `BNGCRMOT` call `DFHPC`,
`DFHFC`, `DFHTC`, `DFHSC`, `DFHCOVER`. There is no CICS here to supply those
macros, and none of the five is a member of any target library — `AOS29` holds
23 members and only 7 of them are installed at all.

They are listed in
[`excluded.tsv`](../work/measurements/ifox-run/excluded.tsv) with their reason,
they keep their row in `module-table.tsv` with the reason in an `excluded`
column, and they drop out of `for-cc370.tsv` — **2,112 owned by the assembler,
2,107 handed over.** Nothing is deleted: a figure that quietly loses rows stops
being checkable.

The other 17 `BNG*` modules are not affected — 9 of them are already byte-identical.

## What the inventory says about the rest

| Family | Modules | No distribution object | Member of a target library | Where |
|---|---:|---:|---:|---|
| `IST*` — VTAM | 608 | 1 | 282 | `LPALIB` 259, `VTAMLIB` 15, `LINKLIB` 8 |
| `IKJ*` — TSO | 265 | 152 | 119 | `CMDLIB` 78, `LINKLIB` 22, `LPALIB` 17 |
| `IER*` — sort | 251 | 251 | 0 | — |

`IKJ*` is worth a second look on its own account: 152 of 265 have no object in
any distribution library, while 119 are installed. That is the TSO source
question this project started from.

The largest distribution libraries by module count: `AOSD0` (600), `AOSC5` (537),
`AOS21` (517), `AOSU0` (470), `AOSB3` (390), `AOS26` (363), `AOS32` (350).

## How it was measured

Member lists came from the REST files API on `MVSCE-EXP`
(`GET /zosmf/restfiles/ds/<library>/member`), the distribution assignment from
the extracted `AOS*` objects in `work/measurements/dlib/`. Rebuild with the
snippet in [`ifox-objections.md`](ifox-objections.md); the target library list is
the ten named above.
