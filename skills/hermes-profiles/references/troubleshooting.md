# Hermes profiles troubleshooting

## Profile not listed

- Directory under `profiles/` needs an identity file (`config.yaml`, `.env`, `SOUL.md`, `profile.yaml`, `auth.json`, or `state.db`).
- Bare empty folders are ignored.

## Wrong profile active

```bash
hermes profile
hermes profile use <slug>    # sticky
# or one-shot:
hermes -p <slug> chat
```

Prompt should show the profile name. Banner shows `Profile: <slug>`.

## Alias missing

```bash
hermes profile alias <slug>
# wrapper should appear on PATH (often ~/.local/bin/<slug>)
```

## SOUL / personality / memory changes ignored

Context loads at session start. Open a new session or:

```bash
hermes sessions refresh-prompts
```

Personality overlay is `display.personality` (slash `/personality`). Clearing needs
`none` / `default` / `neutral` or an empty config value. Confirm with
`hermes -p <slug> config get display.personality`. Custom presets live under
`agent.personalities` and only apply after the name is selected.

Memory tool writes hit disk immediately but the system-prompt snapshot stays frozen
until the next session. Staged writes (`memory.write_approval: true`) never land until
`/memory approve`. Confirm the profile path: `hermes -p work` uses
`profiles/work/memories/`, not `~/.hermes/memories/`. See `memory.md`.

## Gateway conflict / token lock

Two profiles cannot share the same messaging bot token. Second gateway fails with a conflict naming the other profile.

Fix: unique token per profile, or stop the other gateway.

## Clone brought over the wrong cwd

`--clone` copies `config.yaml`. Reset:

```bash
hermes -p <slug> config set terminal.cwd /absolute/path/to/project
# or "." for "launch directory" on local backend
```

Profiles do not sandbox the filesystem.

## Doctor warnings

```bash
hermes -p <slug> doctor
```

Fix missing `.env` keys via `setup`. Optional messaging libraries may warn if unused.

## Export missing tools/models

Exports and distributions intentionally skip machine-local `tools/`, `installs/`, and `cache/`. Reinstall deps with the package manager / `hermes` tooling on the destination.

## Stuck after rename

```bash
hermes -p <new> gateway install
hermes profile alias <new>
hermes profile migrate-identity <old> <new>   # if routing identity lagged
```

## Dual writers corrupting memory

Symptom: identity/memory drifts after two processes share one home.

Fix: one writer per profile. Use separate profiles or an external memory provider for shared knowledge.

## Browser or computer_use missing / failing

```bash
hermes -p <slug> tools list
hermes -p <slug> tools enable browser          # needs terminal toolset too
hermes pm install chromium                     # local browser
hermes -p <slug> computer-use status
hermes -p <slug> computer-use doctor           # TCC / AX / display checks
hermes -p <slug> computer-use screen status    # Linux Bot Screen
```

Confirm `browser.cloud_provider` and keys if using cloud. Real-profile issues:
check `use_real_profile`, pin, and (Windows) whether the browser must quit for
the first cookie copy. See `browser-and-computer.md`.

## Terminal commands fail / wrong cwd / sandbox

```bash
hermes -p <slug> config get terminal.backend
hermes -p <slug> config get terminal.cwd
# Local smoke test:
hermes -p <slug> config set terminal.backend local
# Docker: docker version ; check image / network / mounts
hermes -p <slug> tools list
```

Approvals stuck unanswered: check `approvals.mode` and platform (cron uses
`cron_mode: deny` by default). Output truncated: raise `tool_output.max_bytes`
or read with `offset`/`limit`. Turns cut short: inspect `agent.max_turns` /
`run_budget_seconds`. See `runtime-limits-and-tools.md`.

## Unauthorized messaging users / pairing

```bash
hermes -p <slug> pairing list
# Approve only with owner confirmation:
# hermes -p <slug> pairing approve <platform> <code>
```

Confirm allowlists exist in that profile's `.env` (never dump IDs into chat).
Default is deny-all when nothing is configured. See `security.md`.

## Session DB "old WAL" / refuse to write

Stop all writers on the profile → `hermes -p <slug> doctor` → restart one process.
Never delete `state.db-wal`. See `security.md` and official session-storage-recovery docs.

## Rollback / checkpoints missing

```bash
hermes -p <slug> config get checkpoints.enabled
hermes -p <slug> checkpoints status
```

Checkpoints are opt-in (`checkpoints.enabled` or `hermes chat --checkpoints`).

## Wrong workspace / missing repos in Desktop

```bash
hermes -p <slug> config get terminal.cwd
hermes -p <slug> project list
hermes -p <slug> config get desktop.repo_scan_enabled
hermes sessions list --workspace <path-or-basename>
```

Gateway/cron use `terminal.cwd`; CLI uses the launch directory. Resume restores the
session cwd unless `--no-restore-cwd`. Empty sidebar: enable scan or add folders via
`hermes project add-folder`. Restrict roots with `desktop.repo_scan_roots`. See
`workspace-and-display.md`.

## Skin / reasoning / progress not changing

`/skin` and `/verbose` / `/focus` / `/reasoning` are often session-scoped until
`config set`. Confirm:

```bash
hermes -p <slug> config get display.skin
hermes -p <slug> config get display.tool_progress
hermes -p <slug> config get display.show_reasoning
```

Skin ≠ personality. Desktop theme/density live in `$HERMES_HOME/ui-preferences.json`
(root home), not under `profiles/<slug>/`. See `workspace-and-display.md`.

## Secrets in chat

If a secret was pasted into the conversation, rotate it and scrub `.env` / provider dashboards. Do not commit `.env`.
