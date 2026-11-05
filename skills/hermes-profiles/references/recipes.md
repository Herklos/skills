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

## 2b. Create missing profiles from Anytype inventory

When live Hermes-runtime Agents have `hermes_profile` set but no
`~/.hermes/profiles/<slug>/` (common after an Anytype structure fix):

```bash
# after inventory (anytype-apply.md → Create missing profiles)
hermes profile create firmin --clone-from ambre \
  --description "Sales & Acquisition under Kléber. Draft only…"
# then: Local parent config sets, replace SOUL from system Prompt,
# describe, voice modes, sessions refresh-prompts
```

Skip Osaurus-runtime Agents and archived Agents. Full checklist:
`anytype-apply.md` → **Create missing profiles**.

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

## 5b. Install custom Bot Mode avatars

When the user supplies a folder of PNGs named by profile slug (e.g.
`~/Documents/images/agents/avatars/`):

**Writing `assets/avatar.png` alone is not enough.** On launch, Bot Mode
(`pullServerAvatars` / `pushLocalAvatars`) prefers cached `bot-meta` images and
can overwrite disk files with a 160×160 SVG raster. Install through the asset
API and clear the Desktop cache.

1. Diff filenames vs `hermes profile list` + live Hermes-runtime Anytype Agents.
   Fix typos; map `p.png` → profile `default`. Skip Osaurus-only slugs.
2. **Quit Hermes Desktop** (otherwise it may race and restore old faces).
3. Center-crop square → resize to **256×256** PNG data URL.
4. For each slug, call gateway `profiles.set_asset`
   `{ name, asset: "avatar", data: "data:image/png;base64,…" }`
   (Hermes Python: `tui_gateway.server.handle_request` after importing
   `tui_gateway.methods_profiles`). This writes `assets/avatar.png` atomically.
5. Stamp `ui_meta.hermes-bots.imageKind: photo` + `custom: true` (via
   `profiles.configure` or `profile.yaml`).
6. Clear cached images in Desktop plugin storage so the roster re-fetches:
   Chromium LevelDB key `hermes.plugin.hermes-bots.bot-meta-v2` under
   `~/Library/Application Support/Hermes/Local Storage/leveldb` — delete each
   entry’s `image` field and set `imageKind: photo`. Backup the Local Storage
   folder first. (Backfill rasters are exactly **160×160**; real photos are 256.)
7. Reopen Hermes Desktop. Leave Osaurus art in `osaurus-ready/` for manual use.

Paths and style notes: `profile-map.md` → **Custom photo avatars**.

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

## 8b. Multi-bot messaging group

Full guide: `messaging-groups.md`. Summary:

1. One distinct bot token per member profile `.env`
2. Create a Telegram **supergroup** (or Discord channel); add every bot
3. Allowlist the chat id on each profile (`telegram.group_allowed_chats`)
4. Set `require_mention` + `exclusive_bot_mentions` (and bot loop guard)
5. Start one gateway per profile
6. Paste welcome from the Anytype Group's `welcome_prompt`

Do not apply from Anytype until the user asks.

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

## Config topics (one home each)

Lifecycle recipes stay above. Topic recipes live in the matching reference
(Minimal recipes / Recipe sections). Do not duplicate bash here.

| Topic | Reference |
|-------|-----------|
| Main / aux / fallback / MoA | `models.md` |
| Subagents / advanced-delegation / model_map | `delegation.md` (see its Recipe) |
| Personality / SOUL | `soul-templates.md` |
| Memory | `memory.md` |
| Browser / computer / Bot Screen | `browser-and-computer.md` |
| Tools / terminal / limits | `runtime-limits-and-tools.md` |
| Approvals / privacy / checkpoints / backup | `security.md` |
| cwd / projects / repo scan | `workspace.md` |
| Skins / display chrome / fonts | `display.md` |
| Voice / STT / TTS | `voice.md` |
| Scheduled tasks / Bot routines | `cron.md` |
| Multi-bot Telegram / Discord groups | `messaging-groups.md` |
| Anytype Agent → live Hermes apply / create-if-missing | `anytype-apply.md` |

## Decision guide: what to edit where

| Change | Where |
|--------|--------|
| Durable voice / role | `SOUL.md` (`soul-templates.md`) |
| Named mode overlay | `display.personality` / `/personality` |
| Custom personality definitions | `agent.personalities` |
| User preferences / durable facts | memory tool → `USER.md` / `MEMORY.md` |
| Memory limits, approval, provider | `memory.md` |
| Browser / computer / Bot Screen | `browser-and-computer.md` |
| Toolsets, terminal, output/turn caps | `runtime-limits-and-tools.md` |
| Approvals, privacy, pairing, checkpoints, backup | `security.md` |
| cwd, projects, repo scan | `workspace.md` |
| Skins, display chrome, fonts | `display.md` |
| Voice mode, STT, TTS, messaging `/voice` | `voice.md` |
| Scheduled tasks / Bot routines | `cron.md` |
| Multi-bot room allowlists / mention gates | `messaging-groups.md` |
| Main / aux / fallback / MoA | `models.md` |
| Task-specific subagent routes | `delegation.md` |
| API keys / bot tokens / allowlist IDs | profile `.env` (never echo values) |
| Kanban one-liner | `hermes profile describe` |
| Bot roster avatar/section | `assets/avatar.png` + `ui_meta` (`profile-map.md`; fleet: recipe **5b**) |
