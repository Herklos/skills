---
name: any-agents
description: >
  Set up, run, configure, or debug AI agents and teams on any + anyrt (anybao).
  Use for anyrt serve, overlays, tiers, triggers, connectors, sync. Use when
  the user runs /any-agents.
version: 1.2.0
license: MIT
metadata:
  category: agents
  domain: any-anyrt
---

# any-agents

Operate agents on **`any`** (local-first E2E-encrypted database + HTTP API) and
**`anyrt`** (anybao agent runtime). Chat, memory, config, triggers and agent
code live as objects in `any` spaces. Prefer the MIT open stack (`any`,
`anybao`/`anyrt`, `any-sync-sdk`, `any-store`, `any-sync` nodes). Do **not**
depend on Anytype app projects (`anytype-heart`, `anytype-cli`, `anytype-mcp`,
`anytype-ts`, …).

**Alpha.** Data shapes and APIs change without migration. Prefer a dedicated
experiment account. Re-read sources before changing runtime behaviour
(`reference/sources.md`).

## Before you act

1. Confirm the **`any` listen address** (default `127.0.0.1:2046`; override with
   `ANY_LISTEN_ADDR`, `listen.addr`, or `any run --addr`). Do not assume 7001.
2. Point `anyrt` at that same URL (`anybao.toml` `addr`, or `--addr`).
3. Confirm account: `any auth status` (or `GET /v1/auth`). Without an account,
   data routes return `401 auth.required`.
4. Confirm anyrt readiness: log line `wait set clear — agent ready`
   (or `scripts/agent-ready.sh`, which treats control `GET /status`
   `envelope.data.role == "active"` as ready).
5. Never print, log or commit the account mnemonic or secret values.
6. Runtime behaviour changes require an ADR in anybao first.
7. CLI `--addr` is `host:port` (no `http://`). HTTP scripts use a full URL.

## Security (read first)

The local `any` server **trusts every process on the machine** and does not
authenticate local callers. Isolate agents (dedicated OS user, or keep
sensitive spaces off hosts that run shell-enabled agents). Keep HTTP on
loopback. Prefer the default runtime over `make runtime-shell` unless shell
effects are required. Details: `reference/security.md`.

## References (load when needed)

| File | When |
|------|------|
| `reference/install-macos.md` | Build/install `any` + anyrt; launchd |
| `reference/install-linux.md` | Hetzner/Linux; systemd; dedicated user |
| `reference/multi-device-and-sync.md` | Mnemonic restore; LAN; iroh; self-hosted nodes |
| `reference/models.md` | LLM tiers, providers, smoke tests |
| `reference/agents-and-teams.md` | New agent overlays; team spaces; multi-serve |
| `reference/triggers.md` | Cron / once / event triggers |
| `reference/connectors.md` | Shipped connectors + writing a new one |
| `reference/http-api.md` | Verified `/v1` curls |
| `reference/ui-and-observability.md` | `/ui`, any-tui, `trace follow`, desktop any-ui |
| `reference/debugging.md` | `trace` / `replay` / `drift`; common failures |
| `reference/upgrades-and-backup.md` | Pins, backup, NDJSON export |
| `reference/security.md` | Trust model and isolation |
| `reference/extensions.md` | ACP / host routing / approvals (design only) |
| `reference/sources.md` | URLs + commits/dates read for this skill |

Scripts: `scripts/any-health.sh`, `agent-ready.sh`, `chat.sh`, `set-tier.sh`,
`export-ndjson.sh`.

## Mental model

| Term | Meaning |
|------|---------|
| `any` | Local DB server + CLI; default listen `127.0.0.1:2046` |
| `anyrt` | Agent runtime binary from anybao; client of `any` |
| bao space | Derived working space (`agent.space = "bao"`): chat, memory, config, triggers |
| Overlay | Repo space of programs/skills; `[overlays]` aliases (usually `agent`, `connectors`) |
| Serve | `anyrt serve`: one process watches one working space; elects with other devices |
| Trigger | `agent_triggers` record: `cron` / `once` / `event` |
| Subagent | In-process quiet `toolcaller` child (`subagent@v1`), same space |
| Team HQ | Convention: one `any` space per team + one serve (or shared rules space) |

**One agent per `any` server.** Two `anyrt serve` processes against the same
`any` instance share device identity and both answer chat. For a second agent
on one machine, run a second `any` (separate `--data-dir` and `--addr`) plus
its own `anyrt serve`. Cross-device: one active bao per account (election);
standby devices still fire device-pinned triggers.

Org catalog (Anytype MCP / `anytype-agents`) can describe intent; this skill
applies into `any`/`anyrt`. Editing Anytype does not push into anyrt.

## Resolve addresses

```bash
# Host: Mac / Linux — discover any
ANY_ADDR="${ANY_ADDR:-http://127.0.0.1:2046}"
# Prefer the running server's recorded addr when using the CLI without --addr
any status          # GET /v1/health
any auth status
./scripts/any-health.sh   # from this skill
```

```bash
# Host: Mac / Linux — anyrt (from anybao checkout)
ANYRT="${ANYRT:-./runtime/target/release/anyrt}"
"$ANYRT" --help
# anybao.toml addr must match ANY_ADDR (official quickstart uses :2046)
```

## Core workflow

### 1. Bootstrap a host

Mac: `reference/install-macos.md`. Linux/Hetzner: `reference/install-linux.md`.

```bash
# Host: Mac / Linux
git clone https://github.com/anyproto/any && cd any && make build
export ANY_DATA_DIR="${ANY_DATA_DIR:-$HOME/.any}"
./bin/any init          # prints mnemonic ONCE — store offline; never commit
./bin/any run           # LISTENING 127.0.0.1:2046
```

```bash
# Host: Mac / Linux — second shell
any auth status
git clone https://github.com/anyproto/anybao && cd anybao
# nix develop   # or: brew install python@3.14 && UV_PYTHON=python3.14
# Default `python3` on many Macs is 3.12; anybao requires >=3.14
uv sync && make kernel && make runtime
# .connectors.env next to anybao.toml (gitignored):
# llm.key.anthropic=sk-ant-…   # workspace-scoped Anthropic key
# anybao.toml addr must match any listen (default http://127.0.0.1:2046)
./runtime/target/release/anyrt serve
# wait for: wait set clear — agent ready
```

Check: `./scripts/agent-ready.sh` and one chat turn (`reference/http-api.md`).

### 2. Talk to the agent

Space and chat ids are in the `anyrt serving space=… chat=…` log line.
To **follow** live work: browser `$ANY_ADDR/ui`, or **any-tui**, or
`anyrt trace follow` — see `reference/ui-and-observability.md`.

```bash
# Host: Mac / Linux — TUI (override any-tui's stale :7001 default)
any-tui --api "${ANY_ADDR:-http://127.0.0.1:2046}/v1"
# or web debug harness:
open "${ANY_ADDR:-http://127.0.0.1:2046}/ui"
```

```bash
# Host: Mac / Linux — CLI / scripts
any chat send <bao-space-id> <chat-id> --text "hi, what can you do?"
# read via HTTP query (no `any chat list` in current CLI)
curl -s -X POST "$ANY_ADDR/v1/spaces/<space>/query" -H 'Content-Type: application/json' \
  -d '{"objectId":"<chat>","dataset":"chat_messages","sort":["-createdAt"],"limit":5}' | jq
# or: ./scripts/chat.sh <space> <chat> "hi"
```

### 3. Model tiers

Mechanism: `docs/skill-bao-config.md` (HTTP modify on `agent_config`) or
guest `cfg.set("llm.tier.<tier>", {…})`. Full shapes: `reference/models.md`.

```bash
# Host: Mac / Linux
./scripts/set-tier.sh codegen '{"provider":"anthropic","model":"claude-sonnet-5","base_url":"https://api.anthropic.com","api_key_ref":"llm.key.anthropic"}'
```

### 4. Custom agent code

Copy `repos/_agent`, edit skills/programs per `repos/CLAUDE.md`, deploy:

```bash
# Host: Mac / Linux
REPO=$(curl -s -X POST "$ANY_ADDR/v1/spaces" -H 'Content-Type: application/json' \
  -d '{"name":"_agentrepo"}' | jq -r .id)
./runtime/target/release/anyrt deploy --source repos/_agent --target "$REPO"
# set [overlays] agent = "<REPO>" in anybao.toml (owned space: no invite)
```

Running serve picks up deploys on the next conversation. Restart only after
binary/kernel changes. Details: `reference/agents-and-teams.md`.

### 5. Teams, triggers, connectors

- Teams / multi-agent: `reference/agents-and-teams.md`
- Schedules: `reference/triggers.md`
- Connectors: `reference/connectors.md`

### 6. Debug / follow a run

```bash
# Host: Mac / Linux — live effects as they land
anyrt trace follow --addr "$ANY_ADDR" --program toolcaller
anyrt trace ls --addr "$ANY_ADDR" --program toolcaller
anyrt trace show --addr "$ANY_ADDR" run_<id> --stats
anyrt replay run_<id>
anyrt drift
```

See `reference/debugging.md` and `reference/ui-and-observability.md`.

## Workflow checklist

1. Resolve `ANY_ADDR` / anyrt `addr` (never hard-code blindly)
2. `any-health.sh` → account signed in
3. `anyrt serve` → `agent-ready.sh`
4. Chat smoke test
5. Configure tiers / overlays / triggers as asked
6. On failure: `debugging.md`; mark anything unrun as UNVERIFIED

## Common recipes

- **Fresh Mac laptop:** `install-macos.md` → chat smoke → optional launchd
- **Hetzner agent host:** `install-linux.md` (dedicated user + systemd)
- **Second device:** mnemonic restore (`init --mnemonic-stdin`); never copy `wallet.key`
- **OpenRouter / Ollama tier:** `models.md`
- **Cron every 4h:** `triggers.md`
- **GitHub connector:** `.connectors.env` + `connectors.md`
- **Export spaces:** `./scripts/export-ndjson.sh`
- **Watch chat / bao status:** `/ui` or any-tui (`ui-and-observability.md`)
- **Watch tool/LLM effects live:** `anyrt trace follow --program toolcaller`
