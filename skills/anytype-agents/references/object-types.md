# Object types (Agent, Team, Subteam, Subagent, Harness, Harness profile, Project)

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
| `subagent` | Subagents | Spawn configs an Agent may start (task, harness profile, scope, tools). Not the same as `subteam` |
| `harness` | Harnesses | Product catalog: Claude, Codex, Grok, GitHub Copilot, Muse, NVIDIA NIM, Local model |
| `harness_profile` | Harness profiles | Reusable model stacks (primary + backups). Agents and Subagents link here |
| `project` | Projects | Portfolio roots under the Projects hub (built-in type, extended) |

Hub roots named **Agents** / **Projects** may remain `page`; their inventory
children use the keys above. Keep Harness + Harness profile objects under
Agents → Shared (or a Harnesses index). Keep Subagent objects linked from their
parent Agent (`parent_agent` + Agent.`subagents`).

**Name collision:** `subteam` = org domain under an HQ. `subagent` = runtime
worker/route the parent Agent can `delegate_task` (or equivalent). Do not mix them.

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
| `harness_profile` | objects | Link to one **Harness profile** (source of primary + backup models). **Default for most agents: Local router** |
| `subagents` | objects | Zero or more **Subagent** spawn configs this agent may start |

Other properties:

| Key | Format | Notes |
|-----|--------|-------|
| `autonomy` | select | `read-only` \| `propose` \| `change-with-gates` |
| `hermes_profile` | text | Optional Hermes home slug when applying via `hermes-profiles` |
| `primary_model` | text | Optional agent-local override note; prefer the linked Harness profile |
| `short_description` | text | One-liner mission |

Also includes shared `tag`, `links`, `backlinks`.

Keep Agent.`subagents` and each Subagent.`parent_agent` in sync (both ways).

**Recommended parent pattern (most agents):**
1. Agent.`harness_profile` → **Local router** (local model is the routing brain)
2. Several Subagents with richer profiles (Coding, Data fetching, …) for work that
   needs a stronger/cheaper specialized stack
3. Parent answers peers / light questions itself when no Subagent route is needed
   (no “quick answer” Subagent required)

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

## Subagent (`api_key`: `subagent`)

Spawn / route config a parent **Agent** may start. An agent has zero or more
Subagents. Distinct from **`subteam`** (org domain).

| Key | Format | Notes |
|-----|--------|-------|
| `parent_agent` | objects | Owning Agent (required). Keep in sync with Agent.`subagents` |
| `task_key` | text | Stable route name the parent picks (`fast`, `deep`, `fetch`, …). Maps to Hermes `model_map` option `name` |
| `harness_profile` | objects | **Harness profile** for this spawn (may differ from the parent's) |
| `lifecycle` | select | `draft` \| `live` \| `archived` |
| `intent` | text | Short when-to-use (becomes route `description` when declined to Hermes) |
| `scope` | text | Bounds: cwd, read-only, web-only, single-repo, … |
| `toolsets` | text | Enabled toolsets for the child (e.g. `web,terminal,file` or `inherit`) |
| `spawn_effort` | select | Optional override: `low` \| `medium` \| `high` (else use profile primary effort). Display name **Spawn effort** (avoids clash with a numeric Effort property) |
| `model_override` | text | Optional pin over the linked Harness profile primary |
| `deliver_back` | text | What the child must return to the parent (summary shape) |
| `notes` | text | Extra apply notes |

Also `tag`, `links`, `backlinks`.

**Default template name:** `Subagent default`. Body: `type-templates.md`.

**Hermes decline** (skill `hermes-profiles` → `delegation.md`): each live Subagent
on a parent becomes one `model_map` option (`task_key` → `name`, `intent` →
`description`, models from `harness_profile` / `model_override` / `spawn_effort`).
Toolsets and scope are documented on the Subagent and applied to the parent
prompt / child brief; Hermes children inherit the parent's tool policy unless
you use `profile_routes` for a dedicated child profile.

**Example Subagents** (link from Engineering chiefs / implementers):

| Name | task_key | Profile | Intent |
|------|----------|---------|--------|
| Fast fetch | `fetch` | Data fetching | Lookups, scrape, light summary |
| Deep code | `deep` | Coding | Hard debug, careful refactor |
| Quick edit | `fast` | Coding (lower effort note) | Small edits, simple tests |

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
| `intent` | text | e.g. `coding`, `data-fetching`, `ops`, `research`, `local-router` |
| `lifecycle` | select | `draft` \| `live` \| `archived` |
| `primary_harness` | objects | Link to one **Harness** |
| `primary_model` | text | Display label (e.g. `d1-2B-GGUF Q4_K_M`, `Claude Code Sonnet 5.5`) |
| `primary_effort` | select | `low` \| `medium` \| `high` |
| `decision_provider` | text | Hermes `model.provider` for the decision/routing slot when this profile is a **parent** stack (e.g. `llamacpp`). Leave empty on Subagent-only stacks |
| `decision_model` | text | Hermes `model.default` id for that slot (e.g. `d1-2b-q4_k_m`). Prefer over guessing from `primary_model` when set |
| `backup_1_harness` | objects | First backup Harness |
| `backup_1_model` | text | First backup model |
| `backup_1_effort` | select | `low` \| `medium` \| `high` |
| `backup_2_harness` | objects | Second backup Harness |
| `backup_2_model` | text | Second backup model |
| `backup_2_effort` | select | `low` \| `medium` \| `high` |
| `notes` | text | When to use this profile |

Also `tag`, `links`, `backlinks`. Put longer rationale and apply notes in the body.

**Decision model:** for parent/router profiles, Hermes main brain =
`decision_provider` + `decision_model` (falls back to resolving
`primary_harness` + `primary_model`). Apply with skill `hermes-profiles`
`models.md` (**Local decision model**). Do not invent values; read the profile.

**Example profiles:**

| Profile | Primary / decision | Backup 1 | Backup 2 | Typical use |
|---------|--------------------|----------|-----------|-------------|
| **Local router** | Local model · `llamacpp` / `d1-2b-q4_k_m` · medium | Grok · 4.5 · medium | Claude · Haiku 5.5 · medium | **Most Agents** (parent decision brain + quick peer answers) |
| Coding | Claude · Sonnet 5.5 · high | Codex · Sol 6.1 · high | Grok · 4.5 · high | Subagent routes (`deep`, `fast`, …); leave `decision_*` empty |
| Data fetching | Codex · Terra 6.1 · high | Claude · Haiku 5.5 · medium | Grok · 4.5 · medium | Subagent routes (`fetch`, …); leave `decision_*` empty |

Parent Agents usually link **Local router**. Subagents link Coding / Data fetching
(or other specialized stacks). The local parent picks a Subagent `task_key` when
needed and answers directly otherwise.

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
      "harness_profile": ["<localRouterHarnessProfileObjectId>"],
      "subagents": ["<fastFetchSubagentId>", "<deepCodeSubagentId>"],
      "autonomy": "change-with-gates",
      "short_description": "Implements one Ready coding TODO…"
    },
    "markdown": "## Short Description\n…"
  }
}
```

Create a Subagent the same way (`"type": "subagent"`) with `parent_agent`,
`task_key`, `harness_profile`, then add its id to the parent's `subagents`.

Team / Subteam / Subagent / Harness / Harness profile / project the same way with
the matching `"type"` and property keys above.

## Search by type

```json
{
  "space_id": "<spaceId>",
  "type": "agent",
  "limit": 50,
  "fields": ["name", "role", "lifecycle", "harness_profile", "subagents"]
}
```

Use `"type": "team"`, `"type": "subteam"`, `"type": "subagent"`, `"type": "harness"`,
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
(`subteam`) + Subagents (`subagent`) + Harnesses + Harness profiles, and Projects
hub portfolio roots. Leave Skills, Shared Rules, memory children, bugs, and other
support pages as `page`.

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

1. `API-create-type` for `agent`, `team`, `subteam`, `subagent`, `harness`, and
   `harness_profile` with the property definitions above
   (`create_missing_options: true` for selects). On `team`, define `kind` options
   `Board` / `HQ` / `Group` only (no `Sub-team`).
2. On existing Agent types: `add_property` `harness_profile` and `subagents`
   (objects, featured); `remove_property` legacy `harness` select when ready.
3. `API-update-type` on built-in `project` with `add_property` ops for the Project
   fields (or create them once if the space already has matching keys).
4. `API-create-template` with `template_for`: `agent` | `team` | `subteam` |
   `subagent` | `harness` | `harness_profile` | `project` and body markdown from
   **`type-templates.md`**.
5. `API-update-type` body `{ "default_template": "<templateId>" }` per type.
6. Create the seven Harness catalog objects; create Harness profiles (**Local
   router**, Coding, Data fetching, …); create Subagent spawn configs; link most
   agents to Local router + `subagents` (and Subagent.`parent_agent`).
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
