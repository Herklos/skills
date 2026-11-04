# Prompt type (system / welcome / shared_rules / library / draft)

Canonical copy-into-bot text lives on typed **`prompt`** objects. Agents and
Group pages keep a short pointer in the body and link the Prompt via a
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
| `owner_group` | objects | Owning Group **page** when `prompt_kind=welcome` (featured) |
| `audience` | select | `agent` \| `group` \| `org` \| `library` (featured) |
| `notes` | text | Apply / sync notes |

Also `tag`, `links`, `backlinks`. Put the full prompt text in the **body**
(markdown), not in `notes`.

## Link properties on other types

| On type | Key | Format | Points to |
|---------|-----|--------|-----------|
| `agent` | `system_prompt` | objects | One Prompt (`prompt_kind=system`, usually) |
| `page` (Group) | `welcome_prompt` | objects | One Prompt (`prompt_kind=welcome`) |

Shared Rules and Mission/library pages are themselves type `prompt` (no separate
link property required). Agents still short-point at Shared Rules inside their
system prompt body.

## Naming

| Kind | Name pattern |
|------|----------------|
| system | `{Name} – System prompt` (curly braces optional; keep accents) |
| welcome | `{Group name} – Welcome prompt` |
| shared_rules | keep the existing Shared Rules title when migrating in place |
| library / draft | keep existing title when `set_type` in place |

## Agent body after migrate

1. **Suggested runtime** (narrative; properties + catalogs hold structured facts)
2. **System prompt** heading + one paragraph pointer to the linked Prompt
   (property **System prompt** / `system_prompt`)
3. Memory pages / standing notes that are not the copy-into-bot fence

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

Groups stay type `page`. Replace `## Welcome (copy-paste)` + fence with:

```markdown
## Welcome prompt
Canonical welcome paste lives on the linked **Welcome prompt** property
([{Group} – Welcome prompt](anytype://object?objectId=<promptId>&spaceId=<spaceId>)).
```

Set `welcome_prompt` to that Prompt id.

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

## Create a welcome Prompt + link a Group page

Same pattern with `prompt_kind=welcome`, `owner_group=[<groupPageId>]`,
`audience=group`, then Group page `welcome_prompt=[<promptId>]`.

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

Use `prompt_kind=library` for Mission & Prompt style libraries; `draft` for
draft agent designs that stay typed as Prompt until promoted.

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
4. On Agent: `add_property` **System prompt** (`system_prompt`, objects, featured)
5. On Page: `add_property` **Welcome prompt** (`welcome_prompt`, objects)
6. Migrate live agents / groups / Shared Rules as above

## What is out of scope

- Restore / backup dump pages (names with Backup, Restore, sauvegarde, Copie)
  stay `page`
- Archived agents without a fence may stay unlinked until revived
- Live Hermes profiles: do not apply until the user says the redesign is done
  (companion skill `hermes-profiles`)
