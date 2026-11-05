# Declarative config document

Docs: https://docs.osaurus.ai/configuration#declarative-configuration

Manage desired state with YAML or JSON (≤ 512 KiB). Same engine as Orchestrator
`osaurus_config`, CLI `osaurus config *`, and loopback `/admin/config/*`.

## Workflow

```bash
osaurus config export -o osaurus-config.yaml
osaurus config schema
osaurus config plan osaurus-config.yaml
osaurus config apply osaurus-config.yaml
# destructive / high-risk:
osaurus config plan osaurus-config.yaml --prune
osaurus config apply osaurus-config.yaml --prune --yes
```

Exit codes (`apply`): `0` converged, `1` failed/cancelled, `3` applied but
interactive step remains (e.g. credential sheet).

## Semantics

- **Merge by default.** Absent keys untouched; explicit `null` clears an optional override.
- **Match by name** (case-insensitive) for agents, providers, MCP, schedules, watchers, runtimes.
- **Plan is read-only.** Only `apply` mutates.
- **`--prune`** deletes unlisted entries only in sections the document declares (destructive).
- **Validation is all-or-nothing.**
- **High-risk** lines need `--yes`: prune deletions, browser/computer use grants, relay/channel exposure, new MCP endpoints, runtime command/env, moving an agent onto a runtime, Claude Code shell / config-write, automatic tool policies, looser delegation permissions.

## Sections (common)

| Key | Covers |
|-----|--------|
| `version` | Document version (`1`) |
| `memory` | Memory toggles / budget |
| `default_agent` | Orchestrator defaults (`name`, `model`, `system_prompt`, `runtime`, `claude_code`) |
| `new_chat_agent` | `default` or custom agent name (`active_agent` still accepted) |
| `agents` | Custom agents list |
| `delegation` | Spawnable agents, budgets, permission defaults, local-model memory |
| `harness_runtimes` | External Claude Code / Pi programs |
| `tools` / plugins / `mcp_servers` | Tool surface |
| `commands` | Slash commands |
| `knowledge_collections` | Knowledge |
| `channels` | Messaging channels |
| `models` / `providers` / `search_providers` | Local + cloud |
| `schedules` / `watchers` | Jobs |

## Agent entry (shape)

```yaml
agents:
  - name: Research Agent
    description: "One-line for Orchestrator routing"
    system_prompt: "…"
    model: null                 # inherit Orchestrator; or foundation / local id / provider/model
    temperature: 0.4
    capabilities:
      tools_enabled: true
      web_search_enabled: true
      image_enabled: false
      applescript_enabled: false
      browser_use_enabled: false
      computer_use_enabled: false
      apple_apps: [calendar, reminders]   # replaces set when listed
    skills: []                  # omit = unchanged; null = all; [] = none
    tools:
      mode: manual
      enabled: [get_current_time]
    mcp_servers:
      enabled: [GitHub]
    plugins:
      enabled: [osaurus.fetch]
    sandbox:
      enabled: true
      network_enabled: true
      allowed_domains: [api.example.com]
    subagents:
      enabled: true
      agents: [Other Agent]
    orchestrator_spawnable: true
    runtime: builtin            # or a harness_runtimes name / "Claude Code"
    claude_code:
      model: sonnet
      mode: agent               # agent | text_only
      allow_writes: true
      allow_shell: false
      allow_osaurus_tools: true
```

Working folders and some per-agent model UI overrides stay in the app.

## Harness runtimes (inside Osaurus)

```yaml
harness_runtimes:
  - name: Spotlight
    kind: pi_rpc                # claude_code | pi_rpc; fixed after add
    executable: ~/.local/bin/spotlight
    arguments: ["--mode", "rpc", "--session-id", "{chat_id}"]
    environment: { PI_LOG_LEVEL: info }   # plain values only
```

Placeholders: `{chat_id}`, `{agent_id}`, `{cwd}`, `{system_prompt_file}`.
Docs: https://docs.osaurus.ai/harness-runtimes

This is **not** Anytype type `runtime` (platform catalog).

## Secrets

Exports never include secrets. Documents accept:

- `env:VARIABLE_NAME`
- `keychain:SERVICE/ACCOUNT`
- `set_api_key: true` (opens native credential sheet on apply)

Use on provider `api_key_ref`, MCP `token_ref` / `secret_header_refs` /
`secret_env_refs`, channel `bot_token_ref`.

## Delegation sketch

```yaml
delegation:
  local_text_enabled: true
  spawnable_agents: ["Research Agent"]
  spawnable_workspace_agents: []
  permission_defaults:
    spawn: always_allow          # ask | deny | always_allow
    spawn_workspace: ask
  budget_max_tokens: 8192
  budget_max_turns: 24
  budget_max_seconds: 900
```
