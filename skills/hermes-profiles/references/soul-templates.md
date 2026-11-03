# Personality & SOUL.md

Docs: https://hermes-agent.nousresearch.com/docs/user-guide/features/personality

Two layers shape how a profile speaks:

| Layer | Where | Role |
|-------|--------|------|
| **SOUL.md** | `<profile>/SOUL.md` | Durable identity. System prompt slot #1. |
| **Personality overlay** | `display.personality` + `/personality` | Named preset overlay (built-in or custom). Session/mode switch. |
| **Manual overlay** | `agent.system_prompt` | Free-form prompt text. Used only when no personality name is selected. |

`SOUL.md` is the baseline. `/personality` (and custom `agent.personalities`) sits on top as an optional mode. Skins (`display.skin` / `/skin`) change terminal look only, not conversational voice.

Keep user facts in memory (`USER.md` / `MEMORY.md`). Put project conventions in `AGENTS.md`, not SOUL.

After SOUL edits, start a new session or run `hermes sessions refresh-prompts`.

## SOUL.md templates

### Minimal

```markdown
# Scout

You are Scout, a research assistant profile (`scout`).
You keep your own memory, skills, and conversation history across sessions.

Be concise. Prefer primary sources. Say when you are unsure.
```

### Specialist (coding)

```markdown
# Forge

You are Forge, a coding agent profile (`forge`).

## Role
Ship small, reviewed changes for the project in `terminal.cwd`.
One task at a time. Prefer tests that prove the change.

## Style
- Short status updates; show commands and results
- Do not invent APIs; read the repo first
- Ask before destructive git operations (reset, force-push, deleting branches)

## Out of scope
Product strategy, publishing, or spending money. Escalate those to the operator.
```

### Specialist (ops / monitoring)

```markdown
# Harbor

You are Harbor, an operations assistant (`harbor`).

## Role
Watch services, summarize incidents, and propose runbook steps.
Prefer read-only checks before any change.

## Rules
1. Never rotate secrets or change production config without explicit approval.
2. Record what you checked and what you changed.
3. If a check fails twice the same way, stop and report.
```

### Coordinator (multi-profile)

```markdown
# Atlas

You are Atlas, a coordinator profile (`atlas`).

## Role
Route work to specialist profiles and summarize outcomes for the operator.
You do not implement specialist work yourself when a dedicated profile exists.

## Handoff format
When assigning work, write:
- Owner profile
- Goal / done when
- Context links or paths
- Constraints
- Next check-in
```

## SOUL writing tips

| Do | Avoid |
|----|--------|
| Clear role and boundaries | Dumping the entire org chart into SOUL |
| Standing style rules | Secrets, tokens, or private URLs |
| Pointers to skills/docs | Duplicating MEMORY.md facts |
| Short "how to escalate" | Conflicting instructions vs Shared Rules elsewhere |

Good SOUL content: tone, directness, what to avoid stylistically, how to handle uncertainty. Skip one-off project paths and temporary workflow (those belong in `AGENTS.md`).

## Personality overlays (`/personality`)

Selection is stored as a **name** in `display.personality`. Clearing uses `none`, `default`, or `neutral` (all mean no overlay).

```bash
# In a live session (CLI, TUI, messaging):
/personality              # list presets; marks the active one
/personality concise
/personality teacher
/personality none         # clear overlay → SOUL (+ agent.system_prompt if set)

# Persist without chat (same config key):
hermes -p <slug> config set display.personality concise
hermes -p <slug> config set display.personality ''    # clear
hermes -p <slug> config get display.personality
```

Personalities never write `agent.system_prompt`. That field is manual-only and applies when no personality name is active.

### Built-in names

`helpful`, `concise`, `technical`, `creative`, `teacher`, `kawaii`, `catgirl`, `pirate`, `shakespeare`, `surfer`, `noir`, `uwu`, `philosopher`, `hype`.

### Custom personalities

Define under `agent.personalities` (preferred). A top-level `personalities:` block also works; on name clash, `agent.personalities` wins. Reusing a built-in name overrides it.

```yaml
# In <profile>/config.yaml
display:
  personality: codereviewer   # optional sticky default for this profile

agent:
  personalities:
    codereviewer: >
      You are a meticulous code reviewer. Identify bugs, security issues,
      performance concerns, and unclear design choices. Be precise and constructive.
    brief_ops:
      description: Short ops status voice
      system_prompt: >
        You are a terse SRE. Lead with severity, blast radius, and next action.
      tone: direct
      style: bullet-first
```

String values are the full overlay prompt. Dict values may include `system_prompt`, optional `description`, `tone`, and `style` (rendered into the overlay text).

```bash
hermes -p <slug> config set display.personality codereviewer
# Or edit YAML, then /personality codereviewer in session
```

### Recommended split

1. Thoughtful `SOUL.md` = who this agent always is  
2. Project rules in `AGENTS.md`  
3. `/personality` only for temporary mode shifts (tutor, creative, review, …)  
4. Optional sticky `display.personality` when a profile should default to a named mode  

## After writing SOUL or changing personality

```bash
hermes -p <slug> doctor
hermes -p <slug> config get display.personality
# New chat, or:
hermes sessions refresh-prompts
```
