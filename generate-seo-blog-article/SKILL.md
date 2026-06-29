---
name: generate-seo-blog-article
description: Draft SEO blog articles in a founder-engineer voice using plain Markdown. Includes article templates, voice principles, AI-wording blacklist, phrase bank, and pre-publish checks. Use when writing blog posts, briefing AI on brand voice, creating educational or product content, or when the user mentions SEO blog articles, content voice, or blog drafting.
license: MIT
metadata:
  version: 1.0.0
  category: marketing
  domain: content-marketing
  updated: 2026-06-29
  references: blog_voice_guide.md
---

# Generate SEO Blog Article

Draft product blog posts in a founder-engineer voice. Output is plain Markdown only: no frontmatter, no MDX, no framework components.

## Keywords

blog writing, SEO content, brand voice, founder voice, article templates, content drafting, educational posts, product announcements, listicles, technical deep dives, AI writing blacklist, markdown blog posts

## Quick Start

1. Read `references/blog_voice_guide.md` in full before drafting.
2. Confirm with the user (or brief): product name, author voice, article type, topic, target reader, and any required links or CTAs.
3. Pick the article template from section 4 of the voice guide.
4. Draft in plain Markdown following voice principles (section 2) and the chosen template.
5. Run the pre-publish scan (em dashes, Tier A/B blacklist, read-aloud check).
6. Add disclaimer (section 6) when the topic covers performance, outcomes, or regulated advice.

## Core Workflow

### 1. Gather inputs

Before writing, collect:

| Input | Example |
|-------|---------|
| Product name | Acme Platform |
| Author / voice | Jane Doe, co-founder |
| Article type | Educational / SEO |
| Topic | What is workflow versioning |
| Primary keyword | workflow versioning |
| Secondary keywords | version control, rollback |
| Target reader | Practitioners new to the concept |
| CTA | Free trial, docs link, waitlist |
| Links to include | Related posts, setup guide, community |

If any input is missing, use sensible placeholders and flag them in a short note at the end of the draft.

### 2. Choose article type

| Type | Use when |
|------|----------|
| Product announcement | Releases, features, plan changes |
| Educational / SEO | Glossary, what-is, how-it-works |
| Technical deep dive | Making-of, methodology, test results |
| Listicle | Best-of comparisons |
| Partnership / event | Integrations, co-marketing, events |
| Vision / philosophy | Roadmap, direction, teaser posts |

See section 4 of `references/blog_voice_guide.md` for structure per type.

### 3. Apply voice rules

Mandatory habits from the voice guide:

- Founder-engineer tone: what you built, tested, learned
- Mission before pitch: problem first, product second
- Honest limits: pros/cons, "when not to use"
- Ground claims: "we realized", "our tests show", specific numbers
- No em dashes (Unicode U+2014)
- Zero Tier A blacklist words (section 2 of voice guide)
- Replace Tier B red-flag words unless genuinely needed
- Product mentions concentrated in educational posts (usually one closing section)

### 4. Format output

Deliver **only** the article body as Markdown:

- `#` for title (H1)
- `##` / `###` for sections
- Standard `![alt](path)` images with italic captions below screenshots
- Plain `[text](url)` links
- `**bold**` for key decisions
- `>` blockquotes for punchy insights
- No YAML frontmatter
- No MDX imports or custom components

Track metadata separately (title, description, tags, date, reading time) only if the user asks for it, in a second block labeled "Metadata" after the article.

### 5. Pre-publish checklist

Before returning the draft:

1. [ ] Zero em dashes (U+2014)
2. [ ] Zero Tier A banned words/phrases
3. [ ] Tier B words reviewed and replaced where possible
4. [ ] No symmetric "Most people think X, but Y" hooks
5. [ ] Educational posts: product mention not stuffed in every paragraph
6. [ ] Deep dives / outcome posts: disclaimer included
7. [ ] Links: internal posts, docs, and external authorities where useful
8. [ ] Read-aloud test: sounds like a person, not Wikipedia or LinkedIn

## Article Type Defaults

| Type | Typical length | Difficulty | Disclaimer |
|------|----------------|------------|------------|
| Product announcement | 2–5 min read | Beginner | Usually skip |
| Educational / SEO | 2–5 min read | Beginner | Skip unless outcomes discussed |
| Technical deep dive | 8–12 min read | Advanced | Required |
| Listicle | ~3 min read | Beginner | Skip |
| Partnership / event | 1–2 min read | Beginner | Skip |
| Vision / philosophy | 4–6 min read | Beginner–intermediate | Skip unless outcome claims |

## Reference Files

| File | Purpose |
|------|---------|
| `references/blog_voice_guide.md` | Full voice guide: principles, blacklist, templates, phrase bank, disclaimers, AI prompt block |

## Default AI Drafting Prompt

When the user asks for a draft, use the prompt block in section 9 of `references/blog_voice_guide.md`. Substitute product, author, topic, and article type from the brief.

## Output Format Example

```markdown
# What Is Workflow Versioning?

![Diagram showing version history](/images/blog/workflow-versioning/cover.png)

Workflow versioning is the practice of tracking changes to a workflow over time so teams can compare, roll back, and audit what changed.

## What is workflow versioning?

...

## How Acme Platform helps

Acme Platform stores every workflow revision automatically. [Start a free trial](https://example.com/signup).
```

Return the article only unless the user also requests metadata, SEO notes, or a separate title/description pair.
