# Prompt type (system / welcome / shared_rules / library / draft)

Canonical copy-into-bot text lives on typed **`prompt`** objects. Agents and
typed **Groups** keep a short pointer in the body and link the Prompt via a
property. Editing Anytype still does not push into live Hermes / bots; copy
from the Prompt object when applying runtime.

Property keys and create recipes: this file. Type inventory: `object-types.md`.
Body shapes: `page-templates.md` / `type-templates.md`.

## Type key

| Type key | Plural | Use for |
|----------|--------|---------|
| `prompt` | Prompts | System prompts, group welcomes, Shared Rules, prompt libraries, drafts |

**Default template name:** `Prompt default`. Body dump in `type-templates.md`.

## Properties

| Key | Format | Notes |
|-----|--------|-------|
| `prompt_kind` | select | `system` \| `welcome` \| `shared_rules` \| `library` \| `draft` \| `other` (featured) |
| `lifecycle` | select | Shared `draft` \| `live` \| `archived` (featured) |
| `owner_agent` | objects | Owning Agent when `prompt_kind=system` (featured) |
| `owner_group` | objects | Owning typed **Group** when `prompt_kind=welcome` (featured) |
| `audience` | select | `agent` \| `group` \| `org` \| `library` (featured) |
| `notes` | text | Apply / sync notes |

Also `tag`, `links`, `backlinks`. Put the full prompt text in the **body**
(markdown), not in `notes`.

## Link properties on other types

| On type | Key | Format | Points to |
|---------|-----|--------|-----------|
| `agent` | `system_prompt` | objects | One Prompt (`prompt_kind=system`, usually) |
| `group` | `welcome_prompt` | objects | One Prompt (`prompt_kind=welcome`) |
| `team` | `standing_instructions` | objects | One Prompt (`prompt_kind=library`) for HQ/Board gates |
| `team` | `system_prompt` | objects | Optional system Prompt (prefer `standing_instructions` for HQ gates) |
| `subteam` | `system_prompt` | objects | Optional; domains usually inherit HQ standing + agent prompts |
| `subagent` | `system_prompt` | objects | Optional child system Prompt (else inherit parent agent) |

Shared Rules and Mission/library pages are themselves type `prompt`. HQ standing
libraries also use `prompt_kind=library` and are linked from
Team.`standing_instructions` (`hq-standing-instructions.md`). Agents still
short-point at Shared Rules and HQ standing inside their system prompt body.

**Cleanup:** Agent pages must not keep `## Full System Prompt` / `## Full SOUL.md`
fences once `system_prompt` is set. Agent default template uses System prompt +
Agenda pointers only (no `## Suggested runtime`, no Short description /
Autonomy / Home / Chief / HQ / Team / Reports-to prose that duplicates
properties). Teams / Subteams / Subagents normally have no system-prompt body
section.

## Naming

| Kind | Name pattern |
|------|----------------|
| system | `{Name} – System prompt` (curly braces optional; keep accents) |
| welcome | `{Group name} – Welcome prompt` |
| shared_rules | keep the existing Shared Rules title when migrating in place |
| library / draft | keep existing title when `set_type` in place |

## Agent body after migrate

1. **Properties first** (short_description, team, reports_to, harness_profile, catalogs); no Suggested runtime body section
2. **System prompt** heading + one paragraph pointer to the linked Prompt
   (property **System prompt** / `system_prompt`)
3. **Agenda** short pointer to Agent.`agenda_page` when linked
4. Memory pages / standing notes that are not the copy-into-bot fence

System Prompt body must tell the agent to schedule via the Agenda (Shared Rules
Agenda rule + optional `# Agenda (mandatory)` section). See
`agenda-and-schedules.md` → **Prompt wording**.

System Prompt body must also tell the agent to open HQ standing instructions
before gated work (Shared Rules HQ standing rule + `# HQ standing instructions
(mandatory)`). See `hq-standing-instructions.md` → **Prompt wording**. Do
**not** paste the full standing library into the system Prompt.

Do **not** keep a second `## Full System Prompt` / `## Full SOUL.md` fenced
block on the Agent. Hermes SOUL text is still a system Prompt (`prompt_kind=system`).

Pointer example:

```markdown
## System prompt
Canonical system prompt lives on the linked **System prompt** property
([{Name} – System prompt](anytype://object?objectId=<promptId>&spaceId=<spaceId>)).
Copy from that Prompt object into the bot. Do not paste a second Full System
Prompt fence here.
```

## Group body after migrate

Groups are type **`group`**. Replace `## Welcome (copy-paste)` + fence with:

```markdown
## Welcome prompt
Canonical welcome paste lives on the linked **Welcome prompt** property
([{Group} – Welcome prompt](anytype://object?objectId=<promptId>&spaceId=<spaceId>)).
```

Set Group.`welcome_prompt` to that Prompt id. Migrate legacy Group pages with
`set_type` → `group` (`object-types.md`).

## Create a system Prompt + link an Agent

1. Create type `prompt` with `prompt_kind=system`, `lifecycle`, `owner_agent`,
   `audience=agent`, body = full system / SOUL text
2. On the Agent: `set_properties` `system_prompt=[<promptId>]`
3. Replace any Full System Prompt / SOUL heading + code block with the pointer
   (`replace_subtree` on the heading, `delete_block` on the sibling code block)

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "prompt",
    "name": "{Lee} – System prompt",
    "properties": {
      "prompt_kind": ["system"],
      "lifecycle": ["live"],
      "owner_agent": ["<agentId>"],
      "audience": ["agent"],
      "notes": "Copy into the bot as system prompt. Must follow Shared Rules."
    },
    "markdown": "# Role\nYou are Lee…\n"
  }
}
```

Omit `template` to use **Prompt default**, or pass the template id from
`API-list-templates` (`type: prompt`).

## Create a welcome Prompt + link a Group

Same pattern with `prompt_kind=welcome`, `owner_group=[<groupObjectId>]`,
`audience=group`, then Group.`welcome_prompt=[<promptId>]`.

## Migrate Shared Rules / libraries in place

Prefer `set_type` → `prompt` (keeps id and links), then set properties:

```json
{
  "ops": [
    { "op": "set_type", "type": "prompt" },
    {
      "op": "set_properties",
      "set": {
        "prompt_kind": ["shared_rules"],
        "lifecycle": ["live"],
        "audience": ["org"],
        "notes": "Org-wide shared rules."
      }
    }
  ]
}
```

Use `prompt_kind=library` for Mission & Prompt style libraries **and** for HQ /
Board Standing instructions (link via Team.`standing_instructions`; see
`hq-standing-instructions.md`). Use `draft` for draft agent designs that stay
typed as Prompt until promoted.

## Search

```json
{
  "space_id": "<spaceId>",
  "type": "prompt",
  "limit": 100,
  "fields": ["name", "prompt_kind", "lifecycle", "owner_agent", "owner_group"]
}
```

Filter agents that still need a link:

```json
{
  "space_id": "<spaceId>",
  "type": "agent",
  "limit": 100,
  "fields": ["name", "lifecycle", "system_prompt"]
}
```

## Bootstrap in a new space

1. `API-create-type` `prompt` with the property definitions above
   (`create_missing_options: true` for selects)
2. `API-create-template` `template_for: prompt` from `type-templates.md`
3. `API-update-type` `{ "default_template": "<templateId>" }`
4. On Agent / Team / Subteam / Subagent: `add_property` **System prompt**
   (`system_prompt`, objects, featured) when missing (reuse the same property key)
5. On Group: `welcome_prompt` is part of the Group type (featured objects)
6. Migrate live agents / groups / Shared Rules as above

## What is out of scope

- Restore / backup dump pages (names with Backup, Restore, sauvegarde, Copie)
  stay `page`
- Archived agents without a fence may stay unlinked until revived
- Live Hermes profiles: do not apply until the user says the redesign is done
  (companion skill `hermes-profiles`)
