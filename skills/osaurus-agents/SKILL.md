---
name: osaurus-agents
description: >
  Define and manage Osaurus agents via the osaurus CLI (declarative config
  plan/apply) or Osaurus Bundles (import install/update/remove). Create agents,
  skills, MCP servers, harness runtimes, and settings the same way hermes-profiles
  does for Hermes. Use when the user mentions Osaurus agents, osaurus config,
  osaurus import, osaurus-bundle, or Anytype Runtime kind osaurus. Use when the
  user runs /osaurus-agents.
version: 1.3.0
license: MIT
metadata:
  category: agents
  domain: osaurus
---

# Osaurus agents

Osaurus is a local macOS LLM server and agent host. Agents live in the running
app (and under `~/.osaurus/`), not as one folder per profile like Hermes.
Define agents with a **declarative YAML/JSON config** (`osaurus config
plan|apply`) or an **Osaurus Bundle** (`osaurus import …`). Prefer the CLI over
hand-editing app state.

Anytype catalog: type **`runtime`** with `runtime_kind: osaurus`. Agents link
Agent.`runtime` to that catalog object. Editing Anytype does not push into
Osaurus; apply only when the user asks (or after an accepted suggestion).

## Resolve CLI

```bash
cli="$(command -v osaurus || true)"
[ -x "$cli" ] || cli="/Applications/Osaurus.app/Contents/Helpers/osaurus"
[ -x "$cli" ] || cli="/Applications/Osaurus.app/Contents/MacOS/osaurus"
"$cli" version
"$cli" status
"$cli" doctor --json
```

Homebrew cask owns the PATH link. For a DMG install, use the Helpers path above
or install the CLI from **Settings → Server → Overview → Command Line Tool**.

Access key (when **Require Access Key for Local Admin Routes** is on):

```bash
export OSAURUS_API_KEY=osk-v1.…
# or pass --access-key on config / import / mcp
```

Must be a live `osk-v1.…` local-admin key (Settings → Server). Keychain
`com.osaurus.account` master/recovery material is **not** this key. Session-only;
never commit. See `troubleshooting.md`.

## References (load when needed)

| File | When |
|------|------|
| `references/cli-map.md` | Full CLI: serve/supervise/launchd, models, config, import, tools, mcp, coord, env, paths |
| `references/config-document.md` | Declarative YAML/JSON: all sections, agent shape, memory, MCP/providers, delegation, schedules/watchers, sandbox outside document |
| `references/bundles.md` | `osaurus-bundle.json`, agents/skills/MCP/harness/secrets, import CLI, installer + security checklists |
| `references/harness-runtimes.md` | Claude Code / Pi runtimes (`agents[].runtime`); not Anytype Runtime type |
| `references/tools-and-plugins.md` | Native plugins, Auto/Manual tools, remote MCP, ABI, `osaurus tools` / `mcp` / `.mcpb` |
| `references/anytype-apply.md` | Anytype Agent + Runtime(osaurus) → config document or bundle |
| `references/recipes.md` | Create / update / export / supervise / plugin / Anytype flows |
| `references/troubleshooting.md` | CLI missing, queued imports, secrets, access key, tools, runtime confusion |

Docs: https://docs.osaurus.ai/cli · https://docs.osaurus.ai/configuration · https://docs.osaurus.ai/bundles · https://docs.osaurus.ai/harness-runtimes · https://docs.osaurus.ai/tools

## Mental model

| Term | Meaning |
|------|---------|
| Osaurus agent | Named agent in the app (system prompt, model, capabilities, skills, tools) |
| Config document | Desired-state YAML/JSON; merge-by-default; `plan` then `apply` |
| Bundle | Folder with `osaurus-bundle.json` + agents/skills/mcp/runtimes; `osaurus import` |
| Harness runtime | Osaurus-internal: run chats on Claude Code / Pi (`agents[].runtime`). **Not** the Anytype `runtime` type |
| Anytype Runtime | Catalog where the org agent runs: `grok-bot` \| `hermes` \| `osaurus` \| `noodle` |
| Orchestrator | Default Osaurus agent; can spawn listed subagents |
| Secrets | Never in documents; use `env:VAR` or `keychain:SERVICE/ACCOUNT` |

Do not confuse **Anytype `runtime`** (platform: hermes/osaurus/…) with **Osaurus
`agents[].runtime`** (builtin / Claude Code / Pi).

## Discover first

```bash
"$cli" status
"$cli" config export -o /tmp/osaurus-export.yaml
"$cli" import list --json
"$cli" tools list
"$cli" list   # local models
```

Read the export before creating or patching agents. Do not dump secrets into chat.

## Define agents (config file)

Preferred path for one-off or repo-tracked desired state (mirrors Hermes
`config set` discipline: plan before apply).

```bash
"$cli" config schema                    # annotated YAML reference
"$cli" config export -o osaurus-config.yaml
# edit agents / delegation / memory / …
"$cli" config plan osaurus-config.yaml
"$cli" config apply osaurus-config.yaml
# high-risk (browser/computer use, new MCP, prune, runtime moves):
"$cli" config apply osaurus-config.yaml --prune --yes
```

Minimal agent document:

```yaml
version: 1

agents:
  - name: Research Agent
    description: "Web research with cited sources"
    system_prompt: "Research thoroughly and cite sources."
    model: null   # inherit Orchestrator
    temperature: 0.4
    capabilities:
      tools_enabled: true
      web_search_enabled: true
    skills: []    # allow-list; null = all installed; omit = leave unchanged
    orchestrator_spawnable: true

delegation:
  spawnable_agents: ["Research Agent"]
  permission_defaults:
    spawn: always_allow
```

Semantics: missing keys stay untouched; entities match by **name**
(case-insensitive); validation is all-or-nothing; `--prune` deletes unlisted
entries only in sections the document declares. Exit codes: `0` converged, `1`
failed/cancelled, `3` applied but interactive step remains (credential sheet).

Full field map: `references/config-document.md`.

## Define agents (bundle)

Preferred path for shipping a set of agents + skills + MCP + harness runtimes
(vendor/IT installer pattern).

```bash
"$cli" import validate --from ./my-bundle --json
"$cli" import install  --from ./my-bundle --yes --json
"$cli" import update   --from ./my-bundle --yes --json
"$cli" import list     --json
"$cli" import remove   --bundle com.example.my-bundle --json
```

Bundle root needs `osaurus-bundle.json` plus relative `agents/*.json`,
`skills/<slug>/SKILL.md`, optional MCP / harness_runtimes / settings. Secrets
are Keychain refs only (`keychain:SERVICE/ACCOUNT` with
`-T /Applications/Osaurus.app`). High-risk items need `--yes`. Import never
launches the app; if Osaurus is stopped, changes queue until next open.

Full layout: `references/bundles.md`.

## Identity and tools

| Concern | Config / CLI |
|---------|----------------|
| System prompt | `agents[].system_prompt` (or bundle agent JSON) |
| Model | `agents[].model` (`null` inherits; `foundation`; local id; `provider/model`) |
| Skills allow-list | `agents[].skills` |
| Tools | `agents[].tools` (`mode: manual` + `enabled`) / plugins / mcp_servers |
| Capabilities | `browser_use_enabled`, `computer_use_enabled`, `apple_apps`, … |
| Delegation | `delegation.spawnable_agents` + budgets / permissions |
| External program | `harness_runtimes` + `agents[].runtime` / `claude_code` |
| Memory | top-level `memory:` or Settings → Memory |
| Plugins | `osaurus tools install\|list\|upgrade` (outside config document) |
| Models download | `osaurus pull <hf-id>` then `osaurus list` |

## Anytype → Osaurus

1. Confirm Agent.`runtime` → Runtime with `runtime_kind: osaurus` (and usually
   `slug: osaurus`).
2. Read Agent.`system_prompt`, `short_description`, `harness_profile` (model),
   Subagents/chief reports, Team standing, Groups, Agenda schedules, catalog
   links as intent only.
3. Build a config fragment with **org defaults** (capabilities, sandbox,
   `runtime`+`model` from harness profile), chief `subagents`, and `schedules:`
   for live Agenda items (`anytype-apply.md`). Match agents by short **name**.
4. `config plan` or `import validate`, then apply/install only when the user asks
   (`--yes` when browser/channel high-risk).
5. Report gaps: voice (Settings UI), empty Group chat ids, Signal if unsupported,
   Cua Spaces ≠ Computer Use, model id missing on host, skills allow-lists.

Do not auto-apply from draft/proposed suggestions. Hermes-shaped fields
(`hermes_profile`, Cua pair, langfuse, Chrome `real_profile_pin`) do not map 1:1;
translate deliberately.

## Org defaults (always on apply)

When creating or updating any Osaurus agent (config fragment or Anytype apply),
always set these unless the user overrides for that agent:

```yaml
runtime: builtin          # Osaurus host; use a harness_runtimes name only if Anytype says so
model: <from harness_profile>   # required — never leave unset/foundation by accident
capabilities:
  tools_enabled: true
  memory_enabled: true
  search_memory_enabled: true   # memory recall
  web_search_enabled: false     # prefer browser_use over web_search
  db_enabled: true
  self_scheduling_enabled: true
  browser_use_enabled: true     # high-risk; apply needs --yes when newly granting
  render_chart_enabled: true
sandbox:                        # autonomous execution
  enabled: true
  network_enabled: true
  plugin_create: true
```

**Model source:** Agent.`harness_profile` → `model_default` + `model_provider`
(+ linked `model_harness`). Translate into an Osaurus model id that exists on
this host (`osaurus list` / export `models:`). Example: Foyer / Local parent
`lfm3` via `ollama-launch` → `OsaurusAI/LFM3-1.7B-JANG_6M` when that local model
is installed. Do not invent cloud fallbacks the profile forbids.

**Chief / subchief delegation:** If the agent is a Team/Subteam chief (or has
direct reports / Subagents in Anytype), set `subagents.enabled: true` and
`subagents.agents: [<specialist names…>]`, and keep those names on
`delegation.spawnable_agents`. Specialists without reports stay
`subagents.enabled: false`.

**Schedules:** If Agent.`agenda_page` (or search by `owner_agent`) has live
`schedule` objects, create matching `schedules:` entries (`name`, `agent`,
`frequency`/`frequency_value` from `schedule_expr` or kind, `instructions` from
intent/body Prompt, `enabled` from lifecycle/paused). Osaurus has no timezone
field; note Europe/Paris (etc.) in instructions and assume host local clock.
Skip draft/paused unless the user asks to enable them.

Details: `anytype-apply.md`, `recipes.md`, `config-document.md`.

## Safety

1. Confirm before `--prune`, `--yes` high-risk grants, `import remove`, or
   turning off the local access key.
2. Never put raw API keys in YAML/JSON/bundles; use `env:` / `keychain:`.
3. Prefer exact `tools.enabled` lists over whole MCP servers when possible.
4. Runtime programs (Claude Code / Pi) run as the user; keep shell allow off
   unless needed.
5. Editing Anytype ≠ updating live Osaurus agents.

## Common recipes (summary)

- **New specialist:** draft agent YAML → `config plan` → `apply` → optional
  `delegation.spawnable_agents` (`recipes.md`)
- **Ship a pack:** scaffold bundle → Keychain secrets → `import validate` →
  `import install --yes`
- **Export backup:** `config export -o …` (secrets stripped)
- **Keepalive serve:** `serve --supervise` (+ LaunchAgent); see `cli-map.md`
- **Plugin:** `tools search` → `install` → scope agent tools (`tools-and-plugins.md`)
- **Harness runtime:** Claude Code / Pi via `harness-runtimes.md` + `--yes`
- **Anytype apply:** `anytype-apply.md` after accepted suggestion or explicit ask
- **Doctor:** `osaurus doctor --json` when serve/import fails

## Workflow checklist

1. Resolve `osaurus` binary + `status` / `doctor`
2. `config export` or `import list` (discover current state)
3. Choose config document vs bundle
4. `plan` / `validate`, then `apply` / `install` with `--yes` only when needed
5. Verify in app (Agents list) or re-export
6. On failure, `troubleshooting.md`
