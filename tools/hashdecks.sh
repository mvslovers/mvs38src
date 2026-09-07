#!/bin/sh
# Hash every deck in a directory with the END card excluded.
# as370 stamps the assembly date into the END card, so two runs on different
# days differ in the last 80 bytes of every deck and in nothing else. The
# comparison against IBM's object ignores the END card; so must this hash.
d=$1
for o in "$d"/*.obj; do
  m=$(basename "$o" .obj)
  sz=$(stat -f %z "$o")
  body=$((sz - 80)); [ $body -lt 0 ] && body=0
  h=$(head -c $body "$o" | shasum -a 256 | cut -d' ' -f1)
  printf '%s\t%s\t%s\n' "$m" "$sz" "$h"
done
