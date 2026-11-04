# Project PM: Epic / User story / Task

On-demand playbook for project delivery work under each project's Project
Management hub. Load when creating PM types, migrating Roadmap/Backlog/TODO
collections, wiring filtered Queries, or filing new work items.

Property tables also live in `object-types.md`. Short MCP snippets:
`mcp-recipes.md`.

## Model

| Layer | Type key | PM Query name | Was |
|-------|----------|---------------|-----|
| Epic | `epic` | Roadmap | Roadmap collection |
| User story | `user_story` | Backlog | Backlog collection |
| Task | `task` (built-in, extended) | TODO | TODO collection |

Each Query is filtered by **`linked_projects`** containing that project's
object id. New work items set `linked_projects` to the project so they appear
automatically.

Hierarchy (optional links): Epic ← User story (`parent_epic`) ← Task
(`parent_user_story` / `parent_epic`). Do not invent hierarchy during bulk
migrate; wire parents when refining.

## Task kinds

Select `kind` on Task (featured):

| Option | Use |
|--------|-----|
| `bugfix` | Defect / regression |
| `implementation` | Feature or code change (default on migrate from TODO) |
| `doc` | Docs / README / ADR write-up |
| `design` | Design deliverable |
| `review` | Review / audit pass |
| `chore` | Maintenance, deps, cleanup |
| `spike` | Time-boxed investigation |

## Shared fields

| Key | On | Notes |
|-----|----|-------|
| `linked_projects` | epic, user_story, task | Primary project link for Query filters (objects → project) |
| `status` | all three | Shared select: Backlog / Ready / In progress / Done / Cancelled |
| `pm_priority` (display **PM priority**) | epic (+ may be `pm_priority_2` on user_story/task if space already had a Priority number) | P0 / P1 / P2 / P3 |
| `user_stories` | epic | Optional child User stories |
| `parent_epic` | user_story, task | Optional parent Epic |
| `child_tasks` | user_story | Optional child Tasks |
| `parent_user_story` | task | Optional parent User story |
| `kind` | task | See table above |
| `done`, `assignee`, `due_date` | task | Built-in todo layout |

Resolve live api keys with `API-get-type` (some spaces mint opaque keys for
Parent epic / PM priority). Prefer display names in `set_properties` when the
API accepts them.

## Create types (bootstrap)

1. `API-create-type` `epic` and `user_story` (`layout: basic`,
   `create_missing_options: true`). Reuse `linked_projects` and `status`. Name
   priority **PM priority** (bare Priority may already be a number property).
2. `API-update-type` on `task` with `add_property` for Kind (select + options),
   Parent epic, Parent user story, PM priority; feature `linked_projects`.
3. `API-create-template` for Epic default / User story default; set
   `default_template` on each type. Keep built-in Task default.
4. Do **not** replace whole `property_definitions` on Task (layout todo + views).

## Per-project Queries

For each project with a `pm_page`:

```json
{
  "space_id": "<spaceId>",
  "name": "TODO",
  "type": "task",
  "filter": "linked_projects IN (\"<projectObjectId>\")",
  "sorts": [{ "property": "last_modified_date", "direction": "desc" }]
}
```

Same for `Roadmap` / `epic` and `Backlog` / `user_story`. Dry-run once when
unsure of object-filter spelling. Then `replace_subtree` the three link blocks
on the PM page so they point at the new Query ids (keep extra PM prose / other
links).

## Migrate old collections

1. Read PM page markdown → Roadmap / Backlog / TODO collection ids.
2. `API-get-collection-objects` (paginate).
3. Patch each member page:
   - Roadmap → `set_type` `epic` + `linked_projects: [projectId]`
   - Backlog → `user_story` + `linked_projects`
   - TODO → `task` + `linked_projects` + `kind: implementation`
4. Create the three Queries; rewrite PM links; verify with
   `API-get-query-objects`.
5. `API-delete-object` (Bin) the old collections. Permanent delete only with
   explicit approval.
6. Leave `[MOVED to Backlog]` stub cards as typed tasks unless the user asks to
   Bin them; do not invent Epic↔US links from titles alone.

## New work item

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "task",
    "name": "Fix auth callback double-fire",
    "properties": {
      "linked_projects": ["<projectObjectId>"],
      "kind": "bugfix",
      "status": "Ready"
    },
    "markdown": "## Acceptance\n- [ ] …\n"
  }
}
```

User story / Epic the same way with `"type": "user_story"` / `"epic"`.

## Agents

Agents pull Ready work from `Projects → [Project] → Project Management → TODO`
(now a Task Query). Prefer `kind` + `status` filters over free-text. Design-done
evidence still comes from the Design child when that gate exists.

## Verify

- `API-list-types` includes `epic`, `user_story`; `task` has `kind`
- Per project: Roadmap/Backlog/TODO Queries return expected counts
- PM page links resolve to `type: query` objects
- Old Roadmap/Backlog/TODO collections are in the Bin (or absent from live search)
