---
name: hermes-profiles
description: >
  Manage Hermes Agent profiles (each profile is a full agent home: config, SOUL,
  memory, skills, gateway). Create, clone, list, show, describe, rename, delete,
  export/import, install distributions, edit SOUL/config/model, and run per-profile
  gateways. Use when the user mentions Hermes profiles, hermes -p, Bot Mode roster,
  or profile lifecycle. Use when the user runs /hermes-profiles.
version: 1.3.0
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
| `references/recipes.md` | End-to-end create/clone/gateway/export examples |
| `references/troubleshooting.md` | List/gateway/alias/session issues |

Docs: https://hermes-agent.nousresearch.com/docs/user-guide/profiles  
Personality: https://hermes-agent.nousresearch.com/docs/user-guide/features/personality

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

`HERMES_HOME` isolates Hermes data. `terminal.cwd` sets the tool working directory.
Profiles do not sandbox the filesystem. Never run two writers against the same profile.

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
| `delegate_task` workers | `delegation.model` / `provider` / concurrency / `backend` |
| Multi-model advice + one acting loop | `moa.presets` / `hermes -p <slug> moa configure` / provider `moa` |

Subagents are fresh child runs, not separate profiles. Optional `delegation.backend: profile_routes` can run a child **as** another profile. MoA presets appear as selectable models under provider `moa`.

### .env

API keys and messaging bot tokens. One bot token per messaging profile.
Never paste secret values into the conversation.

### Memory

`<profile>/memories/USER.md` and `MEMORY.md` freeze into the prompt at session start.
Prefer in-chat memory saves. Mid-session disk edits apply on the next session.

## Gateway

```bash
hermes -p <slug> gateway start
hermes -p <slug> gateway stop
hermes -p <slug> gateway restart
hermes -p <slug> gateway install
```

One gateway process per profile. Separate bot tokens per profile.

## Safety

1. Confirm before `delete`, `--clone-channels`, bulk `.env` changes, or history wipes.
2. One writer per profile.
3. Do not dump `.env` or auth tokens into chat.
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
