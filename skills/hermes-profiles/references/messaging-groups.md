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
| Delegation backend | Separate: `model_map` / `profile_routes` / `default` on the Agent (`delegation.md`). Groups are rooms, not spawn modes |

Anytype does **not** create the Telegram/Discord room or start gateways. It
stores who belongs, the welcome text, and intended platform settings. Apply
into Hermes when the user asks (standing redesign rule: wait until they say
apply).

## Anytype: join HQ Group vs create a new room

Every **live** Agent should have Agent.`messaging_group` filled. Prefer joining
the owning HQ (or existing domain) Group over minting one room per specialist.

**Join (default for new specialists under an HQ that already has a Group):**

1. Search `type: group` for the HQ / domain room
2. Patch Group.`members` (+ HQ.`members` when they report there)
3. Append slug to Group.`hermes_profiles` (comma list)
4. Set Agent.`messaging_group` → Group id
5. Rewrite welcome Prompt (delete stale blocks → `insert_blocks`)
6. Defer Hermes token/allowlist/gateway apply until the user asks

**Create a new typed Group only when** there is a new HQ, or a domain that
already owns a distinct chat (Veille & Technology, Wedding, Ana, Kitchen, …).
Example: Clovis / Denise / Joachim joined **Engineering Group** rather than
getting three new rooms; Octave stays on Veille & Technology Group.

Gap inventory: `type: agent`, `lifecycle = "live"`, fields include
`messaging_group`. Empty → join HQ or domain Group.

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

## Fleet apply (groups that use messaging, Hermes still incomplete)

When the user asks to apply messaging groups for agents that already have
Anytype Groups but Hermes is still unconfigured:

1. **Inventory** live Groups (`type: group`, `lifecycle=live`) and member
   Agent.`hermes_profile` slugs (also Group.`hermes_profiles` comma list).
2. **Per member profile** that exists under `~/.hermes/profiles/<slug>/`:
   - Always set mention gates (and bot loop guard when missing):
     ```bash
     hermes -p <slug> config set telegram.require_mention true
     hermes -p <slug> config set telegram.exclusive_bot_mentions true
     hermes -p <slug> config set telegram.bots_require_mention true
     # bot_loop_guard: enabled + max_events/window/cooldown if absent
     ```
   - Set allowlists **only** when Group.`platform_chat_id` is a real id.
   - If `platform_chat_id` is empty: gates only; leave
     `group_allowed_chats` / `allowed_chats` empty. **Do not invent** chat ids.
3. **Tokens / gateways:** never auto-clone `TELEGRAM_BOT_TOKEN` or start a
   dedicated gateway unless asked. Treat commented `# TELEGRAM_BOT_TOKEN=`
   lines as **missing** (not configured). Report token + chat-id gaps.
4. Verify gates with `hermes -p <slug> config get telegram` (or a YAML scan).
   A profile can have `require_mention` set while still missing
   `bots_require_mention`; check all three gates.

Fleet example (2026-11-05): mention gates on ~50 Group member profiles; every
live Group still lacked `platform_chat_id`; no live tokens written.

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
