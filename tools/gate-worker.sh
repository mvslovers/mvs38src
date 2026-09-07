#!/bin/sh
# One module. Env: BIN, OUTDIR, MACFLAGS (space separated -I list), SRC
# The alarm was 20 s, and one module sat on the edge of it. IFCEE155 assembles
# in 11.4 s alone and sometimes exceeded 20 s under -P 8, so it appeared and
# disappeared between runs -- a phantom +1 deck with no code behind it, which is
# exactly what a gate must not produce. Its deck is byte-identical either way.
# 90 s costs one module's wall clock (HEWLDIOC does not terminate in 300 s and
# never will within any alarm) and buys a run that repeats.
m=$1
perl -e 'alarm 90; exec @ARGV' "$BIN" $MACFLAGS -o "$OUTDIR/$m.obj" "$SRC/$m.ASM" >/dev/null 2>&1
rc=$?
if [ -f "$OUTDIR/$m.obj" ]; then
  h=$(shasum -a 256 "$OUTDIR/$m.obj" | cut -d' ' -f1)
  printf '%s\t%s\t1\t%s\n' "$m" "$rc" "$h"
else
  printf '%s\t%s\t0\t-\n' "$m" "$rc"
fi
