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

## Import queued but agents missing

Open Osaurus once so pending imports under `~/.osaurus/import/pending/` apply.
Check `osaurus import list --json` and `~/.osaurus/import/results/`.

## `pending_secrets` / needs setup

Keychain item missing `-T /Applications/Osaurus.app`. Re-store with `-T`, then
`osaurus import update --from <bundle> --yes`.

## Apply refused (risks)

Review `plan` / validate `risks`, then pass `--yes` only after user confirmation.

## Access key rejected

Pass `--access-key` or set `OSAURUS_API_KEY` when Require Access Key for Local
Admin Routes (or network exposure) is on. Without a key, imports may queue.

## Agent missing a tool

Server not connected, wrong tool name, or MCP still waiting on a secret. Compare
with `osaurus config export` and **Settings → Tools & MCP**.

## Validate "only checked for shape"

Osaurus was not running during `import validate`. Open the app and validate again.

## Confusion: Anytype Runtime vs agents[].runtime

- Anytype type **`runtime`**: platform catalog (`hermes` / `osaurus` / …)
- Osaurus **`agents[].runtime`**: builtin or Claude Code / Pi harness program

They are different concepts; do not overwrite one with the other.
