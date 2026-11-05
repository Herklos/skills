# Osaurus CLI map

Binary (prefer PATH, else app Helpers):

```bash
cli="$(command -v osaurus || true)"
[ -x "$cli" ] || cli="/Applications/Osaurus.app/Contents/Helpers/osaurus"
```

Docs: https://docs.osaurus.ai/cli

## Server

| Command | Purpose |
|---------|---------|
| `osaurus serve [--port N] [--expose] [--yes] [--supervise]` | Start local server (default `127.0.0.1:1337`) |
| `osaurus stop` | Stop server |
| `osaurus status` | `running (port N)` or `stopped` |
| `osaurus doctor [--json] [--redact]` | Install / version / storage diagnostics |
| `osaurus ui` | Open menu-bar popover |
| `osaurus version` | App/CLI version |

`OSU_PORT` overrides the default port. `--expose` is LAN bind (confirm with `--yes`).

## Models

| Command | Purpose |
|---------|---------|
| `osaurus list` | Downloaded model ids |
| `osaurus show <id>` | Metadata |
| `osaurus pull <hf-id>` | Download MLX model |
| `osaurus run <id>` | Interactive chat REPL |
| `osaurus bench …` | TTFT / prefill / decode benchmark |

Default models dir: `~/MLXModels` (`OSU_MODELS_DIR`). CLI pull without configured dir may use `~/.osaurus/models/…`.

## Declarative config

| Command | Purpose |
|---------|---------|
| `osaurus config export [-o file] [--format yaml\|json]` | Current state (no secrets) |
| `osaurus config schema [--format yaml\|json]` | Annotated schema / JSON Schema |
| `osaurus config plan <file> [--prune]` | Dry-run diff |
| `osaurus config apply <file> [--prune] [--yes]` | Apply desired state |

Access key: `--access-key` or `OSAURUS_API_KEY`. See `config-document.md`.

## Bundles

| Command | Purpose |
|---------|---------|
| `osaurus import validate --from <dir>` | Check bundle |
| `osaurus import install --from <dir> [kind] [names…] [--yes]` | Install |
| `osaurus import update --from <dir> …` | Update to bundle version |
| `osaurus import remove --bundle <id> …` | Remove what that bundle installed |
| `osaurus import list [--bundle <id>] [--json]` | Receipts + queued |

See `bundles.md`.

## Tools / plugins

| Command | Purpose |
|---------|---------|
| `osaurus tools list\|search\|install\|uninstall\|outdated\|upgrade\|rollback\|verify\|reload` | Plugin lifecycle |
| `osaurus tools create <name> [--language swift\|rust]` | Scaffold |
| `osaurus tools package\|dev …` | Package / hot reload |
| `osaurus manifest extract\|validate …` | Plugin manifest helpers |
| `osaurus bundle load <file.mcpb>` | Load MCP Bundle (`.mcpb`, not Osaurus Bundle) |

## MCP / coord

| Command | Purpose |
|---------|---------|
| `osaurus mcp [--access-key] [--tools PATTERNS]` | Stdio MCP proxy to local server |
| `osaurus coord init\|status\|…` | Multi-instance coordination foundation |

## On-disk paths

| What | Path |
|------|------|
| App data | `~/.osaurus/` |
| Skills | `~/.osaurus/skills/<slug>/` |
| Config JSON | `~/.osaurus/config/*.json` |
| Harness runtimes file | `~/.osaurus/config/harness-runtimes.json` |
| Import queue / results | `~/.osaurus/import/pending/`, `…/results/`, `installed.json` |
| Memory / chat / methods | under `~/.osaurus/` (see docs Configuration → Where things live) |
