#!/bin/zsh
# Assemble a sample of modules with as370 and count how many come out clean.
#
#   tools/measure-as370.sh NAME SAMPLE OUTDIR -I macrodir [-I macrodir...]
#
# NAME    label for the run; the result lands in OUTDIR/res_NAME.txt
# SAMPLE  one module file name per line, relative to $MVSBLD
# Every remaining argument is passed to as370 unchanged.
#
# A module counts as clean when as370 exits 0. The result file has one line per
# module, "NAME OK" or "NAME FAIL", so two runs can be joined to find
# regressions:
#
#   join <(sort res_A.txt) <(sort res_C.txt) | awk '$2=="OK" && $3=="FAIL"'
#
# The sample must stay the same across runs, or the numbers are not comparable.
: ${MVSBLD:="/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"}

name=$1; sample=$2; outdir=$3; shift 3
out=$outdir/res_$name.txt
mkdir -p $outdir
: > $out

while read m; do
  if as370 "$@" -o /dev/null "$MVSBLD/$m" >/dev/null 2>&1; then
    echo "$m OK" >> $out
  else
    echo "$m FAIL" >> $out
  fi
done < $sample

echo "$name: $(grep -c OK $out) of $(wc -l < $out)"
