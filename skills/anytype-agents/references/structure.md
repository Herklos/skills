# Anytype Agents structure (generic)

No space ids or personal names here. Discover live ids with MCP search each session.

## Companion references

| File | When |
|------|------|
| `object-types.md` | Agent / Team / Project type keys, properties, templates |
| `page-templates.md` | Creating/auditing body shapes |
| `suggested-runtime.md` | Suggested runtime field list |
| `shared-rules-starter.md` | Bootstrapping Shared Rules |
| `examples.md` | Fictional org / project walkthrough |
| `handoff-templates.md` | Briefs, handoffs, welcome paste |
| `mcp-recipes.md` | Concrete MCP call patterns |

## How to find hubs

```
API-search-global or API-search-space
  query: "Agents"
  query: "Projects"
  query: "Shared Rules" / "Agent Template"
  query: "Skill Template"
  query: "Drafted" / "Drafts"
```

Confirm with the user when multiple pages match. Prefer the hub that links a full HQ index.

From an `https://object.any.coop/<objectId>?spaceId=<spaceId>` or `anytype://object?objectId=…&spaceId=…` URL, take both ids from the query.

## Typical tree

```
Agents
├── Shared Rules (template / mandatory rules)
├── Skills (global) ── Skill Template
├── Primary (coordinator)
│   ├── Roster / routing
│   ├── Delegation playbook
│   ├── Open loops / approvals (optional)
│   └── Memory pages
├── Board HQ (+ Board Group)
├── {Domain} HQ
│   ├── Chief agent page
│   ├── Sub-team pages
│   ├── Group page
│   ├── Skills (team)
│   └── Specialist agent pages
│       ├── Skills (agent)
│       └── Memory children
└── Drafts

Projects
├── {Product / repo}
│   ├── Technical / Business / …
│   ├── Project Management → Roadmap / Backlog / TODO
│   ├── Product / Design / Marketing
│   └── Skills (project) optional
└── …
```

Titles vary by org. Treat the pattern as a guide; always read what exists.

## Common page roles

| Role | Look for |
|------|----------|
| Primary | Human front door, cross-HQ coordination, approvals |
| Board | Chiefs alignment; not day-to-day specialist delivery |
| HQ | Domain ownership, sub-teams, routing rules |
| Specialist | Narrow delivery; reports to a chief |
| Group | Chat membership paste + welcome |
| Skills hub | Index + template; resolution Agent → Team → Project → Global |

## Types

Org inventory uses custom keys **`agent`** and **`team`**, plus extended built-in
**`project`**. Supporting docs (Shared Rules, Skills, memory children, hubs) stay
**`page`**. Spaces also expose `task`, `note`, `collection`, `query`, `template`,
media types. See `object-types.md` for property keys, default templates, create
and `set_type` migration.

## Runtime vs docs

| Layer | Store |
|-------|-------|
| Org, prompt text-as-docs, memory pages, skill procedures | Anytype |
| Hermes runtime home | `$HERMES_HOME/profiles/<slug>` (`hermes-profiles`) |
| Other harnesses | Their own configs; prompt copied from the agent page |

When docs and a local runtime memory disagree, prefer the Anytype agent page unless the user says otherwise.

## Routing habits (when documented)

- Task through the owning HQ chief
- Specialists escalate to their chief, then Primary
- Only Primary reaches the human when that rule is published
- Public VCS comments stay free of internal org links when hygiene rules say so
