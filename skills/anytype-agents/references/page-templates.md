# Page templates (generic)

Use these shapes when creating or auditing **bodies**. Inventory objects use
types `agent`, `team`, and `project` (see `object-types.md`); memory children,
Shared Rules, and Skills stay `page`. Prefer duplicating a live peer in the same
space over inventing a new layout.

Suggested runtime field list: **`suggested-runtime.md`**.
Filled samples: **`examples.md`**. MCP create/patch: **`mcp-recipes.md`**.

## Agent page

Title: `{Name} – {Role}`

1. Heading + optional Autonomy line
2. **Suggested runtime** (paste from `suggested-runtime.md`, date the heading)
3. **Short Description** (one paragraph: mission, HQ, reporting line, ownership)
4. **Full System Prompt** fenced block (copy into the bot)
5. **Your Memory Pages** (links)
6. Map line: `Agents → {HQ} → [{Sub-team} →] {Agent}` and any `Projects → …` paths

Body outline (write as normal page markdown, not nested fences):

- `# {Name} – {Role}` then optional `**Autonomy:** …`
- `## Suggested runtime (YYYY-MM-DD)` from `suggested-runtime.md`
- `## Short Description` (one paragraph)
- `## Full System Prompt (copy into the bot)` with a fenced prompt (skeleton below)
- `## Your Memory Pages` (bullet links)
- Map line naming `Agents → {HQ} → …` and any `Projects → …` paths

Link memory children after create.

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
Membership and routing blurb for the live chat group.
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
- Models: primary/routing {…}; fallback {…}; aux {…}; subagents model_map {fast/deep/…} | default worker {…}; MoA {off|preset}
- Personality: SOUL {…}; overlay {none|name}; customs {…}
- Memory: built-in {on|off}; approval {on|off}; provider {none|name}
- Browser: {none|source + identity}
- Computer: {none | Cua Spaces (default) | host desktop | Bot Screen} · dedicated|shared
- Tools: {toolsets}; approvals {smart|manual|off}; terminal {cua (preferred)|local|…}/{cwd}
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
