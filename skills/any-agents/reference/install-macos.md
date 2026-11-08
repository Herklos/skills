# Install on macOS

Host: **Mac**. Goal: `any` listening, account present, `anyrt serve` ready.

## Prerequisites

- Git, Go 1.26.2+, `make`, `curl`, `jq`
- For anyrt: nix (`nix develop` / `direnv allow`) **or** recent Rust + Python **≥3.14** + [`uv`](https://docs.astral.sh/uv/)
- Optional: Homebrew for toolchain packages

**Python note (verified 2026-11-08):** anybao `requires-python = ">=3.14"`.
On Mac, `python3` is often 3.12 (conda/system). Install and point uv:

```bash
# Host: Mac
brew install python@3.14
# uv discovers /usr/local/bin/python3.14; or force:
UV_PYTHON=python3.14 uv sync
```

## 1. Build and run `any`

```bash
# Host: Mac
git clone https://github.com/anyproto/any
cd any
make build                    # bin/any; includes local embedder when libs fetch OK
# if llama.cpp libs missing: make llamacpp
```

```bash
# Host: Mac
export ANY_DATA_DIR="${ANY_DATA_DIR:-$HOME/.any}"
./bin/any init                # creates data dir + account; mnemonic → stderr ONCE
./bin/any run                 # foreground; wait for LISTENING 127.0.0.1:2046
```

Override listen address if needed:

```bash
# Host: Mac
ANY_LISTEN_ADDR=127.0.0.1:7001 ./bin/any run
# or: ./bin/any run --addr 127.0.0.1:7001
# or config ~/.config/any/config.yaml → listen.addr
```

**Port note:** `any` default is **2046**. Older anybao README examples used
**7001**. Match `anyrt` `addr` to whatever `any` actually prints.

Without prior `init`, `any run` starts unauthorized until:

```bash
# Host: Mac — second terminal
any auth login                         # new account in place
# or: any auth login --mnemonic-stdin  # restore
any auth status
```

Check: `curl -fsS http://127.0.0.1:2046/v1/health | jq` and
`curl -fsS http://127.0.0.1:2046/v1/account | jq -r .id`.

## 2. Build anyrt

```bash
# Host: Mac
git clone https://github.com/anyproto/anybao
cd anybao
nix develop                   # recommended
uv sync
make kernel                   # bin/kernel.wasm (required before cargo)
make runtime                  # runtime/target/release/anyrt
# optional coding variant (shell + fs effects): make runtime-shell
export PATH="$PWD/runtime/target/release:$PATH"
```

## 3. Config and secrets

Create `anybao.toml` in the working directory (CLI flags override file):

```toml
addr = "http://127.0.0.1:2046"

[agent]
space = "bao"
name = "bao"
control_port = 7010

# Optional: pin published overlays (space ids). Committed anybao.toml
# already points at public guest keys for agent + connectors.
# [overlays]
# agent = { space = "bafy…", invite = "…" }
# connectors = { space = "bafy…", invite = "…" }
```

Secrets: gitignored `.connectors.env` **next to** `anybao.toml` (never commit):

```
llm.key.anthropic=sk-ant-…
```

Use an Anthropic key **scoped to one workspace** (Console → API keys →
choose workspace). Unscoped identity-linked keys return 400. Other
providers: `reference/models.md`. Connector keys:
`connector.key.github=…`, `connector.key.linear=…` (see
`reference/connectors.md`).

## 4. First serve

```bash
# Host: Mac
./runtime/target/release/anyrt serve
```

Watch for:

```
anyrt serving space=<id> chat=<id> control=127.0.0.1:7010
wait set clear — agent ready
```

(Older README/docs may still say `overlays synced — agent ready`; the
runtime log line is `wait set clear — agent ready`.) Without
`.connectors.env` / `llm.key.anthropic`, the agent still becomes ready
and answers that it needs a language-model key.

Record space/chat ids for `any chat` / `scripts/chat.sh`. CLI
`--addr` is `host:port` (e.g. `127.0.0.1:2046`), not a URL.

Check: `../any-agents/scripts/agent-ready.sh` (or wait on the log) then
one `any chat send …`.

## 5. launchd (optional keepalive)

UNVERIFIED against a real LaunchAgent on this machine — pattern only.
Create `~/Library/LaunchAgents/org.anyproto.any.plist` and
`org.anyproto.anyrt.plist` that run `any run` and `anyrt serve` with
`ANY_DATA_DIR`, correct `WorkingDirectory` (anybao checkout), and
`StandardOutPath`/`StandardErrorPath` under `~/Library/Logs/`. Load with
`launchctl bootstrap gui/$(id -u) …`. Prefer a dedicated macOS user for
untrusted agent code (`reference/security.md`).

## Second device on this Mac

```bash
# Host: Mac — separate data dir
export ANY_DATA_DIR="$HOME/.any-device2"
any init --mnemonic-stdin     # paste same phrase; fresh device key
any run --addr 127.0.0.1:2047
```

Never copy `wallet.key` between devices.
