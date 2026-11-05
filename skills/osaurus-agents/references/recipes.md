# Recipes

## New Osaurus agent (config)

1. Export current state: `osaurus config export -o /tmp/osaurus-before.yaml`
2. Write a fragment with the new `agents:` entry (+ optional `delegation.spawnable_agents`)
3. `osaurus config plan` → review → `osaurus config apply`
4. Verify in app Agents list or re-export

## Twin / update an agent

Entities match by **name**. Edit the same `name` in a document and `apply`
(merge). To rename, create the new name then remove the old (prune or app UI);
confirm with the user first.

## Ship a starter pack (bundle)

1. Copy upstream example or scaffold `osaurus-bundle.json` + `agents/` + `skills/`
2. Bump `version`; keep stable `id`
3. Store Keychain secrets with `-T /Applications/Osaurus.app`
4. `import validate` → `import install --yes`
5. Open Osaurus; finish any Set Up Now steps

## Export for backup / review

```bash
osaurus config export -o ~/Desktop/osaurus-config.yaml
```

Secrets are stripped. Treat the file as still sensitive (URLs, agent prompts).

## Wire Claude Code as agent runtime

```yaml
harness_runtimes:
  - name: Claude Code
    kind: claude_code
    executable: claude
agents:
  - name: Coding Buddy
    runtime: Claude Code
    claude_code:
      model: sonnet
      mode: agent
      allow_writes: true
      allow_shell: false
```

`apply` with `--yes` (runtime / shell flags are high-risk). Agent must be signed
in via Claude Code separately. Docs: https://docs.osaurus.ai/harness-runtimes

## Anytype agent on Osaurus

1. Set Agent.`runtime` → Runtime **Osaurus**
2. Follow `anytype-apply.md`
3. Prefer config fragment for a single specialist; bundle when shipping skills too

## Serve + MCP for clients

```bash
osaurus serve
osaurus mcp --tools "osaurus_status,osaurus_list,osaurus_*"
```

Client config: `"command": "osaurus", "args": ["mcp"]`.
