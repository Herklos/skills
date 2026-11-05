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
      "analytics_enabled": false,
      "browser": ["<browserCatalogObjectId>"],
      "computer": ["<computerCatalogObjectId>"],
      "tool_profile": ["<toolProfileCatalogObjectId>"],
      "terminal_backend": "cua",
      "computer_surface": "cua-spaces",
      "voice_enabled": false,
      "voice_auto_tts": false,
      "voice_chat_mode": "off",
      "messaging_voice_mode": "off",
      "stt_provider": "local",
      "stt_model": "base",
      "tts_provider": "edge",
      "tts_voice": "en-US-AriaNeural",
      "tts_speed": 1,
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

Hermes-shaped fields: `model_*` → `model.*`, `fallback_*` →
`fallback_providers`, `aux_<task>_*` → `auxiliary.<task>.*`.

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
      "model_provider": "anthropic",
      "model_default": "Claude Code Sonnet 5.5",
      "model_effort": "high",
      "model_harness": ["<claudeObjectId>"],
      "fallback_1_provider": "openai-codex",
      "fallback_1_model": "Codex Sol 6.1",
      "fallback_1_effort": "high",
      "fallback_1_harness": ["<codexObjectId>"],
      "fallback_2_provider": "xai",
      "fallback_2_model": "Grok 4.5",
      "fallback_2_effort": "high",
      "fallback_2_harness": ["<grokObjectId>"],
      "aux_vision_provider": "auto",
      "aux_compression_provider": "auto",
      "aux_web_extract_provider": "auto",
      "aux_skills_hub_provider": "auto",
      "aux_title_generation_provider": "auto",
      "stt_provider": "none",
      "tts_provider": "none"
    },
    "markdown": "## When to use\n…\n\n## Stack summary\n…\n"
  }
}
```

For **Local router** (parent stack):

```json
"model_provider": "llamacpp",
"model_default": "d1-2b-q4_k_m",
"model_effort": "medium",
"model_harness": ["<localModelHarnessObjectId>"],
"fallback_1_provider": "xai",
"fallback_1_model": "Grok 4.5",
"fallback_1_effort": "medium",
"fallback_1_harness": ["<grokObjectId>"],
"fallback_2_provider": "anthropic",
"fallback_2_model": "Claude Haiku 5.5",
"fallback_2_effort": "medium",
"fallback_2_harness": ["<claudeObjectId>"],
"stt_provider": "local",
"stt_model": "base",
"tts_provider": "edge",
"tts_voice": "en-US-AriaNeural",
"tts_speed": 1
```

Decline via hermes-profiles `models.md` (incl. Local decision / llamacpp) and
`voice.md`. Subagent stacks (Coding / Data fetching) usually keep aux at `auto`
and STT/TTS at `none`.

Point agents at the profile with `harness_profile: ["<profileObjectId>"]`.

## Create a per-HQ Browser + Computer pair

Full playbook: `hq-runtime-pair.md`. Org convention: one Computer and one
Browser per HQ. **When `is_real` (org default):** create a dedicated Chrome
profile on the host first (`hq-runtime-pair.md` → Create Chrome profile), then
set Browser.`real_profile_pin` to that directory (`Profile N`). Never reuse
another Browser's pin. Link both on the HQ, its Subteams, and its Agents. Board
/ Primary leave both empty.

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "computer",
    "name": "Engineering HQ – Cua Spaces",
    "properties": {
      "slug": "engineering-cua-spaces",
      "lifecycle": "live",
      "access_needed": true,
      "computer_surface": "cua-spaces",
      "computer_scope": "dedicated",
      "permission_mode": "standard",
      "desktop_enabled": true,
      "docs_url": "https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces",
      "notes": "Dedicated Cua Space for Engineering HQ."
    },
    "markdown": "## When to use\nEngineering HQ + its Subteams + Agents.\n"
  }
}
```

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "browser",
    "name": "Engineering HQ – Hermes Chromium",
    "properties": {
      "slug": "engineering-hermes-chromium",
      "lifecycle": "live",
      "access_needed": true,
      "is_real": true,
      "browser_engine": "chrome",
      "real_profile_pin": "Profile 2",
      "browser_source": "operator-real-profile",
      "browser_identity": "operator-real-profile",
      "headed": false,
      "docs_url": "https://hermes-agent.nousresearch.com/docs/user-guide/features/browser",
      "notes": "Chrome profile Hermes Engineering (pin Profile 2). Hermes use_real_profile=true. Pair with Engineering HQ Cua Spaces Computer."
    },
    "markdown": "## When to use\nPair with Engineering HQ – Cua Spaces. Create the Chrome profile on the host first; store its directory pin here.\n"
  }
}
```

Omit `icon` on create when using shortcut `name`/`markdown` (icon forces the
AnyBlock document form). After create, patch the HQ / Subteams / Agents:

```json
{
  "op": "set_properties",
  "set": {
    "browser": ["<hqBrowserId>"],
    "computer": ["<hqComputerId>"],
    "computer_surface": "cua-spaces"
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

`kind` is `Board` | `HQ` only (`Group` deprecated). Domains under an HQ use
**`subteam`**. Messaging rooms use typed **`group`** (next recipe).

## Create a Group

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "group",
    "name": "Engineering Group",
    "properties": {
      "lifecycle": ["live"],
      "parent_team": ["<engineeringHqObjectId>"],
      "members": ["<agentId>", "…"],
      "welcome_prompt": ["<welcomePromptId>"],
      "platform": ["telegram"],
      "slug": "engineering",
      "require_mention": true,
      "exclusive_bot_mentions": true,
      "hermes_profiles": "etienne,arnold,simone"
    },
    "markdown": "## Members\nCanonical roster is the **Members** property.\n\n## Welcome prompt\nCanonical welcome paste lives on the linked **Welcome prompt** property.\n"
  }
}
```

Then patch HQ / Agent `messaging_group: ["<groupId>"]`. Migrate legacy Group
pages with `set_type` → `group` (`object-types.md`). Hermes apply:
`hermes-profiles` → `messaging-groups.md` (when asked).

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

Also ensure the HQ has a **Subteams** Query (create once per HQ):

```json
{
  "space_id": "<spaceId>",
  "name": "Engineering – Subteams",
  "type": "subteam",
  "filter": "parent_team IN (\"<engineeringHqObjectId>\")",
  "sorts": [{ "property": "name", "direction": "asc" }]
}
```

Then `set_properties` Team.`subteams_page: ["<queryId>"]`. Replace any static
Sub-teams / Domains / Notion-map body section with a short pointer + link to
the Query (`page-templates.md`).

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

## Create Epic / User story / Task + PM Queries

Full playbook: `project-pm.md`. Task `kind` options: `bugfix` |
`implementation` | `doc` | `design` | `review` | `chore` | `spike`.

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "task",
    "name": "Spike auth provider options",
    "properties": {
      "linked_projects": ["<projectObjectId>"],
      "kind": "spike",
      "status": "Ready"
    },
    "markdown": "## Acceptance\n- [ ] Time-box 2h\n- [ ] Write recommendation\n"
  }
}
```

Same shape with `"type": "epic"` / `"user_story"`. Per-project filtered Query:

```json
{
  "space_id": "<spaceId>",
  "name": "TODO",
  "type": "task",
  "filter": "linked_projects IN (\"<projectObjectId>\")",
  "sorts": [{ "property": "last_modified_date", "direction": "desc" }]
}
```

Repeat for Roadmap (`epic`) and Backlog (`user_story`). Migrate old collection
pages with `set_type` + `linked_projects` (and `kind: implementation` for TODO).

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

## HQ structure fix ops

Playbook: SKILL.md → **HQ structure fix**. Typical ops for one HQ pass.

### Revive a dormant Subteam

```json
{
  "space_id": "<spaceId>",
  "object_id": "<subteamId>",
  "expected_etag": "<etag>",
  "create_missing_options": true,
  "ops": [
    {
      "op": "set_properties",
      "set": {
        "lifecycle": "live",
        "members": ["<agentId>"],
        "chief": ["<hqChiefId>"],
        "mission": "… under chief. Draft-only specialist; no send/sign/money.",
        "routing_summary": "Domain via specialist → chief.",
        "browser": ["<hqBrowserId>"],
        "computer": ["<hqComputerId>"],
        "tool_profile": ["<standardToolProfileId>"]
      }
    }
  ]
}
```

### Append a structure-fix snip (Prompt or Operating Notes)

Omit `after`/`before`/`inside` to append at end of the document:

```json
{
  "space_id": "<spaceId>",
  "object_id": "<promptOrMemoryId>",
  "expected_etag": "<etag>",
  "ops": [
    {
      "op": "insert_blocks",
      "markdown": "# Growth structure fix 2026-11-05\nFirmin owns Sales…\nDraft only; send/deals pass chief → Primary."
    }
  ]
}
```

### Rewrite a Group welcome (delete stale, then insert)

1. `outline: true` → collect block ids of the old welcome body (keep Prompt/Notes
   scaffolding if present).
2. `delete_block` each stale id (batch in one `ops` array).
3. `insert_blocks` with the new welcome markdown.

`replace_text` needs exact in-block text (markup included) and fails on
markdown-link destinations; prefer delete + insert for wholesale welcome rewrites.

### Update Primary org-map table cell

1. Outline Primary system Prompt → find the org-map `table` block id.
2. Get that block with `ids: "full"` if you need row/col ids; or use first-cell /
   header text locators:

```json
{
  "space_id": "<spaceId>",
  "object_id": "<primaryPromptId>",
  "expected_etag": "<etag>",
  "ops": [
    {
      "op": "set_cell",
      "table_id": "<tableBlockIdOrSuffix>",
      "row": "Kléber",
      "col": "Scope and reporting",
      "value": "Growth HQ chief; Board. Marketing (A, B); Sales (C draft); Partnerships (D draft)."
    }
  ]
}
```

`row` / `col` may be ids or unique first-cell / header text (case-insensitive).

### Wire HQ + Group after new agents

```json
{
  "op": "set_properties",
  "set": {
    "members": ["<chiefId>", "<aId>", "<bId>", "<newId>"],
    "routing_summary": "…",
    "hermes_profiles": "chief,a,b,new"
  }
}
```

`hermes_profiles` on Group is a checklist string until Hermes apply
(`hermes-profiles` → `messaging-groups.md`).

## Patch with etag

1. `API-get-object` → note `etag`
2. `API-patch-object` with `expected_etag` and a small op (`replace_text`, `insert_blocks`, `set_cell`, `set_properties`, …)
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

Filter inventory with `"type": "agent"`, `"team"`, `"group"`, `"subteam"`,
`"subagent"`, `"harness"`, `"harness_profile"`, `"browser"`, `"computer"`,
`"tool_profile"`, or `"project"` (support docs often stay `"page"`).

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
