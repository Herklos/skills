# Skills

Product-agnostic agent-ops skills for Hermes profiles and Anytype multi-agent orgs. Compatible with **Claude Code**, **Cursor**, **Codex**, and other skills installers.

## Skills

| Skill | Description |
|-------|-------------|
| [hermes-profiles](./skills/hermes-profiles/SKILL.md) | Manage Hermes Agent profiles (create, clone, config, gateway) |
| [anytype-agents](./skills/anytype-agents/SKILL.md) | Manage multi-agent org pages in Anytype via MCP (discover, create, route) |

## Repository layout

```
.
├── .claude-plugin/
│   ├── plugin.json          # Claude Code plugin manifest (bundle)
│   └── marketplace.json     # Marketplace catalog (bundle + individual skills)
├── .agents/plugins/
│   └── marketplace.json     # Cursor / agent marketplace catalog
├── skills/
│   ├── hermes-profiles/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── profile-map.md
│   │       ├── models-and-delegation.md
│   │       ├── soul-templates.md
│   │       ├── recipes.md
│   │       └── troubleshooting.md
│   └── anytype-agents/
│       ├── SKILL.md
│       └── references/
│           ├── structure.md
│           ├── page-templates.md
│           ├── shared-rules-starter.md
│           ├── examples.md
│           ├── handoff-templates.md
│           └── mcp-recipes.md
├── LICENSE
└── README.md
```

## Installation

### Claude Code (marketplace)

```bash
claude plugin marketplace add Herklos/skills

# Full bundle
claude plugin install agent-ops-skills@herklos-skills

# Or a single skill
claude plugin install hermes-profiles@herklos-skills
claude plugin install anytype-agents@herklos-skills
```

### Claude Code (local)

```bash
git clone https://github.com/Herklos/skills.git
claude --plugin-dir ./skills
```

### Cursor

Install from the marketplace UI, or add this repo as a plugin source via `.agents/plugins/marketplace.json`.

### ai-agent-skills

```bash
npx ai-agent-skills install Herklos/skills
npx ai-agent-skills install Herklos/skills/skills/hermes-profiles
npx ai-agent-skills install Herklos/skills/skills/anytype-agents

npx ai-agent-skills install Herklos/skills --agent cursor
npx ai-agent-skills install Herklos/skills --agent claude
```

### Manual install

```bash
cp -r skills/hermes-profiles ~/.claude/skills/
cp -r skills/anytype-agents ~/.claude/skills/

mkdir -p .cursor/skills
cp -r skills/hermes-profiles .cursor/skills/
cp -r skills/anytype-agents .cursor/skills/
```

## Validation

```bash
claude plugin validate .
claude plugin validate . --strict
```

## License

MIT — see [LICENSE](./LICENSE).
