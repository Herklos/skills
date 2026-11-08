# HTTP API examples

Base URL: `$A` = `http://127.0.0.1:2046` unless you changed listen /
`ANY_LISTEN_ADDR`. All routes under `/v1`. Local callers are trusted —
no auth header on standalone loopback (`reference/security.md`).

Host for all curls: **Mac / Linux**.

## Health and account

```bash
A="${ANY_ADDR:-http://127.0.0.1:2046}"
curl -fsS "$A/v1/health" | jq
curl -fsS "$A/v1/auth" | jq
curl -fsS "$A/v1/account" | jq -r .metadata.name
```

`401 auth.required` → run `any init` or `any auth login`.

## Spaces and objects

```bash
# create space
curl -fsS -X POST "$A/v1/spaces" -H 'Content-Type: application/json' \
  -d '{"name":"Notebook"}' | jq

# list
curl -fsS "$A/v1/spaces" | jq

# derived bao
any space derived | jq
```

## Query and live subscribe

```bash
SP=…   # space id
curl -fsS -X POST "$A/v1/spaces/$SP/objects/query" \
  -H 'Content-Type: application/json' \
  -d '{"filter":{"any.type":"page"},"sort":["-modifiedAt"],"limit":20}' | jq

# SSE: ready → snapshot → changes
curl -fsSN -X POST "$A/v1/spaces/$SP/objects/query/subscribe" \
  -H 'Content-Type: application/json' \
  -d '{"filter":{"any.type":"page"},"sort":["-modifiedAt"],"limit":20}'
```

CLI equivalent: `any query-subscribe …`.

## Chat

Prefer CLI for send (there is **no** `any chat list` in current `any` —
reads use HTTP query or `any query-subscribe`):

```bash
any chat send "$SP" "$CHAT" --text "hello"
curl -fsS -X POST "$A/v1/spaces/$SP/query" -H 'Content-Type: application/json' \
  -d "{\"objectId\":\"$CHAT\",\"dataset\":\"chat_messages\",\"sort\":[\"-createdAt\"],\"limit\":5}" | jq
```

HTTP (shapes from skill-bao-config / testing docs):

```bash
# catalog general chat setup (returns bundle root)
curl -s -X POST "$A/v1/catalog/general-chat/setup" \
  -H 'Content-Type: application/json' -d "{\"spaceId\": \"$SP\"}" | jq

curl -s -X POST "$A/v1/spaces/$SP/objects/$CHAT/chat/messages" \
  -H 'Content-Type: application/json' \
  -d '{"text":"hello from curl"}' | jq
```

Agent-tagged message (automated):

```bash
ME="$(curl -s "$A/v1/account" | jq -r .metadata.name) (agent)"
curl -s -X POST "$A/v1/spaces/$SP/objects/$CHAT/chat/messages" \
  -H 'Content-Type: application/json' \
  -d "{\"text\": \"ping\", \"agent\": {\"name\": \"$ME\"}}" | jq
```

## Config modify

See `reference/models.md` and anybao `docs/skill-bao-config.md` for
the full `POST …/modify` upsert on `agent_config`.

## Devices / election

```bash
curl -fsS "$A/v1/devices" | jq '{self, active, devices: (.devices|length)}'
# any devices list
# any devices activate bao
```

## Export (local store / NDJSON helper)

Prefer `scripts/export-ndjson.sh` for object dumps. Trace collections:

```bash
any local export --space "$SP" --names trace_runs,trace_records,trace_blobs \
  --out traces.anyenc.gz
```

(Exact flags: `any` CLI `docs/01-cli.md` / `docs/26-local-store.md` —
re-check if a flag errors; mark drift in TESTING.md.)
