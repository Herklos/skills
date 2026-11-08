#!/usr/bin/env sh
# chat.sh — send a message and print recent replies.
# Usage: chat.sh <spaceId> <chatId> [text…]
# Host: Mac / Linux. Prefers `any chat send`; reads via HTTP query
# (there is no `any chat list` in current any CLI — docs/01-cli.md reads
# go through query / query-subscribe).
set -eu

if [ "$#" -lt 2 ]; then
  echo "usage: $0 <spaceId> <chatId> [text]" >&2
  exit 1
fi

SP="$1"
CHAT="$2"
shift 2
TEXT="${*:-ping from any-agents chat.sh}"
A="${ANY_ADDR:-http://127.0.0.1:2046}"
# CLI --addr wants host:port
ADDR="${A#http://}"
ADDR="${ADDR#https://}"

send_ok=0
if command -v any >/dev/null 2>&1; then
  if any --addr "$ADDR" chat send "$SP" "$CHAT" --text "$TEXT"; then
    send_ok=1
  fi
fi

if [ "$send_ok" -ne 1 ]; then
  curl -fsS -X POST "$A/v1/spaces/$SP/objects/$CHAT/chat/messages" \
    -H 'Content-Type: application/json' \
    -d "$(jq -nc --arg t "$TEXT" '{text:$t}')" | jq .
fi

echo "--- recent chat_messages ---" >&2
sleep 1
curl -fsS -X POST "$A/v1/spaces/$SP/query" -H 'Content-Type: application/json' \
  -d "{\"objectId\": \"$CHAT\", \"dataset\": \"chat_messages\", \"sort\": [\"-createdAt\"], \"limit\": 5}" \
  | jq '{n: (.records|length), messages: [.records[]? | {id, text, agent, createdAt}]}'
