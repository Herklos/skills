---
name: hermes-profiles
description: >
  Manage Hermes Agent profiles (each profile is a full agent home: config, SOUL,
  memory, skills, gateway). Create, clone, list, show, describe, rename, delete,
  export/import, install distributions, edit SOUL/config/model, and run per-profile
  gateways. Use when the user mentions Hermes profiles, hermes -p, Bot Mode roster,
  or profile lifecycle. Use when the user runs /hermes-profiles.
version: 1.41.0
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
| `references/models.md` | Main / decision / routing model (incl. local llamacpp), auxiliary, fallback, MoA |
| `references/delegation.md` | Subagents, advanced-delegation, `model_map` / `profile_routes` |
| `references/soul-templates.md` | Personality stack: `SOUL.md`, `/personality`, custom presets |
| `references/memory.md` | Built-in MEMORY/USER, limits, write approval, external providers |
| `references/browser-and-computer.md` | Browser toolset, **sign-in / vault / real-profile**, computer_use, **Cua Spaces default**, Anytype per-HQ pair + `vault_grant`, Bot Screen |
| `references/runtime-limits-and-tools.md` | Toolsets, terminal backend, output/turn/compression limits |
| `references/security.md` | Approvals, privacy, write safety, pairing, checkpoints/rollback, backup |
| `references/workspace.md` | `terminal.cwd`, projects, repo scan, worktrees |
| `references/display.md` | Fonts, `display.*`, skins, ui-preferences |
| `references/voice.md` | Voice mode, STT, TTS (`voice.*` / `stt.*` / `tts.*`), messaging `/voice` |
| `references/cron.md` | Scheduled tasks: `cronjob` toolset, `hermes cron`, model pins, delivery, no-agent; **Anytype Agenda → Hermes** bind |
| `references/messaging-groups.md` | **Hermes Bot Mode hosted Group Chats** (preferred) + optional Telegram/Discord; Anytype typed **Group** → room_id writeback |
| `references/recipes.md` | Lifecycle create/clone/gateway recipes (config topics point at each ref) |
| `references/avatars.md` | **Bot Mode custom photo avatars** (fleet: quit Desktop → `set_asset` → seed `bot-meta-v2` with 256 data URLs) |
| `references/anytype-apply.md` | **Anytype Agent → live Hermes apply** (create-if-missing inventory, ordered fast path, model label map, write discipline, gaps) |
| `references/troubleshooting.md` | List/gateway/alias/session issues |

Stubs (redirect only): `models-and-delegation.md`, `workspace-and-display.md`.

Docs: https://hermes-agent.nousresearch.com/docs/user-guide/profiles  
Config: https://hermes-agent.nousresearch.com/docs/user-guide/configuration  
Security: https://hermes-agent.nousresearch.com/docs/user-guide/security  
Checkpoints: https://hermes-agent.nousresearch.com/docs/user-guide/checkpoints-and-rollback  
Tools: https://hermes-agent.nousresearch.com/docs/user-guide/features/tools  
Skins: https://hermes-agent.nousresearch.com/docs/user-guide/features/skins  
Personality: https://hermes-agent.nousresearch.com/docs/user-guide/features/personality  
Memory: https://hermes-agent.nousresearch.com/docs/user-guide/features/memory  
Browser: https://hermes-agent.nousresearch.com/docs/user-guide/features/browser  
Passwords & logins (vault): https://hermes-agent.nousresearch.com/docs/user-guide/features/credential-vault  
Computer use: https://hermes-agent.nousresearch.com/docs/user-guide/features/computer-use  
Cua Spaces (default computer): https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces  
Cron: https://hermes-agent.nousresearch.com/docs/user-guide/features/cron  
Delegation: https://hermes-agent.nousresearch.com/docs/user-guide/features/delegation  
Advanced delegation: https://hermes-agent.nousresearch.com/docs/plugins/advanced-delegation  
Voice mode: https://hermes-agent.nousresearch.com/docs/user-guide/features/voice-mode  
Voice & TTS: https://hermes-agent.nousresearch.com/docs/user-guide/features/tts  
Voice guide: https://hermes-agent.nousresearch.com/docs/guides/use-voice-mode-with-hermes

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
| Messaging group | Shared multi-bot room; org default = Hermes Bot Mode hosted Group Chat (2–6 bots); optional Telegram/Discord when asked. Anytype typed Group holds roster + welcome + `platform_chat_id` (`messaging-groups.md`) |
| Subagent | Child from `delegate_task` (fresh chat, not a separate profile) |
| Personality | Named voice overlay (`display.personality` / `/personality`) on top of SOUL |
| Memory | Per-profile curated `MEMORY.md` / `USER.md`, optional one external provider |
| Browser | `browser` toolset (`browser_exec`); local / cloud / real-profile / CDP; in Space when cua + desktop |
| Computer | **Default: Cua Spaces** (`terminal.backend: cua`, plugin cua-spaces); `computer_use` / Bot Screen as host or Linux-gateway exceptions |
| Toolsets / limits | Enabled tools, approvals, terminal backend (`cua` preferred), output and turn caps |
| Security | Approvals/YOLO floor, privacy redaction, pairing, checkpoints, backup |
| Workspace / display | `terminal.cwd`, projects, repo scan, skins, `display.*`, Desktop prefs |
| Voice | Mic loop + STT + TTS (`voice.*` / `stt.*` / `tts.*`); messaging `/voice`; Discord VC |
| Scheduled tasks | Per-profile `cron/` jobs (`cronjob_manage` / `/cron` / `hermes cron`); Bot routines |

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
`hermes profile show` does not print it. Desktop Edit Profile Description is this
same field (Save → `profile describe <bot.name> --text`); Primary uses slug
`default`, not display title `P`. The Bot Mode roster **card subtitle** is the
last chat preview, not `description` — see `profile-map.md` → **Description vs
roster card subtitle** and `troubleshooting.md`.

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
When applying from Anytype: keep Shared Rules + Agenda + HQ standing as **short
pointers** in SOUL (do not paste HQ Standing instructions libraries). See
`soul-templates.md` → Anytype Shared Rules + HQ standing. Reload the session
(or `hermes sessions refresh-prompts`) after SOUL edits.

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

### Models, auxiliary, fallback, MoA

Full guide: `references/models.md`.

| Concern | Config / CLI |
|---------|----------------|
| Main / decision / routing model | `model.*` / `hermes -p <slug> model` / `/model` |
| Local parent (chat + approval) | Chat `llamacpp` / `LFM3-1.7B-Q8_0`; approval `auxiliary.approval` = `llamacpp` / `d1-2b-q4_k_m` + `local_runtime` (`models.md`) |
| Side jobs | `auxiliary.<task>.*` (default `auto` = main) |
| Backup mid-turn | `fallback_providers` / `hermes -p <slug> fallback` |
| MoA | `moa.presets` / `hermes -p <slug> moa configure` |

### Subagents / advanced-delegation

Full guide: `references/delegation.md`.

| Concern | Config / CLI |
|---------|----------------|
| Enable | `tools enable delegation` |
| Plugin (task routes) | `plugins install advanced-delegation` (Hermes >= 0.22.5) |
| Task-specific models | `delegation.backend: model_map` + `hermes delegation config` |
| Profile personas | `delegation.backend: profile_routes` |
| Chat switch | `/delegation model_map\|profiles\|default [--now]` |

Parent `model.*` is the routing model. Prefer named `model_map` routes when task cost/difficulty varies.

### .env

API keys and messaging bot tokens. One bot token per messaging profile.
Never paste secret values into the conversation.

### Memory

Full guide: `references/memory.md`. Keys: `memory.*`, `hermes -p <slug> memory setup|status|off|reset`, `display.memory_notifications`.

### Browser and computer use

Full guide: `references/browser-and-computer.md` (includes **Signing in**). **Default computer:** [cua-spaces](https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces) (`plugins install` + `terminal.backend: cua`; set `desktop: true` for browser / `computer_use` in Linux Spaces). When Anytype links a per-HQ pair (`{HQ} – Cua Spaces` + `{HQ} – Hermes Chromium`; `hq-runtime-pair.md` + `cua-hq-spaces.md`), pin Hermes `settings.space` from Computer.`cua_space` and apply Browser.`is_real` / `browser_engine` / `real_profile_pin` (org default: one dedicated Chrome profile per Browser, e.g. pin `Profile 2`; see **Anytype per-HQ pair → Hermes**). Host desktop and Linux Bot Screen are exceptions. Also: `tools enable browser|computer_use`; `browser.*`, `computer_use.*`, `bot_desktop.*`.

**Authenticated browsing:** org Anytype default is **operator real profile** (`use_real_profile` + dedicated pin). When `is_real` is false, Chromium is logged out; use Hermes **vault** (masked prompts; never paste passwords in chat), 1Password/Bitwarden CLI, **dedicated persistent** `user_data_dir`, or CDP attach. Check Anytype **`vault_grant`** for which Agent may use which site/identity. Secrets never live in Anytype. Vault docs: https://hermes-agent.nousresearch.com/docs/user-guide/features/credential-vault

### Tools, terminal, limits

Full guide: `references/runtime-limits-and-tools.md`. Toolsets via `hermes tools`; prefer `terminal.backend: cua`; caps via `tool_output.*`, `agent.max_turns`, `compression.*`.
### Security, privacy, restoration

Full guide: `references/security.md`. Approvals/`cron_mode`, `security.*`, `privacy.redact_pii`, pairing, checkpoints/`/rollback`, `hermes backup`.

### Workspace and display

Full guides: `references/workspace.md` (`terminal.cwd`, projects, repo scan) and `references/display.md` (skins, `display.*`, fonts, ui-preferences). Personality overlay remains in `soul-templates.md`.

### Voice (STT / TTS / mic loop)

Full guide: `references/voice.md`. Defaults: `stt.provider: local` + `tts.provider: edge`.
Keys: `voice.*`, `stt.*`, `tts.*`. Session: `/voice on|off|tts|status`; Discord VC:
`/voice join|leave`. Anytype: Harness profile holds STT/TTS stack; Agent holds
enablement / modes (`voice_enabled`, `voice_auto_tts`, `voice_chat_mode`,
`messaging_voice_mode`).

### Scheduled tasks (cron)

Full guide: `references/cron.md`. Enable `cronjob`; manage with `hermes cron` /
`/cron`. Intended jobs live as Anytype **Schedule** objects on the agent's
**Agenda** Query (`anytype-agents` `agenda-and-schedules.md`); decline
recurring/oneshot rows into Hermes only when the user asks to apply.

### Messaging groups (multi-bot rooms)

Full guide: `references/messaging-groups.md`. **Org default: Hermes Bot Mode
hosted Group Chats** (Desktop Bots → Manage groups / New Group Chat, or
`groups.create` RPC; 2–6 bots; stored in `hosted_rooms`). Do not create
Telegram/Discord rooms unless the user asks. Write the Hermes `room_id` back to
Anytype Group.`platform_chat_id` (and `platform=hermes`). When a Group has more
than 6 `hermes_profiles`, seat six in the primary room and create a satellite
B room for overflow. External Telegram/Discord still need one token + allowlist
+ mention gates per profile. Intended rooms live as Anytype typed **Group**
objects; decline only when the user asks. **Join HQ/domain Group first** for
new specialists. Groups are not `delegation.backend` modes (`delegation.md`).

### Anytype suggestions → Hermes apply

Org improvement feedback lives as typed Anytype **`suggestion`** objects
(Agent.`suggestions_page`; Shared Rule 25; Agathe weekly + agent ad-hoc). Full
loop: `anytype-agents` → `suggestions.md`.

Apply harness / Subagent / model / SOUL / cron / messaging changes into live
`~/.hermes` profiles only when:

1. the related suggestion is **`accepted`** (or the user explicitly asks to
   apply), and
2. you follow **`anytype-apply.md`** (ordered playbook) plus the matching topic
   refs (`models.md`, `delegation.md`, `soul-templates.md`, `cron.md`,
   `messaging-groups.md`, …).

Never auto-apply from a `draft` / `proposed` suggestion. Mark the suggestion
`done` after a successful apply when you are tracking that object.

**Primary maps to Hermes id `default`** (not `profiles/p`). After apply, set
Agent.`hermes_profile` when empty. Prefer `hermes config set` / `tools` over
full-file `yaml.safe_dump`. Resolve Harness display labels via
`provider_models_cache.json` before writing `model_map` routes.

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
6. Do not apply Anytype org changes into live profiles from `draft`/`proposed` suggestions; wait for `accepted` or an explicit user ask (see **Anytype suggestions → Hermes apply**).

## Common recipes (summary)

- **New specialist:** `create` → `setup` → set `terminal.cwd` → edit SOUL → optional `display.personality` → `doctor` (see `recipes.md`)
- **Twin of existing:** `create <new> --clone-from <src>` (add `--clone-all` only if needed)
- **Empty orchestrator:** `create <slug> --no-skills`
- **Create missing from Anytype:** inventory live Hermes-runtime Agents vs `~/.hermes/profiles`; create gaps with `--clone-from` peer; replace SOUL; Local parent; describe (`anytype-apply.md` → Create missing profiles). Skip Osaurus / archived.
- **Fleet Bot Mode avatars:** quit Desktop → `profiles.set_asset` → `ui_meta` photo/custom → seed `bot-meta-v2` with 256 data URLs (`avatars.md`; recipe **5b**)
- **Messaging (external platform):** unique token in that profile `.env` → `gateway start` / `install` (only when user asks for Telegram/Discord)
- **Multi-bot group:** `messaging-groups.md` (prefer Hermes Bot Mode hosted rooms via `groups.create` / Desktop; Anytype join-HQ-first; optional Telegram tokens/allowlists only when asked)
- **Fleet messaging + deferred delegation:** `anytype-apply.md` → Fleet apply; Bot Mode `groups.create` when chat id empty; `model_map` via JSON `config set` for Subagent parents still unconfigured (`delegation.md` Fleet apply); skip `profile_routes` parents
- **Delegation mode:** one of `model_map` / `profile_routes` / `default` via Agent.`delegation_backend` (`delegation.md`); distinct from messaging Groups
- **Share package:** `export` / `import` or `profile install <git-url>`
- **Anytype → Hermes apply:** `anytype-apply.md` (SOUL + Local parent + model_map routes + **default** + option enforcement + tools + cron + org skills + voice modes + analytics/langfuse + describe)
- **Delegation safety:** Local parent `model_map.default` required; SOUL/Shared Rules require `option` on every `delegate_task`; rebuild schema with `/delegation model_map --now` or `/new` (`delegation.md`)
- **Browser sign-in:** vault / manager / persistent / real-profile / CDP (`browser-and-computer.md`); respect Anytype `vault_grant`; never passwords in chat or Anytype

## Workflow checklist

1. `hermes profile list` / `show <slug>`
2. Choose action (use `recipes.md` for multi-step flows)
3. Run the matching `hermes` command
4. Verify with `show` / `doctor`
5. For identity edits, note session reload
6. On failure, check `troubleshooting.md`
