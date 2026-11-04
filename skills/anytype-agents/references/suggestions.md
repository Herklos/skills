# Suggestion type (improvement feedback)

Agents (and Agathe) file typed **`suggestion`** objects when something about
how they work should change: model unfit for a task, missing Subagent route,
missing Skill, harness/tool/prompt/memory tweak, or other. Indexes are
**Queries** via Agent.`suggestions_page`. Editing Anytype still does not push
into live Hermes; remind separately.

Property keys and create recipes: this file. Type inventory: `object-types.md`.
Agathe weekly pass + Shared Rule **25** wire the loop.

## Type key

| Type key | Plural | Use for |
|----------|--------|---------|
| `suggestion` | Suggestions | Improvement proposals (model / subagent / skill / harness / tool / memory / prompt / other) |

**Default template:** `Suggestion default`.

## Properties

| Key | Format | Notes |
|-----|--------|-------|
| `suggestion_kind` | select | `model_fit` \| `new_subagent` \| `new_skill` \| `harness` \| `tool` \| `memory` \| `prompt` \| `other` (featured) |
| `suggestion_status` | select | `draft` \| `proposed` \| `accepted` \| `done` \| `declined` (featured) |
| `owner_agent` | objects | Agent the change is about (featured; required) |
| `proposed_by` | objects | Who filed it: the agent or Agathe (featured) |
| `proposed_at` | date | When filed (featured) |
| `summary` | text | One or two sentences (featured) |
| `related_objects` | objects | Optional harness_profile / skill / subagent / prompt / … |
| `reviewed_by` | objects | Optional chief / Solange / P |
| `notes` | text | Short extra |

Object **name** should match or shorten `summary`. Body holds Evidence /
Proposed action / Approval path (Suggestion default).

## Link property on Agent

| On type | Key | Format | Points to |
|---------|-----|--------|-----------|
| `agent` | `suggestions_page` | objects | Suggestions **Query** for this agent |

## Naming

| Kind | Name pattern |
|------|----------------|
| suggestion | short action title (also set `summary`) |
| Suggestions Query | `{OwnerShort} – Suggestions` |
| Org inbox | `Suggestions – Inbox` (status draft\|proposed\|accepted) |
| Agathe proposed | `Suggestions – Agathe proposed` (`proposed_by` = Agathe) |

## Cadence and approval

1. **Ad-hoc:** any agent files a `suggestion` after friction (status `draft` or
   `proposed`).
2. **Weekly:** Agathe Sunday hygiene (`weekly-memory-hygiene`) asks each agent
   for improvement feedback and files `proposed` suggestions.
3. **Approval:** owning agent + their chief. New Skill drafts → Solange reviews
   quality. Org-wide / harness profile / Shared Rules → René then **P**.
4. **Apply:** create draft Subagent / Skill / Memory / Prompt patches only after
   acceptance. **Never auto-apply into Hermes.**

Skip agents with `lifecycle=archived` or `memory_review_off=true` on Agathe’s
pass (same as memory hygiene).

## Create Suggestion + Suggestions Query

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "suggestion",
    "name": "Coding Subagent needed for long refactors",
    "properties": {
      "suggestion_kind": ["new_subagent"],
      "suggestion_status": ["proposed"],
      "owner_agent": ["<agentId>"],
      "proposed_by": ["<agatheOrAgentId>"],
      "proposed_at": "2026-11-04",
      "summary": "Parent lfm3 struggles on multi-file refactors; add Coding Subagent route."
    },
    "markdown": "## Summary\n…\n\n## Evidence\n…\n\n## Proposed action\n…\n\n## Approval path\nOwning agent → chief. No Hermes apply until asked.\n\n## Notes\n"
  }
}
```

Ensure a Suggestions Query exists for that agent:

```json
{
  "space_id": "<spaceId>",
  "name": "Lee – Suggestions",
  "type": "suggestion",
  "filter": "owner_agent IN (\"<agentId>\")",
  "sorts": [{ "property": "proposed_at", "direction": "desc", "empty_placement": "end" }]
}
```

Patch Agent: `suggestions_page=[<queryId>]`.

Org inbox (Agathe triage):

```json
{
  "space_id": "<spaceId>",
  "name": "Suggestions – Inbox",
  "type": "suggestion",
  "filter": "suggestion_status IN (\"draft\",\"proposed\",\"accepted\")",
  "sorts": [{ "property": "proposed_at", "direction": "desc", "empty_placement": "end" }]
}
```

## Search

```json
{
  "space_id": "<spaceId>",
  "type": "suggestion",
  "limit": 100,
  "fields": ["name", "suggestion_kind", "suggestion_status", "owner_agent", "proposed_by", "proposed_at", "summary"]
}
```

## Bootstrap in a new space

1. `API-create-type` `suggestion` (`create_missing_options: true`); reuse
   shared `owner_agent` / `summary` / `notes` / `reviewed_by` via `"property"`
2. `API-create-template` Suggestion default; set `default_template`
3. On Agent: `add_property` **Suggestions page** (`suggestions_page`, objects,
   featured)
4. Create `{OwnerShort} – Suggestions` Query per live agent; set
   `suggestions_page`; create Suggestions – Inbox (+ optional Agathe proposed)

## Out of scope

- Auto Hermes apply of harness / Subagent / skill changes
- Replacing Solange’s skill-quality ownership
- Customer Feedback Analyst (Fanny) product feedback (separate track)
