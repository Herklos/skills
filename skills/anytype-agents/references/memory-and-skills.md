# Memory + Skill types

Durable agent notes live as typed **`memory`** objects. Runnable procedures live
as typed **`skill`** objects. Skills indexes are **Queries** of `skill` (not
typed skills). Editing Anytype still does not push into live Hermes; remind
separately.

Property keys and create recipes: this file. Type inventory: `object-types.md`.
Body shapes: `page-templates.md` / `type-templates.md`.

## Type keys

| Type key | Plural | Use for |
|----------|--------|---------|
| `memory` | Memories | Memory & Decisions, Lessons Learned, Resources, Operating Notes, playbooks, other agent support notes |
| `skill` | Skills | Procedures, Skill Template, how-to guides |

**Default templates:** `Memory default`, `Skill default`.

Skills **indexes** are type **`query`** filtered over `skill` (Agent / Team /
Subteam / Global). Point at them via `skills_page`.

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

## Link properties on other types

| On type | Key | Format | Points to |
|---------|-----|--------|-----------|
| `agent` | `memory_pages` | objects | Memory objects (not Skills indexes) |
| `agent` | `skills_page` | objects | Skills **Query** for this agent |
| `team` | `skills_page` | objects | HQ Skills Query |
| `subteam` | `skills_page` | objects | Domain Skills Query |

## Naming

| Kind | Name pattern |
|------|----------------|
| memory | `{Kind label} – {OwnerShort}` e.g. `Lessons Learned – Étienne`, `Memory & Preferences – Philippe` |
| skill procedure | keep hyphen `skill_key` as object name (e.g. `run-qa`) |
| skill template / guide | keep existing title when `set_type` in place |
| Skills Query | `{OwnerShort} – Skills` or `Skills – Global` / `{HQ} – Skills` |

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

## Bootstrap in a new space

1. `API-create-type` `memory` and `skill` (`create_missing_options: true`); reuse
   shared `lifecycle`, `owner_agent`, `notes` via `"property"` keys when present
2. `API-create-template` Memory default / Skill default; set `default_template`
3. On Agent: ensure `memory_pages`; `add_property` **Skills page** (`skills_page`)
   reusing the Team/Subteam property key when possible
4. Migrate live memory pages + procedures; convert indexes to Queries

## Out of scope

- Backup / restore / snapshot / Mémoire dump pages stay `page`
- Usage counters on skills
- Live Hermes apply until the user says the redesign is done
