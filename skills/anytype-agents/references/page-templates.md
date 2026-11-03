# Page templates (generic)

Use these shapes when creating or auditing pages. Prefer duplicating a live peer page in the same space over inventing a new layout.

## Agent page

Title: `{Name} – {Role}`

```markdown
# {Name} – {Role}

## Suggested runtime (YYYY-MM-DD)
Document the intended runtime stack. Values are guidance for whoever configures
the bot; they do not auto-apply. For Hermes, map these into that profile's
`config.yaml` (see skill `hermes-profiles` → `references/models-and-delegation.md`).

**Harness:** hermes | grok | claude | codex | noodle | cli | other
**Primary (main):** {provider} · {model} · {reasoning effort} · {speed tier if any}
**Fallback / backup:** {provider} · {model}  (ordered list if several)
**Auxiliary (optional overrides; else auto = main):**
- vision: …
- compression: …
- approval: …
- title_generation: …
- review (`/review`): …
- other tasks: …
**Subagents / delegation:** inherit | cheaper worker {provider}·{model} | model_map | profile_routes ({profile names})
**Mixture of Agents (optional):** off | preset `{name}` (references: …; aggregator: …; fanout: user_turn|per_iteration|every_n:N)
**Gateway / messaging:** none | telegram | discord | … (token lives in runtime secrets, not on this page)

# {Name} – {Role}
**Autonomy:** …
**Short Description**
One paragraph: mission, HQ, reporting line, ownership.

---
## Full System Prompt (copy into the bot)
```
# Role
You are {Name}, …

# Shared rules
Follow **Agents → Shared Rules** (or the exact linked title) in full.

# …
```

---
## Your Memory Pages
- Memory & Decisions (chiefs / Primary)
- Operating Notes
- Resources
- Lessons Learned
- Skills
```

Link memory children after create. Add a map section naming
`Agents → {HQ} → [{Sub-team} →] {Agent}` and any `Projects → …` paths used.

## HQ page

```markdown
# {Name} HQ
> Chief: **{Name}**. …

**Mission**
…

## Sub-teams | Domains | Members
…

## Routing
Specialists → chief → Primary (adjust to local docs).

## Rules
1. …
n. Follow Agents → Shared Rules.

## Map
- Agents → {HQ} → …
```

Link: chief, group, skills, transition notes, sub-teams.

## Group page

```markdown
# {Name} Group
## Members
…

## Welcome (copy-paste)
```
Membership and routing blurb for the live chat group.
```
```

Document membership here; applying it to a messaging platform is a separate runtime step.

## Skill page

1. Metadata: name, title, scope (`global` / `team:[HQ]` / `project:[name]` / `agent:[name]`), owner, status, version
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

```markdown
# {Project}
One-line positioning.

## Overview
…

## Core Features
…

## Architecture
…

## Target Users
…

## Key Differentiators
…

**Related projects:** …
```

Common children: Technical, Business, Project Management (Roadmap / Backlog / TODO), Product, Design, Marketing.

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
- Runtime: {harness}
- Models: primary {…}; fallback {…}; aux {…}; subagents {…}; MoA {off|preset}

# Memory
Maintain linked Memory Pages. Prefer workspace docs over chat-only memory.

# Delivery
{How work arrives: TODO card, handoff, comment thread.}
{Definition of done.}

# Escalation
{chief → Primary → Human as documented}
```

## Worked specialist example (fictional)

Title: `Lee – Implementer`

Short description: Implements one Ready coding TODO as a small PR for Engineering HQ. Reports to Remy. Does not set product scope.

Prompt fence should include Role, Shared rules pointer, single-TODO rule, PR hygiene, and escalation to Remy.

Memory children: Skills, Implementation Patterns, Lessons Learned, Resources.

## Shared Rules pointer

Prefer a short pointer in each agent prompt:

`Follow Agents → {Shared Rules page title} in full.`

Avoid pasting the entire rules document into every prompt when a pointer suffices.
For a starter ruleset, see `shared-rules-starter.md`.

## Create via MCP (sketch)

```json
{
  "space_id": "<discovered-space-id>",
  "body": {
    "type": "page",
    "name": "Name – Role",
    "markdown": "# Name – Role\n…"
  }
}
```

Then patch the parent hub to add a link, create memory children, and return the object URL from the API response.
