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

## Hierarchy
Human ↔ Nova → chiefs → specialists
Skills: Agent → Team → Project → Global
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

### Sample Suggested runtime (Hermes implementer)

```markdown
## Suggested runtime (2026-11-03)
**Harness:** hermes
**Primary (main):** openrouter · anthropic/claude-sonnet-4 · high
**Fallback / backup:** openrouter · google/gemini-2.5-pro
**Auxiliary:**
- vision: openrouter · google/gemini-2.5-flash
- compression: openrouter · google/gemini-2.5-flash
- approval: auto (main)
- review: openrouter · anthropic/claude-opus-4
**Subagents / delegation:**
- Enabled: yes (`delegation` toolset)
- Routing model: openrouter · anthropic/claude-sonnet-4 · high (Primary / main; picks `option` per task)
- Mode: `model_map` · plugin advanced-delegation installed
- Task-specific models (default `fast`):
  - `fast` = openrouter · google/gemini-2.5-flash — lookups, summaries, simple edits
  - `deep` = openrouter · anthropic/claude-sonnet-4 · high — hard debugging, careful refactors
- max_concurrent_children 8; max_iterations 250
- Setup: `hermes plugins install advanced-delegation` → `hermes delegation config`
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
- Source: local Chromium
- Identity: dedicated throwaway
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
- Backend: cua · cwd: unset (Space home) · timeout: 180 · plugin cua-spaces installed**Limits:**
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
      │    ├── Roadmap
      │    ├── Backlog
      │    └── TODO
      ├── Product
      ├── Design
      └── Marketing
```

Agents reference `Projects → Harbor → Project Management → TODO` for Ready work and `Design` for design-done evidence when that gate exists.

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
5. User told: copy prompt into runtime; verify chat group separately
6. If Hermes: profile created/updated via `hermes-profiles`
