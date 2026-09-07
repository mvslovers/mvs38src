#!/bin/sh
# One module. Env: BIN, OUTDIR, MACFLAGS (space separated -I list), SRC
m=$1
perl -e 'alarm 20; exec @ARGV' "$BIN" $MACFLAGS -o "$OUTDIR/$m.obj" "$SRC/$m.ASM" >/dev/null 2>&1
rc=$?
if [ -f "$OUTDIR/$m.obj" ]; then
  h=$(shasum -a 256 "$OUTDIR/$m.obj" | cut -d' ' -f1)
  printf '%s\t%s\t1\t%s\n' "$m" "$rc" "$h"
else
  printf '%s\t%s\t0\t-\n' "$m" "$rc"
fi
