# Harness runtimes (Claude Code / Pi)

Docs: https://docs.osaurus.ai/harness-runtimes

An Osaurus **harness runtime** decides who runs an agent's chats. Default is
Osaurus itself (`builtin`). You can hand chats to an outside program such as
**Claude Code** or **Pi**. The outside program brings its own model, tools, and
history; Osaurus starts it, relays messages, shows replies, and stops it.

**Not** Anytype type `runtime` (`grok-bot` / `hermes` / `osaurus` / `noodle`).

## When to use

- You already like Claude Code / Pi and want them inside Osaurus chat
- You want Claude Pro/Max via signed-in Claude Code

Requirements: program installed on the Mac; Claude Code signed in.

## Claude Code (built-in setup)

1. Install Claude Code; sign in once in Terminal if needed
2. **Settings → Agents → Runtimes** → **Test** / **Sign In** on Claude Code row
3. In chat model picker: runtime column → Sonnet / Opus / Haiku  
   or agent **Configure → Runtime → Runs on**

## Add Pi (or Pi-based)

**Settings → Agents → Runtimes → Add Runtime**:

| Field | Example |
|-------|---------|
| Protocol | Pi (RPC) or Claude Code |
| Name | Shown in picker |
| Executable | `pi` or full path |
| Arguments | one per line; include `--mode` `rpc`; `--session-id` `{chat_id}` to resume |
| Environment | `NAME=value` (plain; never secrets) |

Click **Test**. Then set the agent **Runs on** that name.

## Claude Code options (agent Configure)

| Option | Meaning |
|--------|---------|
| Claude model | Sonnet / Opus / Haiku (alias as Claude Code defines) |
| Execution mode | **Agent** (read/search in folder) or **Text only** (no tools) |
| Allow file changes | Edits only inside chat folder |
| Allow shell commands | Unrestricted shell; keep off unless needed |
| Allow Osaurus read tools | Osaurus tools the agent may use |
| Allow Osaurus configuration changes | Orchestrator only (`allow_osaurus_config_writes`) |

## What changes on a runtime

- One process per chat; works in chat Working Folder (or private scratch)
- Osaurus abilities / memory / Sandbox **do not** apply to that agent while on a runtime
- Chat history stays in Osaurus across process restarts
- Stop asks the program to abort; kill after timeout
- Delegation **to** runtime agents fails today; Computer Use / Browser Use / AppleScript cannot target them

## Config / bundle

```yaml
harness_runtimes:
  - name: Spotlight
    kind: pi_rpc              # claude_code | pi_rpc; required to add, fixed after
    executable: ~/.local/bin/spotlight
    arguments: ["--mode", "rpc", "--session-id", "{chat_id}"]
    environment: { PI_LOG_LEVEL: info }

agents:
  - name: Researcher
    runtime: Spotlight        # or "builtin" / "Claude Code"
default_agent:
  runtime: Claude Code
  claude_code: { model: opus, allow_writes: true }
```

Runtimes apply before agents. Unknown `runtime` name fails validation (no silent
fallback to builtin). Adding/changing command/env, moving an agent onto a
runtime, `allow_shell`, and `allow_osaurus_config_writes` are **high-risk**
(`--yes`).

On-disk: `~/.osaurus/config/harness-runtimes.json`.

### Argument placeholders

| Placeholder | Value |
|-------------|-------|
| `{chat_id}` | Chat UUID (lowercase) |
| `{agent_id}` | Agent UUID |
| `{cwd}` | Process working directory |
| `{system_prompt_file}` | 0600 file with system prompt |

### Process env (always win)

`OSAURUS_CHAT_ID`, `OSAURUS_AGENT_ID`, `OSAURUS_AGENT_TOKEN`, `OSAURUS_API_BASE`,
`OSAURUS_WORKING_DIRECTORY`, `OSAURUS_MCP_BRIDGE_GRANT`. Other `OSAURUS_*`
reserved. Token is loopback-scoped; MCP routes honor the agent's tool allow-list
(Ask tools refused; no spawn/loop tools; Computer/Browser/AppleScript error).

## Safety

Runtime = user-account process. Osaurus limits Claude Code file edits to the
chat folder; it cannot confine shell or Pi tools. Approve Orchestrator-added
runtimes. Prefer shell off.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Not signed in (Claude Code) | Sign In on Runtimes page or `claude` in Terminal, then Test |
| Program not found | Full path in Executable |
| Pi forgets history | Add `--session-id` `{chat_id}` |
| Runtime switch grayed | Wait for reply / Stop |
| Delegation fails | Runtime agents cannot take delegated work yet |
