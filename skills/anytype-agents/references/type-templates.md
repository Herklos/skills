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

Dumped from a live Agents org on **2026-11-04** (Agent / Team / Project
defaults). **Subteam default** is skill-authored (type not yet live in that
space); create it when bootstrapping `subteam`.

---

## Agent default (`template_for`: `agent`)

````markdown
## Suggested runtime (YYYY-MM-DD)
**Harness:** hermes | grok | claude | codex | noodle | cli | other
**Primary (main):** {provider} · {model} · {reasoning}
**Fallback / backup:** …
**Subagents / delegation:** enabled. Prefer model_map (fast/deep named routes) for different models per delegate_task; else cheaper single worker. Hermes: tools enable delegation + models-and-delegation.md.
**Personality / Memory / Browser / Computer / Tools / Limits / Security / Workspace:** fill from hermes-profiles references (see anytype-agents skill → page-templates.md / suggested-runtime.md).

## Autonomy
read-only | propose | change-with-gates

## Short Description
One paragraph: mission, HQ, reporting line, ownership.

## Full System Prompt (copy into the bot)
```
# Role
You are {Name}, …

# Shared rules
Follow **Agents → Agent Template – Shared Rules** in full.

# Tools and systems
- Runtime: {harness}
- Models / personality / memory / browser / computer / tools / security / workspace: see Suggested runtime

# Escalation
{chief → Primary → Human}
```

## Your Memory Pages
- Skills
- Operating Notes (optional)
- Lessons Learned (optional)
````

Full Suggested runtime field list: `suggested-runtime.md`. Filled sample:
`examples.md`.

---

## Team default (`template_for`: `team`)

For Board / HQ / Group. Domains under an HQ use **Subteam default** (type
`subteam`), not a second Team with a Sub-team kind.

```markdown
## Mission
…

## Subteams | Domains | Members
…

## Routing
Specialists → chief → Primary (adjust to local docs).

## Rules
1. Follow Agents → Agent Template – Shared Rules.

## Map
- Agents → {HQ} → …
```

Live dump historically titled the members section `Sub-teams | Domains | Members`.
Prefer **Subteams** and link typed `subteam` children from the map.

---

## Subteam default (`template_for`: `subteam`)

Skill-authored bootstrap body. Create with `API-create-template` when the
`subteam` type exists; set it as the type `default_template`.

```markdown
## Mission
…

## Members
- …

## Routing
Members → Subteam lead (if any) → HQ chief → Primary.

## Map
- Agents → {HQ} → {Subteam} → …
```

Set property `parent_team` to the owning HQ on create.

---

## Project default (`template_for`: `project`)

```markdown
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
Common children: Technical, Business, Project Management (Roadmap / Backlog / TODO), Product, Design, Marketing.
```

---

## Recreate a default template (MCP)

1. `API-create-template` with `template_for` = `agent` | `team` | `subteam` | `project`,
   name `{Type} default`, and body markdown from the matching section above
   (document form or create-object-style markdown if the server accepts it on
   templates; otherwise blocks from the markdown).
2. `API-list-templates` with that `type` → note the new id.
3. `API-update-type` on the type: `{ "default_template": "<templateId>" }`.
4. Verify: create a throwaway object of that type with no `template` arg and
   confirm the body sections match.

## Drift check

1. `API-list-templates` for `agent`, `team`, `subteam`, `project`.
2. `API-get-object` each default (`format: "md"`).
3. Diff against this file. Update the skill dump when the live org intentionally
   changes the defaults; update live templates when the skill is the source of
   truth for a bootstrap.
