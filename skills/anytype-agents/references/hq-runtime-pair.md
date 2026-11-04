# Per-HQ Computer + Browser pair

On-demand playbook for the org convention: **one Cua Spaces Computer and one
Hermes Chromium Browser per HQ**. Subteams and Agents under that HQ link the same
pair. Board and Primary leave both empty.

Load when creating an HQ, adding a Subteam/Agent under an HQ, migrating away
from shared org-wide Browser/Computer catalogs, or auditing runtime links.
Property tables: `object-types.md`. Short MCP snippets: `mcp-recipes.md`.
**Live Cua Space create + Computer.`cua_space`:** `cua-hq-spaces.md` (do this
after the Computer row exists). Hermes apply of the linked pair: skill
`hermes-profiles` → `browser-and-computer.md` (section **Anytype per-HQ pair →
Hermes**).

## Convention

| Owner | Computer | Browser | Agent.`computer_surface` |
|-------|----------|---------|--------------------------|
| Each HQ (`team` kind HQ) | `{HQ name} – Cua Spaces` | `{HQ name} – Hermes Chromium` | (on members) `cua-spaces` |
| Subteam under that HQ | same Computer id | same Browser id | (on members) `cua-spaces` |
| Agent under that HQ / Subteam | same Computer id | same Browser id | `cua-spaces` |
| Board | empty | empty | n/a on Team |
| Primary (P) | empty | empty | `none` |

Do **not** mint shared org-wide None / Host desktop / Bot Screen / Operator
catalog rows unless the user asks for an exception surface.

Tool profiles stay a **shared** org catalog (Standard interactive / Coding /
Data fetching / Read-only). This playbook is Browser + Computer only.

## Naming and slugs

| Kind | Display name | `slug` |
|------|--------------|--------|
| Computer | `{HQ name} – Cua Spaces` | `{hq-slug}-cua-spaces` |
| Browser | `{HQ name} – Hermes Chromium` | `{hq-slug}-hermes-chromium` |

`hq-slug` examples: `engineering`, `product`, `growth`, `finance`, `legal-hr`,
`foyer`. Keep ASCII kebab-case; match the HQ's short id used in notes.

## Property defaults (pair)

**Computer** (`type: computer`):

| Key | Value |
|-----|-------|
| `lifecycle` | `live` |
| `access_needed` | `true` |
| `computer_surface` | `cua-spaces` |
| `computer_scope` | `dedicated` |
| `permission_mode` | `standard` |
| `desktop_enabled` | `true` |
| `cua_space` | set after live create (e.g. `local:engineering-hq`); see `cua-hq-spaces.md` |
| `docs_url` | `https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces` |
| `notes` | Dedicated Cua Space for this HQ; `terminal.backend: cua`; desktop true. Linked from HQ, Subteams, Agents. |

**Browser** (`type: browser`): Hermes-managed local Chromium (throwaway).
Not a separate Cua browser product. With Computer `desktop_enabled: true`,
Hermes places browser work inside that HQ Space.

| Key | Value |
|-----|-------|
| `lifecycle` | `live` |
| `access_needed` | `true` |
| `browser_source` | `local-chromium` |
| `browser_identity` | `dedicated-throwaway` |
| `headed` | `false` |
| `docs_url` | `https://hermes-agent.nousresearch.com/docs/user-guide/features/browser` |
| `notes` | Hermes browser toolset; local throwaway Chromium. Pair with the HQ Computer. |

## Create the pair (MCP)

Discover the HQ first (`API-search-space` `type: team`, confirm `kind: HQ`).
Omit `icon` on create when using shortcut `name` / `markdown` (icon forces the
AnyBlock document form and rejects that shortcut).

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "computer",
    "name": "Engineering HQ – Cua Spaces",
    "properties": {
      "slug": "engineering-cua-spaces",
      "lifecycle": "live",
      "access_needed": true,
      "computer_surface": "cua-spaces",
      "computer_scope": "dedicated",
      "permission_mode": "standard",
      "desktop_enabled": true,
      "docs_url": "https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces",
      "notes": "Dedicated Cua Space for Engineering HQ. terminal.backend cua; desktop true."
    },
    "markdown": "## When to use\nDefault computer for Engineering HQ agents.\n"
  }
}
```

```json
{
  "space_id": "<spaceId>",
  "create_missing_options": true,
  "body": {
    "type": "browser",
    "name": "Engineering HQ – Hermes Chromium",
    "properties": {
      "slug": "engineering-hermes-chromium",
      "lifecycle": "live",
      "access_needed": true,
      "browser_source": "local-chromium",
      "browser_identity": "dedicated-throwaway",
      "headed": false,
      "docs_url": "https://hermes-agent.nousresearch.com/docs/user-guide/features/browser",
      "notes": "Hermes-managed local Chromium (throwaway) for Engineering HQ. Pair with the HQ Cua Space Computer."
    },
    "markdown": "## When to use\nPair with Engineering HQ – Cua Spaces. Hermes owns the browser; Space placement follows Computer desktop.\n"
  }
}
```

Keep the returned Computer and Browser object ids for linking.

## Link who should inherit

1. **HQ** (`team`): set `computer` + `browser` to the new ids.
2. **Every Subteam** with `parent_team` = that HQ: same ids.
3. **Every Agent** whose `team` is that HQ or one of its Subteams: same ids, plus
   `computer_surface: cua-spaces` (and usually `terminal_backend: cua` when the
   Tool profile agrees).
4. **Board**: `computer: []`, `browser: []`.
5. **Primary**: `computer: []`, `browser: []`, `computer_surface: none`.

```json
{
  "space_id": "<spaceId>",
  "object_id": "<hqOrSubteamOrAgentId>",
  "create_missing_options": true,
  "ops": [
    {
      "op": "set_properties",
      "set": {
        "computer": ["<hqComputerId>"],
        "browser": ["<hqBrowserId>"],
        "computer_surface": "cua-spaces"
      }
    }
  ]
}
```

On Team/Subteam you may omit `computer_surface` (Agent-only select). On Board /
Primary clear links with empty arrays; Primary also sets `computer_surface` to
`none`.

## Bulk migration (replace shared catalogs)

When retiring shared org-wide Browser/Computer objects:

1. Create the 2 × N HQ pairs (N = number of HQs).
2. Build a link map: HQ → pair; Subteam → parent HQ pair; Agent → owning HQ pair;
   Board + Primary → clear.
3. Patch every Team / Subteam / Agent in that map.
4. Verify with `API-search-space` `type: browser` and `type: computer` (expect
   only the per-HQ rows).
5. Bin-delete the old shared catalog objects (`API-delete-object`, default Bin;
   permanent only with explicit approval).
6. Do **not** apply live Hermes profiles until the user says the redesign pass is
   done (standing org rule during redesign).

## New HQ checklist

1. Create `team` (`kind: HQ`) with chief / mission / …
2. Create Computer + Browser pair (this file)
3. Create live Cua Space + set Computer.`cua_space` (`cua-hq-spaces.md`)
4. Link pair on the HQ
5. Create Subteams → link same pair
6. Create / move Agents → link same pair + `computer_surface: cua-spaces`
7. Remind: Hermes apply is separate (`hermes-profiles` `browser-and-computer.md`;
   pin `settings.space` from Computer.`cua_space`)

## Verify

```json
{ "space_id": "<spaceId>", "type": "computer", "limit": 50, "fields": ["name", "slug", "lifecycle"] }
```

```json
{ "space_id": "<spaceId>", "type": "browser", "limit": 50, "fields": ["name", "slug", "lifecycle"] }
```

Spot-check one HQ, one Subteam, one Agent under it, Board, and Primary.

## What this is not

- Creating the live Cua Space on the host (use **`cua-hq-spaces.md`** right
  after the Computer row exists; Hermes still applies `terminal.backend: cua`
  / `desktop: true` / `settings.space` at profile apply time).
- Changing Tool profiles (shared catalog; see `object-types.md`).
- Auto-pushing Anytype links into `~/.hermes/profiles/<slug>`.
