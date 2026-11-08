#!/usr/bin/env sh
# export-ndjson.sh — dump chosen spaces' objects to NDJSON via HTTP query.
# Usage: export-ndjson.sh <outdir> <spaceId> [spaceId…]
# Host: Mac / Linux. Deps: curl, jq. Does not dump secret values intentionally.
set -eu

if [ "$#" -lt 2 ]; then
  echo "usage: $0 <outdir> <spaceId> [spaceId…]" >&2
  exit 1
fi

OUT="$1"
shift
A="${ANY_ADDR:-http://127.0.0.1:2046}"
mkdir -p "$OUT"

for SP in "$@"; do
  SAFE=$(printf '%s' "$SP" | tr -c 'A-Za-z0-9._-' '_')
  DEST="$OUT/$SAFE.ndjson"
  : >"$DEST"
  echo "exporting space $SP -> $DEST" >&2

  # Page through objects query (limit 100)
  OFFSET=0
  LIMIT=100
  while :; do
    RESP=$(curl -fsS -X POST "$A/v1/spaces/$SP/objects/query" \
      -H 'Content-Type: application/json' \
      -d "{\"sort\":[\"-modifiedAt\"],\"limit\":$LIMIT,\"offset\":$OFFSET}")
    COUNT=$(echo "$RESP" | jq '.records | length')
    echo "$RESP" | jq -c '.records[]?' >>"$DEST"
    if [ "$COUNT" -lt "$LIMIT" ]; then
      break
    fi
    OFFSET=$((OFFSET + LIMIT))
  done

  # Space metadata line
  curl -fsS "$A/v1/spaces/$SP" 2>/dev/null \
    | jq -c '{_export: "space", space: .}' >>"$DEST" || true

  LINES=$(wc -l <"$DEST" | tr -d ' ')
  echo "wrote $LINES lines for $SP" >&2
done

echo "done under $OUT (review for secrets before sharing)"
