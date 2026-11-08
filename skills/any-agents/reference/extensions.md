# Extension points (design notes only)

**Do not implement these in this skill.** Runtime changes need an
**accepted ADR in anybao** first ("no code lands ahead of its ADR").

**Shipped today:** anyrt **is** the harness (Wasm/CPython guest +
recorded effects). Optional coding shell = `make runtime-shell`
(ADR-024). Browser tools = MCP HTTP client (`tools-and-mcp.md`), often
via desktop clipper relay — not an external chat runtime.

**Not shipped:** handing a chat to Claude Code / Pi / another CLI
(Osaurus-style harness runtime), ACP broker effects, mutate approval
UX, host-capability routing objects.

## ACP action for CLI agents

[Agent Client Protocol](https://agentclientprotocol.com/) **could**
expose Claude Code, Codex, Mistral Vibe (`vibe-acp`), etc. as a
**host-side broker effect** (same class as `http.get` / `llm.chat`) —
available only on hosts where the CLI is installed. **No accepted ADR
and no runtime surface yet**; do not configure or claim ACP support.

- Map ACP `session/request_permission` to **future** human approvals.
- Keep credentials and process spawn on the host; guest sees a typed
  effect result only.
- Gate via host capability objects (below) so election can prefer a
  device that actually has the CLI.

## Host-capability routing

A **host object per device** listing installed CLIs, credential
presence (refs only), and local model endpoints. Use it to:

- Filter trigger election / pin suggestions ("run GPU job where Ollama
  is up").
- Advertise ACP / shell / browser availability without putting secrets
  in the space.

Likely ties to existing `devices` registry (ADR-015) rather than a
parallel invent — amend via ADR.

## Human approvals

Expected from the any team (plus iPhone app + push). Until then:

- There is **no** approval gate on mutate effects.
- Natural hook: broker **read / mutate** classification on every
  effect (ADR-002) — an approval layer can intercept `mutate` before
  execution.
- Do not claim an approval UX exists in current anyrt.

## Reminder

Document intent in org spaces (`anytype-agents` or HQ pages). Ship
code only after ADR acceptance and tests (`repos/CLAUDE.md`,
`docs/testing-agent-changes.md`).
