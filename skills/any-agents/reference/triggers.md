# Triggers and schedules

Triggers are records in the `agent_triggers` dataset on the
`bao/triggers/v1` bundle child (ADR-006 §4, ADR-018). The running
`anyrt serve` reconciles every ~5s tick.

Kinds:

| kind | spec | Behaviour |
|------|------|-----------|
| `cron` | `{"every_s": 600}` or `{"cron": "0 */4 * * *"}` | Cron fields are **UTC**. `every_s` = interval seconds |
| `once` | `{"at": <epoch seconds>}` | Fires once then `enabled: false`. Late fire if `at` was in the past |
| `event` | `{"dataset":"chat_messages","objectId":"<chat>","spaceId"?}` | New messages (v1). Self messages skipped |

`program` is an ADR-004 spec (`hello@v1` or `agent:rollup@v1`).
`owner` = device peer id pin; empty = claimed by the election-active
device. Standby still runs **pinned** triggers. Missed cron while down
does not backfill (except `once` late-fire and chat-watch backlog).

Standing built-ins (rollup, extraction, …) and `chat-watch` follow
election; user triggers do not move when the active bao switches
unless you clear `owner`.

There is **no human approval step** yet for trigger fires.

## Create (HTTP) — official quickstart shape

Host: **Mac / Linux**.

```bash
A="${ANY_ADDR:-http://127.0.0.1:2046}/v1"
BAO=$(any space derived | jq -er '.spaces[] | select(.name=="bao") | .spaceId')
TRG=$(curl -s "$A/spaces/$BAO/types?includeHidden=true" \
  | jq -er '.types[] | select(.xKey=="agent_trigger") | .id')
ANCHOR=$(curl -s -X POST "$A/spaces/$BAO/bundles/bao%2Fv1/children" \
  -H 'content-type: application/json' \
  -d '{"seed":"bao/triggers/v1","type":"'$TRG'"}' | jq -er .objectId)
TRIGGERS=$(curl -s "$A/spaces/$BAO/datasets" \
  | jq -r '.datasets[].name | select(endswith("_agent_triggers"))')
```

Example: run every 4 hours (UTC):

```bash
curl -s -X POST "$A/spaces/$BAO/modify" -H 'content-type: application/json' -d '{
  "objectId": "'$ANCHOR'", "dataset": "'$TRIGGERS'",
  "records": [{ "id": "pm-refine-every-4h", "upsert": true, "ops": [
    { "type": "$set", "path": "", "value": {
        "name": "PM refine every 4 hours",
        "kind": "cron", "spec": { "cron": "0 */4 * * *" },
        "program": "agent:toolcaller@v1",
        "args": { "userText": "Run the PM refine checklist.", "quiet": true },
        "enabled": true } } ] }] }'
```

UNVERIFIED exact `args` for a custom "PM refine" program — deploy your
program first and set `program` / `args` to match. Interval form:
`"spec": { "every_s": 14400 }`.

Reminder (`once`) payload program: `agent:remind@v1` with
`args: {"space","chatId","text"}` (see `repos/_agent/programs/remind@v1.py`).

## List / disable

```bash
curl -s -X POST "$A/spaces/$BAO/query" -H 'content-type: application/json' \
  -d '{"objectId":"'$ANCHOR'","dataset":"'$TRIGGERS'","limit":50}' \
  | jq '.records[] | {id, name, kind, enabled, owner, lastStatus, lastRunAt}'
```

Disable: upsert the same id with `"enabled": false` (or patch that
field). Three consecutive failures → auto-disable
(`lastStatus: "auto_disabled"`). Bad specs → `invalid_spec` /
`unsupported_source`.

## Election and network split

- Unassigned triggers: claimed by the active device; ≤ one poll (~10s)
  overlap possible on claim.
- Pinned triggers: only the owner device; if that device is offline,
  the trigger does not fire (no automatic failover) — intentional for
  remote runners (ADR-018).
- Split-brain chat answering is prevented by election + `chat-watch`
  ownership; user pins do not follow the winner.

## Check it worked

Within one tick after create, `owner` is stamped and `lastRunAt`
advances after the first due fire. Inspect
`anyrt trace ls --addr "$ANY_ADDR"` filtered by the program name, or
query `agent_runs` summaries keyed by `triggerId` when available.
