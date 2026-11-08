# Connectors

Shipped in `repos/_connectors` (overlay alias `connectors`). Guest
import: `use("connectors:linear@v1")`, etc.

For **MCP** servers (HTTP tools/list + tools/call via `agent:mcp@v1`),
see `reference/tools-and-mcp.md` — that path uses `mcp.server.*` /
`mcp.key.*`, not `connector.key.*`.

## Enable shipped connectors

Host: **Mac / Linux**. Put refs in `.connectors.env` next to
`anybao.toml` (mode 0600; gitignored):

```
connector.key.github=github_pat_…
connector.key.linear=lin_api_…
connector.key.granola=…
connector.key.attio=…
connector.key.figma=…
connector.key.intercom=…
# Google OAuth (managed — ADR-011):
connector.oauth.google.client_id=…
connector.oauth.google.client_secret=…
# empty value deletes a stored secret:
# connector.key.github=
```

| Ref | Header notes |
|-----|----------------|
| `connector.key.linear` | Authorization, raw (no Bearer) |
| `connector.key.github` | Authorization, Bearer |
| `connector.key.granola` | Authorization, Bearer |
| `connector.key.attio` | Authorization, Bearer |
| `connector.key.figma` | X-Figma-Token |
| `connector.key.intercom` | Authorization, Bearer |
| `connector.oauth.google` | Host-held refresh; `googleAuth.connect()` |

On every `anyrt serve` start, hard seeds write through to
`agent_secrets`. Keys sync across the account's devices (E2E). The
broker injects credentials **after** the trace record is written —
guest code and the model never see values.

Live-verified in upstream README: Linear, GitHub. Others may still need
hardening (`repos/_connectors/testing-flow.md`).

Ensure the `connectors` overlay is in `anybao.toml` (committed file
already ships public guest keys). Redeploy after local connector edits:

```bash
# Host: Mac / Linux
./runtime/target/release/anyrt deploy --source repos/_connectors --target connectors
```

Check: ask bao to call a method (`linear.whoami` / list GitHub repos)
and read `anyrt trace show …` for the http effect (no key material in
the trace).

## Write a new connector

Follow `repos/CLAUDE.md` + connectors README:

1. Add `programs/<name>@vN/program.py` (guest source; `use` /
   `effect` / `span` are globals).
2. Declare `__any_tool__ = True` and `@span` on public methods.
3. Declare `__any_credentials__` so serve stamps hosts/label for the
   Credentials dashboard (ADR-021).
4. Trim upstream field names (C1) — do not rename API keys in results.
5. Unit-test via kernel harness; deploy; exercise through chat; file
   frictions from traces.

Empty `connector.key.<x>=` deletes the stored secret. Managed OAuth
empty refresh deletes **local** token only — call provider
`disconnect()` to revoke server-side.
