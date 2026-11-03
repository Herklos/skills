# Security, privacy, and restoration

Docs:
- https://hermes-agent.nousresearch.com/docs/user-guide/security
- https://hermes-agent.nousresearch.com/docs/user-guide/checkpoints-and-rollback
- https://hermes-agent.nousresearch.com/docs/user-guide/session-storage-recovery
- https://hermes-agent.nousresearch.com/docs/user-guide/managed-scope

Per-profile. Secrets and allowlists live in `.env` (never paste values into chat or Anytype).

## Quick map

| Concern | Keys / CLI |
|---------|------------|
| Dangerous commands | `approvals.*`, `command_allowlist`, `/yolo`, `hermes approvals suggest` |
| URL / secret redaction | `security.*`, `privacy.redact_pii` |
| File write sandbox | Protected-path denylist + `HERMES_WRITE_SAFE_ROOT` |
| Who can DM the bot | Platform allowlists, `GATEWAY_ALLOW_ALL_USERS`, `hermes pairing …` |
| Filesystem restore | `checkpoints.*`, `/rollback`, `hermes checkpoints …` |
| Profile backup / restore | `hermes backup`, `hermes import`, `updates.pre_update_backup` |
| Session DB safety | Quit writers → `hermes doctor` → restart (never delete `state.db-wal`) |
| Memory / skill gates | `memory.write_approval`, `skills.write_approval` (see `memory.md`) |
| Terminal isolation | `terminal.backend` docker/ssh/… (see `runtime-limits-and-tools.md`) |

## Approvals

```yaml
approvals:
  mode: smart                 # smart | manual | off (= yolo for the profile)
  timeout: 300
  cron_mode: deny             # deny | approve
  single_query_mode: deny
  unattended_mode: deny
  deny: []                    # fnmatch globs; always blocked (even under yolo)
  smart_policy: ""
  denial_breaker_threshold: 3
  mcp_reload_confirm: true
  destructive_slash_confirm: true

command_allowlist: []         # permanent "always allow" patterns
```

```bash
hermes -p <slug> config set approvals.mode smart
hermes -p <slug> config set approvals.cron_mode deny
hermes -p <slug> approvals suggest            # mine history → allowlist proposals
hermes -p <slug> approvals suggest --apply 1
# Session-only: --yolo / /yolo / HERMES_YOLO_MODE=1
```

| Mode | Behavior |
|------|----------|
| `smart` | Aux LLM auto-allows low risk; escalates uncertain; denies clear danger |
| `manual` | Always prompt |
| `off` | No approval prompts (profile-wide YOLO) |

Hardline blocklist (e.g. `rm -rf /`, fork bombs) always refuses; no override.  
`approvals.deny` is the user-editable floor under YOLO.  
YOLO does **not** skip MCP spend limits, vault card-fill prompts, or elicitation.

Also always gated (even under YOLO): writes to agent-instruction files when
`security.protected_instruction_files: true` (SOUL.md, AGENTS.md, CLAUDE.md, …).

## `security.*` and privacy

```yaml
security:
  allow_private_urls: false          # web/vision/media + cloud/CDP browsers
  fake_ip_ranges: []                 # proxy fake-IP CIDRs treated as non-private
  redact_secrets: true               # scrub secrets from tool/chat surfaces
  allow_data_training_tiers_noninteractive: false
  protected_instruction_files: true
  protected_instruction_extra_patterns: []   # e.g. ["*.mdc"]
  website_blocklist:
    enabled: false
    domains: []
    shared_files: []
  approval:
    transport: builtin               # or named plugin transport
    transport_fallback: deny         # deny | builtin
  allow_lazy_installs: true          # false = no auto pip for optional backends
  acked_advisories: []               # hermes doctor --ack <id>

privacy:
  redact_pii: false                  # hash user IDs / strip phones from LLM context
```

```bash
hermes -p <slug> config set security.redact_secrets true
hermes -p <slug> config set security.allow_private_urls false
hermes -p <slug> config set security.protected_instruction_files true
hermes -p <slug> config set privacy.redact_pii false
hermes -p <slug> doctor --ack <advisory-id>
```

MoA advisor redaction (when using Mixture of Agents): `moa.privacy_filter`
(`""` | `display` | `full`) — see `models-and-delegation.md`.

## File write safety

Always blocked for `write_file` / `patch` (no chat override): OS credential dirs
(`~/.ssh` keys, `~/.aws`, …), Hermes secret stores (`.env`, vault, browser-profile,
mcp-tokens, pairing, …). `~/.ssh/config` is approval-gated, not hard-blocked.

Optional sandbox via env (profile `.env` or process env):

```bash
# Unix: colon-separated roots. Include HERMES_HOME if cron/skills must stay writable.
HERMES_WRITE_SAFE_ROOT=/path/to/project:/home/you/.hermes/profiles/<slug>
```

Unset to rely only on the protected-path denylist. Terminal shell can still reach
denied paths as the same OS user; use a container backend for stronger isolation.

## Messaging authorization

Default deny if no allowlists / allow-all. Configure in profile `.env`:

```bash
TELEGRAM_ALLOWED_USERS=…          # platform-specific
DISCORD_ALLOWED_USERS=…
GATEWAY_ALLOWED_USERS=…           # cross-platform
GATEWAY_ALLOW_ALL_USERS=false     # extreme caution if true
```

Or DM pairing:

```bash
hermes -p <slug> pairing list
hermes -p <slug> pairing approve <platform> <code>
hermes -p <slug> pairing revoke <platform> <user-id>
hermes -p <slug> pairing clear-pending
```

```yaml
unauthorized_dm_behavior: pair    # pair | ignore | decline
# optional per-platform overrides in messaging config
```

Never put user IDs or tokens on Anytype pages; document policy only
(allowlist | pairing | open).

## Checkpoints and `/rollback` (filesystem restoration)

Opt-in shadow-git snapshots before destructive file edits. Default **off**.

```yaml
checkpoints:
  enabled: false
  max_snapshots: 20
  max_total_size_mb: 500
  max_file_size_mb: 10
  auto_prune: true
  retention_days: 7
  min_interval_hours: 24
```

```bash
hermes -p <slug> config set checkpoints.enabled true
hermes -p <slug> chat --checkpoints
# In session:
# /rollback                  list
# /rollback <N>              restore (keep hand-edits)
# /rollback <N> --all        full restore
# /rollback diff <N>
# /rollback <N> <file>
hermes -p <slug> checkpoints status
hermes -p <slug> checkpoints prune
# Destructive — confirm first:
# hermes -p <slug> checkpoints clear
```

Does not replace git. Confirm before `--all` or `clear`.

## Backup and profile restore

```bash
hermes -p <slug> backup                  # full zip (excludes agent codebase)
hermes -p <slug> backup --quick          # critical state only
hermes -p <slug> backup -o /path/out.zip
# Restore: hermes import <archive>  (or profile import for profile packages)
```

```yaml
updates:
  pre_update_backup: quick    # quick | full | off
```

`quick` snapshots pairing/cron/config/auth into state-snapshots; `full` also zips
HERMES_HOME (slow on large homes). Confirm before discarding local changes on update.

## Session storage recovery

If Hermes refuses writes because another process holds an old `state.db-wal`:

1. Stop every writer on that profile (`gateway stop`, Desktop quit, dashboard, cron)
2. `hermes -p <slug> doctor` until no holders listed
3. Start one process again

**Do not** delete `state.db-wal` / `state.db-shm`. Use `hermes backup` or
`hermes sessions recover`, never copy `state.db` alone.

## Related gates (pointers)

| Gate | Where |
|------|--------|
| Memory write approval | `memory.write_approval` → `memory.md` |
| Skill write approval | `skills.write_approval` |
| Computer-use permissions | `computer_use.permission_mode` → `browser-and-computer.md` |
| Browser real profile | `browser.use_real_profile` → `browser-and-computer.md` |
| Docker / network isolation | `terminal.backend`, `docker_network` → `runtime-limits-and-tools.md` |
| Egress credential proxy | `hermes egress setup` (sandbox credential injection) |
| Admin-pinned config | managed scope `/etc/hermes` (IT; user cannot override pinned keys) |

## Minimal recipes

**Interactive specialist (safe default):**

```bash
hermes -p forge config set approvals.mode smart
hermes -p forge config set approvals.cron_mode deny
hermes -p forge config set security.redact_secrets true
hermes -p forge config set security.protected_instruction_files true
hermes -p forge config set privacy.redact_pii false
hermes -p forge config set checkpoints.enabled false   # or true if /rollback wanted
```

**Messaging bot:**

```bash
# Set TELEGRAM_ALLOWED_USERS=… (or pairing) in profile .env — never echo values
hermes -p forge config set unauthorized_dm_behavior pair
hermes -p forge pairing list
hermes -p forge config set approvals.mode smart
```

**Unattended cron on disposable sandbox:**

```bash
hermes -p forge config set terminal.backend docker
hermes -p forge config set approvals.cron_mode deny    # or approve only if trusted
# Prefer approvals.deny patterns for force-push / wipe commands
```

## Safety

1. Confirm before `approvals.mode: off`, `GATEWAY_ALLOW_ALL_USERS`, `checkpoints clear`, full restore `--all`, or deleting WAL files.
2. Document policy on Anytype; keep IDs, tokens, and allowlist values in runtime secrets only.
3. Write denylist ≠ OS sandbox; pair with container backends when isolation matters.
