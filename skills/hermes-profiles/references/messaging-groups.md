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

## Anytype: HQ Group vs Subteam Group (Subgroup)

Every **live** Agent should have Agent.`messaging_group` filled, except when the
user has **deferred** messaging for that HQ (org example: Foyer agents may have
empty `messaging_group` until rooms are requested again).

**Overflow rule (Bot Mode 2–6 seats):** do **not** create satellite `* B` rooms.
When an HQ roster would exceed 6 Hermes seats, split onto **Subteam Groups**:

1. HQ Group = chief + Subteam leads only (≤6)
2. Each Subteam that needs a chat gets its own typed Group (`parent_team` = HQ;
   Subteam.`messaging_group` → that Group)
3. Specialists: Agent.`messaging_group` → **Subteam Group** (not the HQ Group)
4. Solo Subteams (1 specialist): keep the lead on the HQ Group, or seat HQ chief
   as a bridge so the Subgroup has ≥2 Hermes members

**Join an existing Subteam/HQ Group** for new specialists under a Subteam that
already has a Group. Mint a new typed Group only for a new HQ or a Subteam that
does not yet have a room.

Gap inventory: `type: agent`, `lifecycle = "live"`, fields include
`messaging_group`. Empty → join Subteam Group (preferred) or HQ Group; skip only
when the user deferred that HQ’s messaging.

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
- When an HQ would exceed 6 seats: create **Subteam Groups** (see above). Never
  mint `*-group-b` / “satellite B” overflow rooms.
- Disbanded room ids **cannot be reused** (`groups.disband` retires the id). To
  resize a roster, create a new `room_id`, write back Anytype `platform_chat_id`,
  then disband the old room.

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
| `notes` | Apply notes; list linked Subteam Groups when HQ was split |

### Fleet example (2026-11-05 → 2026-11-06)

First pass created HQ rooms plus temporary satellite B overflow rooms. Refactor
replaced satellites with **Subteam Groups** (Development, Ops, Customer &
Analytics, Investments, Tax, Companies Finance, Personal Finance, HR, Legal,
Compliance, …), slimmed HQ Groups to chief + leads, removed Foyer Groups
(Ana/Kitchen/Wedding) per user deferral, and disbanded all `*-group-b` plus
Foyer Hermes rooms. Follow-up same day: Growth got Marketing / Sales &
Acquisition / Partnerships & BD Subteam Groups + `anytype-growth-group-leads`
(flat `anytype-growth-group` disbanded).

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

1. Inventory live Groups + `hermes_profiles` (each Group must be ≤6 slugs).
2. If an HQ roster is oversized: mint Subteam Groups first; slim HQ; never
   create satellite B rooms.
3. For each Group with empty `platform_chat_id`: `groups.create` (2–6).
4. Write back `platform_chat_id` + `platform=hermes`.
5. Disband obsolete rooms with `groups.disband` (`room_id` + `cancel_id`) after
   writeback (retired ids cannot be reused).

### External platform path (only when asked)

1. Set mention gates on member profiles.
2. Set allowlists **only** when `platform_chat_id` is a real external id.
3. Never invent chat ids or clone tokens. Treat commented `# TELEGRAM_BOT_TOKEN=`
   as missing.

Earlier fleet pass (2026-11-05 morning): mention gates on ~50 profiles while
chat ids were still empty. Evening pass: Hermes hosted rooms + Anytype
writeback (this doc).

## Room purpose, notes, and unaddressed routing (v0.23+)

After a room exists, set **purpose**, **shared notes**, and who answers when a
human message names nobody. Official Bot Mode docs:
https://hermes-agent.nousresearch.com/docs/user-guide/bot-mode#groups-and-group-chats

### Modes (gateway-owned rooms)

| `routing` | Behavior |
|-----------|----------|
| `everyone` | **Default.** Unaddressed human message wakes every member (normal rounds) |
| `lead` | Unaddressed message goes to the **lead** first; lead returns JSON `{"assign":["handle",…]}`; gateway records `room.assignment` and only chosen members answer. Lead alone if assign is empty |
| `auto` | **v0.23+.** Short tool-less router call over purpose + notes + member descriptions + recent messages; UI shows “Assigned to X”. Pin cheap model with `auxiliary.group_router`. Falls back to everyone on failure. Confirmed on installed Hermes **0.23.0** (`gateway/hosted_room_context.py` accepts `everyone`\|`lead`\|`auto`; `hosted_room_router.py` + `auxiliary.group_router`) |

@mentions, `@all` / `@everyone`, scheduled posts, and replies inside an existing
thread **skip** lead/auto routing.

### Apply via RPC (`groups.context`)

Same session WebSocket as `groups.create` (not `gateway.sock`):

```json
{
  "method": "groups.context",
  "params": {
    "room_id": "anytype-engineering-group",
    "purpose": "Engineering HQ coordination: chiefs + Subteam leads.",
    "notes": "Prefer @marcel for Dev, @gaston for Ops. Escalate Sev-1 to @etienne.",
    "routing": "lead",
    "lead_member_id": "etienne"
  }
}
```

Keys (from gateway `session_group_controls`): `room_id`, optional `event_id`,
`purpose`, `notes`, `routing`, `lead_member_id`. Desktop path: room header →
**Group settings** (purpose / notes / who answers).

Purpose and notes are injected into member turn prompts (user-role context), not
the system prompt. Keep them short; they feed lead (and auto) routing.

### Anytype decline

| Anytype Group field | Hermes |
|---------------------|--------|
| `mission` | Room `purpose` |
| `shared_notes` | Room `notes` |
| `unaddressed_routing` (`everyone` \| `lead` \| `auto`) | `routing` |
| `lead_agent` → Agent.`hermes_profile` | `lead_member_id` when routing=`lead` |
| `routing_summary` | Human one-liner; optional paste into notes |

Org default until the user picks otherwise: **`everyone`**. Strong-fit later:
HQ Groups → `lead` = HQ chief; dense Subteam Groups → try `auto` (pin `auxiliary.group_router`).

Optional: pin `auxiliary.group_router` on a parent / default profile when using
`auto` (Hermes model picker → auxiliary → Group router). Document intent on
Harness profile `aux_group_router_*`.

### Cron → room

Deliver a Schedule into a Bot Mode room (starts a round only for members the
output @mentions):

```bash
hermes -p <slug> cron create "0 9 * * 1-5" \
  "Post the Eng standup digest. @etienne @marcel" \
  --name eng-standup \
  --deliver "room:anytype-engineering-group"
```

Format from the `cronjob` tool: `room:<room_id>` (not a Telegram id). Use the
Anytype Group.`platform_chat_id` as `room_id`. See `cron.md`.

### Bot-to-bot loops

Bot Mode DMs use `message_agent`. Exchanges are capped after the last human
message (release notes: `max_hops` default **4**). External Telegram/Discord
still use `gateway.bot_loop_guard` (`enabled`, `max_events`, `window_seconds`,
`cooldown_seconds`) as in the Optional Telegram section above. Bots should not
ping each other in endless loops; prefer @mention scope in rooms.

### Multi-connection Desktop (short)

Desktop can keep several gateways connected. A room whose members are all on
the **active** connection is **gateway-owned** (keeps running when Desktop
closes). A room that **mixes** machines is Desktop-driven (classic). Prefer
same-gateway HQ/Subteam rooms for org apply. Docs: Bot Mode → rooms across
machines.

## Safety

- Confirm before creating many rooms, `--clone-channels`, or copying tokens.
- Prefer Hermes Bot Mode over inventing Telegram groups.
- Editing Anytype Group membership does not auto-update hosted room rosters;
  re-run `groups.create` / Desktop Manage members / `groups` member RPCs as
  needed.
- Changing `routing` / lead / purpose needs `groups.context` or Group settings;
  Anytype fields alone do not push.
- Parallel Anytype `create_missing_options` for the same select name creates
  duplicate options (ambiguous later). Mint `hermes` once, sequentially.
- During org redesign, document intended groups in Anytype and **defer** Hermes
  apply until the user asks.

## Docs

- https://hermes-agent.nousresearch.com/docs/user-guide/bot-mode (Groups and group chats)
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram
- Anytype side: skill `anytype-agents` → typed Group (`object-types.md`)
