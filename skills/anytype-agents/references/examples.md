# Fictional org examples

Illustrative only. Do not treat names or ids as real. Pattern to copy when designing an org.

## Sample org: Northwind Labs

```
Human
 └── Primary (Nova) — coordinator, approvals, weekly brief
      ├── Board
      │    ├── Kai — Product HQ chief
      │    ├── Remy — Engineering HQ chief
      │    └── Quinn — Growth HQ chief
      ├── Product HQ (Kai)
      │    ├── Jordan — PM
      │    └── Sam — Design
      ├── Engineering HQ (Remy)
      │    ├── Lee — Implementer
      │    └── Morgan — QA
      └── Growth HQ (Quinn)
           ├── Avery — Content
           └── Riley — Distribution
```

### Agents hub outline

```markdown
# Agents
Central home for teams and shared rules.

## Shared
- Agent Template – Shared Rules
- Skills

## Primary
- Nova – Primary

## Teams (HQ)
- Board HQ
- Product HQ
- Engineering HQ
- Growth HQ

## Subteams (type `subteam`, under HQs)
- Customer & Analytics – Product (example domain under Product HQ)
- Prefer `subteam` objects; do not create new Sub-teams as `team` with `kind: Sub-team`

## Harnesses (type `harness`)
- Claude, Codex, Grok, GitHub Copilot, Muse, NVIDIA NIM, Local model, Mistral

## Harness profiles (type `harness_profile`)
- **Local parent** → chat `mistral` / `zai-glm-5-3-flash` / low; aux approval `llamacpp` / `d1-2b-q4_k_m`; no cloud fallbacks (**most Agents**)
- **Foyer** → dual local `llamacpp` / `LFM3-1.7B-Q8_0` + d1 approvals; voice-friendly; no Subagents (home agents)
- **CLASQUIN** → Anthropic Claude Sonnet 5.5 high; no fallbacks (Arnold)
- Chiefs / Coding / Reviewing / Browser / Web/MCP / Deep think → Subagent specialist stacks
- Agents link `harness_profile` (not a harness select)

## Subagents (type `subagent`, under Agents)
- Lee (Local parent) → Coding (`coding`), Review (`review`), Deep (`deep`)
- Remy (chief pack) → Chiefs / Deep / Review; parent answers peer chiefs on lfm3 when no Subagent is needed
- Keep Subagent.`parent_agent` and Agent.`subagents` both ways

## Hierarchy
Human ↔ Nova → chiefs → specialists
Skills: Agent → Subteam → Team → Project → Global
```

### Routing table (example)

| Signal | Route |
|--------|-------|
| Roadmap / backlog / Ready work | Nova → Kai → Jordan |
| Design | Nova → Kai → Sam |
| Implementation / CI / review | Nova → Remy → Lee / Morgan |
| Marketing / launch copy | Nova → Quinn → Avery / Riley |
| Human approval | Nova → Human |

### Sample agent short description

> Lee – Implementer. Ships one Ready TODO as a small PR under Remy. Runtime: coding CLI. Does not set product scope.

### Sample Suggested runtime (coding implementer)

```markdown
## Suggested runtime (2026-11-04)
**Harness profile:** Local parent (Agent.`harness_profile` → Local parent)
**Primary (from profile):** Ollama · lfm3 · none (chat + route picking)
**Approval (Hermes):** llamacpp · d1-2b-q4_k_m
**Fallback / backup (from profile):**
- 1: Grok · Grok 4.5 · medium
- 2: Claude · Claude Haiku 5.5 · medium
**Auxiliary:**
- vision: openrouter · google/gemini-2.5-flash
- compression: openrouter · google/gemini-2.5-flash
- approval: auto (main)
- review: openrouter · anthropic/claude-opus-4
**Subagents / delegation:**
- Enabled: yes (`delegation` toolset)
- Pattern: parent Local parent answers peers / light asks on lfm3; spawn Subagent only when specialized
- Anytype Subagents: role packs (`chiefs` / `coding` / `review` / `web` / `browser` / `deep`)
- Chat / routing model: llamacpp · LFM3-1.7B-Q8_0; approvals: llamacpp · d1-2b-q4_k_m
- Mode: `model_map` · plugin advanced-delegation installed
- Task-specific models (declined from Subagent objects; unrouted work stays on parent):
  - `fast` ← Quick edit · Coding · medium — small edits, simple tests
  - `deep` ← Deep code · Coding · high — hard debugging, careful refactors
  - `fetch` ← Fast fetch · Data fetching · high — lookups, scrape, light summary
- max_concurrent_children 8; max_iterations 250
- Setup: `hermes plugins install advanced-delegation` → decline Subagents (`delegation.md`) → `hermes delegation config`
**Scheduled tasks:**
- `pr-hygiene` · `0 8 * * 1-5` · list stale draft PRs in cwd repo and open Ready follow-ups · deliver origin · workdir /absolute/path/to/repo · model: cron.model · cronjob toolset on · approvals.cron_mode deny
- (no no_agent watchdogs on this implementer)
**Mixture of Agents:** off
**Personality:**
- SOUL: pragmatic implementer; short status; ask before destructive git
- Overlay: none (use `/personality concise` only for terse triage)
- Custom presets: none
**Memory:**
- Built-in: MEMORY.md on · USER.md on · limits 2200 / 1375
- Write approval: off
- Notifications: on
- External provider: none
**Browser access:**
- Needed: yes (PR checks on CI web UI)
- Is real: yes · Engine: chrome · Pin: Profile 2 (Hermes Engineering)
- Source: operator real profile
- Identity: operator real profile
- Headed: no
**Computer access:**
- Needed: yes (sandboxed work surface)
- Surface: Cua Spaces (default). Docs: https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces
- Scope: dedicated (plugin `space: create` or named Space)
- Permission mode: standard · desktop stack: on (Linux Space)
**Tools access:**
- Enabled toolsets: terminal, file, web, browser, cronjob
- Approvals: smart · cron/unattended: deny
**Terminal / execution:**
- Backend: cua · cwd: unset (Space home) · timeout: 180 · plugin cua-spaces installed
**Limits:**
- max_turns: 150 · tool_output: 50000/2000 · compression: on @ 0.50
**Security / privacy / restoration:**
- Approvals: smart · cron: deny · hard deny: none
- Redact secrets: on · redact PII: off · allow_private_urls: off
- Protected instruction files: on
- Messaging auth: n/a (no gateway)
- Checkpoints: off · backup: quick before major changes
**Workspace / display:**
- Gateway/cron cwd: /absolute/path/to/repo · Named project: forge-app
- Repo scan: on · roots: default · exclude: none
- Skin: slate · tool_progress: all · reasoning: on · streaming: off · resume: full
- UI language: en
**Gateway / messaging:** none
```

Chiefs that need multi-model review can set MoA, for example:

```markdown
**Mixture of Agents:** preset `deep_review` (references: codex gpt + flash advisor; aggregator: opus; fanout: user_turn)
```

A sticky named voice looks like:

```markdown
**Personality:**
- SOUL: coordinator; routes work; does not implement
- Overlay: teacher (sticky `display.personality: teacher`)
- Custom presets: `brief_ops` — terse SRE status voice
```

A gated memory + Honcho example:

```markdown
**Memory:**
- Built-in: MEMORY.md on · USER.md on · defaults
- Write approval: on
- Notifications: verbose
- External provider: honcho (workspace shared; AI peer per profile)
```

Ops agent on Cua Spaces (preferred) with headed takeover in the Space viewer:

```markdown
**Browser access:**
- Needed: yes
- Is real: no (exception: Space-local throwaway / persistent)
- Source: local Chromium (inside Linux Space with desktop stack)
- Identity: dedicated throwaway (or dedicated persistent inside a kept Space)
- Headed: yes · human takeover via Cua Spaces viewer / Desktop Screen pane
**Computer access:**
- Needed: yes
- Surface: Cua Spaces (default). Docs: https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces
- Scope: dedicated (`space: hermes-default` or named Space; `delete_on_exit: false` to keep)
- Permission mode: standard · `plugins.entries.cua-spaces.settings.desktop: true`
**Terminal / execution:**
- Backend: cua · cwd: unset (Space home)
```

Host Bot Screen exception (only when the operator needs the Linux gateway screen without a Space):

```markdown
**Computer access:**
- Needed: yes
- Surface: Linux Bot Screen (exception; prefer Cua Spaces)
- Scope: dedicated (this profile's screen)
- Permission mode: standard
```
Blank Suggested runtime fields: `suggested-runtime.md`.  
Apply Hermes runtime with `hermes-profiles`: `models.md`, `delegation.md` (advanced-delegation plugin), `soul-templates.md`, `memory.md`, `browser-and-computer.md`, `runtime-limits-and-tools.md`, `security.md`, `workspace.md`, `display.md`, `cron.md`.

### Sample handoff (Primary → HQ chief)

```text
Owner: Kai (Product)
Why: Backlog quality gate for Project Harbor
Context: Projects → Harbor → Project Management → Backlog
Done when: Top 5 items have clear acceptance criteria and owner
Human approval needed: no
Next check: Friday brief
```

## Sample project: Harbor

```
Projects
 └── Harbor
      ├── Overview (positioning, features)
      ├── Technical
      ├── Business
      ├── Project Management
      │    ├── Roadmap   (Query → epic where linked_projects contains Harbor)
      │    ├── Backlog  (Query → user_story …)
      │    └── TODO     (Query → task …; kind includes spike)
      ├── Product
      ├── Design
      └── Marketing
```

Agents reference `Projects → Harbor → Project Management → TODO` for Ready work
and `Design` for design-done evidence when that gate exists. File new work as
typed `epic` / `user_story` / `task` with `linked_projects` set (`project-pm.md`).

## Sample skill index entry

```markdown
## Index of global skills
- look-before-edit (active): read-only check before mutating external systems
- weekly-hq-brief (active): format Monday status for Primary
```

## What "done" looks like after creating an agent

1. Agent page exists with Full System Prompt fence
2. Memory children linked (at least Skills)
3. HQ map links to the agent
4. Shared Rules pointer in the prompt
5. Optional Subagent objects linked (`parent_agent` + Agent.`subagents`)
6. User told: copy prompt into runtime; verify chat group separately
7. If Hermes: profile created/updated via `hermes-profiles` (models from harness_profile; routes from Subagents)
