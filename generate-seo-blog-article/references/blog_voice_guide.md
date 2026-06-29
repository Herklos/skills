Reusable reference for drafting blog articles in a founder-engineer voice. Adapt product name, author, links, and domain-specific disclaimers to your context before use.

---

## 1. Purpose

Use this document when:

- Writing a new blog post from scratch
- Briefing someone (or an AI) to draft in your voice
- Reviewing a draft before publishing

**Workflow:** Pick an article type (section 5) → follow its template → apply voice principles (section 3) → check the AI-wording blacklist (section 3, Avoid AI-like writing) → format as plain Markdown (section 6) → check the Do/Don't list (section 9).

For major product direction teasers, use the **Vision / philosophy** template. Lead with philosophy and curiosity; save feature details for later; end with a clear CTA (waitlist, signup, or feedback invite).

---

## 2. Voice principles

1. **Founder-engineer, not agency copy.** Explain what you built, what you tested, and what you learned. Ground claims in real work: "After running tons of tests…", "we realized that for most users, this threshold is usually around 80%."

2. **Mission before pitch.** Open with the problem or insight, not the product. Your product appears naturally as the answer after the reader understands why it matters.

3. **Honest about limits.** How-to, comparison, and deep-dive posts always include drawbacks, risks, or "when not to use." Never imply guaranteed outcomes.

4. **Simple and direct.** Short-to-medium sentences. Numbered lists for steps, features, pros/cons. Bold for key decisions. Blockquotes for punchy takeaways after a setup paragraph.

5. **Conversational enthusiasm, sparingly.** "We're very excited to announce…", "We even saw great results!": use for launches and milestones, not every paragraph.

6. **Show your reasoning.** When introducing a paid plan, a design choice, or a configuration option, explain *why*: operating costs, user feedback, test results.

7. **Educate first on SEO posts.** Define the term, explain context, give pros/cons, then mention how your product helps, often in a short closing section, not woven through every paragraph.

8. **Preserve authentic rhythm.** Light non-native-English patterns are fine ("overal", "naratives", "it allows to"). Do not over-polish into generic American marketing prose.

9. **Transparency as a value, not a slogan.** Reference open source, testing, sandbox modes, and visible results when relevant, with specifics, not vague claims.

10. **Disclaimers on sensitive content.** Any article discussing performance, settings, regulated topics, or outcome claims should end with the standard disclaimer block (section 7).

### Avoid AI-like writing

Blog posts must not read like generic AI output. This applies to human and AI drafts. See also principle 8 (do not over-polish) and section 9 Don't.

**Never use the em dash (Unicode U+2014).** Use a comma, period, colon, or parentheses instead.

- Bad: "Open-source software is powerful [em dash] but requires technical setup."
- Good: "Open-source software is powerful, but requires technical setup."

#### Tier A: hard ban (zero tolerance)

| Category | Banned |
|----------|--------|
| Punctuation | em dash (U+2014) |
| Verbs | leverage, delve, embark, harness, foster, utilize, underscore, showcase, navigate (metaphorical) |
| Transitions | moreover, furthermore, additionally, in conclusion, in essence, ultimately, at the end of the day |
| Openers | in today's fast-paced world, in today's world, in the realm of, when it comes to, let's dive in |
| Importance filler | it's important to note, it's worth noting, plays a crucial/vital role, crucial role in shaping |

#### Tier B: red-flag (replace on sight)

| Category | Watch list |
|----------|------------|
| Adjectives | robust, seamless, holistic, comprehensive, multifaceted, nuanced, pivotal, intricate, meticulous, groundbreaking, ever-evolving, dynamic, vibrant |
| Nouns / metaphors | landscape, realm, tapestry, testament, beacon, symphony, ecosystem (when vague), paradigm, synergy |
| Verbs | unlock, elevate, facilitate, supercharge, turbocharge |
| Phrases | deep dive, game-changer, cutting edge, secret sauce, moves the needle, at its core |

#### Tier C: structural patterns (rewrite the sentence)

- Symmetric hook: "Most people think X, but the truth is Y"
- Correlative frame: "not just X, but Y" / "it's not about X, it's about Y"
- Perfect rule-of-three lists where every item has identical grammatical shape and length
- Paragraph openers: *Certainly,* *Notably,* *Importantly,* *Interestingly,*
- Chat residue: "I hope this helps", "Let me know if you'd like"
- Hedging stacks: "often", "generally", "it's worth considering" piled in one paragraph

#### What to write instead

| AI default | Use instead |
|------------|-------------|
| leverage | use |
| delve | look at, examine |
| utilize | use |
| moreover / furthermore | and, also, or start the sentence |
| robust | strong, reliable |
| seamless | smooth, easy |
| in conclusion | (delete; state the point) |
| it's important to note that X | X |

#### Pre-publish scan

1. Search draft for em dashes (must be zero)
2. Search for Tier A words (must be zero)
3. Scan Tier B; replace anything that is not genuinely needed
4. Read aloud: if it sounds like a Wikipedia article or a LinkedIn post, shorten and specify

### Tone sliders

| Dimension | Your style | Avoid |
|-----------|-------------|-------|
| Formality | Conversational, direct | Corporate infrastructure essay |
| Sentence length | Short-to-medium, lists | Em dashes (U+2014) or em-dash-heavy compound sentences |
| Claims | "We realized", "our tests show" | Abstract systems language ("execution infrastructure") |
| Sales | Explain why, then link | Hard sell without reasoning |
| Risk | Explicit pros/cons, disclaimers | Implied guarantees |

### What NOT to sound like

Avoid formal third-person systems analysis, em-dash prose, and vague SEO infrastructure vocabulary. Your voice is personal, experiment-driven, and team-narrative ("At [Company], we realized…").

---

## 3. Messaging pillars

Weave these in naturally, never as a bullet list in the article body. Customize to your product.

| Pillar | How it shows up in posts |
|--------|--------------------------|
| **Simplicity** | "It shouldn't be more complicated than this." Tiered plans vs full product complexity. |
| **Transparency** | Open source repos, test results, sandbox or trial modes, visible performance data. |
| **Accessibility** | Free tier, no hidden fees, partner programs funding free access. |
| **Community** | Feedback channels, forums, chat groups, public roadmap, user-driven priorities. |
| **Open source** | Public codebase as backbone; customization; auditability. |
| **Privacy / control** | User-owned data, local-first options, clear data handling. |

---

## 4. Article templates

### A. Product announcement

**When:** Version releases, new features, app revamps, plan changes.

**Structure:**

1. **H1** = title (often "Introducing X" or "[Product] X.Y.Z - What's new")
2. **Cover image** (standard Markdown image)
3. **Hook**: excitement + numbered list of major changes (2–4 items)
4. **One H2 per major feature**: what it is, why it matters, screenshot(s)
5. **"Other improvements"**: bug fixes, integration updates, minor items
6. **Optional CTA**: link to signup, trial, or docs
7. **Closing**: "We hope you will enjoy…" / invite feedback

**Length:** 2–5 min read

**Opening patterns:**

- "We're very excited to announce the release of [Product] X.Y.Z!"
- "When building [workflow], the hardest part is often to validate it before launch…"

---

### B. Educational / SEO

**When:** What-is posts, glossary entries, how-it-works explainers, concept guides.

**Structure:**

1. **H1** = title (often "Understanding X" or "What is X")
2. **One-line definition** in the opening paragraph (no heading)
3. **H2 sections**: one concept per section:
   - What is X
   - Why X matters
   - Pros / cons (or psychology, examples, how to handle it)
   - How [Product] helps (short closing section)
4. **Optional:** Table of contents (longer posts), cover image
5. **Conclusion**: brief wrap-up (optional on short glossary posts)

**Length:** 2–5 min read

**Opening patterns:**

- Direct definition: "[TERM], short for '[expansion]' is when [simple definition]."
- Context hook: "When choosing how to [task], there are a lot of different approaches…"
- "Welcome to your guide to…" (longer guides only)

**Product mention:** Usually one section near the end, not every paragraph.

---

### C. Technical deep dive

**When:** Making-of posts, technical explanations, methodology breakdowns.

**Structure:**

1. **H1** = title (often "X making of" or "X deep dive")
2. **Optional:** video embed link or summary at top
3. **Origin story**: "At [Company], we are always trying to find better ways to [solve problem]…"
4. **H2: Introducing [topic]**: concept, link to authority source, blockquote insight
5. **H2: Video summary** (if video): H3 pros and cons as numbered lists
6. **H2: When to use**: conditions, limitations with honesty
7. **H2: Deep dive / technicals**: H3 subsections, screenshots with captions, specific numbers from tests
8. **H2: Other resources**: links to guides and related blog posts
9. **H2: Disclaimer**: standard block (section 7)

**Length:** 8–12 min read

**Key habits:**

- Always pair advantages with drawbacks
- Cite test results with specifics (thresholds, sample sizes, edge cases)
- Cross-link to related posts and docs
- Images with italic captions under screenshots

---

### D. Listicle

**When:** "Best X tools" or comparison posts.

**Structure:**

1. **H1** = numbered title ("10 Best Paid and Free [Category] Tools")
2. **Brief intro**: why choosing is hard, what the article covers
3. **H2: What is a [topic]?**: 2–3 sentences
4. **H2 per entry**: `## 1. [Your product]` first, then competitors
5. Each entry: description paragraph + optional rating summary (Ease of use, Price, Features)
6. Your product entry is longest and links to docs, open source, and key capabilities

**Length:** 3 min read

**Tone:** Neutral-comparative for competitors; warmer and more detailed for your product.

---

### E. Partnership / event

**When:** Integrations, co-marketing, events, ecosystem announcements.

**Structure:**

1. **H1** = announcement headline
2. **Cover image**
3. **Opening**: "[Product] is excited to announce…"
4. **H2: What is [partner]**: brief partner description with external link
5. **H2: How to use [X] with [Product]**: link to setup guide
6. **Optional:** "Final words" for partner-specific posts

**Length:** 1–2 min read

---

### F. Vision / philosophy

**When:** Major direction changes, roadmap, platform launch, accessibility revamps, product philosophy teasers.

**Structure:**

1. **H1** = vision title
2. **Optional:** video link or embed summary for major launches
3. **Problem observed**: "At [Company], we realized that…"
4. **What we decided**: bold pivot line: **We decided to change that.**
5. **Numbered principles or plan tiers**: what changes and why
6. **Transparency / honesty section**: risks, limitations, how free tiers stay sustainable
7. **Continuity**: reassure existing users nothing is abandoned
8. **Invite feedback**: feedback site, community channels, beta program
9. **CTA**: waitlist, start link, or "join us"

**Length:** 4–6 min read

**For product teaser posts specifically:**

- Curiosity first; don't explain everything
- Narrative arc: where the space is today → what's missing → new philosophy
- Name a small set of pillars (3–6) that define the direction
- End with beta or early-access CTA

---

## 5. Markdown formatting

Output plain Markdown only. No frontmatter, no framework-specific components, no custom tags.

### Document structure

```markdown
# Article Title

![Cover alt text](/images/blog/your-article-slug/cover.png)

Opening paragraph with hook or definition.

## First major section

Content with **bold for key decisions** and numbered lists where helpful.

> Blockquote for a punchy insight after setup.

## Next section

![Screenshot alt text](/images/blog/your-article-slug/screenshot.png)
*Italic caption under the screenshot*

[Internal link to related post](related-post-slug)

[Link to docs](/guides/getting-started)
```

### Images

- Use standard Markdown: `![alt text](path)`
- Add an italic caption on the line below screenshots
- Prefer descriptive alt text and file names

### Links

- **External:** `[Link text](https://example.com)`
- **Internal blog:** `[Post title](post-slug)`
- **Docs:** `[Guide name](/guides/section/page)`

### Blockquotes

Use for insights, pivots, or memorable lines after a setup paragraph:

```markdown
> After running tons of tests, we realized this approach also works well in shorter cycles.
```

### CTAs

Plain Markdown links or short callout paragraphs. No custom button components.

```markdown
[Start your free trial](https://example.com/signup)

Or join the [beta waitlist](https://example.com/waitlist).
```

### Metadata (keep separate from the article body)

Track these outside the Markdown file (CMS, spreadsheet, or brief):

- Title
- Meta description (1–2 sentences for SEO and social previews)
- Tags
- Cover image path
- Publish date
- Author
- Difficulty level (1 = beginner, 2 = intermediate, 3 = advanced)
- Estimated reading time (minutes)

---

## 6. Phrase bank

### Openings

| Context | Example |
|---------|---------|
| Origin story | "At [Company], we are always trying to find better ways to [solve problem]. After experimenting with many approaches, we realized that sometimes, keeping it simple just works." |
| Product insight | "At [Company], we realized that the current product works well for technical users but is too complex for most people." |
| Mission statement | "At [Company], our mission is to make [outcome] simpler." |
| Release excitement | "We're very excited to announce the release of [Product] 2.0!" |
| Partnership | "[Product] is excited to announce that it has joined [Partner]…" |
| Glossary / SEO | "[TERM], short for '[expansion]' is when [simple definition]." |
| Guide intro | "Welcome to your guide to [topic]. After reading this post, you'll have a clear understanding of…" |

### Transitions

- "Therefore, …"
- "This means that …"
- "Following this philosophy, …"
- "Let's now explore …"
- "More details on …"
- "Similarly to [related article], …"
- "In the end, …"
- "Of course, …" (before nuance or caveat)

### Pivot / decision lines

- **We decided to change that.**
- "The goal with [X] is to …"
- "While [A] is designed to [X], [B] makes it very easy to [Y]"

### Closings

- "We hope you will enjoy the new [feature]!"
- "We hope that you will enjoy those changes and can't wait to get your feedback."
- "Feel free to use, experiment and give us your feedback on …"
- "If you have ideas for features you'd like to see, please reach out."
- "In the end, [topic] offers … Stay engaged with the community, keep your software updated, and embrace what's ahead."

### Blockquote-worthy insights

- "How is this possible? With our free tier, we rely on partner programs to cover running costs."
- "Those offers will now explicitly target users who want to create or customize workflows."
- "[Method] is an attempt to [goal] from [mechanism], but not by predicting every variable."

### Standard disclaimer (performance / outcome content)

Adapt the domain and legal wording to your product and jurisdiction.

```markdown
## Disclaimer

Please be advised that the contents of this article are intended for general information purposes only and not professional advice. The information contained herein is for informational purposes only. Nothing herein shall be construed as legal, financial, or tax advice. The content of this article reflects the opinions of the author and/or the [Company] team. None of the authors are licensed advisors in regulated fields unless explicitly stated. Using any product or method discussed here may involve risk. The author and/or [Company] does not guarantee any particular outcome. Past results do not indicate future results.
```

Use `## Warning` instead of `## Disclaimer` on shorter posts; same text.

**When to include:** Deep dives, performance discussions, articles with specific outcome claims or test results. Skip for pure glossary, partnerships, and simple product announcements.

---

## 7. Linking habits

### Internal blog cross-links

Link to related posts by slug. Build a web: deep dives reference each other; platform posts reference plan or launch posts.

### Documentation links (high value)

Link to setup guides, core concepts, integrations, and configuration pages wherever the reader would need them next.

### Product pages

Link to homepage, pricing, feature pages, and signup when relevant. One clear CTA is enough.

### External authorities

Link to reputable sources for definitions, standards, and third-party context (industry publications, official docs, well-known references).

### Community

Link to feedback portals, forums, chat channels, and roadmap pages when inviting input.

---

## 8. Do / Don't

### Do

- Start with insight, problem, or definition, not "In today's fast-paced world…"
- Use numbered lists for features, steps, pros/cons
- Include drawbacks and "when not to use" on how-to and comparison content
- Explain pricing or paid features with reasoning (operating costs, development effort)
- Cross-link to docs and related blog posts
- Use real numbers from your tests when available
- Keep educational posts useful even if the reader never uses your product
- End sensitive posts with the standard disclaimer
- Match author attribution to whoever actually wrote the piece

### Don't

- Never use em dashes (Unicode U+2014)
- Never use Tier A blacklist words/phrases (section 2, Avoid AI-like writing)
- Replace Tier B red-flag words unless no simpler alternative exists
- Write like a formal infrastructure essay (em-dash chains, vague "execution infrastructure" vocabulary, no team narrative)
- Imply guaranteed outcomes or downplay risks
- Open with hard sell or feature dump on vision posts
- Over-polish grammar into generic marketing English; your voice is direct, not corporate
- Use "In conclusion" on every post; only when the article is long enough to need a wrap-up
- Stuff product mentions into every paragraph of educational content
- Skip pros/cons on anything involving methods, tools, or outcome claims
- Use regulated-advisor language ("we recommend you…") unless you are qualified to give that advice

---

## 9. AI prompt block

Copy-paste this when asking an AI to draft a blog post. Fill in bracketed placeholders.

```
Write a blog article in [Author Name]'s voice ([Role] at [Company]).

Voice rules:
- Founder-engineer explaining to practitioners, not a marketing agency
- Use "we" for team decisions, "you" for the reader
- Ground claims in experiments and real observations ("we realized", "our tests show")
- Always honest about limits and drawbacks
- Mission-first: simplicity, transparency, accessibility, open source, community (where applicable)
- Conversational and direct; short-to-medium sentences; numbered lists for features/pros/cons
- Bold for key decisions; blockquotes for punchy insights
- Do NOT sound like a formal infrastructure essay: no em-dash chains, no corporate systems tone
- Light non-native-English patterns are OK; don't over-polish
- Anti-AI rules (mandatory):
  - NEVER use em dashes (Unicode U+2014). Use commas, periods, or colons.
  - NEVER use: leverage, delve, embark, moreover, furthermore, additionally, in conclusion, in today's fast-paced world, let's dive in, it's important to note, plays a crucial role, in the realm of, when it comes to
  - Avoid: robust, seamless, holistic, tapestry, landscape, realm, pivotal, not just X but Y framing
  - Vary sentence length. Prefer specific numbers and observations over vague importance language.

Article type: [Product announcement | Educational/SEO | Technical deep dive | Listicle | Partnership | Vision/philosophy]

Topic: [YOUR TOPIC]

Product: [PRODUCT NAME]

Structure: Follow the template for this article type from blog_voice_guide.md section 4.

Output: Plain Markdown only. No frontmatter, no MDX, no custom components.

Include:
- Disclaimer at end if discussing performance, outcomes, or regulated topics
- Internal and external links where helpful
- Image placeholders with alt text and caption pattern where screenshots apply
```

---

## Quick reference: article type → template

| Type | Template | Typical reading time |
|------|----------|----------------------|
| Product announcement | A | 2–5 min |
| Educational / SEO | B | 2–5 min |
| Technical deep dive | C | 8–12 min |
| Listicle | D | 3 min |
| Partnership / event | E | 1–2 min |
| Vision / philosophy | F | 4–6 min |
