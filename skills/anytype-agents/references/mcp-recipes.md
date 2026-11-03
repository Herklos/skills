# Anytype MCP recipes (generic)

Tool names may be prefixed (`anytype__API-…`). Replace placeholders.

## Discover space and Agents root

1. If the user pasted a URL:
   - `https://object.any.coop/<objectId>?spaceId=<spaceId>`
   - or `anytype://object?objectId=<objectId>&spaceId=<spaceId>`
2. Else list/search spaces, then:

```json
{
  "space_id": "<spaceId>",
  "query": "Agents",
  "limit": 25
}
```

Confirm the hub that looks like the org root (links to Shared Rules / HQs).

## Read a page as markdown

```json
{
  "space_id": "<spaceId>",
  "object_id": "<objectId>",
  "format": "md"
}
```

Outline only:

```json
{
  "space_id": "<spaceId>",
  "object_id": "<objectId>",
  "outline": true
}
```

## Create an agent (typed)

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
    "markdown": "**Short Description**\n…\n\n## Full System Prompt (copy into the bot)\n```\n# Role\nYou are Lee…\n```\n"
  }
}
```

Omit `template` to use the type default (**Agent default**). Create memory
children as `page`. Patch the parent Team / HQ to add a link. Full property
tables: `object-types.md`.

## Create a team / HQ

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "team",
    "name": "Engineering HQ",
    "properties": {
      "kind": "HQ",
      "lifecycle": "live",
      "mission": "…"
    },
    "markdown": "## Mission\n…\n"
  }
}
```

`kind` is `Board` | `HQ` | `Group` only. Domains under an HQ use **`subteam`**.

## Create a Subteam

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "subteam",
    "name": "Platform – Engineering",
    "properties": {
      "lifecycle": "live",
      "parent_team": ["<engineeringHqObjectId>"],
      "mission": "…"
    },
    "markdown": "## Mission\n…\n\n## Members\n…\n"
  }
}
```

Omit `template` to use **Subteam default** when the type has one. Patch the
parent HQ map to link the new Subteam. Prefer this over `team` + `kind: Sub-team`.

## Create a project portfolio root

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "project",
    "name": "Example Product",
    "properties": {
      "project_status": "Active",
      "project_category": "Core Platform",
      "one_liner": "…"
    },
    "markdown": "## Overview\n…\n"
  }
}
```

## Migrate page → typed object

```json
{
  "space_id": "<spaceId>",
  "object_id": "<objectId>",
  "create_missing_options": true,
  "ops": [
    { "op": "set_type", "type": "agent" },
    { "op": "set_properties", "set": { "lifecycle": "live", "harness": "grok" } }
  ]
}
```

`set_properties` values live under `set`. Keeps id and links.

## Patch with etag

1. `API-get-object` → note `etag`
2. `API-patch-object` with `expected_etag` and a small op (`replace_text`, `insert_blocks`, `set_properties`, …)
3. On conflict, re-get and retry
4. Use `dry_run: true` when unsure

## Search within space

```json
{
  "space_id": "<spaceId>",
  "query": "Lee –",
  "limit": 15
}
```

Filter inventory with `"type": "agent"`, `"team"`, `"subteam"`, or `"project"` (support docs often stay `"page"`).

## Archive

```json
{
  "space_id": "<spaceId>",
  "object_id": "<objectId>"
}
```

Confirm the display name with the user first. Permanent delete only with explicit approval.

## Comments / discussions

When Shared Rules treat comments as a channel:

1. List or open the discussion for the object
2. Read new comments
3. Act
4. Reply on the same thread

## Verify after writes

- Re-get the object as markdown
- Confirm links from HQ / Agents
- Report object URL to the user
- List remaining runtime steps (prompt copy, group membership, Hermes profile)
