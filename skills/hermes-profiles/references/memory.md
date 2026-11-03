# Profile memory settings

Docs:
- https://hermes-agent.nousresearch.com/docs/user-guide/features/memory
- https://hermes-agent.nousresearch.com/docs/user-guide/features/memory-providers

Memory is **per profile**. Paths are under that profile's home:
`$HERMES_HOME/memories/` for `default`, or `$HERMES_HOME/profiles/<slug>/memories/` for named agents.

One writer per profile. Shared knowledge across profiles needs an external provider, not two processes on the same home.

## Layers

| Layer | What it is | Always on? |
|-------|------------|------------|
| **Built-in stores** | `MEMORY.md` (agent notes) + `USER.md` (user profile) | Yes unless disabled in config |
| **Session search** | FTS5 over past chats in `state.db` (`session_search` tool) | Separate from curated memory |
| **External provider** | One plugin at a time (retaindb, byterover, honcho, hindsight, …) | Optional; additive to built-in |

Built-in files inject as a **frozen snapshot** at session start (prefix-cache friendly). Mid-session tool writes hit disk immediately but appear in the prompt only on the next session. Prefer `/new` (or a fresh CLI run) at natural boundaries so curated memory reloads.

## Built-in files

| File | Purpose | Default char limit |
|------|---------|-------------------|
| `memories/MEMORY.md` | Environment, conventions, lessons | 2200 (~800 tokens) |
| `memories/USER.md` | User prefs, communication style | 1375 (~500 tokens) |

The agent manages them via the `memory` tool (`add` / `patch` / `remove`, target `memory` or `user`). Writes that would overflow return an error; the agent must free space in the same batch. Exact duplicates are rejected. Entries are scanned for injection patterns.

```bash
# Inspect (never dump secrets from elsewhere into chat)
ls "$HERMES_HOME/profiles/<slug>/memories/"
# default profile:
ls ~/.hermes/memories/
```

## `memory.*` config keys

In `<profile>/config.yaml`:

```yaml
memory:
  memory_enabled: true          # agent notes store + guidance
  user_profile_enabled: true    # USER.md store
  memory_char_limit: 2200
  user_char_limit: 1375
  write_approval: false         # true = gate all saves (CLI inline; else staged)
  nudge_interval: 10            # turns between built-in memory review prompts; 0 when external auto-extracts
  prefetch_spill_enabled: false # true = spill oversized external recall to file preview
  provider: ""                  # empty = built-in only; else one external name
```

```bash
hermes -p <slug> config set memory.memory_enabled true
hermes -p <slug> config set memory.user_profile_enabled true
hermes -p <slug> config set memory.memory_char_limit 2200
hermes -p <slug> config set memory.user_char_limit 1375
hermes -p <slug> config set memory.write_approval false
hermes -p <slug> config set memory.nudge_interval 10
hermes -p <slug> config get memory.provider
```

| Goal | Settings |
|------|----------|
| Normal built-in memory | both `*_enabled: true` (defaults) |
| User profile only | `memory_enabled: false`, `user_profile_enabled: true` |
| Agent notes only | inverse |
| Turn built-in off (keep external) | both `*_enabled: false` |
| Hide built-in **and** external memory tools | put `memory` under `agent.disabled_toolsets` |
| Approve every save | `write_approval: true` |

### Write approval

With `write_approval: true`, interactive CLI prompts inline; messaging / scripts / background review **stage** writes:

```text
/memory pending
/memory approve <id>|all
/memory reject <id>|all
/memory approval on|off
```

### Chat notifications

Background self-improvement may save memory after a turn:

```yaml
display:
  memory_notifications: on    # off | on | verbose
  # optional per platform:
  # platforms:
  #   telegram:
  #     memory_notifications: verbose
```

```bash
hermes -p <slug> config set display.memory_notifications on
```

This only controls the gateway chat line. Writes still run.

### Cheaper / quieter background review

Related (not under `memory.*`): `auxiliary.background_review.*` (model, `enabled`, `max_input_tokens`, `defer`, …). See models doc / official memory page. Same-model reviews inherit parent reasoning effort.

## External providers

Only **one** external provider at a time. Built-in stays active alongside it unless you disable the built-in stores.

Bundled examples: `retaindb`, `byterover`. Catalog (install first): `honcho`, `hindsight`, `supermemory`, `mem0`, `openviking`, `holographic`.

```bash
hermes -p <slug> memory setup              # picker + configure
hermes -p <slug> memory setup honcho       # skip picker when known
hermes -p <slug> memory status
hermes -p <slug> memory off                # external off; built-in remains
# Or:
hermes -p <slug> config set memory.provider retaindb
hermes plugins install honcho              # catalog providers before setup
```

Provider-specific secrets/config often live beside the profile (for example Honcho `honcho.json` under the profile home). Clone copies provider config when present; give clones their own bank/peer ids when the provider docs say so.

When active, Hermes typically: injects provider context, prefetches before turns, syncs turns, extracts on session end, mirrors built-in writes, and adds provider tools. Content handed to providers is secret-scrubbed first.

`memory.prefetch_spill_enabled: true` replaces oversized external recall with a head/tail preview + file path (uses `hooks.output_spill` thresholds). Prefer the provider's own recall budget when available. Restart after changing spill settings.

## Reset built-in stores

Destructive. Confirm with the user first.

```bash
hermes -p <slug> memory reset              # both MEMORY.md and USER.md
hermes -p <slug> memory reset --target memory
hermes -p <slug> memory reset --target user
hermes -p <slug> memory reset --yes        # only after explicit approval
```

## Session search vs curated memory

| | Built-in MEMORY/USER | `session_search` |
|--|----------------------|------------------|
| Capacity | Char-limited | All sessions in `state.db` |
| In every prompt | Yes (frozen) | No (on demand) |
| Use | Always-needed facts | "Did we discuss X?" |

```bash
hermes -p <slug> sessions list
```

## Learning journey

Timeline of learned skills + memory chunks:

```bash
hermes -p <slug> journey              # also: learning, memory-graph
hermes -p <slug> journey list
hermes -p <slug> journey edit <node>
hermes -p <slug> journey delete <node>   # confirm; skills archive, memory chunks remove
# In session: /journey
```

## Clone / multi-profile notes

- `--clone` copies curated `MEMORY.md` / `USER.md` (identity-like). Fresh blank memory: create without `--clone`, or clear/reset after.
- Two gateways on the same profile corrupt memory. Use separate profiles.
- Cross-profile shared user modeling: external provider (for example Honcho workspace + per-profile AI peer).

## Quick checklist

```bash
hermes -p <slug> memory status
hermes -p <slug> config get memory.memory_enabled
hermes -p <slug> config get memory.user_profile_enabled
hermes -p <slug> config get memory.write_approval
hermes -p <slug> config get memory.provider
hermes -p <slug> config get display.memory_notifications
# After enabling/disabling stores or changing limits, start a new session
```
