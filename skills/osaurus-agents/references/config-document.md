# Declarative config document

Docs: https://docs.osaurus.ai/configuration#declarative-configuration

Manage desired state with YAML or JSON (≤ 512 KiB). Same engine as Orchestrator
`osaurus_config`, CLI `osaurus config *`, and loopback `/admin/config/*`.

## Workflow

```bash
osaurus config export -o osaurus-config.yaml
osaurus config schema                 # annotated YAML; --format json for JSON Schema
osaurus config plan osaurus-config.yaml
osaurus config apply osaurus-config.yaml
# destructive / high-risk:
osaurus config plan osaurus-config.yaml --prune
osaurus config apply osaurus-config.yaml --prune --yes
```

Access key when required: `--access-key` or `OSAURUS_API_KEY`.

Exit codes (`apply`): `0` converged, `1` failed/cancelled, `3` applied but
interactive step remains (credential sheet, etc.).

## Semantics and safety

- **Merge by default.** Absent keys untouched; explicit `null` clears an optional override.
- **Match by name** (case-insensitive) for agents, providers, MCP servers, schedules, watchers, harness runtimes.
- **Plan is read-only.** Only `apply` mutates.
- **`--prune`** is a CLI flag, not a document key. Deletes unlisted entries only in sections the document declares; refuses broken cross-references.
- **Validation is all-or-nothing.** Unknown keys / bad values / bad refs stop the whole document.
- **High-risk** needs `--yes`: prune deletions; browser or Computer Use grants; relay exposure; channel writes; new or stdio MCP endpoints; runtime command/env; moving an agent onto a runtime; Claude Code shell or `allow_osaurus_config_writes`; automatic tool policies; looser delegation permissions.
- Cap **512 KiB**.

## Document sections

Documents can manage all of:

| Key | Covers |
|-----|--------|
| `version` | Document version (`1`) |
| `memory` | Memory master toggles / budget (see below) |
| `default_agent` | Orchestrator: `name`, `model`, `system_prompt`, `runtime`, `claude_code` (incl. `allow_osaurus_config_writes`) |
| `new_chat_agent` | `default` (Orchestrator) or custom agent name (`active_agent` still accepted) |
| `agents` | Custom agents list |
| `delegation` | Spawnable agents, workspace join, budgets, permission defaults, local-model memory |
| `harness_runtimes` | External Claude Code / Pi programs (`harness-runtimes.md`) |
| `tools` | Tool surface (with agent-level tools) |
| `plugins` | Native plugins enablement |
| `mcp_servers` | MCP HTTP/stdio servers |
| `commands` | Slash commands |
| `knowledge_collections` | Knowledge collections |
| `channels` | Messaging channels (`bot_token_ref`, …) |
| `models` | Local models |
| `providers` | Cloud providers (`api_key_ref`, …) |
| `search_providers` | Web search providers |
| `schedules` | Timed jobs (match by name) |
| `watchers` | Folder watchers (match by name) |

### Sections worth knowing (docs table)

| Key | Detail |
|-----|--------|
| `agents[].model` | `null` inherits Orchestrator |
| `agents[].capabilities` | Switches incl. `image_enabled`, `applescript_enabled`, `browser_use_enabled`, `computer_use_enabled`, `apple_apps` list (`calendar`, `reminders`, `contacts`, `notes`, `mail`, `messages`, `maps`, `music`, `shortcuts`) replacing the set |
| `agents[].skills` | Omit = unchanged; `null` = every installed skill; list of names/slugs; `[]` = none. Listed skills appear in prompt, `capabilities_load`, slash commands |
| `agents[].tools` | `mode: manual` + exact `enabled` list. Exports: fully selected plugin/MCP under `plugins` / `mcp_servers`; partial as exact names under `tools.enabled` |
| `agents[].runtime` / `claude_code` | Builtin or harness name; Claude Code options. Also on `default_agent` |
| `agents[].orchestrator_spawnable` | `false` keeps a **newly created** agent out of Orchestrator allow-list. Ignored when patching; `delegation.spawnable_agents` in the same document wins |
| `delegation` | `spawnable_agents`, `spawnable_workspace_agents` (`Name@Workspace`), `workspace_auto_join`, `permission_defaults` (`spawn` / `spawn_workspace`: `ask` \| `deny` \| `always_allow`), `budget_max_*`, `local_text_enabled`, `ram_safety_preflight` |

**Not in the document** (app / interactive by design): working folders; some per-agent model UI overrides; OAuth / device pairing; macOS permission grants (Apple apps); folder pickers; destructive resets; payment; server runtime process; app appearance; voice; sandbox **VM resources**; privacy filtering; image targets.

Orchestrator can also create from an [agent template](https://docs.osaurus.ai/agent-templates) in chat: `template: "<name>"` + `overrides` (`name`, `description`, `system_prompt`, `model`). Vendor packs: `bundles.md`.

## Agent entry (shape)

```yaml
version: 1

agents:
  - name: Research Agent
    description: "One-line for Orchestrator routing"
    system_prompt: "…"
    model: null                 # inherit; or foundation / local id / provider/model
    temperature: 0.4
    capabilities:
      tools_enabled: true
      memory_enabled: true
      web_search_enabled: true
      knowledge_enabled: false
      image_enabled: false
      applescript_enabled: false
      browser_use_enabled: false
      computer_use_enabled: false
      relay_enabled: false
      apple_apps: [calendar, reminders]
    skills: []                  # omit | null | list | []
    tools:
      mode: manual              # Auto in UI = omit manual list; Manual = exact enabled
      enabled: [get_current_time]
    mcp_servers:
      enabled: [GitHub]
      # disabled: […]
    plugins:
      enabled: [osaurus.fetch]
    sandbox:
      enabled: true
      network_enabled: true
      allowed_domains: [api.example.com]
      max_commands_per_turn: null
      background_process_enabled: false
      plugin_create: true
    subagents:
      enabled: true
      agents: [Other Agent]
    orchestrator_spawnable: true
    runtime: builtin            # or harness_runtimes name / "Claude Code"
    claude_code:
      model: sonnet             # sonnet | opus | haiku
      mode: agent               # agent | text_only
      allow_writes: true
      allow_shell: false
      allow_osaurus_tools: true
```

UI **Auto** tool mode starts small and loads on demand (`capabilities_discover` /
`capabilities_load`). **Manual** sends every enabled tool each turn (larger
prompts; skills unused in Manual). Prefer Auto unless you need a fixed list.

## Memory (document + file)

Declarative `memory:` section covers high-level toggles (e.g. `enabled`,
`budget_tokens`). Fine settings also live in **Settings → Memory** or
`~/.osaurus/config/memory.json`:

| Setting | Default | Notes |
|---------|---------|-------|
| `enabled` | `true` | Master |
| `embeddingBackend` | `mlx` | `mlx` / `none` |
| `embeddingModel` | `nomic-embed-text-v1.5` | |
| `extractionMode` | `sessionEnd` | `sessionEnd` / `manual` |
| `relevanceGateMode` | `heuristic` | `off` / `heuristic` / `llm` |
| `memoryBudgetTokens` | `800` | 100–4000 |
| `summaryDebounceSeconds` | `60` | 10–3600 |
| `consolidationIntervalHours` | `24` | 1–168 |
| `salienceFloor` | `0.2` | 0–1 |
| `episodeRetentionDays` | `365` | 0 = forever |

Docs: https://docs.osaurus.ai/memory

## Harness runtimes

See **`harness-runtimes.md`**. Short form:

```yaml
harness_runtimes:
  - name: Spotlight
    kind: pi_rpc                # claude_code | pi_rpc; fixed after add
    executable: ~/.local/bin/spotlight
    arguments: ["--mode", "rpc", "--session-id", "{chat_id}"]
    environment: { PI_LOG_LEVEL: info }   # plain values only; never secrets
```

Runtimes apply before agents in one document. This is **not** Anytype type
`runtime` (platform catalog).

## MCP / providers / channels (secrets)

```yaml
mcp_servers:
  - name: Acme Tickets
    transport: http             # http | stdio
    url: https://mcp.acme.example/mcp
    auth: bearer                # none | bearer | oauth
    token_ref: env:ACME_TOKEN   # or keychain:SERVICE/ACCOUNT
    # secret_header_refs: { X-API-Key: env:ACME_KEY }
  - name: GitHub
    transport: stdio
    command: npx
    args: ["-y", "@modelcontextprotocol/server-github@1.2.3"]
    secret_env_refs:
      GITHUB_PERSONAL_ACCESS_TOKEN: keychain:com.example/github-token
    execution_host: sandbox     # sandbox | host

providers:
  - name: Example
    # api_key_ref: env:EXAMPLE_API_KEY
    # or set_api_key: true

channels:
  - name: Telegram
    # bot_token_ref: keychain:…/bot-token
```

Exports never include secrets or whether a credential exists. References:

- `env:VARIABLE_NAME`
- `keychain:SERVICE/ACCOUNT`
- `set_api_key: true` (opens native credential sheet on apply)

## Delegation sketch

```yaml
delegation:
  local_text_enabled: true
  spawnable_agents: ["Research Agent"]
  spawnable_workspace_agents: []
  # workspace_auto_join: { "Some Workspace": false }
  permission_defaults:
    spawn: always_allow
    spawn_workspace: ask
  budget_max_tokens: 8192
  budget_max_turns: 24
  budget_max_seconds: 900
```

Per-agent delegation (chief → specialists) uses `agents[].subagents`:

```yaml
agents:
  - name: Sidonie
    subagents:
      enabled: true
      agents: [Philippe, Blanche, Bob]
```

## Org defaults sketch (this workspace)

Always include on agent apply (see `SKILL.md` / `anytype-apply.md`):

```yaml
agents:
  - name: Example
    runtime: builtin
    model: OsaurusAI/LFM3-1.7B-JANG_6M   # from harness_profile translation
    capabilities:
      tools_enabled: true
      memory_enabled: true
      search_memory_enabled: true
      web_search_enabled: false
      db_enabled: true
      self_scheduling_enabled: true
      browser_use_enabled: true
      render_chart_enabled: true
    sandbox:
      enabled: true
      network_enabled: true
      plugin_create: true
```

## Schedules and watchers

Listed under `schedules` / `watchers`; match by name; create or patch on apply.
On disk: `~/.osaurus/schedules/{uuid}.json`, `~/.osaurus/watchers/{uuid}.json`.
Prefer exporting first and editing known fields; prune only with `--prune` and
user confirmation. Product docs: https://docs.osaurus.ai/schedules ·
https://docs.osaurus.ai/watchers

When applying from Anytype Agenda, emit cron schedules like:

```yaml
schedules:
  - name: mardi-proposition-semaine – Philippe
    agent: Philippe
    frequency: cron
    frequency_value: "59 8 * * 2"
    enabled: true
    instructions: |
      …self-contained task…
```

## Sandbox resources (not declarative config)

VM resources are **Settings → Sandbox** or `~/.osaurus/config/sandbox.json`
(macOS 26+ Linux VM; macOS 15 Seatbelt has no VM resources):

```json
{ "autoStart": true, "cpus": 2, "memoryGB": 2, "network": "outbound" }
```

`network`: `outbound` | `proxy` | `none`. Agent-level sandbox switches still go
in `agents[].sandbox` in the document.

## Server settings outside the document

Local inference concurrency, model memory eviction, CORS allowed origins,
require local access key, context window cap, compaction model, storage
encryption, themes, voice: use Settings UI (or the few keys bundles may set:
`require_local_access_key`, `allowed_origins`). See Configuration docs
“Local inference” / “Server flags”.
