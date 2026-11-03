# Runtime limits, tools, terminal, output

Docs:
- https://hermes-agent.nousresearch.com/docs/user-guide/configuration
- https://hermes-agent.nousresearch.com/docs/user-guide/features/tools
- https://hermes-agent.nousresearch.com/docs/reference/toolsets-reference

Per-profile settings in `<profile>/config.yaml` (and `hermes -p <slug> tools` / `config set`). Secrets stay in `.env`.

## Quick map

| Concern | Keys / CLI |
|---------|------------|
| Which tools | `toolsets`, `agent.disabled_toolsets`, `hermes tools enable\|disable\|list` |
| Dangerous-command gate | `approvals.*`, `command_allowlist` |
| Where shell runs | `terminal.backend`, `terminal.cwd`, container/SSH options |
| Tool / file output caps | `tool_output.*`, `file_read_max_chars`, `context_file_max_chars` |
| Turn / time budgets | `agent.max_turns`, `agent.run_budget_seconds`, `agent.gateway_timeout` |
| Context compaction | `compression.*` (+ `auxiliary.compression` model) |
| Loop / runaway tools | `tool_loop_guardrails.*` |

## Tools access

Tools ship as **toolsets** (e.g. `web`, `terminal`, `file`, `browser`, `memory`, `delegation`, `code_execution`, `safe`, platform presets like `hermes-cli` / `hermes-telegram`). MCP servers appear as `mcp-<server>` toolsets.

```bash
hermes -p <slug> tools                 # interactive UI
hermes -p <slug> tools list
hermes -p <slug> tools enable web terminal file
hermes -p <slug> tools disable browser
hermes -p <slug> tools --summary       # per-platform
# One-shot session override:
hermes -p <slug> chat --toolsets "web,terminal,file"
```

```yaml
toolsets:
  - hermes-cli
  - web
  - terminal
  - file

agent:
  disabled_toolsets: []    # hide even if otherwise enabled (e.g. ["memory"])
```

Common toolsets: `web`, `search`, `terminal`, `file`, `browser`, `vision`, `image_gen`, `skills`, `tts`, `todo`, `memory`, `session_search`, `cronjob`, `code_execution`, `delegation`, `clarify`, `messaging`, `debugging`, `safe`, `computer_use`.

`browser` requires `terminal` (local Python for `browser_exec`). Messaging platforms can use narrower presets than CLI.

## Approvals (dangerous commands)

Canonical home: **`security.md`** (modes, YOLO floor, `approvals.deny`, pairing,
privacy, checkpoints). For tool/terminal setup, typical interactive defaults:

```bash
hermes -p <slug> config set approvals.mode smart
hermes -p <slug> config set approvals.cron_mode deny
```

## Terminal backend

```yaml
terminal:
  backend: cua             # preferred: cua (Cua Spaces plugin) | local | docker | ssh | modal | daytona | vercel_sandbox | singularity
  cwd: .                   # absolute project path for host/local specialists; leave unset with cua (Space home)
  timeout: 180             # seconds per command
  temp_dir: ""             # empty = managed cache under HERMES_HOME
  home_mode: auto          # auto | real | profile
  env_passthrough: []      # env names forwarded into sandbox / execute_code
  degraded_mode: warn      # warn | fail on remote connection failures

  # Container backends (docker / modal / daytona / …):
  container_cpu: 1
  container_memory: 5120   # MB
  container_disk: 51200    # MB
  container_persistent: true
  docker_image: nousresearch/hermes-sandbox:desktop
  docker_network: true     # false = --network=none
  docker_volumes: []       # ["host:container", …]
  docker_mount_cwd_to_workspace: false
  docker_forward_env: []   # host env names visible inside container
  docker_shm_size: "1g"
  docker_run_as_host_user: false
  lifetime_seconds: 300    # idle sandbox lifetime (backend-dependent)
```

```bash
# Preferred default computer / sandboxed terminal: Cua Spaces
hermes -p <slug> plugins install https://github.com/trycua/hermes-cua-spaces
hermes -p <slug> config set terminal.backend cua
# Leave terminal.cwd unset with cua (starts in Space home)

hermes -p <slug> config set terminal.backend local
hermes -p <slug> config set terminal.cwd /absolute/path/to/project
hermes -p <slug> config set terminal.timeout 180
hermes -p <slug> config set terminal.backend docker
hermes -p <slug> config set terminal.docker_network true
hermes -p <slug> config set terminal.container_memory 5120
```

| Backend | Runs commands on | Notes |
|---------|------------------|-------|
| `cua` | [Cua Space](https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces) | **Preferred default** for agents; install plugin `cua-spaces`; optional `desktop: true` for browser / `computer_use` in Linux Spaces |
| `local` | Host | Simplest for host debugging; use when the agent must touch the real machine |
| `docker` | Container | Isolation; optional shared key across profiles |
| `ssh` | Remote host | Needs SSH config / keys |
| `modal` / `daytona` / `vercel_sandbox` | Cloud sandbox | Provider credentials in `.env` |
| `singularity` | Apptainer/SIF | Plugin; set image path |

Bot Screen / `computer_use` follow `bot_desktop.placement` relative to this backend (see `browser-and-computer.md`). With `cua` + Linux desktop stack, prefer `bot_desktop.placement: auto` so the screen follows the Space. Use `local` when debugging host tool failures, then switch back to `cua`.
## Output and read limits

```yaml
tool_output:
  max_bytes: 50000         # terminal/tool output cap (chars; head+tail kept)
  max_lines: 2000          # max lines one read_file may request
  max_line_length: 2000    # per-line cap in numbered views

file_read_max_chars: 100000          # hard reject above this per read_file
context_file_max_chars: null         # SOUL/AGENTS/etc. auto-load cap; null = scale with model
context_file_read_timeout: 5.0       # seconds per context-file read
```

```bash
hermes -p <slug> config set tool_output.max_bytes 50000
hermes -p <slug> config set file_read_max_chars 100000
```

Raise `tool_output.max_bytes` only when agents must see huge command logs; cost and context pressure rise with it.

## Agent turn / time limits

```yaml
agent:
  max_turns: null            # null = unlimited; positive int caps tool/LLM turns
  budget_warning_ratio: null # e.g. 0.75 one-time warning before finite cap
  run_budget_seconds: null   # wall-clock per run; wrap-up notice at 80%
  gateway_timeout: 1800      # idle gateway timeout (s); 0 = unlimited
  turn_liveness:
    timeout_s: 600.0         # no-progress interrupt; <=0 disables
    poll_s: 15.0
  disabled_toolsets: []
```

```bash
hermes -p <slug> config set agent.max_turns 200
hermes -p <slug> config unset agent.max_turns    # back to unlimited
hermes -p <slug> config set agent.run_budget_seconds 3600
```

Default `max_turns` is unlimited so long tasks are not cut mid-work. Cap specialists that should stay bounded. Delegation children have their own `delegation.max_iterations` (see `delegation.md`).

## Compression (context window)

```yaml
compression:
  enabled: true
  threshold: 0.50            # compress when usage exceeds this ratio
  threshold_tokens: null     # optional absolute token trigger
  target_ratio: 0.20
  protect_last_n: 20
  max_attempts: 3
  progress_notices: false
```

```bash
hermes -p <slug> config set compression.threshold 0.50
hermes -p <slug> config set compression.enabled true
# Cheaper summarizer: auxiliary.compression.provider / model
```

Full knobs live in the official configuration doc. Gateway hygiene settings (`hygiene_*`) apply mainly to messaging gateways.

## Tool-loop guardrails

```yaml
tool_loop_guardrails:
  warnings_enabled: true
  hard_stop_enabled: false
  non_interactive_hard_stop_enabled: true   # cron/gateway default hard-stop
  warn_after:
    exact_failure: 2
    same_tool_failure: 3
    idempotent_no_progress: 2
  hard_stop_after:
    exact_failure: 5
    same_tool_failure: 8
    idempotent_no_progress: 5
  loop_caps:
    max_web_searches: 50     # per turn; 0 = unlimited
    max_subagents: 50
```

Interactive CLI stays warning-first by default; unattended surfaces hard-stop sooner.

## Minimal recipes

**Default: Cua Spaces terminal (preferred computer):**

```bash
hermes -p forge plugins install https://github.com/trycua/hermes-cua-spaces
hermes -p forge config set terminal.backend cua
hermes -p forge config set plugins.entries.cua-spaces.settings.desktop true
hermes -p forge tools enable terminal file web
hermes -p forge config set agent.max_turns 150
hermes -p forge config set approvals.mode smart
```

**Narrow coding specialist (host local, bounded):**

```bash
hermes -p forge tools enable terminal file web
hermes -p forge config set terminal.backend local
hermes -p forge config set terminal.cwd /absolute/path/to/repo
hermes -p forge config set agent.max_turns 150
hermes -p forge config set approvals.mode smart
hermes -p forge config set tool_output.max_bytes 50000
```

**Sandboxed terminal (Docker):**

```bash
hermes -p forge config set terminal.backend docker
hermes -p forge config set terminal.container_memory 5120
hermes -p forge config set terminal.docker_network true
hermes -p forge config set terminal.docker_mount_cwd_to_workspace true
```
**Tight messaging bot:**

```bash
hermes -p forge tools --summary
# enable only the messaging preset + needed toolsets
hermes -p forge config set approvals.mode smart
hermes -p forge config set approvals.cron_mode deny
hermes -p forge config set agent.gateway_timeout 1800
```

## Safety

1. Confirm before `approvals.mode: off`, broad `command_allowlist`, or `docker_forward_env` that exposes secrets.
2. Shared Docker containers (`docker_shared_container_key`) are intentional collaboration, not isolation.
3. Do not put API keys or allowlist secrets on Anytype pages; document capability labels only.
