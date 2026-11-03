# Workspace (cwd, projects, repo scan)

Docs:
- https://hermes-agent.nousresearch.com/docs/user-guide/configuration (Working Directory)
- https://hermes-agent.nousresearch.com/docs/user-guide/features/context-files
- https://hermes-agent.nousresearch.com/docs/user-guide/git-worktrees
- https://hermes-agent.nousresearch.com/docs/user-guide/desktop (Workspace)

Per-profile. Display chrome and skins: `display.md`. Personality voice: `soul-templates.md`.

## Quick map

| Concern | Keys / CLI |
|---------|------------|
| Tool / gateway working directory | `terminal.cwd` |
| Named multi-folder workspace | `hermes -p <slug> project …` |
| Desktop repo discovery | `desktop.repo_scan_*` (Settings → Workspace) |
| Session ↔ folder | resume restores cwd; `hermes sessions list --workspace …` |
| Isolated git tree | `hermes -w` / `/worktree` (see git-worktrees docs) |
| Presentation / Bot Mode labels | `profile.yaml` `display_name` / `description` / `ui_meta` |

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

**Desktop scan only under ~/code:**

```bash
hermes -p forge config set desktop.repo_scan_enabled true
# Set desktop.repo_scan_roots to ["/Users/you/code"] via config edit
```

## Safety / notes

1. `terminal.cwd` does not sandbox the filesystem; pair with backends / write-safe root when needed (`security.md`, `runtime-limits-and-tools.md`).
2. Confirm before archiving projects or wiping discovery caches that operators still use.
