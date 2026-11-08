# Debugging and observability

Trace bodies are **device-local** (ADR-023). Summaries / turn lean data
sync. Default `--addr` in many anybao docs is `http://127.0.0.1:7001`;
pass your real any URL (often `:2046`).

Host: **Mac / Linux**.

```bash
A="${ANY_ADDR:-http://127.0.0.1:2046}"
anyrt trace ls --addr "$A" --program toolcaller
anyrt trace ls --addr "$A" -n 0
anyrt trace show --addr "$A" run_<id>
anyrt trace show --addr "$A" run_<id> --stats    # tokens, cache, costUsd
anyrt trace show --addr "$A" run_<id> --full
anyrt trace show --addr "$A" run_<id> --system
anyrt replay run_<id>                            # strict bit-exact replay
anyrt drift                                      # vendored any OpenAPI pin vs coverage
```

Map a chat reply to its run:

```bash
curl -s -X POST "$A/v1/spaces/$SPACE/query" -H 'Content-Type: application/json' \
  -d "{\"objectId\": \"$CHAT\", \"dataset\": \"agent_turns\",
       \"sort\": [\"-seq\"], \"limit\": 1}" | jq -r '.records[0].traceRef'
```

Control API (serve log `control=127.0.0.1:7010`): `GET /status`,
`GET /election` — UNVERIFIED exact JSON against your build; prefer log
lines and `any devices list`.

## Common failures

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `401 auth.required` | No account on this data dir | `any init` or `any auth login` |
| "Not ready yet" | Overlays still syncing / program miss | Wait for `overlays synced — agent ready`; check join/invite |
| Anthropic 400 workspace | Unscoped / identity-linked API key | Create workspace-scoped key |
| Anthropic 400 credits | Billing, not key shape | Console Plans & Billing (subscription ≠ API credits) |
| No reply, standby log | Another device holds bao election | Activate this device; check `chat-watch` pin |
| Double answers | Two serves on **one** any server | One serve per any process |
| Relay flapping | Copied `wallet.key` / two processes one key | Fresh mnemonic restore per device |
| Empty config query | Used dataset key `agent_config` instead of collection id | Resolve collection via types/datasets |
| Port confusion | anyrt still on :7001, any on :2046 | Align `addr` / `ANY_LISTEN_ADDR` |

Per-turn cost: `trace show --stats`. Retention: `[traces]`
`retain_conversations` / `retain_jobs` / `max_bytes` in host config
(debugging.md upstream).
