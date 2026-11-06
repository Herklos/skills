# Anytype → Hermes apply (fleet playbook)

Use when the user explicitly asks to apply an Anytype Agent into a live Hermes
profile (or after an **accepted** suggestion). Companion checklist:
`anytype-agents` → `suggested-runtime.md`. Editing Anytype never pushes config.

First successful apply (P → Hermes `default`, 2026-11-04) is the template below.

## Resolve profile slug

| Anytype | Hermes |
|---------|--------|
| Agent.`hermes_profile` filled **and** dir exists | `hermes -p <slug>` |
| Primary / empty + Bot Mode title **P** | id **`default`** (`$HERMES_HOME`, not `profiles/p`) |
| Missing slug but `~/.hermes/profiles/<name>` exists | set Agent.`hermes_profile` then apply |
| Slug filled but **no** `~/.hermes/profiles/<slug>/` | **create-if-missing** (section below), then apply |
| No slug and no dir | invent slug from Agent name (lowercase ASCII), create, write back `hermes_profile` |

After apply, write back `hermes_profile` on the Agent if it was empty.

## Create missing profiles (inventory → create)

When the user asks to create missing Hermes agents/profiles (or after an org
structure fix that minted Anytype Agents without homes):

1. **Inventory**
   - Anytype: `type: agent`, fields `name`, `lifecycle`, `hermes_profile`,
     `runtime`, `short_description`, `harness_profile`, `system_prompt`.
   - Hermes: `hermes profile list` + `ls ~/.hermes/profiles`.
   - **Create** only when: `lifecycle=live`, Agent.`runtime` is the **Hermes**
     catalog object, and `~/.hermes/profiles/<slug>/` is missing (slug from
     `hermes_profile`, else derive from the Agent short name).
   - **Skip** `lifecycle=archived` / `draft` unless the user names them.
   - **Skip** Agent.`runtime` = **Osaurus** (or Grok Bot / Noodle). Foyer
     agents may still carry a `hermes_profile` string as documentation; do
     **not** create a Hermes home for them (use `osaurus-agents` instead).
2. **Create**
   ```bash
   hermes profile create <slug> --clone-from <peer> \
     --description "<Agent.short_description>"
   ```
   - Prefer a same-HQ Local-parent peer (Growth → `ambre` / `kleber`; Eng →
     `marcel` / `etienne`; …). Never `--clone-channels` unless asked.
   - Clone copies the peer’s **SOUL.md**; replace it in the next step.
3. **Minimum post-create (always)**
   - Local parent: `model.provider=llamacpp`, `model.default=LFM3-1.7B-Q8_0`,
     `model.base_url=http://127.0.0.1:18434/v1`, `local_runtime.enabled=true`,
     `auxiliary.approval` = `llamacpp` / `d1-2b-q4_k_m`, org `timezone`
     (e.g. `Europe/Paris`). Drop leftover `providers.ollama-launch` /
     `model.api_key` if present.
   - `SOUL.md` ← linked system Prompt (`format=md`), strip
     `# {Name} – System prompt` / `## Prompt` / `## Notes` wrappers.
   - `hermes profile describe <slug> --text "<short_description>"`.
   - Voice modes even when off: `voice.auto_tts`, `voice.voice_chat_mode`;
     stack keys are nested (`stt.local.model`, `tts.edge.voice`), not
     `stt.model` / `tts.voice`.
   - `memories/MEMORY.md` = Anytype Memory titles only (pointers).
   - `hermes -p <slug> sessions refresh-prompts`.
4. **Full apply** (Subagents → `model_map`, tools, cron, org skills, messaging)
   only when the user asks; follow the fast path below. Create-if-missing alone
   does not install messaging tokens or start a dedicated gateway beyond the
   multiplexed roster.
5. Write back Agent.`hermes_profile` when it was empty. Report remaining gaps
   (empty Agenda, no Subagent decline, Group without `platform_chat_id`, …).

Example (2026-11-05): Growth structure fix left Firmin/`firmin` and
Bérénice/`berenice` with filled `hermes_profile` but no dirs; created via
`--clone-from ambre`, then Local parent + SOUL + describe. Foyer Sidonie /
Philippe / Blanche / Bob stayed Osaurus-only.

## Delete orphan profiles (inventory → delete)

Inverse of **Create missing profiles**. Use when Hermes dirs remain after an
Anytype Agent was archived, marked temporary, absorbed into another role, or
never minted as a live Agent (common after roster cleanup).

1. **Inventory**
   - Hermes: `hermes profile list` + `ls ~/.hermes/profiles` (every named dir
     with an identity file counts).
   - Anytype: `type: agent`, fields `name`, `lifecycle`, `hermes_profile`,
     `runtime`, `role`.
   - **Orphan candidate** when there is no `lifecycle=live` Agent whose
     `hermes_profile` equals that slug (and Primary/`default` is never an
     orphan). Also candidate when the only matching Agent is
     `archived` / `draft` / library Prompt only, and the user agrees the
     Hermes home is obsolete.
   - **Keep** when a live Hermes-runtime Agent still points at the slug, or
     the user plans to revive the role.
2. **Pre-delete checks**
   - Not seated on a live Bot Mode room:
     `sqlite3 ~/.hermes/state.db "SELECT room_id, name, members_json FROM hosted_rooms WHERE disbanded_at IS NULL;"`
     (search `members_json` for the slug). Remove from the room first if found.
   - Cron: `hermes -p <slug> cron list` — note any jobs; delete drops them.
   - Stale `gateway.lock` / list status `running` without a live process is
     harmless; `profile delete` stops a real gateway if one is up.
3. **Delete** (confirm slug with the user first):
   ```bash
   hermes profile delete <slug> --yes
   ```
   Cannot delete `default`. Leaves aliases under `~/.local/bin/<slug>` cleaned
   by the CLI.
4. **Anytype** — leave archived Prompts, Logs, Skills, and Agent pages unless
   the user asks to Bin them. Optionally clear a stale Agent.`hermes_profile`
   on an archived Agent if it still names the deleted slug.
5. Report what was deleted and any rooms/crons that blocked a candidate.

Example (2026-11-06): `camille` (Weekly Metrics temporary) and `colette`
(Design, absorbed; Prompt archived) had stub SOULs, no live Agents, no room
seats, no cron → deleted after confirm.

## Fast path (ordered)

1. **Read Anytype once** (batch gets): Agent props, linked `system_prompt` (`format=md`),
   `harness_profile`, each `subagents[]` + their harness profiles, Tool profile,
   Agenda Query / `type:schedule` filter `owner_agent`, optional Group.
2. **Backup** `SOUL.md` + `config.yaml` under `/tmp/hermes-<slug>-apply/`.
3. **SOUL** ← system Prompt body (strip template `# {Name} – System prompt` /
   `## Prompt` / `## Notes` wrappers). Keep Shared Rules + Agenda + HQ standing
   as **short pointers** already in the Prompt; do not paste HQ libraries.
4. **Memory pointers** ← create/update `memories/MEMORY.md` with Anytype
   `memory_pages` titles (do not dump full Memory bodies). `USER.md` = human facts.
5. **Local parent / harness** via `hermes -p <slug> config set` only:
   - `model.provider` / `model.default` / `model` effort if needed
   - `local_runtime.enabled` + `backend` when approval is llamacpp
   - `auxiliary.approval.provider` / `.model`
   - Leave cloud `fallback_providers` empty on Local parent / Foyer
   - **Clear leftover MoA** on Local parent / Foyer: a stub `moa.active_preset: ''`
     alone still makes `hermes moa list` / Desktop synthesize stock cloud advisors
     (gpt-5.5 / deepseek / opus). Write an explicit preset with `enabled: false`,
     local `reference_models` + `aggregator` (`llamacpp`/`LFM3-1.7B-Q8_0`), and
     `active_preset: ''`. Empty `reference_models` is filled with stock defaults
     by normalize, so always put at least one local ref. Prefer Hermes
     `load_config`/`save_config` (via `hermes_bootstrap`) over a whole-file dump.
6. **Tools** from Tool profile + Browser/Computer links:
   - `hermes -p <slug> tools enable …` for listed toolsets + `cronjob` when Agenda exists
   - Primary / `computer_surface: none` / empty browser+computer → `tools disable browser computer_use`
   - `approvals.cron_mode` from Tool profile `cron_approvals` (usually `deny`)
   - `terminal.backend` from Tool profile / Agent (org default `cua`)
7. **Delegation** when `delegation_enabled` and Subagents exist:
   - Ensure plugin: `hermes -p <slug> plugins install advanced-delegation --enable`
   - Build `delegation.backend: model_map` with one option per live Subagent
     (`task_key` → `name`, `intent` → `description`, harness `model_*` → provider/model,
     `spawn_effort` → `reasoning_effort`)
   - Decline Subagent / route harness `fallback_1_*` + `fallback_2_*` into that
     option's `fallback_providers` (ordered). Parent Local parent still keeps
     top-level `fallback_providers: []`.
   - **Always set `model_map.default`** to one live Subagent `task_key` when the
     parent is Local (lfm3). Unrouted `delegate_task` calls otherwise inherit
     parent lfm3 (incident: Octave `deleg_e2211d4e`). Prefer the most common
     child route (`web` for veille/research; `deep` or `fast` for coding packs).
   - SOUL / Shared Rules must require: every `delegate_task` sets **`option`** to
     a live route matching Subagent `task_key`; full `goal` + `context`.
   - After writing `model_map`: tell the user (or run if interactive) to rebuild
     the tool schema with `/delegation model_map --now` or `/new`. Schema is
     built at session start; stale sessions omit the `option` enum.
   - Resolve display labels → runtime ids (see **Model label map**)
8. **Cron** only for Agenda rows with `lifecycle=live`, kind `recurring|oneshot`,
   non-empty `schedule_expr`. Skip `event` / `draft` / `archived` / empty expr.
   Respect `paused`. Write prompts to temp files and `$(cat file)` into
   `hermes cron create` (nested heredocs in multi-job one-liners break quoting).
   Write back `hermes_job_id` / `hermes_job_name` via `set_properties` **`set`**
   (not `properties`). Schedule.`skills` → `--skill org/<skill_key>` when the
   Hermes copy lives under `skills/org/`.
9. **Org skills** (when user asks for full sync / cron needs them): copy each
   active agent-scoped Anytype `skill` (`skill_kind=procedure`) into
   `$HERMES_HOME/skills/org/<skill_key>/SKILL.md` (+ optional `skills/org/DESCRIPTION.md`).
   Do **not** wipe Hermes builtins (~50). Keep Anytype as procedure SoT; Hermes
   copy is the runnable router for chat/cron. Put Anytype object id in metadata.
10. **Describe** (kanban / Edit Profile Description in `profile.yaml`):
   `hermes profile describe <slug> --text "<Agent.short_description>"`.
   Verify with `hermes profile describe <slug>` (plain `profile show` does **not**
   print description). For Primary (`default`), also set presentation name:
   `hermes profile rename default P` → `display_name: P` (id stays `default`;
   never `describe P` / `profiles/p`). Bot Mode **card subtitle** is chat
   preview, not this field (`profile-map.md` → Description vs roster card subtitle).
11. **Voice** align Agent modes even when off: `voice.auto_tts` ←
    `voice_auto_tts`; `voice.voice_chat_mode` ← `voice_chat_mode` (usually `off`).
    Only enable STT/TTS stack when `voice_enabled`. There is **no** `voice.enabled`.
12. **Analytics (Langfuse)** when Agent.`analytics_enabled` is true:
    - `hermes -p <slug> plugins install langfuse --enable` (idempotent if already
      present; ensure `plugins.enabled` lists `langfuse`).
    - Required env on that profile's `.env`: `HERMES_LANGFUSE_PUBLIC_KEY` +
      `HERMES_LANGFUSE_SECRET_KEY` (optional `HERMES_LANGFUSE_BASE_URL` for
      self-hosted). Never print secret values into chat or ledgers.
    - If the target is **not** `default` and those keys are missing on the target
      `.env`, **copy** the matching lines from `~/.hermes/.env` (default profile)
      into `~/.hermes/profiles/<slug>/.env`.
    - If keys are still missing (including on default): record a gap and tell the
      user to supply them via the Hermes CLI, which prompts interactively:
      `hermes -p <slug> plugins install langfuse` (or paste into that profile
      `.env`). Do **not** invent placeholders (`pk-lf-...` / `your-key` are
      refused). Plugin fails open without real keys.
    - Leave `plugins.entries.langfuse.settings.end_user_attribution` false/unset
      unless the user asks.
    - When `analytics_enabled` is false/unset: do **not** auto-disable langfuse
      (opt-in only; user may `plugins disable langfuse` manually).
13. **Verify** `hermes profile describe <slug>`, `delegation config --show`
    (routes + **`default:`** set + route fallbacks), `cron list` vs Agenda
    Schedules, `skills list` for `org/…`, `config get voice.voice_chat_mode`,
    `plugins list | grep langfuse` when analytics was requested, `doctor`,
    `sessions refresh-prompts`. Note open sessions need a turn to pick up SOUL
    and **`/delegation model_map --now` or `/new`** after route changes.
14. **Messaging** only when user asks (`messaging-groups.md`). **Org default:
    Hermes Bot Mode hosted rooms** (`groups.create` / Desktop Manage groups;
    2–6 members). Overflow → **Subteam Groups** (never satellite B). Write
    `platform=hermes` + `platform_chat_id=<room_id>`. Resize = new `room_id` +
    writeback + `groups.disband` (retired ids cannot be reused). No Telegram
    tokens required for Bot Mode. External Telegram/Discord only when asked:
    tokens never auto-cloned; allowlists only with a real external chat id; if
    the user wants gates without a room yet, set mention gates and leave
    allowlists empty. Do not invent Telegram groups or chat ids. Commented
    `# TELEGRAM_BOT_TOKEN=` counts as missing for the external path.

## Model label map (resolve before writing routes)

Harness profile fields often store **display** names. Resolve against
`~/.hermes/provider_models_cache.json` (or `hermes model` cache) before apply:

| Anytype label (examples) | Provider key | Runtime model id |
|--------------------------|--------------|------------------|
| Grok 4.5 | `xai-oauth` | `grok-4.5` |
| Claude Code Sonnet 5.5 / Claude Sonnet 5.5 | `anthropic` | `claude-sonnet-5-5` |
| Codex Sol 6.1 | `openai-codex` | `gpt-6.1-sol` |
| llamacpp / LFM3-1.7B-Q8_0 | `llamacpp` | `LFM3-1.7B-Q8_0` (+ `local_runtime`) |
| ollama-launch / lfm3 (legacy) | migrate → `llamacpp` | `LFM3-1.7B-Q8_0` (see `models.md`) |
| llamacpp / d1-2b-q4_k_m | `llamacpp` | `d1-2b-q4_k_m` (+ `local_runtime`) |

Re-check the cache when labels drift. Prefer provider ids that exist in
`auth.json` / credential pool (`xai-oauth`, `anthropic`, `openai-codex`, …).

## Config write discipline

- Prefer `hermes -p <slug> config set` and `tools enable|disable` for single keys.
- For `delegation.backends.model_map.options`, pass a **JSON array** as the
  `config set` value (Hermes coerces it into a YAML list). Then set
  `delegation.backends.model_map.default` and `delegation.backend model_map`.
  Interactive `hermes delegation config` or a surgical YAML subtree edit also
  work. See `delegation.md` → Fleet apply.
- **Do not** `yaml.safe_dump` the whole `config.yaml` (strips comments and can
  drop default-expanded sections). Always backup first.
- One writer per profile; gateway may already be running (OK for config/SOUL).

## Out of scope unless asked

- Messaging: Bot Mode `groups.create` / Desktop Manage groups, or external
  tokens / allowlists / gateway install (prefer Bot Mode when asked)
- Pasting full Memory bodies into `MEMORY.md`
- Creating Hermes cron from Prompt cadence prose (only typed Schedule objects)
- Applying draft/proposed suggestions
- Wiping Hermes builtin skills when syncing Anytype procedures

## Verify checklist

```bash
hermes -p <slug> profile show          # or: hermes profile show <slug>
hermes profile describe <slug>
hermes -p <slug> config get model.default
hermes -p <slug> config get auxiliary.approval.model
hermes -p <slug> config get local_runtime.enabled
hermes -p <slug> config get voice.voice_chat_mode
hermes -p <slug> fallback list         # Local parent: expect none
hermes -p <slug> moa list              # Local parent: expect Active (off), local slots, no stock cloud
hermes -p <slug> delegation config --show   # default: set; each route has fallback_providers when Subagent had fallback_*
# After route changes: /delegation model_map --now  OR  /new  (in an open chat)
hermes -p <slug> tools list | grep -E 'browser|computer|delegation|cronjob'
hermes -p <slug> cron list             # names match Schedule.schedule_key; ids written back
hermes -p <slug> skills list | grep org/
hermes -p <slug> plugins list | grep langfuse   # when analytics_enabled
hermes -p <slug> doctor
hermes -p <slug> sessions refresh-prompts
```

## Full sync aspects (P template, 2026-11-05)

When the user asks for a **proper / full** Agent ↔ Hermes sync, cover all of:

| Aspect | Anytype | Hermes |
|--------|---------|--------|
| Identity | Prompt + `short_description` | `SOUL.md` + `profile describe` / `display_name` |
| Local parent | Harness profile | `model.*` + `auxiliary.approval` + `local_runtime`; empty parent fallbacks; MoA off |
| Subagents | `task_key` + harness + `fallback_*` | When `delegation_backend=model_map` (or unset): `model_map` options + **`default`** + per-route `fallback_providers`; SOUL/Shared Rules require `option` on spawn |
| Profile routes | `delegation_backend=profile_routes` + `profile_route_targets` (+ optional `profile_routes_default`) | `delegation.backend: profile_routes`; allowlist from teammate Agents' `hermes_profile` + `short_description`; require `profile` on spawn |
| Agenda | live Schedules | `hermes cron` + `hermes_job_*` writeback |
| Skills | active procedures on Skills Query | `skills/org/<key>/SKILL.md` (additive) |
| Voice | `voice_*` modes | `voice.auto_tts` / `voice.voice_chat_mode` |
| Analytics | `analytics_enabled` | langfuse plugin + `HERMES_LANGFUSE_*` (copy from default when needed) |
| Messaging | Group + `platform=hermes` + `platform_chat_id` | Bot Mode `groups.create` → room_id writeback (preferred); external allowlists only when asked |
| Tools | Tool profile + surface | `tools enable/disable`; Primary disables browser/computer_use |
| Timezone | Schedule.`timezone` / org | profile `timezone` (e.g. Europe/Paris) |

## Fleet apply (many agents still unconfigured)

When the user asks to apply **messaging groups** and/or **deferred delegation**
for every agent that already uses them in Anytype but Hermes is still wrong:

1. Messaging → `messaging-groups.md` **Fleet apply** (preferred Bot Mode path:
   Subteam Groups when an HQ would exceed 6; `groups.create` for empty
   `platform_chat_id`; write back `platform=hermes` + room_id; never satellite
   B). External Telegram/Discord gates + allowlists only when the user names
   that platform.
2. Delegation → `delegation.md` **Fleet apply** (`model_map` for Subagent
   parents still missing options/default; skip `profile_routes` parents and
   agents with zero Subagents).
3. One ledger under `/tmp/hermes-…-apply/` (Anytype search dumps, plan JSON,
   per-profile backups, results). Verify samples with
   `delegation config --show` + `sqlite3 ~/.hermes/state.db` hosted_rooms query.
4. Report gaps: empty `platform_chat_id`, missing Bot Mode seats, duplicate
   Anytype `platform` select options, `delegation_enabled` without Subagents,
   empty stub `model_map` on non-delegating Foyer clones.

Do **not** mint Telegram rooms, BotFather tokens, or invented chat ids during
this pass. Prefer Hermes Bot Mode hosted rooms.

## Gaps to report after each apply

Always list Anytype ↔ Hermes gaps found (empty Agenda, stale Prompt roster,
unresolved model labels, missing `hermes_profile`, Group without
`platform_chat_id`, Subagent fallbacks not declined, org skills not copied,
SOUL org map behind Prompt, etc.). Fix only what the user asked; leave the
rest as an explicit backlog.
