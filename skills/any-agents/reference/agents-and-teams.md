# Agents and teams

## Creating a custom agent (overlay)

Host: **Mac / Linux**, anybao checkout.

1. Copy `repos/_agent` to a working tree (or edit in place for staging).
2. Follow `repos/CLAUDE.md`: programs under `programs/<name>@vN/`,
   skills under `skills/`; docstrings are the docs; `_`-prefix =
   system skills always in prompt; others on-demand via `get_skill`.
3. Change identity via `_soul` / `_core` skills and programs — do not
   invent host APIs.
4. Create a repo space and deploy:

```bash
A="${ANY_ADDR:-http://127.0.0.1:2046}"
REPO=$(curl -s -X POST "$A/v1/spaces" -H 'Content-Type: application/json' \
  -d '{"name":"_agentrepo"}' | jq -r .id)
./runtime/target/release/anyrt deploy --source repos/_agent --target "$REPO"
```

5. Point the overlay (owned space — no invite):

```toml
# anybao.toml
[overlays]
agent = "<REPO space id>"
```

6. Running `serve` loads the new hash on the **next conversation**.
   Restart only after `anyrt` binary / kernel changes.

Published production overlays use guest-key invites in the committed
`anybao.toml`. Staging often uses one account owning both overlay and
bao space (`docs/testing-agent-changes.md`).

### In-process subagents

`subagent@v1.delegate(space, task, opts?)` runs a quiet fresh
`toolcaller` in the **same** space (no chat post, no history). This is
delegation inside one agent — not a second team member process.

## How many agents per serve?

From the official anyrt quickstart:

> Agents on different devices of the account elect one active instance,
> so only one of them answers the chat. **Two agents against the same
> `any` server share its device identity and both answer — run one
> agent per server.**

| Pattern | Support |
|---------|---------|
| One `any` + one `anyrt serve` | Default; one bao working space |
| Same account, many devices | Election: one chat responder; pinned triggers on standby |
| Several overlays on one serve | One `agent` overlay alias + optional `connectors` (and more aliases for `use("alias:…")`) — still **one** chat agent identity |
| Second distinct agent on one machine | **Second `any` process** (own `--data-dir`, `--addr`) + second `anyrt serve` + own `anybao.toml` |
| Quiet child tasks | `subagent@v1` inside the same serve |

App slug for election is constant **`bao`** (ADR-015) — one account
runs one bao election identity. Extra agents need separate servers
(device keys) and usually separate working spaces / configs.

## Owner team model → anyrt

Map org intent (also used by `anytype-agents`) onto spaces and serves:

| Org concept | any / anyrt |
|-------------|-------------|
| Team HQ | One `any` **space** (name e.g. `hq-engineering`) holding that team's chat, triggers, memory objects |
| Shared Rules / shared skills | One **shared space** joined read-only (guest key or ACL reader) by every team serve; deploy skills/programs there; import via an overlay alias |
| Agent page (prompt, role, schedule, lessons) | Objects in the HQ space (pages / datasets) **plus** the agent overlay skills (`_soul`, operating notes) and `agent_triggers` rows |
| Live bot | One `anyrt serve` with `[agent] space = "<hq>"` (or derived `bao` for the personal agent) and `[overlays] agent = "<repo>"` |
| Bot-to-bot messages | Prefer **named chats** in a shared or HQ space; post with `any chat send` / `chat_send` under distinct `agent.name` values. Foreign agent names are treated as user-side input by the watcher (ADR-009) — useful as nudges. Cap hops in skill text (e.g. max 2) — **no built-in hop counter yet**; enforce in prompts/skills |
| Who may trigger whom | Event triggers on specific `chat_messages` objectIds (ADR-018); pin `owner` to the device that should run them |

Suggested layout:

```
account
├── space bao              # personal / primary agent (derived)
├── space hq-<team>        # per-team HQ
├── space org-shared       # Shared Rules + shared skills repo
├── space _agentrepo-<role># per-role code overlay (or one shared overlay with shadows)
└── processes
    ├── any :2046 + anyrt serve (primary)
    └── any :2047 + anyrt serve (second role)   # separate data-dir
```

UNVERIFIED: production multi-HQ fleet on one Hetzner host beyond the
"one serve per any server" rule — validate ports, disk, and election
noise before scaling.

## Aligning with anytype-agents

When the org roster lives in Anytype (`anytype-agents` skill):

1. Treat Anytype as **intent** (role, prompt, agenda, shared rules).
2. Apply only when the user asks (or after an accepted suggestion).
3. Map Agent.`system_prompt` → overlay `_soul` / skill text; Agenda →
   `agent_triggers`; Runtime catalog kind → document as `anyrt` (add a
   Runtime object with `runtime_kind` / slug when the org uses that
   catalog).
4. Do not auto-push Anytype edits into live serves.

## Check it worked

- `anyrt serving space=… chat=…` then `wait set clear — agent ready`
- Chat reply from the expected `agent.name`
- `anyrt trace ls --program toolcaller` shows the turn
- Second agent: separate listen port; messages in **its** space only
