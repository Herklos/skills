#!/usr/bin/env sh
# agent-ready.sh — wait until anyrt control/status looks ready, or poll bao chat.
# Prefer watching the serve log for: overlays synced — agent ready
# Host: Mac / Linux. Deps: curl, jq, sh.
set -eu

A="${ANY_ADDR:-http://127.0.0.1:2046}"
CONTROL="${ANYRT_CONTROL:-http://127.0.0.1:7010}"
TIMEOUT="${TIMEOUT_SEC:-120}"
i=0

echo "waiting up to ${TIMEOUT}s for agent (control=$CONTROL any=$A)" >&2

while [ "$i" -lt "$TIMEOUT" ]; do
  # Control API status (shape may vary by version)
  if curl -sf --connect-timeout 1 "$CONTROL/status" >/tmp/anyrt-status.$$ 2>/dev/null; then
    if jq -e '.ready == true or .overlaysSynced == true or .agent == "ready"' >/dev/null 2>&1 \
         < /tmp/anyrt-status.$$; then
      echo "ready: control /status reports ready"
      cat /tmp/anyrt-status.$$ | jq -c . 2>/dev/null || cat /tmp/anyrt-status.$$
      rm -f /tmp/anyrt-status.$$
      exit 0
    fi
    # Any 200 from control after serve started is a weak positive — keep polling for phrase via log
    if grep -qi 'ready\|synced' /tmp/anyrt-status.$$ 2>/dev/null; then
      echo "ready: control status mentions ready/synced"
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
      echo "provisioned: bao space $SP has agent_config (still confirm serve log: overlays synced — agent ready)"
      # Not full ready — continue until timeout unless CONTROL answered
    fi
  fi

  i=$((i + 2))
  sleep 2
done

rm -f /tmp/anyrt-status.$$
echo "timeout: did not confirm ready. Check anyrt serve log for: overlays synced — agent ready" >&2
echo "UNVERIFIED control JSON schema — log line remains authoritative." >&2
exit 1
