# Object types (Agent, Team, Subteam, Subagent, Harness, Harness profile, Browser, Computer, Tool profile, Runtime, Vault grant, Prompt, Group, Project)

Org inventory uses dedicated Anytype types (not plain `page`) so you can filter,
feature properties, and start from body templates. Discover live keys with
`API-list-types` / `API-get-type` and templates with `API-list-templates`.

Messaging rooms use typed **`group`** (welcome Prompt + platform fields). Hub
scaffolding (Agents / Projects roots, drafts) may stay `page`. **Shared Rules**,
system/welcome prompts, and prompt libraries use type **`prompt`** (see
`prompts.md`). Agent support notes use type **`memory`**; procedures use type
**`skill`**; per-action summaries use type **`log`**; improvement feedback uses
type **`suggestion`**; Skills, Logs, and Suggestions indexes are **Queries**
(see `memory-and-skills.md` + `suggestions.md`). Scheduled jobs use type
**`schedule`**; each Agent's **Agenda** is a Query filtered by `owner_agent`
via `agenda_page` (see `agenda-and-schedules.md`).

## Type keys

| Type key | Plural | Use for |
|----------|--------|---------|
| `agent` | Agents | Primary, chiefs, specialists, archived agents |
| `team` | Teams | Board and HQs (`kind`: Board / HQ) |
| `group` | Groups | Messaging roster + welcome Prompt + platform fields (not Team `kind: Group`) |
| `subteam` | Subteams | Domains / pods under an HQ (**preferred**; do not model these as `team` with `kind: Sub-team`) |
| `subagent` | Subagents | Spawn configs an Agent may start (task, harness profile, scope, tools). Not the same as `subteam` |
| `harness` | Harnesses | Product catalog: Claude, Codex, Grok, GitHub Copilot, Muse, NVIDIA NIM, Local model |
| `harness_profile` | Harness profiles | Reusable Hermes-shaped model / fallback / aux stacks. Agents and Subagents link here |
| `browser` | Browsers | Reusable browser access catalog (`is_real` / engine / pin + source + identity). Agents / Teams / Subteams link here |
| `computer` | Computers | Reusable computer / desktop catalog (surface + scope). Agents / Teams / Subteams link here |
| `tool_profile` | Tool profiles | Reusable toolsets + approvals + terminal. Agents / Teams / Subteams link here |
| `runtime` | Runtimes | Where the agent runs: `grok-bot` \| `hermes` \| `osaurus` \| `noodle`. Agents link via Agent.`runtime` |
| `vault_grant` | Vault grants | **Capability only:** which Agents may use which site / login identity. No passwords (`hermes-profiles` → `browser-and-computer.md`) |
| `prompt` | Prompts | System prompts, group welcomes, Shared Rules, libraries, drafts (`prompts.md`) |
| `memory` | Memories | Durable agent notes (`memory-and-skills.md`) |
| `skill` | Skills | Procedures / templates / guides (`memory-and-skills.md`) |
| `log` | Logs | Per-action activity summaries (`memory-and-skills.md`) |
| `suggestion` | Suggestions | Improvement feedback (model/subagent/skill/harness/…); Queries via Agent.`suggestions_page` (`suggestions.md`) |
| `schedule` | Schedules | Recurring / oneshot / event jobs; Agenda Queries via Agent.`agenda_page` (`agenda-and-schedules.md`) |
| `project` | Projects | Portfolio roots under the Projects hub (built-in type, extended) |
| `epic` | Epics | Large delivery themes under a project (Roadmap Query) |
| `user_story` | User stories | Backlog stories under a project (Backlog Query) |
| `task` | Tasks | Built-in todo type extended with `kind` + project links (TODO Query) |

Hub roots named **Agents** / **Projects** may remain `page`; their inventory
children use the keys above. Keep Harness + Harness profile + Browser + Computer
+ Tool profile + Runtime objects under Agents → Shared (or a Runtime / Harnesses index).
Keep Subagent objects linked from their parent Agent (`parent_agent` +
Agent.`subagents`).

**Name collision:** `subteam` = org domain under an HQ. `subagent` = runtime
worker/route the parent Agent can `delegate_task` (or equivalent). Do not mix them.

Skills resolution order when a space uses Subteams:
**Agent → Subteam → Team → Project → Global**.

## Agent (`api_key`: `agent`)

**Properties hold structured facts.** Do not duplicate Short Description,
Autonomy, Team, Reports to, HQ / Home / Chief / map path, Hermes slug, browser /
computer / tools, or linked projects in markdown. Agent body keeps a short
**System prompt** pointer + **Agenda** pointer only (no `## Suggested runtime`
section). Canonical copy-into-bot text lives on a linked **`prompt`** object
(`system_prompt`); see `prompts.md`. Runtime apply checklist (Hermes only):
`suggested-runtime.md`.

Featured properties (API keys):

| Key | Format | Notes |
|-----|--------|-------|
| `role` | text | e.g. Primary, Chief, Implementer |
| `team` | objects | Link to owning Team or Subteam |
| `reports_to` | objects | Link to chief / Primary agent |
| `lifecycle` | select | `draft` \| `live` \| `archived` |
| `harness_profile` | objects | Link to one **Harness profile** (source of `model.*` / fallbacks / aux). **Default for most agents: Local parent** |
| `subagents` | objects | Zero or more **Subagent** spawn configs this agent may start |
| `system_prompt` | objects | Link to one **Prompt** (`prompt_kind=system`; canonical SOUL / system text) |
| `browser` | objects | Link to one **Browser** catalog object |
| `computer` | objects | Link to one **Computer** catalog object |
| `tool_profile` | objects | Link to one **Tool profile** catalog object |
| `runtime` | objects | Link to one **Runtime** catalog object (`grok-bot` / `hermes` / `osaurus` / `noodle`) |
| `voice_enabled` | checkbox | Intended to use Hermes voice mode (featured) |
| `analytics_enabled` | checkbox | When true, Hermes apply enables the **langfuse** observability plugin (featured). Opt-in; default false. Org: Primary (P) true; others leave false until asked |
| `board_member` | checkbox | Board seat |

Other properties:

| Key | Format | Notes |
|-----|--------|-------|
| `autonomy` | select | `read-only` \| `propose` \| `change-with-gates` |
| `hermes_profile` | text | Hermes home slug under `~/.hermes/profiles/<slug>` when applying via `hermes-profiles` |
| `short_description` | text | One-liner mission |
| `memory_pages` | objects | Typed **Memory** children (decisions, lessons, resources, …) |
| `skills_page` | objects | Skills **Query** for this agent |
| `logs_page` | objects | Logs **Query** for this agent (per-action summaries; Calendar on `logged_at`) |
| `agenda_page` | objects | Agenda **Query** for this agent (Schedules filtered by `owner_agent`; Calendar on `next_run`) |
| `suggestions_page` | objects | Suggestions **Query** for this agent (improvement feedback; Shared Rule 25) |
| `memory_review_off` | checkbox | When true, Memory Keeper (Agathe) skips this agent in Sunday hygiene (featured) |
| `messaging_group` | objects | Typed **Group** (chat roster) |
| `map_path` | text | `Agents → HQ → [Subteam →] Agent` |
| `delegation_enabled` | checkbox | Parent may spawn Subagents |
| `terminal_backend` | select | `cua` \| `local` \| `docker` \| `ssh` \| `other` (org default: `cua`; keep aligned with linked Tool profile) |
| `computer_surface` | select | `cua-spaces` \| `host` \| `bot-screen` \| `none` (org default: `cua-spaces`; keep aligned with linked Computer) |
| `voice_auto_tts` | checkbox | Hermes `voice.auto_tts` |
| `voice_chat_mode` | select | `off` \| `chained` \| `gpt-live` (Desktop voice chat) |
| `messaging_voice_mode` | select | `off` \| `voice_only` \| `all` (Telegram/Discord `/voice`) |
| `stt_provider` | select | Shared with Harness profile; optional agent override |
| `stt_model` | text | Optional agent override (e.g. `base`) |
| `tts_provider` | select | Shared with Harness profile; optional agent override |
| `tts_voice` | text | Provider-specific voice id (e.g. `en-US-AriaNeural`) |
| `tts_speed` | number | Optional; default `1` |
| `voice_notes` | text | Apply notes |

Also includes shared `tag`, `links`, `backlinks`.

Prefer catalog links (`browser`, `computer`, `tool_profile`) as the structured
source for Browser / Computer / Tools / Terminal detail. Keep
`terminal_backend` / `computer_surface` selects consistent with those links for
quick filters. Do not paste a Suggested runtime body section once these
properties are set.

**Voice:** Harness profile holds the shared STT/TTS stack. Agent holds enablement
/ modes and may override `stt_*` / `tts_*`. Prefer properties over markdown-only
Voice bullets. Hermes apply: `hermes-profiles` → `voice.md`. Org fill: most
agents `voice_enabled=false` / modes `off` with local+edge stack filled for
later enable; Foyer personal assistants may set `voice_enabled=true` +
`voice_chat_mode=chained` + `messaging_voice_mode=voice_only`.

**Analytics:** Agent.`analytics_enabled` gates Langfuse on Hermes apply
(`hermes-profiles` → `anytype-apply.md`). Opt-in only (do not auto-disable when
false). Org fill: Primary true; specialists false until asked. Shared project
keys live on the default profile `.env` (`HERMES_LANGFUSE_*`).

Keep Agent.`subagents` and each Subagent.`parent_agent` in sync (both ways).

**Recommended parent pattern (most agents):**
1. Agent.`harness_profile` → **Local parent** (chat = llamacpp `LFM3-1.7B-Q8_0` / none; approvals
   = llamacpp `d1-2b-q4_k_m`; route picking also uses parent `model.*`)
2. Several Subagents with richer profiles (Chiefs, Coding, Reviewing, Browser,
   Web/MCP, Deep think) for specialized work
3. Parent answers peers / light questions itself when no Subagent route is needed
   (no “quick answer” Subagent required)
4. Exceptions: **Foyer** agents → **Foyer** profile, no Subagents; **Arnold** →
   **CLASQUIN** (Claude subscription), no Subagents

**Do not** use a select `harness` on Agent. Legacy spaces may still have an old
`harness` select (`hermes` / `grok` / …); migrate by linking `harness_profile`
and removing `harness` from the Agent type (`remove_property`).

**Do not** use Agent.`primary_model`. Models live on the linked **Harness
profile** (`model_*` / `fallback_*`). Remove leftover `primary_model` text
properties with `remove_property` when present.

**Default template name:** `Agent default`. Full dumped body:
`type-templates.md`. Also: `page-templates.md`; runtime fields:
`suggested-runtime.md`.

## Team (`api_key`: `team`)

Board / HQ only. Domains under an HQ use type **`subteam`**. Messaging rooms
use type **`group`** (do not create new `team` with `kind: Group`).

| Key | Format | Notes |
|-----|--------|-------|
| `kind` | select | `Board` \| `HQ` (featured). **`Group` option deprecated** (prefer typed `group`) |
| `chief` | objects | Link to chief Agent (featured) |
| `members` | objects | Agent members (featured) |
| `parent_team` | objects | Parent Team when nested (rare; HQs usually sit under Agents) |
| `lifecycle` | select | Shared with Agent (`draft` / `live` / `archived`) |
| `subteams` | objects | Child **Subteam** objects (featured on HQ) |
| `mission` | text | Short mission |
| `messaging_group` | objects | Typed **Group** |
| `skills_page` | objects | HQ Skills **Query** |
| `routing_summary` | text | One-line routing |
| `standing_instructions` | objects | HQ/Board **Standing instructions** Prompt (`prompt_kind=library`) (featured). Full playbook: `hq-standing-instructions.md` |
| `subteams_page` | objects | HQ **Subteams** Query filtered by `parent_team` (featured). Prefer this over a static Sub-teams / Domains body table |
| `system_prompt` | objects | Optional link to a **Prompt** (`prompt_kind=system`). Prefer `standing_instructions` for HQ gates; use `system_prompt` only when an HQ/Board needs bot-facing system text |
| `browser` | objects | Optional team-default **Browser** catalog link |
| `computer` | objects | Optional team-default **Computer** catalog link |
| `tool_profile` | objects | Optional team-default **Tool profile** catalog link |

Also `tag`, `links`, `backlinks`. Put long gates / principles / routing prose on
the linked Standing instructions Prompt; keep the filterable one-liner in
`routing_summary`. Child domains appear on the **Subteams** Query
(`subteams_page`, filter `parent_team IN ("<hqId>")`); keep Team.`subteams` in
sync for featured membership. HQ body stays Map notes + Subteams Query pointer
(no static Sub-teams / Domains / Notion-map tables). Agent-level runtime links
override team defaults when both are set.

**Default template name:** `Team default`. Full dumped body: `type-templates.md`.
Mirror shapes in `page-templates.md` (HQ page). Link child **`subteam`** objects
via `subteams` and the HQ map; do not create new Sub-teams as `team`.

Legacy: older spaces may still have `team` objects with `kind: Sub-team`. Prefer
migrating those to type **`subteam`** via `set_type` (see below). Do not mint new
`Sub-team` select options. Do not mint new Team `kind: Group` objects; migrate
informal Group pages to type **`group`**.

## Subteam (`api_key`: `subteam`)

Dedicated type for domains / pods under an HQ. Prefer this over putting
sub-teams on the `team` type.

| Key | Format | Notes |
|-----|--------|-------|
| `parent_team` | objects | Owning HQ / Team (featured; required when known) |
| `chief` | objects | Lead agent when the subteam has one (else HQ chief) (featured) |
| `lifecycle` | select | Shared with Agent / Team (`draft` / `live` / `archived`) (featured) |
| `mission` | text | Short domain mission |
| `members` | objects | Agent members of this domain |
| `routing_summary` | text | One-line routing |
| `messaging_group` | objects | Typed **Group** when present |
| `skills_page` | objects | Domain Skills **Query** when present |
| `system_prompt` | objects | Optional **Prompt** link (rarely used; domains usually inherit HQ standing + agent system prompts) |
| `browser` | objects | Optional domain-default **Browser** catalog link |
| `computer` | objects | Optional domain-default **Computer** catalog link |
| `tool_profile` | objects | Optional domain-default **Tool profile** catalog link |

Also `tag`, `links`, `backlinks`. No `kind` property: the type itself is the kind.
Agent-level runtime links override subteam defaults when both are set.

**Default template name:** `Subteam default`. Body: `type-templates.md`. Also
`page-templates.md` (Subteam page).

Agent `team` (objects) may link the owning HQ **or** this Subteam when the agent
sits under a domain.

## Subagent (`api_key`: `subagent`)

Spawn / route config a parent **Agent** may start. An agent has zero or more
Subagents. Distinct from **`subteam`** (org domain).

| Key | Format | Notes |
|-----|--------|-------|
| `parent_agent` | objects | Owning Agent (required). Keep in sync with Agent.`subagents` |
| `task_key` | text | Stable route name the parent picks (`fast`, `deep`, `fetch`, …). Maps to Hermes `model_map` option `name` |
| `harness_profile` | objects | **Harness profile** for this spawn (may differ from the parent's) |
| `lifecycle` | select | `draft` \| `live` \| `archived` |
| `intent` | text | Short when-to-use (becomes route `description` when declined to Hermes) |
| `scope` | text | Bounds: cwd, read-only, web-only, single-repo, … |
| `toolsets` | text | Enabled toolsets for the child (e.g. `web,terminal,file` or `inherit`) |
| `spawn_effort` | select | Optional override: `low` \| `medium` \| `high` (else use profile primary effort). Display name **Spawn effort** (avoids clash with a numeric Effort property) |
| `model_override` | text | Optional pin over the linked Harness profile primary |
| `deliver_back` | text | What the child must return to the parent (summary shape) |
| `system_prompt` | objects | Optional child **Prompt** when the spawn needs its own system text (else inherit parent) |
| `notes` | text | Extra apply notes |

Also `tag`, `links`, `backlinks`.

**Default template name:** `Subagent default`. Body: `type-templates.md`.

**Hermes decline** (skill `hermes-profiles` → `delegation.md`): each live Subagent
on a parent becomes one `model_map` option (`task_key` → `name`, `intent` →
`description`, models from `harness_profile` / `model_override` / `spawn_effort`).
Toolsets and scope are documented on the Subagent and applied to the parent
prompt / child brief; Hermes children inherit the parent's tool policy unless
you use `profile_routes` for a dedicated child profile.

**Example Subagents** (role packs; link from parent Agent.`subagents`):

| Name | task_key | Profile | Intent |
|------|----------|---------|--------|
| Chiefs | `chiefs` | Chiefs | HQ / Primary orchestration |
| Coding | `coding` | Coding | Implementation, debug, tests |
| Review | `review` | Reviewing | Code / doc / PR review |
| Web | `web` | Web/MCP | Web, MCP, data collection |
| Browser | `browser` | Browser | Browser instrumenting |
| Deep | `deep` | Deep think | Analysis, audit, refactor, refine |

## Harness (`api_key`: `harness`)

Product catalog entry. One object per product agents may run on.

| Key | Format | Notes |
|-----|--------|-------|
| `slug` | text | Stable id: `claude` \| `codex` \| `grok` \| `github-copilot` \| `muse` \| `nvidia-nim` \| `local-model` |
| `lifecycle` | select | `draft` \| `live` \| `archived` |
| `vendor` | text | Optional vendor label |
| `docs_url` | url | Optional docs |
| `notes` | text | Short capability notes |

Also `tag`, `links`, `backlinks`.

**Canonical catalog (create these once):** Claude, Codex, Grok, GitHub Copilot,
Muse, NVIDIA NIM, Local model (matching slugs above).

**Default template name:** `Harness default`. Body: `type-templates.md`.

## Harness profile (`api_key`: `harness_profile`)

Reusable Hermes-shaped model stack. Many agents share one profile; edit the
profile to refresh every linked agent's intended `model.*`,
`fallback_providers`, and `auxiliary.<task>.*`.

| Key | Format | Notes |
|-----|--------|-------|
| `intent` | text | e.g. `coding`, `data-fetching`, `ops`, `research`, `local-router` (featured) |
| `lifecycle` | select | `draft` \| `live` \| `archived` (featured) |
| `model_provider` | text | Hermes `model.provider` (featured). e.g. `llamacpp`, `anthropic`, `openai-codex`, `xai`, `openrouter` |
| `model_default` | text | Hermes `model.default` id (featured). e.g. `d1-2b-q4_k_m`, or a display label until the exact id is known |
| `model_effort` | select | `low` \| `medium` \| `high` (featured). Reasoning / effort for main |
| `model_harness` | objects | Optional catalog **Harness** link for org UX (featured). Do not invent provider from this when `model_provider` is set |
| `fallback_1_provider` | text | Hermes `fallback_providers[0].provider` |
| `fallback_1_model` | text | Hermes `fallback_providers[0].model` |
| `fallback_1_effort` | select | `low` \| `medium` \| `high` |
| `fallback_1_harness` | objects | Optional catalog Harness for fallback 1 |
| `fallback_2_provider` | text | Hermes `fallback_providers[1].provider` |
| `fallback_2_model` | text | Hermes `fallback_providers[1].model` |
| `fallback_2_effort` | select | `low` \| `medium` \| `high` |
| `fallback_2_harness` | objects | Optional catalog Harness for fallback 2 |
| `aux_vision_provider` / `aux_vision_model` / `aux_vision_effort` | text / text / select | Hermes `auxiliary.vision.*`. Use `auto` + empty model to inherit main |
| `aux_compression_*` | same | Hermes `auxiliary.compression.*` |
| `aux_web_extract_*` | same | Hermes `auxiliary.web_extract.*` |
| `aux_skills_hub_*` | same | Hermes `auxiliary.skills_hub.*` |
| `aux_title_generation_*` | same | Hermes `auxiliary.title_generation.*` |
| `aux_approval_provider` / `aux_approval_model` / `aux_approval_effort` | text / text / select | Hermes `auxiliary.approval.*`. Local parent / Foyer: `llamacpp` / `d1-2b-q4_k_m` |
| `notes` | text | When to use this profile |
| `stt_provider` | select | `local` \| `groq` \| `openai` \| `mistral` \| `xai` \| `elevenlabs` \| `deepinfra` \| `none` (featured). Display name **STT provider** |
| `stt_model` | text | e.g. `base`, `whisper-large-v3-turbo` |
| `tts_provider` | select | `edge` \| `elevenlabs` \| `openai` \| `minimax` \| `mistral` \| `gemini` \| `xai` \| `deepinfra` \| `neutts` \| `kittentts` \| `piper` \| `nous` \| `none` (featured). Display name **TTS provider** |
| `tts_voice` | text | Provider voice id (featured), e.g. `en-US-AriaNeural` |
| `tts_speed` | number | Global TTS speed (default `1`) |
| `voice_notes` | text | When / how to apply voice for agents on this profile |

Also `tag`, `links`, `backlinks`. Put longer rationale and apply notes in the body.

**Hermes decline** (skill `hermes-profiles` → `models.md`):
1. `model_provider` + `model_default` (+ `model_effort`) → `model.*`. When
   provider is `llamacpp`, also enable `local_runtime`.
2. `fallback_1_*` / `fallback_2_*` → ordered `fallback_providers`.
3. Each filled `aux_<task>_*` → `auxiliary.<task>.provider` / `.model` (effort
   when Hermes accepts it on that task).
4. `model_harness` / `fallback_*_harness` are catalog UX only.

**Voice stack:** parent profiles (**Local parent**, **Foyer**) set STT/TTS defaults
agents inherit. Subagent-only profiles leave `stt_provider` / `tts_provider` as
`none`. Apply with `hermes-profiles` → `voice.md`.

**Example profiles:**

| Profile | model.* | fallback_1 | fallback_2 | Aux | Voice | Typical use |
|---------|---------|------------|------------|-----|-------|-------------|
| **Local parent** | `llamacpp` / `LFM3-1.7B-Q8_0` · none · Local model | (none) | (none) | approval=`llamacpp`/`d1-2b-q4_k_m`; others `auto` | STT `local`/`base` · TTS `edge`/`en-US-AriaNeural` | **Most Agents** (parent brain) |
| **Foyer** | same as Local parent | (none) | (none) | same dual local | local+edge (voice-friendly) | Foyer/home agents; no Subagents |
| **CLASQUIN** | `anthropic` · Claude Code Sonnet 5.5 · high | (none) | (none) | `auto` | none | Arnold only; Claude subscription |
| Chiefs | `xai` · Grok 4.5 · high | Sonnet 5.5 · high | Sol 6.1 · medium | `auto` | none | Subagent `chiefs` |
| Coding | `anthropic` · Sonnet 5.5 · high | Sol 6.1 · medium | Grok 4.5 · high | `auto` | none | Subagent `coding` |
| Reviewing | `openai-codex` · Sol 6.1 · medium | Sonnet 5.5 · high | Grok 4.5 · high | `auto` | none | Subagent `review` |
| Browser | `openai-codex` · Terra 6.1 · high | Haiku 5.5 · high | Grok 4.5 · medium | `auto` | none | Subagent `browser` |
| Web/MCP | same as Browser | same | same | `auto` | none | Subagent `web` |
| Deep think | same as Coding | same | same | `auto` | none | Subagent `deep` |

Parent Agents usually link **Local parent**. Subagents link specialist stacks.
**LFM3-1.7B-Q8_0** and **d1** both run on Hermes builtin llamacpp (`local_runtime`); legacy Ollama `lfm3` is retired.

**Default template name:** `Harness profile default`. Body: `type-templates.md`.

Apply: when an agent's harness profile or live bot models / voice change,
update the **Harness profile** object, then re-apply to each linked agent's
runtime (Anytype does not auto-push into Claude/Codex/Grok/Hermes/…).

**Legacy keys (removed):** `primary_*`, `decision_*`, `backup_*`. Migrate any
old docs/recipes to `model_*` / `fallback_*` / `aux_*`.

## Browser (`api_key`: `browser`)

Reusable browser-access catalog. Agents / Teams / Subteams link one via
`browser`. Prefer catalog + links over per-agent instances.

| Key | Format | Notes |
|-----|--------|-------|
| `slug` | text | Stable id (e.g. `engineering-hermes-chromium`) (featured) |
| `lifecycle` | select | `draft` \| `live` \| `archived` (featured) |
| `access_needed` | checkbox | Whether interactive browser is needed (featured). Display name **Access needed** |
| `browser_source` | select | `none` \| `local-chromium` \| `lightpanda` \| `cloud-browserbase` \| `cloud-browser-use` \| `cloud-firecrawl` \| `cloud-nous` \| `cdp-attach` \| `operator-real-profile` (featured). Display name **Browser source** |
| `is_real` | checkbox | When true, Hermes apply sets `browser.use_real_profile: true` (featured). Display **Is real**. Org default: **true** |
| `browser_engine` | select | `chrome` \| `brave` \| `edge` \| `chromium` \| `brave-origin` (featured). Display **Browser engine**. Org default: **chrome**. Intended Chromium-family binary for real-profile / CDP |
| `real_profile_pin` | text | Chrome/Brave **profile directory** name when `is_real` (e.g. `Profile 2`, never a shared human Default across HQs) (featured). Display **Real profile pin**. Required when `is_real`; maps to Hermes `browser.real_profile_pin`. **Always mint a dedicated host profile** for this Browser and store that directory here (see `hq-runtime-pair.md` → Create Chrome profile) |
| `browser_identity` | select | `none` \| `dedicated-throwaway` \| `dedicated-persistent` \| `team-shared-persistent` \| `operator-real-profile`. Prefer align with `is_real` (`operator-real-profile` when true) |
| `headed` | checkbox | Headed Chromium when true |
| `cloud_provider` | text | Optional cloud provider label when source is cloud-* |
| `docs_url` | url | Optional docs |
| `notes` | text | Short apply notes |

Also `tag`, `links`, `backlinks`. Long apply notes stay in the body.

**`is_real` vs identity:** `is_real` is the apply source of truth for
`use_real_profile`. Keep `browser_source` / `browser_identity` as
`operator-real-profile` when `is_real` is true. When `is_real` is false, use
throwaway / persistent / cloud / CDP as before and leave `real_profile_pin`
empty.

**Per-HQ catalog (org convention):** one Browser per HQ, not a shared org-wide
row. Create when the HQ is created; Subteams and Agents under that HQ link the
same object. Board and Primary leave `browser` empty. Full create/link/migrate
playbook: `hq-runtime-pair.md`.

| Name pattern | slug pattern | Typical props |
|--------------|--------------|---------------|
| `{HQ name} – Hermes Chromium` | `{hq-slug}-hermes-chromium` | `is_real: true`, `browser_engine: chrome`, `real_profile_pin: Profile N` (dedicated), `browser_source` + `browser_identity: operator-real-profile`, `access_needed: true`, `headed: false` |

Example: `Engineering HQ – Hermes Chromium` / `engineering-hermes-chromium` with
pin `Profile 2` (Chrome display name **Hermes Engineering**). Pair with the
same HQ's Computer. Org default is **one dedicated operator Chrome profile per
Browser** (`is_real` + `browser_engine: chrome` + unique `real_profile_pin`).
**Never** reuse the human's personal profile or another HQ's pin. Create the
Chrome profile on the host before or with the Anytype row
(`hq-runtime-pair.md`). Space placement for in-Space browsing still follows the
paired Computer's `desktop_enabled`. Do not mint shared None / throwaway
catalog rows unless the user asks for an exception.

**Default template name:** `Browser default`. Body: `type-templates.md`.

Hermes apply: skill `hermes-profiles` → `browser-and-computer.md`.

## Computer (`api_key`: `computer`)

Reusable computer / desktop catalog. Agents / Teams / Subteams link one via
`computer`.

| Key | Format | Notes |
|-----|--------|-------|
| `slug` | text | Stable id (e.g. `engineering-cua-spaces`) (featured) |
| `lifecycle` | select | `draft` \| `live` \| `archived` (featured) |
| `access_needed` | checkbox | Whether desktop / computer_use is needed (featured; shared key with Browser) |
| `computer_surface` | select | `cua-spaces` \| `host` \| `bot-screen` \| `none` (featured; shared with Agent select) |
| `computer_scope` | select | `dedicated` \| `team-shared` \| `none`. Display name **Computer scope** |
| `permission_mode` | select | `standard` \| `bounded`. Display name **Permission mode** |
| `desktop_enabled` | checkbox | Cua Spaces desktop stack on when true. Display name **Desktop enabled** |
| `cua_space` | text | Live Cua Space id (e.g. `local:engineering-hq`) (featured). Display name **Cua space**. Not the Computer `slug` |
| `docs_url` | url | Optional docs |
| `notes` | text | Short apply notes |

Also `tag`, `links`, `backlinks`.

**Per-HQ catalog (org convention):** one Computer per HQ. Create when the HQ is
created; Subteams and Agents under that HQ link the same object. Board and
Primary leave `computer` empty (Primary also sets Agent.`computer_surface` to
`none`). Full create/link/migrate playbook: `hq-runtime-pair.md`. After the
Computer row exists, create the live Cua Space and set `cua_space`:
`cua-hq-spaces.md`.

| Name pattern | slug pattern | Typical props |
|--------------|--------------|---------------|
| `{HQ name} – Cua Spaces` | `{hq-slug}-cua-spaces` | `computer_surface: cua-spaces`, `computer_scope: dedicated`, `permission_mode: standard`, `desktop_enabled: true`, `access_needed: true` |

Example: `Engineering HQ – Cua Spaces` / `engineering-cua-spaces`. Pair with the
same HQ's Browser. Host desktop / Bot Screen / None are exception surfaces only
when the user asks.

**Default template name:** `Computer default`. Body: `type-templates.md`.

Hermes apply: `browser-and-computer.md` + Cua Spaces plugin docs.

## Tool profile (`api_key`: `tool_profile`)

Reusable toolsets + approvals + terminal defaults. Agents / Teams / Subteams
link one via `tool_profile`. Use key `tool_profile` (not bare `tool`) to mirror
`harness_profile` and avoid clashes.

| Key | Format | Notes |
|-----|--------|-------|
| `slug` | text | Stable id (e.g. `standard-interactive`, `coding`) (featured) |
| `lifecycle` | select | `draft` \| `live` \| `archived` (featured) |
| `intent` | text | When to use (featured) |
| `enabled_toolsets` | text | Comma list (e.g. `web,terminal,file,memory,delegation`) |
| `disabled_toolsets` | text | Comma list or empty |
| `tool_approvals` | select | `smart` \| `manual` \| `off`. Display name **Tool approvals** (avoid bare `Approvals`) |
| `cron_approvals` | select | `deny` \| `approve`. Display name **Cron approvals** |
| `hard_deny` | text | Globs / patterns or `none` |
| `terminal_backend` | select | Shared with Agent (`cua` \| `local` \| …); org default `cua` |
| `terminal_cwd` | text | Absolute host cwd when needed; leave empty with cua |
| `timeout_seconds` | number | Terminal timeout (e.g. `180`) |
| `notes` | text | Short apply notes |

Also `tag`, `links`, `backlinks`.

**Canonical catalog (create these once):**

| Name | slug | Typical use |
|------|------|-------------|
| Standard interactive | `standard-interactive` | **Org default** tool access |
| Coding | `coding` | Engineering chiefs / specialists (+ browser, code_execution, computer_use) |
| Data fetching | `data-fetching` | Lookups / scrape / light summary |
| Read-only light | `read-only-light` | Propose / read-only autonomy |

**Default template name:** `Tool profile default`. Body: `type-templates.md`.

Hermes apply: `runtime-limits-and-tools.md`. Pair with linked Browser / Computer
when those toolsets are enabled.

**Fill conventions (org):**
- Computer + Browser → owning HQ's `{HQ} – Cua Spaces` / `{HQ} – Hermes Chromium`
  pair for that HQ, its Subteams, and its Agents
- Board + Primary → leave `browser` / `computer` empty (Primary
  `computer_surface: none`)
- Tool profile → **Standard interactive**; Engineering → **Coding**; fetch /
  veille roles → **Data fetching**

## Runtime (`api_key`: `runtime`)

Catalog of **where** an Agent runs. Distinct from **Harness** (model product) and
from Osaurus's own `agents[].runtime` (Claude Code / Pi inside Osaurus).

| Key | Format | Notes |
|-----|--------|-------|
| `slug` | text | Stable id: `grok-bot` \| `hermes` \| `osaurus` \| `noodle` (featured) |
| `lifecycle` | select | `draft` \| `live` \| `archived` (featured) |
| `runtime_kind` | select | Same vocabulary as slug (featured). Display **Runtime kind** |
| `product` | text | Product label (featured) |
| `cli_command` | text | e.g. `hermes`, `osaurus` |
| `home_path` | text | e.g. `~/.hermes`, `~/.osaurus` |
| `skill_name` | text | Apply skill: `hermes-profiles`, `osaurus-agents`, … |
| `docs_url` | url | Optional docs |
| `notes` | text | Short apply notes |

Also `tag`, `links`, `backlinks`.

**Canonical catalog (create these once):** Grok Bot, Hermes, Osaurus, Noodle
(matching slugs / `runtime_kind` above).

| Name | slug / kind | Skill |
|------|-------------|-------|
| Hermes | `hermes` | `hermes-profiles` |
| Osaurus | `osaurus` | `osaurus-agents` |
| Grok Bot | `grok-bot` | (none yet) |
| Noodle | `noodle` | (none yet) |

Agents link one via featured Agent.`runtime`. Keep under Agents → Shared (or a
Runtime index). Editing Anytype does not push into the live runtime.

**Default template name:** `Runtime default`.

## Vault grant (`api_key`: `vault_grant`)


**Capability catalog only.** Records which Agents (or Team) may use which site
login / browser identity. **Never** store passwords, TOTP seeds, API tokens, or
card numbers here. Secrets live in Hermes vault (`hermes vault`), 1Password /
Bitwarden CLI, or a Chromium profile dir (`user_data_dir` / real-profile).

| Key | Format | Notes |
|-----|--------|-------|
| `site_origins` | text | Origins or host list (e.g. `https://x.com, https://twitter.com`) (featured) |
| `identity_kind` | select | `hermes-vault` \| `onepassword` \| `bitwarden` \| `persistent-profile` \| `real-profile` \| `cdp-attach` (featured) |
| `vault_handle` | text | Optional label matching `hermes vault list` / manager item name (featured) |
| `agents` | objects | Agents allowed to use this grant (featured) |
| `team` | objects | Optional HQ / Team scope (featured) |
| `lifecycle` | select | `draft` \| `live` \| `archived` (featured) |
| `notes` | text | Apply notes (no secrets) |

Also `tag`, `links`, `backlinks`. Keep under Agents → Shared (or a Runtime /
Secrets index of **grants**, not credentials).

**Agent playbook:** before signing into a site in Hermes browser, search
`type: vault_grant` for this Agent + site. If none is live, escalate to chief /
P. Prefer vault masked fill over asking the human to paste a password in chat.
Full Hermes paths: `hermes-profiles` → `browser-and-computer.md` → **Signing in**.
Shared Rule **27**.

**Example:** `X.com – Octave` → `identity_kind: hermes-vault`, `agents: [Octave]`,
`site_origins: https://x.com`, `lifecycle: live`.

## Project (`api_key`: `project`)

Built-in Project type extended with org fields. Short overview and hub links
live in properties; long narrative stays in the body.

| Key | Format | Notes |
|-----|--------|-------|
| `project_status` | select | `Active` \| `Other` \| `Archived` |
| `project_category` | select | `Core Platform` \| `Consumer Apps` \| `Research` \| `AI & Content` \| `B2B` \| `Tools` \| `Other` |
| `owning_team` | objects | Link to Team / HQ |
| `git_hub` | url | Repo URL (API key is `git_hub`) |
| `public_url` | url | Public product URL |
| `one_liner` | text | Positioning line |
| `execution_policy` | select | `Local` \| `Cloud` \| `Mixed` \| `Unset` (featured) |
| `lead_agent` | objects | Owning coordinator when known (featured) |
| `related_projects` | objects | Sibling / dependency projects |
| `overview` | text | Short overview (2–4 sentences) |
| `technical_page` | objects | Child Technical hub |
| `product_page` | objects | Child Product hub |
| `pm_page` | objects | Child Project Management hub |
| `design_page` | objects | Child Design hub |
| `business_page` | objects | Child Business hub |
| `marketing_page` | objects | Child Marketing hub |

**Default template name:** `Project default`. Full dumped body:
`type-templates.md`.

PM children under `pm_page` are **Queries** named Roadmap / Backlog / TODO
(filtered by `linked_projects`), not bare collections. Full playbook:
`project-pm.md`.

## Epic (`api_key`: `epic`)

Large theme on a project's Roadmap Query.

| Key | Format | Notes |
|-----|--------|-------|
| `linked_projects` | objects | Owning project(s) (featured; Query filter) |
| `status` | select | `Backlog` \| `Ready` \| `In progress` \| `Done` \| `Cancelled` (featured) |
| `pm_priority` | select | `P0` \| `P1` \| `P2` \| `P3` (featured; display **PM priority**) |
| `user_stories` | objects | Optional child User stories |

Also `tag`, `links`, `backlinks`. **Default template:** Epic default (Goal /
Scope / Out of scope / Notes).

## User story (`api_key`: `user_story`)

Backlog item on a project's Backlog Query.

| Key | Format | Notes |
|-----|--------|-------|
| `linked_projects` | objects | Owning project(s) (featured) |
| `parent_epic` | objects | Optional parent Epic (featured) |
| `status` | select | Same as Epic (featured) |
| `pm_priority` | select | Same P0–P3 vocabulary (featured; key may be `pm_priority_2` if Priority number already existed) |
| `child_tasks` | objects | Optional child Tasks |

Also `tag`, `links`, `backlinks`. **Default template:** User story default
(Story / Acceptance / Notes). Plural display: User stories.

## Task (`api_key`: `task`, built-in extended)

TODO Query items. Layout stays **todo** (`done` checkbox).

| Key | Format | Notes |
|-----|--------|-------|
| `kind` | select | `bugfix` \| `implementation` \| `doc` \| `design` \| `review` \| `chore` \| `spike` (featured) |
| `linked_projects` | objects | Owning project(s) (featured; Query filter) |
| `parent_epic` | objects | Optional parent Epic (featured) |
| `parent_user_story` | objects | Optional parent User story (featured) |
| `pm_priority` | select | P0–P3 when present (featured) |
| `status` | select | Shared status vocabulary |
| `done` | checkbox | Built-in |
| `assignee` | objects | Built-in (participants) |
| `due_date` | date | Built-in |

Default migrate kind from old TODO pages: **`implementation`**. Keep built-in
Task default template. See `project-pm.md` for Query create + collection migrate.

## Create with type + template

Prefer typed creates. Omit `template` when the type has a default; pass a
template id from `API-list-templates` when you need a specific one; pass
`"none"` for an empty body.

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
      "subagents": ["<fastFetchSubagentId>", "<deepCodeSubagentId>"],
      "autonomy": "change-with-gates",
      "short_description": "Implements one Ready coding TODO…",
      "delegation_enabled": true,
      "analytics_enabled": false,
      "browser": ["<engineeringHqHermesChromiumBrowserId>"],
      "computer": ["<engineeringHqCuaSpacesComputerId>"],
      "tool_profile": ["<codingOrStandardToolProfileId>"],
      "terminal_backend": "cua",
      "computer_surface": "cua-spaces",
      "map_path": "Agents → Engineering HQ → Development → Lee"
    },
    "system_prompt": ["<promptObjectId>"],
    "markdown": "## System prompt\nCanonical system prompt lives on the linked **System prompt** property. Copy from that Prompt into the bot.\n\n## Agenda\nCanonical scheduled work lives on the linked **Agenda** Query.\n"
  }
}
```

Create the Prompt object first (or in the same session) per `prompts.md`. Omit
body sections that only repeat properties (`## Short Description`,
`**Autonomy:**`, `**Home:**` / `**Chief:**` / `**HQ:**` / `**Reports to:**`,
`## Suggested runtime`, map path as prose-only) when those properties are set.
Do not paste a Full System Prompt / SOUL fence on the Agent once `system_prompt`
is set.

Create a Subagent the same way (`"type": "subagent"`) with `parent_agent`,
`task_key`, `harness_profile`, then add its id to the parent's `subagents`.

Team / Subteam / Group / Subagent / Harness / Harness profile / Browser /
Computer / Tool profile / Runtime / project the same way with the matching `"type"` and
property keys above.

## Search by type

```json
{
  "space_id": "<spaceId>",
  "type": "agent",
  "limit": 50,
  "fields": ["name", "role", "lifecycle", "harness_profile", "subagents", "browser", "computer", "tool_profile"]
}
```

Use `"type": "team"`, `"type": "group"`, `"type": "subteam"`, `"type": "subagent"`,
`"type": "harness"`, `"type": "harness_profile"`, `"type": "browser"`,
`"type": "computer"`, `"type": "tool_profile"`, `"type": "runtime"`, or `"type": "project"` the same way.

## Migrate an existing page (`set_type`)

Keep the same object id and links. Apply `set_type` then `set_properties` in one
`API-patch-object` (atomic). `set_properties` values go under `set`, not
`properties`.

```json
{
  "space_id": "<spaceId>",
  "object_id": "<objectId>",
  "create_missing_options": true,
  "ops": [
    { "op": "set_type", "type": "agent" },
    {
      "op": "set_properties",
      "set": {
        "role": "Primary",
        "lifecycle": "live",
        "harness_profile": ["<harnessProfileObjectId>"]
      }
    }
  ]
}
```

Recommended inventory scope: Agents hub agents + Board/HQ (`team`) + Groups
(`group`) + Subteams (`subteam`) + Subagents (`subagent`) + Harnesses + Harness
profiles, and Projects hub portfolio roots. Leave Skills, Shared Rules, memory
children, bugs, and other support pages as `page` (or their typed forms).

### Migrate legacy `team` + `kind: Sub-team` → `subteam`

```json
{
  "space_id": "<spaceId>",
  "object_id": "<objectId>",
  "create_missing_options": true,
  "ops": [
    { "op": "set_type", "type": "subteam" },
    {
      "op": "set_properties",
      "set": {
        "lifecycle": "live",
        "parent_team": ["<hqTeamObjectId>"],
        "mission": "…"
      }
    }
  ]
}
```

Keep `parent_team` / `chief` / `mission` when the keys already exist on the
object; re-set only what is missing after the type change.

### Migrate legacy Group `page` → `group`

Prefer `set_type` → `group` (keeps id, `welcome_prompt`, and Agent
`messaging_group` links), then fill properties:

```json
{
  "space_id": "<spaceId>",
  "object_id": "<objectId>",
  "create_missing_options": true,
  "ops": [
    { "op": "set_type", "type": "group" },
    {
      "op": "set_properties",
      "set": {
        "lifecycle": ["live"],
        "parent_team": ["<hqTeamObjectId>"],
        "members": ["<agentId>", "…"],
        "slug": "engineering",
        "platform": ["telegram"],
        "require_mention": true,
        "exclusive_bot_mentions": true
      }
    }
  ]
}
```

Keep existing `welcome_prompt` when present. Then patch HQ / Agent
`messaging_group` to this Group id.

## Bootstrap types in a new space

1. `API-create-type` for `agent`, `team`, `group`, `subteam`, `subagent`,
   `harness`, `harness_profile`, `browser`, `computer`, `tool_profile`,
   `vault_grant`, `runtime`, `prompt`, `memory`, `skill`, `log`, `suggestion`, and
   `schedule` with the property definitions above (`create_missing_options: true`
   for selects).
   On `team`, define `kind` options `Board` / `HQ` only (no `Sub-team`, no new
   `Group` option). Prefer **sequential** creates when several types share new
   property names (`members`, `skills_page`, `access_needed`,
   `computer_surface`, …) so keys stay clean aliases rather than colliding
   opaque ids. Name new selects carefully (`Browser source`, `Tool approvals`)
   when a shorter name already exists with a different format.
2. On existing Agent / Team / Subteam / Subagent types: `add_property` for
   org/runtime fields above including featured `browser`, `computer`,
   `tool_profile`, `runtime`, shared `system_prompt` (Agent required; Team/Subteam/Subagent
   optional), and Agent voice fields (`voice_enabled`, `voice_auto_tts`,
   `voice_chat_mode`, `messaging_voice_mode`, shared `stt_*` / `tts_*`); also
   `board_member`, `memory_pages`, `skills_page`,
   `logs_page`, `agenda_page`, `suggestions_page`, `messaging_group`, `map_path`,
   `delegation_enabled`, `analytics_enabled`, `terminal_backend`, `computer_surface`; keep
   `harness_profile` / `subagents`; `remove_property` legacy `harness` select,
   unused `primary_model`, and unused Agent `linked_projects` when ready
   (Project.`lead_agent` / `owning_team` + map_path cover agent↔project;
   keep `linked_projects` on epic / user_story / task). On Group: `welcome_prompt` is a Group
   property (not Page). On Harness profile: add STT/TTS stack fields above.
   Prompt / Memory / Skill / Log / Suggestion / Schedule / Group bootstrap detail:
   `prompts.md` + `memory-and-skills.md` + `suggestions.md` +
   `agenda-and-schedules.md` + Group section below.
3. On Team: `add_property` `members`, `subteams`, `messaging_group`,
   `skills_page`, `subteams_page`, `routing_summary`, `standing_instructions`
   (+ runtime catalog links). Create `{HQ} – Subteams` Query
   (`type: subteam`, `filter: parent_team IN ("<hqId>")`) and link
   `subteams_page`. On Project:
   `execution_policy`, `lead_agent`, `related_projects`, `overview`, and child
   hub page links.
4. `API-create-template` with `template_for`: `agent` | `team` | `group` |
   `subteam` | `subagent` | `harness` | `harness_profile` | `browser` |
   `computer` | `tool_profile` | `prompt` | `memory` | `skill` | `log` |
   `suggestion` | `schedule` | `project` | `epic` | `user_story` and body
   markdown from **`type-templates.md`** / `suggestions.md`. Extend built-in
   `task` with Kind (+ `spike`) and project links (`project-pm.md`); keep
   Task's built-in default template.
5. `API-update-type` body `{ "default_template": "<templateId>" }` per type.
6. Create the seven Harness catalog objects; create Harness profiles (**Local
   router**, Coding, Data fetching, …); create Tool profile catalogs (table
   above); for each HQ create one Computer + one Browser (per-HQ tables above)
   and link that pair on the HQ / its Subteams / its Agents; create Subagent
   spawn configs; link most agents to Local router + runtime catalogs +
   `subagents` (and Subagent.`parent_agent`); create typed Groups + welcome
   Prompts and link `messaging_group`.
7. Migrate existing inventory with `set_type` as above (including legacy
   Sub-team `team` objects → `subteam`, and Group `page` → `group`). Fill
   properties from the org map; leave unknown urls / people empty. For PM:
   migrate Roadmap/Backlog/TODO collections per `project-pm.md`.

Do not hardcode space or template ids in skill text; resolve them via list/get
each session.

## Prompt (`api_key`: `prompt`)

Canonical copy-into-bot / welcome / shared-rules text. Full property table,
create/migrate recipes, and Agent/Group pointer shapes: **`prompts.md`**.

| Key | Format | Notes |
|-----|--------|-------|
| `prompt_kind` | select | `system` \| `welcome` \| `shared_rules` \| `library` \| `draft` \| `other` (featured) |
| `lifecycle` | select | `draft` \| `live` \| `archived` (featured) |
| `owner_agent` | objects | Owning Agent when kind is system (featured) |
| `owner_group` | objects | Owning typed **Group** when kind is welcome (featured) |
| `audience` | select | `agent` \| `group` \| `org` \| `library` (featured) |
| `notes` | text | Apply / sync notes |

**Default template:** Prompt default (`type-templates.md`). Agents link via
`system_prompt`. Groups link via `welcome_prompt` (Group property). Shared
Rules and Mission-style libraries are themselves type `prompt` (`set_type` in
place).

## Group (`api_key`: `group`)

Messaging roster for a shared Telegram / Discord / … room. Distinct from Team
(`kind` Board/HQ) and Subteam. Hermes has no first-class Group object; decline
platform settings via `hermes-profiles` → `messaging-groups.md`.

| Key | Format | Notes |
|-----|--------|-------|
| `lifecycle` | select | `draft` \| `live` \| `archived` (featured) |
| `parent_team` | objects | Owning HQ / Board Team (featured) |
| `members` | objects | Agent members of the chat (featured) |
| `welcome_prompt` | objects | One Prompt (`prompt_kind=welcome`) (featured) |
| `platform` | select | `telegram` \| `discord` \| `slack` \| `whatsapp` \| `other` \| `none` (featured) |
| `platform_chat_id` | text | Platform room/channel id when known (featured); leave empty until real |
| `slug` | text | Stable lowercase id (e.g. `engineering`) (featured) |
| `mission` | text | Short purpose of the room |
| `routing_summary` | text | One-line who answers what |
| `hermes_profiles` | text | Comma list of member Hermes slugs (checklist) |
| `require_mention` | checkbox | Intended `telegram.require_mention` (and peers) |
| `exclusive_bot_mentions` | checkbox | Intended `telegram.exclusive_bot_mentions` |
| `notes` | text | Apply / sync notes |

Also `tag`, `links`, `backlinks`. Canonical roster is `members`; keep each
Agent.`messaging_group` pointing here. Body keeps Members + Welcome pointer
only (`page-templates.md` / **Group default**).

**Default template name:** `Group default`. Body: `type-templates.md`.

**Hermes decline:** one bot token + gateway per member profile; allowlist
`platform_chat_id`; apply mention gates from the checkboxes; paste welcome from
`welcome_prompt`. Do not apply until the user asks.

## Memory (`api_key`: `memory`)

| Key | Format | Notes |
|-----|--------|-------|
| `memory_kind` | select | `memory_decisions` \| `lessons` \| `resources` \| `operating_notes` \| `playbook` \| `other` (featured) |
| `lifecycle` | select | Shared `draft` \| `live` \| `archived` (featured) |
| `owner_agent` | objects | Owning Agent (featured) |
| `owner_team` | objects | Optional |
| `owner_subteam` | objects | Optional |
| `cadence` | text | Optional |
| `last_reviewed` | date | Optional |
| `notes` | text | |

**Default template:** Memory default. Full playbook: `memory-and-skills.md`.

## Skill (`api_key`: `skill`)

| Key | Format | Notes |
|-----|--------|-------|
| `skill_kind` | select | `procedure` \| `template` \| `guide` (featured) |
| `skill_key` | text | lowercase-hyphen id (featured) |
| `skill_scope` | select | `global` \| `team` \| `subteam` \| `agent` \| `project` (featured) |
| `skill_status` | select | `draft` \| `active` \| `deprecated` \| `archived` (featured) |
| `version` | text | |
| `intent` | text | Router blurb (featured) |
| `owner_agent` / `owner_team` / `owner_subteam` / `owner_project` | objects | Match scope |
| `parent_skill` / `related_skills` | objects | Optional |
| `box_path` | text | Optional |
| `reviewed_by` | objects | Optional |
| `notes` | text | |

**Default template:** Skill default. Indexes are **Queries**, not `skill_kind=index`.
Full playbook: `memory-and-skills.md`.

## Log (`api_key`: `log`)

Small per-action summary of what an agent did. Distinct from durable Memory and
from skill usage counters (still forbidden).

| Key | Format | Notes |
|-----|--------|-------|
| `owner_agent` | objects | Owning Agent (featured; required) |
| `logged_at` | date | When the action happened (featured) |
| `summary` | text | One or two sentences (featured) |
| `notes` | text | Optional |

**Default template:** Log default. Agent indexes via `logs_page` → Query
filtered by `owner_agent`, sorted by `logged_at` desc, plus a **Calendar**
view on `logged_at` (date index). Full playbook: `memory-and-skills.md`.

## Suggestion (`api_key`: `suggestion`)

Improvement feedback when a model, Subagent, Skill, harness, tool, Memory, or
Prompt should change. Distinct from Logs (what happened) and Memory (durable
facts).

| Key | Format | Notes |
|-----|--------|-------|
| `suggestion_kind` | select | `model_fit` \| `new_subagent` \| `new_skill` \| `harness` \| `tool` \| `memory` \| `prompt` \| `other` (featured) |
| `suggestion_status` | select | `draft` \| `proposed` \| `accepted` \| `done` \| `declined` (featured) |
| `owner_agent` | objects | Agent the change is about (featured) |
| `proposed_by` | objects | Filer (agent or Agathe) (featured) |
| `proposed_at` | date | When filed (featured) |
| `summary` | text | One or two sentences (featured) |
| `related_objects` | objects | Optional linked harness_profile / skill / subagent / prompt |
| `reviewed_by` | objects | Optional |
| `notes` | text | |

**Default template:** Suggestion default. Agent indexes via `suggestions_page`
→ Query filtered by `owner_agent`. Org triage: **Suggestions – Inbox**. Full
playbook: `suggestions.md`. Shared Rules rule **25**.

## Schedule (`api_key`: `schedule`)

One intended job (Hermes cron / Bot Routine / event wake) owned by an Agent.
The agent's **Agenda** is a Query over these objects (no Agenda type).

| Key | Format | Notes |
|-----|--------|-------|
| `owner_agent` | objects | Owning Agent (featured; required; Agenda filter) |
| `schedule_key` | text | Stable lowercase-hyphen id (featured); prefer Hermes `--name` |
| `schedule_kind` | select | `recurring` \| `oneshot` \| `event` (featured) |
| `schedule_expr` | text | Cron or natural schedule (featured); empty for pure events |
| `timezone` | text | e.g. `Europe/Paris` (featured) |
| `next_run` | date | Next fire / Calendar anchor (featured); Date Objects |
| `intent` | text | Short what/when (featured) |
| `deliver` | text | Hermes deliver target |
| `skills` | text | Comma skill keys |
| `workdir` | text | Absolute cwd when needed |
| `model_pin` | text | Per-job pin note |
| `no_agent` | checkbox | Script-only |
| `script_path` | text | When `no_agent` |
| `paused` | checkbox | |
| `paused_reason` | text | |
| `hermes_job_id` | text | Filled after Hermes apply |
| `hermes_job_name` | text | Usually mirrors `schedule_key` |
| `lifecycle` | select | Shared `draft` \| `live` \| `archived` (featured) |
| `notes` | text | |

**Default template:** Schedule default. Agent indexes via `agenda_page` → Query
filtered by `owner_agent`, sorted by `next_run` asc (optional Calendar view on
`next_run`). Full playbook: `agenda-and-schedules.md`. Hermes decline:
`hermes-profiles` → `cron.md`.

## What stays `page`

- Agents / Projects hub roots (optional)
- Drafts hub scaffolding, misc notes, restore/backup dumps

Messaging rooms are type **`group`** (migrate legacy Group pages with
`set_type`). Shared Rules and prompt libraries are type **`prompt`**. Memory
children are type **`memory`**. Procedures / Skill Template / guides are type
**`skill`**. Per-action summaries are type **`log`**. Improvement feedback is
type **`suggestion`**. Scheduled jobs are type **`schedule`**. Login
**capabilities** (not secrets) are type **`vault_grant`**. Skills, Logs,
Suggestions, and Agenda indexes are type **`query`**.
