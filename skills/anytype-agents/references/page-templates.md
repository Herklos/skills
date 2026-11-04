# Page templates (generic)

Use these shapes when creating or auditing **bodies**. Inventory objects use
types `agent`, `team`, `subteam`, `group`, `prompt`, `memory`, `skill`, `log`,
`suggestion`, `schedule`, and `project` (see `object-types.md` + `prompts.md` +
`memory-and-skills.md` + `suggestions.md` + `agenda-and-schedules.md`). Skills,
Logs, Suggestions, and Agenda indexes are Queries. Shared Rules is type
`prompt`. Prefer duplicating a live peer in the same space over inventing a new
layout.

Hermes apply checklist (not Agent body): **`suggested-runtime.md`**.
Filled samples: **`examples.md`**. MCP create/patch: **`mcp-recipes.md`**.
Type default template dumps (Agent / Team / Subteam / Project): **`type-templates.md`**.

## Agent page

Title: `{Name} – {Role}`

**Set as properties** (do not rely on markdown alone): `role`, `team`,
`reports_to`, `lifecycle`, `harness_profile`, `subagents`, `system_prompt`,
`browser`, `computer`, `tool_profile`, `voice_enabled`, `autonomy`,
`short_description`, `hermes_profile`, `board_member`,
`memory_pages`, `skills_page`, `logs_page`, `agenda_page`, `suggestions_page`, `messaging_group`,
`map_path`, `delegation_enabled`, `terminal_backend`, `computer_surface`, voice
modes / optional `stt_*` / `tts_*`. See `object-types.md` + `prompts.md` +
`memory-and-skills.md` + `suggestions.md` + `agenda-and-schedules.md`.

Body (pointers + unique narrative only):

1. **System prompt** short pointer to the linked Prompt (`system_prompt`)
2. **Agenda** short pointer to the linked Agenda Query (`agenda_page`) when
   schedules exist or the Query is linked
3. Optional notes / checklists / memory that do **not** fit properties

Body outline:

- `## System prompt` + one paragraph pointing at `[{Name} – System prompt]`
- `## Agenda` + one paragraph pointing at `[{OwnerShort} – Agenda]`

**Do not** put these on the Agent body once the matching property is set:
`short_description`, `autonomy`, `team`, `reports_to`, `map_path` / HQ / Home /
Chief, harness / browser / computer / tools / voice runtime stacks, or a
`## Suggested runtime` section. Fill the properties first; delete body
duplicates. `suggested-runtime.md` is an apply checklist for Hermes, not page
markdown.

**Do not** keep `## Sub-pages to create`, `## Sub-pages`, `## Your Memory Pages`,
`## Memory pages`, or “(Sub-pages below.)” / “already created as sub-pages”
inventories. Create Memory objects + Skills / Logs / Agenda Queries, wire
`memory_pages` / `skills_page` / `logs_page` / `agenda_page` / `suggestions_page`, then delete those
body sections. Legacy Full backup / restore dumps stay type `page` (no Agent
property; see `memory-and-skills.md` out of scope). Old Skills index `page`s are
superseded by `skills_page` Queries. Routine pages belong as `schedule` rows on
the Agenda.

**Do not** leave dated org/routing **quote** blocks (or “Board member. Current
Board: …” paragraphs) on Agent bodies. Migrate:

- Dated announcements / restores / archives → type `log` (`logged_at`, `summary`)
- Durable cross-HQ routing (“X → Y via René”) → owning HQ
  `standing_instructions` (and optionally a dated Memory & Decisions entry)
- Role voice / standing preferences → Memory & Decisions (keep
  `short_description` as the one-liner)
- Hard pipelines already documented on HQ standing → Log only, then delete body
  quote

Fill properties / standing / memory first; delete the body quote.

Link Memory objects via `memory_pages`, the Skills Query via `skills_page`, the
Logs Query via `logs_page`, the Agenda Query via `agenda_page`, and the
Suggestions Query via `suggestions_page` after create (`memory-and-skills.md` +
`agenda-and-schedules.md` + `suggestions.md`). Create the Prompt object
first (`prompts.md`); do not keep a Full System Prompt / SOUL fence on the
Agent. Replace old Automations / Noodle / Hermes schedule prose with the Agenda
pointer.

## HQ page

Set as properties: `kind` (`HQ` / `Board`), `chief`, `members`,
`subteams`, `mission`, `routing_summary`, `standing_instructions` (→ Prompt
library), `subteams_page` (→ Subteams Query), optional `messaging_group`
(typed Group) / `skills_page`, optional `browser` / `computer` /
`tool_profile` team defaults.

```markdown
# {Name} HQ

## Subteams
Canonical domain roster is the linked **Subteams page** Query
([{Name short} – Subteams](anytype://object?objectId=<queryId>&spaceId=<spaceId>)),
filtered by `parent_team` = this HQ.

## Standing instructions
Canonical gates and routing live on the linked **Standing instructions** Prompt
([{Name} – Standing instructions](anytype://object?objectId=<promptId>&spaceId=<spaceId>)).

## HQ coordination
(Chief / Group / Skills / Transition plan links as needed.)
```

Do **not** keep a static Sub-teams / Domains / Sub-domains table, per-domain
empty headings, or Notion-map path lists once `subteams_page` is set. Do
**not** keep a second full Rules / Delivery / Routing dump once
`standing_instructions` is set. Full playbook: `hq-standing-instructions.md`.

Link: chief, group, skills, transition notes, **`subteam`** children via the
`subteams` property **and** the Subteams Query (not `team` + `kind: Sub-team`).

## Subteam page

Type **`subteam`**. Title: `{Domain} – {HQ short name}` or `{Name} Subteam`.

Set as properties: `parent_team`, `chief`, `lifecycle`, `mission`, `members`,
`routing_summary`, optional `messaging_group` / `skills_page`, optional
`browser` / `computer` / `tool_profile` domain defaults.

```markdown
# {Name} Subteam

## Map notes
(Optional detail beyond properties.)
```

Body may omit Mission / Members / Routing headings when those properties are
filled.

## Group (type `group`)

Type **`group`**. Set as properties: `lifecycle`, `parent_team`, `members`,
`welcome_prompt`, `platform`, optional `platform_chat_id` / `slug` / `mission` /
`routing_summary` / `hermes_profiles` / `require_mention` /
`exclusive_bot_mentions` / `notes` (`object-types.md`). Body:

```markdown
# {Name} Group

## Members
Canonical roster is the **Members** property. Keep Agent.`messaging_group`
pointing here.

## Welcome prompt
Canonical welcome paste lives on the linked **Welcome prompt** property
([{Name} Group – Welcome prompt](anytype://object?objectId=<promptId>&spaceId=<spaceId>)).

## Hermes / platform
Platform, Platform chat id, Require mention, Exclusive bot mentions, and Hermes
profiles are properties. Apply via hermes-profiles `messaging-groups.md` when
asked (no auto-push).
```

Skip duplicating member lists in markdown when `members` is filled. Full Prompt
create/migrate: `prompts.md`.

## Skill (type `skill`)

Set as properties: `skill_kind`, `skill_key`, `skill_scope`, `skill_status`,
`version`, `intent`, matching `owner_*` (`memory-and-skills.md`). Body:

1. Goal
2. When to use / When not to use
3. Prerequisites
4. Procedure with a **Verify** step
5. Output format
6. Constraints & gotchas
7. Verification checklist
8. Progressive disclosure
9. Change log
10. Authoring checklist before `skill_status=active`

Skip Metadata tables once properties are set. Skip usage-logging fields if
Shared Rules forbid them. Owner Skills **Query** lists the skill automatically.

## Log (type `log`)

Set as properties: `owner_agent`, `logged_at`, `summary` (`memory-and-skills.md`).
Name the object after the short summary. Body:

1. Summary (mirrors `summary` property)
2. Context (optional)
3. Outcome (optional)
4. Notes

Owner Logs **Query** (`logs_page`) lists the entry automatically. One Log per
discrete action.

## Suggestion (type `suggestion`)

Set as properties: `owner_agent`, `proposed_by`, `suggestion_kind`,
`suggestion_status`, `proposed_at`, `summary` (`suggestions.md`). Body:

```markdown
## Summary
One or two sentences: what should change and why.

## Evidence
What task, failure, or observation triggered this.

## Proposed action
Concrete next step (harness / Subagent / Skill / Prompt / tool / other).

## Approval path
Owning agent → chief. Org-wide / harness / Shared Rules → P. No Hermes auto-apply.

## Notes
```

Owner Suggestions **Query** (`suggestions_page`) lists the entry automatically.

## Schedule (type `schedule`)

Set as properties: `owner_agent`, `schedule_key`, `schedule_kind`, optional
`schedule_expr` / `timezone` / `next_run`, `intent`, deliver/skills/workdir /
model_pin / paused fields (`agenda-and-schedules.md`). Name:
`{schedule_key} – {OwnerShort}`. Body:

1. Prompt (full self-contained Hermes cron prompt)
2. Delivery
3. Notes

Owner Agenda **Query** (`agenda_page`) lists the row automatically. Calendar
view on `next_run` optional.

## Project page

Set as properties: `project_status`, `project_category`, `owning_team`,
`one_liner`, `overview`, `execution_policy`, `lead_agent`, `related_projects`,
optional `git_hub` / `public_url`, and child hub links (`technical_page`,
`product_page`, `pm_page`, `design_page`, `business_page`, `marketing_page`).

```markdown
# {Project}

## Core Features
…

## Architecture
…

## Target Users
…

## Key Differentiators
…
```

Skip duplicating one-liner / overview / related-projects / execution policy in
markdown when properties are set. Common children: Technical, Business, Project
Management (links to **Roadmap / Backlog / TODO** Queries filtered by
`linked_projects` over Epic / User story / Task; see `project-pm.md`), Product,
Design, Marketing (also link via the matching `*_page` properties).

## System Prompt skeleton (body of the Prompt object)

Put this text on the **Prompt** object (`prompt_kind=system`), not as a fence on
the Agent page. Full create flow: `prompts.md`.

```text
# Role
You are {Name}, {role} in {HQ}. You report to {chief or Primary}.

# Mission
{One paragraph outcome.}

# Boundaries
- In scope: …
- Out of scope: …
- Autonomy: {read-only | propose | change-with-gates}

# Shared rules
Follow **Agents → {Shared Rules title}** in full.

# Tools and systems
- Workspace pages under Agents / Projects (source of truth)
- {MCP / CLI / browser as applicable}
- Harness profile: {Coding | Data fetching | …}
- Models: from profile (`model.*` + fallbacks + aux); optional local overrides; Subagents (type `subagent` → model_map {task_key…}) | default worker {…}; MoA {off|preset}
- Personality: SOUL {…}; overlay {none|name}; customs {…}
- Memory: built-in {on|off}; approval {on|off}; provider {none|name}
- Browser: {linked Browser catalog name | {HQ} – Hermes Chromium | empty on Board/Primary}
- Computer: {linked Computer catalog | {HQ} – Cua Spaces | empty on Board/Primary | host / Bot Screen exception} · dedicated|shared
- Tools: {linked Tool profile | toolsets}; approvals {smart|manual|off}; terminal {cua (preferred)|local|…}/{cwd}
- Voice: {off|on}; auto TTS {on|off}; chat {off|chained|gpt-live}; messaging {off|voice_only|all}; STT/TTS from harness profile or overrides
- Limits: max_turns {…}; tool_output {…}; compression {…}
- Security: redact {on|off}; auth {allowlist|pairing|open}; checkpoints {on|off}
- Workspace/display: project {…}; skin {…}; tool_progress {…}
- Scheduled tasks: Agenda Query `{OwnerShort} – Agenda` | {none | schedule_key list}

# Agenda (mandatory)
When you schedule recurring work, a one-shot timer, or an event wake, create an
Anytype **schedule** on your Agenda Query (`agenda_page`): owner_agent=you,
schedule_key, schedule_kind (recurring|oneshot|event), schedule_expr+timezone
when timed, intent/deliver/skills, body Prompt self-contained. Prefer the Agenda
over chat-only or markdown-only schedule lists (Shared Rules Agenda rule).

# HQ standing instructions (mandatory)
Before delivery, routing, merge, design, legal, finance, or cross-HQ work, open
your HQ Team → **Standing instructions** (Prompt library). Follow those
gates/rules/routing. Do not invent HQ policy. Shared Rules still apply org-wide.

# Memory
Maintain linked Memory Pages. Prefer workspace docs over chat-only memory.

# Delivery
{How work arrives: TODO card, handoff, comment thread.}
{Definition of done.}

# Escalation
{chief → Primary → Human as documented}
```

## Shared Rules pointer

Prefer a short pointer inside each system Prompt body:

`Follow Agents → {Shared Rules title} in full.`

Shared Rules itself is type `prompt` (`prompt_kind=shared_rules`). Avoid pasting
the entire rules document into every agent Prompt when a pointer suffices.
Starter ruleset: `shared-rules-starter.md`. Worked org sample: `examples.md`.
