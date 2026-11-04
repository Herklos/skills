# Suggested runtime (agent page section)

Document the intended runtime stack on each agent. Values guide whoever
configures the bot; they do **not** auto-apply. For Hermes, map fields with
skill `hermes-profiles`:

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
| Scheduled tasks | `cron.md` |

Paste under the agent title (date the heading when you revise it).

```markdown
## Suggested runtime (YYYY-MM-DD)
**Harness profile:** {Local router (default for most agents) | Coding | Data fetching | …}  (link Agent.`harness_profile`)
**Primary (from profile):** {Harness} · {model} · {low|medium|high}  (Local router → Local model · d1-2B-GGUF Q4_K_M · medium)
**Decision (Hermes main, from profile when set):** {decision_provider} · {decision_model}  (Local router → llamacpp · d1-2b-q4_k_m)
**Fallback / backup (from profile, ordered):**
- 1: {Harness} · {model} · {effort}
- 2: {Harness} · {model} · {effort}
**Catalog harnesses:** claude | codex | grok | github-copilot | muse | nvidia-nim | local-model
**Optional agent overrides:** none | note local exceptions (prefer changing the shared profile)
**Auxiliary (optional overrides; else auto = main):**
- vision: …
- compression: …
- approval: …
- title_generation: …
- review (`/review`): …
- other tasks: …
**Subagents / delegation:**
- Enabled: yes (`delegation` toolset) | no
- **Pattern:** parent Local router answers peers / light asks itself; spawn a Subagent only when a specialized route fits
- **Anytype Subagents:** none | list linked Agent.`subagents` (type `subagent`; each has task_key + harness_profile + scope/tools)
- **Decision / routing model:** same as Decision fields (Local router → llamacpp · d1-2b-q4_k_m) | {provider}·{model} · {reasoning}
- **Mode:** `model_map` (preferred) | `default` (one worker for all) | `profile_routes`
- Plugin: **advanced-delegation** on this profile (Hermes >= 0.22.5) when using model_map / profile_routes
- **Task-specific models** (prefer decline from Subagent objects; else hand-list):
  - `{task_key}` ← Subagent "{name}" · profile {Coding|Data fetching|…} · effort {…} — {intent}
  - default for unrouted / no-spawn work: **parent main** (Local router); optional `model_map.default` only if you want a cheap child fallback
- Alternatives: single worker {provider}·{model} (`backend: default`) | `profile_routes` ({profile}: {description})
- Concurrency: max_concurrent_children {n} · max_iterations {n}
- Setup: `hermes plugins install advanced-delegation` → decline Subagents via hermes-profiles `delegation.md` → `/delegation model_map`
**Scheduled tasks:**
- none yet
- or: `{name}` · `{schedule}` · {prompt intent} · deliver {target} · skills {…} · workdir {path?} · model pin {per-job|cron.model|main} · no_agent/script {if any}
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
**Browser access:**
- Needed: no | yes (interactive pages; else prefer web_search / web_extract)
- Source: local Chromium | lightpanda | cloud ({browserbase|browser-use|firecrawl|nous|…}) | CDP attach | operator real profile
- Identity: dedicated throwaway | dedicated persistent | team/shared persistent | operator real profile
- Headed: no | yes · Notes: {vault logins? cron needs cookies?}
**Computer access:**
- Needed: no | yes (native desktop / OS UI; not for ordinary web)
- Surface: **Cua Spaces (default)** | host desktop | Linux Bot Screen | sandbox desktop | host beside sandbox
- Docs: https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces
- Scope: dedicated (this profile / Space) | team/shared host (same OS user; not isolated)
- Permission mode: standard | bounded (manifest) · Notes: {desktop stack on Linux Space? TCC / takeover for 2FA?}
**Tools access:**
- Enabled toolsets: {web, terminal, file, browser, memory, delegation, cronjob, …}
- Disabled / denied: {list or none}
- Approvals: smart | manual | off · cron/unattended: deny | approve
- Hard deny patterns: {none | globs}
**Terminal / execution:**
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
