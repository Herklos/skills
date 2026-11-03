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
| `config.yaml` | Model, provider, toolsets, MCP, terminal, memory, plugins, gateway, TTS, … |
| `.env` | API keys, messaging bot tokens, gateway allowlists |
| `SOUL.md` | Personality / standing instructions (system prompt slot #1) |
| `memories/USER.md` | User profile facts (agent-written via memory tool) |
| `memories/MEMORY.md` | Agent notes (agent-written) |
| `skills/` | Per-profile skills and curator state |
| `state.db` (+ `-shm`/`-wal`) | Sessions and history |
| `cron/` | Scheduled jobs; Bot routines are namespaced cron |
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
| `SOUL.md` | Operator | Session start, system prompt |
| `USER.md` / `MEMORY.md` | Agent (memory tool) | Frozen snapshot at session start |
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
hermes -p <slug> gateway start|stop|restart|install
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
- https://hermes-agent.nousresearch.com/docs/reference/profile-commands
- https://hermes-agent.nousresearch.com/docs/user-guide/which-file-does-what
- https://hermes-agent.nousresearch.com/docs/user-guide/bot-mode
- https://hermes-agent.nousresearch.com/docs/user-guide/profile-distributions
- https://hermes-agent.nousresearch.com/docs/llms.txt
