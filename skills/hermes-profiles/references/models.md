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
| `aux_<task>_provider` / `aux_<task>_model` (+ effort) for `vision`, `compression`, `web_extract`, `skills_hub`, `title_generation` | `auxiliary.<task>.*` (`auto` + empty model = inherit main) |
| `model_harness` / `fallback_*_harness` | catalog UX only |

If provider is `llamacpp`, also enable `local_runtime` (see Local decision model).

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

## Local parent (Ollama chat + llamacpp approval)

**Org default for Local parent / Foyer agents:**

| Role | Provider | Model | Notes |
|------|----------|-------|-------|
| **Chat / route picking** (`model.*`) | `ollama-launch` (or `ollama`) | `lfm3` | Effort **none**. Ollama must serve lfm3. **llamacpp cannot run lfm3.** |
| **Approvals** (`auxiliary.approval.*`) | `llamacpp` | `d1-2b-q4_k_m` | Hermes builtin llama.cpp managed runtime (`local_runtime`) |

Parent answers peers / light asks on lfm3 and picks Subagent routes when needed
(`delegation.md`). Hermes has no separate routing-model slot: route picking uses
`model.*` (lfm3). Smart command approvals use d1 via `auxiliary.approval`.

Anytype **Local parent** / **Foyer** store chat as `model_provider: ollama-launch`,
`model_default: lfm3`, `model_effort: none`, plus `aux_approval_provider: llamacpp`,
`aux_approval_model: d1-2b-q4_k_m`. Prefer those fields when applying; if Hermes
assigns a slightly different local name after **Add model file**, use the exact
id Hermes shows.

### Config shape

```yaml
local_runtime:
  enabled: true
  backend: auto          # or cuda / metal / vulkan / cpu

model:
  provider: ollama-launch   # or ollama — match live Hermes provider key
  default: lfm3

auxiliary:
  approval:
    provider: llamacpp
    model: d1-2b-q4_k_m
```

```bash
hermes -p <slug> config set model.provider ollama-launch
hermes -p <slug> config set model.default lfm3
hermes -p <slug> config set local_runtime.enabled true
hermes -p <slug> config set auxiliary.approval.provider llamacpp
hermes -p <slug> config set auxiliary.approval.model d1-2b-q4_k_m
```

Add the d1 GGUF via Desktop **Add model file** (links without copying). Hermes
manages the llama-server for approvals. Keep Ollama running for lfm3 chat.

Notes:

- `local_runtime.backend: auto` picks CUDA / Metal / Vulkan / CPU for d1.
- Do not put lfm3 on `provider: llamacpp`.
- No cloud `fallback_providers` on Local parent / Foyer by org default.
- Cloning a profile with default clone flags excludes local model trees; re-link
  or re-download the GGUF on the new profile if needed.

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
| **Local parent (org default)** | Chat `ollama-launch`/`lfm3`; approval `llamacpp`/`d1-2b-q4_k_m` + `local_runtime` (section above) |
| Cheaper summaries / vision / approvals | `auxiliary.<task>.*` |
| Survive primary outages | `fallback_providers` |
| Multi-model advice, one acting loop | `moa` preset as main via provider `moa` |
| Task-specific subagent models | `delegation.md` + advanced-delegation |
