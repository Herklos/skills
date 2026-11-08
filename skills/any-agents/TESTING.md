# TESTING.md — any-agents skill

Date: **2026-11-08**. Authoring machine: macOS (Darwin), toolchain present
(`curl`, `jq`, `make`, `go`, `rustc`, `uv`). **Full end-to-end
`any` + `anyrt serve` + chat was not run in this session** (no local
checkout bootstrapped here). Commands and shapes below come from
upstream sources at the commits in `reference/sources.md`, cross-checked
across README / docs / ADRs / official anyrt quickstart.

## What was verified (source read / cross-check)

| Item | Result |
|------|--------|
| Default `any` listen port | **2046** (`docs/05-config.md`, README `LISTENING 127.0.0.1:2046`, website anyrt quickstart `addr = "http://127.0.0.1:2046"`) |
| anybao README / anybao.toml comment | Still mention **7001** as local any — **stale vs any default**; skill prefers 2046 and env/config discovery |
| Desktop embedded any (skill-bao-config) | Default **31330** (`ANY_DESKTOP_PORT`) — separate from CLI `any run` |
| P2P / relay config | Documented in `docs/05-config.md` + `docs/30-global-p2p.md` + SDK `global-p2p.md` |
| One agent per any server | Explicit note in `website/02-quickstart/anyrt.md` |
| Trigger create HTTP | Official anyrt quickstart §5 (bundle child + modify) |
| Election / pins | ADR-015, ADR-018 |
| Connectors refs | `_connectors/README.md` |
| LLM tier shape + defaults | `llm-models.md`, `config_defaults.json`, `skill-bao-config.md` |
| Ollama / llama.cpp / Grok tiers | Declared backends; **no golden parity** for ollama-qwen3; Grok not in parity table → marked UNVERIFIED |
| Sync node minimal set | any-sync-dockercompose README service list |
| Scripts syntax | Written; `chmod +x` applied |
| Live smoke 2026-11-08 | Built `any` v0.3.8-nightly @0b73c01 under `/tmp/any-agents-smoke`; `init`+`run` on :2046; `any-health.sh` OK; space create OK; `export-ndjson.sh` OK; `catalog/general-chat/setup` OK; `chat.sh` send OK after fix; `set-tier` N/A without bao/anyrt; anyrt **not** built (host Python 3.12, anybao wants 3.14) |
| `any chat list` | **Does not exist** on live CLI (anybao README / prompt were wrong). Reads = HTTP `…/query` on `chat_messages` or `query-subscribe`. Skill + `chat.sh` corrected. |

## Open questions — answers

1. **Default any port:** **2046**. Change via `listen.addr`,
   `ANY_LISTEN_ADDR`, or `any run --addr`. anyrt `addr` must match.
   anybao README’s 7001 is outdated relative to any main + docs site.
2. **iroh / relay:** `p2p.global.relayUrls` (+ pkarr URLs); production
   relays auto-filled on embedded production network; custom nodeconf
   requires naming relays. `insecureRelay` for http://. Self-hosted
   relay **config shape verified in docs**; live self-host lab
   **UNVERIFIED** in this session.
3. **Several agents one serve:** **No** — one serve per any server;
   multiple overlays ≠ multiple chat agents. Second agent → second any
   (data-dir + port) + second serve. Subagent tool = in-process only.
4. **Triggers / split:** Create via `agent_triggers` modify; pins are
   device-specific with no auto-failover; election moves `chat-watch`
   + standing built-ins only.
5. **Ollama / llama.cpp / Grok:** Example JSON in `models.md` marked
   **UNVERIFIED** — test before production use.
6. **Minimal self-hosted sync:** coordinator + node×3 + filenode +
   consensusnode + Mongo + Redis + Garage (dockercompose). Production
   network embedded if you do not set nodeconf.

## Prompt vs sources (follow sources)

- Prompt said anybao uses 7001; **any default is 2046** — skill uses
  discovery + 2046.
- Prompt / anybao README said `any chat list`; **live CLI has no such
  command** — skill uses HTTP query / `query-subscribe`.
- Prompt folder name `reference/` (singular) — used (sibling skills use
  `references/`).
- Full acceptance (anyrt reply, second device, two tiers, second agent,
  cron) still needs anyrt build + model key on a machine with Python 3.14
  / nix.

## Suggested live validation plan

```bash
# Host: Mac
./scripts/any-health.sh          # expect fail until any runs
# build any + anyrt per install-macos.md
./scripts/any-health.sh          # up + auth
./scripts/agent-ready.sh         # after anyrt serve
./scripts/chat.sh "$SP" "$CHAT" "ping"
./scripts/set-tier.sh codegen '…' # anthropic or openrouter
# optional local ollama tier — mark verified if reply works
# second ANY_DATA_DIR + mnemonic-stdin
# second any --addr :2047 + second anyrt for team agent
# create cron trigger per triggers.md; wait for lastRunAt
./scripts/export-ndjson.sh /tmp/any-export "$SP"
```

Record outcomes back into this file when run.
