# Page templates (generic)

Use these shapes when creating or auditing **bodies**. Inventory objects use
types `agent`, `team`, `subteam`, and `project` (see `object-types.md`); memory
children, Shared Rules, and Skills stay `page`. Prefer duplicating a live peer
in the same space over inventing a new layout.

Suggested runtime field list: **`suggested-runtime.md`**.
Filled samples: **`examples.md`**. MCP create/patch: **`mcp-recipes.md`**.
Type default template dumps (Agent / Team / Subteam / Project): **`type-templates.md`**.

## Agent page

Title: `{Name} – {Role}`

**Set as properties** (do not rely on markdown alone): `role`, `team`,
`reports_to`, `lifecycle`, `harness_profile`, `subagents`, `browser`,
`computer`, `tool_profile`, `voice_enabled`, `autonomy`, `short_description`,
`hermes_profile`, `board_member`, `linked_projects`, `memory_pages`,
`messaging_group`, `map_path`, `delegation_enabled`, `terminal_backend`,
`computer_surface`, voice modes / optional `stt_*` / `tts_*`. See
`object-types.md`.

Body (narrative only):

1. **Suggested runtime** (paste from `suggested-runtime.md`, date the heading;
   point structured facts at properties + harness_profile + browser / computer /
   tool_profile catalogs)
2. **Full System Prompt** fenced block (copy into the bot)
3. Optional notes that do not fit properties

Body outline:

- `# {Name} – {Role}` (name/role also live in title + `role` property)
- `## Suggested runtime (YYYY-MM-DD)` from `suggested-runtime.md`
- `## Full System Prompt (copy into the bot)` with a fenced prompt (skeleton below)

Skip `## Short Description`, `**Autonomy:**`, and prose-only map lines when
`short_description`, `autonomy`, and `map_path` properties are set. Link memory
children via `memory_pages` after create.

## HQ page

Set as properties: `kind` (`HQ` / `Board` / `Group`), `chief`, `members`,
`subteams`, `mission`, `routing_summary`, optional `messaging_group` /
`skills_page`, optional `browser` / `computer` / `tool_profile` team defaults.

```markdown
# {Name} HQ

## Rules
1. …
n. Follow Agents → Shared Rules.

## Map notes
(Optional detail beyond `routing_summary` / `subteams` / `members` properties.)
```

Link: chief, group, skills, transition notes, **`subteam`** children via the
`subteams` property (not `team` + `kind: Sub-team`).

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

## Group page

```markdown
# {Name} Group
## Members
…

## Welcome (copy-paste)
Membership and routing blurb for the live chat group.
```

Document membership here; applying it to a messaging platform is a separate runtime step.

## Skill page

1. Metadata: name, title, scope (`global` / `team:[HQ]` / `subteam:[name]` / `project:[name]` / `agent:[name]`), owner, status, version
2. Description router: third person, what + when (+ when not)
3. Goal
4. When to use / When not to use
5. Prerequisites
6. Procedure with a **Verify** step
7. Output format
8. Constraints & gotchas
9. Verification checklist
10. Progressive disclosure
11. Change log
12. Authoring checklist before status=active

Skip usage-logging fields if Shared Rules forbid them.

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
Management (Roadmap / Backlog / TODO), Product, Design, Marketing (also link via
the matching `*_page` properties).

## Full System Prompt skeleton (inside the fence)

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
- Browser: {linked Browser catalog name | {HQ} – Cua Chromium | empty on Board/Primary}
- Computer: {linked Computer catalog | {HQ} – Cua Spaces | empty on Board/Primary | host / Bot Screen exception} · dedicated|shared
- Tools: {linked Tool profile | toolsets}; approvals {smart|manual|off}; terminal {cua (preferred)|local|…}/{cwd}
- Voice: {off|on}; auto TTS {on|off}; chat {off|chained|gpt-live}; messaging {off|voice_only|all}; STT/TTS from harness profile or overrides
- Limits: max_turns {…}; tool_output {…}; compression {…}
- Security: redact {on|off}; auth {allowlist|pairing|open}; checkpoints {on|off}
- Workspace/display: project {…}; skin {…}; tool_progress {…}
- Scheduled tasks: {none | names + cadence summary}

# Memory
Maintain linked Memory Pages. Prefer workspace docs over chat-only memory.

# Delivery
{How work arrives: TODO card, handoff, comment thread.}
{Definition of done.}

# Escalation
{chief → Primary → Human as documented}
```

## Shared Rules pointer

Prefer a short pointer in each agent prompt:

`Follow Agents → {Shared Rules page title} in full.`

Avoid pasting the entire rules document into every prompt when a pointer suffices.
Starter ruleset: `shared-rules-starter.md`. Worked org sample: `examples.md`.
