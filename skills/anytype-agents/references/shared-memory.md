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
report drift, one Log. Simple work: the Memory Keeper. Real decisions (conflict,
superseding a human decision, rules / prompts / roster, personal data, forget):
escalate to Primary as a `suggestion`.

## Versioning

`version` on Shared Rules and Operating Guide (minor = new rule, patch =
wording, major = HARD change). One `log` per change. `applied_rules_version`
on the Agent is written at apply. Drift is reported, never auto-applied.

## Hermes pointers (when asked to apply)

`USER.md` = About digest; `MEMORY.md` = memory titles only (limits 1375 / 2200
chars); set `applied_rules_version`; `sessions refresh-prompts`; `/new`.
Playbook: `hermes-profiles` `anytype-apply.md`.
