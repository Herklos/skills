# Models, auxiliary, fallback, MoA

Per-profile settings live in that profile's `config.yaml` (and credentials in `.env`).
Prefer CLI / dashboard / Desktop Settings over large hand-edits.

Official docs:

- https://hermes-agent.nousresearch.com/docs/user-guide/configuring-models
- https://hermes-agent.nousresearch.com/docs/user-guide/features/fallback-providers
- https://hermes-agent.nousresearch.com/docs/user-guide/features/mixture-of-agents

Related: `delegation.md` (subagents / advanced-delegation). Parent `model.*` is also the **routing / decision model** when delegating.

Official local models: https://hermes-agent.nousresearch.com/docs/user-guide/local-models

## Slot map

| Slot | Role |
|------|------|
| **Main / decision / routing model** (`model.*`) | Thinks, tools, streamed replies; when delegating, **picks** the per-task route |
| **Auxiliary** (`auxiliary.<task>.*`) | Side jobs: compression, vision, titles, approval, … |
| **Fallback** (`fallback_providers`) | Backup provider:model when main fails mid-turn |
| **Subagents** | See `delegation.md` |
| **MoA** (`moa.presets`) | Virtual provider: reference advisors + acting aggregator |

All of the above are **per profile**. Cloning a profile copies them unless you override afterward.

When declining from Anytype **Harness profile** (Hermes-shaped keys):

| Anytype | Hermes |
|---------|--------|
| `model_provider` + `model_default` (+ `model_effort`) | `model.*` (main / decision / routing) |
| `fallback_1_*` / `fallback_2_*` (`provider`, `model`, optional `effort` / `harness`) | ordered `fallback_providers` |
| `aux_<task>_provider` / `aux_<task>_model` (+ effort) for `vision`, `compression`, `web_extract`, `skills_hub`, `title_generation`, **`approval`** | `auxiliary.<task>.*` (`auto` + empty model = inherit main) |
| `model_harness` / `fallback_*_harness` | catalog UX only |

Anytype often stores **display labels** (`Grok 4.5`, `Claude Code Sonnet 5.5`,
`Codex Sol 6.1`). Resolve to runtime provider + model id via
`~/.hermes/provider_models_cache.json` before writing config. Label map and
full apply order: `anytype-apply.md`.

If provider is `llamacpp`, also enable `local_runtime` (see Local parent).

**When to apply:** write live `model.*` / `auxiliary.*` / `fallback_providers`
only after an accepted Anytype **`suggestion`** (kinds `model_fit` / `harness`)
or when the user explicitly asks. Source of truth for the loop:
`anytype-agents` → `suggestions.md`. Editing Anytype does not push config.

## Main model

```bash
hermes -p <slug> model                 # interactive picker
hermes -p <slug> config set model.provider openrouter
hermes -p <slug> config set model.default anthropic/claude-sonnet-4
```

```yaml
model:
  provider: openrouter
  default: anthropic/claude-sonnet-4
  api_mode: chat_completions
```

Mid-session: `/model` in chat. New sessions pick up `config.yaml` changes; open chats keep their start model until switched.

## Local parent (Mistral chat + llamacpp approval)

**Org default for Local parent agents** (Foyer stays dual-local; see below):

| Role | Provider | Model | Notes |
|------|----------|-------|-------|
| **Chat / route picking** (`model.*`) | `mistral` | `zai-glm-5-3-flash` | Effort **low**. Custom provider `providers.mistral` → `https://api.mistral.ai/v1`; key `HERMES_CUSTOM_MISTRAL_API_KEY`. Display name GLM-5.3-Flash. |
| **Approvals** (`auxiliary.approval.*`) | `llamacpp` | `d1-2b-q4_k_m` | Managed runtime (`local_runtime`); GGUF `d1-2B-Q4_K_M.gguf`. |

**Foyer** (sidonie / philippe / blanche / bob): keep dual local chat
`llamacpp` / `LFM3-1.7B-Q8_0` + same d1 approvals. Do not migrate Foyer to Mistral
unless the user asks.

Parent answers peers / light asks on Flash and picks Subagent routes when needed
(`delegation.md`). Hermes has no separate routing-model slot: route picking uses
`model.*`. Smart command approvals use d1 via `auxiliary.approval`.

Anytype **Local parent** stores chat as `model_provider: mistral`,
`model_default: zai-glm-5-3-flash`, `model_effort: low`, `model_harness` →
**Mistral** catalog, plus `aux_approval_provider: llamacpp`,
`aux_approval_model: d1-2b-q4_k_m`. **Foyer** harness stays
`llamacpp` / `LFM3-1.7B-Q8_0` / none.

### Config shape (Local parent)

```yaml
local_runtime:
  enabled: true
  backend: auto          # needed for aux approval d1

model:
  provider: mistral
  default: zai-glm-5-3-flash
  api_mode: chat_completions
  base_url: https://api.mistral.ai/v1
  key_env: HERMES_CUSTOM_MISTRAL_API_KEY

providers:
  mistral:
    name: Mistral
    base_url: https://api.mistral.ai/v1
    key_env: HERMES_CUSTOM_MISTRAL_API_KEY
    discover_models: true
    model: zai-glm-5-3-flash

auxiliary:
  approval:
    provider: llamacpp
    model: d1-2b-q4_k_m
```

```bash
# Ensure key in profile .env (copy from default; do not print)
# HERMES_CUSTOM_MISTRAL_API_KEY=…

hermes -p <slug> config set model.provider mistral
hermes -p <slug> config set model.default zai-glm-5-3-flash
hermes -p <slug> config set model.api_mode chat_completions
hermes -p <slug> config set model.base_url https://api.mistral.ai/v1
hermes -p <slug> config set model.key_env HERMES_CUSTOM_MISTRAL_API_KEY
hermes -p <slug> config set providers.mistral.name Mistral
hermes -p <slug> config set providers.mistral.base_url https://api.mistral.ai/v1
hermes -p <slug> config set providers.mistral.key_env HERMES_CUSTOM_MISTRAL_API_KEY
hermes -p <slug> config set providers.mistral.discover_models true
hermes -p <slug> config set providers.mistral.model zai-glm-5-3-flash
hermes -p <slug> config set local_runtime.enabled true
hermes -p <slug> config set local_runtime.backend auto
hermes -p <slug> config set auxiliary.approval.provider llamacpp
hermes -p <slug> config set auxiliary.approval.model d1-2b-q4_k_m
```

### Foyer (dual local) config

```bash
hermes -p <slug> config set model.provider llamacpp
hermes -p <slug> config set model.default LFM3-1.7B-Q8_0
hermes -p <slug> config set model.api_mode chat_completions
hermes -p <slug> config set model.base_url http://127.0.0.1:18434/v1
hermes -p <slug> config set local_runtime.enabled true
hermes -p <slug> config set auxiliary.approval.provider llamacpp
hermes -p <slug> config set auxiliary.approval.model d1-2b-q4_k_m
```

Add LFM3 and d1 GGUFs via Desktop **Add model file** when Foyer/local approval
needs them. Hermes manages llama-server via `local_runtime`.

### Migrate notes

- **2026-11-06:** most Hermes profiles + Anytype Local parent → Mistral Flash;
  Foyer 4 left on LFM3. Ledger `/tmp/mistral-flash-migrate/`.
- Older Ollama `lfm3` / dual-local Local parent shape is retired for non-Foyer.
- No cloud `fallback_providers` on Local parent / Foyer by org default.
- Cloning a profile with default clone flags excludes local model trees and may
  omit `HERMES_CUSTOM_MISTRAL_API_KEY`; copy the key into the new profile `.env`.

## Auxiliary models

Side tasks default to `auto` (try main, then task `fallback_chain`, then top-level `fallback_providers`). Hermes does not invent another logged-in provider.

Common tasks (names as in config):

| Task key | Typical use |
|----------|-------------|
| `vision` | Image analysis when main lacks vision |
| `compression` | Context summarization (prefer cheap/fast) |
| `approval` | Smart command-approval scoring |
| `web_extract` | Page summarization |
| `title_generation` | Session titles |
| `skills_hub` | Skill search |
| `mcp` | MCP tool routing |
| `review` | `/review` reviewer model |
| `profile_describer` | `hermes profile describe --auto` |
| `curator` | Skill-usage curator pass |
| Kanban-related aux slots | Triage specifier / decomposer when Kanban is used |

```bash
hermes -p <slug> config set auxiliary.vision.provider openrouter
hermes -p <slug> config set auxiliary.vision.model google/gemini-2.5-flash
hermes -p <slug> config set auxiliary.compression.provider auto
hermes -p <slug> config set auxiliary.compression.model ''
```

```yaml
auxiliary:
  vision:
    provider: openrouter
    model: google/gemini-2.5-flash
  compression:
    provider: auto
    model: ''
  title_generation:
    provider: auto
    model: ''
    fallback_chain:
      - provider: openrouter
        model: some/cheap-flash-model
  review:
    provider: openrouter
    model: anthropic/claude-opus-4.6
```

Dashboard: Models → Show auxiliary. Desktop: Settings → Model.

## Fallback (backup) providers

When the main model hits rate limits, 5xx, auth failures, etc., Hermes can switch to another provider:model for **that turn**, then try primary again next message.

```bash
hermes -p <slug> fallback          # interactive manager
hermes -p <slug> fallback add
hermes -p <slug> fallback list
```

```yaml
fallback_providers:
  - provider: openrouter
    model: anthropic/claude-sonnet-4
  - provider: custom
    model: local-model
    base_url: http://127.0.0.1:8000/v1
    key_env: MY_LOCAL_KEY

# Legacy single entry still honored; prefer the list above:
# fallback_model:
#   provider: openrouter
#   model: anthropic/claude-sonnet-4
```

Notes:

- Credential pools rotate keys for the **same** provider; fallback switches **provider:model**.
- Fallback can be a MoA preset (`provider: moa`, `model: <preset-name>`).
- Prompt cache resets on switch (cost implication).
- Optional: `fallback.min_switch_reset_seconds` to wait out short rate-limit windows.

## Mixture of Agents (MoA)

MoA is a **virtual provider**. A preset = reference models (advise, no tools) + aggregator (acting model that tools and replies). Cost mostly lands on the aggregator.

```bash
hermes -p <slug> moa configure [name]
hermes -p <slug> moa list
# Select like any model:
# /model <preset> --provider moa
# /moa <one-shot prompt>   # temporary; restores previous model after
```

```yaml
moa:
  default_preset: default
  privacy_filter: display    # optional: display | full
  presets:
    default:
      enabled: true
      fanout: user_turn      # user_turn | per_iteration | every_n:3
      reference_models:
        - provider: openrouter
          model: deepseek/deepseek-chat
          reasoning_effort: low
        - provider: openai-codex
          model: gpt-5.5
      aggregator:
        provider: openrouter
        model: anthropic/claude-opus-4
        reasoning_effort: high
```

Configure also via Dashboard / Desktop → Model → Mixture of Agents.

## Decision guide (models)

| Need | Configure |
|------|-----------|
| Default chat brain / decision / routing model | `model.*` |
| **Local parent (org default)** | Chat `llamacpp`/`LFM3-1.7B-Q8_0`; approval `llamacpp`/`d1-2b-q4_k_m` + `local_runtime` (section above) |
| Cheaper summaries / vision / approvals | `auxiliary.<task>.*` |
| Survive primary outages | `fallback_providers` |
| Multi-model advice, one acting loop | `moa` preset as main via provider `moa` |
| Task-specific subagent models | `delegation.md` + advanced-delegation |
