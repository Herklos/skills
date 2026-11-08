#!/usr/bin/env sh
# any-health.sh — is the any server up, signed in, and which port?
# Host: Mac / Linux. Deps: curl, jq, sh.
set -eu

A="${ANY_ADDR:-http://127.0.0.1:2046}"
# Also probe common alternate if default fails
ALT="${ANY_ADDR_ALT:-http://127.0.0.1:7001}"

probe() {
  url="$1"
  code=$(curl -s -o /tmp/any-health-body.$$ -w '%{http_code}' --connect-timeout 2 "$url/v1/health" || echo 000)
  echo "$code"
}

CODE=$(probe "$A")
if [ "$CODE" != "200" ]; then
  CODE2=$(probe "$ALT")
  if [ "$CODE2" = "200" ]; then
    echo "warn: default $A failed (HTTP $CODE); $ALT is up — set ANY_ADDR=$ALT" >&2
    A="$ALT"
    CODE=200
  fi
fi

if [ "$CODE" != "200" ]; then
  echo "down: no any server at $A (health HTTP $CODE)" >&2
  rm -f /tmp/any-health-body.$$
  exit 3
fi

jq -c '{status: "up", addr: "'"$A"'", health: .}' < /tmp/any-health-body.$$ 2>/dev/null \
  || echo "up addr=$A (non-JSON health body)"

AUTH=$(curl -s -o /tmp/any-auth.$$ -w '%{http_code}' --connect-timeout 2 "$A/v1/auth" || echo 000)
if [ "$AUTH" = "200" ]; then
  # any 0.3.8-nightly: {authorized, accountId, mode, …} — no metadata.name here
  NAME=$(jq -r '.accountId // .status // "authorized"' < /tmp/any-auth.$$ 2>/dev/null || echo authorized)
  echo "auth: ok ($NAME)"
else
  ACCT=$(curl -s -o /tmp/any-acct.$$ -w '%{http_code}' --connect-timeout 2 "$A/v1/account" || echo 000)
  if [ "$ACCT" = "200" ]; then
    # account body: {id, techSpaceId} (metadata.name absent on smoke build)
    jq -r '"auth: ok account=" + (.id // .metadata.name // "yes")' < /tmp/any-acct.$$
  elif [ "$ACCT" = "401" ]; then
    echo "auth: required (401) — run any init or any auth login" >&2
    rm -f /tmp/any-health-body.$$ /tmp/any-auth.$$ /tmp/any-acct.$$
    exit 1
  else
    echo "auth: unknown (HTTP $AUTH / account $ACCT)" >&2
  fi
fi

# Prefer printing listen hint from env/config if present
if [ -n "${ANY_LISTEN_ADDR:-}" ]; then
  echo "ANY_LISTEN_ADDR=$ANY_LISTEN_ADDR"
fi

rm -f /tmp/any-health-body.$$ /tmp/any-auth.$$ /tmp/any-acct.$$
echo "ANY_ADDR=$A"
exit 0
