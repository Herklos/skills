# Scheduled tasks (cron)

Per-profile recurring and one-shot jobs. Official docs:
https://hermes-agent.nousresearch.com/docs/user-guide/features/cron

Jobs live under that profile's `cron/` directory (`cron/jobs.json`,
`cron/output/…`). Bot Mode **Routines** are the same store with a bot namespace.
The **gateway** ticks the scheduler (~60s). Agent-backed jobs need a running
gateway; `no_agent` script jobs can still run from `hermes cron tick`.

## Expectation

Every Hermes profile that should own scheduled work:

1. Enable the `cronjob` toolset so chat can call `cronjob_manage`.
2. Keep intended jobs as typed Anytype **Schedule** objects on the agent's
   **Agenda** Query (`agenda_page`). See anytype-agents
   `agenda-and-schedules.md`. Suggested runtime may summarize; do not treat
   markdown bullets as the only source when Schedules exist.
3. Apply recurring/oneshot Schedules with `/cron`, `hermes -p <slug> cron …`,
   or plain-language asks that use `cronjob_manage`. Docs alone do not create
   live jobs. Skip apply during org redesign unless the user says apply.

```bash
hermes -p <slug> tools enable cronjob
hermes -p <slug> cron list
hermes -p <slug> cron status
hermes -p <slug> gateway start   # agent jobs need the gateway
```

## How to create and manage

| Surface | Examples |
|---------|----------|
| Chat slash | `/cron add "every 2h" "Check server status"` · `/cron list` · `/cron pause\|resume\|run\|remove <id\|name>` |
| CLI | `hermes -p <slug> cron create\|list\|edit\|pause\|resume\|run\|cancel\|remove\|status\|tick\|doctor\|runs\|incidents\|notepad` |
| Natural language | "Every weekday at 9am, summarize HN AI news and send it on Telegram." → `cronjob_manage` |

Prefer tool/CLI/dashboard over hand-editing `cron/jobs.json` (write-safety and
mutation checks can silently block direct patches).

```bash
hermes -p <slug> cron create "every 2h" "Check server status"
hermes -p <slug> cron create "every 1h" "Summarize new feed items" --skill blogwatcher
hermes -p <slug> cron create "0 9 * * 1-5" "HK market open brief" --timezone Asia/Hong_Kong
hermes -p <slug> cron create "every 1d at 09:00" "Audit open PRs" --workdir /absolute/path/to/repo
hermes -p <slug> cron create "every 5m" --script disk-watch.sh --no-agent --deliver telegram --name disk-watch
hermes -p <slug> cron create "every 1h" "Post the digest" --paused --paused-reason "Awaiting review"
```

Job refs accept **id or name** (case-insensitive). Ambiguous names are refused.

## Model and reasoning at fire time

Resolution order for agent jobs:

1. **Per-job pin** (`--model` / `--provider`, or `--pin` to lock current main)
2. **`cron.model` / `cron.model_provider`** (fleet default, independent of chat)
3. **Main agent model** at the moment the job fires

```bash
hermes -p <slug> config set cron.model google/gemini-2.5-flash
hermes -p <slug> cron edit <id> --pin
hermes -p <slug> cron edit <id> --provider openrouter --model anthropic/claude-sonnet-4
hermes -p <slug> cron edit <id> --unpin
hermes -p <slug> cron edit <id> --reasoning-effort high   # none|minimal|low|medium|high|…
```

Pinned jobs do **not** walk `fallback_providers`. Unpinned jobs can. Reasoning
pins are CLI/dashboard only (not on `cronjob_manage`). `no_agent` jobs ignore
model/reasoning pins.

## Job fields worth documenting

| Field | Role |
|-------|------|
| `name` | Human label; usable as job ref |
| `schedule` | Natural (`every 2h`, `in 30m`) or cron expr |
| `prompt` | Full self-contained task (fresh session; no prior chat) |
| `skills` / `--skill` | Zero or more skills loaded before the prompt |
| `deliver` | `origin` · `local` · `telegram:<chat>` · `all` · `bot-chat` · `bot-chat:<profile>` · **`room:<room_id>`** (Bot Mode Group Chat) · … |
| `workdir` | Absolute project dir (injects AGENTS.md / .cursorrules; tools cwd) |
| `timezone` | Wall-clock zone for cron exprs (else profile `timezone`) |
| `no_agent` + `script` | Script-only; stdout delivered; empty stdout = silent |
| `enabled_toolsets` | Per-job tool allowlist (else cron-platform / defaults) |
| Model / reasoning pin | See above |
| `--grace-minutes` / catch-up | Missed-run window (see below) |
| `--paused` | Create without scheduling until `resume` |

Cron-run sessions **cannot** create more cron jobs unless
`cron.allow_agent_scheduling: true`. Default is off (anti-runaway).

## Delivery (short)

Final agent response (or script stdout) goes to the job's `deliver` target.
The prompt should not try to "send" itself. Common targets:

| Target | Effect |
|--------|--------|
| (omit) / `origin` | Chat/topic the job was created from |
| `local` | Files under `cron/output/` only |
| `all` | Every connected home channel (resolved at fire time) |
| `bot-chat` / `bot-chat:<profile>` | Inject into that Bot Chat as a real message |
| **`room:<room_id>`** | Post into a Bot Mode Group Chat; starts a round **only for members the output @mentions** |
| `telegram:<chat_id>` / `…:thread` | External platform (only when asked) |

Comma-combine (e.g. `origin,all`). Use Anytype Group.`platform_chat_id` as
`room_id` when delivering into org rooms (`messaging-groups.md`).

Markers in agent replies: `[SILENT]` suppresses successful delivery; `[CRON_FAILURE]`
marks the run failed. Script jobs signal failure with non-zero exit.

Related config: `cron.wrap_response`, `cron.delivery.notify`,
`cron.mirror_delivery` (continuable replies), `approvals.cron_mode`
(`deny` \| `approve` for unattended tool approvals).

```bash
hermes -p <slug> config set approvals.cron_mode deny
```

## Cancel in-flight + missed runs

```bash
hermes -p <slug> cron cancel <job_id_or_name>
hermes -p <slug> cron cancel <job_id_or_name> --reason "wedged on staging API"
```

`cancel` stops the **current** run only (schedule untouched). It is a request,
not a hard kill; the run books a `cancelled` row (no failure notice, no streak).
Safe no-op when nothing is running. Also: Desktop **Stop**, API
`POST /api/cron/jobs/{id}/cancel`, agent `cronjob_manage` action `cancel`.
`remove` cancels an in-flight run first.

**Missed occurrences (cron expressions):** catch-up window = half the period,
clamped 2 minutes–2 hours, unless overridden:

```bash
hermes -p <slug> cron edit <id> --grace-minutes 0     # never catch up
hermes -p <slug> cron edit <id> --grace-minutes 30
hermes -p <slug> config set cron.catch_up_missed false  # fleet: skip catch-up
```

`once` / `interval` schedules have no wall-clock miss. Recurring jobs that were
**paused** over a due slot keep that slot due on resume (one catch-up, or skip
when catch-up is off).

## Ops surfaces (pointer)

```bash
hermes -p <slug> cron runs <id>           # durable execution attempts
hermes -p <slug> cron incidents           # failure incidents
hermes -p <slug> cron incidents ack <id>
hermes -p <slug> cron notepad <id>        # durable KV across runs for one job
```

Full behavior: official cron docs. Recurring jobs share a prompt-cache key
(v0.23 latency work); prefer stable prompts for fleet jobs.

## Fleet health

```bash
hermes -p <slug> cron list
hermes -p <slug> cron status      # ticker / overdue / store writable
hermes -p <slug> cron doctor      # blocked_config, delivery issues, …
hermes -p <slug> cron runs <id>
hermes pause --reason "…"         # global emergency stop (all scheduled fires)
hermes resume
```

Preflight (`cron.preflight`, default on) blocks misconfigured jobs before an LLM
call (`blocked_config`). Gateway must be able to write `cron/` or due jobs are
skipped until the store is writable again.

## Config keys (common)

```yaml
cron:
  model: google/gemini-2.5-flash      # optional fleet default for unpinned jobs
  model_provider: openrouter
  preflight: true
  allow_agent_scheduling: false
  catch_up_missed: true
  max_parallel_jobs: 4                # optional concurrency cap
  wrap_response: true
  mirror_delivery: false
  # delivery.notify, script timeout, media send timeout: see official docs

approvals:
  cron_mode: deny                     # unattended tool approvals
```

```bash
hermes -p <slug> config set cron.model <name>
hermes -p <slug> config set cron.preflight true
hermes -p <slug> config set cron.allow_agent_scheduling false
hermes -p <slug> config set approvals.cron_mode deny
```

## Clone / export note

`--clone` and `--clone-all` **skip** `cron/` by default. Recreate jobs on the
new profile from the agent's Scheduled tasks list (or export/import if you
copy the store deliberately).

## Recipe: morning brief + disk watchdog

```bash
hermes -p atlas tools enable cronjob
hermes -p atlas gateway start

# Agent brief → Telegram home
hermes -p atlas cron create "0 9 * * 1-5" \
  "Summarize overnight CI failures and open Sev-1s for Project Harbor. Be concise." \
  --name morning-brief \
  --deliver telegram \
  --skill weekly-hq-brief

# Optional cheaper fleet model for unpinned jobs
hermes -p atlas config set cron.model google/gemini-2.5-flash
hermes -p atlas config set approvals.cron_mode deny

# Script watchdog (no LLM): empty stdout = silent
hermes -p atlas cron create "every 5m" \
  --script "$HOME/bin/disk-watch.sh" \
  --no-agent \
  --deliver telegram \
  --name disk-watch

hermes -p atlas cron list
hermes -p atlas cron status
```

## Self-contained prompts

Each fire is a **fresh** session. Put hostnames, paths, acceptance criteria, and
delivery expectations in the prompt (or in attached skills). Vague references
to "that server issue" fail.

## Decision guide

| Need | Do |
|------|----|
| Chat can schedule | `tools enable cronjob` |
| Jobs actually fire | Gateway running (`gateway start` / `install`) |
| Cheap recurring fleet | `cron.model` (+ leave jobs unpinned) |
| Lock one job's model | `cron edit <id> --pin` or `--model`/`--provider` |
| Watchdog / heartbeat | `--no-agent --script …` (empty stdout = silent) |
| Post into Bot Mode room | `--deliver room:<platform_chat_id>` + @mentions in prompt |
| Stop wedged run | `cron cancel <id>` (schedule stays) |
| Skip missed fires | `--grace-minutes 0` or `cron.catch_up_missed: false` |
| Repo-aware audit | `--workdir /absolute/path` |
| Unattended approvals | `approvals.cron_mode: deny` (or `approve` if trusted) |
| Document intent | Anytype **Schedule** on Agenda Query (`agenda_page`); Suggested runtime summary optional |

## Anytype Agenda → Hermes

Org source of truth: Anytype type **`schedule`** on Agent.`agenda_page`
(Query `{OwnerShort} – Agenda`). Companion skill: `anytype-agents`
`agenda-and-schedules.md`. Dates/Calendar: Schedule.`next_run` (Anytype Date
Objects). Editing Anytype does not create `cron/` jobs.

### When to apply

- User explicitly asks to apply / sync Hermes cron for an agent or Schedule.
- Prefer `lifecycle=live`, `schedule_kind` in `recurring` | `oneshot`, non-empty
  `schedule_expr`. Skip `event`, `archived`, and empty expr.
- Respect `paused` / `paused_reason` (`--paused` on create, or create then pause).

### Field map

| Anytype Schedule | Hermes |
|------------------|--------|
| `schedule_key` | `--name` (job ref) |
| `schedule_expr` | schedule argument (cron expr or natural) |
| `timezone` | `--timezone` (else profile timezone) |
| body **Prompt** | prompt string (fresh session; self-contained) |
| `skills` (comma list) | one `--skill` per key |
| `deliver` | `--deliver` |
| `workdir` | `--workdir` |
| `model_pin` | `--model` / `--provider` / `--pin`, or leave to `cron.model` / main |
| `no_agent` + `script_path` | `--no-agent --script <path>` |
| `paused` + `paused_reason` | `--paused --paused-reason "…"` |
| after create | write back `hermes_job_id` / `hermes_job_name` on the Schedule |

### Apply recipe

```bash
hermes -p <slug> tools enable cronjob
hermes -p <slug> gateway start   # agent jobs need the gateway

# Prefer prompt files (nested heredocs inside multi-job bash one-liners break):
printf '%s\n' '<Schedule body Prompt text>' > /tmp/hermes-cron-<schedule_key>.txt
hermes -p <slug> cron create "<schedule_expr>" \
  "$(cat /tmp/hermes-cron-<schedule_key>.txt)" \
  --name <schedule_key> \
  --timezone <timezone> \
  --deliver <deliver> \
  --skill org/<skill1> \
  # optional: --workdir … --model … --provider … --paused …

hermes -p <slug> cron list
```

Then `API-patch-object` the Schedule with `set_properties` **`set`** (values
under `set`, not `properties`): `hermes_job_name` = `schedule_key` (or the name
Hermes stored) and `hermes_job_id` from `cron list`. Keep Agenda Calendar
`next_run` in sync when you know the next fire. If Schedule.`skills` names an
Anytype procedure synced under `skills/org/`, pass `--skill org/<skill_key>`.

### Clone note

`--clone` / `--clone-all` still skip `cron/`. Recreate from the Agenda Schedules
(or deliberate cron store copy), not from Suggested runtime markdown alone.

## Doc links

- https://hermes-agent.nousresearch.com/docs/user-guide/features/cron
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/webhooks#event-triggered-cron-jobs
- Approvals: `security.md` / `runtime-limits-and-tools.md` (`approvals.cron_mode`)
- cwd for gateway/cron: `workspace.md` (`terminal.cwd`)
- Anytype Agenda / Schedule: anytype-agents `agenda-and-schedules.md`
- Anytype dates / Calendar: https://doc.anytype.io/anytype/features/dates
