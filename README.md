# Agent-ops skills

Two companion skills for running a multi-agent org: **Anytype** as the org source of truth, **Hermes** as the runtime home for each bot. Compatible with Claude Code, Cursor, Codex, and other skills installers.

| Skill | Version | Role |
|-------|---------|------|
| [hermes-profiles](./skills/hermes-profiles/SKILL.md) | 1.26.0 | Lifecycle and config for Hermes Agent profiles |
| [anytype-agents](./skills/anytype-agents/SKILL.md) | 1.35.0 | Org roster, typed inventory, Prompts, suggestions, and Projects via Anytype MCP |

Use them together when an agent page in Anytype should decline into a live Hermes profile. Editing Anytype does not push configs; apply with `hermes-profiles` after an accepted suggestion or when the user asks.

---

## hermes-profiles

Manage Hermes Agent **profiles**. A profile is one agent's home directory under `~/.hermes/profiles/<slug>/` (or `$HERMES_HOME`): config, SOUL, memory, skills, sessions, cron, and gateway state. Bot Mode bots are the same profiles with roster metadata.

**What it covers**

- **Lifecycle** via the `hermes` CLI: create, clone, list, show, describe, rename, delete, export/import, install distributions, aliases, sticky `profile use`
- **Identity**: durable `SOUL.md`, optional `/personality` overlay, custom presets
- **Models**: main / decision / routing model (including local `llamacpp`), auxiliary tasks, fallback providers, MoA
- **Delegation**: `advanced-delegation` + `model_map` / profile routes so a parent routes specialized work to Subagents
- **Memory**: per-profile `MEMORY.md` / `USER.md`, write approval, optional external provider
- **Browser and computer**: default computer is **Cua Spaces** (`terminal.backend: cua`); Anytype per-HQ Computer/Browser pairs decline into a stable HQ Space + Chromium in that Space; host desktop and Linux Bot Screen as exceptions
- **Tools and limits**: toolsets, approvals, terminal backend, output/turn/compression caps
- **Security**: approvals / YOLO floor, privacy redaction, pairing, checkpoints and rollback, backup
- **Workspace and display**: `terminal.cwd`, projects, repo scan, skins, Desktop prefs; Bot Mode Edit Profile Description vs roster card chat preview (`profile-map.md`)
- **Voice**: mic loop + STT + TTS (`voice.*` / `stt.*` / `tts.*`); messaging `/voice`; Discord voice channel. Defaults: local Whisper + Edge TTS
- **Cron**: scheduled jobs and Bot routines per profile; Anytype Agenda → Hermes bind when asked
- **Messaging groups**: multi-bot Telegram/Discord rooms from Anytype typed Group
- **Gateway**: start/stop/install one messaging gateway per profile (one bot token each)
- **Suggestions gate**: apply Anytype harness / Subagent / model changes only after an accepted `suggestion` (or explicit ask)

**References** (loaded on demand): `profile-map`, `models`, `delegation`, `soul-templates`, `memory`, `browser-and-computer`, `runtime-limits-and-tools`, `security`, `workspace`, `display`, `voice`, `cron`, `messaging-groups`, `recipes`, `troubleshooting`.

**Typical flows**

- New specialist: `create` → `setup` → set `terminal.cwd` → edit SOUL → `doctor`
- Twin of an existing agent: `create <new> --clone-from <src>`
- Messaging bot: unique token in that profile `.env` → `gateway start` / `install`
- Apply Anytype Suggested runtime: matching refs (`models.md`, `delegation.md`, `voice.md`, …) after accepted suggestion or user ask

Docs: [Hermes profiles](https://hermes-agent.nousresearch.com/docs/user-guide/profiles) · Skill: [`skills/hermes-profiles/SKILL.md`](./skills/hermes-profiles/SKILL.md)

---

## anytype-agents

Manage a multi-agent **organization in Anytype** through the Anytype MCP. The Agents hub holds typed inventory; Projects hold portfolio work. Discover the space each session (no hardcoded ids). Runtime bots stay separate until you apply with `hermes-profiles`.

**Typed inventory**

| Type | Purpose |
|------|---------|
| `agent` | Role, memory links, `harness_profile`, Subagents, `system_prompt` → Prompt, browser/computer/tool links, voice modes |
| `team` | Board / HQ / Group (`kind`) |
| `subteam` | Domain / pod under an HQ (preferred over legacy Sub-team teams) |
| `subagent` | Spawn/route config under an Agent (`task_key`, harness, scope, tools) |
| `harness` | Product catalog (Claude, Codex, Grok, Copilot, Muse, NIM, Local model) |
| `harness_profile` | Reusable primary + backup model stack, optional decision model, shared STT/TTS |
| `browser` / `computer` / `tool_profile` | Runtime catalogs; Browser/Computer are per-HQ (Cua pair); Tool profiles are shared; agents/teams/subteams link them |
| `prompt` | System / welcome / shared_rules / library / draft text; Agents and Groups link them |
| `memory` / `skill` / `log` / `suggestion` / `schedule` | Memory pages, skill catalog, activity logs, improvement feedback, Agenda jobs |
| `group` | Messaging room roster + welcome Prompt + platform gates |
| `project` | Portfolio root with status, owning team, execution policy, child hub links |

Shared Rules is type `prompt`. Skills resolve Agent → Subteam → Team → Project → Global. Suggestions index via Agent.`suggestions_page` (Shared Rule 25; Agathe weekly + ad-hoc).

**What it covers**

- Discover Agents / Projects hubs, roster, and routing without assuming a fixed space
- Create and patch agents, HQs, Subteams, Subagents, harness stacks, and runtime catalogs
- Property-first design: structured facts on typed objects; body templates for long narrative only
- Suggested runtime mapping into Hermes (models, delegation, browser/computer, tools, voice, cron)
- Shared Rules rollout, Prompt objects for system/welcome text, handoff / welcome paste, MCP search/create/patch recipes
- Safety: confirm Board/roster/archive changes; Anytype edits do not refresh live prompts by themselves

**Org defaults (documented in the skill)**

- Most agents link **Local parent** (Ollama `lfm3` chat + llamacpp `d1` approval; spawn Subagents for specialized routes). Exceptions: Foyer, CLASQUIN
- Computer + Browser → owning HQ's `{HQ} – Cua Spaces` / `{HQ} – Hermes Chromium` pair (Board/Primary leave both empty); Tool profile → Standard interactive
- Voice stack on Local parent / Foyer: local Whisper + Edge TTS; Agent holds enablement / modes
- Canonical system / welcome text on typed **Prompt** objects; Agent.`system_prompt` and Group `welcome_prompt` link them; agent bodies keep short pointers
- Improvement feedback as typed **`suggestion`**; no Hermes auto-apply

**References** (loaded on demand): `structure`, `object-types`, `type-templates`, `page-templates`, `suggested-runtime`, `shared-rules-starter`, `examples`, `handoff-templates`, `mcp-recipes`, `hq-runtime-pair`, `cua-hq-spaces`, `prompts`, `memory-and-skills`, `suggestions`, `agenda-and-schedules`, `hq-standing-instructions`, `project-pm`.

**Typical flows**

- Orient: discover space → open Agents → read Shared Rules + roster
- New specialist: create `agent` + Local parent → link owning HQ Computer/Browser pair + tool profile → role-pack Subagents → create Prompt + `system_prompt` → Memory + Skills/Logs/Agenda/Suggestions Queries → link HQ/Subteam
- New Suggestion: create `suggestion` → Inbox / owner Query → approve agent+chief (P org-wide)
- Hermes apply: continue with `hermes-profiles` after accepted suggestion or explicit ask

Skill: [`skills/anytype-agents/SKILL.md`](./skills/anytype-agents/SKILL.md)

---

## How they fit

```
Anytype (org truth)          Hermes (runtime)
─────────────────            ────────────────
agent + harness_profile  →   profile config / models / voice
agent.system_prompt      →   SOUL / system prompt copy
subagent routes          →   delegation model_map
browser / computer / tools → browser-and-computer, runtime-limits
suggestion (accepted)    →   gate for apply via hermes-profiles refs
schedule / agenda        →   cron jobs (when asked)
group                    →   messaging-groups (when asked)
```

`anytype-agents` designs and stores the roster. `hermes-profiles` creates and configures the live homes. Keep them in sync deliberately; the skills never auto-push one into the other.

---

## Installation

### Claude Code (marketplace)

```bash
claude plugin marketplace add Herklos/skills
claude plugin install agent-ops-skills@herklos-skills
# or: hermes-profiles@herklos-skills / anytype-agents@herklos-skills
```

### Other installers

```bash
# ai-agent-skills
npx ai-agent-skills install Herklos/skills

# Manual copy into a harness skills folder
cp -r skills/hermes-profiles ~/.claude/skills/
cp -r skills/anytype-agents ~/.claude/skills/
```

Cursor: install from the marketplace UI, or use `.agents/plugins/marketplace.json` in this repo. Local Claude plugin dir: `git clone` then `claude --plugin-dir ./skills`.

Validate: `claude plugin validate .`

## License

MIT. See [LICENSE](./LICENSE).
