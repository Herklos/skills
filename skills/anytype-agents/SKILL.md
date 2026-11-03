---
name: anytype-agents
description: >
  Manage a multi-agent organization stored in Anytype (Agents hub, HQ pages,
  agent pages, groups, shared rules, skills, drafts) and related Projects via
  Anytype MCP. Discover structure by search; create/update/archive agents and
  teams without assuming a fixed space. Use when the user mentions Anytype
  Agents, HQ, Board, shared agent rules, agent prompts, roster routing, or
  Projects linked from agents. Use when the user runs /anytype-agents.
version: 1.9.2
license: MIT
metadata:
  category: agents
  domain: anytype
---

# Anytype Agents

Org source of truth for a multi-agent roster lives in **Anytype** as typed
objects (`agent`, `team`, `project`) plus supporting `page`s. Runtime bots (chat
harnesses, CLIs, local agents) are separate: editing Anytype does not by itself
update a live bot prompt or messaging group. Verify runtime separately after doc
changes.

## References (load when needed)

| File | When |
|------|------|
| `references/structure.md` | Hub discovery and typical tree |
| `references/object-types.md` | Agent / Team / Project type keys, properties, templates, migration |
| `references/page-templates.md` | Agent / HQ / group / skill / project body shapes |
| `references/shared-rules-starter.md` | Bootstrap or refresh Shared Rules |
| `references/examples.md` | Fictional Northwind Labs org walkthrough |
| `references/handoff-templates.md` | Handoffs, briefs, welcome paste |
| `references/mcp-recipes.md` | MCP search/create/patch/archive patterns |

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
| HQ / Team | Typed `team` object (Board / HQ / Sub-team / Group) under Agents |
| Agent | Typed `agent` object: role, system prompt, memory links, skills |
| Group | Messaging roster notes; membership text is not auto-synced to chat |
| Shared Rules | Mandatory rules every agent must follow (`page`) |
| Skills | Procedures (`page`); resolve most-specific first: Agent → Team → Project → Global |
| Drafts | Agent designs not live until approved |
| Projects | Portfolio roots as typed `project`; children often stay `page` |
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
2. Read: short description, suggested runtime, full system prompt, memory links, skills
3. Note featured properties (`role`, `lifecycle`, `harness`, `autonomy`, …) and body sections

### Show a project (agent context)

1. Prefer `"type": "project"` search, or open Projects hub then the project
2. Typical children: technical, business, project management, product, design, marketing
3. Project management often links roadmap, backlog, TODO
4. Agents pull execution policy, TODO contracts, and design-done evidence from here when the org uses those gates

## Write playbooks

Confirm with the user before creating chiefs, Board seats, shared-rule edits, archives, or live routing changes.

### Create or update an agent

1. Confirm HQ, reporting line, runtime harness, and draft vs live
2. Drafts: place under the drafts hub; wait for approval before treating as live
3. Create type **`agent`** (not `page`) using `references/object-types.md` + body from `page-templates.md`; leave `template` unset to use **Agent default**
4. Set properties: `role`, `lifecycle`, `harness`, `team` / `reports_to` when known, `autonomy`, optional `hermes_profile` / `primary_model` / `short_description`
5. Create memory children as `page` (at least Skills; chiefs often also Memory & Decisions, Operating Notes, Resources, Lessons Learned)
6. Link from the HQ map / sub-team page
7. Point the system prompt at Shared Rules (short pointer, not a full paste, when token economy matters)
8. Fill **Suggested runtime** with primary, fallback, auxiliary, subagents, MoA, **personality**, **memory**, **browser / computer**, **tools / terminal / limits**, **security / privacy / restoration**, **workspace / display**, and **Scheduled tasks** fields when known (see `page-templates.md`)
9. Tell the user Anytype is updated; **copy the Full System Prompt into the runtime bot** and verify groups/routines separately
10. If the runtime is Hermes, use `hermes-profiles` for the profile home and apply Suggested runtime into `model` / `auxiliary` / `fallback_providers` / `delegation` / `moa` / `SOUL.md` / `display.*` / `agent.personalities` / `memory.*` / `browser.*` / `computer_use.*` / `bot_desktop.*` / `toolsets` / `approvals.*` / `terminal.*` / `desktop.*` / `tool_output.*` / `agent.max_turns` / `compression.*` / `security.*` / `privacy.*` / `checkpoints.*` / `hermes project …` / `cron.*` + `hermes cron …` (`hermes-profiles` → `models-and-delegation.md`, `soul-templates.md`, `memory.md`, `browser-and-computer.md`, `runtime-limits-and-tools.md`, `security.md`, `workspace-and-display.md`, `cron.md`)

### Create or update a Team / HQ

1. Create type **`team`** with `kind` (`Board` / `HQ` / `Sub-team` / `Group`) and `lifecycle`
2. Mirror an existing HQ's body sections (mission, sub-teams, routing, rules, map) from `page-templates.md` / **Team default** template
3. Set `chief`, `parent_team`, `mission` when known
4. Link from Agents
5. Update roster/routing and Board/group welcome text if membership changes

### Create or update a Project portfolio root

1. Create (or migrate) type **`project`** with `project_status`, `project_category`, optional `owning_team` / `git_hub` / `public_url` / `one_liner`
2. Use **Project default** template / `page-templates.md` for body
3. Link from Projects hub; keep child docs as `page` unless the org types them too

### Edit Shared Rules

1. Read the current Shared Rules page fully
2. Primary (or the documented owner) runs rollout: edit rules → per-agent checklist → completion log
3. Confirm before changing HARD / standing rules
4. Doc edit alone does not refresh live prompts

### Author a skill page

1. Follow the Skill Template in the space (or `references/page-templates.md`)
2. Place under agent / team / project / global Skills as appropriate
3. Respect no-usage-logging rules if the Shared Rules forbid counters
4. Non-trivial skills: review with the documented skills/HR owner
5. Mark active only after the authoring checklist

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

- **Orient:** discover space → open Agents → read Shared Rules + roster (`examples.md` for shape); filter inventory with `type: agent|team|project`
- **New specialist:** draft vs live → create `agent` + properties (`object-types.md`) → body from `page-templates.md` → memory `page`s → link HQ → prompt copy reminder
- **New HQ:** create `team` (`kind: HQ`) → clone peer HQ sections → link Agents → update roster + Group welcome (`handoff-templates.md`)
- **New portfolio project:** create/extend `project` + status/category → link Projects hub
- **Migrate old pages:** `set_type` + `set_properties.set` on hub inventory only (`object-types.md`)
- **Shared Rules change:** edit → rollout checklist (`shared-rules-starter.md`) → runtime refresh reminder
- **MCP ops:** follow `mcp-recipes.md` with etags and dry-run when unsure

## Workflow checklist

1. Resolve space + discover Agents/Projects roots
2. Read roster/routing before ownership changes
3. Create/patch using templates / MCP recipes
4. Link from parent HQ / Agents / Skills hub
5. Report object ids/URLs and remaining runtime verification
6. If Hermes runtime: continue with `hermes-profiles`
