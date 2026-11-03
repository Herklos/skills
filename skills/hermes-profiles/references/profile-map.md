# Hermes profile map

Companion to `hermes-profiles`. Paths are relative to the profile home:
`$HERMES_HOME` for `default`, or `$HERMES_HOME/profiles/<slug>/` for named agents.

## Identity files

A directory under `profiles/` is a profile only if it contains at least one of:

`config.yaml`, `.env`, `SOUL.md`, `profile.yaml`, `auth.json`, `state.db`

Bare leftover directories are ignored by `hermes profile list`, gateways, and `-p`.

## Directory layout

| Path | Role |
|------|------|
| `profile.yaml` | `description` / `description_auto`, optional `display_name`, Bot Mode `ui_meta` |
| `config.yaml` | Model, provider, toolsets, MCP, terminal, memory, plugins, gateway, TTS, `display.*`, `desktop.*`, `agent.personalities`, … |
| `.env` | API keys, messaging bot tokens, gateway allowlists |
| `SOUL.md` | Durable identity / standing voice (system prompt slot #1). Overlays: `/personality` |
| `memories/USER.md` | User profile facts (agent-written via memory tool; `memory.user_*`) |
| `memories/MEMORY.md` | Agent notes (agent-written; `memory.memory_*`) |
| `skills/` | Per-profile skills and curator state |
| `state.db` (+ `-shm`/`-wal`) | Sessions and history |
| `cron/` | Scheduled jobs (`jobs.json`, `output/`); Bot routines are namespaced cron (see `cron.md`) |
| `plugins/` | Profile-local plugins |
| `mcp-tokens/` | MCP OAuth token cache |
| `platforms/`, `pairing/` | Messaging adapter / pairing state |
| `home/` | Tool `HOME` when `terminal.home_mode: profile` |
| `auth.json` | Profile-local OAuth (else shared from root `$HERMES_HOME/auth.json`) |
| `logs/`, `sessions/`, `cache/`, `runtime/` | Operational state |
| `.no-bundled-skills` | Marker from `--no-skills` |

## Which file does what

| File | Who writes | When loaded |
|------|------------|-------------|
| `SOUL.md` | Operator | Session start, system prompt slot #1 |
| `display.personality` | Operator / `/personality` | Named overlay on top of SOUL |
| `agent.personalities` | Operator | Custom / override personality presets |
| `USER.md` / `MEMORY.md` | Agent (memory tool) | Frozen snapshot at session start |
| `memory.*` / `memory.provider` | Operator / `hermes memory` | Built-in limits + optional external provider |
| Project `AGENTS.md` / `.hermes.md` | Operator | From working directory |
| `config.yaml` | Operator / setup / `config set` | Process start |
| `profile.yaml` description | `hermes profile describe` | Kanban routing + UI |
| `profile.yaml` ui_meta | Desktop Bot Mode | Roster presentation |

## CLI cheat sheet

```bash
hermes profile list
hermes profile show <slug>
hermes profile use <slug|default>
hermes profile create <slug> [--clone|--clone-all|--clone-from SRC|--no-skills|--description TXT|--no-alias]
hermes profile describe <slug> [--text TXT|--auto] [--overwrite] [--all]
hermes profile rename <old> <new>
hermes profile delete <slug> [--yes]
hermes profile alias <slug> [--name ALIAS|--remove]
hermes profile export <slug>
hermes profile import <archive.tar.gz>
hermes profile install <git-url-or-path> [--alias]
hermes profile update <slug>
hermes profile info <slug>

hermes -p <slug> setup|doctor|chat|skills list
hermes -p <slug> config set <dotted.key> <value>
hermes -p <slug> config set display.personality <name|''>
hermes -p <slug> memory setup|status|off|reset
hermes -p <slug> config set memory.<key> <value>
hermes -p <slug> tools enable|disable|list [toolsets…]
hermes -p <slug> computer-use install|status|doctor|permissions|screen …
hermes -p <slug> config set browser.<key> <value>
hermes -p <slug> config set computer_use.<key> <value>
hermes -p <slug> config set bot_desktop.<key> <value>
hermes -p <slug> config set terminal.<key> <value>
hermes -p <slug> config set approvals.<key> <value>
hermes -p <slug> config set security.<key> <value>
hermes -p <slug> config set privacy.redact_pii true|false
hermes -p <slug> config set checkpoints.enabled true|false
hermes -p <slug> config set agent.max_turns <n|null>
hermes -p <slug> config set tool_output.max_bytes <n>
hermes -p <slug> config set compression.<key> <value>
hermes -p <slug> config set display.<key> <value>
hermes -p <slug> config set desktop.<key> <value>
hermes -p <slug> project create|list|show|add-folder|use|archive|…
hermes -p <slug> pairing list|approve|revoke|clear-pending
hermes -p <slug> approvals suggest [--apply …]
hermes -p <slug> checkpoints status|prune|clear
hermes -p <slug> backup [--quick]
hermes -p <slug> tools enable cronjob
hermes -p <slug> cron create|list|edit|pause|resume|run|cancel|remove|status|tick|doctor
hermes -p <slug> config set cron.model <name>
hermes -p <slug> config set approvals.cron_mode deny|approve
hermes -p <slug> gateway start|stop|restart|install
# In session: /cron … ; /personality [name|none] ; /skin <name> ; /verbose ; /focus ;
#   /reasoning show|hide ; /memory pending|approve|reject ; /rollback …
```

## Clone flag matrix

| Flag | Copies | Skips by default |
|------|--------|------------------|
| (none) | Fresh home + bundled skills (unless `--no-skills`) | Everything from source |
| `--clone` | config, `.env` (non-channel), SOUL, skills, MEMORY/USER, plugins | sessions, state.db, cron, messaging channels |
| `--clone-all` | Fuller tree | sessions, state.db, backups, checkpoints, cron; messaging channels |
| `--clone-from SRC` | Same as `--clone` (or `--clone-all`) from SRC | Same skips |
| `--clone-channels` | Opt in to copy messaging tokens/platform state | May be refused if multiplex serves source |
| `--no-skills` | Empty skills + `.no-bundled-skills` | Incompatible with clone flags |
| `--description` | Sets kanban description in profile.yaml | — |

## Targeting

| Mechanism | Effect |
|-----------|--------|
| `hermes -p <slug>` | One-shot target |
| Profile shell alias | Wrapper setting `HERMES_HOME` to the profile |
| `hermes profile use <slug>` | Sticky default for bare `hermes` |
| `HERMES_HOME=/path` | Manual override |

## Bot Mode metadata (profile.yaml)

```yaml
description: Optional kanban role blurb
description_auto: false
ui_meta:
  hermes-bots:
    title: Display title
    imageKind: shape
    shape: blobatar
    sectionId: …
    sectionName: …
    pinned: true
```

## Doc links

- https://hermes-agent.nousresearch.com/docs/user-guide/profiles
- https://hermes-agent.nousresearch.com/docs/user-guide/features/personality
- https://hermes-agent.nousresearch.com/docs/user-guide/features/memory
- https://hermes-agent.nousresearch.com/docs/user-guide/features/memory-providers
- https://hermes-agent.nousresearch.com/docs/user-guide/features/browser
- https://hermes-agent.nousresearch.com/docs/user-guide/features/computer-use
- https://hermes-agent.nousresearch.com/docs/user-guide/features/bot-screen
- https://hermes-agent.nousresearch.com/docs/user-guide/configuration
- https://hermes-agent.nousresearch.com/docs/user-guide/security
- https://hermes-agent.nousresearch.com/docs/user-guide/checkpoints-and-rollback
- https://hermes-agent.nousresearch.com/docs/user-guide/session-storage-recovery
- https://hermes-agent.nousresearch.com/docs/user-guide/features/tools
- https://hermes-agent.nousresearch.com/docs/user-guide/features/skins
- https://hermes-agent.nousresearch.com/docs/user-guide/features/cron
- https://hermes-agent.nousresearch.com/docs/user-guide/git-worktrees
- https://hermes-agent.nousresearch.com/docs/user-guide/features/context-files
- https://hermes-agent.nousresearch.com/docs/reference/toolsets-reference
- https://hermes-agent.nousresearch.com/docs/reference/profile-commands
- https://hermes-agent.nousresearch.com/docs/user-guide/which-file-does-what
- https://hermes-agent.nousresearch.com/docs/user-guide/bot-mode
- https://hermes-agent.nousresearch.com/docs/user-guide/profile-distributions
- https://hermes-agent.nousresearch.com/docs/llms.txt
