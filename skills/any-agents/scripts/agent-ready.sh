#!/usr/bin/env sh
# agent-ready.sh — wait until anyrt control/status looks ready, or poll bao chat.
# Prefer watching the serve log for: wait set clear — agent ready
# (older docs say "overlays synced — agent ready"; runtime emits the wait-set line.)
# Host: Mac / Linux. Deps: curl, jq, sh.
set -eu

A="${ANY_ADDR:-http://127.0.0.1:2046}"
CONTROL="${ANYRT_CONTROL:-http://127.0.0.1:7010}"
TIMEOUT="${TIMEOUT_SEC:-120}"
i=0

echo "waiting up to ${TIMEOUT}s for agent (control=$CONTROL any=$A)" >&2

while [ "$i" -lt "$TIMEOUT" ]; do
  # Control API status — verified 2026-11-08 anyrt 0.11.1:
  # { beatSec, envelope: { type:"bao.status", data: { role, state, identity, winner } } }
  if curl -sf --connect-timeout 1 "$CONTROL/status" >/tmp/anyrt-status.$$ 2>/dev/null; then
    if jq -e '
      .envelope.data.role == "active"
      or .ready == true
      or .overlaysSynced == true
      or .agent == "ready"
    ' >/dev/null 2>&1 < /tmp/anyrt-status.$$; then
      ROLE=$(jq -r '.envelope.data.role // empty' < /tmp/anyrt-status.$$ 2>/dev/null || true)
      STATE=$(jq -r '.envelope.data.state // empty' < /tmp/anyrt-status.$$ 2>/dev/null || true)
      echo "ready: control /status role=${ROLE:-?} state=${STATE:-?}"
      jq -c '{beatSec, role: .envelope.data.role, state: .envelope.data.state, winner: .envelope.data.winner}' \
        < /tmp/anyrt-status.$$ 2>/dev/null || true
      rm -f /tmp/anyrt-status.$$
      exit 0
    fi
  fi

  # Fallback: bao space listable and types include agent_config (serve provisioned)
  SP=$(curl -sf --connect-timeout 1 "$A/v1/spaces" 2>/dev/null \
    | jq -r '(.spaces // .)[] | select(.name == "bao") | .id' 2>/dev/null | head -1 || true)
  if [ -n "${SP:-}" ]; then
    HID=$(curl -sf "$A/v1/spaces/$SP/types?includeHidden=true" 2>/dev/null \
      | jq -r '.types[]? | select(.xKey == "agent_config") | .id' 2>/dev/null | head -1 || true)
    if [ -n "${HID:-}" ]; then
      echo "provisioned: bao space $SP has agent_config (still waiting for control role=active / log: wait set clear — agent ready)"
    fi
  fi

  i=$((i + 2))
  sleep 2
done

rm -f /tmp/anyrt-status.$$
echo "timeout: did not confirm ready. Check anyrt serve log for: wait set clear — agent ready" >&2
exit 1
