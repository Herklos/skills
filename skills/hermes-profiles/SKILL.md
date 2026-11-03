---
name: hermes-profiles
description: >
  Manage Hermes Agent profiles (each profile is a full agent home: config, SOUL,
  memory, skills, gateway). Create, clone, list, show, describe, rename, delete,
  export/import, install distributions, edit SOUL/config/model, and run per-profile
  gateways. Use when the user mentions Hermes profiles, hermes -p, Bot Mode roster,
  or profile lifecycle. Use when the user runs /hermes-profiles.
version: 1.8.1
license: MIT
metadata:
  category: agents
  domain: hermes-agent
---

# Hermes profiles

A **profile** is one Hermes agent's home directory. Named agents live under
`$HERMES_HOME/profiles/<slug>/` (default `$HERMES_HOME` is `~/.hermes`). The
default profile is `$HERMES_HOME` itself (id `default`).

Bot Mode bots are the same profiles with roster metadata in `profile.yaml`. Prefer
the `hermes` CLI over hand-editing for lifecycle and config.

## References (load when needed)

| File | When |
|------|------|
| `references/profile-map.md` | File layout, clone flags, CLI cheat sheet |
| `references/models-and-delegation.md` | Main, auxiliary, fallback, subagents, Mixture of Agents |
| `references/soul-templates.md` | Personality stack: `SOUL.md`, `/personality`, custom presets |
| `references/memory.md` | Built-in MEMORY/USER, limits, write approval, external providers |
| `references/browser-and-computer.md` | Browser toolset, computer_use, Bot Screen, shared vs dedicated |
| `references/runtime-limits-and-tools.md` | Toolsets, approvals, terminal backend, output/turn/compression limits |
| `references/security.md` | Approvals, privacy, write safety, pairing, checkpoints/rollback, backup |
| `references/workspace-and-display.md` | Working directory, projects, repo scan, skins, display chrome, ui-preferences |
| `references/recipes.md` | End-to-end create/clone/gateway/export examples |
| `references/troubleshooting.md` | List/gateway/alias/session issues |

Docs: https://hermes-agent.nousresearch.com/docs/user-guide/profiles  
Config: https://hermes-agent.nousresearch.com/docs/user-guide/configuration  
Security: https://hermes-agent.nousresearch.com/docs/user-guide/security  
Checkpoints: https://hermes-agent.nousresearch.com/docs/user-guide/checkpoints-and-rollback  
Tools: https://hermes-agent.nousresearch.com/docs/user-guide/features/tools  
Skins: https://hermes-agent.nousresearch.com/docs/user-guide/features/skins  
Personality: https://hermes-agent.nousresearch.com/docs/user-guide/features/personality  
Memory: https://hermes-agent.nousresearch.com/docs/user-guide/features/memory  
Browser: https://hermes-agent.nousresearch.com/docs/user-guide/features/browser  
Computer use: https://hermes-agent.nousresearch.com/docs/user-guide/features/computer-use

## Resolve home

1. Default root: `$HERMES_HOME` if set, else `~/.hermes`.
2. Named profile path: `<root>/profiles/<slug>/`.
3. Target with `hermes -p <slug> …` or the shell alias `<slug>` when present.
4. Sticky default: `hermes profile use <slug>`. Use `default` to return.

A directory under `profiles/` counts as a profile only if it has an identity file:
`config.yaml`, `.env`, `SOUL.md`, `profile.yaml`, `auth.json`, or `state.db`.

## Discover first

Before create/edit/delete:

```bash
hermes profile list
hermes profile show <slug>
```

Read `SOUL.md`, `display.personality` / `agent.personalities` in `config.yaml`,
`profile.yaml` (description / ui_meta), and the model block as needed.
Do not print `.env` secret values into chat.

## Mental model

| Term | Meaning |
|------|---------|
| Profile | Persistent home: config, secrets, SOUL, memory, skills, sessions, cron, gateway state |
| Agent | Running Hermes process using that home |
| Bot | Profile in Desktop Bot Mode roster (`ui_meta` in `profile.yaml`) |
| Messaging bot | Platform account token in that profile's `.env` |
| Subagent | Child from `delegate_task` (fresh chat, not a separate profile) |
| Personality | Named voice overlay (`display.personality` / `/personality`) on top of SOUL |
| Memory | Per-profile curated `MEMORY.md` / `USER.md`, optional one external provider |
| Browser | `browser` toolset (`browser_exec`); local / cloud / real-profile / CDP |
| Computer use | `computer_use` toolset (cua-driver); optional Linux Bot Screen per profile |
| Toolsets / limits | Enabled tools, approvals, terminal backend, output and turn caps |
| Security | Approvals/YOLO floor, privacy redaction, pairing, checkpoints, backup |
| Workspace / display | `terminal.cwd`, projects, repo scan, skins, `display.*`, Desktop prefs |

`HERMES_HOME` isolates Hermes data. `terminal.cwd` sets the gateway/cron working directory
(CLI uses the launch dir). Profiles do not sandbox the filesystem. Never run two writers
against the same profile.

## Lifecycle

### Create

```bash
hermes profile create <slug>
hermes profile create <slug> --description "One-line role for kanban routing"
hermes profile create <slug> --clone
hermes profile create <slug> --clone-from <source>
hermes profile create <slug> --clone-all
hermes profile create <slug> --clone-from <source> --clone-all
hermes profile create <slug> --no-skills
```

- Blank / `--no-skills`: run `hermes -p <slug> setup` for keys and model.
- `--clone`: copies config, `.env` (minus messaging channels by default), `SOUL.md`, skills, curated MEMORY/USER, plugins. Fresh sessions/state/cron.
- `--clone-all`: fuller copy; still excludes sessions, `state.db`, backups, checkpoints, cron, and (from default) local model trees. Messaging channels still stripped unless `--clone-channels`.
- Messaging tokens are never cloned by default. Ask before `--clone-channels`.
- Creating a profile does not set `terminal.cwd`. Set an absolute project path if needed:

```bash
hermes -p <slug> config set terminal.cwd /absolute/path/to/project
```

Verify with `hermes profile show <slug>` and `hermes profile alias <slug>` if the wrapper is missing.

### Describe (kanban routing)

```bash
hermes profile describe <slug>
hermes profile describe <slug> --text "Reads code and writes findings."
hermes profile describe <slug> --auto
hermes profile describe --all --auto
```

Persists in `<profile>/profile.yaml` as `description` / `description_auto`.

### Use / show / rename / alias

```bash
hermes profile use <slug>
hermes profile show <slug>
hermes profile rename <old> <new>
hermes profile alias <slug>
hermes profile alias <slug> --remove
```

After rename, reinstall a per-profile gateway service if one existed:
`hermes -p <new> gateway install`.

`hermes profile rename default <DisplayName>` only sets presentation `display_name`.
The id stays `default`.

### Delete

Ask the user to confirm the slug. Then:

```bash
hermes profile delete <slug>
hermes profile delete <slug> --yes
```

Cannot delete `default`. Use `hermes uninstall` only for a full wipe the user requested.

### Share

```bash
hermes profile export <slug>
hermes profile import <archive.tar.gz>
hermes profile install <git-url-or-path> [--alias]
hermes profile update <slug>
hermes profile info <slug>
```

Distributions are versioned agent packages. Recipient keeps their own `.env`, memories, and sessions.

## Identity and config

### SOUL.md and personality

Full guide: `references/soul-templates.md`.

| Layer | Path / key | Role |
|-------|------------|------|
| Durable identity | `<profile>/SOUL.md` | System prompt slot #1 (who the agent is) |
| Named overlay | `display.personality` + `/personality` | Built-in or custom preset on top of SOUL |
| Manual overlay | `agent.system_prompt` | Free-form; used only when no personality name is set |
| Custom presets | `agent.personalities` (or top-level `personalities`) | User-defined / overrides of built-ins |

```bash
# Sticky personality for this profile
hermes -p <slug> config set display.personality concise
hermes -p <slug> config set display.personality ''     # clear → SOUL only
# In session: /personality teacher | /personality none
```

Put standing voice and role in SOUL. Use `/personality` for temporary mode shifts
(or a sticky named default). Put user facts in memory (`USER.md` / `MEMORY.md`).
Reload the session (or `hermes sessions refresh-prompts`) after SOUL edits.

### profile.yaml

- `description`, `description_auto` via `hermes profile describe`
- `display_name` for presentation
- `ui_meta.hermes-bots` for Bot Mode roster presentation (leave unless asked)

### config.yaml

```bash
hermes -p <slug> config set model.default <model-id>
hermes -p <slug> config set terminal.cwd /absolute/path
hermes -p <slug> config set display.personality concise
hermes -p <slug> doctor
hermes -p <slug> skills list
```

Prefer `hermes -p <slug> …` / setup over large hand-edits.

### Models, auxiliary, fallback, subagents, MoA

Full guide: `references/models-and-delegation.md`. Short map:

| Concern | Config / CLI |
|---------|----------------|
| Main brain | `model.*` / `hermes -p <slug> model` / `/model` |
| Side jobs (vision, compression, titles, approval, review, …) | `auxiliary.<task>.*` (default `auto` = main) |
| Backup when primary fails | `fallback_providers` / `hermes -p <slug> fallback` |
| `delegate_task` workers | `tools enable delegation` + `delegation.*` (model/provider, concurrency, `backend`) |
| Different models per delegated task | `delegation.backend: model_map` (`advanced-delegation`; see `models-and-delegation.md`) |
| Multi-model advice + one acting loop | `moa.presets` / `hermes -p <slug> moa configure` / provider `moa` |

Subagents are fresh child runs, not separate profiles. Enable the `delegation`
toolset so profiles that fan out work can call `delegate_task`. Prefer
`delegation.backend: model_map` when tasks need different models; use
`profile_routes` to run a child **as** another profile. MoA presets appear as
selectable models under provider `moa`.

### .env

API keys and messaging bot tokens. One bot token per messaging profile.
Never paste secret values into the conversation.

### Memory

Full guide: `references/memory.md`.

| Concern | Config / CLI |
|---------|----------------|
| Built-in stores | `memory.memory_enabled` / `user_profile_enabled` + char limits |
| Gate saves | `memory.write_approval` + `/memory pending\|approve\|reject` |
| External provider (one) | `memory.provider` / `hermes -p <slug> memory setup\|status\|off` |
| Notifications | `display.memory_notifications` (`off` \| `on` \| `verbose`) |
| Wipe built-in files | `hermes -p <slug> memory reset` (confirm first) |

`<profile>/memories/USER.md` and `MEMORY.md` freeze into the prompt at session start.
Prefer in-chat memory tool saves. Mid-session disk edits apply on the next session.
One external provider is additive; built-in stays unless you disable it.

### Browser and computer use

Full guide: `references/browser-and-computer.md`.

| Concern | Config / CLI |
|---------|----------------|
| Enable toolsets | `hermes -p <slug> tools enable browser\|computer_use` |
| Browser source | `browser.cloud_provider` / `engine` / `cdp_url` / `use_real_profile` |
| Persistent vs throwaway cookies | `browser.user_data_dir` (empty = throwaway) |
| Visible browser | `browser.headed` |
| Computer driver | `hermes -p <slug> computer-use install\|status\|doctor` |
| Permission mode | `computer_use.permission_mode` (`standard` \| `bounded`) |
| Linux Bot Screen | `bot_desktop.*` / `hermes -p <slug> computer-use screen …` |

Browser ≠ computer use. Prefer `web_search` when pages need no interaction.
Confirm before real-profile browsing or shared `user_data_dir`.

### Tools, terminal, limits

Full guide: `references/runtime-limits-and-tools.md`.

| Concern | Config / CLI |
|---------|----------------|
| Toolsets | `hermes -p <slug> tools enable\|disable\|list` / `toolsets` / `agent.disabled_toolsets` |
| Approvals | `approvals.mode` (`smart` \| `manual` \| `off`) + `deny` / `command_allowlist` |
| Terminal backend | `terminal.backend` (`local` \| `docker` \| `ssh` \| cloud sandboxes) + `cwd` / timeout |
| Output caps | `tool_output.max_bytes` / `max_lines`, `file_read_max_chars` |
| Turn / time | `agent.max_turns`, `run_budget_seconds`, `gateway_timeout` |
| Compression | `compression.threshold` (+ `auxiliary.compression` model) |
| Loop caps | `tool_loop_guardrails.*` |

### Security, privacy, restoration

Full guide: `references/security.md`.

| Concern | Config / CLI |
|---------|----------------|
| Approvals / YOLO | `approvals.*`, `command_allowlist`, `/yolo`, `hermes approvals suggest` |
| Redaction / URL guards | `security.redact_secrets`, `allow_private_urls`, `privacy.redact_pii` |
| Instruction-file gate | `security.protected_instruction_files` |
| Write sandbox | Protected paths + `HERMES_WRITE_SAFE_ROOT` |
| Messaging who | Allowlists in `.env` / `hermes pairing approve\|revoke` |
| Filesystem rollback | `checkpoints.enabled` + `/rollback` / `hermes checkpoints …` |
| Backup / restore | `hermes backup`, `hermes import`, `updates.pre_update_backup` |

Confirm before `approvals.mode: off`, open gateway allow-all, or destructive restore.

### Workspace and display

Full guide: `references/workspace-and-display.md`.

| Concern | Config / CLI |
|---------|----------------|
| Gateway / cron cwd | `terminal.cwd` (absolute path) |
| Named projects | `hermes -p <slug> project create\|list\|add-folder\|use\|…` |
| Desktop repo scan | `desktop.repo_scan_enabled` / `repo_scan_roots` / `repo_scan_exclude_paths` |
| Fonts | `desktop.font_family`, `terminal.font_family` |
| Progress / chrome | `display.tool_progress`, `show_reasoning`, `streaming`, `resume_display`, … |
| Skin (look) | `display.skin` / `/skin` (voice stays in SOUL / personality) |
| Computer-wide UI prefs | `$HERMES_HOME/ui-preferences.json` (root home, not profile folder) |

Personality overlay remains `display.personality` (`soul-templates.md`).

## Gateway

```bash
hermes -p <slug> gateway start
hermes -p <slug> gateway stop
hermes -p <slug> gateway restart
hermes -p <slug> gateway install
```

One gateway process per profile. Separate bot tokens per profile.

## Safety

1. Confirm before `delete`, `--clone-channels`, bulk `.env` changes, history wipes, YOLO/off approvals, open allow-all, or destructive `/rollback` / `checkpoints clear`.
2. One writer per profile.
3. Do not dump `.env`, auth tokens, or allowlist IDs into chat.
4. Export strips API keys; treat archives as sensitive.
5. After SOUL / personality / config / memory edits, note that live sessions need reload.

## Common recipes (summary)

- **New specialist:** `create` → `setup` → set `terminal.cwd` → edit SOUL → optional `display.personality` → `doctor` (see `recipes.md`)
- **Twin of existing:** `create <new> --clone-from <src>` (add `--clone-all` only if needed)
- **Empty orchestrator:** `create <slug> --no-skills`
- **Messaging:** unique token in that profile `.env` → `gateway start` / `install`
- **Share package:** `export` / `import` or `profile install <git-url>`

## Workflow checklist

1. `hermes profile list` / `show <slug>`
2. Choose action (use `recipes.md` for multi-step flows)
3. Run the matching `hermes` command
4. Verify with `show` / `doctor`
5. For identity edits, note session reload
6. On failure, check `troubleshooting.md`
