# Shared Rules starter (generic template)

Duplicate into the space as **Agent Template – Shared Rules** (core index) plus
**topic library Prompts**. Every agent system Prompt keeps only a short pointer.
Rule bodies live in topic Prompts so agents open one topic at a time.

```markdown
# Agent Template – Shared Rules

Applies to every agent under Agents. Version 2.x (compact index).

## How to use (HARD)
1. System Prompt pointer only:
   `Follow Agents → Agent Template – Shared Rules in full.`
2. Do not paste topic bodies into SOUL / system Prompts.
3. Open **only the topic Prompt** that covers the rule you need.
4. HQ Standing instructions may add detail; they do not override Shared Rules.

## Topic prompts (open on demand)
- Shared Rules – Ops & quality (cheat sheets, lightest route, look-before-change, failure log, Monday scorecard, …)
- Shared Rules – Anytype data & channels (comments, Logs, Agenda, standing instructions, suggestions, memory layers, HTTP API, …)
- Shared Rules – Org & escalation (human escalation, time budget, ownership, …)
- Shared Rules – Delivery & tools (skills, token economy, GitHub hygiene, design/PX, Cursor, delegation, vault, …)
- Shared Rules – Meta & templates (ops retro template, rollout log; rarely mid-task)
- Optional: Anytype HTTP access (curl cheat sheet)

## One-line index
Keep a numbered 1…N map of rule → topic name (no full rule text on the core page).
```

Put full rule text only inside the matching topic Prompt. Prefer ~4–6 topics over one giant fence or one Prompt per rule.

## Rollout checklist (Primary)

When changing Shared Rules:

1. Edit the **topic** Prompt that owns the rule (or the core index if the map changed)
2. Bump core `version` / notes when the index changes
3. List agents that must acknowledge (pointer-only SOULs usually need no paste)
4. Remind: runtime bots still need prompt reload / restart when SOUL embeds an old fence
