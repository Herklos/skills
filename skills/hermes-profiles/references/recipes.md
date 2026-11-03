# Hermes profile recipes (generic examples)

Examples use fictional slugs. Replace with the user's names.

## 1. Blank specialist, then setup

```bash
hermes profile create forge --description "Implements small PRs in the active repo"
hermes -p forge setup
hermes -p forge config set terminal.cwd /absolute/path/to/repo
hermes -p forge doctor
hermes profile show forge
```

Edit `$HERMES_HOME/profiles/forge/SOUL.md` using `soul-templates.md`, optionally set
`display.personality`, then open a new session.

## 2. Clone config from an existing profile

```bash
hermes profile create forge-sandbox --clone-from forge --description "Sandbox twin of forge"
hermes profile show forge-sandbox
```

Messaging tokens stay off the clone unless `--clone-channels` (ask first).

## 3. Narrow orchestrator (no bundled skills)

```bash
hermes profile create atlas --no-skills --description "Routes tasks; does not implement"
# Write SOUL as coordinator
hermes -p atlas doctor
```

## 4. Kanban-friendly descriptions for a fleet

```bash
hermes profile describe forge --text "Implements Ready coding tasks as small PRs."
hermes profile describe scout --text "Researches topics and writes cited notes."
hermes profile describe --all --auto   # fill missing only
```

## 5. Point Bot Mode section (optional)

Leave `ui_meta` to Desktop unless asked. For CLI-only identity:

```bash
hermes profile describe forge --text "…"
# display name via rename of default only, or Desktop title field
```

## 6. Export / import between machines

```bash
hermes profile export forge
# copy the tar.gz to the other machine
hermes profile import forge-export.tar.gz
hermes -p forge setup   # fill keys locally
```

## 7. Install a distribution (git agent package)

```bash
hermes profile install github.com/example/research-agent --alias
hermes profile info research-agent
hermes profile update research-agent
```

## 8. Gateway for messaging

```bash
# Put TELEGRAM_BOT_TOKEN (or platform equivalent) only in this profile's .env
hermes -p forge gateway start
hermes -p forge gateway install   # persistent service when desired
```

Never reuse the same bot token across two profiles.

## 9. Rename and re-hook gateway

```bash
hermes profile rename forge smith
hermes -p smith gateway install
hermes profile alias smith
```

## 10. Safe delete

```bash
hermes profile show old-bot
# confirm with user
hermes profile delete old-bot
# or hermes profile delete old-bot --yes after explicit approval
```

## Decision guide: create flags

| Goal | Flags |
|------|--------|
| Fresh agent, full skill seed | `create <slug>` |
| Fresh agent, empty skills | `create <slug> --no-skills` |
| Same model/config as current | `create <slug> --clone` |
| Same as named source | `create <slug> --clone-from <src>` |
| Near-full copy of source | `--clone-all` (+ optional `--clone-from`) |
| Also copy messaging tokens | add `--clone-channels` (confirm first) |

## 11. Wire main, aux, fallback, subagents

See `models-and-delegation.md` for full YAML. Minimal sequence:

```bash
hermes -p forge model
hermes -p forge fallback add
hermes -p forge config set auxiliary.compression.provider openrouter
hermes -p forge config set auxiliary.compression.model google/gemini-2.5-flash
hermes -p forge tools enable delegation
hermes -p forge config set delegation.model google/gemini-2.5-flash
hermes -p forge config set delegation.provider openrouter
# Prefer per-task models when difficulty varies (needs advanced-delegation plugin):
# hermes -p forge config set delegation.backend model_map
# then edit delegation.backends.model_map.options (see models-and-delegation.md)
hermes -p forge moa configure deep_review   # optional
```

## 12. Personality (SOUL + overlay)

See `soul-templates.md`. Minimal sequence:

```bash
# Edit $HERMES_HOME/profiles/forge/SOUL.md for durable identity
hermes -p forge config set display.personality concise   # sticky overlay, or ''
# Optional custom preset: edit agent.personalities in config.yaml, then:
hermes -p forge config set display.personality codereviewer
# In a live session you can also /personality teacher | /personality none
hermes sessions refresh-prompts   # after SOUL edits
```

## 13. Memory settings

See `memory.md`. Minimal sequence:

```bash
hermes -p forge memory status
hermes -p forge config set memory.memory_enabled true
hermes -p forge config set memory.user_profile_enabled true
hermes -p forge config set memory.write_approval false    # true to gate saves
hermes -p forge config set display.memory_notifications on
# Optional external provider (one at a time):
hermes -p forge memory setup          # or: config set memory.provider retaindb
hermes -p forge memory off            # external off; built-in remains
# Destructive — confirm first:
# hermes -p forge memory reset --target all
```

## 14. Browser and computer use

See `browser-and-computer.md`. Minimal sequences:

```bash
# Local throwaway browser
hermes -p forge tools enable browser
hermes -p forge config set browser.cloud_provider local
hermes -p forge config set browser.use_real_profile false
hermes pm install chromium

# Computer use on this machine
hermes -p forge tools enable computer_use
hermes -p forge computer-use install
hermes -p forge computer-use doctor

# Linux Bot Screen (gateway host)
hermes -p forge computer-use screen install
hermes -p forge computer-use screen start
```

## 15. Tools, terminal, limits

See `runtime-limits-and-tools.md`. Minimal sequence:

```bash
hermes -p forge tools enable terminal file web
hermes -p forge config set terminal.backend local
hermes -p forge config set terminal.cwd /absolute/path/to/repo
hermes -p forge config set terminal.timeout 180
hermes -p forge config set approvals.mode smart
hermes -p forge config set agent.max_turns 150          # or unset for unlimited
hermes -p forge config set tool_output.max_bytes 50000
hermes -p forge config set compression.threshold 0.50
```

## 16. Security, privacy, restoration

See `security.md`. Minimal sequence:

```bash
hermes -p forge config set approvals.mode smart
hermes -p forge config set approvals.cron_mode deny
hermes -p forge config set security.redact_secrets true
hermes -p forge config set security.protected_instruction_files true
hermes -p forge config set privacy.redact_pii false
hermes -p forge config set checkpoints.enabled false    # true + /rollback if wanted
hermes -p forge backup --quick                          # optional snapshot
# Messaging: set allowlists in .env, or hermes -p forge pairing approve …
```

## 17. Workspace and display

See `workspace-and-display.md`. Minimal sequence:

```bash
hermes -p forge config set terminal.cwd /absolute/path/to/repo
hermes -p forge project create forge-app
hermes -p forge project add-folder forge-app /absolute/path/to/repo
hermes -p forge project use forge-app
hermes -p forge config set desktop.repo_scan_enabled true
hermes -p forge config set display.skin slate
hermes -p forge config set display.tool_progress all
hermes -p forge config set display.show_reasoning true
hermes -p forge config set display.resume_display full
# Optional Desktop fonts:
# hermes -p forge config set desktop.font_family "Atkinson Hyperlegible"
# hermes -p forge config set terminal.font_family "MesloLGS NF"
```

## Decision guide: what to edit where

| Change | Where |
|--------|--------|
| Durable voice / role | `SOUL.md` |
| Named mode overlay (built-in or custom) | `display.personality` / `/personality` |
| Custom personality definitions | `agent.personalities` in `config.yaml` |
| Manual prompt when no personality name | `agent.system_prompt` |
| User preferences / durable facts | memory tool → `USER.md` / `MEMORY.md` |
| Memory limits, approval, provider | `memory.*` / `hermes -p <slug> memory …` (`memory.md`) |
| Browser / computer / Bot Screen | `browser-and-computer.md` / `hermes tools` / `computer-use` |
| Toolsets, terminal, output/turn caps | `runtime-limits-and-tools.md` |
| Approvals, privacy, pairing, checkpoints, backup | `security.md` |
| cwd, projects, repo scan, skins, display chrome | `workspace-and-display.md` |
| Model / cwd / tools | `hermes -p <slug> config set …` |
| Auxiliary / fallback / MoA / delegation | `models-and-delegation.md` |
| API keys / bot tokens / allowlist IDs | profile `.env` (never echo values) |
| Kanban one-liner | `hermes profile describe` |
| Bot roster avatar/section | Desktop Bot Mode / `ui_meta` |
