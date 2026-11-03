# Page templates (generic)

Use these shapes when creating or auditing **bodies**. Inventory objects use
types `agent`, `team`, and `project` (see `object-types.md`); memory children,
Shared Rules, and Skills stay `page`. Prefer duplicating a live peer in the same
space over inventing a new layout.

## Agent page

Title: `{Name} – {Role}`

```markdown
# {Name} – {Role}

## Suggested runtime (YYYY-MM-DD)
Document the intended runtime stack. Values are guidance for whoever configures
the bot; they do not auto-apply. For Hermes, map these into that profile's
`config.yaml` / `SOUL.md` (see skill `hermes-profiles` →
`models-and-delegation.md`, `soul-templates.md`, `memory.md`,
`browser-and-computer.md`, `runtime-limits-and-tools.md`, `security.md`,
`workspace-and-display.md`).

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
**Personality:**
- SOUL / durable identity: {summary or "see Full System Prompt / SOUL.md"}
- Overlay (`display.personality` / `/personality`): none | helpful | concise | technical | creative | teacher | … | custom `{name}`
- Custom presets (`agent.personalities`): none | list names + one-line intent
**Memory (Hermes profile):**
- Built-in: MEMORY.md on|off · USER.md on|off · limits {2200}/{1375} or custom
- Write approval: off | on (`/memory pending`)
- Notifications: off | on | verbose
- External provider: none | retaindb | byterover | honcho | hindsight | … (one)
- Notes: {shared across profiles via provider? / reset policy}
**Browser access:**
- Needed: no | yes (interactive pages; else prefer web_search / web_extract)
- Source: local Chromium | lightpanda | cloud ({browserbase|browser-use|firecrawl|nous|…}) | CDP attach | operator real profile
- Identity: dedicated throwaway | dedicated persistent | team/shared persistent | operator real profile
- Headed: no | yes · Notes: {vault logins? cron needs cookies?}
**Computer access:**
- Needed: no | yes (native desktop / OS UI; not for ordinary web)
- Surface: host desktop | Linux Bot Screen | sandbox desktop | host beside sandbox
- Scope: dedicated (this profile) | team/shared host (same OS user; not isolated)
- Permission mode: standard | bounded (manifest) · Notes: {TCC / takeover for 2FA}
**Tools access:**
- Enabled toolsets: {web, terminal, file, browser, memory, delegation, …}
- Disabled / denied: {list or none}
- Approvals: smart | manual | off · cron/unattended: deny | approve
- Hard deny patterns: {none | globs}
**Terminal / execution:**
- Backend: local | docker | ssh | modal | daytona | vercel_sandbox | singularity
- cwd: {absolute path or .}
- Timeout (s): {180} · Container CPU/RAM/disk/network: {…} if sandboxed
- Env passthrough / forwarded secrets: {names only, never values}
**Limits:**
- max_turns: unlimited | {n} · run_budget_seconds: off | {n} · gateway_timeout: {1800}
- tool_output max_bytes/lines: {50000}/{2000} · file_read_max_chars: {100000}
- compression: on|off · threshold {0.50} · loop hard-stop: interactive warn | unattended hard
**Security / privacy / restoration:**
- Approvals: smart | manual | off · cron/unattended: deny | approve · hard deny: {none|globs}
- Redact secrets: on|off · redact PII: on|off · allow_private_urls: on|off
- Protected instruction files: on|off · write safe root: unset | {policy label only}
- Messaging auth: allowlist | pairing | open (never put IDs/tokens here)
- Checkpoints /rollback: off | on · backup cadence: none | quick | full pre-update
- Notes: {YOLO allowed? disposable sandbox?}
**Workspace / display:**
- Gateway/cron cwd: {absolute path or .} · Named project: none | `{name}` (+ folders)
- Repo scan: on|off · roots: default home | {paths} · exclude: {paths}
- Skin: default | slate | mono | … · tool_progress: off|new|all|verbose
- Reasoning shown: on|off · streaming: on|off · resume_display: full|minimal
- UI language: en | … · Notes: {quiet Slack? Desktop fonts?}
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
- Personality: SOUL {…}; overlay {none|name}; customs {…}
- Memory: built-in {on|off}; approval {on|off}; provider {none|name}
- Browser: {none|source + identity}
- Computer: {none|surface + dedicated|shared}
- Tools: {toolsets}; approvals {smart|manual|off}; terminal {backend}/{cwd}
- Limits: max_turns {…}; tool_output {…}; compression {…}
- Security: redact {on|off}; auth {allowlist|pairing|open}; checkpoints {on|off}
- Workspace/display: project {…}; skin {…}; tool_progress {…}

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
  "create_missing_options": true,
  "body": {
    "type": "agent",
    "name": "Name – Role",
    "properties": {
      "role": "Implementer",
      "lifecycle": "draft",
      "harness": "hermes"
    },
    "markdown": "## Short Description\n…"
  }
}
```

Use `"type": "team"` / `"project"` for those objects. Then patch the parent hub to
add a link, create memory children as `page`, and return the object URL.
Property keys and default templates: `object-types.md`.
