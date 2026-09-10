#!/bin/sh
# Tree-wide gate: assemble every MVSBLD module, record the return code, keep the
# deck whatever that code is, and hash it.
#   gate.sh <as370-binary> <label>
# Writes <label>.tsv (module, rc, deck-present, sha256) and decks to obj_<label>/.
#
# Earlier runs deleted the deck on a non-zero rc. That cannot measure cc370#141:
# it makes 400+ modules report IFO117 on object code that does not change, and a
# gate that throws those decks away sees a regression where there is none.
set -e
BIN=$1; LABEL=$2
here=$(cd "$(dirname "$0")" && pwd)
SRC="/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
M=$HOME/repos/mvs/mvs38src/work/macros
# erep-set is NOT a trial: those six macros were uploaded to IBMUSER.PVTMAC on
# MVSCE-EXP on 2026-09-09 and the 33 affected reference decks were replaced, so
# the oracle HAS them.  Leaving them off here would recreate the same inequality
# in the other direction -- see docs/erep-adoption.md.  The rule is the one this
# file already states: whatever is added must be on both sides.
# EXTRA_MACS adds libraries for a trial. Whatever is added here must also go up
# to MVS before the IFOX00 side means anything -- the two sides seeing different
# macros is the one inequality that makes every difference unattributable.
MACFLAGS="-I $M/mvsce-2.1.4-dlib/AMACLIB -I $M/mvsce-2.1.4-dlib/AMODGEN -I $M/mvsce-2.1.4-dlib/AGENLIB -I $M/mvsce-2.1.4-dlib/ATSOMAC -I $M/mvsce-2.1.4-dlib/ATCAMMAC -I $M/mvsce-2.1.4-dlib/APVTMACS -I $M/tape -I $M/mirror -I $M/erep-set ${EXTRA_MACS:-}"
OUTDIR="$PWD/obj_$LABEL"
rm -rf "$OUTDIR"; mkdir -p "$OUTDIR"
: ${ASMDATE:=09/07/26}; : ${ASMTIME:=12.00}   # pin the stamp: 381 decks carry it
export BIN OUTDIR MACFLAGS SRC ASMDATE ASMTIME
ls "$SRC" | sed -n 's/\.ASM$//p' | sort > "$PWD/modules.txt"
xargs -P 8 -n 1 "$here/gate-worker.sh" < "$PWD/modules.txt" | sort > "$PWD/$LABEL.tsv"
printf '%s: %s modules, rc0=%s, decks=%s\n' "$LABEL" \
  "$(wc -l < "$PWD/$LABEL.tsv")" \
  "$(awk -F'\t' '$2==0' "$PWD/$LABEL.tsv" | wc -l)" \
  "$(awk -F'\t' '$3==1' "$PWD/$LABEL.tsv" | wc -l)"
