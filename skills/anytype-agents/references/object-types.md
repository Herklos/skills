# Object types (Agent, Team, Subteam, Subagent, Harness, Harness profile, Browser, Computer, Tool profile, Project)

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
| `browser` | Browsers | Reusable browser access catalog (source + identity). Agents / Teams / Subteams link here |
| `computer` | Computers | Reusable computer / desktop catalog (surface + scope). Agents / Teams / Subteams link here |
| `tool_profile` | Tool profiles | Reusable toolsets + approvals + terminal. Agents / Teams / Subteams link here |
| `project` | Projects | Portfolio roots under the Projects hub (built-in type, extended) |

Hub roots named **Agents** / **Projects** may remain `page`; their inventory
children use the keys above. Keep Harness + Harness profile + Browser + Computer
+ Tool profile objects under Agents → Shared (or a Runtime / Harnesses index).
Keep Subagent objects linked from their parent Agent (`parent_agent` +
Agent.`subagents`).

**Name collision:** `subteam` = org domain under an HQ. `subagent` = runtime
worker/route the parent Agent can `delegate_task` (or equivalent). Do not mix them.

Skills resolution order when a space uses Subteams:
**Agent → Subteam → Team → Project → Global**.

## Agent (`api_key`: `agent`)

**Properties hold structured facts.** Do not duplicate Short Description,
Autonomy, Board seat, map path, Hermes slug, browser / computer / tools, or
linked projects only in markdown. Body keeps **Suggested runtime** narrative
and **Full System Prompt**.

Featured properties (API keys):

| Key | Format | Notes |
|-----|--------|-------|
| `role` | text | e.g. Primary, Chief, Implementer |
| `team` | objects | Link to owning Team or Subteam |
| `reports_to` | objects | Link to chief / Primary agent |
| `lifecycle` | select | `draft` \| `live` \| `archived` |
| `harness_profile` | objects | Link to one **Harness profile** (source of primary + backup models). **Default for most agents: Local router** |
| `subagents` | objects | Zero or more **Subagent** spawn configs this agent may start |
| `browser` | objects | Link to one **Browser** catalog object |
| `computer` | objects | Link to one **Computer** catalog object |
| `tool_profile` | objects | Link to one **Tool profile** catalog object |
| `board_member` | checkbox | Board seat |
| `linked_projects` | objects | Projects this agent works |

Other properties:

| Key | Format | Notes |
|-----|--------|-------|
| `autonomy` | select | `read-only` \| `propose` \| `change-with-gates` |
| `hermes_profile` | text | Hermes home slug under `~/.hermes/profiles/<slug>` when applying via `hermes-profiles` |
| `primary_model` | text | Optional agent-local override note; prefer the linked Harness profile |
| `short_description` | text | One-liner mission |
| `memory_pages` | objects | Skills / Memory / Operating Notes children |
| `messaging_group` | objects | Group page / chat roster |
| `map_path` | text | `Agents → HQ → [Subteam →] Agent` |
| `delegation_enabled` | checkbox | Parent may spawn Subagents |
| `terminal_backend` | select | `cua` \| `local` \| `docker` \| `ssh` \| `other` (org default: `cua`; keep aligned with linked Tool profile) |
| `computer_surface` | select | `cua-spaces` \| `host` \| `bot-screen` \| `none` (org default: `cua-spaces`; keep aligned with linked Computer) |

Also includes shared `tag`, `links`, `backlinks`.

Prefer catalog links (`browser`, `computer`, `tool_profile`) as the structured
source for Suggested runtime Browser / Computer / Tools / Terminal detail. Keep
`terminal_backend` / `computer_surface` selects consistent with those links for
quick filters.

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

Board / HQ / Group only. Domains under an HQ use type **`subteam`**.

| Key | Format | Notes |
|-----|--------|-------|
| `kind` | select | `Board` \| `HQ` \| `Group` (featured) |
| `chief` | objects | Link to chief Agent (featured) |
| `members` | objects | Agent members (featured) |
| `parent_team` | objects | Parent Team when nested (rare; HQs usually sit under Agents) |
| `lifecycle` | select | Shared with Agent (`draft` / `live` / `archived`) |
| `subteams` | objects | Child **Subteam** objects (featured on HQ) |
| `mission` | text | Short mission |
| `messaging_group` | objects | Group page |
| `skills_page` | objects | HQ Skills index |
| `routing_summary` | text | One-line routing |
| `browser` | objects | Optional team-default **Browser** catalog link |
| `computer` | objects | Optional team-default **Computer** catalog link |
| `tool_profile` | objects | Optional team-default **Tool profile** catalog link |

Also `tag`, `links`, `backlinks`. Put long routing prose in the body; keep the
filterable one-liner in `routing_summary`. Agent-level runtime links override
team defaults when both are set.

**Default template name:** `Team default`. Full dumped body: `type-templates.md`.
Mirror shapes in `page-templates.md` (HQ page). Link child **`subteam`** objects
via `subteams` and the HQ map; do not create new Sub-teams as `team`.

Legacy: older spaces may still have `team` objects with `kind: Sub-team`. Prefer
migrating those to type **`subteam`** via `set_type` (see below). Do not mint new
`Sub-team` select options.

## Subteam (`api_key`: `subteam`)

Dedicated type for domains / pods under an HQ. Prefer this over putting
sub-teams on the `team` type.

| Key | Format | Notes |
|-----|--------|-------|
| `parent_team` | objects | Owning HQ / Team (featured; required when known) |
| `chief` | objects | Lead agent when the subteam has one (else HQ chief) (featured) |
| `lifecycle` | select | Shared with Agent / Team (`draft` / `live` / `archived`) (featured) |
| `mission` | text | Short domain mission |
| `members` | objects | Agent members of this domain |
| `routing_summary` | text | One-line routing |
| `messaging_group` | objects | Group page when present |
| `skills_page` | objects | Domain Skills index when present |
| `browser` | objects | Optional domain-default **Browser** catalog link |
| `computer` | objects | Optional domain-default **Computer** catalog link |
| `tool_profile` | objects | Optional domain-default **Tool profile** catalog link |

Also `tag`, `links`, `backlinks`. No `kind` property: the type itself is the kind.
Agent-level runtime links override subteam defaults when both are set.

**Default template name:** `Subteam default`. Body: `type-templates.md`. Also
`page-templates.md` (Subteam page).

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

## Browser (`api_key`: `browser`)

Reusable browser-access catalog. Agents / Teams / Subteams link one via
`browser`. Prefer catalog + links over per-agent instances.

| Key | Format | Notes |
|-----|--------|-------|
| `slug` | text | Stable id (e.g. `none`, `cua-spaces-chromium`, `local-chromium-throwaway`) (featured) |
| `lifecycle` | select | `draft` \| `live` \| `archived` (featured) |
| `access_needed` | checkbox | Whether interactive browser is needed (featured). Display name **Access needed** |
| `browser_source` | select | `none` \| `local-chromium` \| `lightpanda` \| `cloud-browserbase` \| `cloud-browser-use` \| `cloud-firecrawl` \| `cloud-nous` \| `cdp-attach` \| `operator-real-profile` (featured). Display name **Browser source** (avoid bare `Source`; that clashes with a url property elsewhere) |
| `browser_identity` | select | `none` \| `dedicated-throwaway` \| `dedicated-persistent` \| `team-shared-persistent` \| `operator-real-profile`. Display name **Browser identity** |
| `headed` | checkbox | Headed Chromium when true |
| `cloud_provider` | text | Optional cloud provider label when source is cloud-* |
| `docs_url` | url | Optional docs |
| `notes` | text | Short apply notes |

Also `tag`, `links`, `backlinks`. Long apply notes stay in the body.

**Canonical catalog (create these once):**

| Name | slug | Typical use |
|------|------|-------------|
| None | `none` | Default when web_search / web_extract suffice |
| Cua Spaces Chromium | `cua-spaces-chromium` | Interactive pages inside Cua Space (pair with Cua computer) |
| Local Chromium throwaway | `local-chromium-throwaway` | Host-local Chromium, fresh profile |
| Operator real profile | `operator-real-profile` | Consent-gated real Chrome/Edge/Brave logins |

**Default template name:** `Browser default`. Body: `type-templates.md`.

Hermes apply: skill `hermes-profiles` → `browser-and-computer.md`.

## Computer (`api_key`: `computer`)

Reusable computer / desktop catalog. Agents / Teams / Subteams link one via
`computer`.

| Key | Format | Notes |
|-----|--------|-------|
| `slug` | text | Stable id (e.g. `cua-spaces-dedicated`, `none`) (featured) |
| `lifecycle` | select | `draft` \| `live` \| `archived` (featured) |
| `access_needed` | checkbox | Whether desktop / computer_use is needed (featured; shared key with Browser) |
| `computer_surface` | select | `cua-spaces` \| `host` \| `bot-screen` \| `none` (featured; shared with Agent select) |
| `computer_scope` | select | `dedicated` \| `team-shared` \| `none`. Display name **Computer scope** |
| `permission_mode` | select | `standard` \| `bounded`. Display name **Permission mode** |
| `desktop_enabled` | checkbox | Cua Spaces desktop stack on when true. Display name **Desktop enabled** |
| `docs_url` | url | Optional docs |
| `notes` | text | Short apply notes |

Also `tag`, `links`, `backlinks`.

**Canonical catalog (create these once):**

| Name | slug | Typical use |
|------|------|-------------|
| None | `none` | No desktop / computer_use |
| Cua Spaces dedicated | `cua-spaces-dedicated` | **Org default** (`terminal.backend: cua`, desktop true) |
| Host desktop shared | `host-desktop-shared` | Exception: drive operator host UI |
| Linux Bot Screen | `bot-screen` | Linux gateway Bot Screen exception |

**Default template name:** `Computer default`. Body: `type-templates.md`.

Hermes apply: `browser-and-computer.md` + Cua Spaces plugin docs.

## Tool profile (`api_key`: `tool_profile`)

Reusable toolsets + approvals + terminal defaults. Agents / Teams / Subteams
link one via `tool_profile`. Use key `tool_profile` (not bare `tool`) to mirror
`harness_profile` and avoid clashes.

| Key | Format | Notes |
|-----|--------|-------|
| `slug` | text | Stable id (e.g. `standard-interactive`, `coding`) (featured) |
| `lifecycle` | select | `draft` \| `live` \| `archived` (featured) |
| `intent` | text | When to use (featured) |
| `enabled_toolsets` | text | Comma list (e.g. `web,terminal,file,memory,delegation`) |
| `disabled_toolsets` | text | Comma list or empty |
| `tool_approvals` | select | `smart` \| `manual` \| `off`. Display name **Tool approvals** (avoid bare `Approvals`) |
| `cron_approvals` | select | `deny` \| `approve`. Display name **Cron approvals** |
| `hard_deny` | text | Globs / patterns or `none` |
| `terminal_backend` | select | Shared with Agent (`cua` \| `local` \| …); org default `cua` |
| `terminal_cwd` | text | Absolute host cwd when needed; leave empty with cua |
| `timeout_seconds` | number | Terminal timeout (e.g. `180`) |
| `notes` | text | Short apply notes |

Also `tag`, `links`, `backlinks`.

**Canonical catalog (create these once):**

| Name | slug | Typical use |
|------|------|-------------|
| Standard interactive | `standard-interactive` | **Org default** tool access |
| Coding | `coding` | Engineering chiefs / specialists (+ browser, code_execution, computer_use) |
| Data fetching | `data-fetching` | Lookups / scrape / light summary |
| Read-only light | `read-only-light` | Propose / read-only autonomy |

**Default template name:** `Tool profile default`. Body: `type-templates.md`.

Hermes apply: `runtime-limits-and-tools.md`. Pair with linked Browser / Computer
when those toolsets are enabled.

**Fill conventions (org):**
- Computer → **Cua Spaces dedicated** for live agents / HQs / subteams
- Tool profile → **Standard interactive**; Engineering → **Coding**; fetch /
  veille roles → **Data fetching**
- Browser → **None** unless interactive pages are needed; then **Cua Spaces
  Chromium** (with Cua computer)

## Project (`api_key`: `project`)

Built-in Project type extended with org fields. Short overview and hub links
live in properties; long narrative stays in the body.

| Key | Format | Notes |
|-----|--------|-------|
| `project_status` | select | `Active` \| `Other` \| `Archived` |
| `project_category` | select | `Core Platform` \| `Consumer Apps` \| `Research` \| `AI & Content` \| `B2B` \| `Tools` \| `Other` |
| `owning_team` | objects | Link to Team / HQ |
| `git_hub` | url | Repo URL (API key is `git_hub`) |
| `public_url` | url | Public product URL |
| `one_liner` | text | Positioning line |
| `execution_policy` | select | `Local` \| `Cloud` \| `Mixed` \| `Unset` (featured) |
| `lead_agent` | objects | Owning coordinator when known (featured) |
| `related_projects` | objects | Sibling / dependency projects |
| `overview` | text | Short overview (2–4 sentences) |
| `technical_page` | objects | Child Technical hub |
| `product_page` | objects | Child Product hub |
| `pm_page` | objects | Child Project Management hub |
| `design_page` | objects | Child Design hub |
| `business_page` | objects | Child Business hub |
| `marketing_page` | objects | Child Marketing hub |

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
      "short_description": "Implements one Ready coding TODO…",
      "delegation_enabled": true,
      "browser": ["<browserNoneOrCuaChromiumId>"],
      "computer": ["<cuaSpacesDedicatedComputerId>"],
      "tool_profile": ["<codingOrStandardToolProfileId>"],
      "terminal_backend": "cua",
      "computer_surface": "cua-spaces",
      "map_path": "Agents → Engineering HQ → Development → Lee"
    },
    "markdown": "## Full System Prompt (copy into the bot)\n…"
  }
}
```

Omit body sections that only repeat properties (`## Short Description`,
`**Autonomy:**`, map path as prose-only) when those properties are set.

Create a Subagent the same way (`"type": "subagent"`) with `parent_agent`,
`task_key`, `harness_profile`, then add its id to the parent's `subagents`.

Team / Subteam / Subagent / Harness / Harness profile / Browser / Computer /
Tool profile / project the same way with the matching `"type"` and property
keys above.

## Search by type

```json
{
  "space_id": "<spaceId>",
  "type": "agent",
  "limit": 50,
  "fields": ["name", "role", "lifecycle", "harness_profile", "subagents", "browser", "computer", "tool_profile"]
}
```

Use `"type": "team"`, `"type": "subteam"`, `"type": "subagent"`, `"type": "harness"`,
`"type": "harness_profile"`, `"type": "browser"`, `"type": "computer"`,
`"type": "tool_profile"`, or `"type": "project"` the same way.

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

1. `API-create-type` for `agent`, `team`, `subteam`, `subagent`, `harness`,
   `harness_profile`, `browser`, `computer`, and `tool_profile` with the
   property definitions above (`create_missing_options: true` for selects). On
   `team`, define `kind` options `Board` / `HQ` / `Group` only (no `Sub-team`).
   Prefer **sequential** creates when several types share new property names
   (`members`, `skills_page`, `access_needed`, `computer_surface`, …) so keys
   stay clean aliases rather than colliding opaque ids. Name new selects
   carefully (`Browser source`, `Tool approvals`) when a shorter name already
   exists with a different format.
2. On existing Agent / Team / Subteam types: `add_property` for org/runtime
   fields above including featured `browser`, `computer`, `tool_profile`
   objects links; also `board_member`, `linked_projects`, `memory_pages`,
   `messaging_group`, `map_path`, `delegation_enabled`, `terminal_backend`,
   `computer_surface`; keep `harness_profile` / `subagents`; `remove_property`
   legacy `harness` select when ready.
3. On Team: `add_property` `members`, `subteams`, `messaging_group`,
   `skills_page`, `routing_summary` (+ runtime catalog links). On Project:
   `execution_policy`, `lead_agent`, `related_projects`, `overview`, and child
   hub page links.
4. `API-create-template` with `template_for`: `agent` | `team` | `subteam` |
   `subagent` | `harness` | `harness_profile` | `browser` | `computer` |
   `tool_profile` | `project` and body markdown from **`type-templates.md`**.
5. `API-update-type` body `{ "default_template": "<templateId>" }` per type.
6. Create the seven Harness catalog objects; create Harness profiles (**Local
   router**, Coding, Data fetching, …); create Browser / Computer / Tool
   profile catalogs (tables above); create Subagent spawn configs; link most
   agents to Local router + runtime catalogs + `subagents` (and
   Subagent.`parent_agent`).
7. Migrate existing inventory with `set_type` as above (including legacy Sub-team
   `team` objects → `subteam`). Fill properties from the org map; leave unknown
   urls / people empty.

Do not hardcode space or template ids in skill text; resolve them via list/get
each session.

## What stays `page`

- Agents / Projects hub roots (optional)
- Shared Rules, Skill Template, Skills indexes
- Agent memory children (Skills, Operating Notes, …)
- Group welcome pages when not modeled as Team `kind: Group`
- Drafts hub scaffolding, misc notes
