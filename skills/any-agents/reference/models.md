# Model tiers

Config rows live in the bao space `agent_config` dataset (ADR-006 §3).
A write is live for the next message — no restart. Canonical external
procedure: anybao `docs/skill-bao-config.md`. Shapes: `docs/llm-models.md`.

## Tier keys

| Key | Role |
|-----|------|
| `llm.tier.codegen` | Main chat |
| `llm.tier.classify` | Background extract / rollup / link |
| `llm.tier.vision` | Image / file reads |
| `llm.tier.judge` | Yes/no judging (optional) |

Default soft seeds (`runtime/src/config_defaults.json`): Anthropic
claude-sonnet-5 / haiku for the three main tiers.

## Row shape

```json
{
  "provider": "openai-compat",
  "model": "deepseek/deepseek-r1-0528",
  "base_url": "https://openrouter.ai/api/v1",
  "api_key_ref": "llm.key.openrouter",
  "backend": "openrouter",
  "profile": "deepseek-r1",
  "traits": {"vision": false},
  "options": {"top_p": 0.95}
}
```

- `provider`: `anthropic` or `openai-compat`
- `api_key_ref: null` → keyless local server (no credential card)
- `backend` / `profile` optional when host/model are well-known
- Do **not** put integer traits like `context_window` in writes over HTTP
  (store float coercion breaks validation) — leave `traits` to booleans/strings
  or omit
- Secrets are **not** config; seed via `.connectors.env` /
  Credentials UI (`docs/config-secrets.md`)

Backends: `anthropic`, `openai`, `openrouter`, `gemini`, `deepseek`,
`groq`, `together`, `vllm`, `llamacpp`, `ollama`, `anyai`, `generic`.

Parity env for recording: `ANYBAO_SECRET_<REF>` with dots → `_`
(e.g. `ANYBAO_SECRET_LLM_KEY_OPENROUTER`).

`anyai` (Codex/Claude Code login proxy) is optional and part of any-ui —
document only; do not require it.

## Resolve config object (HTTP)

Host: **Mac / Linux**. `$A` = any base URL (default `http://127.0.0.1:2046`).

```bash
A="${ANY_ADDR:-http://127.0.0.1:2046}"
SP=$(curl -s "$A/v1/spaces" | jq -r '(.spaces // .)[] | select(.name == "bao") | .id')
# derived bao space id also via: any space derived | jq …
TID=$(curl -s "$A/v1/spaces/$SP/types?includeHidden=true" \
  | jq -r '.types[] | select(.xKey == "agent_config") | .id')
OBJ=$(curl -s -X POST "$A/v1/spaces/$SP/bundles/bao%2Fv1/children" \
  -H 'Content-Type: application/json' \
  -d "{\"seed\": \"bao/config/v1\", \"type\": \"$TID\"}" | jq -r .objectId)
COL=$(curl -s "$A/v1/spaces/$SP/types/$TID/datasets" \
  | jq -r '.datasets[] | select(.key == "agent_config") | .collection')
```

If `TID` is empty, serve has not provisioned the space yet — stop.

List rows:

```bash
curl -s -X POST "$A/v1/spaces/$SP/query" -H 'Content-Type: application/json' \
  -d "{\"objectId\": \"$OBJ\", \"dataset\": \"$COL\"}" \
  | jq '.records | map({key, value})'
```

Or use `scripts/set-tier.sh`.

## Examples

### Anthropic (verified shape in defaults + parity table)

```json
{"provider":"anthropic","model":"claude-sonnet-5","base_url":"https://api.anthropic.com","api_key_ref":"llm.key.anthropic"}
```

Seed: `llm.key.anthropic=…` (workspace-scoped).

Smoke: chat "which model are you running?" → `anyrt trace show … --stats`.

### OpenRouter

```json
{"provider":"openai-compat","model":"minimax/minimax-m3.1-flash:free","base_url":"https://openrouter.ai/api/v1","api_key_ref":"llm.key.openrouter"}
```

Seed: `llm.key.openrouter=…`. Preflight a tiny
`/chat/completions` with the user's key before writing
(`skill-bao-config.md` §4).

### Ollama (declared; **UNVERIFIED** golden parity)

```json
{"provider":"openai-compat","model":"qwen3","base_url":"http://127.0.0.1:11434/v1","api_key_ref":null,"backend":"ollama"}
```

Docs list `ollama-qwen3` as declared without a golden trace. Confirm
Ollama serves OpenAI-compatible `/v1` and smoke-test before treating as
supported.

### llama.cpp / local OpenAI-compatible (**UNVERIFIED** exact tier)

```json
{"provider":"openai-compat","model":"local-model","base_url":"http://127.0.0.1:8080/v1","api_key_ref":null,"backend":"llamacpp"}
```

Confirm the local server's path and model id; adjust `backend` to
`vllm` / `generic` if needed.

### xAI Grok as generic OpenAI-compatible (**UNVERIFIED**)

```json
{"provider":"openai-compat","model":"grok-2-latest","base_url":"https://api.x.ai/v1","api_key_ref":"llm.key.xai","backend":"generic"}
```

Test one completion before documenting as working in a deployment.

## Guest path (from a cell)

```python
cfg = use("agent:config@v1")
cfg.set("llm.tier.codegen", {
  "provider": "openai-compat",
  "model": "…",
  "base_url": "https://openrouter.ai/api/v1",
  "api_key_ref": "llm.key.openrouter",
})
```

## Smoke test per tier

1. Save current rows (rollback).
2. Preflight key status (`status: "set"`, hosts match `base_url`) without
   printing `value`.
3. Write whole value objects for the tiers you change.
4. One agent-tagged or user chat turn asking for the model name.
5. `anyrt trace show run_<id> --stats` — tokens/cost; errors →
   `reference/debugging.md`.
