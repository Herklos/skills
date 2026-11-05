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

**Browser** (`type: browser`): Hermes-managed Chromium-family browser using a
**dedicated operator Chrome profile per Browser** (org default). Not a separate
Cua browser product. **Always create the Chrome profile on the host first**,
then store its directory name in `real_profile_pin`. Never reuse the human's
personal profile or another HQ's pin.

| Key | Value |
|-----|-------|
| `lifecycle` | `live` |
| `access_needed` | `true` |
| `is_real` | `true` |
| `browser_engine` | `chrome` |
| `real_profile_pin` | `Profile N` (dedicated; from Create Chrome profile below) |
| `browser_source` | `operator-real-profile` |
| `browser_identity` | `operator-real-profile` |
| `headed` | `false` |
| `docs_url` | `https://hermes-agent.nousresearch.com/docs/user-guide/features/browser` |
| `notes` | Hermes browser toolset; Chrome display name Hermes {HQ short}; pin Profile N. Pair with the HQ Computer. |

## Create Chrome profile (required when `is_real`)

Do this **before** (or immediately with) the Anytype Browser create. One host
Chrome profile per Browser object.

**macOS path:** `~/Library/Application Support/Google/Chrome/`
**Pin value** = profile **directory** name (`Profile 2`, `Profile 3`, …). Hermes
`browser.real_profile_pin` uses that directory string.
**Chrome display name** = `Hermes {HQ short}` (e.g. `Hermes Engineering`,
`Hermes Legal-HR`, `Hermes Arnold`). Shown in the profile picker; stored in
Local State `profile.info_cache[<dir>].name`.

Steps:

1. List existing pins: read Local State `profile.info_cache` keys and dirs
   matching `Default` / `Profile N`. Pick the next free `Profile N`.
2. Quit Google Chrome first (editing Local State while Chrome runs is unsafe).
3. Create `…/Google/Chrome/Profile N/` with a minimal `Preferences` that sets
   `profile.name` to `Hermes {HQ short}` and `profile.is_using_default_name` to
   false.
4. Register the directory in Local State `profile.info_cache` and append to
   `profile.profiles_order`. Set `name` + `shortcut_name` to the Hermes display
   name; `is_using_default_name: false`.
5. Optional: launch Chrome once with
   `--profile-directory="Profile N" --no-first-run about:blank`, then quit, so
   Chrome finishes scaffolding.
6. Put **`Profile N`** into Browser.`real_profile_pin` (and mention the display
   name in `notes`).
7. Reopen Chrome for the user if you quit it.

**Do not** point several Browsers at the same pin. **Do not** use the human's
signed-in personal profile as an HQ pin unless the user explicitly asks.

Live org map (example): Engineering → `Profile 2` / Hermes Engineering;
Product → `Profile 3`; Growth → `Profile 4`; Finance → `Profile 5`; Legal-HR →
`Profile 6`; Foyer → `Profile 7`; Arnold → `Profile 8`.

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
      "is_real": true,
      "browser_engine": "chrome",
      "real_profile_pin": "Profile 2",
      "browser_source": "operator-real-profile",
      "browser_identity": "operator-real-profile",
      "headed": false,
      "docs_url": "https://hermes-agent.nousresearch.com/docs/user-guide/features/browser",
      "notes": "Chrome profile Hermes Engineering (pin Profile 2). Hermes use_real_profile=true. Pair with Engineering HQ Cua Spaces Computer."
    },
    "markdown": "## When to use\nPair with Engineering HQ – Cua Spaces. Create the Chrome profile on the host first; store its directory pin here.\n"
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
2. **Create dedicated Chrome profile** on the host (Create Chrome profile above);
   note the directory pin
3. Create Computer + Browser pair (this file); set Browser.`real_profile_pin` to
   that directory
4. Create live Cua Space + set Computer.`cua_space` (`cua-hq-spaces.md`)
5. Link pair on the HQ
6. Create Subteams → link same pair
7. Create / move Agents → link same pair + `computer_surface: cua-spaces`
8. Remind: Hermes apply is separate (`hermes-profiles` `browser-and-computer.md`;
   pin `settings.space` from Computer.`cua_space`; `use_real_profile` +
   `real_profile_pin` from Browser)

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
