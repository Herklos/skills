# Object types (Agent, Team, Subteam, Harness, Harness profile, Project)

Org inventory uses dedicated Anytype types (not plain `page`) so you can filter,
feature properties, and start from body templates. Discover live keys with
`API-list-types` / `API-get-type` and templates with `API-list-templates`.

Skills, Shared Rules, Groups, memory children, and other hub pages stay type
`page` unless the space defines otherwise.

## Type keys

| Type key | Plural | Use for |
|----------|--------|---------|
| `agent` | Agents | Primary, chiefs, specialists, archived agents |
| `team` | Teams | Board, HQs, and groups-as-org-units when typed |
| `subteam` | Subteams | Domains / pods under an HQ (**preferred**; do not model these as `team` with `kind: Sub-team`) |
| `harness` | Harnesses | Product catalog: Claude, Codex, Grok, GitHub Copilot, Muse, NVIDIA NIM, Local model |
| `harness_profile` | Harness profiles | Reusable model stacks (primary + backups). Agents link here so one edit updates many agents |
| `project` | Projects | Portfolio roots under the Projects hub (built-in type, extended) |

Hub roots named **Agents** / **Projects** may remain `page`; their inventory
children use the keys above. Keep Harness + Harness profile objects under
Agents → Shared (or a Harnesses index).

Skills resolution order when a space uses Subteams:
**Agent → Subteam → Team → Project → Global**.

## Agent (`api_key`: `agent`)

Featured properties (API keys):

| Key | Format | Notes |
|-----|--------|-------|
| `role` | text | e.g. Primary, Chief, Implementer |
| `team` | objects | Link to owning Team or Subteam |
| `reports_to` | objects | Link to chief / Primary agent |
| `lifecycle` | select | `draft` \| `live` \| `archived` |
| `harness_profile` | objects | Link to one **Harness profile** (source of primary + backup models) |

Other properties:

| Key | Format | Notes |
|-----|--------|-------|
| `autonomy` | select | `read-only` \| `propose` \| `change-with-gates` |
| `hermes_profile` | text | Optional Hermes home slug when applying via `hermes-profiles` |
| `primary_model` | text | Optional agent-local override note; prefer the linked Harness profile |
| `short_description` | text | One-liner mission |

Also includes shared `tag`, `links`, `backlinks`.

**Do not** use a select `harness` on Agent. Legacy spaces may still have an old
`harness` select (`hermes` / `grok` / …); migrate by linking `harness_profile`
and removing `harness` from the Agent type (`remove_property`).

**Default template name:** `Agent default`. Full dumped body:
`type-templates.md`. Also: `page-templates.md`; runtime fields:
`suggested-runtime.md`.

## Team (`api_key`: `team`)

| Key | Format | Notes |
|-----|--------|-------|
| `kind` | select | `Board` \| `HQ` \| `Group` |
| `chief` | objects | Link to chief Agent |
| `parent_team` | objects | Parent Team when nested (rare; HQs usually sit under Agents) |
| `lifecycle` | select | Shared with Agent (`draft` / `live` / `archived`) |
| `mission` | text | Short mission |

Also `tag`, `links`, `backlinks`.

**Default template name:** `Team default`. Full dumped body: `type-templates.md`.
Mirror shapes in `page-templates.md` (HQ page). Link child **`subteam`** objects
from the HQ map; do not create new Sub-teams as `team`.

Legacy: older spaces may still have `team` objects with `kind: Sub-team`. Prefer
migrating those to type **`subteam`** via `set_type` (see below). Do not mint new
`Sub-team` select options.

## Subteam (`api_key`: `subteam`)

Dedicated type for domains / pods under an HQ. Prefer this over putting
sub-teams on the `team` type.

| Key | Format | Notes |
|-----|--------|-------|
| `parent_team` | objects | Owning HQ / Team (required when known) |
| `chief` | objects | Lead agent when the subteam has one (else HQ chief) |
| `lifecycle` | select | Shared with Agent / Team (`draft` / `live` / `archived`) |
| `mission` | text | Short domain mission |

Also `tag`, `links`, `backlinks`. No `kind` property: the type itself is the kind.

**Default template name:** `Subteam default`. Full dumped body (skill-authored
until live): `type-templates.md`. Also `page-templates.md` (Subteam page).

Agent `team` (objects) may link the owning HQ **or** this Subteam when the agent
sits under a domain.

## Harness (`api_key`: `harness`)

Product catalog entry. One object per product agents may run on.

| Key | Format | Notes |
|-----|--------|-------|
| `slug` | text | Stable id: `claude` \| `codex` \| `grok` \| `github-copilot` \| `muse` \| `nvidia-nim` \| `local-model` |
| `lifecycle` | select | `draft` \| `live` \| `archived` |
| `vendor` | text | Optional vendor label |
| `docs_url` | url | Optional docs |
| `notes` | text | Short capability notes |

Also `tag`, `links`, `backlinks`.

**Canonical catalog (create these once):** Claude, Codex, Grok, GitHub Copilot,
Muse, NVIDIA NIM, Local model (matching slugs above).

**Default template name:** `Harness default`. Body: `type-templates.md`.

## Harness profile (`api_key`: `harness_profile`)

Reusable model stack. Many agents share one profile; edit the profile to refresh
every linked agent's intended primary / backups.

| Key | Format | Notes |
|-----|--------|-------|
| `intent` | text | e.g. `coding`, `data-fetching`, `ops`, `research` |
| `lifecycle` | select | `draft` \| `live` \| `archived` |
| `primary_harness` | objects | Link to one **Harness** |
| `primary_model` | text | Model id / label (e.g. `Claude Code Sonnet 5.5`, `Codex Terra 6.1`) |
| `primary_effort` | select | `low` \| `medium` \| `high` |
| `backup_1_harness` | objects | First backup Harness |
| `backup_1_model` | text | First backup model |
| `backup_1_effort` | select | `low` \| `medium` \| `high` |
| `backup_2_harness` | objects | Second backup Harness |
| `backup_2_model` | text | Second backup model |
| `backup_2_effort` | select | `low` \| `medium` \| `high` |
| `notes` | text | When to use this profile |

Also `tag`, `links`, `backlinks`. Put longer rationale and apply notes in the body.

**Example profiles:**

| Profile | Primary | Backup 1 | Backup 2 |
|---------|---------|----------|-----------|
| Coding | Claude · Sonnet 5.5 · high | Codex · Sol 6.1 · high | Grok · 4.5 · high |
| Data fetching | Codex · Terra 6.1 · high | Claude · Haiku 5.5 · medium | Grok · 4.5 · medium |

**Default template name:** `Harness profile default`. Body: `type-templates.md`.

Apply: when an agent's Suggested runtime or live bot models change, update the
**Harness profile** object, then re-apply to each linked agent's runtime (Anytype
does not auto-push into Claude/Codex/Grok/…).

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

**Default template name:** `Project default`. Full dumped body:
`type-templates.md`.

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
      "harness_profile": ["<codingHarnessProfileObjectId>"],
      "autonomy": "change-with-gates",
      "short_description": "Implements one Ready coding TODO…"
    },
    "markdown": "## Short Description\n…"
  }
}
```

Team / Subteam / Harness / Harness profile / project the same way with the matching
`"type"` and property keys above.

## Search by type

```json
{
  "space_id": "<spaceId>",
  "type": "agent",
  "limit": 50,
  "fields": ["name", "role", "lifecycle", "harness_profile"]
}
```

Use `"type": "team"`, `"type": "subteam"`, `"type": "harness"`,
`"type": "harness_profile"`, or `"type": "project"` the same way.

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
        "harness_profile": ["<harnessProfileObjectId>"]
      }
    }
  ]
}
```

Recommended inventory scope: Agents hub agents + Board/HQ (`team`) + Subteams
(`subteam`) + Harnesses + Harness profiles, and Projects hub portfolio roots.
Leave Skills, Shared Rules, memory children, bugs, and other support pages as
`page`.

### Migrate legacy `team` + `kind: Sub-team` → `subteam`

```json
{
  "space_id": "<spaceId>",
  "object_id": "<objectId>",
  "create_missing_options": true,
  "ops": [
    { "op": "set_type", "type": "subteam" },
    {
      "op": "set_properties",
      "set": {
        "lifecycle": "live",
        "parent_team": ["<hqTeamObjectId>"],
        "mission": "…"
      }
    }
  ]
}
```

Keep `parent_team` / `chief` / `mission` when the keys already exist on the
object; re-set only what is missing after the type change.

## Bootstrap types in a new space

1. `API-create-type` for `agent`, `team`, `subteam`, `harness`, and
   `harness_profile` with the property definitions above
   (`create_missing_options: true` for selects). On `team`, define `kind` options
   `Board` / `HQ` / `Group` only (no `Sub-team`).
2. On existing Agent types: `add_property` `harness_profile` (objects, featured);
   `remove_property` legacy `harness` select when ready.
3. `API-update-type` on built-in `project` with `add_property` ops for the Project
   fields (or create them once if the space already has matching keys).
4. `API-create-template` with `template_for`: `agent` | `team` | `subteam` |
   `harness` | `harness_profile` | `project` and body markdown from
   **`type-templates.md`**.
5. `API-update-type` body `{ "default_template": "<templateId>" }` per type.
6. Create the seven Harness catalog objects; create Harness profiles (Coding,
   Data fetching, …); link agents via `harness_profile`.
7. Migrate existing inventory with `set_type` as above (including legacy Sub-team
   `team` objects → `subteam`).

Do not hardcode space or template ids in skill text; resolve them via list/get
each session.

## What stays `page`

- Agents / Projects hub roots (optional)
- Shared Rules, Skill Template, Skills indexes
- Agent memory children (Skills, Operating Notes, …)
- Group welcome pages when not modeled as Team `kind: Group`
- Drafts hub scaffolding, misc notes
