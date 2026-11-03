# Models, auxiliary, fallback, subagents, MoA

Per-profile settings live in that profile's `config.yaml` (and credentials in `.env`).
Prefer CLI / dashboard / Desktop Settings over large hand-edits.

Official docs:

- https://hermes-agent.nousresearch.com/docs/user-guide/configuring-models
- https://hermes-agent.nousresearch.com/docs/user-guide/features/fallback-providers
- https://hermes-agent.nousresearch.com/docs/user-guide/features/delegation
- https://hermes-agent.nousresearch.com/docs/plugins/advanced-delegation
- https://github.com/NousResearch/hermes-official-plugins/tree/main/advanced-delegation
- https://hermes-agent.nousresearch.com/docs/user-guide/features/mixture-of-agents

## Slot map

| Slot | Role |
|------|------|
| **Main / routing model** (`model.*`) | Thinks, tools, streamed replies; when delegating, **picks** the per-task route |
| **Auxiliary** (`auxiliary.<task>.*`) | Side jobs: compression, vision, titles, approval, … |
| **Fallback** (`fallback_providers`) | Backup provider:model when main fails mid-turn |
| **Subagents** (`delegation.*`) | `delegate_task` children; one worker model, or named task-specific routes |
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

Docs:

- Core: https://hermes-agent.nousresearch.com/docs/user-guide/features/delegation#configuration
- Plugin: https://hermes-agent.nousresearch.com/docs/plugins/advanced-delegation
- Source: https://github.com/NousResearch/hermes-official-plugins/tree/main/advanced-delegation

**Expectation for every Hermes profile that should fan out work:** enable the
`delegation` toolset, set a strong **routing model** (parent `model.*`), and
prefer **task-specific models** via the official **`advanced-delegation`**
plugin (`delegation.backend: model_map`). Default single-model workers are fine
for simple fleets.

### Two layers: routing model vs task-specific models

| Layer | Where | Role |
|-------|--------|------|
| **Routing model** | Parent `model.*` (main brain) | Plans the work and **chooses** a named route per `delegate_task` item (`option` or `profile`) |
| **Task-specific models** | `delegation.backends.model_map.options` | Named routes (`fast`, `deep`, `local`, …) the parent may pick; each is a full provider·model (+ optional reasoning / tier) |
| **Single worker (no routes)** | `delegation.model` / `provider` with `backend: default` | Every child uses one model; no per-task choice |

There is no separate `routing_model` config key. The parent session's main model
**is** the router. Give orchestrators a capable main model; put cheap/heavy
workers in `model_map` routes.

Subagents are **not** separate profiles (unless you use `profile_routes`). They
are fresh child runs with isolated context; only the final summary returns.
Parent must pass full `goal` + `context` (children know nothing of prior chat).
Repo context files may still inject into the child system prompt; `SOUL.md` does
not (except under `profile_routes`, where the child runs **as** that profile).

### Install advanced-delegation (per profile that delegates)

Needs Hermes **>= 0.22.5** (`requires_hermes` on the plugin). Install on the
**parent** profile only; profile-route targets need no plugin.

```bash
hermes -p <slug> tools enable delegation
hermes -p <slug> plugins install advanced-delegation
# Or follow repo main:
# hermes -p <slug> plugins install NousResearch/hermes-official-plugins#advanced-delegation --enable

hermes -p <slug> delegation config          # pick mode + edit routes (recommended)
hermes -p <slug> delegation config --show   # print mode + routes
```

Desktop: **Settings → Model → Subagents → Install plugin**. One mode is active
at a time (`default` | `model_map` | `profile_routes`). Switching modes keeps
the other mode's `backends.*` block for later.

### Default backend (one worker model for all children)

Built into Hermes (no plugin). Every child uses `delegation.model` / `provider`
(or inherits the parent). **No** per-task model argument on the tool.

```bash
hermes -p <slug> tools enable delegation
hermes -p <slug> config set delegation.model google/gemini-2.5-flash
hermes -p <slug> config set delegation.provider openrouter
hermes -p <slug> config set delegation.backend default
```

```yaml
delegation:
  backend: default                    # or omit; default is built-in
  model: google/gemini-2.5-flash      # optional cheaper workers; empty = inherit parent
  provider: openrouter                # optional; else inherit parent
  max_iterations: 250                 # turns per child
  max_concurrent_children: 10
  max_spawn_depth: 1                  # 1 = flat; raise for nested orchestrators
  orchestrator_enabled: true
  # independent_completions: false    # true = each task/group returns as it finishes
  # worktree_isolation: false
```

### Model routes (`model_map`) — routing model + task-specific models

**Recommended** when task difficulty or cost varies. Plugin adds a per-task
`option` enum on `delegate_task`. The parent (routing model) picks a **name**;
raw provider / model / keys never become tool parameters, so the agent cannot
invent a route.

```yaml
delegation:
  backend: model_map
  max_concurrent_children: 8
  max_iterations: 250
  backends:
    model_map:
      default: fast                   # optional: unrouted tasks; else parent main model
      options:
        - name: fast                  # what the agent picks
          description: Cheap and quick; lookups, summaries, simple edits.
          provider: openrouter
          model: google/gemini-2.5-flash
        - name: deep
          description: Slow and careful; hard debugging and design work.
          provider: anthropic
          model: claude-opus-4
          reasoning_effort: high
          service_tier: fast          # optional: normal | fast | ultrafast (if offered)
        - name: local
          description: Private; runs on this machine.
          base_url: http://localhost:8080/v1
          model: qwen3-coder
```

Route keys: `name` + `description` (required), `model` (required), `provider`
and/or `base_url` (at least one), optional `reasoning_effort`, `service_tier`,
`fallback_providers`, `api_mode`, `api_key`. Prefer `provider:` (credentials in
`.env` / `auth.json`) over inline `api_key` (plain text in `config.yaml`).

While `model_map` or `profile_routes` is active, top-level `delegation.model` /
`provider` are **inactive** (they apply again when you switch back to
`default`). Each child result reports `route` (label + resolved provider/model/
effort/tier).

```bash
hermes -p <slug> config set delegation.backend model_map
hermes -p <slug> delegation config    # interactive route editor (uses hermes model pickers)
# Or hand-set (YAML list as one value):
# hermes -p <slug> config set delegation.backends.model_map.default fast
```

In chat (after plugin install):

```text
/delegation                          # show modes + picker
/delegation model_map                # save; applies next session (/new)
/delegation model_map --now          # save + rebuild this chat's tools (cache break)
/delegation default                  # back to single-worker mode
```

Schema is built at session start. Mid-chat mode changes need `/new` or `--now`.

### Profile routes (`profile_routes`)

Per-task `profile` choice: child runs **as** another Hermes profile (that
profile's model, SOUL, skills, credentials, terminal policy).

```yaml
delegation:
  backend: profile_routes
  backends:
    profile_routes:
      default: coder                  # optional
      profiles:                       # allowlist + what the agent reads
        - name: coder
          description: Writes and refactors code; runs tests.
        - name: researcher
          description: Web research and long-form summaries.
```

Only list profiles this parent may use. Unlisted profiles cannot be picked.

| Backend | Behavior |
|---------|----------|
| `default` | All children use `delegation.model` / inherit parent (no per-task choice) |
| `model_map` | Parent routing model picks named **task-specific** model routes |
| `profile_routes` | Parent picks a **profile** persona/home per task |

### Related knobs

| Knob | Role |
|------|------|
| Parent `model.*` | **Routing model** (plans + picks `option` / `profile`) |
| `delegation.backends.model_map.*` | Task-specific model routes |
| `delegation.backends.profile_routes.*` | Task-specific profile allowlist |
| `delegation.max_iterations` | Tool-calling turns per child (default 250) |
| `delegation.max_concurrent_children` | Parallel children per batch (default 10) |
| `delegation.independent_completions` | Per-task/group wake-ups vs one consolidated return |
| `delegation.request_overrides` | Extra API kwargs / `extra_body` on every child call |
| `delegation.base_url` + `api_key` | Direct endpoint instead of named provider (default backend) |
| `auxiliary.review` | Dedicated model for `/review` (separate from `delegate_task`) |

`/review` uses a background reviewer; pin with `auxiliary.review` if desired.
Monitor with `/agents` (Ctrl+T).

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

## Recipe: strong routing model + task-specific workers (`model_map`)

Preferred pattern: capable parent (routing model) plans and picks `fast` /
`deep` / … per task; children run on the named route.

```bash
hermes -p <slug> tools enable delegation
hermes -p <slug> plugins install advanced-delegation
hermes -p <slug> model                    # set strong routing / main model
hermes -p <slug> delegation config        # mode = Model routes; add fast/deep/…
# or hand-edit config.yaml as below, then:
hermes -p <slug> config set delegation.backend model_map
hermes -p <slug> doctor
hermes -p <slug> delegation config --show
```

```yaml
model:
  provider: openrouter
  default: anthropic/claude-opus-4        # routing model (picks option per task)

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
  review:
    provider: openrouter
    model: anthropic/claude-opus-4.6

delegation:
  backend: model_map
  max_concurrent_children: 8
  max_iterations: 250
  backends:
    model_map:
      default: fast
      options:
        - name: fast
          description: Lookups, summaries, simple edits.
          provider: openrouter
          model: google/gemini-2.5-flash
        - name: deep
          description: Hard debugging, design, careful refactors.
          provider: openrouter
          model: anthropic/claude-sonnet-4
          reasoning_effort: high
```

Simpler single-worker fleet (all children one cheap model, no plugin):

```yaml
delegation:
  backend: default
  provider: openrouter
  model: google/gemini-2.5-flash
  max_concurrent_children: 8
```

Verify:

```bash
hermes -p <slug> tools enable delegation
hermes -p <slug> plugins list | grep -i advanced-delegation
hermes -p <slug> doctor
hermes -p <slug> config get model.default
hermes -p <slug> delegation config --show
# Inspect YAML: model, auxiliary, fallback_providers, delegation, moa
```

Document on the agent page: routing model (primary) + named task routes
(`fast` / `deep` / …) under **Subagents / delegation**.

## Decision guide

| Need | Configure |
|------|-----------|
| Default chat brain / **routing model** | `model.*` |
| Cheaper summaries / vision / approvals | `auxiliary.<task>.*` |
| Survive primary outages | `fallback_providers` |
| Parallel research / isolated workers | `tools enable delegation` + `delegate_task` |
| **Task-specific models** (named routes) | `plugins install advanced-delegation` + `delegation.backend: model_map` + `backends.model_map.options` |
| Child uses another profile's persona | `delegation.backend: profile_routes` (+ plugin) |
| One cheap worker for every child | `delegation.backend: default` + `delegation.model` |
| Multi-model advice, one acting loop | `moa` preset as main via provider `moa` |
