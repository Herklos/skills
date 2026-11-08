#!/usr/bin/env sh
# set-tier.sh — upsert llm.tier.<name> from a JSON object (whole value replace).
# Usage: set-tier.sh <tier> '<json>'
# Example: set-tier.sh codegen '{"provider":"anthropic","model":"claude-sonnet-5","base_url":"https://api.anthropic.com","api_key_ref":"llm.key.anthropic"}'
# Host: Mac / Linux. Deps: curl, jq. Never pass raw API keys in the JSON.
set -eu

if [ "$#" -lt 2 ]; then
  echo "usage: $0 <tier> '<json-value>'" >&2
  echo "tiers: codegen | classify | vision | judge | …" >&2
  exit 1
fi

TIER="$1"
ROW="$2"
KEY="llm.tier.$TIER"
A="${ANY_ADDR:-http://127.0.0.1:2046}"

echo "$ROW" | jq -e . >/dev/null
# Refuse obvious secret material
if echo "$ROW" | jq -e '.. | strings | select(test("sk-ant-|sk-or-|sk-proj-|ghp_|github_pat_"))' >/dev/null 2>&1; then
  echo "refusing: JSON looks like it contains a raw API key; use api_key_ref only" >&2
  exit 1
fi

SP=$(curl -fsS "$A/v1/spaces" | jq -er '(.spaces // .)[] | select(.name == "bao") | .id')
TID=$(curl -fsS "$A/v1/spaces/$SP/types?includeHidden=true" \
  | jq -er '.types[] | select(.xKey == "agent_config") | .id')
OBJ=$(curl -fsS -X POST "$A/v1/spaces/$SP/bundles/bao%2Fv1/children" \
  -H 'Content-Type: application/json' \
  -d "{\"seed\": \"bao/config/v1\", \"type\": \"$TID\"}" | jq -er .objectId)
COL=$(curl -fsS "$A/v1/spaces/$SP/types/$TID/datasets" \
  | jq -er '.datasets[] | select(.key == "agent_config") | .collection')

BODY=$(jq -nc --arg obj "$OBJ" --arg col "$COL" --arg id "$KEY" --arg key "$KEY" --argjson val "$ROW" \
  '{objectId: $obj, dataset: $col, records: [{
     id: $id, upsert: true, ops: [
       {type: "$set", path: "key", value: $key},
       {type: "$set", path: "value", value: $val}
     ]}]}')

curl -fsS -X POST "$A/v1/spaces/$SP/modify" -H 'Content-Type: application/json' \
  -d "$BODY" | jq '{recordIds, rejections}'

echo "wrote $KEY on bao=$SP — live for the next message"
