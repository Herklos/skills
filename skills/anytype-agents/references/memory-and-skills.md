# Memory + Skill + Log types

Durable agent notes live as typed **`memory`** objects. Runnable procedures live
as typed **`skill`** objects. Per-action activity summaries live as typed
**`log`** objects. Skills indexes and Logs indexes are **Queries** (not typed
skills/logs). Editing Anytype still does not push into live Hermes; remind
separately.

Property keys and create recipes: this file. Type inventory: `object-types.md`.
Body shapes: `page-templates.md` / `type-templates.md`.

## Type keys

| Type key | Plural | Use for |
|----------|--------|---------|
| `memory` | Memories | Memory & Decisions, Lessons Learned, Resources, Operating Notes, playbooks, other agent support notes |
| `skill` | Skills | Procedures, Skill Template, how-to guides |
| `log` | Logs | Small per-action summaries of what an agent did |

**Default templates:** `Memory default`, `Skill default`, `Log default`.

Skills **indexes** are type **`query`** filtered over `skill` (Agent / Team /
Subteam / Global). Point at them via `skills_page`. Logs **indexes** are type
**`query`** filtered over `log` by `owner_agent`. Point at them via
`logs_page`.

## Memory properties

| Key | Format | Notes |
|-----|--------|-------|
| `memory_kind` | select | `memory_decisions` \| `lessons` \| `resources` \| `operating_notes` \| `playbook` \| `other` (featured) |
| `lifecycle` | select | Shared `draft` \| `live` \| `archived` (featured) |
| `owner_agent` | objects | Owning Agent (featured; required for agent memory) |
| `owner_team` | objects | Optional HQ-shared notes |
| `owner_subteam` | objects | Optional |
| `cadence` | text | Optional (weekly scorecard, Monday retro) |
| `last_reviewed` | date | Optional |
| `notes` | text | Short intent |

## Skill properties

| Key | Format | Notes |
|-----|--------|-------|
| `skill_kind` | select | `procedure` \| `template` \| `guide` (featured) |
| `skill_key` | text | lowercase-hyphen id (featured) |
| `skill_scope` | select | `global` \| `team` \| `subteam` \| `agent` \| `project` (featured) |
| `skill_status` | select | `draft` \| `active` \| `deprecated` \| `archived` (featured) |
| `version` | text | semver string |
| `intent` | text | Router description: third person what + when (featured) |
| `owner_agent` | objects | 0..1 (featured) |
| `owner_team` | objects | 0..1 HQ |
| `owner_subteam` | objects | 0..1 |
| `owner_project` | objects | 0..1 |
| `parent_skill` | objects | e.g. launch-* → base launch skill |
| `related_skills` | objects | Progressive disclosure / siblings |
| `box_path` | text | Optional legacy mirror path |
| `reviewed_by` | objects | Skills/HR owner when non-trivial |
| `notes` | text | |

Do **not** add Times used / Last used (Shared Rules forbid usage logging).

## Log properties

| Key | Format | Notes |
|-----|--------|-------|
| `owner_agent` | objects | Owning Agent (featured; required) |
| `logged_at` | date | When the action happened (featured) |
| `summary` | text | One or two sentences: what the agent did (featured) |
| `notes` | text | Optional extra detail |

Object **name** should match or shorten `summary` (e.g. `Migrated Skills indexes to Queries`). Body holds optional Context / Outcome.

Logs are **activity summaries**, not skill usage counters. Shared Rules still forbid Times used / Last used on skills.

## Link properties on other types

| On type | Key | Format | Points to |
|---------|-----|--------|-----------|
| `agent` | `memory_pages` | objects | Memory objects (not Skills indexes) |
| `agent` | `skills_page` | objects | Skills **Query** for this agent |
| `agent` | `logs_page` | objects | Logs **Query** for this agent |
| `team` | `skills_page` | objects | HQ Skills Query |
| `subteam` | `skills_page` | objects | Domain Skills Query |

## Naming

| Kind | Name pattern |
|------|----------------|
| memory | `{Kind label} – {OwnerShort}` e.g. `Lessons Learned – Étienne`, `Memory & Preferences – Philippe` |
| skill procedure | keep hyphen `skill_key` as object name (e.g. `run-qa`) |
| skill template / guide | keep existing title when `set_type` in place |
| Skills Query | `{OwnerShort} – Skills` or `Skills – Global` / `{HQ} – Skills` |
| log | short action summary (also set `summary`) |
| Logs Query | `{OwnerShort} – Logs` |

## Resolution order

**Agent → Subteam → Team → Project → Global** via typed Skills + owner Queries.
Prefer the most specific matching active skill. Do not invent skills mid-flight;
create via Skill default / Skill Template (`skill_kind=template`).

## Create Memory + link an Agent

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "memory",
    "name": "Lessons Learned – Lee",
    "properties": {
      "memory_kind": ["lessons"],
      "lifecycle": ["live"],
      "owner_agent": ["<agentId>"]
    },
    "markdown": "## Purpose\nFailure log and retros.\n\n## Entries\n\n## Notes\n"
  }
}
```

Then `set_properties` on the Agent: `memory_pages` includes the new id (and peers).

Core set for a new agent: Memory & Decisions, Lessons Learned, Resources,
Operating Notes, plus a Skills Query (below).

## Create Skill + Skills Query

1. Create type `skill` with `skill_kind=procedure`, `skill_key`, `skill_scope`,
   `skill_status`, `intent`, matching `owner_*`
2. Body: Goal / When to use / Prerequisites / Procedure+Verify / Output /
   Gotchas / Checklist / Progressive disclosure / Change log (Skill default)
3. Ensure a Query exists for that owner; it picks up the skill via `owner_*` /
   `skill_scope` filters

```json
{
  "space_id": "<spaceId>",
  "name": "Lee – Skills",
  "type": "skill",
  "filter": "owner_agent IN (\"<agentId>\")",
  "sorts": [{ "property": "skill_key", "direction": "asc" }]
}
```

Patch Agent / Team / Subteam: `skills_page=[<queryId>]`.

Global Query example: `skill_scope IN ("global")` (optionally AND
`skill_status IN ("active")`).

## Create Log + Logs Query

After a meaningful action (handoff, migrate, ship, decide), create a Log:

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "log",
    "name": "Migrated Skills indexes to Queries",
    "properties": {
      "owner_agent": ["<agentId>"],
      "logged_at": "2026-11-04",
      "summary": "Migrated Skills indexes to Queries for live agents."
    },
    "markdown": "## Summary\nMigrated Skills indexes to Queries for live agents.\n\n## Context\nMemory + Skill redesign.\n\n## Outcome\nAgent.skills_page linked; old indexes Binned.\n\n## Notes\n"
  }
}
```

Ensure a Logs Query exists for that agent (created once with the agent):

```json
{
  "space_id": "<spaceId>",
  "name": "Lee – Logs",
  "type": "log",
  "filter": "owner_agent IN (\"<agentId>\")",
  "sorts": [{ "property": "logged_at", "direction": "desc" }]
}
```

Patch Agent: `logs_page=[<queryId>]`. New Log objects appear automatically via
the filter.

### Logs Calendar (date index)

Add a **Calendar** view on `logged_at` so the agent memory/Logs section can
filter activity by date (Anytype Date Objects). Keep the table **All** view
sorted by `logged_at` desc for undated / backlog rows.

```json
{
  "op": "insert_view",
  "name": "Calendar",
  "position": "first",
  "set": {
    "type": "calendar",
    "end_property": "logged_at",
    "sorts": [
      {
        "property": "logged_at",
        "direction": "desc",
        "empty_placement": "end"
      }
    ]
  },
  "columns": {
    "logged_at": { "width": 200 },
    "name": { "width": 280 },
    "summary": { "width": 320 }
  }
}
```

Org fill: every live agent Logs Query has Calendar + All. Set `logged_at` when
creating Logs so they plot on the calendar.

Keep entries short. Prefer one Log per discrete action, not a running diary
inside Memory.

## Migrate in place

Prefer `set_type` (keeps id and links), then properties + rename:

```json
{
  "ops": [
    { "op": "set_type", "type": "memory" },
    {
      "op": "set_properties",
      "set": {
        "name": "Resources – Lee",
        "memory_kind": ["resources"],
        "lifecycle": ["live"],
        "owner_agent": ["<agentId>"]
      }
    }
  ]
}
```

Same pattern for `skill` with Metadata parsed into `skill_key` / `skill_scope` /
`skill_status` / `intent` / `owner_*`.

Replace old Skills **index pages** with Queries, set `skills_page`, then Bin the
index page (not permanent unless approved).

## Search

```json
{
  "space_id": "<spaceId>",
  "type": "memory",
  "limit": 100,
  "fields": ["name", "memory_kind", "lifecycle", "owner_agent"]
}
```

```json
{
  "space_id": "<spaceId>",
  "type": "skill",
  "limit": 100,
  "fields": ["name", "skill_key", "skill_kind", "skill_scope", "skill_status", "owner_agent"]
}
```

```json
{
  "space_id": "<spaceId>",
  "type": "log",
  "limit": 100,
  "fields": ["name", "logged_at", "summary", "owner_agent"]
}
```

## Bootstrap in a new space

1. `API-create-type` `memory`, `skill`, and `log` (`create_missing_options: true`);
   reuse shared `lifecycle`, `owner_agent`, `notes` via `"property"` keys when present
2. `API-create-template` Memory default / Skill default / Log default; set
   `default_template`
3. On Agent: ensure `memory_pages`; `add_property` **Skills page** (`skills_page`)
   and **Logs page** (`logs_page`) reusing shared property keys when possible
4. Migrate live memory pages + procedures; convert indexes to Queries; create
   Logs Query per live agent and set `logs_page`

## Hermes skills sync (when asked)

Anytype remains the procedure source of truth. When the user asks to apply /
full-sync an Agent into Hermes:

1. List active procedures on Agent.`skills_page` (`skill_kind=procedure`,
   `skill_status=active`, matching `owner_agent`).
2. Write `$HERMES_HOME/skills/org/<skill_key>/SKILL.md` (front matter + steps
   from the Anytype body). Optional `skills/org/DESCRIPTION.md` naming the
   folder as Anytype-synced.
3. Put Anytype `skill` object id + `skill_key` in Hermes skill metadata.
4. Do **not** delete Hermes builtin / hub skills. Additive only.
5. Schedule.`skills` comma list → Hermes cron `--skill org/<skill_key>` after
   the copy exists.
6. Playbook: `hermes-profiles` → `anytype-apply.md` (Org skills step).

## Out of scope

- Backup / restore / snapshot / Mémoire dump pages stay `page`
- Usage counters on skills
- Auto-pushing Anytype skill edits into Hermes without an apply ask
- Replacing Hermes builtin skill trees with Anytype copies
