# Page templates (generic)

Use these shapes when creating or auditing pages. Prefer duplicating a live peer page in the same space over inventing a new layout.

## Agent page

Title: `{Name} – {Role}`

```markdown
# {Name} – {Role}

## Suggested runtime (YYYY-MM-DD)
**Primary:** {harness} · {model} · {effort}
**Fallback 1:** …
**Fallback 2:** …

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

## Shared Rules pointer

Prefer a short pointer in each agent prompt:

`Follow Agents → {Shared Rules page title} in full.`

Avoid pasting the entire rules document into every prompt when a pointer suffices.

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
