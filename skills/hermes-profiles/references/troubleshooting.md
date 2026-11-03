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

## Secrets in chat

If a secret was pasted into the conversation, rotate it and scrub `.env` / provider dashboards. Do not commit `.env`.
