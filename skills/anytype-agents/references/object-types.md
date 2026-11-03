# Object types (Agent, Team, Project)

Org inventory uses dedicated Anytype types (not plain `page`) so you can filter,
feature properties, and start from body templates. Discover live keys with
`API-list-types` / `API-get-type` and templates with `API-list-templates`.

Skills, Shared Rules, Groups, memory children, and other hub pages stay type
`page` unless the space defines otherwise.

## Type keys

| Type key | Plural | Use for |
|----------|--------|---------|
| `agent` | Agents | Primary, chiefs, specialists, archived agents |
| `team` | Teams | Board, HQs, sub-teams, groups-as-org-units when typed |
| `project` | Projects | Portfolio roots under the Projects hub (built-in type, extended) |

Hub roots named **Agents** / **Projects** may remain `page`; their inventory
children use the keys above.

## Agent (`api_key`: `agent`)

Featured properties (API keys):

| Key | Format | Notes |
|-----|--------|-------|
| `role` | text | e.g. Primary, Chief, Implementer |
| `team` | objects | Link to owning Team |
| `reports_to` | objects | Link to chief / Primary agent |
| `lifecycle` | select | `draft` \| `live` \| `archived` |
| `harness` | select | `hermes` \| `grok` \| `claude` \| `codex` \| `noodle` \| `cli` \| `other` |

Other properties:

| Key | Format | Notes |
|-----|--------|-------|
| `autonomy` | select | `read-only` \| `propose` \| `change-with-gates` |
| `hermes_profile` | text | Profile slug when harness is Hermes |
| `primary_model` | text | Short model label |
| `short_description` | text | One-liner mission |

Also includes shared `tag`, `links`, `backlinks`.

**Default template name:** `Agent default` (sections: Suggested runtime including
Subagents and Scheduled tasks, Autonomy, Short Description, Full System Prompt
fence, Memory Pages). Body shapes: `page-templates.md`; runtime fields:
`suggested-runtime.md`.

## Team (`api_key`: `team`)

| Key | Format | Notes |
|-----|--------|-------|
| `kind` | select | `Board` \| `HQ` \| `Sub-team` \| `Group` |
| `chief` | objects | Link to chief Agent |
| `parent_team` | objects | Parent Team / HQ |
| `lifecycle` | select | Shared with Agent (`draft` / `live` / `archived`) |
| `mission` | text | Short mission |

Also `tag`, `links`, `backlinks`.

**Default template name:** `Team default` (Mission, Sub-teams / Domains / Members,
Routing, Rules, Map). Mirror shapes in `page-templates.md` (HQ page).

## Project (`api_key`: `project`)

Built-in Project type extended with org fields:

| Key | Format | Notes |
|-----|--------|-------|
| `project_status` | select | `Active` \| `Other` \| `Archived` |
| `project_category` | select | `Core Platform` \| `Consumer Apps` \| `Research` \| `AI & Content` \| `B2B` \| `Tools` \| `Other` |
| `owning_team` | objects | Link to Team |
| `git_hub` | url | Repo URL (API key is `git_hub`) |
| `public_url` | url | Public product URL |
| `one_liner` | text | Positioning line |

**Default template name:** `Project default` (Overview, Features, Architecture,
Users, Differentiators, related projects, common children callout).

## Create with type + template

Prefer typed creates. Omit `template` when the type has a default; pass a
template id from `API-list-templates` when you need a specific one; pass
`"none"` for an empty body.

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "agent",
    "name": "Lee – Implementer",
    "icon": { "format": "emoji", "emoji": "🛠️" },
    "properties": {
      "role": "Implementer",
      "lifecycle": "draft",
      "harness": "hermes",
      "autonomy": "change-with-gates",
      "short_description": "Implements one Ready coding TODO…"
    },
    "markdown": "## Short Description\n…"
  }
}
```

Team / project the same way with `"type": "team"` or `"type": "project"` and the
property keys above.

## Search by type

```json
{
  "space_id": "<spaceId>",
  "type": "agent",
  "limit": 50,
  "fields": ["name", "role", "lifecycle", "harness"]
}
```

Use `"type": "team"` or `"type": "project"` the same way.

## Migrate an existing page (`set_type`)

Keep the same object id and links. Apply `set_type` then `set_properties` in one
`API-patch-object` (atomic). `set_properties` values go under `set`, not
`properties`.

```json
{
  "space_id": "<spaceId>",
  "object_id": "<objectId>",
  "create_missing_options": true,
  "ops": [
    { "op": "set_type", "type": "agent" },
    {
      "op": "set_properties",
      "set": {
        "role": "Primary",
        "lifecycle": "live",
        "harness": "grok"
      }
    }
  ]
}
```

Recommended inventory scope: Agents hub agents + Board/HQ/sub-teams, and Projects
hub portfolio roots. Leave Skills, Shared Rules, memory children, bugs, and other
support pages as `page`.

## Bootstrap types in a new space

1. `API-create-type` for `agent` and `team` with the property definitions above
   (`create_missing_options: true` for selects).
2. `API-update-type` on built-in `project` with `add_property` ops for the Project
   fields (or create them once if the space already has matching keys).
3. `API-create-template` with `template_for`: `agent` | `team` | `project`.
4. `API-update-type` body `{ "default_template": "<templateId>" }` per type.
5. Migrate existing inventory with `set_type` as above.

Do not hardcode space or template ids in skill text; resolve them via list/get
each session.

## What stays `page`

- Agents / Projects hub roots (optional)
- Shared Rules, Skill Template, Skills indexes
- Agent memory children (Skills, Operating Notes, …)
- Group welcome pages when not modeled as Team `kind: Group`
- Drafts hub scaffolding, misc notes
