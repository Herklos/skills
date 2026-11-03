# Workspace and display

Docs:
- https://hermes-agent.nousresearch.com/docs/user-guide/configuration (Display Settings, Working Directory)
- https://hermes-agent.nousresearch.com/docs/user-guide/features/skins
- https://hermes-agent.nousresearch.com/docs/user-guide/git-worktrees
- https://hermes-agent.nousresearch.com/docs/user-guide/features/context-files
- https://hermes-agent.nousresearch.com/docs/user-guide/desktop (Appearance, Workspace, ui-preferences)

Per-profile unless noted. Personality voice (`display.personality`) is covered in `soul-templates.md`; this page is workspace roots, UI chrome, and skins.

## Quick map

| Concern | Keys / CLI |
|---------|------------|
| Tool / gateway working directory | `terminal.cwd` |
| Named multi-folder workspace | `hermes -p <slug> project …` |
| Desktop repo discovery | `desktop.repo_scan_*` (Settings → Workspace) |
| Chat / terminal fonts (Desktop) | `desktop.font_family`, `terminal.font_family` |
| CLI/TUI/gateway progress & chrome | `display.*` |
| Skin (look) vs personality (voice) | `display.skin` / `/skin` vs `display.personality` |
| Computer-wide Desktop prefs | `$HERMES_HOME/ui-preferences.json` (root home, not a profile folder) |
| Session ↔ folder | resume restores cwd; `hermes sessions list --workspace …` |
| Isolated git tree | `hermes -w` / `/worktree` (see git-worktrees docs) |

## Working directory

| Surface | Default |
|---------|---------|
| CLI (`hermes` / `hermes chat`) | Directory where you launched the command |
| Messaging gateway / cron | `terminal.cwd` (else `~`) |
| Container / remote backends | Home inside the sandbox / remote |

```yaml
terminal:
  cwd: /absolute/path/to/repo   # gateway + cron; CLI still uses launch dir
```

```bash
hermes -p <slug> config set terminal.cwd /absolute/path/to/repo
hermes -p <slug> config get terminal.cwd
```

Legacy env fallbacks `MESSAGING_CWD` / `TERMINAL_CWD` exist; prefer `terminal.cwd`.

Resume restores the session's recorded workspace directory. Stay put with
`hermes --resume <id> --no-restore-cwd`. Filter history with
`hermes sessions list --workspace <path-or-basename>`.

Project context files (`.hermes.md`, `AGENTS.md`, `CLAUDE.md`, …) load from the
working directory / git root. See context-files docs. Instruction-file writes can
be gated by `security.protected_instruction_files` (`security.md`).

Docker host-workspace mounting (`terminal.docker_mount_cwd_to_workspace`) is under
`runtime-limits-and-tools.md`.

## Named projects (`hermes project`)

Human-named workspaces that can span several folders/repos. They group Desktop
sessions and can bind a kanban board for worktree/branch conventions. **State is
per profile.**

```bash
hermes -p <slug> project create <name>
hermes -p <slug> project list
hermes -p <slug> project show <name>
hermes -p <slug> project add-folder <name> <path>
hermes -p <slug> project remove-folder <name> <path>
hermes -p <slug> project set-primary <name> <path>
hermes -p <slug> project use <name>
hermes -p <slug> project rename <old> <new>
hermes -p <slug> project archive <name>
hermes -p <slug> project restore <name>
hermes -p <slug> project bind-board <name> <board>
```

Dashboard / Webapp workspace picker lists these projects plus discovered git
repos (and **Other path…**). Choice is remembered per profile for the next
**New chat**; a resumed session keeps its own cwd.

## Desktop repository discovery

Settings → Workspace, or `config.yaml`:

```yaml
desktop:
  repo_scan_enabled: true
  repo_scan_roots: []            # empty = default home-directory scan
  repo_scan_exclude_paths: []    # skip whole subtrees
```

```bash
hermes -p <slug> config set desktop.repo_scan_enabled true
# Restrict scan (YAML list via config edit, or repeated set if supported):
# desktop.repo_scan_roots: ["/Users/you/code"]
# desktop.repo_scan_exclude_paths: ["/Users/you/Downloads"]
```

- `repo_scan_enabled: false` stops the filesystem scan and clears that profile's
  disk-discovery cache. Explicit projects and session-inferred repos remain.
- Changing scan settings refreshes only that profile's discovery cache.
- **Hide from sidebar** is a separate per-item curation action in the UI.

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

## Presentation metadata (`profile.yaml`)

| Field | Role |
|-------|------|
| `display_name` | Presentation label (`hermes profile rename default <Name>` only renames presentation for default) |
| `description` | Kanban / routing blurb (`hermes profile describe`) |
| `ui_meta.hermes-bots` | Bot Mode roster title, avatar, section (leave to Desktop unless asked) |

## Git worktrees (brief)

`hermes -w <name>` / `/worktree new` creates an isolated tree under
`.worktrees/` and retargets terminal/file tools. Recorded in
`<HERMES_HOME>/worktree_repos.json` for the profile. Full guide: git-worktrees
docs. Pair with `terminal.cwd` / projects when agents share a checkout.

## Minimal recipes

**Specialist pinned to one repo (gateway + cron):**

```bash
hermes -p forge config set terminal.cwd /absolute/path/to/repo
hermes -p forge project create forge-app
hermes -p forge project add-folder forge-app /absolute/path/to/repo
hermes -p forge project set-primary forge-app /absolute/path/to/repo
hermes -p forge project use forge-app
```

**Quiet messaging bot, detailed CLI:**

```bash
hermes -p forge config set display.tool_progress all
# edit config.yaml platforms.slack.tool_progress: "off"
hermes -p forge config set display.skin slate
hermes -p forge config set display.show_reasoning false
hermes -p forge config set display.runtime_footer.enabled false
```

**Desktop scan only under ~/code:**

```bash
hermes -p forge config set desktop.repo_scan_enabled true
# Set desktop.repo_scan_roots to ["/Users/you/code"] via config edit
hermes -p forge config set desktop.font_family "Atkinson Hyperlegible"
hermes -p forge config set terminal.font_family "MesloLGS NF"
```

## Safety / notes

1. `terminal.cwd` does not sandbox the filesystem; pair with backends / write-safe root when needed.
2. Do not hand-edit `ui-preferences.json` while Desktop/Webapp are open if you can avoid it; use Settings.
3. Skin changes appearance only. Put standing voice in `SOUL.md`.
4. Confirm before archiving projects or wiping discovery caches that operators still use.
