---
name: anytype-agents
description: >
  Manage a multi-agent organization stored in Anytype (Agents hub, HQ pages,
  agent pages, groups, shared rules, skills, drafts) and related Projects via
  Anytype MCP. Discover structure by search; create/update/archive agents and
  teams without assuming a fixed space. Use when the user mentions Anytype
  Agents, HQ, Board, shared agent rules, agent prompts, roster routing, or
  Projects linked from agents. Use when the user runs /anytype-agents.
version: 1.26.0
license: MIT
metadata:
  category: agents
  domain: anytype
---

# Anytype Agents

Org source of truth for a multi-agent roster lives in **Anytype** as typed
objects (`agent`, `team`, `subteam`, `subagent`, `harness`, `harness_profile`,
`browser`, `computer`, `tool_profile`, `prompt`, `memory`, `skill`, `project`,
plus PM `epic` / `user_story` / extended `task`) plus supporting `page`s and
Skills **Queries**.
Runtime bots are separate: editing Anytype does not by itself update a live bot
prompt or messaging group. Verify runtime separately after doc changes. Model
stacks live on **Harness profile** objects; agents link `harness_profile` so one
profile edit covers many agents. Browser / computer / tool access live on
reusable **Browser**, **Computer**, and **Tool profile** catalog objects;
agents, teams, and subteams link them the same way. **Browser / Computer are
per-HQ:** each HQ owns one dedicated Cua Spaces computer and one Cua Chromium
browser; Subteams and Agents under that HQ link the same pair. Board and
Primary leave both empty (`computer_surface: none` on Primary). **Voice** (STT/TTS stack)
lives on **Harness profile**; Agent holds enablement / modes
(`voice_enabled`, `voice_auto_tts`, `voice_chat_mode`, `messaging_voice_mode`)
and optional STT/TTS overrides. Apply into Hermes via `hermes-profiles`
`voice.md`. **Most agents use Local router** (local model as parent brain;
default voice stack local Whisper + Edge TTS). Spawn routes live on
**Subagent** objects (Agent.`subagents` / Subagent.`parent_agent`) with richer
profiles (Coding, Data fetching, …); the local parent routes when needed and
answers peers itself otherwise. Decline into Hermes via `hermes-profiles`
`delegation.md`.

## References (load when needed)

| File | When |
|------|------|
| `references/structure.md` | Hub discovery and typical tree |
| `references/object-types.md` | Agent / Team / Subteam / Subagent / Harness / Harness profile / Browser / Computer / Tool profile / Project type keys, properties, migration |
| `references/type-templates.md` | Dumped default template bodies (incl. Subagent / Harness / runtime catalogs) for bootstrap and drift |
| `references/page-templates.md` | Agent / HQ / Subteam / group / skill / project body shapes |
| `references/suggested-runtime.md` | Suggested runtime field list (Hermes mapping; prefer Browser / Computer / Tool profile links) |
| `references/shared-rules-starter.md` | Bootstrap or refresh Shared Rules |
| `references/examples.md` | Fictional Northwind Labs org walkthrough |
| `references/handoff-templates.md` | Handoffs, briefs, welcome paste |
| `references/mcp-recipes.md` | MCP search/create/patch/archive patterns |
| `references/hq-runtime-pair.md` | Per-HQ Cua Spaces Computer + Cua Chromium Browser create, link, migrate |
| `references/project-pm.md` | Epic / User story / Task types, kinds (incl. spike), filtered Roadmap/Backlog/TODO Queries, migrate |
| `references/prompts.md` | Prompt type (system / welcome / shared_rules / library / draft), Agent.`system_prompt`, Group `welcome_prompt`, migrate |
| `references/memory-and-skills.md` | Memory + Skill types, Agent.`memory_pages` / `skills_page`, Skills Queries, migrate |

## Resolve space and roots

Do **not** hardcode space or object ids. Discover them each session:

1. List or search spaces with Anytype MCP (`API-search-global` / space list tools).
2. Prefer a space the user names, or the space from an `object.any.coop` / `anytype://` URL they paste.
3. Search that space for hubs named like **Agents** and **Projects** (exact titles may vary; confirm with the user if several match).
4. From the Agents page, follow linked Shared Rules, Skills, Primary, HQ, and Draft pages.
5. Cache ids only for the current task; re-search if a rename breaks a link.

MCP tools (names may be prefixed by the server): `API-search-space`, `API-get-object`,
`API-create-object`, `API-patch-object`, `API-delete-object`, `API-create-discussion`,
`API-list-widgets`, `API-list-types`, `API-get-type`, `API-create-type`,
`API-update-type`, `API-list-templates`, `API-create-template`.

Read with `format: "md"` for body; `outline: true` for structure; full object form when patching.
`format=md` and `outline` are mutually exclusive on get-object.

## Mental model

| Term | Meaning |
|------|---------|
| Agents | Root hub: shared rules, skills index, Primary, HQ index |
| HQ / Team | Typed `team` object (`kind`: Board / HQ / Group) under Agents |
| Subteam | Typed `subteam` object: domain / pod under an HQ (preferred over `team` + `kind: Sub-team`) |
| Subagent | Typed `subagent` object: spawn/route config (task_key, harness_profile, scope, tools) under an Agent |
| Harness | Typed `harness` catalog: Claude, Codex, Grok, GitHub Copilot, Muse, NVIDIA NIM, Local model |
| Harness profile | Typed `harness_profile`: Hermes-shaped model / fallback / aux stack; agents and subagents link here |
| Browser | Typed `browser` catalog: source + identity + headed; agents / teams / subteams link here |
| Computer | Typed `computer` catalog: surface + scope + desktop; agents / teams / subteams link here |
| Tool profile | Typed `tool_profile` catalog: toolsets + approvals + terminal; agents / teams / subteams link here |
| Agent | Typed `agent` object: role, memory links, skills, `harness_profile`, `subagents`, `system_prompt` → Prompt, runtime catalog links |
| Prompt | Typed `prompt` object: canonical system / welcome / shared_rules / library / draft text (`prompts.md`) |
| Memory | Typed `memory` object: decisions, lessons, resources, operating notes, playbooks (`memory-and-skills.md`) |
| Skill | Typed `skill` object: procedures / template / guides; indexes are Queries via `skills_page` |
| Group | Messaging roster notes (`page` + `welcome_prompt` → Prompt); membership text is not auto-synced to chat |
| Shared Rules | Mandatory rules every agent must follow (type `prompt`, `prompt_kind=shared_rules`) |
| Skills | Typed procedures + owner Queries; resolve most-specific first: Agent → Subteam → Team → Project → Global |
| Drafts | Agent designs not live until approved (often type `prompt` with `prompt_kind=draft`) |
| Projects | Portfolio roots as typed `project`; children often stay `page` |
| Epic / User story / Task | PM work items; Roadmap / Backlog / TODO Queries filter by `linked_projects` (`project-pm.md`; Task `kind` includes `spike`) |
| Primary | Coordinator agent; usually the only path to the human for escalations |
| Human | The operator |

Typical hierarchy: `Human ↔ Primary → HQ chiefs → specialists`.

Durable state in Anytype; item-scoped dialogue often lives in page/card comments when the shared rules say so.

## Discover first

Before mutating:

1. Open Agents root (`format: "md"`)
2. `API-search-space` for the agent / HQ / project name
3. Open the roster/routing page if one exists under Primary (or equivalent)
4. For delivery work, open `Projects → [Project] →` project-management / TODO pages and any execution-policy notes

Never invent roster membership, legal conclusions, or financial numbers. Prefer existing linked pages over duplicates.

## Read playbooks

### Show org / route a task

1. Read Agents, roster/routing, and any delegation playbook under Primary
2. Route through the owning HQ chief documented on those pages
3. Do not bypass a chief to task their specialists unless the docs explicitly allow it
4. Escalate to the human only via Primary when that is the standing rule

### Show an agent

1. Prefer `API-search-space` with `"type": "agent"` (or search by display name / role)
2. Read: short description, suggested runtime, linked **System prompt** Prompt, memory links, skills
3. Note featured properties (`role`, `lifecycle`, `harness_profile`, `subagents`, `system_prompt`, `browser`, `computer`, `tool_profile`, `autonomy`, …) and body sections

### Show a project (agent context)

1. Prefer `"type": "project"` search, or open Projects hub then the project
2. Typical children: technical, business, project management, product, design, marketing
3. Project management links **Roadmap / Backlog / TODO** Queries (Epic / User story / Task filtered by `linked_projects`); see `project-pm.md`
4. Agents pull execution policy, TODO contracts, and design-done evidence from here when the org uses those gates

## Write playbooks

Confirm with the user before creating chiefs, Board seats, shared-rule edits, archives, or live routing changes.

### Create or update an agent

1. Confirm HQ, reporting line, **Harness profile** (prefer **Local router**), Subagents, and draft vs live
2. Drafts: place under the drafts hub; wait for approval before treating as live
3. Create type **`agent`** (not `page`) using `references/object-types.md` + body from `page-templates.md`; leave `template` unset to use **Agent default**
4. Set properties (structured facts live here, not only in markdown): `role`, `lifecycle`, `harness_profile` (Local router), optional `subagents`, `team` / `reports_to`, `autonomy`, `short_description`, `hermes_profile`, `board_member`, `map_path`, `delegation_enabled`, `browser` / `computer` / `tool_profile` (catalog links; org defaults: Computer + Browser = owning HQ's `{HQ} – Cua Spaces` / `{HQ} – Cua Chromium` pair; Tool profile **Standard interactive**; Primary / Board leave browser+computer empty), `terminal_backend` / `computer_surface` (keep aligned with linked Computer / Tool profile; org defaults `cua` / `cua-spaces`; Primary uses `computer_surface: none`), voice fields (`voice_enabled`, `voice_auto_tts`, `voice_chat_mode`, `messaging_voice_mode`, optional `stt_*` / `tts_*` overrides; prefer Harness profile STT/TTS stack), optional `linked_projects` / `memory_pages` / `skills_page` / `messaging_group`
5. Create a **Prompt** (`prompt_kind=system`) with the full system / SOUL text; set Agent.`system_prompt` to it (`prompts.md`). Agent body keeps Suggested runtime + a short System prompt pointer (no Full System Prompt fence)
6. Create **Memory** objects (Memory & Decisions, Lessons Learned, Resources, Operating Notes) and a Skills **Query**; link via `memory_pages` + `skills_page` (`memory-and-skills.md`)
7. Link from the HQ map / Subteam; keep Agent.`team` pointing at the Subteam or HQ
8. Inside the Prompt body, point at Shared Rules (short pointer, not a full paste, when token economy matters)
9. Fill **Suggested runtime** from `suggested-runtime.md` for narrative apply notes; prefer properties + catalog links (`harness_profile`, `browser`, `computer`, `tool_profile`, `subagents`, voice fields) over markdown-only Browser / Computer / Tools / Voice bullets
10. Tell the user Anytype is updated; **copy the linked Prompt into the runtime bot** and verify groups/routines separately
11. If the runtime is Hermes, continue with skill `hermes-profiles` and apply Suggested runtime using its refs (`models.md`, `delegation.md`, `soul-templates.md`, `memory.md`, `browser-and-computer.md`, `runtime-limits-and-tools.md`, `security.md`, `workspace.md`, `display.md`, `voice.md`, `cron.md`)

### Create or update a Team / HQ

1. Create type **`team`** with `kind` (`Board` / `HQ` / `Group`) and `lifecycle`
2. Set `chief`, `members`, `subteams`, `mission`, `routing_summary`, optional `messaging_group` / `skills_page`, plus optional `browser` / `computer` / `tool_profile` team defaults
3. Body from `page-templates.md` / **Team default** for rules and long notes only (avoid duplicating mission/members/routing already in properties)
4. Link from Agents
5. Update roster/routing and Board/group welcome text if membership changes

### Create or update a Subteam

1. Prefer type **`subteam`** (do not create new Sub-teams as `team` with `kind: Sub-team`)
2. Set `parent_team` to the owning HQ, plus `lifecycle`, `members`, `routing_summary`, optional `chief` / `mission` / `messaging_group` / `skills_page`, plus optional `browser` / `computer` / `tool_profile` domain defaults
3. Body from `page-templates.md` / **Subteam default** template (properties first)
4. Link from the HQ `subteams` property and map; point member agents' `team` at this Subteam when they sit under it
5. Migrate legacy `team` + `kind: Sub-team` with `set_type` → `subteam` (`object-types.md`)

### Create or update a Subagent

1. Create type **`subagent`** with `parent_agent`, `task_key`, `harness_profile`,
   `intent`, optional `scope` / `toolsets` / `spawn_effort` / `model_override` / `deliver_back`
2. Body from `type-templates.md` / **Subagent default**
3. Add the Subagent id to the parent's Agent.`subagents` (keep both links)
4. Document the route under the parent's Suggested runtime Subagents section
5. If Hermes: decline into `model_map` via `hermes-profiles` `delegation.md`

### Create or update a Harness / Harness profile

1. **Harness** (catalog): type `harness` with `slug` in
   `claude` | `codex` | `grok` | `github-copilot` | `muse` | `nvidia-nim` | `local-model`
2. **Harness profile** (stack): type `harness_profile` with Hermes-shaped fields:
   `model_provider` / `model_default` / `model_effort` / `model_harness`,
   `fallback_1_*` / `fallback_2_*`, `aux_<task>_*` for vision / compression /
   web_extract / skills_hub / title_generation, and optional voice stack
   (`stt_*` / `tts_*` / `voice_notes`). **Local router** org default:
   `llamacpp` / `d1-2b-q4_k_m` + STT `local`/`base` + TTS `edge`/`en-US-AriaNeural`.
   Subagent-only stacks leave STT/TTS as `none` and aux at `auto`
3. Bodies from `type-templates.md`; link profiles from Agents → Shared
4. Point agents (and Subagents) at a profile via `harness_profile` (no Agent `harness` select)
5. After editing a shared profile, re-apply models **and voice** into each linked agent's
   live runtime (`hermes-profiles` `models.md` + `voice.md`)

### Create or update Browser / Computer / Tool profile

1. Prefer **Catalog + links**: create typed objects, then link from Agent / Team /
   Subteam (`browser`, `computer`, `tool_profile`)
2. **Per-HQ Browser + Computer (org convention):** full create/link/migrate
   playbook in `hq-runtime-pair.md`. When adding an HQ, create one Computer
   (`{hq-slug}-cua-spaces`, `computer_surface: cua-spaces`,
   `computer_scope: dedicated`, `desktop_enabled: true`) and one Browser
   (`{hq-slug}-cua-chromium`, `browser_source: local-chromium`,
   `browser_identity: dedicated-throwaway`). Name them `{HQ name} – Cua Spaces`
   and `{HQ name} – Cua Chromium`. Link that pair on the HQ, every Subteam under
   it, and every Agent under it. Board and Primary leave `browser` / `computer`
   empty (Primary also `computer_surface: none`). Do not create shared org-wide
   None / Host / Bot Screen catalog rows unless the user asks for an exception.
3. **Browser** (`browser`): `slug`, `access_needed`, `browser_source`, `browser_identity`,
   optional `headed` / `cloud_provider` / `docs_url` / `notes`
4. **Computer** (`computer`): `slug`, `access_needed`, `computer_surface`, `computer_scope`,
   optional `permission_mode` / `desktop_enabled` / `docs_url` / `notes`
5. **Tool profile** (`tool_profile`): `slug`, `intent`, `enabled_toolsets`,
   `disabled_toolsets`, `tool_approvals`, `cron_approvals`, optional `hard_deny` /
   `terminal_backend` / `terminal_cwd` / `timeout_seconds` / `notes` (still a
   shared org catalog: Standard interactive / Coding / Data fetching / Read-only)
6. Bodies from `type-templates.md`; keep catalogs under Agents → Shared (or a
   Runtime index). After editing a catalog object, re-apply into each linked
   agent's live runtime (Hermes: `browser-and-computer.md`,
   `runtime-limits-and-tools.md`)
7. Fill conventions: Computer + Browser → owning HQ pair; Tool profile →
   **Standard interactive** (Engineering → **Coding**; fetch/veille →
   **Data fetching**)

### Create or update a Project portfolio root

1. Create (or migrate) type **`project`** with `project_status`, `project_category`, `owning_team`, `one_liner`, `overview`, `execution_policy`, optional `lead_agent` / `related_projects` / `git_hub` / `public_url`, and child hub links (`technical_page`, `product_page`, `pm_page`, …)
2. Use **Project default** template / `page-templates.md` for long body sections only
3. Link from Projects hub; keep child docs as `page` unless the org types them too
4. Under `pm_page`, use filtered Queries named Roadmap / Backlog / TODO (Epic / User story / Task). Full create / migrate: `project-pm.md`

### Create Epic / User story / Task

1. Set `linked_projects` to the project so the item appears in that project's Query
2. Task: set `kind` (`bugfix` | `implementation` | `doc` | `design` | `review` | `chore` | `spike`)
3. Optional hierarchy: Epic ← User story (`parent_epic`) ← Task (`parent_user_story`)
4. Bodies from Epic / User story defaults in `type-templates.md`; Task uses built-in todo layout
5. Recipes: `mcp-recipes.md` + `project-pm.md`

### Edit Shared Rules

1. Read the current Shared Rules object fully (type `prompt`, `prompt_kind=shared_rules`)
2. Primary (or the documented owner) runs rollout: edit rules → per-agent checklist → completion log
3. Confirm before changing HARD / standing rules
4. Doc edit alone does not refresh live prompts (re-copy from linked Agent Prompts when applying)

### Create or update a Prompt

1. Choose `prompt_kind` (`system` / `welcome` / `shared_rules` / `library` / `draft` / `other`)
2. Create type `prompt` (or `set_type` an existing page in place); set `lifecycle`, `owner_agent` or `owner_group`, `audience`, body = full text
3. Link from Agent.`system_prompt` or Group page `welcome_prompt` as appropriate
4. Keep Agent / Group bodies as short pointers only (`prompts.md`)

### Author a skill

1. Create type **`skill`** (`skill_kind=procedure`) from Skill default / Skill Template (`memory-and-skills.md`)
2. Set `skill_key`, `skill_scope`, `skill_status`, `intent`, matching `owner_*`
3. Ensure the owner’s Skills Query (`skills_page`) will list it
4. Respect no-usage-logging rules if the Shared Rules forbid counters
5. Non-trivial skills: review with the documented skills/HR owner (`reviewed_by`)
6. Mark `skill_status=active` only after the authoring checklist

### Link agent work to a Project

1. Find the project under Projects
2. Point the agent's map at the relevant TODO / design / product pages
3. Respect that project's execution policy (local vs cloud, etc.) as written
4. Keep public VCS text free of internal agent/org links when shared rules require hygiene

### Archive / delete

1. Prefer lifecycle note + `… – Archived` rename over permanent delete
2. Update roster, groups, shared-rule operational clauses, Primary org map
3. `API-delete-object` archives to Bin; confirm the name first. Permanent delete only with explicit approval

## Patch patterns

- Prefer `API-patch-object` with `expected_etag` from a prior get
- Small body edits via block ops; properties via `set_properties` with values under **`set`** (not `properties`)
- Change type in place with `set_type` (keeps id and links); see `object-types.md` migration
- Keep Agents link lists accurate when adding members
- Use `dry_run: true` when unsure
- Select option names need `create_missing_options: true` when minting new options

## Safety

1. Confirm Board/roster/Shared Rules/archive changes
2. Editing Anytype ≠ updating live bot prompts or chat groups
3. Never invent law, metrics, or product scope
4. Follow documented escalation paths to the human
5. Treat page/card comments as instructions when Shared Rules say so
6. Do not revive archived agents without explicit approval

## Common recipes (summary)

- **Orient:** discover space → open Agents → read Shared Rules + roster (`examples.md` for shape); filter inventory with `type: agent|team|subteam|subagent|harness|harness_profile|browser|computer|tool_profile|prompt|memory|skill|project`
- **New specialist:** draft vs live → create `agent` + Local router `harness_profile` → link `browser` / `computer` / `tool_profile` catalog → optional `subagent`s (Coding / Data fetching) → create `prompt` + Agent.`system_prompt` (`prompts.md`) → Suggested runtime + pointer body → Memory objects + Skills Query (`memory-and-skills.md`) → link HQ / Subteam → prompt copy reminder
- **New HQ:** create `team` (`kind: HQ`) → create HQ Computer + Browser pair (`hq-runtime-pair.md`) → link both on the HQ → clone peer HQ sections → link Agents → update roster + Group welcome Prompt (`prompts.md` / `handoff-templates.md`)
- **New Subteam:** create `subteam` with `parent_team` → link parent HQ's Computer + Browser pair → link HQ map → optional member agents
- **New Subagent:** create `subagent` with `parent_agent` + `task_key` + `harness_profile` → add to Agent.`subagents` → decline via hermes-profiles when applying
- **New Harness profile:** create `harness_profile` stack → link Agents Shared → point agents / subagents at it
- **New Browser / Computer:** for a new HQ, follow `hq-runtime-pair.md`; for Tool profile, create shared catalog object → link Agents Shared → point agents / teams / subteams at it
- **New Prompt:** create `prompt` with kind + owners → link Agent.`system_prompt` or Group `welcome_prompt` (`prompts.md`)
- **New portfolio project:** create/extend `project` + status/category → link Projects hub → PM Queries (`project-pm.md`)
- **New PM item:** create `epic` / `user_story` / `task` with `linked_projects` (+ Task `kind`, incl. `spike`)
- **Migrate old pages:** `set_type` + `set_properties.set` on hub inventory only (`object-types.md`); PM collections → typed + Queries (`project-pm.md`); agent/group fences → Prompt objects (`prompts.md`)
- **Shared Rules change:** edit Prompt → rollout checklist (`shared-rules-starter.md`) → runtime refresh reminder
- **MCP ops:** follow `mcp-recipes.md` with etags and dry-run when unsure

## Workflow checklist

1. Resolve space + discover Agents/Projects roots
2. Read roster/routing before ownership changes
3. Create/patch using templates / MCP recipes
4. Link from parent HQ / Agents / Skills hub
5. Report object ids/URLs and remaining runtime verification
6. If Hermes runtime: continue with `hermes-profiles`
