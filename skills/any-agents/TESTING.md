# TESTING.md — any-agents skill

Date: **2026-11-08**. Authoring machine: macOS (Darwin). Toolchain:
`curl`, `jq`, `make`, `go`, `rustc`, `uv`, Homebrew `python@3.14`.

Live smoke root: `/tmp/any-agents-smoke` (`any` + `anybao` checkouts,
`ANY_DATA_DIR=…/data`).

## What was verified (live + sources)

| Item | Result |
|------|--------|
| Default `any` listen port | **2046** |
| anybao README / anybao.toml comment | Still mention **7001** — stale; skill uses 2046 + discovery |
| Desktop embedded any | Default **31330** (`ANY_DESKTOP_PORT`) — separate from CLI `any run` |
| `any` build / init / run | `v0.3.8-nightly.20261107.1` @`0b73c01`; `LISTENING 127.0.0.1:2046` |
| `/v1/health` | `{status, version, startedAt, networkId, account, bootstrapping, crdtVersion}` |
| `/v1/auth` | `{authorized, accountId, mode, capabilities, accounts[]}` |
| `/v1/account` | `{id, techSpaceId}` — **no** `metadata.name` on this build |
| CLI `--addr` | **`host:port` only**. Passing `http://…` yields `http://http//…` dial errors |
| `any chat list` / `any query` | **Do not exist**. Reads = HTTP `…/query` on `chat_messages` or `query-subscribe` |
| `scripts/any-health.sh` | OK against live :2046 |
| `scripts/chat.sh` | Send + recent messages OK |
| `scripts/set-tier.sh` | Upserted `llm.tier.codegen`; `rejections: null` |
| `scripts/export-ndjson.sh` | OK earlier in session |
| Python for anybao | **≥3.14** required. Host default `python3` was 3.12 (conda). Fix: `brew install python@3.14`; `uv sync` linked `.venv` → `/usr/local/opt/python@3.14/…` |
| `anyrt` build | `uv sync` + `make kernel` + `make runtime` → **0.11.1** |
| `anyrt serve` | Boot ~8s; log `anyrt serving space=… chat=… control=127.0.0.1:7010` then **`wait set clear — agent ready`** |
| Ready phrase drift | Runtime emits `wait set clear — agent ready`. README / some docs still say `overlays synced — agent ready` |
| Control `GET /status` | `{beatSec, envelope:{type:"bao.status", data:{identity, role, state, winner}}}`. Ready ⇒ `role == "active"` |
| Control `GET /election` | `{active, app:"bao", enabled, peerId, winner}` |
| `scripts/agent-ready.sh` | Fixed in 1.1.0 to treat `envelope.data.role == "active"` as ready (pre-fix timed out) |
| Chat without LLM key | Conversation starts; agent replies asking to choose a provider / needs a model key. Boot warns `no anthropic key` |
| Overlay guest warnings | Boot may `WARN credentials: cannot read programs … 404` until overlay sync; serve can still become ready |
| Full LLM reply (Anthropic/OpenRouter) | **UNVERIFIED** this session (no key supplied) |
| Second device / second agent / cron | **UNVERIFIED** this session |
| Ollama / llama.cpp / Grok tiers | Example JSON in `models.md` still **UNVERIFIED** live |
| Embedded `/ui` | `GET http://127.0.0.1:2046/ui` → **200** HTML debug harness |
| any-tui | Built **0.6.0** (`cargo build --release`); launched with `--api http://127.0.0.1:2046/v1 --agent-space bao`. Default API in binary help is still **:7001** — must override |
| `anyrt trace follow` | Subcommand present (`--program`, `--addr` URL, `--space`); live effect stream |
| MCP client (ADR-032) | Docs + `mcp@v1` + `browser` skill present in smoke anybao. Config = `mcp.server.*` + `mcp.key.*`; **http only**, no stdio. Live call against a real MCP server **UNVERIFIED** this session |
| Teams / harness | Teams = multi-serve + spaces (documented). Subagent = in-process only. No Claude Code/Pi harness; ACP design-only (`extensions.md`) |

## Open questions — answers

1. **Default any port:** **2046**. anybao README’s 7001 is outdated.
2. **Ready signal:** Prefer log `wait set clear — agent ready` or control
   `/status` with `envelope.data.role == "active"`.
3. **Several agents one serve:** **No** — one serve per any server.
4. **Python:** anybao needs **≥3.14**; on Mac use Homebrew `python@3.14`
   / `UV_PYTHON=python3.14`.
5. **CLI addr:** Always `host:port` for `--addr`; full URL only for HTTP/`ANY_ADDR`.
6. **Follow UI:** `/ui` (browser), any-tui (terminal; override `--api`), or
   `anyrt trace follow` for internals. See `reference/ui-and-observability.md`.

## Prompt vs sources (follow sources)

- Prompt / anybao README 7001 → skill uses discovery + 2046.
- Prompt / README `any chat list` → HTTP query / `query-subscribe`.
- README ready phrase `overlays synced…` → runtime `wait set clear…`.
- any-tui / some READMEs still default API **:7001** → always pass
  `--api http://127.0.0.1:2046/v1` (or your listen).
- Full acceptance (paid model reply, second device, two tiers, cron)
  still needs a model key + extra hosts.

## Suggested further validation

```bash
# Host: Mac — with .connectors.env llm.key.anthropic=…
./scripts/agent-ready.sh
any-tui --api http://127.0.0.1:2046/v1   # or open http://127.0.0.1:2046/ui
anyrt trace follow --addr http://127.0.0.1:2046 --program toolcaller
./scripts/chat.sh "$SP" "$CHAT" "ping"
# expect an agent-tagged model reply, not only the “need a language model” stub
# second ANY_DATA_DIR + mnemonic-stdin
# second any --addr 127.0.0.1:2047 + second anyrt for team agent
# cron trigger per triggers.md; wait for lastRunAt
```

Record outcomes back into this file when run.
