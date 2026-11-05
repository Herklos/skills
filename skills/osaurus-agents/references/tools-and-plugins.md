# Tools and plugins

Docs: https://docs.osaurus.ai/tools · Plugin authoring: https://docs.osaurus.ai/plugin-authoring · Tool contract: https://docs.osaurus.ai/tool-contract · Registry: https://github.com/osaurus-ai/osaurus-tools

Osaurus is both an MCP **server** and **client**. Agents see built-in tools, native Swift/Rust plugins, and remote MCP provider tools in one surface.

## CLI (`osaurus tools`)

| Command | Purpose |
|---------|---------|
| `tools list` | Installed plugins |
| `tools search <query>` | Search registry |
| `tools install <id\|url\|path>` | Registry id, URL, or local dir with `osaurus-plugin.json` / `manifest.json` / `plugin.json` |
| `tools uninstall <id>` | Remove |
| `tools outdated` | Newer registry versions |
| `tools upgrade` | Upgrade installed |
| `tools rollback <id>` | Previous version |
| `tools verify` | Dylib integrity (after suspicious sync/restore) |
| `tools reload` | Rescan without app restart |
| `tools create <Name> [--language swift\|rust]` | Scaffold Package/Cargo + `osaurus-plugin.json` |
| `tools package <plugin_id> <version> [dylib]` | Zip for distribution |
| `tools dev <plugin_id> [--web-proxy url]` | Hot reload while editing |

Install location: `~/.osaurus/Tools/<plugin_id>/<version>/`.

Manifest helpers:

```bash
osaurus manifest extract ./MyPlugin.dylib
osaurus manifest validate ./osaurus-plugin.json
```

MCP Bundle (packaged MCP server hostable by Osaurus), **not** an Osaurus Bundle:

```bash
osaurus bundle load ./my-server.mcpb --name "Display Name"
```

Osaurus Bundles use `osaurus import` (`bundles.md`).

## Settings UI tabs (Tools & MCP)

| Tab | Contents |
|-----|----------|
| **Services** | Connected MCP services, Add Service, Directory catalog |
| **All Tools** | Every tool by source, permission policy, Auto-Allow All Tool Calls |
| **Plugins** | Installed + available native plugins from registry |

No global Disable Tools switch. Availability is per agent under **Abilities → Overview / Tools**.

## Built-in vs registry

Built-in capabilities (not registry plugins): web search, browser automation, `get_current_time`, `calculate`, Computer Use, Apple Apps (Calendar, Reminders, Contacts, Notes, Mail, Messages, Maps, Music, Shortcuts). Apple app tools are off by default; enable per agent via `capabilities.apple_apps` or Abilities → Tools.

Former Apple app plugins (`osaurus.calendar`, …) are superseded; installed copies are never loaded. Agents that named old plugin tools were migrated to built-in names.

Orchestrator management tools (read-only agent definition):

- `osaurus_inspect` — state: agents, models, providers, MCP, plugins, schedules, watchers, skills, knowledge, channels, memory, Sandbox, settings, config schema
- `osaurus_config` — approval-gated desired-state apply (can create specialist + activate for delegation in one turn)
- `osaurus_help` — bundled `guide-*` topics

Sensitive controls outside declarative schema stay UI-only (delegation budgets ceilings in some paths, identity/pairing keys, privacy, blanket tool approval). Same desired-state model as `osaurus config` and loopback `/admin/config/*`.

## Agent tool modes

| Mode | Behavior |
|------|----------|
| **Auto** (default) | Small always-loaded set; mid-session `capabilities_discover` + `capabilities_load` pull more from enabled methods/tools/skills |
| **Manual** | Every enabled capability sent each turn (larger prompts; skills unused in Manual) |

Config document: omit manual list for Auto; set `agents[].tools.mode: manual` + exact `enabled` for Manual. Prefer Auto unless you need a fixed allow-list. Prefer exact `tools.enabled` names over whole MCP servers when scoping.

`calculate` and `get_current_time` are available to Orchestrator, custom agents, and spawned workers.

## Permissions

| Policy | Behavior |
|--------|----------|
| `ask` (default) | Prompt before each execution |
| `auto` | Run when requirements are met (skips approval card) |
| `deny` | Block |

**Org default:** set **every** `tools.policies.<name>` to **`auto`**, and set
`delegation.permission_defaults` kinds to **`always_allow`** (spawn,
spawn_workspace, browser_use, computer_use, applescript, image, video). Apply
is high-risk (`--yes`). Rebuild the policy map from a fresh `config export`
when new tools appear.

Some built-ins **always ask** even when policy is `auto` (send mail/messages;
delete calendar/reminder events; some Stripe send/write tools). macOS
Automation / Accessibility grants: System Settings → Privacy & Security; UI
offers one-click grant buttons.


## Remote MCP providers

Add under **Tools & MCP → Services** (catalog or Custom Server). Fields: name (also tool-name prefix), URL or stdio command, auth (none / bearer / OAuth; secrets in Keychain), auto-connect, streaming, discovery timeout (default 20s), tool-call timeout (default 45s).

- Remote tools are **namespaced** as `provider_toolname`
- Appear in the unified All Tools list and via `osaurus mcp`
- Declarative: `mcp_servers` in config document (`config-document.md`) with `token_ref` / `secret_env_refs` as `env:` or `keychain:`

Services header: reconnect all, test connections, copy diagnostics.

## MCP stdio proxy for clients

```bash
osaurus mcp [--access-key KEY] [--tools "osaurus_status,osaurus_*,…"]
```

Without `--tools`, every tool is proxied (often 170+). Empty `--tools ""` admits nothing. Access key when local admin key or network exposure requires it (`OSAURUS_MCP_ACCESS_KEY` preferred).

HTTP (running server):

| Endpoint | Method |
|----------|--------|
| `/mcp/health` | GET |
| `/mcp/tools` | GET |
| `/mcp/call` | POST |

Also OpenAI function-calling via `http://127.0.0.1:1337/v1`.

## Plugin ABI (native)

Append-only host API. Older plugins keep loading on newer hosts.

| ABI | Adds |
|-----|------|
| v1 | Tools only |
| v2 | Full host: HTTP routes, SQLite, agent tasks, inference; opt-in `capabilities.tools\|routes\|config\|web` |
| v3 | Streaming cancel by `stream_id` |
| v4 | `get_active_agent_id()` |
| v5 | `log_structured()` → Insights |
| v6 | Host `free_string()` |

Plugins check `host->version` before newer callbacks. Authoring: `osaurus tools create` then https://docs.osaurus.ai/plugin-authoring.

## Tool contract

Every tool (built-in, folder, sandbox, plugin, MCP) returns a JSON success or failure envelope so the UI can tell "tool succeeded" from "model used the tool wrong". See https://docs.osaurus.ai/tool-contract.

## Config document overlap

| Concern | Where |
|---------|--------|
| Exact tool allow-list | `agents[].tools` |
| Plugin enable for agent | `agents[].plugins.enabled` |
| MCP enable for agent | `agents[].mcp_servers.enabled` |
| MCP server definitions | top-level `mcp_servers` |
| Plugin enablement (global-ish) | top-level `plugins` |
| Install / upgrade binaries | **CLI only** (`osaurus tools …`), not the config document |

High-risk on `config apply`: new or stdio MCP endpoints, automatic tool policies. Confirm with user + `--yes`.

## Troubleshooting (tools)

| Symptom | Check |
|---------|--------|
| Tool missing in MCP client | `tools list`, `status`, restart client; narrow `--tools` filter |
| Permission denied | Tools UI required permissions; System Settings Automation/Accessibility |
| Execution fails | Menu bar → View Logs; reinstall `uninstall` + `install` |
| Agent can't see tool | Agent Abilities → Tools; Auto vs Manual; MCP secret pending; compare `config export` |
| Suspicious restore | `osaurus tools verify` |

## Agent workflow checklist

1. `osaurus tools search` / Settings → Plugins for what exists
2. `osaurus tools install <id>` (or declare MCP in config / bundle)
3. Scope agent with Auto or Manual `tools.enabled` / `plugins` / `mcp_servers`
4. `config plan` → `apply` (or bundle `import`) with `--yes` only when high-risk
5. For clients: `osaurus mcp --tools "…"` with a tight pattern
