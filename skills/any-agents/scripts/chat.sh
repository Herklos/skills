#!/usr/bin/env sh
# chat.sh — send a message and list recent replies.
# Usage: chat.sh <spaceId> <chatId> [text…]
# Host: Mac / Linux. Prefers `any` CLI; falls back to curl.
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

if command -v any >/dev/null 2>&1; then
  # Prefer CLI when it can reach the server (uses recorded addr or --addr)
  if any --addr "${A#http://}" chat send "$SP" "$CHAT" --text "$TEXT" 2>/tmp/any-chat-err.$$; then
    any --addr "${A#http://}" chat list "$SP" "$CHAT" --limit 5
    rm -f /tmp/any-chat-err.$$
    exit 0
  fi
  # some builds take host:port without scheme already handled; try without stripping
  if any chat send "$SP" "$CHAT" --text "$TEXT" 2>>/tmp/any-chat-err.$$; then
    any chat list "$SP" "$CHAT" --limit 5
    rm -f /tmp/any-chat-err.$$
    exit 0
  fi
  echo "any CLI send failed; falling back to HTTP" >&2
fi

curl -fsS -X POST "$A/v1/spaces/$SP/objects/$CHAT/chat/messages" \
  -H 'Content-Type: application/json' \
  -d "$(jq -nc --arg t "$TEXT" '{text:$t}')" | jq .

echo "--- recent (query chat_messages; may need a moment for the agent) ---" >&2
sleep 2
curl -fsS -X POST "$A/v1/spaces/$SP/query" -H 'Content-Type: application/json' \
  -d "{\"objectId\": \"$CHAT\", \"dataset\": \"chat_messages\", \"sort\": [\"-createdAt\"], \"limit\": 5}" \
  | jq '.records // .'

rm -f /tmp/any-chat-err.$$
