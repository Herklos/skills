# Messaging groups (multi-bot Telegram / Discord)

How to put several Hermes **profiles** (bots) into one shared chat group, and
how that maps from Anytype typed **Group** objects.

Load when creating or updating a multi-agent messaging room, applying
Agent.`messaging_group` / Group platform fields, or debugging mention routing.
Platform setup details: official Telegram / Discord messaging docs. Lifecycle:
`recipes.md`. Tokens: profile `.env` only (never echo).

## Mental model

| Layer | What it is |
|-------|------------|
| Anytype **Group** (`type: group`) | Org roster + welcome Prompt + platform ids |
| Hermes **profile** | One bot home (`~/.hermes/profiles/<slug>/`) |
| Platform group/channel | Telegram supergroup / Discord channel the bots join |
| Gateway | One process per profile (`hermes -p <slug> gateway …`) |

Anytype does **not** create the Telegram/Discord room or start gateways. It
stores who belongs, the welcome text, and intended platform settings. Apply
into Hermes when the user asks (standing redesign rule: wait until they say
apply).

## Create a multi-bot group (Hermes)

1. **One bot token per profile.** In BotFather (Telegram) or the Discord portal,
   create a distinct bot for each agent. Put `TELEGRAM_BOT_TOKEN` (or platform
   equivalent) only in that profile's `.env`. Never share a token across two
   running gateways (Telegram returns HTTP 409).
2. **Create the platform room.** Private Telegram **supergroup** (basic groups
   only allow one admin bot). Add every bot as admin (or with permission to
   read messages). Disable BotFather privacy mode when bots must see all human
   messages.
3. **Allowlist the chat** on each member profile (ids are numeric; get them from
   a forwarded message or bot updates):

```bash
hermes -p <slug> config set telegram.group_allowed_chats -- "<GROUP_ID>"
# optional: also on allowed_chats / free_response_channels when the org uses them
```

Or edit that profile `config.yaml` under `telegram:` (prefer `hermes config set`
so restarts do not fight hand-edits of `.env`).

4. **Recommended multi-bot gates** (each member profile):

```yaml
telegram:
  require_mention: true
  exclusive_bot_mentions: true
  mention_patterns: []
  bots_require_mention: true   # bot-authored msgs only when @this_bot
gateway:
  bot_loop_guard:
    enabled: true
    max_events: 20
    window_seconds: 300
    cooldown_seconds: 600
```

With this, `@research_bot @ops_bot summarize this` wakes only those two
profiles. Other Hermes bots in the room stay silent.

5. **Start one gateway per profile:**

```bash
hermes -p etienne gateway start
hermes -p arnold gateway start
# or install launchd/systemd per profile
hermes -p etienne gateway install
```

6. **Paste the welcome** from the Anytype Group's linked Prompt
   (`welcome_prompt`, `prompt_kind=welcome`) into the room once.

## Anytype Group → Hermes decline

| Anytype Group field | Hermes apply |
|---------------------|--------------|
| `members` + each Agent.`hermes_profile` | Profiles that must join; start their gateways |
| `hermes_profiles` (text, comma slugs) | Quick checklist of slugs |
| `platform` | `telegram` / `discord` / … |
| `platform_chat_id` | Value for `telegram.group_allowed_chats` (or Discord channel allowlist) |
| `require_mention` | `telegram.require_mention` |
| `exclusive_bot_mentions` | `telegram.exclusive_bot_mentions` |
| `welcome_prompt` | Human/ops paste into the room; not auto-pushed |

Keep Agent.`messaging_group` pointing at the typed Group. Do not invent chat
ids; leave `platform_chat_id` empty until a real id is known.

## Discord notes

Same pattern: one bot application per profile, invite all bots to the server
channel, allowlist channel ids per profile, prefer mention-gated behavior so
bots do not answer every message. Voice channels use `voice.md` (`/voice join`).

## Safety

- Confirm before `--clone-channels` or copying tokens between profiles.
- `TELEGRAM_ALLOW_BOTS=all` without `bots_require_mention` can loop forever.
- Editing Anytype Group membership does not add/remove bots from Telegram;
  do that in the platform + restart gateways as needed.
- During org redesign, document intended groups in Anytype and **defer** Hermes
  apply until the user asks.

## Docs

- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram
- Anytype side: skill `anytype-agents` → typed Group (`object-types.md`)
