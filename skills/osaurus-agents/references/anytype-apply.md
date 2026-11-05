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
| `harness_profile` models | Approximate `agents[].model` / providers (translate deliberately; Hermes provider ids ≠ Osaurus) |
| Subagents / reports_to / chief | Peer agents + chief `subagents.enabled` + `subagents.agents` by name; also `delegation.spawnable_agents` for Orchestrator |
| Team.`standing_instructions` | No Team object in Osaurus. Append a compact standing block to the **chief** agent prompt (or keep the Shared Rules pointer and rely on Anytype at runtime) |
| Group (messaging) | `channels.<telegram\|whatsapp\|…>` allowlists + optional `inbound_agent`. Needs real platform chat ids / bot tokens. Empty `platform_chat_id` → `needs_user_action`, do not invent destinations |
| `browser` link | `capabilities.browser_use_enabled: true` (high-risk; `--yes`) |
| `computer` / `computer_surface: cua-spaces` | **Do not** auto-enable `computer_use_enabled`. Cua Spaces ≠ Osaurus Computer Use. Leave false unless the user wants native Osaurus Computer Use |
| `voice_enabled` / TTS / STT | **Not** in the declarative config document (Settings → Voice). Report as `needs_user_action` |
| Skills Query / skill keys | `agents[].skills` allow-list + bundle `skills/` (omit = leave unchanged) |
| Tool profile | `agents[].tools` manual list / plugins / mcp_servers |
| Working directory | App working folder or bundle `working_folder` (may `needs_user_action`) |
| `hermes_profile`, langfuse, Chrome `real_profile_pin` | Hermes-only; do not map without an explicit approved translation |

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
