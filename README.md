# Herklos Skills

Product-agnostic agent skills for content, marketing, and agent-ops workflows. Compatible with **Claude Code**, **Cursor**, and other skills installers.

## Skills

| Skill | Language | Description |
|-------|----------|-------------|
| [generate-seo-blog-article](./skills/generate-seo-blog-article/SKILL.md) | EN | Draft SEO blog articles in founder-engineer voice (plain Markdown) |
| [generate-seo-blog-article-fr](./skills/generate-seo-blog-article-fr/SKILL.md) | FR | Rédiger des articles de blog SEO en français, voix fondateur-ingénieur |
| [hermes-profiles](./skills/hermes-profiles/SKILL.md) | EN | Manage Hermes Agent profiles (create, clone, config, gateway) |
| [anytype-agents](./skills/anytype-agents/SKILL.md) | EN | Manage multi-agent org pages in Anytype via MCP (discover, create, route) |

## Repository layout

```
.
├── .claude-plugin/
│   ├── plugin.json          # Claude Code plugin manifest (bundle)
│   └── marketplace.json     # Marketplace catalog (bundle + individual skills)
├── .agents/plugins/
│   └── marketplace.json     # Cursor / agent marketplace catalog
├── skills/
│   ├── generate-seo-blog-article/
│   │   ├── SKILL.md
│   │   └── references/blog_voice_guide.md
│   ├── generate-seo-blog-article-fr/
│   │   ├── SKILL.md
│   │   └── references/guide_voix_blog.md
│   ├── hermes-profiles/
│   │   ├── SKILL.md
│   │   └── references/profile-map.md
│   └── anytype-agents/
│       ├── SKILL.md
│       └── references/{structure,page-templates}.md
├── LICENSE
└── README.md
```

## Installation

### Claude Code (marketplace)

```bash
# Add this repository as a marketplace
claude plugin marketplace add Herklos/skills

# Install the full bundle (EN + FR)
claude plugin install seo-blog-skills@herklos-skills

# Or install a single skill
claude plugin install generate-seo-blog-article@herklos-skills
claude plugin install generate-seo-blog-article-fr@herklos-skills
claude plugin install hermes-profiles@herklos-skills
claude plugin install anytype-agents@herklos-skills
```

### Claude Code (local dev / test)

```bash
git clone https://github.com/Herklos/skills.git
claude --plugin-dir ./skills
```

### Cursor

Install from the marketplace UI, or add this repo as a plugin source via `.agents/plugins/marketplace.json`.

### ai-agent-skills (Claude, Cursor, Codex, and others)

```bash
# Full bundle
npx ai-agent-skills install Herklos/skills

# Single skill
npx ai-agent-skills install Herklos/skills/skills/generate-seo-blog-article
npx ai-agent-skills install Herklos/skills/skills/generate-seo-blog-article-fr
npx ai-agent-skills install Herklos/skills/skills/hermes-profiles
npx ai-agent-skills install Herklos/skills/skills/anytype-agents

# Target a specific agent
npx ai-agent-skills install Herklos/skills --agent cursor
npx ai-agent-skills install Herklos/skills --agent claude
```

### Manual install

Copy a skill folder into your agent skills directory:

```bash
# Claude Code
cp -r skills/generate-seo-blog-article ~/.claude/skills/
cp -r skills/generate-seo-blog-article-fr ~/.claude/skills/
cp -r skills/hermes-profiles ~/.claude/skills/
cp -r skills/anytype-agents ~/.claude/skills/

# Cursor (project-level)
mkdir -p .cursor/skills
cp -r skills/generate-seo-blog-article .cursor/skills/
cp -r skills/generate-seo-blog-article-fr .cursor/skills/
cp -r skills/hermes-profiles .cursor/skills/
cp -r skills/anytype-agents .cursor/skills/
```

## Validation

If you have the Claude Code CLI:

```bash
claude plugin validate .
claude plugin validate . --strict
```

## License

MIT — see [LICENSE](./LICENSE).
