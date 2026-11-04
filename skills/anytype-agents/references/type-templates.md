# Object type default templates (dump)

Canonical **body markdown** for each inventory type's default template. Use these
when bootstrapping a new space (`API-create-template` + set
`default_template`), auditing drift against live templates, or creating objects
with `template: "none"` and pasting the body yourself.

Resolve live template **ids** each session with `API-list-templates` (filter by
`type`). Do not hardcode ids. Omit `template` on create to apply the type's
current default.

Companion shapes (HQ / Group / Skill / prompt skeleton): `page-templates.md`.
Property keys: `object-types.md`.

Dumped / authored **2026-11-04**; property-complete pass **2026-11-04** (v1.18.0);
runtime catalogs **2026-11-04** (v1.19.0): Browser / Computer / Tool profile
types + Agent/Team/Subteam link props. Per-HQ Browser/Computer pairs
**2026-11-04** (v1.22.0): one `{HQ} – Cua Spaces` + `{HQ} – Cua Chromium` per
HQ; Subteams/Agents inherit; Board/Primary empty. Prefer properties for mission /
members / routing / short description / autonomy / map path / browser /
computer / tool_profile; template bodies keep Suggested runtime + Full System
Prompt and optional long notes.

---

## Agent default (`template_for`: `agent`)

Set Autonomy / Short description / Memory pages / Map path as **properties**
(`object-types.md`). Template body:

````markdown
## Suggested runtime (YYYY-MM-DD)
**Harness profile:** {Local router (default) | Coding | Data fetching | …}  (Agent.`harness_profile`)
**model.* (from profile):** {provider} · {model_default} · {effort}
**fallback_providers (from profile):**
- 1: {provider} · {model} · {effort}
- 2: {provider} · {model} · {effort}
**auxiliary (from profile):** vision / compression / web_extract / skills_hub / title_generation (auto unless set)
**Catalog harnesses:** claude | codex | grok | github-copilot | muse | nvidia-nim | local-model
**Subagents / delegation:** Agent.`delegation_enabled` + Agent.`subagents`. Parent Local router answers light/peer asks itself; model_map routes when specialized work is needed.
**Browser / Computer / Tools:** Agent.`browser` / `computer` / `tool_profile` (catalog links; defaults owning HQ Cua Chromium / HQ Cua Spaces / Standard interactive; Primary leaves browser+computer empty).
**Terminal / computer selects:** Agent.`terminal_backend` / `computer_surface` (defaults cua / cua-spaces; Primary `computer_surface: none`; keep aligned with linked Computer / Tool profile).
**Voice:** Agent.`voice_enabled` / `voice_auto_tts` / `voice_chat_mode` / `messaging_voice_mode`; STT/TTS from Harness profile (Local router: local+edge) or Agent overrides.
**Personality / Memory / Limits / Security / Workspace:** fill from hermes-profiles references when applying via Hermes (see suggested-runtime.md).

## Full System Prompt (copy into the bot)
```
# Role
You are {Name}, …

# Shared rules
Follow **Agents → Agent Template – Shared Rules** in full.

# Tools and systems
- Harness profile: {name} (model.* + fallbacks + aux from that object)
- Browser / Computer / Tool profile: {linked catalog names}
- Models / personality / memory / security / workspace: see Suggested runtime + Agent properties

# Escalation
{chief → Primary → Human}
```
````

Full Suggested runtime field list: `suggested-runtime.md`. Filled sample:
`examples.md`.

---

## Team default (`template_for`: `team`)

For Board / HQ / Group. Domains under an HQ use **Subteam default** (type
`subteam`), not a second Team with a Sub-team kind.

Set `kind`, `chief`, `members`, `subteams`, `mission`, `routing_summary` as
properties. Template body:

```markdown
## Rules
1. Follow Agents → Agent Template – Shared Rules.

## Map notes
(Optional detail beyond `routing_summary` / `subteams` / `members`.)
```

---

## Subteam default (`template_for`: `subteam`)

Live type + default template. Set `parent_team`, `chief`, `lifecycle`,
`mission`, `members`, `routing_summary` as properties. Template body:

```markdown
## Map notes
(Optional detail beyond properties.)
```

---

## Harness default (`template_for`: `harness`)

```markdown
## Purpose
What this product is for in the org.

## Notes
Capability limits, auth, when to prefer another harness.
```

Set `slug` to one of: `claude`, `codex`, `grok`, `github-copilot`, `muse`,
`nvidia-nim`, `local-model`.

---

## Harness profile default (`template_for`: `harness_profile`)

```markdown
## When to use
Intent and agent roles this stack fits.

## Stack summary
- model.*: {provider} · {model_default} · {effort} · harness {catalog}
- fallback_1: {provider} · {model} · {effort}
- fallback_2: {provider} · {model} · {effort}
- auxiliary: vision / compression / web_extract / skills_hub / title_generation
  (provider/model/effort; auto = inherit main)
- Voice: STT {provider}/{model} · TTS {provider}/{voice} · speed {1} (or none)

## Apply notes
Editing this profile updates the intended models (and voice stack) for every
Agent linked via `harness_profile`. Re-apply into each live runtime (Claude /
Codex / Grok / Hermes / …) separately. Anytype does not push configs
automatically. Decline `model_*` / `fallback_*` / `aux_*` via hermes-profiles
`models.md` (Local router: llamacpp + local_runtime) and voice via `voice.md`
(default local+edge).
```

Example stacks: **Local router** (`llamacpp` / `d1-2b-q4_k_m` medium → xai Grok
4.5 → anthropic Haiku 5.5) for most Agents; Coding / Data fetching for Subagent
routes.

---

## Subagent default (`template_for`: `subagent`)

```markdown
## When to use
{intent / task the parent should pick this route for}

## Route
- task_key: {fast | deep | fetch | …}
- parent_agent: {Agent name}
- harness_profile: {Coding | Data fetching | …}
- spawn_effort override: none | low | medium | high
- model_override: none | {label}

## Scope
{cwd / read-only / web-only / single-repo / …}

## Tools
{toolsets list or inherit}

## Deliver back
{what the child must return to the parent}

## Hermes apply
Decline into the parent's `delegation.backends.model_map.options` (see
hermes-profiles `delegation.md`). Re-apply after Subagent edits; Anytype does
not push configs automatically.
```

Set `parent_agent`, `task_key`, and `harness_profile` on create. Also add this
object to Agent.`subagents`.

---

## Browser default (`template_for`: `browser`)

```markdown
## When to use
(Set properties: slug, access_needed, browser_source, browser_identity, headed.
Body for apply notes.)

## Apply
Map to hermes-profiles browser-and-computer.md. Anytype does not push configs.
```

---

## Computer default (`template_for`: `computer`)

```markdown
## When to use
(Set properties: slug, access_needed, computer_surface, computer_scope,
permission_mode, desktop_enabled. Body for apply notes.)

## Apply
Map to hermes-profiles browser-and-computer.md (Cua Spaces default). Anytype
does not push configs.
```

---

## Tool profile default (`template_for`: `tool_profile`)

```markdown
## When to use
(Set properties: slug, intent, enabled/disabled toolsets, tool_approvals,
cron_approvals, terminal_backend, timeout_seconds.)

## Apply
Map to hermes-profiles runtime-limits-and-tools.md. Pair with linked Browser /
Computer when those toolsets are enabled. Anytype does not push configs.
```

---

## Project default (`template_for`: `project`)

Set `one_liner`, `overview`, `execution_policy`, `lead_agent`,
`related_projects`, and child `*_page` links as properties. Template body:

```markdown
## Core Features
…

## Architecture
…

## Target Users
…

## Key Differentiators
…
```

Common children: Technical, Business, Project Management (Roadmap / Backlog /
TODO), Product, Design, Marketing (also link via `technical_page` / …).

---

## Recreate a default template (MCP)

1. `API-create-template` with `template_for` = `agent` | `team` | `subteam` |
   `subagent` | `harness` | `harness_profile` | `browser` | `computer` |
   `tool_profile` | `project`, name `{Type} default`, and body blocks from the
   matching section above (`heading_2` + `paragraph`).
2. `API-list-templates` with that `type` → note the new id.
3. `API-update-type` on the type: `{ "default_template": "<templateId>" }`.
4. Verify: create a throwaway object of that type with no `template` arg and
   confirm the body sections match.

## Drift check

1. `API-list-templates` for `agent`, `team`, `subteam`, `subagent`, `harness`,
   `harness_profile`, `browser`, `computer`, `tool_profile`, `project`.
2. `API-get-object` each default (`format: "md"`).
3. Diff against this file. Update the skill dump when the live org intentionally
   changes the defaults; update live templates when the skill is the source of
   truth for a bootstrap.
