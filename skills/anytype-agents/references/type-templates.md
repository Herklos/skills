# Object type default templates (dump)

Canonical **body markdown** for each inventory type's default template. Use these
when bootstrapping a new space (`API-create-template` + set
`default_template`), auditing drift against live templates, or creating objects
with `template: "none"` and pasting the body yourself.

Resolve live template **ids** each session with `API-list-templates` (filter by
`type`). Do not hardcode ids. Omit `template` on create to apply the type's
current default.

Companion shapes (HQ / Group / Skill / prompt skeleton): `page-templates.md`.
Property keys: `object-types.md`.

Dumped / authored **2026-11-04**; property-complete pass **2026-11-04** (v1.18.0);
runtime catalogs **2026-11-04** (v1.19.0): Browser / Computer / Tool profile
types + Agent/Team/Subteam link props. Per-HQ Browser/Computer pairs
**2026-11-04** (v1.22.0): one `{HQ} – Cua Spaces` + `{HQ} – Hermes Chromium` per
HQ; Subteams/Agents inherit; Board/Primary empty. Prompt type **2026-11-04**
(v1.25.0): system/welcome/shared_rules/library/draft. Memory + Skill types
**2026-11-04** (v1.26.0): agent notes as `memory`; procedures as `skill`;
Skills indexes as Queries via `skills_page`. Log type **2026-11-04** (v1.27.0):
per-action summaries as `log`; Logs Queries via Agent.`logs_page`. Schedule type
**2026-11-04** (v1.30.0): jobs as `schedule`; Agenda Queries via
Agent.`agenda_page` (Calendar on `next_run`). Group type **2026-11-04**
(v1.30.4): messaging rooms as `group` (welcome Prompt + platform fields);
Team `kind: Group` deprecated. HQ standing **2026-11-04** (v1.31.0): Team
`standing_instructions` → Prompt library; slim HQ bodies; short system Prompt
section. HQ Subteams Query **2026-11-04** (v1.31.1): Team.`subteams_page` →
Query filtered by `parent_team` (replace static Sub-teams / Domains tables).
Agent.`primary_model` removed **2026-11-04** (v1.31.2): models live on
Harness profile only. Agent default template + live stubs cleaned
**2026-11-04** (v1.31.3): no Full System Prompt fence; Team/Subteam/Subagent
gain optional `system_prompt`. Agent body property-dup cleanup **2026-11-04**
(v1.31.4): drop `## Suggested runtime` and Short description / Autonomy /
Home / Chief / HQ / Team / Reports-to prose once properties are set; Agent
default is System prompt + Agenda pointers only. Prefer properties for
mission / members / routing / short description / autonomy / map path /
browser / computer / tool_profile / `system_prompt` / `memory_pages` /
`skills_page` / `logs_page` / `agenda_page` / `messaging_group` /
`standing_instructions` / `subteams_page`.

---

## Agent default (`template_for`: `agent`)

Set Autonomy / Short description / Team / Reports to / Memory pages / Map path /
harness_profile / browser / computer / tool_profile / voice as **properties**
(`object-types.md`). Do **not** paste Suggested runtime or property prose into
the body. Template body:

```markdown
## System prompt
Canonical system prompt lives on the linked **System prompt** property
([{Name} – System prompt](anytype://object?objectId=<promptId>&spaceId=<spaceId>)).
Copy from that Prompt object into the bot. Do not paste a second Full System
Prompt fence here.

## Agenda
Canonical scheduled work lives on the linked **Agenda** Query
([{OwnerShort} – Agenda](anytype://object?objectId=<queryId>&spaceId=<spaceId>)).
Create typed **Schedule** objects (`owner_agent` = this agent).
```

Hermes apply checklist (not page body): `suggested-runtime.md`. Prompt create /
migrate: `prompts.md`. Agenda / Schedule: `agenda-and-schedules.md`.

---

## Team default (`template_for`: `team`)

For Board / HQ. Domains under an HQ use **Subteam default** (type `subteam`).
Messaging rooms use **Group default** (type `group`), not Team `kind: Group`.

Set `kind`, `chief`, `members`, `subteams`, `mission`, `routing_summary`,
`standing_instructions`, `subteams_page` as properties. Template body:

```markdown
## Subteams
Canonical domain roster is the linked **Subteams page** Query
(Team.`subteams_page`; filter `parent_team` = this HQ).

## Standing instructions
Standing instructions (gates, principles, routing) live on the linked
**Standing instructions** Prompt (Team.`standing_instructions`).

## HQ coordination
(Optional chief / group / skills / transition links.)
```

---

## Group default (`template_for`: `group`)

Set `lifecycle`, `parent_team`, `members`, `welcome_prompt`, `platform`,
optional `platform_chat_id` / `slug` / `mission` / `routing_summary` /
`hermes_profiles` / `require_mention` / `exclusive_bot_mentions` as properties
(`object-types.md`). Template body:

```markdown
## How to use
Coordination only. Durable state lives in Anytype (Prompts, Memory, Logs,
Agenda, Projects).

## Members
Canonical roster is the **Members** property. Keep Agent.`messaging_group`
pointing here.

## Welcome
Canonical welcome paste lives on the linked **Welcome prompt** property. Copy
that Prompt into the Hermes Bot Mode Group Chat (or Telegram/Discord only when
asked). Do not paste a second welcome fence here.

## Hermes / platform
Prefer `platform=hermes` and `platform_chat_id` = Hermes hosted `room_id`.
Require mention / Exclusive bot mentions apply to external platforms.
`hermes_profiles` is the seat checklist (max 6 per Bot Mode room → satellite B).
Apply via hermes-profiles `messaging-groups.md` when asked (no auto-push).
```

---

## Subteam default (`template_for`: `subteam`)

Live type + default template. Set `parent_team`, `chief`, `lifecycle`,
`mission`, `members`, `routing_summary` as properties. Template body:

```markdown
## Map notes
(Optional detail beyond properties.)
```

---

## Harness default (`template_for`: `harness`)

```markdown
## Purpose
What this product is for in the org.

## Notes
Capability limits, auth, when to prefer another harness.
```

Set `slug` to one of: `claude`, `codex`, `grok`, `github-copilot`, `muse`,
`nvidia-nim`, `local-model`.

---

## Harness profile default (`template_for`: `harness_profile`)

```markdown
## When to use
Intent and agent roles this stack fits.

## Stack summary
- model.*: {provider} · {model_default} · {effort} · harness {catalog}
- fallback_1: {provider} · {model} · {effort}
- fallback_2: {provider} · {model} · {effort}
- auxiliary: vision / compression / web_extract / skills_hub / title_generation
  (provider/model/effort; auto = inherit main)
- Voice: STT {provider}/{model} · TTS {provider}/{voice} · speed {1} (or none)

## Apply notes
Editing this profile updates the intended models (and voice stack) for every
Agent linked via `harness_profile`. Re-apply into each live runtime (Claude /
Codex / Grok / Hermes / …) separately. Anytype does not push configs
automatically. Decline `model_*` / `fallback_*` / `aux_*` via hermes-profiles
`models.md` (Local router: llamacpp + local_runtime) and voice via `voice.md`
(default local+edge).
```

Example stacks: **Local router** (`llamacpp` / `d1-2b-q4_k_m` medium → xai Grok
4.5 → anthropic Haiku 5.5) for most Agents; Coding / Data fetching for Subagent
routes.

---

## Subagent default (`template_for`: `subagent`)

```markdown
## When to use
{intent / task the parent should pick this route for}

## Route
- task_key: {fast | deep | fetch | …}
- parent_agent: {Agent name}
- harness_profile: {Coding | Data fetching | …}
- spawn_effort override: none | low | medium | high
- model_override: none | {label}

## Scope
{cwd / read-only / web-only / single-repo / …}

## Tools
{toolsets list or inherit}

## Deliver back
{what the child must return to the parent}

## Hermes apply
Decline into the parent's `delegation.backends.model_map.options` (see
hermes-profiles `delegation.md`). Re-apply after Subagent edits; Anytype does
not push configs automatically.
```

Set `parent_agent`, `task_key`, and `harness_profile` on create. Also add this
object to Agent.`subagents`.

---

## Browser default (`template_for`: `browser`)

```markdown
## When to use
(Set properties: slug, access_needed, is_real, browser_engine, real_profile_pin,
browser_source, browser_identity, headed. Org default: is_real true, engine
chrome, dedicated Profile N pin minted on the host first, source/identity
operator-real-profile. Body for apply notes.)

## Apply
Map to hermes-profiles browser-and-computer.md (`use_real_profile` /
`real_profile_pin` from is_real / pin). Create the Chrome profile before
saving the pin (`hq-runtime-pair.md`). Anytype does not push configs.
```

---

## Computer default (`template_for`: `computer`)

```markdown
## When to use
(Set properties: slug, access_needed, computer_surface, computer_scope,
permission_mode, desktop_enabled. Body for apply notes.)

## Apply
Map to hermes-profiles browser-and-computer.md (Cua Spaces default). Anytype
does not push configs.
```

---

## Tool profile default (`template_for`: `tool_profile`)

```markdown
## When to use
(Set properties: slug, intent, enabled/disabled toolsets, tool_approvals,
cron_approvals, terminal_backend, timeout_seconds.)

## Apply
Map to hermes-profiles runtime-limits-and-tools.md. Pair with linked Browser /
Computer when those toolsets are enabled. Anytype does not push configs.
```

---

## Project default (`template_for`: `project`)

Set `one_liner`, `overview`, `execution_policy`, `lead_agent`,
`related_projects`, and child `*_page` links as properties. Template body:

```markdown
## Core Features
…

## Architecture
…

## Target Users
…

## Key Differentiators
…
```

Common children: Technical, Business, Project Management (Roadmap / Backlog /
TODO Queries), Product, Design, Marketing (also link via `technical_page` / …).
PM playbook: `project-pm.md`.

---

## Epic default (`template_for`: `epic`)

Set `linked_projects`, `status`, `pm_priority`, optional `user_stories` as
properties. Template body:

```markdown
## Goal
(What outcome this epic delivers.)

## Scope
(In scope.)

## Out of scope
(Explicitly excluded.)

## Notes
(Links, decisions, constraints.)
```

---

## User story default (`template_for`: `user_story`)

Set `linked_projects`, `parent_epic`, `status`, `pm_priority`, optional
`child_tasks` as properties. Template body:

```markdown
## Story
As a … I want … so that …

## Acceptance
- [ ] …

## Notes
(Context, links, refine output.)
```

Task keeps the built-in todo default. Set `kind` (`bugfix` | `implementation` |
`doc` | `design` | `review` | `chore` | `spike`), `linked_projects`, and optional
parents as properties. See `project-pm.md`.

---

## Prompt default (`template_for`: `prompt`)

Set `prompt_kind`, `lifecycle`, `owner_agent` / `owner_group`, `audience` as
properties (`prompts.md`). Template body:

```markdown
## Prompt
(Copy-into-bot or welcome text.)

## Notes
(Apply / sync notes.)
```

---

## Memory default (`template_for`: `memory`)

Set `memory_kind`, `lifecycle`, `owner_agent` as properties
(`memory-and-skills.md`). Template body:

```markdown
## Purpose
(What this memory page is for.)

## Entries
(Durable facts, decisions, lessons, or resources.)

## Notes
(Cadence / review notes.)
```

---

## Skill default (`template_for`: `skill`)

Set `skill_kind`, `skill_key`, `skill_scope`, `skill_status`, `intent`,
matching `owner_*` as properties (`memory-and-skills.md`). Template body:

```markdown
## Goal
(One clear outcome.)

## When to use / When not to use
- Use when:
- Do not use when:

## Prerequisites
(Knowledge, tools, access.)

## Procedure
1. …
2. …
3. **Verify:** …

## Output format / template
(Concrete structure.)

## Constraints & gotchas
-

## Verification checklist
- [ ] Output matches goal

## Progressive disclosure
(Load-when → resource.)

## Change log
| Date | Change | By |
|------|--------|----|
```

---

## Log default (`template_for`: `log`)

Set `owner_agent`, `logged_at`, `summary` as properties
(`memory-and-skills.md`). Template body:

```markdown
## Summary
One or two sentences: what the agent did.

## Context
Optional: trigger, request, or task that led to this action.

## Outcome
Optional: result, links created, or follow-ups.

## Notes
```

---

## Schedule default (`template_for`: `schedule`)

Set `owner_agent`, `schedule_key`, `schedule_kind`, optional `schedule_expr` /
`timezone` / `next_run`, `intent`, deliver/skills as properties
(`agenda-and-schedules.md`). Template body:

```markdown
## Prompt
Full self-contained task for a fresh Hermes cron session. Include hostnames,
paths, acceptance criteria, and delivery expectations.

## Delivery
Target channel or local output. The prompt should not try to send itself.

## Notes
Migration provenance, wake message for event kind, or apply notes.
```

---

## Recreate a default template (MCP)

1. `API-create-template` with `template_for` = `agent` | `team` | `group` |
   `subteam` | `subagent` | `harness` | `harness_profile` | `browser` |
   `computer` | `tool_profile` | `prompt` | `memory` | `skill` | `log` |
   `schedule` | `project` | `epic` | `user_story`, name `{Type} default`, and
   body blocks from the matching section above (`heading_2` + `paragraph`).
2. `API-list-templates` with that `type` → note the new id.
3. `API-update-type` on the type: `{ "default_template": "<templateId>" }`.
4. Verify: create a throwaway object of that type with no `template` arg and
   confirm the body sections match.

## Drift check

1. `API-list-templates` for `agent`, `team`, `group`, `subteam`, `subagent`,
   `harness`, `harness_profile`, `browser`, `computer`, `tool_profile`,
   `prompt`, `memory`, `skill`, `log`, `schedule`, `project`, `epic`,
   `user_story`.
2. `API-get-object` each default (`format: "md"`).
3. Diff against this file. Update the skill dump when the live org intentionally
   changes the defaults; update live templates when the skill is the source of
   truth for a bootstrap.
