# Recipes

## New Osaurus agent (config)

1. Export current state: `osaurus config export -o /tmp/osaurus-before.yaml`
2. Write a fragment with the new `agents:` entry including **org defaults**
   (capabilities, sandbox, `runtime`+`model`), optional chief `subagents`, and
   any `schedules:` (+ `delegation.spawnable_agents`)
3. `osaurus config plan` → review → `osaurus config apply` (`--yes` if browser newly granted)
4. Verify in app Agents list or re-export

Org defaults + field map: `SKILL.md` (Org defaults), `anytype-apply.md`, `config-document.md`.

## Twin / update an agent

Entities match by **name**. Edit the same `name` in a document and `apply`
(merge). To rename, create the new name then remove the old (prune or app UI);
confirm with the user first.

## Ship a starter pack (bundle)

1. Copy upstream example or scaffold `osaurus-bundle.json` + `agents/` + `skills/`
2. Bump `version`; keep stable `id`
3. Store Keychain secrets with `-T /Applications/Osaurus.app`
4. `import validate` → `import install --yes`
5. Open Osaurus; finish any Set Up Now steps

Layout and security: `bundles.md`.

## Export for backup / review

```bash
osaurus config export -o ~/Desktop/osaurus-config.yaml
```

Secrets are stripped. Treat the file as still sensitive (URLs, agent prompts).

## Wire Claude Code or Pi as agent runtime

```yaml
harness_runtimes:
  - name: Claude Code
    kind: claude_code
    executable: claude
agents:
  - name: Coding Buddy
    runtime: Claude Code
    claude_code:
      model: sonnet
      mode: agent
      allow_writes: true
      allow_shell: false
```

`apply` with `--yes` (runtime / shell flags are high-risk). Agent must be signed
in via Claude Code separately. Full options: `harness-runtimes.md`.

## Anytype agent on Osaurus

1. Set Agent.`runtime` → Runtime **Osaurus**
2. Follow `anytype-apply.md`
3. Prefer config fragment for a single specialist; bundle when shipping skills too

## Anytype HQ team (chief + specialists + groups)

Example pattern (Foyer-style): Sidonie chief, Philippe / Blanche / Bob specialists.

1. Confirm each Agent.`runtime` → Runtime(`osaurus`); export Osaurus config (with
   `OSAURUS_API_KEY` if required).
2. Fetch Prompt bodies + `harness_profile` + Team.`standing_instructions` +
   Group platform/chat ids + Agenda schedules (`owner_agent`).
3. Fragment document:
   - `agents[]` matched by short **name** (merge stubs’ generic prompts)
   - **always** org capability defaults + `sandbox.enabled`
   - **always** `runtime: builtin` + `model` translated from `harness_profile`
   - chief: `subagents.enabled: true`, `subagents.agents: [specialists…]`
   - `delegation.spawnable_agents` lists the whole HQ set
   - append standing instructions to the chief prompt
   - `schedules:` for each live Agenda item (cron from `schedule_expr`)
   - leave `computer_use_enabled: false` when Anytype computer is Cua Spaces
4. `config plan` → `apply --yes` if browser/channel high-risk lines appear.
5. **Two-pass:** if chiefs applied before specialists existed, re-apply chief
   `subagents` + `delegation.spawnable_agents` only.
6. Seed `ai.osaurus.agent-secrets` (`{UUID}.ANYTYPE_API_KEY` / `_HOST`) and
   custom avatars under `~/.osaurus/agents/avatars/` (`anytype-apply.md`).
7. Report gaps: empty Group chat ids, Signal (if unsupported), voice Settings,
   missing local model id, skills allow-lists, channel `inbound_agent` mapping,
   agents still on monogram (no portrait source).

Full Team/Group / Workspaces / schedule / model / avatar rules: `anytype-apply.md`.

## Serve + supervise (keep-alive)

```bash
osaurus serve --supervise --interval 15
# optional LaunchAgent: see cli-map.md (ai.osaurus.serve)
```

Plain `serve` starts and exits. Use `--supervise` (and launchd) for quit/crash/reboot resilience.

## Serve + MCP for clients

```bash
osaurus serve
osaurus mcp --tools "osaurus_status,osaurus_list,osaurus_*"
```

Client config: `"command": "osaurus", "args": ["mcp"]`. Tighten `--tools` so clients do not ingest 170+ schemas. Details: `tools-and-plugins.md`.

## Install a registry plugin and scope an agent

```bash
osaurus tools search xlsx
osaurus tools install osaurus.xlsx
```

Then either enable in UI (**Abilities → Tools**) or in a config document:

```yaml
agents:
  - name: Spreadsheet Agent
    plugins:
      enabled: [osaurus.xlsx]
    tools:
      mode: manual
      enabled: []   # or exact tool names from export
```

`config plan` → `apply`. Prefer Auto mode (omit `tools.mode: manual`) unless you need a fixed list.

## Pull a local model then chat

```bash
osaurus pull mlx-community/Llama-3.2-1B-4bit
osaurus list
osaurus show <id>
osaurus run <id>
```

## Doctor when something is broken

```bash
osaurus doctor --json
osaurus doctor --redact          # shareable bug report
osaurus doctor --verify-signatures
```
