# Osaurus CLI map

Docs: https://docs.osaurus.ai/cli · Windows variant: https://docs.osaurus.ai/windows/cli

## Resolve binary

```bash
cli="$(command -v osaurus || true)"
[ -x "$cli" ] || cli="/Applications/Osaurus.app/Contents/Helpers/osaurus"
[ -x "$cli" ] || cli="/Applications/Osaurus.app/Contents/MacOS/osaurus"
"$cli" version
```

Homebrew cask owns the PATH link. DMG install: **Settings → Server → Overview → Command Line Tool**, or:

```bash
bin="/usr/local/bin"
[ -d "$bin" ] && [ -w "$bin" ] || { bin="$HOME/.local/bin"; mkdir -p "$bin"; }
ln -sf "$cli" "$bin/osaurus"
# if ~/.local/bin: ensure it is on PATH
```

Do not write into `$(brew --prefix)/bin` for a DMG install.

## Server lifecycle

| Command | Purpose |
|---------|---------|
| `osaurus serve [--port N] [--expose] [--yes\|-y] [--supervise] [--interval N]` | Start server (default localhost:1337). `--expose` = LAN bind (prompt unless `--yes`). `--supervise` = keep-alive loop (probe every `--interval` sec, default 15) |
| `osaurus stop` | Stop server |
| `osaurus status` | `running (port N)` or `stopped` |
| `osaurus doctor [--port N] [--json] [--redact] [--verify-signatures]` | CLI/app skew, duplicate bundles, startup, model storage. Exit 0 usable, 1 broken |
| `osaurus ui` | Open menu-bar popover (launches app if needed) |
| `osaurus version` / `-v` / `--version` | Version |

`OSU_PORT` overrides the default port globally.

Plain `serve` is one-shot (starts app/server and exits). Pair `--supervise` with a LaunchAgent for quit/crash/reboot resilience:

```xml
<!-- ~/Library/LaunchAgents/ai.osaurus.serve.plist -->
<dict>
  <key>Label</key><string>ai.osaurus.serve</string>
  <key>ProgramArguments</key>
  <array>
    <string>/opt/homebrew/bin/osaurus</string>
    <string>serve</string><string>--supervise</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
</dict>
```

## Models

| Command | Purpose |
|---------|---------|
| `osaurus list` | Downloaded model ids (one per line) |
| `osaurus show <id>` | Architecture, params, quant, context, size, path |
| `osaurus pull <hf-id>` | Download MLX model (resumable). Uses shared models dir; else `~/.osaurus/models/<org>/<name>` (does not read `OSU_MODELS_DIR`) |
| `osaurus run <id>` | Interactive chat REPL (`exit` / Ctrl+C) |
| `osaurus bench [--model] [--prompt-tokens] [--max-tokens] [--runs] [--json path] [--port]` | TTFT / prefill / decode vs running server |
| `osaurus bench --tune-prefill [--model] [--candidates …]` | Persist best prefill step size for a model |

Default app models dir: `~/MLXModels` (`OSU_MODELS_DIR`). Requires running server for `bench`.

## Declarative config

| Command | Purpose |
|---------|---------|
| `osaurus config export [-o file] [--format yaml\|json]` | Current state; **secrets never exported** |
| `osaurus config schema [--format yaml\|json]` | Annotated YAML reference or JSON Schema |
| `osaurus config plan <file> [--prune]` | Dry-run diff (YAML or JSON input) |
| `osaurus config apply <file> [--prune] [--yes\|-y]` | Apply; `--yes` for high-risk |

Targets `127.0.0.1` and starts the local server if needed. Access key: `--access-key` or `OSAURUS_API_KEY` (also `OSAURUS_ACCESS_KEY`, `OSAURUS_MCP_ACCESS_KEY`) when **Require Access Key for Local Admin Routes** is on. Cap 512 KiB. See `config-document.md`.

Apply exit: `0` converged, `1` failed/cancelled, `3` applied but interactive step remains.

## Bundles (`osaurus import`)

| Command | Purpose |
|---------|---------|
| `import validate --from <dir> [--json]` | Check without installing |
| `import install --from <dir> [agent\|skill\|mcp\|runtime\|setting] [names…] [--yes] [--json]` | Install (agent pulls its skills/MCP/runtime from same bundle) |
| `import update --from <dir> …` | Update to bundle version (user-changed settings left alone) |
| `import remove --bundle <id> …` | Remove what that bundle installed (settings stay) |
| `import list [--bundle <id>] [--json]` | Receipts + queued |

Never launches Osaurus; queues under `~/.osaurus/import/` if app stopped. Never run as root. See `bundles.md`.

## Tools / plugins

| Command | Purpose |
|---------|---------|
| `tools list` | Installed plugins |
| `tools search <query>` | Registry search |
| `tools install <plugin_id\|url\|path>` | Registry, URL, or local dir (`osaurus-plugin.json` / `manifest.json` / `plugin.json`) |
| `tools uninstall <name>` | Remove |
| `tools outdated` / `upgrade` | Check / upgrade |
| `tools rollback <plugin_id>` | Previous version |
| `tools verify` | Dylib integrity |
| `tools reload` | Rescan without restart |
| `tools create <name> [--language swift\|rust]` | Scaffold Package/Cargo + manifest |
| `tools package <plugin_id> <version> [dylib]` | Zip for distribution |
| `tools dev <plugin_id> [--web-proxy url]` | Hot reload |
| `manifest extract <dylib>` | Embedded manifest JSON |
| `manifest validate <manifest.json>` | Validate before package |
| `bundle load <path.mcpb> [--name "…"]` | Load **MCP Bundle** (`.mcpb`), not Osaurus Bundle |

Full playbook: `tools-and-plugins.md`. Docs: https://docs.osaurus.ai/tools

## MCP stdio proxy

```bash
osaurus mcp [--access-key KEY] [--tools PATTERNS]
```

Proxies MCP over stdio to the local server (auto-launches without main window). Loopback trust when local-only; with network exposure or local admin key required, pass key / `OSAURUS_MCP_ACCESS_KEY` (also `OSAURUS_ACCESS_KEY`, `OSAURUS_API_KEY`, or `Bearer …` in `OSAURUS_MCP_AUTHORIZATION`).

`--tools` limits exposure: comma-separated names, optional `*` prefix match. Empty `--tools ""` admits nothing. Without it, every tool is proxied (often 170+).

Client example:

```json
{ "mcpServers": { "osaurus": { "command": "osaurus", "args": ["mcp"] } } }
```

## Coord (multi-instance foundation)

```bash
osaurus coord init
osaurus coord status [--json]
osaurus coord feature-flags list|get|set
osaurus coord lock list|acquire|release|reap
```

`--root PATH` for non-default coordinator root. Later orchestration subcommands (`preflight`, `heartbeat`, `lane`, …) may be registered but unsupported in current builds.

## Environment variables

| Variable | Meaning | Default |
|----------|---------|---------|
| `OSU_PORT` | Server port | `1337` |
| `OSU_MODELS_DIR` | MLX models directory (app/serve) | `~/MLXModels` |
| `OSAURUS_API_KEY` | Access key for `config` / `import` / `mcp` | none |
| `OSAURUS_ACCESS_KEY` | Also accepted | none |
| `OSAURUS_MCP_ACCESS_KEY` | MCP preferred | none |
| `OSAURUS_MCP_AUTHORIZATION` | `Bearer …` for MCP | none |

## On-disk paths

| What | Path | Override |
|------|------|----------|
| MLX models | `~/MLXModels/` | `OSU_MODELS_DIR` |
| App data root | `~/.osaurus/` | none |
| Plugin install | `~/.osaurus/Tools/<id>/<ver>/` | none |
| Voice models | `~/Library/Application Support/FluidAudio/Models/` | none |
| Memory | `~/.osaurus/memory/memory.sqlite` + `vectura/{agent}/` | none |
| Chat history | `~/.osaurus/chat-history/…` | none |
| Methods / tool index | `~/.osaurus/methods/`, `tool-index/` | none |
| Schedules / watchers | `~/.osaurus/schedules/{uuid}.json`, `watchers/` | none |
| Skills | `~/.osaurus/skills/{name}/SKILL.md` | none |
| Themes | `~/.osaurus/themes/{uuid}.json` | none |
| Sandbox | `~/.osaurus/container/`, `sandbox-plugins/` | none |
| Config JSON | `~/.osaurus/config/*.json` (incl. `memory.json`, `sandbox.json`, `harness-runtimes.json`) | edit carefully |
| Import queue / results | `~/.osaurus/import/pending/`, `results/`, `installed.json` | none |
| Harness scratch | `~/.osaurus/harness/<chat id>/` | none |
| Encryption key (opt-in) | Keychain `com.osaurus.storage` | Storage docs |
| Identity master | iCloud Keychain | Identity docs |

## Related HTTP

Server speaks OpenAI / Anthropic / Ollama-style prefixes (`/v1`, `/api`, `/v1/api`). Declarative config also on loopback `/admin/config/*`. Docs: https://docs.osaurus.ai/api
