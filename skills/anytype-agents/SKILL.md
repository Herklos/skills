---
name: anytype-agents
description: >
  Manage a multi-agent organization stored in Anytype (Agents hub, HQ pages,
  agent pages, groups, shared rules, skills, drafts) and related Projects via
  Anytype MCP. Discover structure by search; create/update/archive agents and
  teams without assuming a fixed space. Use when the user mentions Anytype
  Agents, HQ, Board, shared agent rules, agent prompts, roster routing, or
  Projects linked from agents. Use when the user runs /anytype-agents.
version: 1.7.0
license: MIT
metadata:
  category: agents
  domain: anytype
---

# Anytype Agents

Org source of truth for a multi-agent roster lives in **Anytype** as linked
**pages** (and optionally `project` objects). Runtime bots (chat harnesses, CLIs,
local agents) are separate: editing Anytype does not by itself update a live bot
prompt or messaging group. Verify runtime separately after doc changes.

## References (load when needed)

| File | When |
|------|------|
| `references/structure.md` | Hub discovery and typical tree |
| `references/page-templates.md` | Agent / HQ / group / skill / project shapes |
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
`API-list-widgets`, `API-list-types`.

Read with `format: "md"` for body; `outline: true` for structure; full object form when patching.

## Mental model

| Term | Meaning |
|------|---------|
| Agents | Root hub: shared rules, skills index, Primary, HQ index |
| HQ | Team page under Agents |
| Agent page | One bot's home: role, system prompt, memory links, skills |
| Group | Messaging roster notes; membership text is not auto-synced to chat |
| Shared Rules | Mandatory rules every agent must follow |
| Skills | Procedures; resolve most-specific first: Agent → Team → Project → Global |
| Drafts | Agent designs not live until approved |
| Projects | Portfolio/delivery hub agents execute against (backlog, TODO, design, policy) |
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

1. Search by display name / role title
2. Read: short description, suggested runtime, full system prompt, memory links, skills
3. Note autonomy and lifecycle/history sections when present

### Show a project (agent context)

1. Open Projects hub, then the project page
2. Typical children: technical, business, project management, product, design, marketing
3. Project management often links roadmap, backlog, TODO
4. Agents pull execution policy, TODO contracts, and design-done evidence from here when the org uses those gates

## Write playbooks

Confirm with the user before creating chiefs, Board seats, shared-rule edits, archives, or live routing changes.

### Create or update an agent page

1. Confirm HQ, reporting line, runtime harness, and draft vs live
2. Drafts: place under the drafts hub; wait for approval before treating as live
3. Create type `page` using `references/page-templates.md`
4. Create memory children (at least Skills; chiefs often also Memory & Decisions, Operating Notes, Resources, Lessons Learned)
5. Link from the HQ map / sub-team page
6. Point the system prompt at Shared Rules (short pointer, not a full paste, when token economy matters)
7. Fill **Suggested runtime** with primary, fallback, auxiliary, subagents, MoA, **personality**, **memory**, **browser / computer**, **tools / terminal / limits**, and **security / privacy / restoration** fields when known (see `page-templates.md`)
8. Tell the user Anytype is updated; **copy the Full System Prompt into the runtime bot** and verify groups/routines separately
9. If the runtime is Hermes, use `hermes-profiles` for the profile home and apply Suggested runtime into `model` / `auxiliary` / `fallback_providers` / `delegation` / `moa` / `SOUL.md` / `display.personality` / `agent.personalities` / `memory.*` / `browser.*` / `computer_use.*` / `bot_desktop.*` / `toolsets` / `approvals.*` / `terminal.*` / `tool_output.*` / `agent.max_turns` / `compression.*` / `security.*` / `privacy.*` / `checkpoints.*` (`hermes-profiles` → `models-and-delegation.md`, `soul-templates.md`, `memory.md`, `browser-and-computer.md`, `runtime-limits-and-tools.md`, `security.md`)

### Create or update an HQ

1. Mirror an existing HQ's sections (mission, sub-teams, routing, rules, map)
2. Link from Agents
3. Update roster/routing and Board/group welcome text if membership changes

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
- Small body edits via block ops; properties via `set_properties`
- Keep Agents link lists accurate when adding members
- Use `dry_run: true` when unsure

## Safety

1. Confirm Board/roster/Shared Rules/archive changes
2. Editing Anytype ≠ updating live bot prompts or chat groups
3. Never invent law, metrics, or product scope
4. Follow documented escalation paths to the human
5. Treat page/card comments as instructions when Shared Rules say so
6. Do not revive archived agents without explicit approval

## Common recipes (summary)

- **Orient:** discover space → open Agents → read Shared Rules + roster (`examples.md` for shape)
- **New specialist:** draft vs live → page from `page-templates.md` → memory children → link HQ → prompt copy reminder
- **New HQ:** clone peer HQ sections → link Agents → update roster + Group welcome (`handoff-templates.md`)
- **Shared Rules change:** edit → rollout checklist (`shared-rules-starter.md`) → runtime refresh reminder
- **MCP ops:** follow `mcp-recipes.md` with etags and dry-run when unsure

## Workflow checklist

1. Resolve space + discover Agents/Projects roots
2. Read roster/routing before ownership changes
3. Create/patch using templates / MCP recipes
4. Link from parent HQ / Agents / Skills hub
5. Report object ids/URLs and remaining runtime verification
6. If Hermes runtime: continue with `hermes-profiles`
