# Anytype → Hermes apply (fleet playbook)

Use when the user explicitly asks to apply an Anytype Agent into a live Hermes
profile (or after an **accepted** suggestion). Companion checklist:
`anytype-agents` → `suggested-runtime.md`. Editing Anytype never pushes config.

First successful apply (P → Hermes `default`, 2026-11-04) is the template below.

## Resolve profile slug

| Anytype | Hermes |
|---------|--------|
| Agent.`hermes_profile` filled | `hermes -p <slug>` |
| Primary / empty + Bot Mode title **P** | id **`default`** (`$HERMES_HOME`, not `profiles/p`) |
| Missing slug but `~/.hermes/profiles/<name>` exists | set Agent.`hermes_profile` then apply |
| No dir | `hermes profile create <slug> --clone-from <src>` (no `--clone-channels` unless asked) |

After apply, write back `hermes_profile` on the Agent if it was empty.

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
     local `reference_models` + `aggregator` (`ollama-launch`/`lfm3`), and
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
   - Prefer **no** `model_map.default` so unrouted work stays on parent lfm3
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
10. **Describe** (kanban / orchestrator routing blurb in `profile.yaml`):
   `hermes profile describe <slug> --text "<Agent.short_description>"`.
   Verify with `hermes profile describe <slug>` (plain `profile show` does **not**
   print description). For Primary (`default`), also set presentation name:
   `hermes profile rename default P` → `display_name: P` (id stays `default`).
11. **Voice** align Agent modes even when off: `voice.auto_tts` ←
    `voice_auto_tts`; `voice.voice_chat_mode` ← `voice_chat_mode` (usually `off`).
    Only enable STT/TTS stack when `voice_enabled`. There is **no** `voice.enabled`.
12. **Verify** `hermes profile describe <slug>`, `delegation config --show`
    (route fallbacks present), `cron list` vs Agenda Schedules, `skills list`
    for `org/…`, `config get voice.voice_chat_mode`, `doctor`,
    `sessions refresh-prompts`. Note open sessions need a turn to pick up SOUL.
13. **Messaging** only when user asks (`messaging-groups.md`); tokens never
    auto-cloned. If Group.`platform_chat_id` is empty, set mention gates only
    and leave allowlists empty (do not invent chat ids).

## Model label map (resolve before writing routes)

Harness profile fields often store **display** names. Resolve against
`~/.hermes/provider_models_cache.json` (or `hermes model` cache) before apply:

| Anytype label (examples) | Provider key | Runtime model id |
|--------------------------|--------------|------------------|
| Grok 4.5 | `xai-oauth` | `grok-4.5` |
| Claude Code Sonnet 5.5 / Claude Sonnet 5.5 | `anthropic` | `claude-sonnet-5-5` |
| Codex Sol 6.1 | `openai-codex` | `gpt-6.1-sol` |
| ollama-launch / lfm3 | `ollama-launch` | `lfm3` |
| llamacpp / d1-2b-q4_k_m | `llamacpp` | `d1-2b-q4_k_m` (+ `local_runtime`) |

Re-check the cache when labels drift. Prefer provider ids that exist in
`auth.json` / credential pool (`xai-oauth`, `anthropic`, `openai-codex`, …).

## Config write discipline

- Prefer `hermes -p <slug> config set` and `tools enable|disable` for single keys.
- For `delegation.backends.model_map`, use the advanced-delegation store /
  `hermes delegation config`, or a **surgical** YAML edit of only that subtree.
- **Do not** `yaml.safe_dump` the whole `config.yaml` (strips comments and can
  drop default-expanded sections). Always backup first.
- One writer per profile; gateway may already be running (OK for config/SOUL).

## Out of scope unless asked

- Messaging tokens / allowlists / gateway install (gates alone OK when Group exists)
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
hermes -p <slug> delegation config --show   # each route has fallback_providers when Subagent had fallback_*
hermes -p <slug> tools list | grep -E 'browser|computer|delegation|cronjob'
hermes -p <slug> cron list             # names match Schedule.schedule_key; ids written back
hermes -p <slug> skills list | grep org/
hermes -p <slug> doctor
hermes -p <slug> sessions refresh-prompts
```

## Full sync aspects (P template, 2026-11-05)

When the user asks for a **proper / full** Agent ↔ Hermes sync, cover all of:

| Aspect | Anytype | Hermes |
|--------|---------|--------|
| Identity | Prompt + `short_description` | `SOUL.md` + `profile describe` / `display_name` |
| Local parent | Harness profile | `model.*` + `auxiliary.approval` + `local_runtime`; empty parent fallbacks; MoA off |
| Subagents | `task_key` + harness + `fallback_*` | `model_map` options + per-route `fallback_providers` |
| Agenda | live Schedules | `hermes cron` + `hermes_job_*` writeback |
| Skills | active procedures on Skills Query | `skills/org/<key>/SKILL.md` (additive) |
| Voice | `voice_*` modes | `voice.auto_tts` / `voice.voice_chat_mode` |
| Messaging | Group + `platform_chat_id` | allowlists only when chat id known; else gates + note |
| Tools | Tool profile + surface | `tools enable/disable`; Primary disables browser/computer_use |
| Timezone | Schedule.`timezone` / org | profile `timezone` (e.g. Europe/Paris) |

## Gaps to report after each apply

Always list Anytype ↔ Hermes gaps found (empty Agenda, stale Prompt roster,
unresolved model labels, missing `hermes_profile`, Group without
`platform_chat_id`, Subagent fallbacks not declined, org skills not copied,
SOUL org map behind Prompt, etc.). Fix only what the user asked; leave the
rest as an explicit backlog.
