# Anytype → Osaurus apply

Anytype is org truth. Osaurus apply is deliberate (accepted suggestion or
explicit user ask), same gate as hermes-profiles.

## Preconditions

1. Agent.`runtime` links a **Runtime** object with `runtime_kind: osaurus`
   (catalog slug usually `osaurus`).
2. Canonical system text lives on Agent.`system_prompt` → Prompt.
3. Resolve CLI (`cli-map.md`) and confirm `osaurus status` / `doctor`.

## Choose path

| Situation | Path |
|-----------|------|
| One or few agents, repo-tracked desired state | Config document → `config plan` → `apply` |
| Pack of agents + skills + MCP for install/update | Bundle → `import validate` → `install`/`update` |
| Only inspect | `config export` |

## Field map (Anytype → Osaurus)

| Anytype | Osaurus |
|---------|---------|
| Agent name / display | `agents[].name` (match key; case-insensitive) |
| `short_description` | `agents[].description` |
| Prompt body (`system_prompt`) | `agents[].system_prompt` |
| `harness_profile` models | Approximate `agents[].model` / providers (translate deliberately; Hermes provider ids ≠ Osaurus) |
| Subagents (`task_key`, intent) | Peer agents + `delegation.spawnable_agents` / agent `subagents.agents` by name |
| `browser` / `computer` intent | `capabilities.browser_use_enabled` / `computer_use_enabled` (high-risk; needs `--yes`) |
| Skills Query / skill keys | `agents[].skills` allow-list + bundle `skills/` |
| Tool profile | `agents[].tools` manual list / plugins / mcp_servers |
| Working directory | App working folder or bundle `working_folder` (may `needs_user_action`) |

Do **not** auto-map Hermes-only keys (`hermes_profile`, langfuse env, Cua
`settings.space`, Chrome `real_profile_pin`) into Osaurus without an explicit
translation the user approved.

## Ordered apply (config)

1. `osaurus config export -o /tmp/osaurus-before.yaml`
2. Write a **fragment** document with only the sections you intend to change
   (merge-by-default).
3. `osaurus config plan /tmp/osaurus-desired.yaml`
4. Confirm high-risk lines with the user; then
   `osaurus config apply …` (+ `--yes` when required).
5. Re-export or open Agents in the app; report exit code `3` gaps.
6. Optionally note apply time on Agent.`notes` / a Log (no secret values).

## Ordered apply (bundle)

1. Scaffold bundle from `bundles.md` (stable `id`, bumped `version`).
2. Store Keychain secrets with `-T /Applications/Osaurus.app`.
3. `osaurus import validate --from <dir> --json`
4. `osaurus import install --from <dir> --yes --json` (or `update`)
5. Open Osaurus if queued; finish Set Up Now for secrets/folders/models.
6. `osaurus import list --json` for receipts.

## Safety

- Never paste API keys into Anytype or into the config/bundle files.
- Prefer exact tool names over enabling whole MCP servers.
- Leave `orchestrator_spawnable: false` unless the Orchestrator should spawn it.
- Mark related Anytype `suggestion` as `done` after a successful apply when tracking one.
