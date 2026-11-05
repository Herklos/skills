# Osaurus Bundles

Docs: https://docs.osaurus.ai/bundles

A **bundle** is a folder with `osaurus-bundle.json` that provisions agents,
skills, MCP servers, harness runtimes, and a short allow-list of server
settings via `osaurus import`. Distinct from encrypted `.osaurus-agent` export
files and from `.mcpb` MCP bundles (`osaurus bundle load`).

Requires Osaurus ≥ 0.25.26 for full schema checks.

## Layout

```text
my-bundle/
├── osaurus-bundle.json
├── agents/
│   └── research.json
├── skills/
│   └── my-skill/
│       └── SKILL.md
├── install.sh          # your script; Osaurus does not read it
└── uninstall.sh
```

## Manifest keys

| Key | Required | Meaning |
|-----|----------|---------|
| `format` / `format_version` | yes | `"osaurus.bundle"` / `1` |
| `id` | yes | Reverse-DNS ownership key (never change) |
| `name` / `version` | yes | Display + semver |
| `publisher` | no | `{ name, url }` |
| `min_osaurus_version` | no | CLI refuses older apps |
| `skills` | no | `{ name, path }` |
| `mcp_servers` | no | Inline MCP entries |
| `harness_runtimes` | no | Inline runtime entries |
| `agents` | no | `{ path }` to agent JSON |
| `settings` | no | `require_local_access_key`, `allowed_origins` |

## Agent JSON shapes

1. Agent template envelope (`"format": "osaurus.template"`)
2. Bare agent object
3. Config document with exactly one agent: `{ "agents": [ {…} ] }`

Bare example:

```json
{
  "name": "Support Desk",
  "description": "Triages tickets.",
  "system_prompt": "You are…",
  "model": "foundation",
  "capabilities": { "tools_enabled": true, "memory_enabled": true },
  "skills": ["triage-ticket"],
  "tools": { "mode": "manual", "enabled": ["get_current_time"] },
  "mcp_servers": { "enabled": ["GitHub"] },
  "sandbox": { "enabled": true, "network_enabled": true },
  "subagents": { "enabled": true, "agents": ["Release Checker"] },
  "orchestrator_spawnable": false,
  "runtime": "builtin",
  "working_folder": "~/Documents/Acme"
}
```

`runtime` here is builtin or a harness runtime **name** (Claude Code / Pi), not
Anytype Runtime kind.

## CLI

```bash
osaurus import validate --from <bundle> [--json]
osaurus import install  --from <bundle> [agent|skill|mcp|runtime|setting] [names…] [--yes] [--json]
osaurus import update   --from <bundle> … [--yes] [--json]
osaurus import remove   --bundle <id> … [--json]
osaurus import list     [--bundle <id>] [--json]
```

- Never run as root; use the logged-in user.
- If Osaurus is stopped, import queues under `~/.osaurus/import/pending/` and
  applies on next open.
- High-risk (every MCP/runtime, powerful agents, loosening access key) needs `--yes`.
- Exit `0` applied/queued, `1` failed, `3` needs in-app finish (secret/sign-in/model/folder).

## Secrets

Store in login Keychain **after** Osaurus is in `/Applications`:

```bash
printf '%s\n%s\n' "$TOKEN" "$TOKEN" \
  | security add-generic-password -U \
      -s com.example.bundle -a tickets-token \
      -T /Applications/Osaurus.app -w
```

Bundle references: `keychain:SERVICE/ACCOUNT`. `env:` refs are refused in bundles.
`-T /Applications/Osaurus.app` is required or imports report `pending_secrets`.

## Skills

Agent Skills folders (`SKILL.md` + optional `references/` / `assets/`). Install
to `~/.osaurus/skills/<slug>/`. Prefix product names to avoid collisions with
built-ins/plugins/user skills.

## Not in a bundle

| Instead | How |
|---------|-----|
| Plugins | `osaurus tools install <id> --consent` in installer |
| Models | `osaurus pull …` or template `strictness: preferred` |
| Raw secrets | Keychain only |
