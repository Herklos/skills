# Handoff and brief templates

## Task handoff (Primary → chief)

```text
Owner: {HQ chief name and role}
Why this owner: {one line}
Context and links: {Agents / Projects paths}
Done when: {testable outcome}
Human approval needed: {yes/no + what}
Next check: {time or trigger}
Constraints: {budget, freeze, do-not-touch}
```

## Specialist assignment (chief → specialist)

```text
Assignee: {agent}
Parent: {chief}
Ticket / TODO: {Projects → … → TODO item}
Acceptance criteria:
- …
Out of scope:
- …
Design / spec links: …
```

## Daily / weekly chief brief → Primary

```markdown
# {HQ} brief — {date}

## Done since last brief
- …

## In progress
- … (blocker: …)

## Decisions needed from Primary / Human
1. …

## Risks
- …

## Links
- …
```

## Pre-gate critique (optional, before human decisions)

Use when Primary must harden an item before the human sees it:

```text
Item: {title + link}
Strongest objections (ranked):
1. …
2. …
3. …
Counter-proposal: …
Open objection left on the item: {one line or none}
```

## Group welcome paste

```text
{HQ or Board} — current organization, {date}.
Members: …
Coordinator: Primary routes; chiefs own delivery.
Only Primary reaches the Human.
Workspace pages are the source of truth.
This page documents membership; applying it to a live chat group must be verified separately.
```

## Archive note (lifecycle)

```markdown
## Lifecycle / History
- {YYYY-MM-DD} — Archived. Reason: … Work routes to: {replacement}.
- {YYYY-MM-DD} — Created / restored / role change: …
```
