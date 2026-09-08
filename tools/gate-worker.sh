#!/bin/sh
# One module. Env: BIN, OUTDIR, MACFLAGS (space separated -I list), SRC
# The alarm was 20 s, and one module sat on the edge of it. IFCEE155 assembles
# in 11.4 s alone and sometimes exceeded 20 s under -P 8, so it appeared and
# disappeared between runs -- a phantom +1 deck with no code behind it, which is
# exactly what a gate must not produce. Its deck is byte-identical either way.
# 90 s was enough until cc370#208: IFCEL155 stopped failing on a table bound and
# started assembling, in 72 s alone and more than 90 under -P 8, so it flapped on
# the very run that recovered it. The rule from the IFCEE155 case holds one order
# of magnitude up -- a module near the alarm is a module that appears and
# disappears -- and a gate that reports a difference no code produced is worse
# than a slow one. 240 s costs HEWLDIOC's wall clock and buys a run that repeats.
#
# This comment used to add that HEWLDIOC "does not terminate in 300 s and never
# will within any alarm". The 300 s was measured; the rest was a conclusion, and
# it was wrong. cc370#215: the module was HUNG -- an expression walk with no
# progress guard, live on main for eleven months and reached from an ordinary
# machine-operand path -- and with the guard it assembles in 0 s, to within 4
# bytes of IFOX00 out of 5056. An alarm cannot tell slow from broken. Writing the
# limit down as a property of the module is what stopped it being a question.
m=$1
perl -e 'alarm 240; exec @ARGV' "$BIN" $MACFLAGS -o "$OUTDIR/$m.obj" "$SRC/$m.ASM" >/dev/null 2>&1
rc=$?
if [ -f "$OUTDIR/$m.obj" ]; then
  h=$(shasum -a 256 "$OUTDIR/$m.obj" | cut -d' ' -f1)
  printf '%s\t%s\t1\t%s\n' "$m" "$rc" "$h"
else
  printf '%s\t%s\t0\t-\n' "$m" "$rc"
fi
