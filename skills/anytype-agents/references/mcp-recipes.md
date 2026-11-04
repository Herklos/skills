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
      "harness_profile": ["<localRouterHarnessProfileObjectId>"],
      "autonomy": "change-with-gates",
      "short_description": "Implements one Ready coding TODO…",
      "delegation_enabled": true,
      "browser": ["<browserCatalogObjectId>"],
      "computer": ["<computerCatalogObjectId>"],
      "tool_profile": ["<toolProfileCatalogObjectId>"],
      "terminal_backend": "cua",
      "computer_surface": "cua-spaces",
      "map_path": "Agents → Engineering HQ → Development → Lee"
    },
    "markdown": "## Full System Prompt (copy into the bot)\n```\n# Role\nYou are Lee…\n```\n"
  }
}
```

Omit `template` to use the type default (**Agent default**). Create memory
children as `page` and link via `memory_pages`. Patch the parent Team / Subteam
`members`. Full property tables: `object-types.md`. Default template body dumps:
`type-templates.md`.

## Create a Harness catalog entry

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "harness",
    "name": "Claude",
    "properties": {
      "slug": "claude",
      "lifecycle": "live",
      "vendor": "Anthropic",
      "notes": "Claude Code / Claude agent"
    },
    "markdown": "## Purpose\n…\n"
  }
}
```

Slugs: `claude` | `codex` | `grok` | `github-copilot` | `muse` | `nvidia-nim` | `local-model`.

## Create a Harness profile

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "harness_profile",
    "name": "Coding",
    "properties": {
      "intent": "coding",
      "lifecycle": "live",
      "primary_harness": ["<claudeObjectId>"],
      "primary_model": "Claude Code Sonnet 5.5",
      "primary_effort": "high",
      "backup_1_harness": ["<codexObjectId>"],
      "backup_1_model": "Codex Sol 6.1",
      "backup_1_effort": "high",
      "backup_2_harness": ["<grokObjectId>"],
      "backup_2_model": "Grok 4.5",
      "backup_2_effort": "high"
    },
    "markdown": "## When to use\n…\n\n## Stack summary\n…\n"
  }
}
```

For **Local router** (parent decision stack), also set Hermes ids:

```json
"decision_provider": "llamacpp",
"decision_model": "d1-2b-q4_k_m",
"primary_model": "d1-2B-GGUF Q4_K_M",
"primary_effort": "medium"
```

Decline via hermes-profiles `models.md` (Local decision model). Leave `decision_*`
empty on Coding / Data fetching (Subagent stacks).

Point agents at the profile with `harness_profile: ["<profileObjectId>"]`.

## Create a Browser catalog entry

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "browser",
    "name": "Cua Spaces Chromium",
    "properties": {
      "slug": "cua-spaces-chromium",
      "lifecycle": "live",
      "access_needed": true,
      "browser_source": "local-chromium",
      "browser_identity": "dedicated-throwaway",
      "headed": false,
      "docs_url": "https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces",
      "notes": "Chromium inside Cua Space with desktop stack."
    },
    "markdown": "## When to use\nInteractive pages while computer is Cua Spaces.\n"
  }
}
```

## Create a Computer catalog entry

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "computer",
    "name": "Cua Spaces dedicated",
    "properties": {
      "slug": "cua-spaces-dedicated",
      "lifecycle": "live",
      "access_needed": true,
      "computer_surface": "cua-spaces",
      "computer_scope": "dedicated",
      "permission_mode": "standard",
      "desktop_enabled": true,
      "docs_url": "https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces",
      "notes": "Org default. terminal.backend cua; desktop true."
    },
    "markdown": "## When to use\nDefault computer for live agents.\n"
  }
}
```

## Create a Tool profile catalog entry

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "tool_profile",
    "name": "Standard interactive",
    "properties": {
      "slug": "standard-interactive",
      "lifecycle": "live",
      "intent": "Default interactive agent: web, terminal, file, memory, delegation",
      "enabled_toolsets": "web,terminal,file,memory,delegation",
      "disabled_toolsets": "",
      "tool_approvals": "smart",
      "cron_approvals": "deny",
      "hard_deny": "none",
      "terminal_backend": "cua",
      "timeout_seconds": 180
    },
    "markdown": "## When to use\nOrg default tool access.\n"
  }
}
```

Link catalogs on Agent / Team / Subteam:

```json
{
  "op": "set_properties",
  "set": {
    "browser": ["<browserObjectId>"],
    "computer": ["<computerObjectId>"],
    "tool_profile": ["<toolProfileObjectId>"]
  }
}
```

## Create a Subagent (spawn route)

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "subagent",
    "name": "Deep code",
    "properties": {
      "parent_agent": ["<leeAgentObjectId>"],
      "task_key": "deep",
      "harness_profile": ["<codingHarnessProfileObjectId>"],
      "lifecycle": "live",
      "intent": "Hard debugging and careful refactors",
      "scope": "single-repo cwd",
      "toolsets": "terminal,file,web",
      "spawn_effort": "high",
      "deliver_back": "Diff summary + test result + open questions"
    },
    "markdown": "## When to use\n…\n\n## Route\n…\n"
  }
}
```

Then patch the parent Agent:

```json
{
  "op": "set_properties",
  "set": { "subagents": ["<deepCodeSubagentId>", "<fastFetchSubagentId>"] }
}
```

Keep Subagent.`parent_agent` and Agent.`subagents` both ways. Decline into Hermes
`model_map` with hermes-profiles `delegation.md`.

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
      "chief": ["<chiefAgentId>"],
      "members": ["<chiefAgentId>"],
      "subteams": ["<subteamId>"],
      "mission": "…",
      "routing_summary": "All work via chief; see Subteams."
    },
    "markdown": "## Rules\n1. Follow Agents → Shared Rules.\n"
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
      "chief": ["<chiefAgentId>"],
      "members": ["<agentId>"],
      "mission": "…",
      "routing_summary": "Members → HQ chief → Primary."
    }
  }
}
```

Omit `template` to use **Subteam default** when the type has one. Patch the
parent HQ `subteams` property. Prefer this over `team` + `kind: Sub-team`.

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
      "one_liner": "…",
      "overview": "…",
      "execution_policy": "Unset",
      "lead_agent": ["<agentId>"],
      "owning_team": ["<hqTeamId>"]
    },
    "markdown": "## Core Features\n…\n"
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
    { "op": "set_properties", "set": { "lifecycle": "live", "harness_profile": ["<profileObjectId>"] } }
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

Filter inventory with `"type": "agent"`, `"team"`, `"subteam"`, `"subagent"`,
`"harness"`, `"harness_profile"`, `"browser"`, `"computer"`, `"tool_profile"`,
or `"project"` (support docs often stay `"page"`).

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
