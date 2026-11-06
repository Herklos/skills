# Plugins and curated skills

Load when updating plugins after a Hermes upgrade, locking org skills, or
checking catalog tiers. Official plugins docs:
https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins

## Update plugins

```bash
hermes plugins update              # list updates; confirm once; apply all
hermes plugins update --yes        # non-interactive (scripts)
hermes plugins update <name>       # one plugin
hermes plugins update --force      # apply despite caution scan (dangerous still blocked)
```

Also: `/plugins update`, Desktop / dashboard **Update all**. Opt-in unattended
updates for tracked git plugins:

```bash
hermes config set plugins.auto_apply true    # default false; ask before enabling fleet-wide
```

`requires_hermes` floors block installs/updates that need a newer Hermes.
Updates that would break a setup are held back or shown as caution findings.

**Verified** catalog tier marks vendor-built plugins (e.g. Cua Spaces). Prefer
Verified when choosing computer/browser backends.

## Curator lock (org skills)

After syncing Anytype procedure skills into `skills/org/<key>`:

```bash
hermes -p <slug> curator lock org/<skill_key>
hermes -p <slug> curator unlock org/<skill_key>   # only when asked
hermes curator status
```

A **locked** skill cannot be changed by `skill_manage`, `write_file`, `patch`,
or terminal writes, even under YOLO. The curator will not auto-archive it.
Human edits outside the agent still work. Use this for standing org playbooks
so a chat cannot rewrite them.

Related: `hermes curator pin` (curator will not auto-transition); `pause` /
`resume` for the curator loop. Bundled and hub-installed skills are never
auto-touched by the curator.

## New official plugins (install only when asked)

Examples from the v0.23 window (catalog grows often): Meshy (3D), ElevenLabs
Music / Sound Effects, X Chat, REA (reverse engineering), bubblewrap (Linux
sandbox), advanced-delegation (already org standard for Subagent parents).
Labs: `hermes inbox`, `hermes record`, Patsnap. Do not mass-install.

## After Hermes upgrade checklist

1. `hermes --version` (expect ≥ target)
2. `hermes plugins update` (review caution)
3. `hermes doctor` on a sample of profiles
4. Re-check advanced-delegation on Subagent parents: `delegation config --show`
5. Lock any newly synced `skills/org/*` the user wants frozen
