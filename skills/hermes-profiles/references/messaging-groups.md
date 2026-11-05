# Messaging groups (Hermes Bot Mode + optional Telegram / Discord)

How to put several Hermes **profiles** (bots) into one shared chat room, and
how that maps from Anytype typed **Group** objects.

**Org default (this fleet):** Hermes **Bot Mode Group Chats** (hosted rooms in
Desktop Bots tab / `hosted_rooms` in `state.db`). Do **not** create Telegram or
Discord rooms unless the user explicitly asks for an external platform.

Load when creating or updating a multi-agent messaging room, applying
Agent.`messaging_group` / Group platform fields, or debugging mention routing.
Bot Mode docs: https://hermes-agent.nousresearch.com/docs/user-guide/bot-mode
Lifecycle: `recipes.md`. External tokens: profile `.env` only (never echo).

## Mental model

| Layer | What it is |
|-------|------------|
| Anytype **Group** (`type: group`) | Org roster + welcome Prompt + platform ids |
| Hermes **profile** / Bot | One bot home (`~/.hermes/profiles/<slug>/`; Primary = `default`) |
| **Hermes hosted room** | Bot Mode Group Chat (2–6 bots); stored in `hosted_rooms` |
| External platform room | Optional Telegram / Discord / … (only when asked) |
| Gateway | Multiplex host serving profiles (`hermes gateway`); one process can serve many |
| Delegation backend | Separate: `model_map` / `profile_routes` / `default` (`delegation.md`). Groups are rooms, not spawn modes |

Anytype stores who belongs, the welcome text, and intended platform settings.
It does not create the Hermes room by itself. Apply into Hermes when the user
asks.

## Anytype: join HQ Group vs create a new room

Every **live** Agent should have Agent.`messaging_group` filled. Prefer joining
the owning HQ (or existing domain) Group over minting one room per specialist.

**Join (default for new specialists under an HQ that already has a Group):**

1. Search `type: group` for the HQ / domain room
2. Patch Group.`members` (+ HQ.`members` when they report there)
3. Append slug to Group.`hermes_profiles` (comma list)
4. Set Agent.`messaging_group` → Group id
5. Rewrite welcome Prompt (delete stale blocks → `insert_blocks`)
6. Defer Hermes room membership apply until the user asks

**Create a new typed Group only when** there is a new HQ, or a domain that
already owns a distinct chat (Veille & Technology, Wedding, Ana, Kitchen, …).
Example: Clovis / Denise / Joachim joined **Engineering Group** rather than
getting three new rooms; Octave stays on Veille & Technology Group.

Gap inventory: `type: agent`, `lifecycle = "live"`, fields include
`messaging_group`. Empty → join HQ or domain Group.

## Create a Hermes Bot Mode Group Chat (preferred)

Bot Mode rooms are **hosted rooms**: 2–6 member bots on the active gateway
connection. UI path: Desktop **Bots** tab → right-click a Bot → **Manage
groups** / **New Group Chat**, or room header **Manage members**.

There is no `hermes group` CLI. Create via JSON-RPC `groups.create` on the
gateway session WebSocket (host-scoped ticket), or the Desktop UI.

### RPC path (agents / scripts)

- Multiplex **`gateway.sock`** is control-plane only (status / routing). It does
  **not** accept `groups.create`.
- Use an interactive session WebSocket (typically `ws://127.0.0.1:9120/api/ws`)
  with a **host-scoped** session ticket so sibling served profiles can be seated.
- Call with `profile: "default"` (or any bot the multiplex already serves).
- Persist results in `~/.hermes/state.db` table `hosted_rooms` (`room_id`,
  `name`, `members_json`, `disbanded_at`).

### Constraints

- **2–6 members** per room (`MIN_DISCUSSION_MEMBERS` / `MAX_DISCUSSION_MEMBERS`).
- Members must be profiles the multiplex gateway **serves**.
- Room id should be stable (org convention: `anytype-<group-slug>`).
- When Anytype `hermes_profiles` has more than 6 slugs: seat the first 6 in the
  primary room, then create a **satellite B** room for overflow (include one
  bridge chief from the primary roster so the satellite stays tied to the HQ).
  Record satellite room ids in Group.`notes`. Primary keeps `platform_chat_id`;
  satellites are notes-only unless the user wants a second Anytype Group.

### Member shape (`groups.create`)

```json
{
  "room_id": "anytype-engineering-group",
  "name": "Engineering Group",
  "members": [
    {
      "member_id": "etienne",
      "profile": "etienne",
      "handle": "etienne",
      "target": { "kind": "local", "profile": "etienne" }
    }
  ]
}
```

### Verify

```bash
sqlite3 ~/.hermes/state.db "SELECT room_id, name FROM hosted_rooms WHERE disbanded_at IS NULL;"
```

Rooms also appear in Desktop Bots → group rows. Docs: Bot Mode → Groups and
group chats.

### Anytype writeback after create

| Field | Value |
|-------|-------|
| `platform` | `hermes` (mint once; do not parallel `create_missing_options` or you get duplicate select options) |
| `platform_chat_id` | Hermes `room_id` (e.g. `anytype-engineering-group`) |
| `notes` | Satellite room ids + overflow seats when split |

### Fleet example (2026-11-05)

Created 13 primary hosted rooms (one per live Anytype Group) plus 5 satellite
B rooms for overflow (Engineering, Board, Finance, Legal & HR, Product). Wrote
`platform_chat_id` on all 13 Groups; `platform=hermes` on the first batch
(remaining Groups need `platform=hermes` after deduping duplicate select
options in Anytype UI).

## Optional: Telegram / Discord (only when asked)

External platforms need one bot **token** per profile, a platform room, and
allowlists. Skip this path for the org Bot Mode default.

1. **One bot token per profile** in that profile's `.env` (`TELEGRAM_BOT_TOKEN`
   or Discord equivalent). Never share a token across two running gateways.
2. **Create the platform room** (Telegram private **supergroup**; Discord
   channel). Add every bot with read permission.
3. **Allowlist** on each member profile:

```bash
hermes -p <slug> config set telegram.group_allowed_chats -- "<GROUP_ID>"
```

4. **Mention gates** (each member profile):

```yaml
telegram:
  require_mention: true
  exclusive_bot_mentions: true
  mention_patterns: []
  bots_require_mention: true
gateway:
  bot_loop_guard:
    enabled: true
    max_events: 20
    window_seconds: 300
    cooldown_seconds: 600
```

5. Start / install gateways as needed; paste the Anytype welcome Prompt once.

## Anytype Group → Hermes decline

| Anytype Group field | Hermes apply |
|---------------------|--------------|
| `members` + each Agent.`hermes_profile` | Profiles that must sit in the room |
| `hermes_profiles` (text, comma slugs) | Checklist; split at 6 for Bot Mode |
| `platform` | Prefer `hermes` for Bot Mode rooms; `telegram` / `discord` / … only when external |
| `platform_chat_id` | Hermes `room_id` **or** Telegram/Discord chat id |
| `require_mention` / `exclusive_bot_mentions` | External platform gates (Telegram/Discord) |
| `welcome_prompt` | Paste into the room once (Bot Mode or external) |

Keep Agent.`messaging_group` pointing at the typed Group. Do not invent chat
ids; leave `platform_chat_id` empty until a real Hermes room_id or platform id
is known.

## Fleet apply (incomplete Hermes config)

When the user asks to apply messaging for agents that already have Anytype
Groups:

### Bot Mode path (preferred)

1. Inventory live Groups + `hermes_profiles`.
2. For each Group with empty `platform_chat_id`: create hosted room(s) via
   `groups.create` (2–6; satellite B for overflow).
3. Write back `platform_chat_id` (+ `platform=hermes`, `notes` for satellites).
4. No Telegram tokens required.

### External platform path (only when asked)

1. Set mention gates on member profiles.
2. Set allowlists **only** when `platform_chat_id` is a real external id.
3. Never invent chat ids or clone tokens. Treat commented `# TELEGRAM_BOT_TOKEN=`
   as missing.

Earlier fleet pass (2026-11-05 morning): mention gates on ~50 profiles while
chat ids were still empty. Evening pass: Hermes hosted rooms + Anytype
writeback (this doc).

## Safety

- Confirm before creating many rooms, `--clone-channels`, or copying tokens.
- Prefer Hermes Bot Mode over inventing Telegram groups.
- Editing Anytype Group membership does not auto-update hosted room rosters;
  re-run `groups.create` / Desktop Manage members / `groups` member RPCs as
  needed.
- Parallel Anytype `create_missing_options` for the same select name creates
  duplicate options (ambiguous later). Mint `hermes` once, sequentially.
- During org redesign, document intended groups in Anytype and **defer** Hermes
  apply until the user asks.

## Docs

- https://hermes-agent.nousresearch.com/docs/user-guide/bot-mode (Groups and group chats)
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram
- Anytype side: skill `anytype-agents` → typed Group (`object-types.md`)
