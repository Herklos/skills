---
name: osaurus-agents
description: >
  Define and manage Osaurus agents via the osaurus CLI (declarative config
  plan/apply) or Osaurus Bundles (import install/update/remove). Create agents,
  skills, MCP servers, harness runtimes, and settings the same way hermes-profiles
  does for Hermes. Use when the user mentions Osaurus agents, osaurus config,
  osaurus import, osaurus-bundle, or Anytype Runtime kind osaurus. Use when the
  user runs /osaurus-agents.
version: 1.0.0
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
export OSAURUS_API_KEY=osk-v1-…
# or pass --access-key on config / import / mcp
```

## References (load when needed)

| File | When |
|------|------|
| `references/cli-map.md` | Serve/status/doctor, config, import, tools, env, paths |
| `references/config-document.md` | Declarative YAML/JSON shape: agents, delegation, memory, harness_runtimes, secrets |
| `references/bundles.md` | `osaurus-bundle.json`, agent JSON files, import validate/install/update/remove |
| `references/anytype-apply.md` | Anytype Agent + Runtime(osaurus) → config document or bundle |
| `references/recipes.md` | Common create / update / export flows |
| `references/troubleshooting.md` | CLI missing, queued imports, secrets, high-risk refuse |

Docs: https://docs.osaurus.ai/cli  
Config: https://docs.osaurus.ai/configuration  
Bundles: https://docs.osaurus.ai/bundles  
Harness runtimes (Claude Code / Pi inside Osaurus): https://docs.osaurus.ai/harness-runtimes

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
2. Read Agent.`system_prompt` Prompt, `short_description`, Subagents, catalog
   links as intent only.
3. Build either a config document fragment or a bundle agent JSON from those
   fields (`anytype-apply.md`).
4. `config plan` or `import validate`, then apply/install only when the user asks.
5. Report gaps (working folder picker, pending secrets, models not pulled).

Do not auto-apply from draft/proposed suggestions. Hermes-shaped fields
(`hermes_profile`, Cua pair, langfuse) do not map 1:1; translate deliberately.

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
- **Anytype apply:** `anytype-apply.md` after accepted suggestion or explicit ask
- **Doctor:** `osaurus doctor --json` when serve/import fails

## Workflow checklist

1. Resolve `osaurus` binary + `status` / `doctor`
2. `config export` or `import list` (discover current state)
3. Choose config document vs bundle
4. `plan` / `validate`, then `apply` / `install` with `--yes` only when needed
5. Verify in app (Agents list) or re-export
6. On failure, `troubleshooting.md`
