# Subagents and advanced-delegation

Per-profile settings live in that profile's `config.yaml` (and credentials in `.env`).
Prefer CLI / dashboard / Desktop Settings over large hand-edits.

Official docs:

- https://hermes-agent.nousresearch.com/docs/user-guide/features/delegation
- https://hermes-agent.nousresearch.com/docs/plugins/advanced-delegation
- https://github.com/NousResearch/hermes-official-plugins/tree/main/advanced-delegation

Related: `models.md` for main / auxiliary / fallback / MoA. The parent **routing model** is `model.*` in `models.md`.

## Overview

**Expectation for every Hermes profile that should fan out work:** enable the
`delegation` toolset, set the **routing model** (parent `model.*`), and prefer
**task-specific models** via the official **`advanced-delegation`** plugin
(`delegation.backend: model_map`).

**Org default (Anytype Local parent):** most parents use **llamacpp `LFM3-1.7B-Q8_0`** as
`model.*` (chat + route picking) and **llamacpp `d1-2b-q4_k_m`** for
`auxiliary.approval`. That parent answers other agents / light asks itself when
no Subagent is needed, and picks named `model_map` routes (from Anytype Subagent
objects) for specialized work. Exceptions: Foyer and CLASQUIN (no Subagents).

### Three layers: rooms vs routing model vs task routes

| Layer | Where | Role |
|-------|--------|------|
| **Messaging Group** | Anytype typed `group` + Agent.`messaging_group` | Human-visible Telegram/Discord room roster. **Not** a delegation backend. See `messaging-groups.md` |
| **Routing model** | Parent `model.*` (main brain) | Plans the work and **chooses** a named route per `delegate_task` item (`option` or `profile`) |
| **Task-specific models** | `delegation.backends.model_map.options` | Named routes (`fast`, `deep`, `local`, …) the parent may pick; each is a full provider·model (+ optional reasoning / tier) |
| **Single worker (no routes)** | `delegation.model` / `provider` with `backend: default` | Every child uses one model; no per-task choice |
| **Profile personas** | `delegation.backends.profile_routes` | Child runs **as** another Hermes profile (SOUL, skills, creds) |

There is no separate `routing_model` config key. The parent session's main model
**is** the router. Give orchestrators a capable main model; put cheap/heavy
workers in `model_map` routes.

**One active delegation backend at a time** (`default` | `model_map` |
`profile_routes`). Switching modes keeps the other mode's `backends.*` block
for later. Messaging Groups stay linked and unchanged when you switch backends.

Subagents are **not** separate profiles (unless you use `profile_routes`). They
are fresh child runs with isolated context; only the final summary returns.
Parent must pass full `goal` + `context` (children know nothing of prior chat).
Repo context files may still inject into the child system prompt; `SOUL.md` does
not (except under `profile_routes`, where the child runs **as** that profile).

**Anytype mode select:** Agent.`delegation_backend` is the intended Hermes
`delegation.backend`. Prefer `model_map` for Local-parent + Subagent role packs;
use `profile_routes` when the parent should hand work to teammate **Agents**
(strong-fit: Sidonie, Kléber, Henri, Noémie, Geneviève). Filling
`profile_route_targets` does not replace Group membership.

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
      default: fast                   # REQUIRED on Local parent: unrouted children use this (never inherit lfm3)
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

### Org enforcement (Local parent + model_map) — mandatory

Three mitigations after unrouted children inherited parent **lfm3**
(Octave `deleg_e2211d4e`, 2026-11-05):

1. **`model_map.default`** — always set to a live Subagent `task_key` on Local
   parents (`hermes -p <slug> config set delegation.backends.model_map.default <key>`).
   Unrouted `delegate_task` must not fall through to lfm3.
2. **Always pass `option`** — SOUL + Shared Rules (rule 26): every spawn sets
   `option` to a route matching Subagent `task_key`, with full `goal` + `context`.
3. **Rebuild tool schema** — after any `model_map` / mode change, `/delegation model_map --now`
   or `/new` (and `hermes -p <slug> sessions refresh-prompts` after SOUL edits).
   Stale sessions can omit the `option` enum even when config is correct.

Verify: `hermes -p <slug> delegation config --show` prints `default: <key>`.
Child `manifest.json` / `task_json` must show the route model, not `lfm3`, when
the parent intended a Subagent.

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

**Anytype decline (org):** when Agent.`delegation_backend=profile_routes`, build
the allowlist from Agent.`profile_route_targets` (each target's
`hermes_profile` → route `name`, `short_description` → `description`) and
Agent.`profile_routes_default` → `default`. Keep linked Subagents for docs;
Hermes activates one backend at a time (`model_map` block may stay in YAML
inactive). Strong-fit parents (2026-11-05): `sidonie`, `kleber`, `henri`,
`noemie`, `genevieve`. After apply: `/delegation profile_routes --now` or `/new`.

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

## Recipe: local routing model + task-specific workers (`model_map`)

**Preferred org pattern:** local parent (routing model) answers peers / light
asks itself and picks `fast` / `deep` / `fetch` / … only when a Subagent route
fits; children run on the named route (often Coding / Data fetching stacks).

```bash
hermes -p <slug> tools enable delegation
hermes -p <slug> plugins install advanced-delegation
hermes -p <slug> model                    # set local routing / main model
hermes -p <slug> delegation config        # mode = Model routes; add fast/deep/fetch…
# or hand-edit config.yaml as below, then:
hermes -p <slug> config set delegation.backend model_map
hermes -p <slug> doctor
hermes -p <slug> delegation config --show
```

```yaml
local_runtime:
  enabled: true
  backend: auto                           # cuda / metal / vulkan / cpu

model:
  provider: llamacpp                      # Local parent chat (LFM3-1.7B-Q8_0)
  default: LFM3-1.7B-Q8_0

auxiliary:
  approval:
    provider: llamacpp
    model: d1-2b-q4_k_m                   # Hermes builtin; local_runtime enabled
  compression:
    provider: auto
    model: ''
  vision:
    provider: auto
    model: ''
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
(`fast` / `deep` / …) under **Subagents / delegation**. Prefer sourcing those
routes from Anytype **Subagent** objects (see below).

## Decline from Anytype Subagent objects

When the org uses skill `anytype-agents`, most parents link **Local parent** as
`harness_profile` and zero or more typed **`subagent`** objects
(`parent_agent` + Agent.`subagents`). Decline Local parent → parent `model.*`
(llamacpp/LFM3-1.7B-Q8_0) + `auxiliary.approval` (llamacpp/d1). Treat Subagents as the
source of truth for `model_map` routes. Do not invent a Subagent for “quick
peer answers”; that stays on the local parent.

**When to apply:** push `model_map` / new Subagent routes into live Hermes only
after an accepted Anytype **`suggestion`** (kinds `new_subagent` / `model_fit` /
`harness`) or when the user explicitly asks. Until then, keep the intended
routes on the Anytype Subagent objects. Loop docs: `anytype-agents` →
`suggestions.md`.

| Anytype Subagent field | Hermes `model_map` option |
|------------------------|---------------------------|
| `task_key` | `name` |
| `intent` | `description` |
| `harness_profile` `model_*` (or `model_override`) | `provider` + `model` (resolve labels to runtime ids) |
| `spawn_effort` (else profile `model_effort`) | `reasoning_effort` when the provider supports it |
| harness `fallback_1_*` then `fallback_2_*` | ordered `fallback_providers` on **that route** (not parent top-level) |
| `scope`, `toolsets`, `deliver_back` | Child brief / parent prompt notes (Hermes children inherit parent tools unless you use `profile_routes`) |

Steps:

1. Read the parent Agent in Anytype (`format: md`) and list linked Subagents
   (`type: subagent`, filter by `parent_agent` or Agent.`subagents`).
2. Decline parent Agent.`harness_profile` (usually **Local parent**) into
   `model.*` + `auxiliary.approval` + `local_runtime` for d1: prefer profile
   `model_provider` / `model_default` (org: `llamacpp` / `LFM3-1.7B-Q8_0`) and
   `aux_approval_*` (`llamacpp` / `d1-2b-q4_k_m`); see `models.md`
   **Local parent**. Also map `fallback_*` and other `aux_*` when filled.
3. For each live Subagent, open its `harness_profile` and take `model_*` /
   effort (honor `model_override` / `spawn_effort` when set) plus `fallback_1_*`
   / `fallback_2_*` → that option's `fallback_providers`.
4. `hermes -p <slug> tools enable delegation`
5. `hermes -p <slug> plugins install advanced-delegation`
6. `hermes -p <slug> delegation config` (or edit YAML) → `backend: model_map` with
   one option per Subagent `task_key` (include route `fallback_providers`)
7. **Always set `model_map.default`** to one live Subagent `task_key` when the
   parent is Local (lfm3). Light peer answers still stay on the parent without
   spawning; but if the parent calls `delegate_task` without `option`, children
   must **not** inherit lfm3 (set `default` to the most common route: `web` /
   `deep` / `fast`). Keep parent top-level `fallback_providers` empty on Local
   parent.
8. Enforce in SOUL + Shared Rules: every `delegate_task` sets **`option`** to a
   live route matching Subagent `task_key`, with full `goal` + `context`.
9. After route edits: `/delegation model_map --now` or `/new` so the `option`
   enum is on the tool schema (built at session start).
10. `hermes -p <slug> delegation config --show` and confirm each route's
   fallbacks match the Subagent harness order and that **`default:`** is set.

Example declined from three Subagents (Coding + Data fetching profiles):

```yaml
delegation:
  backend: model_map
  backends:
    model_map:
      default: fast
      options:
        - name: fast
          description: Small edits, simple tests
          provider: anthropic
          model: claude-sonnet-4-5
          reasoning_effort: medium
        - name: deep
          description: Hard debugging and careful refactors
          provider: anthropic
          model: claude-sonnet-4-5
          reasoning_effort: high
        - name: fetch
          description: Lookups, scrape, light summary
          provider: openai
          model: gpt-5.1-codex  # resolve Codex Terra label to the live id
          reasoning_effort: high
```

Provider/model strings above are illustrative; resolve each Harness profile label
to the ids your runtime actually accepts (`models.md`).

## Decision guide

| Need | Configure |
|------|-----------|
| Shared human chat room for HQ/domain bots | Anytype typed **Group** + Agent.`messaging_group` (`messaging-groups.md`); join HQ Group before minting a new room |
| Parallel research / isolated workers | `tools enable delegation` + `delegate_task` |
| **Local parent router (org default)** | Anytype Local parent → `model.*` LFM3-1.7B-Q8_0 (llamacpp) + `auxiliary.approval` d1; answer peers without spawning |
| **Routing model** (who picks routes) | Parent `model.*` — see `models.md` |
| **Task-specific models** (named routes) | `plugins install advanced-delegation` + `delegation.backend: model_map` + `backends.model_map.options`; set Agent.`delegation_backend=model_map` |
| Routes from Anytype Subagent objects | Decline table above; keep Agent.`subagents` in sync |
| Child uses another **Agent profile's** persona | `delegation.backend: profile_routes` (+ plugin); Anytype `delegation_backend=profile_routes` + `profile_route_targets` |
| One cheap worker for every child | `delegation.backend: default` + `delegation.model` |
