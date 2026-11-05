# Anytype → Osaurus apply

Anytype is org truth. Osaurus apply is deliberate (accepted suggestion or
explicit user ask), same gate as hermes-profiles.

## Preconditions

1. Agent.`runtime` links a **Runtime** object with `runtime_kind: osaurus`
   (catalog slug usually `osaurus`).
2. Canonical system text lives on Agent.`system_prompt` → Prompt.
3. Resolve CLI (`cli-map.md`) and confirm `osaurus status` / `doctor`.
4. When **Require Access Key for Local Admin Routes** is on, set
   `OSAURUS_API_KEY` (or `--access-key`) to a live `osk-v1.…` key before
   `config export|plan|apply`. See troubleshooting for Keychain pitfalls.

## Choose path

| Situation | Path |
|-----------|------|
| One or few agents, repo-tracked desired state | Config document → `config plan` → `apply` |
| Pack of agents + skills + MCP for install/update | Bundle → `import validate` → `install`/`update` |
| Only inspect | `config export` |

## Field map (Anytype → Osaurus)

| Anytype | Osaurus |
|---------|---------|
| Agent name / display | `agents[].name` (match key; case-insensitive). Short name (`Sidonie`) matches stubs even when Anytype title is `Sidonie – Chief of Foyer`. |
| `short_description` | `agents[].description` |
| Prompt body (`system_prompt`) | `agents[].system_prompt` (strip Anytype `{Name} – System prompt` / Prompt / Notes stubs; rewrite Hermes→Osaurus runtime lines) |
| `harness_profile` (`model_default`, `model_provider`, `model_harness`) | **Always** set `agents[].runtime` + `agents[].model`. Default runtime `builtin`. Translate `model_default` to an installed Osaurus model id (see model map below). Never leave `foundation` / unset when a profile exists |
| Agent.`runtime` → Runtime(`osaurus`) | Confirms platform; does **not** replace `agents[].runtime` (builtin vs Claude Code / Pi harness) |
| Subagents / reports_to / Team.`chief` | If chief or subchief: `subagents.enabled: true` + `subagents.agents` by short name; add them to `delegation.spawnable_agents` |
| Team.`standing_instructions` | No Team object in Osaurus. Append a compact standing block to the **chief** agent prompt (or keep the Shared Rules pointer and rely on Anytype at runtime) |
| Agenda / `schedule` (live) | **Always** create `schedules:` entries for live Agenda items owned by the agent (see schedule map) |
| Group (messaging) | `channels.<telegram\|whatsapp\|…>` allowlists + optional `inbound_agent`. Needs real platform chat ids / bot tokens. Empty `platform_chat_id` → `needs_user_action`, do not invent destinations |
| `browser` / org defaults | Apply **org capability defaults** (below). Browser Use is high-risk (`--yes`) when newly granting |
| `computer` / `computer_surface: cua-spaces` | **Do not** auto-enable `computer_use_enabled`. Cua Spaces ≠ Osaurus Computer Use. Leave false unless the user wants native Osaurus Computer Use |
| `voice_enabled` / TTS / STT | **Not** in the declarative config document (Settings → Voice). Report as `needs_user_action` |
| Skills Query / skill keys | `agents[].skills` allow-list + bundle `skills/` (omit = leave unchanged) |
| Tool profile | `agents[].tools` manual list / plugins / mcp_servers |
| Working directory | App working folder or bundle `working_folder` (may `needs_user_action`) |
| `hermes_profile`, langfuse, Chrome `real_profile_pin` | Hermes-only; do not map without an explicit approved translation |

## Org capability defaults (always)

Apply on every agent create/update unless the user overrides that agent:

| Capability | Config key | Value |
|------------|------------|-------|
| Tools | `capabilities.tools_enabled` | `true` |
| Memory | `capabilities.memory_enabled` | `true` |
| Memory recall | `capabilities.search_memory_enabled` | `true` |
| Web search | `capabilities.web_search_enabled` | **`false`** |
| Database | `capabilities.db_enabled` | `true` |
| Self scheduling | `capabilities.self_scheduling_enabled` | `true` |
| Browser use | `capabilities.browser_use_enabled` | `true` |
| Charts | `capabilities.render_chart_enabled` | `true` |
| Sandbox use (autonomous exec) | `sandbox.enabled` (+ `network_enabled` / `plugin_create`) | **`true` always.** Each agent already has its own sandbox env; never create sandboxes, only enable use. Docs: https://docs.osaurus.ai/sandbox |
| Tool approvals | Global `tools.policies.<tool>: auto` for every tool in export | **Always.** High-risk (`--yes`). Some send/delete tools still hard-ask |
| Delegation / CU / browser gates | `delegation.permission_defaults.*: always_allow` | **Always** for spawn, spawn_workspace, browser_use, computer_use, applescript, image, video |

## Model map (harness_profile → Osaurus)

Resolve Agent.`harness_profile` first. Hermes provider strings are **not** Osaurus ids.

| Profile intent (examples) | Anytype hints | Osaurus `model` (when installed) |
|---------------------------|---------------|----------------------------------|
| Foyer / Local parent chat | `model_default: lfm3`, `model_provider: ollama-launch` | `OsaurusAI/LFM3-1.7B-JANG_6M` |
| Local VL | lfm3-vl style | `OsaurusAI/LFM3-VL-2B-JANG_6M` if present |
| CLASQUIN / Claude subscription | anthropic Sonnet… | Map only with user approval to a connected Osaurus provider/model id |
| Other cloud specialists | xai / openrouter / … | Translate via `osaurus config export` `providers` + live model list |

If the translated id is missing on the host, **stop and report** (`needs_user_action`: pull/install model) instead of silently using `foundation` or Orchestrator.

`runtime`: `builtin` for Osaurus-native agents. Set `agents[].runtime` to a `harness_runtimes` name only when the apply explicitly uses Claude Code / Pi.

## Schedule map (Anytype → Osaurus)

| Anytype | Osaurus `schedules[]` |
|---------|----------------------|
| `name` / `schedule_key` | `name` (stable; include agent short name if helpful) |
| `owner_agent` → agent short name | `agent` |
| `schedule_kind: recurring` + `schedule_expr` cron | `frequency: cron`, `frequency_value: <expr>` |
| oneshot / event | `frequency: once` + ISO time when known; else report gap |
| body Prompt / `intent` | `instructions` (self-contained; include delivery + timezone note) |
| `lifecycle: live`, not paused | `enabled: true` |
| draft / paused | skip unless user asks to enable |

Osaurus schedule schema has **no timezone** field. Put timezone intent in `instructions` and rely on host local clock. Prefer Agenda Query filtered by `owner_agent` (Calendar views can mix other owners).

## Team and Group are not 1:1

Anytype **Team** / **Group** do not become Osaurus entities of the same name.

| Anytype | Osaurus shape |
|---------|---------------|
| HQ Team + chief + members | Named agents; chief gets `subagents.agents: [specialists…]`; specialists stay spawnable via `delegation.spawnable_agents` |
| Standing instructions Prompt | Text folded into chief `system_prompt` (and/or left as an Anytype lookup the prompt already requires) |
| Messaging Group (Telegram/Signal/…) | Channel allowlists under `channels`. Signal may be absent from the export surface (Discord/Slack/Telegram/iMessage/WhatsApp). Keep Signal traffic on Hermes until a supported channel exists |
| Group without chat id | Document gap; skip channel writes |

## Stub merge-by-name

UI-created agents often ship with a generic “friendly everyday assistant”
`system_prompt` (~300 chars) and empty `description`. A fragment that lists the
same `name` **patches** those fields on `apply` (merge-by-default). Export first
so you see whether you are creating or updating. Do not `--prune` agents unless
the user asked to delete unlisted ones.

## Ordered apply (config)

1. `export OSAURUS_API_KEY=osk-v1.…` when local admin routes require it (session
   env or a `chmod 600` temp file; never commit the key).
2. `osaurus config export -o /tmp/osaurus-before.yaml`
3. Fetch Anytype Agent + Prompt (+ Team standing, Groups) via MCP.
4. Write a **fragment** with only `agents:` / `delegation:` (and `channels:` only
   when real chat ids and token refs exist).
5. `osaurus config plan /tmp/osaurus-desired.yaml`
6. Confirm high-risk lines (browser, channel writes, prune); then
   `osaurus config apply …` (+ `--yes` when required).
7. Re-export; verify prompt length / `subagents` / capabilities. Report exit
   code `3` gaps and channel/voice/skills leftovers.
8. Optionally note apply time on Agent.`notes` / a Log (no secret values).

## Ordered apply (bundle)

1. Scaffold bundle from `bundles.md` (stable `id`, bumped `version`).
2. Store Keychain secrets with `-T /Applications/Osaurus.app`.
3. `osaurus import validate --from <dir> --json`
4. `osaurus import install --from <dir> --yes --json` (or `update`)
5. Open Osaurus if queued; finish Set Up Now for secrets/folders/models.
6. `osaurus import list --json` for receipts.

## Safety

- Never paste API keys into Anytype, config/bundle files, skill docs, or git.
- Prefer exact tool names over enabling whole MCP servers.
- Leave `orchestrator_spawnable: false` unless the Orchestrator should spawn it.
- Mark related Anytype `suggestion` as `done` after a successful apply when tracking one.
- Browser Use grants need `--yes`. Computer Use is a separate grant; Cua ≠ Computer Use.
