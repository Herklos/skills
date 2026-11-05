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

## Apply refused (risks)

Review `plan` / validate `risks`, then pass `--yes` only after user confirmation.
High-risk includes prune, browser/Computer Use, new MCP, runtime moves, Claude Code shell, auto tool policies.

## Access key rejected / Invalid access key

Pass `--access-key` or set `OSAURUS_API_KEY` when Require Access Key for Local
Admin Routes (or network exposure) is on. Without a key, imports may queue.
Do not paste live keys into chat; confirm the user has a valid `osk-v1-…` style key in env.

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
