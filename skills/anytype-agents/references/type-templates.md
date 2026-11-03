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

Dumped / authored **2026-11-04**: Agent / Team / Project from live org; Harness /
Harness profile from live bootstrap; Subteam skill-authored until type is live.

---

## Agent default (`template_for`: `agent`)

````markdown
## Suggested runtime (YYYY-MM-DD)
**Harness profile:** {Coding | Data fetching | …}  (Agent.`harness_profile`)
**Primary (from profile):** {Harness} · {model} · {low|medium|high}
**Fallback / backup (from profile):**
- 1: {Harness} · {model} · {effort}
- 2: {Harness} · {model} · {effort}
**Catalog harnesses:** claude | codex | grok | github-copilot | muse | nvidia-nim | local-model
**Subagents / delegation:** enabled. Prefer model_map (fast/deep named routes) for different models per delegate_task; else cheaper single worker.
**Personality / Memory / Browser / Computer / Tools / Limits / Security / Workspace:** fill from hermes-profiles references when applying via Hermes (see suggested-runtime.md).

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
- Harness profile: {name} (primary + backups from that object)
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
- Primary: {Harness} · {model} · {effort}
- Backup 1: {Harness} · {model} · {effort}
- Backup 2: {Harness} · {model} · {effort}

## Apply notes
Editing this profile updates the intended models for every Agent linked via
`harness_profile`. Re-apply into each live runtime (Claude / Codex / Grok / …)
separately. Anytype does not push configs automatically.
```

Example stacks: Coding (Claude Sonnet 5.5 high → Codex Sol 6.1 high → Grok 4.5
high); Data fetching (Codex Terra 6.1 high → Claude Haiku 5.5 medium → Grok 4.5
medium).

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

1. `API-create-template` with `template_for` = `agent` | `team` | `subteam` |
   `harness` | `harness_profile` | `project`, name `{Type} default`, and body
   blocks from the matching section above (`heading_2` + `paragraph`).
2. `API-list-templates` with that `type` → note the new id.
3. `API-update-type` on the type: `{ "default_template": "<templateId>" }`.
4. Verify: create a throwaway object of that type with no `template` arg and
   confirm the body sections match.

## Drift check

1. `API-list-templates` for `agent`, `team`, `subteam`, `harness`,
   `harness_profile`, `project`.
2. `API-get-object` each default (`format: "md"`).
3. Diff against this file. Update the skill dump when the live org intentionally
   changes the defaults; update live templates when the skill is the source of
   truth for a bootstrap.
