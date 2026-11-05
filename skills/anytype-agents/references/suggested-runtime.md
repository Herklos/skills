# Suggested runtime (Hermes apply checklist)

**Not an Agent page body section.** Live agents keep System prompt + Agenda
pointers only. Fill runtime facts as Agent / Harness profile / catalog
**properties**, then use this checklist when applying into Hermes (or another
harness). Values guide whoever configures the bot; they do **not** auto-apply.

**Ordered apply playbook (faster):** skill `hermes-profiles` →
`references/anytype-apply.md` (slug resolve including Primary→`default`, SOUL
copy, Local parent, model label map, `model_map` from Subagents, tools,
Agenda→cron, write discipline, verify + gaps report). Use this file as the
property worksheet; use `anytype-apply.md` as the execution order.

**Properties are the source of truth:** Agent.`harness_profile`,
`hermes_profile`, `delegation_enabled`, `analytics_enabled`, `browser`,
`computer`, `tool_profile`, `terminal_backend`, `computer_surface`, `subagents`,
`short_description`, `autonomy`, `team`, `reports_to`, `map_path`, voice fields
(`voice_enabled`, `voice_auto_tts`, `voice_chat_mode`, `messaging_voice_mode`,
optional `stt_*` / `tts_*`), plus Harness profile `model_*` / `fallback_*` /
`aux_*` / voice stack. Do not paste this checklist onto the Agent page.

For Hermes, map fields with skill `hermes-profiles`:

| Area | Reference |
|------|-----------|
| Primary / decision / aux / fallback / MoA | `models.md` (Local decision model for Local router) |
| Subagents / task-specific routes | `delegation.md` |
| Personality / SOUL | `soul-templates.md` |
| Memory | `memory.md` |
| Browser / computer | `browser-and-computer.md` |
| Tools / terminal / limits | `runtime-limits-and-tools.md` |
| Security / privacy / restoration | `security.md` |
| Workspace | `workspace.md` |
| Display / skins | `display.md` |
| Voice / STT / TTS | `voice.md` |
| Scheduled tasks (Agenda / Schedule) | `cron.md` (+ anytype-agents `agenda-and-schedules.md`) |

Use as a private apply worksheet (date when you revise it). Do not commit this
block to the Agent object body.

```markdown
## Suggested runtime apply notes (YYYY-MM-DD)
**Harness profile:** {Local parent (default for most agents) | Foyer | CLASQUIN | Chiefs | Coding | Reviewing | Browser | Web/MCP | Deep think}  (link Agent.`harness_profile`)
**model.* (from profile):** {model_provider} · {model_default} · {model_effort} · harness {catalog}  (Local parent → ollama-launch · lfm3 · none; aux approval → llamacpp · d1-2b-q4_k_m)
**fallback_providers (from profile, ordered):**
- 1: {fallback_1_provider} · {fallback_1_model} · {effort}
- 2: {fallback_2_provider} · {fallback_2_model} · {effort}
**Catalog harnesses:** claude | codex | grok | github-copilot | muse | nvidia-nim | local-model
**Optional agent overrides:** none | note local exceptions (prefer changing the shared profile)
**auxiliary (from profile `aux_*`; else auto = main):**
- vision: {provider} · {model} · {effort}
- compression: …
- web_extract: …
- skills_hub: …
- title_generation: …
- other Hermes aux (approval, review, …): document only if needed
**Subagents / delegation:**
- Enabled: yes (`delegation` toolset) | no
- **Pattern:** parent Local router answers peers / light asks itself; spawn a Subagent only when a specialized route fits
- **Anytype Subagents:** none | list linked Agent.`subagents` (type `subagent`; each has task_key + harness_profile + scope/tools)
- **Chat / routing model:** same as profile `model.*` (Local parent → ollama-launch · lfm3) | {provider}·{model} · {reasoning}
- **Approvals:** profile `aux_approval_*` (Local parent / Foyer → llamacpp · d1-2b-q4_k_m)
- **Mode:** `model_map` (preferred) | `default` (one worker for all) | `profile_routes`
- Plugin: **advanced-delegation** on this profile (Hermes >= 0.22.5) when using model_map / profile_routes
- **Task-specific models** (prefer decline from Subagent objects; else hand-list):
  - `{task_key}` ← Subagent "{name}" · profile {Coding|Data fetching|…} · effort {…} — {intent}
  - default for unrouted / no-spawn work: **parent main** (Local router); optional `model_map.default` only if you want a cheap child fallback
- Alternatives: single worker {provider}·{model} (`backend: default`) | `profile_routes` ({profile}: {description})
- Concurrency: max_concurrent_children {n} · max_iterations {n}
- Setup: `hermes plugins install advanced-delegation` → decline Subagents via hermes-profiles `delegation.md` → `/delegation model_map`
**Scheduled tasks (Agenda):**
- Canonical list: Agent.`agenda_page` → `{OwnerShort} – Agenda` Query of type `schedule` (anytype-agents `agenda-and-schedules.md`)
- none yet | or summarize live/draft rows: `{schedule_key}` · `{schedule_kind}` · `{schedule_expr}` `{timezone}` · {intent} · deliver {target} · skills {…}
- Apply recurring/oneshot into Hermes only when asked (`hermes-profiles` `cron.md`); event kind stays Anytype-only until a timer exists
**Mixture of Agents (optional):** off | preset `{name}` (references: …; aggregator: …; fanout: user_turn|per_iteration|every_n:N)
**Personality:**
- SOUL / durable identity: {summary or "see Full System Prompt / SOUL.md"}
- Overlay (`display.personality` / `/personality`): none | helpful | concise | technical | creative | teacher | … | custom `{name}`
- Custom presets (`agent.personalities`): none | list names + one-line intent
**Memory (Hermes profile):**
- Built-in: MEMORY.md on|off · USER.md on|off · limits {2200}/{1375} or custom
- Write approval: off | on (`/memory pending`)
- Notifications: off | on | verbose
- External provider: none | retaindb | byterover | honcho | hindsight | … (one)
- Notes: {shared across profiles via provider? / reset policy}
**Voice (STT / TTS):** (prefer Agent voice fields + Harness profile STT/TTS stack)
- Enabled: no | yes (Agent.`voice_enabled`)
- Auto TTS: no | yes (Agent.`voice_auto_tts` → `voice.auto_tts`)
- Chat mode: off | chained | gpt-live (Agent.`voice_chat_mode`)
- Messaging mode: off | voice_only | all (Agent.`messaging_voice_mode` → `/voice`)
- STT: {local|groq|openai|…} · model {base|…}  (Agent override or Harness profile)
- TTS: {edge|elevenlabs|openai|…} · voice {en-US-AriaNeural|…} · speed {1}
- Org default stack: local / base + edge / en-US-AriaNeural
- Apply: hermes-profiles `voice.md`
**Analytics (Langfuse):** (Agent.`analytics_enabled`)
- Enabled: no | yes — when yes, Hermes apply installs/enables **langfuse**
- Keys: `HERMES_LANGFUSE_PUBLIC_KEY` + `HERMES_LANGFUSE_SECRET_KEY` (+ optional `BASE_URL`) on the profile `.env`; copy from default when missing
- If keys absent: tell the user to run `hermes -p <slug> plugins install langfuse` (CLI prompts) or paste into that profile `.env`; do not invent placeholders
- Opt-in only (false does not auto-disable). Apply: hermes-profiles `anytype-apply.md`
**Browser access:** (prefer Agent.`browser` → type `browser` catalog)
- Catalog: {{HQ name} – Hermes Chromium | empty on Board/Primary | exception surface …}
- Needed: no | yes (interactive pages; else prefer web_search / web_extract)
- Is real: yes (org default → `use_real_profile`) | no
- Engine: chrome (org default) | brave | edge | chromium | brave-origin
- Real profile pin: Profile N (dedicated Chrome directory minted for this Browser; never share across HQs) | …
- Source: operator real profile (org default) | local Chromium | lightpanda | cloud ({browserbase|browser-use|firecrawl|nous|…}) | CDP attach
- Identity: operator real profile (align with is_real) | dedicated throwaway | dedicated persistent | team/shared persistent
- Headed: no | yes · Notes: {vault logins? cron needs cookies?}
**Computer access:** (prefer Agent.`computer` → type `computer` catalog)
- Catalog: {{HQ name} – Cua Spaces | empty on Board/Primary | host / Bot Screen exception …}
- Needed: no | yes (native desktop / OS UI; not for ordinary web)
- Surface: **Cua Spaces (HQ default)** | host desktop | Linux Bot Screen | none (Primary)
- Docs: https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces
- Scope: dedicated (this HQ Space) | team/shared host (same OS user; not isolated)
- Permission mode: standard | bounded (manifest) · Notes: {desktop stack on Linux Space? TCC / takeover for 2FA?}
**Tools access:** (prefer Agent.`tool_profile` → type `tool_profile` catalog)
- Catalog: {**Standard interactive (default)** | Coding | Data fetching | Read-only light | …}
- Enabled toolsets: {web, terminal, file, browser, memory, delegation, cronjob, …}
- Disabled / denied: {list or none}
- Approvals: smart | manual | off · cron/unattended: deny | approve
- Hard deny patterns: {none | globs}
**Terminal / execution:** (from Tool profile + Agent.`terminal_backend` / Computer)
- Backend: **cua (preferred)** | local | docker | ssh | modal | daytona | vercel_sandbox | singularity
- cwd: {absolute path for host/local; leave unset with cua (Space home)}
- Timeout (s): {180} · Container CPU/RAM/disk/network: {…} if sandboxed
- Env passthrough / forwarded secrets: {names only, never values}
- Cua Spaces setup: `hermes plugins install https://github.com/trycua/hermes-cua-spaces` → `terminal.backend: cua` → optional `plugins.entries.cua-spaces.settings.desktop: true`
**Limits:**
- max_turns: unlimited | {n} · run_budget_seconds: off | {n} · gateway_timeout: {1800}
- tool_output max_bytes/lines: {50000}/{2000} · file_read_max_chars: {100000}
- compression: on|off · threshold {0.50} · loop hard-stop: interactive warn | unattended hard
**Security / privacy / restoration:**
- Approvals: smart | manual | off · cron/unattended: deny | approve · hard deny: {none|globs}
- Redact secrets: on|off · redact PII: on|off · allow_private_urls: on|off
- Protected instruction files: on|off · write safe root: unset | {policy label only}
- Messaging auth: allowlist | pairing | open (never put IDs/tokens here)
- Checkpoints /rollback: off | on · backup cadence: none | quick | full pre-update
- Notes: {YOLO allowed? disposable sandbox?}
**Workspace / display:**
- Gateway/cron cwd: {absolute path or .} · Named project: none | `{name}` (+ folders)
- Repo scan: on|off · roots: default home | {paths} · exclude: {paths}
- Skin: default | slate | mono | … · tool_progress: off|new|all|verbose
- Reasoning shown: on|off · streaming: on|off · resume_display: full|minimal
- UI language: en | … · Notes: {quiet Slack? Desktop fonts?}
**Gateway / messaging:** none | telegram | discord | … (token lives in runtime secrets, not on this page)
```

Filled-in sample: `examples.md` (Lee – Implementer).
