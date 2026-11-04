# HQ standing instructions (Prompt library)

Long HQ gates, principles, and routing live on a typed **`prompt`**
(`prompt_kind=library`, `audience=org`) linked from Team.`standing_instructions`.
HQ bodies stay short (Subteams Query pointer + Standing instructions pointer).
Agent system Prompts keep a short mandatory section; they do **not** paste the
full library (token economy).

Shared Rules still apply org-wide. Standing instructions add HQ-specific detail;
they do not override Shared Rules.

Property inventory: `object-types.md` (Team). Prompt kinds: `prompts.md`.
Body shapes: `page-templates.md` / `type-templates.md`.

## Why

Unstructured HQ prose (delivery gates, quality gates, routing, principles) used
to sit in the HQ page body. Agents either missed it or duplicated it into every
system Prompt (bloat). Pattern:

1. One library Prompt per HQ / Board (canonical standing text)
2. Team.`standing_instructions` → that Prompt (featured)
3. Slim HQ body: Subteams Query (`subteams_page`) + pointer to the Standing Prompt
4. Short `# HQ standing instructions (mandatory)` in every system Prompt
5. Shared Rules rule pointing agents at HQ Standing instructions
6. Consumption details in this skill (not in every Prompt)

## Link property on Team

| On type | Key | Format | Points to |
|---------|-----|--------|-----------|
| `team` | `standing_instructions` | objects | One Prompt (`prompt_kind=library`, usually `audience=org`) (featured) |

Board uses the same property when it has standing routing / channel rules.

## Naming

| Kind | Name pattern |
|------|----------------|
| library Prompt | `{HQ or Board name} – Standing instructions` |
| HQ body pointer | short paragraph under Map notes |

## Create standing Prompt + link an HQ

1. Create type `prompt` with `prompt_kind=library`, `lifecycle=live`,
   `audience=org`, body = full standing text (gates / rules / routing /
   principles). Optional `notes`: "Linked from Team.standing_instructions."
2. On the Team: `set_properties` `standing_instructions=[<promptId>]`
3. Slim the HQ body: replace long Rules / Delivery / Routing sections with Map
   notes + pointer (`replace_subtree` on headings, `delete_block` on sibling
   list/paragraph blocks that held the old prose)

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "prompt",
    "name": "Engineering HQ – Standing instructions",
    "properties": {
      "prompt_kind": ["library"],
      "lifecycle": ["live"],
      "audience": ["org"],
      "notes": "Linked from Engineering HQ.standing_instructions. Do not paste into every agent Prompt."
    },
    "markdown": "## Delivery and quality gates\n1. …\n\n## Routing\n- …\n"
  }
}
```

Then:

```json
{
  "ops": [
    {
      "op": "set_properties",
      "set": {
        "standing_instructions": ["<promptId>"]
      }
    }
  ]
}
```

## HQ body after migrate

```markdown
# {Name} HQ

## Subteams
Canonical domain roster is the linked **Subteams page** Query
([{Name short} – Subteams](anytype://object?objectId=<queryId>&spaceId=<spaceId>)).

## Standing instructions
Canonical gates and routing live on the linked **Standing instructions** Prompt
([{Name} – Standing instructions](anytype://object?objectId=<promptId>&spaceId=<spaceId>)).

## HQ coordination
Group, Skills, and Transition plan links stay here as needed.
```

Do **not** keep a second full Rules / Delivery / Routing dump on the HQ once the
library Prompt is linked. Do **not** keep a static Sub-teams / Domains /
Notion-map table once Team.`subteams_page` points at the filtered Query.

## Resolve which HQ standing Prompt to open

1. Agent.`team` → Team or Subteam
2. If Subteam: Subteam.`parent_team` → HQ Team
3. HQ Team.`standing_instructions` → Prompt library
4. Open that Prompt (`format: "md"`) before gated work

Board standing (when present): Board Team.`standing_instructions`.

## Prompt wording (agents)

Every agent system Prompt and Shared Rules must tell the agent to **open HQ
standing instructions** before gated work:

1. **Shared Rules** — standing rule (org: rule **24**): resolve HQ → open
   Team.`standing_instructions`; do not invent HQ policy.
2. **System Prompt** — short `# HQ standing instructions (mandatory)` section.
   Template text:

```text
# HQ standing instructions (mandatory)
Before delivery, routing, merge, design, legal, finance, or cross-HQ work, open
your HQ Team → **Standing instructions** (Prompt library). Follow those
gates/rules/routing. Do not invent HQ policy. Shared Rules still apply org-wide.
```

3. New agents: include the section when creating the system Prompt
   (`prompts.md` + `page-templates.md`). Live agents: Shared Rules + system
   Prompt patches.

Do **not** paste the full standing library into the system Prompt. Étienne-class
prompts are already large; pointers + skill docs keep them small.

Editing the Prompt does not reload live Hermes SOUL until apply.

## Shared Rules starter line

```markdown
14) HQ standing instructions (mandatory)
Before delivery, routing, merge, design, legal, finance, or cross-HQ work: open
your HQ Team → Standing instructions (Prompt library via Team.standing_instructions).
Follow those gates/rules/routing. Do not invent HQ policy. Shared Rules still apply.
```

(Org live Shared Rules may number this as **24** after other rules; keep the
same meaning.)

## Migrate legacy HQ body prose

1. Inventory each HQ / Board for long Rules / Delivery / Principles / Routing
   sections.
2. Create `{Name} – Standing instructions` Prompt (`prompt_kind=library`).
3. Move the prose into the Prompt body (preserve meaning; tighten lightly).
4. Set Team.`standing_instructions`.
5. Slim HQ body to Subteams Query pointer + Standing instructions pointer
   (remove static Sub-teams / Domains / Notion-map sections).
6. Patch Shared Rules + every live system Prompt with the short mandatory
   section (append after Agenda when present).
7. Do **not** apply Hermes SOUL until the user asks.

## Search

```json
{
  "space_id": "<spaceId>",
  "type": "prompt",
  "limit": 50,
  "fields": ["name", "prompt_kind", "lifecycle", "audience"]
}
```

Filter Teams missing the link:

```json
{
  "space_id": "<spaceId>",
  "type": "team",
  "limit": 50,
  "fields": ["name", "kind", "standing_instructions", "lifecycle"]
}
```

## Bootstrap in a new space

1. On Team: `add_property` **Standing instructions** (`standing_instructions`,
   objects, featured) and **Subteams page** (`subteams_page`, objects,
   featured). Reuse shared objects-format keys when possible.
2. Create one library Prompt per HQ / Board; set `standing_instructions`.
3. Create `{HQ short} – Subteams` Query (`type: subteam`,
   `filter: parent_team IN ("<hqId>")`); set `subteams_page`.
4. Keep HQ default template body as Subteams + Standing pointers
   (`type-templates.md`).
5. Include `# HQ standing instructions (mandatory)` in system Prompt skeleton.
6. Add the Shared Rules line above.

## Out of scope

- Pasting standing libraries into Agent system Prompts
- Hermes SOUL apply during redesign unless the user says apply
- Subteam-local standing libraries (prefer HQ-level; Subteam map notes only)
- Using Memory objects for HQ gates (Prompt library is the chosen store)
