# Create live Cua Spaces for HQ Computers

Companion to `hq-runtime-pair.md`. That file creates the Anytype **Computer**
catalog row. This file creates the **live Cua Space** that row points at, and
stores the Space id on the Computer.

Load when: a new HQ Computer is created, an HQ is bootstrapped, Spaces are
missing / renamed, or Hermes apply needs a stable `settings.space` pin.
Runtime create/list/delete details: skill **`cua-spaces`**. Hermes pin:
`hermes-profiles` → `browser-and-computer.md`.

## Why id, not slug alone

| Field | Example | Role |
|-------|---------|------|
| Computer.`slug` | `engineering-cua-spaces` | Anytype catalog key (stable org id) |
| Computer.`cua_space` | `local:engineering-hq` | **Live** Cua Space id for MCP / CLI / Hermes |
| Space short name | `engineering-hq` | `cua spaces create --name`; Hermes `settings.space` also accepts this |

Store the **full Space id** (`local:engineering-hq`, or `relay:…` /
`host:…` forms when applicable) in Computer.`cua_space`. Slug alone is not
enough for `create_space` / `space_bash` / Hermes pin. Prefer id over short
name so the provider prefix stays explicit.

## Naming

| HQ slug | Computer slug | Space name | `cua_space` value |
|---------|---------------|------------|-------------------|
| `engineering` | `engineering-cua-spaces` | `engineering-hq` | `local:engineering-hq` |
| `product` | `product-cua-spaces` | `product-hq` | `local:product-hq` |
| `growth` | `growth-cua-spaces` | `growth-hq` | `local:growth-hq` |
| `finance` | `finance-cua-spaces` | `finance-hq` | `local:finance-hq` |
| `legal-hr` | `legal-hr-cua-spaces` | `legal-hr-hq` | `local:legal-hr-hq` |
| `foyer` | `foyer-cua-spaces` | `foyer-hq` | `local:foyer-hq` |

Pattern: Space name = `{hq-slug}-hq`. Matches hermes-profiles suggested pin.

## Prerequisites

1. Cua CLI on PATH (`cua --version`); MCP `cua` server optional (CLI is enough).
2. Anytype Computer object already exists (`hq-runtime-pair.md`) with
   `computer_surface: cua-spaces`, `desktop_enabled: true`.
3. Computer type has featured text property **`cua_space`** (api key `cua_space`).
   Add once per space if missing:

```json
{
  "space_id": "<spaceId>",
  "type": "computer",
  "body": {
    "ops": [
      {
        "op": "add_property",
        "property": "Cua space",
        "format": "text",
        "section": "featured"
      }
    ]
  }
}
```

## Create one Space (CLI preferred)

**Org default:** local **Docker container** (`--kind container --runtime runc`)
with a stable `--name`. Named Spaces keep id `local:{name}` across recreate.
`--durable` is only for `--on auto` (recreate on another machine if the host
goes away).

Requires Docker running (OrbStack / Docker Desktop). Verify with `docker info`.

```bash
# Prefer existing (and ready, not missing)
cua sb ls | grep engineering-hq
cua spaces ls --json | jq -r '.spaces[] | select(.name=="engineering-hq") | .id'

# Create if missing (canonical Linux image; desktop features come with spacesd)
cua spaces create linux --on local --kind container --runtime runc \
  --name engineering-hq --json
# → {"spaces":[{"id":"local:engineering-hq","name":"engineering-hq", ...}]}

# Confirm Docker owns it
docker ps --filter name=engineering-hq --format '{{.Names}}\t{{.Status}}'
cua sb exec engineering-hq -- uname -a
```

If `cua sb ls` shows `STATUS missing`, the registry row survived but the
container did not. Delete and recreate:

```bash
cua spaces delete engineering-hq --force
cua spaces create linux --on local --kind container --runtime runc \
  --name engineering-hq --json
```

MCP equivalent (when relay auth is healthy):

```json
{
  "name": "engineering-hq",
  "on": "local",
  "image": "linux",
  "reuse": true
}
```

Pass kind/runtime via CLI when MCP omits them. If MCP returns relay auth
errors, use the CLI. Refresh with `cua auth login` when the access token is
near expiry.

Multi-machine durable (optional):

```bash
cua spaces create linux --on auto --durable --name engineering-hq --json
```

## Patch the Computer

```json
{
  "space_id": "<spaceId>",
  "object_id": "<computerObjectId>",
  "ops": [
    {
      "op": "set_properties",
      "set": {
        "cua_space": "local:engineering-hq",
        "notes": "Dedicated Cua Space for this HQ. cua_space=local:engineering-hq; terminal.backend cua; desktop true."
      }
    }
  ]
}
```

## New HQ checklist (full pair + live Space)

1. Create Anytype Computer + Browser (`hq-runtime-pair.md`)
2. Link pair on HQ / Subteams / Agents
3. **This file:** `cua spaces create linux --on local --kind container
   --runtime runc --name {hq-slug}-hq`
4. Set Computer.`cua_space` to the returned id (`local:{hq-slug}-hq`)
5. Hermes apply later: pin `plugins.entries.cua-spaces.settings.space` to
   Computer.`cua_space` (or its short name), `desktop: true`,
   `delete_on_exit: false` (`browser-and-computer.md`)

## Bulk (org fill)

For each HQ Computer missing `cua_space`:

1. Derive `{hq-slug}` from Computer.`slug` (`engineering-cua-spaces` →
   `engineering`)
2. Create `{hq-slug}-hq` if absent
3. Patch `cua_space=local:{hq-slug}-hq`

Org fill (2026-11-04): six Docker container/runc Spaces created and linked
(same ids after recreate when containers went missing):

| Computer | `cua_space` | kind / runtime |
|----------|-------------|----------------|
| Engineering HQ – Cua Spaces | `local:engineering-hq` | container / runc |
| Product HQ – Cua Spaces | `local:product-hq` | container / runc |
| Growth HQ – Cua Spaces | `local:growth-hq` | container / runc |
| Finance HQ – Cua Spaces | `local:finance-hq` | container / runc |
| Legal & HR HQ – Cua Spaces | `local:legal-hr-hq` | container / runc |
| Foyer HQ – Cua Spaces | `local:foyer-hq` | container / runc |

## Verify

```bash
cua spaces ls --json | jq -r '.spaces[] | select(.name|endswith("-hq")) | "\(.id)\t\(.name)"'
```

```json
{
  "space_id": "<spaceId>",
  "type": "computer",
  "limit": 20,
  "fields": ["name", "slug", "cua_space", "lifecycle"]
}
```

Every live Computer with `computer_surface: cua-spaces` should have a non-empty
`cua_space` that appears in `cua spaces ls`.

## What this is not

- Creating the Anytype Computer / Browser catalog rows (`hq-runtime-pair.md`)
- Applying Hermes profile config (standing redesign rule: wait for user OK)
- Per-agent Spaces (org default is **one Space per HQ**)
- Deleting Spaces when an HQ is archived (confirm with the user first;
  `cua spaces delete <name>` / MCP `delete_space`)
