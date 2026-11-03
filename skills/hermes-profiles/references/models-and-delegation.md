# Models, auxiliary, fallback, subagents, MoA

Per-profile settings live in that profile's `config.yaml` (and credentials in `.env`).
Prefer CLI / dashboard / Desktop Settings over large hand-edits.

Official docs:

- https://hermes-agent.nousresearch.com/docs/user-guide/configuring-models
- https://hermes-agent.nousresearch.com/docs/user-guide/features/fallback-providers
- https://hermes-agent.nousresearch.com/docs/user-guide/features/delegation
- https://hermes-agent.nousresearch.com/docs/user-guide/features/mixture-of-agents

## Slot map

| Slot | Role |
|------|------|
| **Main model** (`model.*`) | Thinks, tools, streamed replies |
| **Auxiliary** (`auxiliary.<task>.*`) | Side jobs: compression, vision, titles, approval, … |
| **Fallback** (`fallback_providers`) | Backup provider:model when main fails mid-turn |
| **Subagents** (`delegation.*`) | `delegate_task` children; optional cheaper model |
| **MoA** (`moa.presets`) | Virtual provider: reference advisors + acting aggregator |

All of the above are **per profile**. Cloning a profile copies them unless you override afterward.

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

## Subagents (`delegate_task`)

Subagents are **not** separate profiles. They are fresh child runs with isolated context; only the final summary returns to the parent.

```yaml
delegation:
  model: google/gemini-2.5-flash      # optional cheaper workers
  provider: openrouter                # optional; else inherit parent
  max_concurrent_children: 10
  max_spawn_depth: 1                  # 1 = flat (default); raise for nested orchestrators
  orchestrator_enabled: true
  # independent_completions: false
```

```bash
hermes -p <slug> config set delegation.model google/gemini-2.5-flash
hermes -p <slug> config set delegation.provider openrouter
```

Parent must pass full `goal` + `context` (children know nothing of prior chat). Repo context files may still inject into the child system prompt; `SOUL.md` does not.

**Strategies** (`delegation.backend`, often via `advanced-delegation` plugin):

| Backend | Behavior |
|---------|----------|
| `default` | All children use `delegation.model` / inherit |
| `model_map` | Parent picks named options (`fast`, `deep`, …) per task |
| `profile_routes` | Child runs **as another Hermes profile** (that profile's model, SOUL, skills, credentials) |

```yaml
delegation:
  backend: model_map
  backends:
    model_map:
      default: fast
      options:
        - name: fast
          description: Lookups and summaries.
          provider: openrouter
          model: google/gemini-2.5-flash
        - name: deep
          description: Hard debugging.
          provider: anthropic
          model: claude-opus-4
          reasoning_effort: high
```

`/review` uses a background reviewer; pin with `auxiliary.review` if desired. Monitor with `/agents` (Ctrl+T).

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

## Recipe: frontier planner, cheap workers, flash aux

```yaml
model:
  provider: openrouter
  default: anthropic/claude-opus-4

fallback_providers:
  - provider: openrouter
    model: anthropic/claude-sonnet-4

auxiliary:
  compression:
    provider: openrouter
    model: google/gemini-2.5-flash
  vision:
    provider: openrouter
    model: google/gemini-2.5-flash
  approval:
    provider: openrouter
    model: google/gemini-2.5-flash

delegation:
  provider: openrouter
  model: google/gemini-2.5-flash
  max_concurrent_children: 8
```

Verify:

```bash
hermes -p <slug> doctor
hermes -p <slug> config get model.default
# Inspect YAML sections: model, auxiliary, fallback_providers, delegation, moa
```

## Decision guide

| Need | Configure |
|------|-----------|
| Default chat brain | `model.*` |
| Cheaper summaries / vision / approvals | `auxiliary.<task>.*` |
| Survive primary outages | `fallback_providers` |
| Parallel research / isolated workers | `delegation.*` + `delegate_task` |
| Child uses another profile's persona | `delegation.backend: profile_routes` |
| Multi-model advice, one acting loop | `moa` preset as main via provider `moa` |
