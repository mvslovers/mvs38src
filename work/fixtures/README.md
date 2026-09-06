# Fixtures for cmplmd370 ([cc370#110](https://github.com/mvslovers/cc370/issues/110))

Real material for the comparison the tool has to perform, so it can be developed
and tested without an MVS system.

Three pairs. Each is a module from Dave Kreiss' `MVSBLD/` tree, assembled here
with `as370`, next to the **distribution-library member** of the same name out of
a pristine MVS/CE 2.1.4.

| | `.asm` | `.obj` | `.dlib` | from |
|---|---|---:|---:|---|
| `IGG026DU` | Dave Kreiss' source | 320 B | 389 B | `SYS1.AOSD0` |
| `IEFJDSNA` | " | 640 B | 549 B | `SYS1.AOSB3` |
| `BLSUZZ2R` | " | 400 B | 465 B | `SYS1.AOS32` |

## What the two sides are

`.obj` is an ordinary **object deck** — 80-byte card images, `ESD` / `TXT` /
`RLD` / `END`.

`.dlib` is a **load module**, not an object deck. The `SYS1.AOS*` distribution
libraries are RECFM=U; a member begins with a record of type X'20', the CESD.
That correction is the reason this fixture exists — see the comment on #110.

## What is known about these pairs, and what is not

**Known: the section lengths agree exactly.**

| | our `SD` length | DLIB `SD` length |
|---|---:|---:|
| `IGG026DU` | 12 | 12 |
| `IEFJDSNA` | 211 | 211 |
| `BLSUZZ2R` | 96 | 96 |

That is the precondition for byte-identity and it holds on all three.

**Not known: whether the text is identical.** Nobody has compared it — that is
precisely what `cmplmd370` is for. Dave Kreiss verified his source against
**TK3**, and this is MVS/CE. So do not treat these as known-equal pairs and do
not build a "must exit 0" test on them.

For a known-equal test, cc370's own corpus is the better source: assemble with
`as370`, bind with `ld370`, compare. What that corpus cannot give you is what
these three carry — real IBM material, bound by IBM's linkage editor, with
relocated address constants and genuine EBCDIC content.

## Two format details a comparator has to survive

**1. The ER length field differs by format, not by content.** In `IGG026DU` the
external reference `IGC0002F` carries a length of binary zero in the load
module's CESD and EBCDIC blanks (`X'404040'`) in the object deck's ESD card. Same
meaning, different filler. Comparing ESD against CESD byte for byte reports a
difference that is not one; the comparison has to be per entry and by type.

**2. Address constants are relocated on the DLIB side.** The binder has run —
that is what `--clearrld` is for, and why Dave Kreiss' tool is called COMPare
Load MoDule. `IGG026DU` is the small case with an `RLD` card to exercise it.

## How many sections a member really has

Measured over the 111 modules of the standing sample that assemble cleanly, by
counting `SD` and `PC` entries in the **object decks**:

| Sections | Modules |
|---:|---:|
| 1 | 100 |
| 2 | 10 |
| 3 | 1 |

**9.9 % carry more than one section.** A count of `CSECT` *statements in the
source* gives 50.9 % over the same kind of material — five times more, because
several `CSECT` statements usually re-open the same section rather than starting
a new one. `IEFJDSNA` has three `CSECT` statements and one `SD`; `BLSUZZ2R` has
five and one.

Both numbers are biased, in opposite directions: the statement count over-counts
re-opened sections, and this one is drawn from the modules that already
assemble, which are the simpler ones. The design conclusion is unaffected —
one member in ten has several sections, so nothing may assume one section per
deck — but 9.9 % is the figure measured on decks.

## Reproducing

```sh
ssh mvsdev
export PATH=/usr/local/hercules/bin:$PATH
D=~/tmp/mvs38src-work/MVSCE/DASD          # a pristine release, Hercules shut down

dasdcat -i $D/smp000.3350 "SYS1.AOSD0/*:?"          # member list with sizes
dasdcat -i $D/smp000.3350 "SYS1.AOSD0/IGG026DU"     # the member itself
```

⚠️ `dasdpdsu` **cannot** read these libraries. It assumes fixed 80-byte records
and stops with `Invalid block length 56`. Use `dasdcat`.

The object side, from the repository root:

```sh
M=work/macros/mvsce-2.1.4-dlib
as370 -I $M/AMACLIB -I $M/AMODGEN -I $M/AGENLIB -I $M/ATSOMAC \
      -I $M/ATCAMMAC -I $M/APVTMACS \
      -I work/macros/tape -I work/macros/mirror \
      -o IGG026DU.obj "$MVSBLD/IGG026DU.ASM"
```

## What the material has already been good for

`cc370`'s `refactor/libobj370-readers` (`6bf8019`, the object-record reader
extracted into `common/obj370`) was checked against it: `file370 -v` built from
`main` and from the branch, run over **111 object decks assembled from IBM
source plus the three DLIB members** — **114 of 114 byte-identical**. That is an
independent check, because cc370's own byte-identity corpus is entirely
self-produced material.

What the same 111 decks say about the record types in real IBM object code:

| ESD entry type | Count |
|---|---:|
| `ER` | 226 |
| `SD` | 112 |
| `LD` | 65 |
| `PC` | 11 |

**25 of 111 decks carry `LD` entries and 64 carry `RLD` cards.** That matters for
one specific reason: `LD` entries get no ESDID and must not advance the counter,
and it is exactly that numbering the `R` and `P` fields of an `RLD` point at. Get
it wrong and relocation silently targets the wrong section while the deck still
parses cleanly.

`file370` also already walks a DLIB member end to end — `CESD`, three `IDR`
records, control, text, `MODEND`. Those IDR records are real maintenance levels
on distribution-library material, which is what
[cc370#111](https://github.com/mvslovers/cc370/issues/111) is after.

## There are 99 more pairs where these came from

Of the 111 modules in the sample that assemble, **102 have a member of the same
name in a distribution library**. The full index — module, library, member size —
is in [`../measurements/aos-index.txt`](../measurements/aos-index.txt), 5,252
members across all 34 `AOS*` libraries. Say if a different shape of pair would be
more useful and it can be cut from that.
