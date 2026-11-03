# Display, skins, and Desktop prefs

Docs:
- https://hermes-agent.nousresearch.com/docs/user-guide/configuration (Display Settings)
- https://hermes-agent.nousresearch.com/docs/user-guide/features/skins
- https://hermes-agent.nousresearch.com/docs/user-guide/desktop (Appearance, ui-preferences)

Per-profile unless noted. Working directory / projects: `workspace.md`. Personality voice (`display.personality`): `soul-templates.md`.

## Quick map

| Concern | Keys / CLI |
|---------|------------|
| Chat / terminal fonts (Desktop) | `desktop.font_family`, `terminal.font_family` |
| CLI/TUI/gateway progress & chrome | `display.*` |
| Skin (look) vs personality (voice) | `display.skin` / `/skin` vs `display.personality` |
| Computer-wide Desktop prefs | `$HERMES_HOME/ui-preferences.json` (root home, not a profile folder) |

## Fonts (Desktop, per profile)

```yaml
desktop:
  font_family: ""          # Chat Font; blank = theme font (e.g. OpenDyslexic)
terminal:
  font_family: ""          # Terminal pane; blank = bundled JetBrains Mono
                           # Nerd Fonts e.g. "MesloLGS NF" for shell icons
```

```bash
hermes -p <slug> config set desktop.font_family "Atkinson Hyperlegible"
hermes -p <slug> config set terminal.font_family "MesloLGS NF"
```

Settings → Appearance → Chat Font / Terminal Font.

## Display (`display.*`, per profile)

```yaml
display:
  tool_progress: all              # off | new | all | verbose  (/verbose cycles)
  tool_progress_command: false    # allow /verbose on messaging gateways
  focus_view: false               # /focus — display-only quiet mode
  platforms: {}                   # per-platform overrides (see below)
  interim_assistant_messages: true
  suppress_warning_notifications: false
  show_commentary: true           # Codex commentary channel mid-turn
  skin: default                   # CLI/Desktop look (/skin); not voice
  personality: ""                 # named voice overlay — see soul-templates.md
  compact: false
  cli_multiline_shortcuts: true
  resume_display: full            # full | minimal (recap on resume)
  bell_on_complete: false
  bell_on_prompt: false           # also OSC 9 / Warp CLI-agent events when supported
  show_reasoning: true            # /reasoning show|hide
  streaming: false
  show_cost: false
  vim_mode: false                 # CLI composer; read at startup
  timestamps: false
  timestamp_format: "%H:%M"
  tool_preview_length: 0          # 0 = no limit
  turn_summary: true              # CLI post-turn accounting line
  spinner_token_flow: true
  runtime_footer:                 # gateway final-reply provenance
    enabled: false
    fields: ["model", "context_pct", "cwd"]
  status_bar:
    fields: []                    # empty = default set (CLI/TUI)
  file_mutation_verifier: true
  credits_notices: true
  memory_notifications: on        # off | on | verbose — see memory.md
  language: en                    # static UI strings only (approval prompts, …)
  busy_ack_enabled: true          # gateway busy acks (⚡/⏳/⏩)
```

```bash
hermes -p <slug> config set display.skin slate
hermes -p <slug> config set display.tool_progress all
hermes -p <slug> config set display.show_reasoning true
hermes -p <slug> config set display.streaming false
hermes -p <slug> config set display.resume_display full
hermes -p <slug> config set display.language en
# In session: /skin <name>  /verbose  /focus  /reasoning show|hide
```

### Tool progress

| Mode | What you see |
|------|----------------|
| `off` | Final response only (task list / clarify / MCP consent still show) |
| `new` | Indicator when the tool changes |
| `all` | Every tool call with a short preview (default) |
| `verbose` | Full args, results, debug |

Per-platform overrides (quiet Slack, verbose Telegram, …):

```yaml
display:
  tool_progress: all
  platforms:
    slack:
      tool_progress: "off"
    telegram:
      tool_progress: verbose
    signal:
      tool_progress: "off"    # Signal cannot show progress bubbles today
```

Focus view (`/focus`) pins progress to `off` and restores the previous mode on
`/focus off`. Display-only: does not change history or prompts.

### Skin vs personality

| | Skin | Personality |
|--|------|-------------|
| Changes | Colors, spinner, branding, CLI chrome | Conversational tone / wording |
| Key | `display.skin` / `/skin` | `display.personality` / `/personality` |
| Custom | `$HERMES_HOME/skins/<name>.yaml` (or profile home skins) | `agent.personalities` |

Built-in skins include `default`, `ares`, `mono`, `slate`, `daylight`,
`warm-lightmode`, `poseidon`, `sisyphus`, `charizard`. On Desktop, `default`
maps to the Nous theme; classic gold is Desktop theme `classic` (`/skin classic`).
`/skin` is session-scoped until you `config set display.skin`. Full skin YAML:
skins docs.

### Status bar and gateway footer

`display.status_bar.fields` controls CLI/TUI visibility (order is fixed). Empty
list = defaults. Opt-in examples: `total_tokens`, `git_branch`. Supported names
include `model`, `context_pct`, `context_detail`, `cache_hit`, `latency`, `tps`,
`compressions`, `bg_tasks`, `duration`, `focus`, `yolo`, …

Gateway-only provenance line:

```bash
hermes -p <slug> config set display.runtime_footer.enabled true
# fields: model, context_pct, cwd
```

### UI language

`display.language` translates a small set of **static** strings (approval
prompts, some gateway notices). It does not translate model replies. Bundled ids
include `en`, `zh`, `zh-hant`, `ja`, `de`, `es`, `fr`, … Session override:
`HERMES_LANGUAGE`. Language packs / `<HERMES_HOME>/locales/` can add ids.

## Computer-wide Desktop preferences

Theme/light-dark, sidebar density, layout, sounds, keybinds, model-picker
favourites, tips/tours seen: stored once per computer in

`$HERMES_HOME/ui-preferences.json`

(root Hermes home, **never** inside `profiles/<slug>/`). Desktop and Webapp on
that machine share it. Credentials, drafts, and per-window state are not stored
there. A desktop connected to a remote gateway still keeps **this computer's**
prefs. Per-profile theme picks can live as scoped entries inside that file.

Desktop Settings pages that write `config.yaml` (Model, Workspace, Safety,
Memory, Voice, Chat, Advanced, Tools & Keys, …) show an **Applies to** chip when
two or more profiles exist; default follows the active profile.

## Minimal recipes

**Quiet messaging bot, detailed CLI:**

```bash
hermes -p forge config set display.tool_progress all
# edit config.yaml platforms.slack.tool_progress: "off"
hermes -p forge config set display.skin slate
hermes -p forge config set display.show_reasoning false
hermes -p forge config set display.runtime_footer.enabled false
```

**Desktop fonts:**

```bash
hermes -p forge config set desktop.font_family "Atkinson Hyperlegible"
hermes -p forge config set terminal.font_family "MesloLGS NF"
```

## Safety / notes

1. Do not hand-edit `ui-preferences.json` while Desktop/Webapp are open if you can avoid it; use Settings.
2. Skin changes appearance only. Put standing voice in `SOUL.md`.
