# Shared memory layer (human profile, atomic facts, capture, versions)

Notion-style "shared brain" on top of the typed Memory / Log model. Anytype is
the source of truth; each runtime (Hermes, Osaurus, Grok Bot, Noodle) keeps
pointers or a short digest only. Editing Anytype never pushes into a live bot.

Property keys: `memory-and-skills.md` and `object-types.md`.

## Objects

| Object | Type | Notes |
|--------|------|-------|
| Operating Guide | `prompt`, `prompt_kind=operating_guide`, `version` | Read once per session by every agent. Where each kind of item goes, conflict order, offline rule, owners, per-runtime pointers |
| About {Human} | `memory`, `memory_kind=profile`, `memory_scope=human`, no `owner_agent` | Profile, preference links, Exclusions link, USER.md digest (< 1375 chars) |
| Preferences | `memory`, `memory_kind=preference`, `memory_scope=human` | One per preference; `topic`, `observed_at`, `source_agent` |
| Exclusions | `memory`, `memory_kind=exclusion`, `memory_scope=org` | Never-save list, forget protocol, tombstones |
| Onboarding | `prompt`, `prompt_kind=library`, `version` | Reusable setup prompt (Basic vs Shared level) |
| Changelog | `log` per rules change + Query filtered on summary | `Shared Rules vX.Y.Z: ...` |
| Drift | Query on `agent` | `lifecycle=live` and `applied_rules_version` empty or not current |

## Atomic memory rules

- One object per durable fact, decision or preference. Set `topic`,
  `observed_at`, `source_agent`, `source_url` when any, `memory_scope`.
- Create with **`template: "none"`**. The `Memory default` template adds bucket
  placeholders (Purpose / Entries / Notes). Body = `## Statement` + `## Source`.
- Search `type=memory` by topic first; merge into the hit and update
  `observed_at`; a replaced fact sets `supersedes`.
- Atomic decisions use `memory_kind=memory_decisions` (no separate `decision`).
- Bucket memories (Memory & Decisions, Lessons, Resources, Operating Notes)
  stay as agent-owned views.

## Four layers (Shared Rule 30)

| Layer | Object | Created by | Rule |
|-------|--------|------------|------|
| 1 Logs | `log` | every agent, one per action | raw, immutable |
| 2 Memories | atomic `memory` (fact / memory_decisions / preference) | agents, Memory Keeper from Logs | one fact per object, `topic`, `observed_at`, `source_agent` |
| 3 Learnings | `memory` with `memory_kind=learning` | Memory Keeper (owners via suggestion) | pattern from 3+ memories or logs |
| 4 Skills / Shared Rules | `skill`, rules | via `suggestion` (Solange / Primary review) | learning repeated 3+ weeks |

Learnings are a **kind**, not a type. Required: `derived_from` (every source),
`applies_to`, `confidence`, `topic`, `observed_at`; body = one insight +
Evidence list. Guardrails (from ACE, Hindsight, authority-collapse research):

- Derived, never source of truth: on conflict the source memory / log wins and
  the Learning returns to `lifecycle=draft`.
- Never rewrite wholesale (context collapse); add, merge or amend one item.
- Cite human decisions, do not restate them; decision-derived Learnings or
  ones that touch rules / prompts / roster stay `draft` until Primary approves.
- `confidence=high` needs 3+ independent sources or an explicit human statement.
- Never from unlogged claims or content covered by Exclusions.

Bucket memories (Memory & Decisions, Operating Notes) are classified item by
item, never copied 1:1: preference -> About / `preference`; decision or fact ->
atomic memory; recurring pattern -> Learning; diary or run log -> stay (or
`log`). `lessons` buckets are raw retro journals (failure log, ops retros), a
source for Learnings, not Learnings themselves. Working docs (Open Loops,
Approvals Waiting, Briefs, Playbooks) are out of scope.

## Queries

`topic IS NOT EMPTY` selects atomic memories (`topic != ""` does not filter
empties). Compact grammar: schema kind `filters`. Typical set: Memories –
Human, Memories – Atomic (All), Memories – Decisions (atomic), Memories –
Facts, Rules – Changelog, Agents – Drift (literal version in the filter; bump
when Shared Rules version changes).

## Capture loop and owners

Schedule `daily-memory-capture` (owner: the Memory Keeper, `0 5 * * *`
Europe/Paris, draft + paused until roster confirm). Pre-check (no change = one
log line), read Exclusions + tombstones, promote new Log facts, merge by topic,
report drift, one Log. Simple work: the Memory Keeper (Agent `autonomy=change-with-gates`: may create
atomic memories and Learnings, never edit others' memories unapproved; her system
Prompt carries a "Memory layers" section and Primary's carries "Memory and
Learnings"; other agents inherit via the Shared Rules pointer). Real decisions (conflict,
superseding a human decision, rules / prompts / roster, personal data, forget):
escalate to Primary as a `suggestion`.

Weekly (Sunday 18:00, inside `weekly-memory-hygiene`): Memories -> Learnings.
The daily run only lists candidate topics (3+ uncited memories on one topic, or
a bucket over ~60 blocks) in its Log. Learnings queries: `Learnings – All`
(`memory_kind IN ("learning")`), `Learnings – To review` (+ `lifecycle` draft).

## Versioning

`version` on Shared Rules and Operating Guide (minor = new rule, patch =
wording, major = HARD change). One `log` per change. `applied_rules_version`
on the Agent is written at apply. Drift is reported, never auto-applied.

## Hermes pointers (when asked to apply)

`USER.md` = About digest; `MEMORY.md` = memory titles only (limits 1375 / 2200
chars); set `applied_rules_version`; `sessions refresh-prompts`; `/new`.
Playbook: `hermes-profiles` `anytype-apply.md`.
