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
**Subagents / delegation:** cheaper worker openrouter · google/gemini-2.5-flash; max_concurrent_children 8; backend default
**Mixture of Agents:** off
**Gateway / messaging:** none
```

Chiefs that need multi-model review can set MoA, for example:

```markdown
**Mixture of Agents:** preset `deep_review` (references: codex gpt + flash advisor; aggregator: opus; fanout: user_turn)
```

Apply Hermes fields with skill `hermes-profiles` → `references/models-and-delegation.md`.

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
