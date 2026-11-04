# Agenda + Schedule types

Each live Agent owns an **Agenda**: a Query of typed **`schedule`** objects
filtered by `owner_agent`. Agents schedule work by creating Schedule objects;
the Agenda Query lists them. Calendar view on `next_run` uses Anytype Date
Objects (every date is an Object; Calendar views plot Date Properties). Docs:
https://doc.anytype.io/anytype/features/dates

There is **no** separate Agenda type. Agenda = Query (same pattern as
`skills_page` / `logs_page`). Point at it via Agent.`agenda_page`.

Editing Anytype does **not** create Hermes cron jobs. Apply recurring Schedules
with skill `hermes-profiles` → `cron.md` when the user asks (not during the
redesign pass unless they say apply).

Property inventory: `object-types.md`. Body dump: `type-templates.md`. Hermes
field map: `hermes-profiles` `cron.md`.

## Type keys

| Type key | Plural | Use for |
|----------|--------|---------|
| `schedule` | Schedules | One recurring / oneshot / event job owned by an Agent |

**Default template:** `Schedule default`.

Agenda **indexes** are type **`query`** filtered over `schedule` by
`owner_agent`. Point at them via `agenda_page`.

## Schedule properties

| Key | Format | Notes |
|-----|--------|-------|
| `owner_agent` | objects | Owning Agent (featured; required). Agenda Query filter |
| `schedule_key` | text | Stable lowercase-hyphen id (featured). Prefer as Hermes `--name` |
| `schedule_kind` | select | `recurring` \| `oneshot` \| `event` (featured) |
| `schedule_expr` | text | Cron expr or natural schedule string (featured). Empty for pure events |
| `timezone` | text | Wall-clock zone (featured), e.g. `Europe/Paris` |
| `next_run` | date | Next fire / calendar anchor (featured). Powers Calendar view + Date Objects |
| `intent` | text | Short what/when for routers and Hermes apply (featured) |
| `deliver` | text | Hermes deliver target (`origin`, `local`, `telegram`, …) |
| `skills` | text | Comma list of skill keys to load before the prompt |
| `workdir` | text | Absolute project dir when needed |
| `model_pin` | text | Per-job model/provider note, or `cron.model` / `main` |
| `no_agent` | checkbox | Script-only job (`--no-agent`) |
| `script_path` | text | Script path when `no_agent` |
| `paused` | checkbox | Create/keep paused until resume |
| `paused_reason` | text | Why paused |
| `hermes_job_id` | text | Filled after Hermes apply (runtime id) |
| `hermes_job_name` | text | Usually mirrors `schedule_key` after apply |
| `lifecycle` | select | Shared `draft` \| `live` \| `archived` (featured) |
| `notes` | text | Migration provenance / apply notes |

Object **name** pattern: `{schedule_key} – {OwnerShort}` (e.g.
`mardi-proposition-semaine – Philippe`). Body holds Prompt / Delivery / Notes
(Schedule default).

### Kind meanings

| Kind | Meaning |
|------|---------|
| `recurring` | Hermes cron / Bot Routine with `schedule_expr` (+ timezone) |
| `oneshot` | Single fire (`in 30m`, one cron fire, then done) |
| `event` | Wake / queue-driven (no fixed timer yet). Keep `schedule_expr` empty; document wake text in body Notes |

Only **`recurring`** (and oneshot with a concrete expr) map 1:1 to
`hermes cron create`. Event rows stay Anytype-only until a timer exists.

## Link property on Agent

| On type | Key | Format | Points to |
|---------|-----|--------|-----------|
| `agent` | `agenda_page` | objects | Agenda **Query** for this agent |

## Naming

| Kind | Name pattern |
|------|----------------|
| schedule | `{schedule_key} – {OwnerShort}` |
| Agenda Query | `{OwnerShort} – Agenda` |

## Dates and Calendar

- Set `next_run` when the next fire is known (ISO date or datetime).
- Agenda Query: add a **Calendar** view on property `next_run` so slots open
  Anytype Date Objects (temporal index of Schedules for that agent).
- Keep a table view sorted by `next_run` asc (`empty_placement: end`) for
  backlog / paused / event rows without a date.
- Mentions: `@date` / `/date` in Schedule body when useful; prefer the
  `next_run` property for Calendar.

## Create Schedule + Agenda Query

1. Ensure type `schedule` + Schedule default template exist (bootstrap below).
2. Create the Agenda Query once per live agent; link `agenda_page`.
3. Create Schedule objects with `owner_agent` set; they appear in the Query.

### Agenda Query (simple filter)

```json
{
  "space_id": "<spaceId>",
  "name": "Lee – Agenda",
  "type": "schedule",
  "filter": "owner_agent IN (\"<agentId>\")",
  "sorts": [
    {
      "property": "next_run",
      "direction": "asc",
      "empty_placement": "end"
    }
  ]
}
```

Do **not** pass both top-level `filter` and `views` in one create (ambiguous).
Create with simple filter first, then add a Calendar view via insert-view /
patch when needed. Prefer Calendar on agents that already have dated Schedules.

Patch Agent: `agenda_page=[<queryId>]`.

### Create Schedule

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "schedule",
    "name": "morning-brief – Lee",
    "properties": {
      "owner_agent": ["<agentId>"],
      "schedule_key": "morning-brief",
      "schedule_kind": ["recurring"],
      "schedule_expr": "0 9 * * 1-5",
      "timezone": "Europe/Paris",
      "intent": "Weekday morning brief of overnight CI and Sev-1s.",
      "deliver": "origin",
      "skills": "weekly-hq-brief",
      "lifecycle": ["draft"]
    },
    "markdown": "## Prompt\nScheduled run. Summarize overnight CI failures and open Sev-1s. Be concise.\n\n## Delivery\norigin\n\n## Notes\nDraft until Hermes apply.\n"
  }
}
```

Body sections: **Prompt** (full self-contained task for a fresh Hermes session),
**Delivery**, **Notes**.

## Prompt wording (agents)

Every agent system Prompt and Shared Rules must tell the agent to **use the
Agenda to schedule things**:

1. **Shared Rules** — standing rule (org: rule **23**): create type `schedule` on
   Agenda (`agenda_page`); prefer Agenda over chat/markdown-only lists.
2. **System Prompt** — short `# Agenda (mandatory)` section (or rely on Shared
   Rules pointer + this rule). Template text:

```text
# Agenda (mandatory)
When you schedule recurring work, a one-shot timer, or an event wake, create an
Anytype **schedule** on your Agenda Query (`agenda_page`): owner_agent=you,
schedule_key, schedule_kind (recurring|oneshot|event), schedule_expr+timezone
when timed, intent/deliver/skills, body Prompt self-contained. Prefer the Agenda
over chat-only or markdown-only schedule lists (Shared Rules #23).
```

3. New agents: include the section when creating the system Prompt (`prompts.md`
   + `page-templates.md`). Live agents: Shared Rules + system Prompt patches.

Editing the Prompt does not reload live Hermes SOUL until apply.

## Agent body pointer

Prefer property `agenda_page` over long markdown job lists. On the Agent body,
keep a short Agenda pointer (replace old Automations / Noodle / Hermes schedule
prose):

```markdown
## Agenda
Canonical scheduled work lives on the linked **Agenda** Query
([{OwnerShort} – Agenda](anytype://object?objectId=<queryId>&spaceId=<spaceId>)).
Create typed **Schedule** objects (`owner_agent` = this agent). Recurring rows
apply via hermes-profiles `cron.md` when asked.
```

Agenda Query + Schedule properties hold scheduled work; do not keep Suggested runtime **Scheduled tasks** bullets on the Agent body. A one-line summary
that points at the Agenda; do not duplicate every field in markdown when
Schedule properties are filled.

## Hermes bind (decline)

Source of truth for intended jobs: Schedule objects on the agent's Agenda.
Apply only when the user asks (redesign default: document only).

| Schedule field | Hermes |
|----------------|--------|
| `schedule_key` | `--name` / job name |
| `schedule_expr` | schedule arg (cron or natural) |
| `timezone` | `--timezone` |
| body **Prompt** | prompt string (fresh session; self-contained) |
| `skills` | repeated `--skill` |
| `deliver` | `--deliver` |
| `workdir` | `--workdir` |
| `model_pin` | `--model` / `--provider` / `--pin` / leave to `cron.model` |
| `no_agent` + `script_path` | `--no-agent --script …` |
| `paused` + `paused_reason` | `--paused --paused-reason …` |
| `hermes_job_id` / `hermes_job_name` | write back after create |

Skip apply when `schedule_kind=event`, `lifecycle=archived`, or
`schedule_expr` empty. Prefer `lifecycle=live` + unpaused for create; keep
`draft` / paused until approved.

Full CLI / config: hermes-profiles `cron.md` section **Anytype Agenda → Hermes**.

## Migrate legacy schedule prose

1. Inventory agent bodies for Automations / Noodle schedule / Hermes schedule /
   Routines / Scheduled tasks lists.
2. For each concrete job: create a `schedule` with `owner_agent`, `schedule_key`,
   kind, expr/timezone when known, intent, deliver, skills, lifecycle
   (`live` only when already running; else `draft`).
3. Merge related routines into one Schedule when they share a timer (e.g. Friday
   competitor veille inside daily project state).
4. Ensure Agenda Query + `agenda_page`; optional Calendar view on `next_run`.
5. Replace body schedule sections with the Agenda pointer.
6. Do **not** run `hermes cron create` unless the user asks to apply.

## Search

```json
{
  "space_id": "<spaceId>",
  "type": "schedule",
  "limit": 100,
  "fields": [
    "name",
    "schedule_key",
    "schedule_kind",
    "schedule_expr",
    "timezone",
    "next_run",
    "lifecycle",
    "paused",
    "owner_agent"
  ]
}
```

## Bootstrap in a new space

1. `API-create-type` `schedule` (`create_missing_options: true`); reuse shared
   `owner_agent`, `lifecycle`, `notes` via `"property"` keys when present.
   Featured: `owner_agent`, `schedule_key`, `schedule_kind`, `schedule_expr`,
   `timezone`, `next_run`, `intent`, `lifecycle`.
2. Prefer `default_view: calendar` on the type when creating.
3. `API-create-template` Schedule default; set `default_template`.
4. On Agent: `add_property` **Agenda page** (`agenda_page`) reusing shared
   objects-format keys when possible.
5. Create Agenda Query per live agent; set `agenda_page`; migrate prose into
   Schedule objects.

## Out of scope

- Live Hermes cron create/edit during redesign unless the user says apply
- A separate Agenda object type (use Query)
- Using Logs as schedule history (Logs stay activity summaries)
