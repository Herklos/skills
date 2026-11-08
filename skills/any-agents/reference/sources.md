# Sources

Read for skill version **1.0.0** on **2026-11-08**. Prefer live main
over this snapshot when they disagree; update this file when you re-verify.

## Primary

| Source | Ref |
|--------|-----|
| https://raw.githubusercontent.com/anyproto/any/main/README.md | any@`0b73c01024f4` (main tip 2026-11-06) |
| https://github.com/anyproto/any `docs/01-cli.md` | same |
| https://github.com/anyproto/any `docs/05-config.md` | same (listen default **2046**, P2P, env) |
| https://github.com/anyproto/any `docs/30-global-p2p.md` | same |
| https://github.com/anyproto/any `website/02-quickstart/anyrt.md` | same (anyrt addr **2046**, triggers, one agent per server) |
| https://raw.githubusercontent.com/anyproto/anybao/main/README.md | anybao@`fb1de0f0732e` (main tip 2026-11-03) |
| https://raw.githubusercontent.com/anyproto/anybao/main/anybao.toml | same (comment still mentions 7001 default) |
| https://raw.githubusercontent.com/anyproto/anybao/main/docs/llm-models.md | same |
| https://raw.githubusercontent.com/anyproto/anybao/main/docs/skill-bao-config.md | same (desktop default port 31330) |
| https://raw.githubusercontent.com/anyproto/anybao/main/docs/config-secrets.md | same |
| https://raw.githubusercontent.com/anyproto/anybao/main/docs/debugging.md | same |
| https://raw.githubusercontent.com/anyproto/anybao/main/docs/llm-fixtures.md | same |
| https://raw.githubusercontent.com/anyproto/anybao/main/docs/testing-agent-changes.md | same |
| https://raw.githubusercontent.com/anyproto/anybao/main/docs/adr/README.md | ADR index 001–033 |
| ADR-006, 009, 015, 018 (data, overlays, election, events) | same |
| https://raw.githubusercontent.com/anyproto/anybao/main/repos/CLAUDE.md | same |
| https://raw.githubusercontent.com/anyproto/anybao/main/repos/_agent/README.md | same |
| https://raw.githubusercontent.com/anyproto/anybao/main/repos/_connectors/README.md | same |
| `runtime/src/config_defaults.json` | same |
| `repos/_agent/programs/remind@v1.py`, `config@v1`, `subagent@v1` | same |

## Secondary

| Source | Ref |
|--------|-----|
| https://raw.githubusercontent.com/anyproto/any-sync-sdk/main/docs/global-p2p.md | read 2026-11-08 |
| https://github.com/anyproto/any-store | linked from any README |
| https://github.com/anyproto/any-sync | protocol |
| https://github.com/anyproto/any-sync-dockercompose | README read 2026-11-08 (coordinator, node×3, filenode, consensus) |
| https://agentclientprotocol.com/ | ACP landing, extensions notes |

## Explicitly out of scope

`anytype-heart`, `anytype-cli`, `anytype-mcp`, `anytype-ts`,
`anytype-swift`, `anytype-kotlin`, `anytype-api`, `anytype-push-server`.
