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
# SRC_TREE overrides the source tree. The macro path, the pinned stamp and the
# deck handling below must NOT move with it: the point of assembling a second
# source state is that everything except the source is held fixed.
SRC="${SRC_TREE:-/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD}"
M=$HOME/repos/mvs/mvs38src/work/macros
# erep-set is NOT a trial: those six macros were uploaded to IBMUSER.PVTMAC on
# MVSCE-EXP on 2026-09-09 and the 33 affected reference decks were replaced, so
# the oracle HAS them.  Leaving them off here would recreate the same inequality
# in the other direction -- see docs/erep-adoption.md.  The rule is the one this
# file already states: whatever is added must be on both sides.
# EXTRA_MACS adds libraries for a trial. Whatever is added here must also go up
# to MVS before the IFOX00 side means anything -- the two sides seeing different
# macros is the one inequality that makes every difference unattributable.
# amaclib-live goes LAST, and that placement is measured, not assumed.  It holds
# the six members the local copy of SYS1.AMACLIB is short of -- BTMHJN BTMIOBWA
# IECPDSCB IEZCTGPL IHADECB IHADVCT.  Three exist nowhere else on this path and
# are found here whatever the order; the other three collide, and for IHADVCT
# the live copy is the WRONG one to prefer:
#
#   IFOX00's own diagnostics for IGC018 (work/measurements/ifox-run/diag)
#   flag DVCMODU and DVCUFIX1 undefined and do NOT flag DVCBPSEC.  Only a
#   203-line @ZA40405-level IHADVCT has that profile.  MVSCE-LAB's live
#   SYS1.AMACLIB holds the 196-line pre-APAR level, and IHADVCT is in no other
#   library of the oracle's SYSLIB -- so the library is no longer in the state
#   that produced the reference decks.  Preferring it cost the IGC018 identity.
#
# The decks are the ground truth for what the oracle saw.  Path order arbitrates
# in their favour: unique members still resolve out of amaclib-live, colliding
# ones come from `mirror`.  See work/macros/amaclib-live/README.md.
MACFLAGS="-I $M/mvsce-2.1.4-dlib/AMACLIB -I $M/mvsce-2.1.4-dlib/AMODGEN -I $M/mvsce-2.1.4-dlib/AGENLIB -I $M/mvsce-2.1.4-dlib/ATSOMAC -I $M/mvsce-2.1.4-dlib/ATCAMMAC -I $M/mvsce-2.1.4-dlib/APVTMACS -I $M/tape -I $M/mirror -I $M/erep-set -I $M/amaclib-live ${EXTRA_MACS:-}"
OUTDIR="$PWD/obj_$LABEL"
rm -rf "$OUTDIR"; mkdir -p "$OUTDIR"
: ${ASMDATE:=09/07/26}; : ${ASMTIME:=12.00}   # pin the stamp: 381 decks carry it
export BIN OUTDIR MACFLAGS SRC ASMDATE ASMTIME
# Record which commit the binary came from: retest.py prints it, and a gate
# against a branch whose base has moved can manufacture LOST and
# rc CLEAN -> FLAGGED lines that are not regressions at all.
( cd "$(dirname "$BIN")/.." 2>/dev/null && git log --oneline -1 2>/dev/null ) \
  > "$OUTDIR/.commit" || echo "unknown" > "$OUTDIR/.commit"
ls "$SRC" | sed -n 's/\.ASM$//p' | sort > "$PWD/modules.txt"
xargs -P 8 -n 1 "$here/gate-worker.sh" < "$PWD/modules.txt" | sort > "$PWD/$LABEL.tsv"
printf '%s: %s modules, rc0=%s, decks=%s\n' "$LABEL" \
  "$(wc -l < "$PWD/$LABEL.tsv")" \
  "$(awk -F'\t' '$2==0' "$PWD/$LABEL.tsv" | wc -l)" \
  "$(awk -F'\t' '$3==1' "$PWD/$LABEL.tsv" | wc -l)"
