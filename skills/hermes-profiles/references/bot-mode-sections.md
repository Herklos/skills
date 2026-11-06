# Bot Mode sidebar sections

Companion to `hermes-profiles`. File bots and Group Chats under named folders in
the Desktop **Bots** sidebar (Board, Engineering, Product, …).

Interactive path: Desktop drag-and-drop or section menus. Fleet path below.

## Mental model

Three stores, different durability:

| What | Where it lives | Syncs with profile? |
|------|----------------|---------------------|
| **Section list** (id + display name + order) | Desktop Local Storage `bot-sections-v1` | No (machine-local) |
| **Bot → section** | `profile.yaml` `ui_meta.hermes-bots.sectionId` + `sectionName` | Yes (rides profile sync) |
| **Group Chat → section** | Desktop Local Storage `group-chats` entry `sectionId` | No (machine-local; remote hydrate keeps local `sectionId`) |

Source of truth for “which folder is this bot in” is the **profile**
(`sectionId` / `sectionName`). The section **catalog** itself is Desktop-only.
Unassigned bots (no `sectionId`) render last under an implicit Unassigned bucket
that is not a real section.

Desktop APIs (in-app): `createBotSection`, `renameBotSection`,
`moveBotsToSection`, `moveGroupChatsToSection` (see
`apps/desktop/src/plugins/hermes-bots/user-sections.ts`).

## Org convention (HQ map)

Name sections after Anytype HQs / Board. File each bot under the HQ it reports
to; file each Group Chat under the same HQ as Group.`parent_team`.

| Section | Typical bots | Typical Group Chats |
|---------|--------------|---------------------|
| Board | `default` (P) | Board Group |
| Engineering | etienne, marcel, simone, anatole, gaston, severin, clovis, denise, joachim, octave, arnold | Engineering / Development / Ops / Veille & Technology Groups |
| Product | henri, genevieve, suzanne, noemie, odette, jerome, fanny, marthe, adele | Product / Customer & Analytics / Product Design & Experience / Project Management Groups |
| Growth | kleber, micheline, ambre, firmin, berenice | Growth / Marketing / Sales & Acquisition / Partnerships & BD Groups |
| Finance | leon, maurice, lucien, aristide, basile, ernest, edmond, theophile, berthe, gaspard, hortense, raoul | Finance / Companies Finance / Personal Finance / Investments & Treasury / Tax & Fiscal / Real Estate Groups |
| Legal & HR | rene, solange, agathe, clothilde, therese, henriette, germaine, irene | Legal & HR / Legal / Compliance / HR Groups |
| Foyer | sidonie, philippe, blanche, bob | (messaging deferred; bots only) |

René is Legal & HR chief; keep him in the Legal & HR section even when he also
sits on Board Group for messaging.

Anytype already places Groups via `parent_team` → HQ. **Do not invent Anytype
sidebar folders** for this; Desktop sections are Hermes-local. See
`anytype-agents` note under Groups.

## Fetch existing sections first

Before creating or renaming, read the live catalog:

1. Prefer Desktop open → note section names in the Bots sidebar.
2. Or, with Desktop **quit**, read LevelDB key
   `hermes.plugin.hermes-bots.bot-sections-v1` (tag byte `0x01` + JSON array
   `[{ id, name }, …]` in display order). Same classic-level pattern as
   `avatars.md` → seed `bot-meta-v2`.

Also inventory bot membership from profiles:

```bash
# Primary
grep -E 'section(Id|Name)' "$HERMES_HOME/profile.yaml"
# Named
find "$HERMES_HOME/profiles" -name profile.yaml -print0 \
  | xargs -0 grep -H -E 'section(Id|Name)' | head -80
```

Group Chat sections: LevelDB `hermes.plugin.hermes-bots.group-chats` (object
keyed by room display name; each value may carry `sectionId`, `roomId`, `log`).

## Assign bots (durable)

`profiles.configure` merges `ui_meta` **key-wise**: the whole `hermes-bots`
object you send **replaces** the previous `hermes-bots` value. Always merge
existing fields (photo / custom / shape / title) before writing, or you wipe
avatars.

```bash
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
HERMES_PY=$(ls -d "$HERMES_HOME"/tools/python-*/bin/python3 2>/dev/null | sort -V | tail -1)
"$HERMES_PY" - <<'PY'
import os, sys, json
from pathlib import Path
os.environ["HERMES_HOME"] = str(Path.home() / ".hermes")
sys.path.insert(0, str(Path.home() / ".hermes" / "hermes-agent"))
import hermes_bootstrap
import tui_gateway.methods_profiles  # register
from tui_gateway.server import handle_request
from hermes_cli import profiles as profiles_mod

# sectionId values come from bot-sections-v1 (fetch first)
SECTIONS = {
    "Board": "sec-…",
    "Engineering": "sec-…",
    # …
}
BOTS = {
    "default": "Board",
    "etienne": "Engineering",
    # …
}

def home_for(slug: str) -> Path:
    root = Path.home() / ".hermes"
    return root if slug == "default" else root / "profiles" / slug

for slug, section_name in BOTS.items():
    home = home_for(slug)
    existing = profiles_mod._read_profile_yaml(home) or {}
    hb = dict((existing.get("ui_meta") or {}).get("hermes-bots") or {})
    hb["sectionId"] = SECTIONS[section_name]
    hb["sectionName"] = section_name
    handle_request({
        "jsonrpc": "2.0", "id": 1, "method": "profiles.configure",
        "params": {"name": slug, "ui_meta": {"hermes-bots": hb}},
    })
    print("OK", slug, section_name)
PY
```

Optional: also stamp Desktop `bot-meta` / `bot-meta-v2` `sectionId` /
`sectionName` while Desktop is quit so the first paint matches before profile
pull. Profile fields remain authoritative after sync.

## Assign Group Chats (Desktop-local)

Group Chat section is **not** on the profile. Options:

1. **Desktop UI** (preferred when Desktop is open): move the group row into the
   section (`moveGroupChatsToSection`).
2. **LevelDB seed** (Desktop quit): ensure `group-chats` has an entry per room
   display name with:
   - `sectionId` = target section id
   - `roomId` = Hermes hosted `room_id` (e.g. `anytype-engineering-group-leads`)
   - `log: []` (hydrate requires `Array.isArray(room.log)`; omit → room skipped)

Remote room snapshots merge with `...existing`, so a local `sectionId` survives
server refresh. Seeding before the first open creates the `group-chats` key when
it was absent.

Backup `~/Library/Application Support/Hermes/Local Storage` before edits. Do
not write LevelDB while Desktop is running (lock + race).

## Rename a section (e.g. Pinned → Board)

1. Quit Desktop.
2. Edit `bot-sections-v1`: change that entry’s `name` (keep the same `id`).
3. Update every bot `sectionName` that still carries the old label
   (`profiles.configure` merge + optional bot-meta stamp).
4. Group Chat rows keep `sectionId`; the new name appears from the catalog.
5. Reopen Desktop and confirm sidebar labels.

Creating a brand-new section: mint an id (`sec-<timestamp>-<rand>` style as
Desktop does) and append to `bot-sections-v1`, or use Desktop **New section**.

## Fleet checklist

1. Fetch `bot-sections-v1` (and optionally Desktop sidebar). Map HQ names → ids.
2. Build bot → section and Group Chat → section maps (Anytype HQ / `parent_team`).
3. Quit Hermes Desktop.
4. Backup Local Storage.
5. Stamp every bot via `profiles.configure` (**merge** existing `hermes-bots`).
6. Optionally stamp `bot-meta-v2` section fields; rename section catalog entries.
7. Seed / update `group-chats` stubs (`sectionId` + `roomId` + `log: []`).
8. Reopen Desktop; verify bots and group rows under the right HQ folders.

## Related

- Avatars / LevelDB pattern: `avatars.md`
- `ui_meta` shape fields: `profile-map.md`
- Hosted rooms create/writeback: `messaging-groups.md`
- Lifecycle pointer: `recipes.md` **5**
- Anytype Groups stay on `parent_team` (no Desktop section field): `anytype-agents`
