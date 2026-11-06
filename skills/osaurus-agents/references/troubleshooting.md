# Troubleshooting

## `osaurus: command not found`

Use the app Helpers binary or install the CLI from Settings:

```bash
cli="/Applications/Osaurus.app/Contents/Helpers/osaurus"
[ -x "$cli" ] || cli="/Applications/Osaurus.app/Contents/MacOS/osaurus"
ln -sf "$cli" "$HOME/.local/bin/osaurus"   # ensure ~/.local/bin on PATH
```

Do not write into Homebrew's bin for a DMG install. Run `osaurus doctor`.

## Server won't start

```bash
osaurus status
lsof -i :1337
osaurus serve --port 8080
osaurus doctor --json
```

For keep-alive after quit/crash, use `serve --supervise` (and optional LaunchAgent in `cli-map.md`).

## Import queued but agents missing

Open Osaurus once so pending imports under `~/.osaurus/import/pending/` apply.
Check `osaurus import list --json` and `~/.osaurus/import/results/`.

## `pending_secrets` / needs setup

Keychain item missing `-T /Applications/Osaurus.app`. Re-store with `-T`, then
`osaurus import update --from <bundle> --yes`.

## Bulk agent sandbox secrets hang / incomplete

Per-agent secrets use Keychain service `ai.osaurus.agent-secrets`, account
`{UUID}.{KEY}` (UUID as in `~/.osaurus/agents/{UUID}.json`). Use inline
`security add-generic-password -U -s ai.osaurus.agent-secrets -a "$UUID.$KEY"
-T /Applications/Osaurus.app -w "$VALUE"` wrapped in `/usr/bin/timeout 8`.
Bulk loops can block on Allow dialogs: click Allow once, re-run, verify with
`find-generic-password` (metadata only; never dump `-w` to logs). Skip accounts
that already exist. HTTP `/v1/agents/{id}/secrets` may return
`secure_channel_required`; prefer Keychain for local seeding. Full recipe:
`anytype-apply.md` → Sandbox secrets.

## Avatars missing after config apply

Avatars are outside the declarative document. Filename must be `{agentUUID}.png`
under `~/.osaurus/agents/avatars/`, with matching `customAvatarFilename` on that
agent’s JSON (clear mascot `avatar`). Patching JSON while Osaurus is running
needs an **Agents reload or app restart** before portraits appear. UI fallback:
General → Appearance. See `anytype-apply.md` → Avatars.

## Apply refused (risks)

Review `plan` / validate `risks`, then pass `--yes` only after user confirmation.
High-risk includes prune, browser/Computer Use, new MCP, runtime moves, Claude Code shell, auto tool policies.

## Access key rejected / Invalid access key

Pass `--access-key` or set `OSAURUS_API_KEY` when **Require Access Key for Local
Admin Routes** (or network exposure) is on. Without a key, `config export|plan|apply`
and some admin routes fail; imports may queue.

Token format must be `osk-v1.…` (JWT-shaped). Errors like `Invalid access key:
Unrecognized token format` mean the value is missing, truncated, or not an
Osaurus local-admin access key.

**Keychain pitfall:** `com.osaurus.account` often holds master/recovery material,
not the local admin access key. Do not treat Keychain blobs as `OSAURUS_API_KEY`.
Ask the user for a key labeled for local admin / terminal (Settings → Server),
store session-only (`export OSAURUS_API_KEY=…` or `chmod 600` temp file), never
commit or write into skills.

Loopback `/admin/*` without the key returns 401 when the require-key flag is on.

## Agent missing a tool

Server not connected, wrong tool name, Auto vs Manual mode, or MCP still waiting
on a secret. Compare with `osaurus config export` and **Settings → Tools & MCP**.
See `tools-and-plugins.md`.

## Tool missing in external MCP client

1. `osaurus tools list` and `osaurus status`
2. Restart the client
3. Narrow `osaurus mcp --tools "…"` (empty filter admits nothing; no filter admits everything)

## Plugin install / dylib concerns

```bash
osaurus tools verify
osaurus tools uninstall <id> && osaurus tools install <id>
osaurus tools rollback <id>
```

## Validate "only checked for shape"

Osaurus was not running during `import validate`. Open the app and validate again.

## Config apply exit 3

Applied, but an interactive step remains in the app (credential sheet, folder
picker, model pull, sign-in). Finish in Osaurus, then re-export if needed.

## Confusion: Anytype Runtime vs agents[].runtime

- Anytype type **`runtime`**: platform catalog (`hermes` / `osaurus` / …)
- Osaurus **`agents[].runtime`**: builtin or Claude Code / Pi harness program

They are different concepts; do not overwrite one with the other. See
`harness-runtimes.md`.

## Confusion: Osaurus Bundle vs `.mcpb`

- **Osaurus Bundle** (`osaurus-bundle.json`): `osaurus import …`
- **MCP Bundle** (`.mcpb`): `osaurus bundle load …`

## Permission denied on CLI binary

```bash
chmod +x /Applications/Osaurus.app/Contents/Helpers/osaurus
# do not sudo osaurus serve
```
