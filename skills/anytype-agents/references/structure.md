# Anytype Agents structure (generic)

No space ids or personal names here. Discover live ids with MCP search each session.

## Companion references

| File | When |
|------|------|
| `object-types.md` | Agent / Team / Subteam / Subagent / Harness / Harness profile / Project / Epic / User story / Task type keys |
| `project-pm.md` | PM Epics / User stories / Tasks + filtered Roadmap/Backlog/TODO Queries |
| `type-templates.md` | Dumped default template bodies (bootstrap / drift) |
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
├── Skills (global Query of skill) ── Skill Template (type skill)
├── Harnesses (type `harness` catalog)
├── Harness profiles (type `harness_profile` stacks)
├── Primary (coordinator)
│   ├── Roster / routing
│   ├── Delegation playbook
│   ├── Subagents (type `subagent` spawn configs; optional)
│   ├── Open loops / approvals (optional)
│   └── Memory pages
├── Board HQ (+ Board Group)
├── {Domain} HQ
│   ├── Chief agent page
│   ├── Subteam pages (type `subteam`)
│   ├── Group page
│   ├── Skills (team)
│   └── Specialist agent pages
│       ├── Subagents (type `subagent`; 0..n per agent)
│       ├── Skills (agent)
│       └── Memory children
└── Drafts

Projects
├── {Product / repo}
│   ├── Technical / Business / …
│   ├── Project Management → Roadmap / Backlog / TODO (Queries of epic / user_story / task)
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
| HQ | Domain ownership, Subteams, routing rules |
| Subteam | Domain / pod under an HQ (type `subteam`) |
| Subagent | Spawn/route config under an Agent (type `subagent`; not a Subteam) |
| Specialist | Narrow delivery; reports to a chief |
| Group | Chat membership paste + welcome |
| Skills hub | Index + template; resolution Agent → Subteam → Team → Project → Global |

## Types

Org inventory uses custom keys **`agent`**, **`team`**, **`subteam`**,
**`subagent`**, **`harness`**, **`harness_profile`**, **`epic`**,
**`user_story`**, plus extended built-ins **`project`** and **`task`**. Prefer
**`subteam`** for domains under an HQ. Prefer **`harness_profile`** on agents
(not a harness select). Prefer **`subagent`** objects linked via Agent.`subagents`
for spawn routes (decline to Hermes `model_map`). Project PM uses **`epic`** /
**`user_story`** / **`task`** with per-project Queries named Roadmap / Backlog /
TODO (`project-pm.md`). Supporting docs: Shared Rules as **`prompt`**; memory as
**`memory`**; procedures as **`skill`**; Skills indexes as **`query`**; other
hubs may stay **`page`**. Spaces also expose `note`, `collection`, `query`,
`template`, media types. See `object-types.md` + `memory-and-skills.md` for
property keys, default templates, create and `set_type` migration.

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
