# Shared Rules starter (generic template)

Duplicate into the space as **Agent Template – Shared Rules** (or local title).
Every agent prompt should point here. Adjust to the org; delete unused rules.

```markdown
# Agent Template – Shared Rules

Applies to every agent under Agents. Team rules may add detail; they do not override these.

Copy a short pointer into each bot prompt:
`Follow Agents → Agent Template – Shared Rules in full.`

## Shared rules (mandatory)

1) Service cheat sheets
For each connected service, keep a short note (under Resources or an HQ shared area):
purpose; exact field/label names; steps that worked; gotchas.
Read it before using that service. Update it when you learn something new.

2) Lightest route first
Order: what you already know → direct API/MCP → public web search → browser → human.
Before opening a browser, say why a direct connection cannot do the job.
If a connection is broken, tell the human. Do not silently work around it.

3) Look before you change
Before update, send, or delete: read-only check first. Confirm the record exists and fields match.
After the change: read it back.

4) Failure log
On failure, record: what you tried; why it failed; what worked instead (in Lessons Learned or Operating Notes).

5) Source of truth
Durable facts live in workspace pages. Runtime chat memory is for short hooks only.
When docs and chat memory disagree, prefer the workspace pages unless the human says otherwise.

6) Escalation
Specialists escalate to their HQ chief. Chiefs escalate to Primary. Only Primary reaches the human when that is the standing rule.

7) No invention
Do not invent law, metrics, prices, or product scope. Cite sources or mark uncertainty.

8) Skills
Resolve Agent → Team → Project → Global. Prefer the most specific matching skill.
Do not invent skills mid-flight; create via the Skill Template (and the skills owner if required).

9) Comments as a channel
When enabled: fetch comments on pages/cards you own or open, act, and reply on the thread.

10) Public hygiene
Do not put internal agent/org workspace links or private process into public VCS descriptions.

11) Approvals
Money, publish, production merge, mass delete: require an explicit human yes logged where the org records approvals.

12) Token economy
Prefer pointers to long docs over pasting them into every prompt.

13) Agenda (mandatory; type `schedule`)
When you need to schedule recurring work, a one-shot timer, or an event wake: create an Anytype **schedule** on your Agenda (Agent → Agenda Query via `agenda_page`), with owner_agent, schedule_key, schedule_kind (recurring|oneshot|event), schedule_expr+timezone when timed, intent/deliver/skills, and a self-contained body Prompt. Prefer the Agenda over chat-only or markdown-only schedule lists. Recurring rows become Hermes cron when applied; until then the Agenda is the source of truth.

14) HQ standing instructions (mandatory)
Before delivery, routing, merge, design, legal, finance, or cross-HQ work: open your HQ Team → Standing instructions (Prompt library via Team.standing_instructions). Follow those gates/rules/routing. Do not invent HQ policy. Shared Rules still apply org-wide. Do not paste the full standing library into every system Prompt.
```

## Rollout checklist (Primary)

When changing Shared Rules:

1. Edit the Shared Rules page
2. List agents that must acknowledge (or auto-refresh prompts)
3. Track completion
4. Remind: runtime bots still need prompt reload / restart
