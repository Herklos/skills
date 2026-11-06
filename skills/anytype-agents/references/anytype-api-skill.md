# Build / refresh the global `anytype-api` skill

Playbook for maintaining the org-wide **HTTP** Anytype skill (replaces
`@anyproto/anytype-mcp` for Hermes and other runtimes). Prefer this over
re-adding MCP.

Live org example (ids change per space; re-search): skill_key `anytype-api`,
`skill_scope=global`, Hermes tree `~/.hermes/skills/org/anytype-api/`.

## Goal

Ship a skill agents can run with **terminal + curl/HTTP** only:

1. Env: `ANYTYPE_API_HOST`, `ANYTYPE_API_KEY`
2. Tight `SKILL.md` router (progressive disclosure)
3. Rich `references/` (full guide, curl recipes, endpoints, gotchas)
4. Matching Anytype `skill` object (global, active) with a **full** body
5. Shared Rules pointer (compact core + topic Prompt), not per-agent Prompt paste
6. No `mcp_servers.anytype` in Hermes configs

## Sources of truth

| Layer | Role |
|-------|------|
| Upstream skill | https://developers.anytype.io/skill.md |
| Docs | https://developers.anytype.io/docs/reference · `/docs/reference/v2` |
| Live OpenAPI | `GET $ANYTYPE_API_HOST/v2/docs/openapi.json` |
| Hermes runnable | `~/.hermes/skills/org/anytype-api/` (default home; named profiles symlink) |
| Anytype SoT object | typed `skill`, `skill_key=anytype-api`, listed by Skills – Global |
| This playbook | `anytype-agents` → `references/anytype-api-skill.md` |

Do **not** leave the Anytype skill as an empty Skill Template. Agents that
only open Anytype will otherwise see almost nothing.

## Env (every Hermes profile)

```bash
ANYTYPE_API_HOST=http://127.0.0.1:31009
ANYTYPE_API_KEY=<token>   # Bearer only; Settings → API keys
```

- No trailing slash on the host.
- Prefer `/v2/` routes (no `Anytype-Version` header on v2).
- Do not keep `ANYTYPE_OPENAPI_MCP_HEADERS` or MCP env injection.
- Never put the key in Anytype objects, SOUL, or chat.

## Hermes skill shape (required)

```
skills/org/anytype-api/
  SKILL.md                 # router only (~3–5 KB)
  references/
    http-guide.md          # full upstream guide (host → $ANYTYPE_API_HOST)
    curl-recipes.md        # bootstrap / search / read / patch / files / chats
    endpoints.md           # path + operationId table (from OpenAPI)
    gotchas.md             # failure modes + org notes
    hermes-env.md          # fleet install, Shared Rules pointers, no-MCP
```

### SKILL.md must include

- Front matter: `name`, `description` (triggers), `version`, `skill_key`,
  `skill_scope`, `anytype_object_id`, `anytype_space_id`, docs URLs
- Env table + first `whoami` curl
- Session start: whoami → spaces → schemas when unsure
- Which-call table (search / read / patch / create / queries / discussion / files)
- Hard rules: query pagination only; no whole-document rewrite; no MCP
- Load-next table pointing at each `references/*` file

### Build steps

1. Download upstream: `curl -fsSL https://developers.anytype.io/skill.md`
2. Strip YAML front matter; rewrite hardcoded `http://127.0.0.1:31009` →
   `$ANYTYPE_API_HOST` (or backtick form in prose)
3. Write `references/http-guide.md` = short header + that body
4. Generate `endpoints.md` from OpenAPI paths (fixture or live
   `/v2/docs/openapi.json`)
5. Author `curl-recipes.md` with working bodies (search `limit` in **query**;
   PATCH `ops`; `create_missing_options`; dry_run; discussion → chat)
6. Author `gotchas.md` (pagination, option names, add/remove vs rewrite
   multiSelect, DELETE provenance, no keys in Anytype)
7. Write thin `SKILL.md` router; bump `version`
8. Symlink into every named Hermes profile:
   `profiles/<slug>/skills/org/anytype-api` →
   `../../../../skills/org/anytype-api`
9. Update `skills/org/DESCRIPTION.md` to mention `anytype-api`

## Anytype skill object

1. Search `type: skill` + `skill_key=anytype-api` (or create)
2. Properties: `skill_kind=procedure`, `skill_scope=global`,
   `skill_status=active`, `version`, rich `intent`
3. Body = Skill Template sections **filled in**:
   Goal / When / When not / Prerequisites / Procedure (bootstrap, search,
   read cheap, PATCH, create, schemas) / Which-call table / Verify /
   Gotchas / Progressive disclosure (Hermes paths) / **Full HTTP guide** /
   Curl recipes / Endpoint excerpt / Change log
4. Rewrite with `delete_block` (top-level, recursive) + `insert_blocks`
   markdown when refreshing; avoid leaving the blank template skeleton
5. Confirm Skills – Global Query lists it (`skill_scope=global`)

Thin stub anti-pattern: Goal/When/Procedure placeholders with “full guide
lives in Hermes only”. Put the guide in the Anytype body too.

## Shared Rules (token economy)

Do **not** paste the HTTP guide into every Agent Prompt / SOUL.

1. Keep Agent Prompt pointer:
   `Follow Agents → Agent Template – Shared Rules in full.`
2. Shared Rules core (`prompt_kind=shared_rules`) = **compact index** only:
   how to use, topic list, one-line rule → topic map, machine ids
3. Rule bodies live in topic library Prompts (~5 topics):
   Ops & quality · Anytype data & channels · Org & escalation ·
   Delivery & tools · Meta & templates
4. HTTP curl cheat sheet: library Prompt **Anytype HTTP access**
5. Lightest-route rule points at skill `org/anytype-api` + HTTP topic
6. Starter pattern: `shared-rules-starter.md`

## Remove MCP (Hermes fleet)

1. Delete `mcp_servers.anytype` (or `anytype:`) from every
   `config.yaml` (default + `profiles/*/config.yaml`)
2. Remove obsolete profile skills like `mcp-anytype`
3. Full Desktop quit (Cmd+Q) so stdio children die
4. Verify: `pgrep -lf anytype-mcp` empty for Hermes gateway children
   (a Grok/Claude session may still hold its own MCP client)

## Verify checklist

- [ ] `curl "$ANYTYPE_API_HOST/v2/auth/whoami" -H "Authorization: Bearer $ANYTYPE_API_KEY"` works
- [ ] Hermes `hermes skills list` shows `org / anytype-api`
- [ ] Named profile symlink resolves
- [ ] Anytype skill body contains Procedure + Full HTTP guide (not empty template)
- [ ] Skills – Global lists `anytype-api`
- [ ] No `@anyproto/anytype-mcp` in Hermes configs
- [ ] Shared Rules core is index-sized; topics hold rule text

## Refresh cadence

When upstream skill.md or OpenAPI changes:

1. Re-pull upstream → refresh `http-guide.md` + `endpoints.md`
2. Bump Hermes + Anytype skill `version`
3. Re-sync Anytype object body
4. Note in Change log; no mass SOUL rewrite if agents only pointer Shared Rules
