# Osaurus Bundles

Docs: https://docs.osaurus.ai/bundles  
Upstream example: https://github.com/osaurus-ai/osaurus/tree/main/docs/examples/osaurus-bundle-example  
Guide: https://github.com/osaurus-ai/osaurus/blob/main/docs/OSAURUS_BUNDLES.md

A **bundle** is a folder with `osaurus-bundle.json` that provisions agents,
skills, MCP servers, harness runtimes, and a short allow-list of server
settings via `osaurus import`.

Distinct from:

| Format | Command |
|--------|---------|
| Encrypted `.osaurus-agent` (Export Bundle button) | App Import Bundle |
| `.mcpb` MCP Bundle | `osaurus bundle load` |
| Declarative config YAML | `osaurus config apply` |

Requires Osaurus ≥ **0.25.26** for full schema checks (open the app during
`validate` for strict checks).

## Layout

```text
my-bundle/
├── osaurus-bundle.json
├── agents/
│   ├── support-desk.json      # template envelope or bare agent
│   └── release-checker.json
├── skills/
│   └── triage-ticket/
│       ├── SKILL.md
│       └── references/…
├── install.sh                 # your script; Osaurus does not read it
└── uninstall.sh
```

Only the manifest and files it lists are copied. Paths must be relative and stay
inside the bundle (no absolute, `~`, `..`, or symlinks). Each JSON ≤ 512 KB.

## Manifest

```json
{
  "format": "osaurus.bundle",
  "format_version": 1,
  "id": "com.example.acme-support",
  "name": "Acme Support Starter",
  "version": "1.0.0",
  "publisher": { "name": "Acme Example", "url": "https://acme.example" },
  "min_osaurus_version": "0.25.26",
  "skills": [{ "name": "triage-ticket", "path": "skills/triage-ticket" }],
  "mcp_servers": [{
    "name": "Acme Tickets",
    "transport": "http",
    "url": "https://mcp.acme.example/mcp",
    "auth": "bearer",
    "token_ref": "keychain:com.example.acme-support/tickets-token"
  }],
  "harness_runtimes": [{
    "name": "Acme Pi",
    "kind": "pi_rpc",
    "executable": "pi"
  }],
  "agents": [
    { "path": "agents/support-desk.json" },
    { "path": "agents/release-checker.json" }
  ],
  "settings": { "require_local_access_key": true }
}
```

| Key | Required | Meaning |
|-----|----------|---------|
| `format` / `format_version` | yes | `"osaurus.bundle"` / `1` |
| `id` | yes | Reverse-DNS ownership key (**never change**; update/remove only own id) |
| `name` / `version` | yes | Display + semver (bump every release; `update` skips newer installs) |
| `description` / `publisher` | no | `publisher.name` required inside object |
| `min_osaurus_version` | no | CLI refuses older apps |
| `skills` | no | `{ name, path }` |
| `mcp_servers` | no | Inline MCP entries |
| `harness_runtimes` | no | Inline runtime entries |
| `agents` | no | `{ path }` to agent JSON |
| `settings` | no | Server settings by key |

At least one of skills / mcp / harness_runtimes / agents / settings must list
something. Unknown keys refused with did-you-mean.

### Settings allow-list

| Key | Value | Control |
|-----|-------|---------|
| `require_local_access_key` | bool | Server → Authentication → Require Access Key for Local Admin Routes |
| `allowed_origins` | string list | CORS allowed origins (**adds only**, never removes; restarts server) |

`require_local_access_key: false` and every origin need `--yes`. Bundles cannot
mint access keys. `install` always sets settings; `update` leaves a setting the
user changed; conflicting bundles fail; `remove` leaves settings as they are.

## Agent JSON shapes

1. **Template envelope:** `"format": "osaurus.template"` + top-level `name`
   (model requirements, `actions`: `{icon, text, prompt}`)
2. **Bare agent object**
3. **Config fragment:** `{ "agents": [ { … } ] }` with exactly one agent

```json
{
  "name": "Support Desk",
  "description": "Triages tickets.",
  "system_prompt": "You are…",
  "model": "foundation",
  "capabilities": {
    "tools_enabled": true,
    "memory_enabled": true,
    "web_search_enabled": true,
    "knowledge_enabled": false,
    "computer_use_enabled": false,
    "browser_use_enabled": false,
    "relay_enabled": false,
    "apple_apps": []
  },
  "skills": ["triage-ticket"],
  "tools": { "mode": "manual", "enabled": ["get_current_time", "acme_tickets_search_tickets"] },
  "mcp_servers": { "enabled": ["GitHub"] },
  "plugins": { "enabled": ["osaurus.fetch"] },
  "sandbox": {
    "enabled": true,
    "network_enabled": true,
    "allowed_domains": ["api.acme.example"]
  },
  "subagents": { "enabled": true, "agents": ["Release Checker"] },
  "orchestrator_spawnable": false,
  "runtime": "builtin",
  "claude_code": {
    "model": "sonnet",
    "mode": "agent",
    "allow_writes": true,
    "allow_shell": false,
    "allow_osaurus_tools": true
  },
  "working_folder": "~/Documents/Acme"
}
```

| Key | Meaning |
|-----|---------|
| `name` | Required; match key on update |
| `description` | Orchestrator routing line (generated if omitted) |
| `model` | `foundation`, local id, or `provider/model`; omit = user's model. Template `requirements.models[0].strictness`: `preferred` \| `always` |
| `capabilities` | Per-agent switches |
| `skills` | Allow-list semantics (omit / null / list / []) |
| `tools` | Manual exact list; MCP tools named `<server_snake>_<tool>` |
| `mcp_servers` / `plugins` | `enabled` = every tool of named server/plugin; `disabled` removes |
| `sandbox` | `enabled`, `network_enabled`, `allowed_domains`, … |
| `subagents` | Delegation allow-list by agent name |
| `orchestrator_spawnable` | `false` at **create** only |
| `runtime` | `builtin` or harness name (bundle or already on Mac) |
| `claude_code` | Claude Code options when on that runtime |
| `working_folder` | Path hint; may `needs_user_action` until user picks |

**Exact tools vs whole servers.** Exact tool names stay listed and work once the
server connects. `mcp_servers.enabled` only adds tools present at apply time; if
the server is waiting on a secret, list tools by name and `import update` later.

Names match case-insensitively; plugins by registry id. Names not in the bundle
must already exist on the Mac (`validate` warns).

## Skills

Agent Skills folders (`SKILL.md` + optional `references/` / `assets/`).
`SKILL.md` `name` must match manifest by slug; include `description`. Limits:
512 files, 10 MB/file, 50 MB total, 16 folders deep, no symlinks. Install to
`~/.osaurus/skills/<slug>/`. Collisions with user/built-in/plugin skills are
refused; prefix product names (`acme-triage`).

## MCP servers (inline)

```json
{
  "name": "Acme Tickets",
  "transport": "http",
  "url": "https://mcp.acme.example/mcp",
  "auth": "bearer",
  "token_ref": "keychain:com.example.acme-support/tickets-token",
  "secret_header_refs": {
    "X-Acme-Workspace-Key": "keychain:com.example.acme-support/ws-key"
  }
}
```

```json
{
  "name": "GitHub",
  "transport": "stdio",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github@1.2.3"],
  "secret_env_refs": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "keychain:com.example.acme-support/github-token"
  },
  "execution_host": "sandbox"
}
```

- HTTP `auth`: `none` \| `bearer` \| `oauth` (OAuth → `needs_user_action` until sign-in)
- stdio: `command`, `args`, `env` (non-secret), `working_directory`, `secret_env_refs`
- `execution_host`: `sandbox` (default) \| `host`
- `enabled: false` installs switched off
- `transport` cannot change after install

## Harness runtimes (inline)

```json
{
  "name": "Acme Pi",
  "kind": "pi_rpc",
  "executable": "pi",
  "arguments": ["--mode", "rpc", "--session-id", "{chat_id}", "--append-system-prompt", "{system_prompt_file}"],
  "environment": { "PI_LOG_LEVEL": "info" }
}
```

`kind` is `pi_rpc` or `claude_code` (fixed after install). Installer must put the
program on PATH (`validate` warns). `environment` plain values only. `builtin`
is reserved. Installing an agent with `"runtime": "Acme Pi"` installs the
runtime too; removing the last agent that pulled it removes it. Details:
`harness-runtimes.md`.

**High risk:** every MCP, every runtime, and every agent on a runtime or with
`computer_use_enabled` / `browser_use_enabled` / `relay_enabled` /
`claude_code.allow_shell` appears under `risks`; needs `--yes`.

## Secrets

Secrets never go in the bundle. Login Keychain only; `env:` refs **refused** in
bundles. After Osaurus is in `/Applications`, as the logged-in user:

```bash
printf '%s\n%s\n' "$TOKEN" "$TOKEN" \
  | security add-generic-password -U \
      -s com.example.acme-support -a tickets-token \
      -T /Applications/Osaurus.app -w
```

- `-T /Applications/Osaurus.app` **required** (else `pending_secrets`)
- `-w` last so value comes from stdin (never `-w "$SECRET"` in argv)
- `-U` updates; rotate then `import update --yes`
- Uninstall: `security delete-generic-password -s SERVICE -a ACCOUNT`

## CLI

```bash
osaurus import validate --from <bundle> [--json]
osaurus import install  --from <bundle> [agent|skill|mcp|runtime|setting] [names…] [--yes] [--json]
osaurus import update   --from <bundle> … [--yes] [--json]
osaurus import remove   --bundle <id> … [--json]
osaurus import list     [--bundle <id>] [--json]
```

Every command accepts `--access-key` / `OSAURUS_API_KEY`. Without an accepted
key when required, import queues for next launch.

| Exit | Meaning |
|------|---------|
| `0` | Applied (app running) or queued |
| `1` | Check/change failed |
| `3` | Applied; finish in app (secret, sign-in, model, folder) |

### `--json` fields (common)

| Field | Values |
|-------|--------|
| `state` | `validated`, `applied`, `partial`, `queued`, `failed`, `refused`, `listed`, `nothing_to_do` |
| `items[].kind` | `agent`, `skill`, `mcp`, `harness_runtime`, `setting` |
| `items[].action` | `install`, `update`, `remove` |
| `items[].status` | `done`, `unchanged`, `needs_user_action`, `failed`, `skipped`, `queued`, `valid` |
| `risks`, `warnings`, `issues`, `pending_secrets` | string lists |
| `installed`, `queued` | (`list`) receipts / pending |
| `cancelled_requests` | (`remove`) |

### Update / remove semantics

- Higher `version` + `update`: changed items re-applied; unchanged → `unchanged`;
  new items installed; user-deleted items not revived (`install` does revive);
  dropped items stay until `remove`; only keys the agent file declares are
  re-applied; declared lists replace; renamed agent keeps user's name.
- `remove --bundle <id>` removes that bundle's items and cancels queued imports
  (folder not required). Skills/servers still used elsewhere are kept.

## Installer script checklist

1. Verify Osaurus signature (`codesign`, `spctl`; TeamIdentifier `4W8QF9VR2F`)
2. Use Helpers CLI path
3. Run as console user, never root (`launchctl asuser` from pkg postinstall)
4. Store Keychain secrets with `-T`
5. Optional: `tools install … --consent`, `pull` models
6. `validate --json` then `install --yes --json`; handle exit 0/3/1
7. Optionally `open -a /Applications/Osaurus.app`

## Not in a bundle

| Instead | How |
|---------|-----|
| Plugins | `osaurus tools install <id> --consent` |
| Models | `osaurus pull` or template `strictness: preferred` |
| Raw secrets | Keychain only |
| Most Settings | App UI |

## On-disk import paths

| Path | Contents |
|------|----------|
| `~/.osaurus/import/pending/<request-id>/` | Queued; removed once applied |
| `~/.osaurus/import/results/<request-id>.json` | Applied result |
| `~/.osaurus/import/installed.json` | Receipts (do not hand-edit) |
| `~/.osaurus/skills/<slug>/` | Installed skills |

## Security checklist

- Sign/notarize installer; verify Osaurus before installing it
- Minimize high-risk items; prefer HTTP you operate + `execution_host: sandbox`
- `https://` endpoints; narrow `allowed_domains`; leave network off unless needed
- Exact `tools.enabled` over whole servers
- Secrets on stdin + `-T` for Osaurus only; delete on uninstall
- Pin stdio packages (`@scope/server@1.2.3`, not `@latest`)
- Never ship `require_local_access_key: false`
