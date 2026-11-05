# Bot Mode custom photo avatars

Companion to `hermes-profiles`. Install custom faces for Desktop Bot Mode.

Interactive path: Desktop **Edit Profile** → upload photo. Fleet path below.

## Why a bare file copy fails

Writing `assets/avatar.png` alone is not enough. On launch, Bot Mode
(`pullServerAvatars` / `pushLocalAvatars`) prefers cached `bot-meta` images.
If local meta already has an `image`, it skips the server asset. Local SVG
backfill can also overwrite disk with a **160×160** raster
(`isBackfilledFacePng`). Real photos are **256×256**.

Proper fleet install: **`profiles.set_asset`** + stamp `ui_meta` photo/custom +
clear Desktop `bot-meta-v2` image cache (Desktop quit).

## Paths

| Profile | File written by `set_asset` |
|---------|-----------------------------|
| Primary (`default`, display **P**) | `$HERMES_HOME/assets/avatar.png` |
| Named `<slug>` | `$HERMES_HOME/profiles/<slug>/assets/avatar.png` |

- Target size **256×256 PNG** (center-crop square, then resize).
- Source filenames = Hermes slug (ASCII). `p.png` → profile `default`.
- Install only **Hermes-runtime** Agents. Leave Osaurus art out of Hermes homes
  (e.g. sibling `osaurus-ready/`).
- Style org default: soft 3D clay / plush; refs `default` / `etienne` / `micheline`.

```yaml
# profile.yaml (also stamped via profiles.configure)
ui_meta:
  hermes-bots:
    imageKind: photo
    custom: true
    shape: blobatar   # keep if already set
```

## Fleet install (required order)

1. Diff source PNGs vs `hermes profile list` (+ live Hermes-runtime Anytype Agents
   when applying from org inventory). Fix typos; map `p` → `default`. Skip
   Osaurus-only slugs.
2. **Quit Hermes Desktop** (otherwise it races and restores old faces).
3. Center-crop → 256×256 → call `profiles.set_asset` per slug (writes
   `assets/avatar.png` atomically).
4. Stamp `ui_meta.hermes-bots` `imageKind: photo` + `custom: true` (via
   `profiles.configure` or `profile.yaml`).
5. Backup, then clear cached `image` fields in Desktop Local Storage key
   `hermes.plugin.hermes-bots.bot-meta-v2`; stamp `imageKind: photo` /
   `custom: true` on each entry.
6. Reopen Hermes Desktop. Roster re-fetches from assets.

### 3–4. `profiles.set_asset` + `profiles.configure`

Use Hermes-managed Python (has `tui_gateway`). Discover the binary under
`$HERMES_HOME/tools/python-*/bin/python3`. Import `tui_gateway.methods_profiles`
so handlers register, then call `tui_gateway.server.handle_request`.

```bash
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
HERMES_PY=$(ls -d "$HERMES_HOME"/tools/python-*/bin/python3 2>/dev/null | sort -V | tail -1)
# SRC= folder of slug-named PNGs; MAP stem→slug (include p→default)
"$HERMES_PY" - <<'PY'
import sys, os, base64, subprocess, tempfile
from pathlib import Path

os.environ["HERMES_HOME"] = str(Path.home() / ".hermes")
sys.path.insert(0, str(Path.home() / ".hermes" / "hermes-agent"))
import hermes_bootstrap
import tui_gateway.methods_profiles  # register handlers
from tui_gateway.server import handle_request

SRC = Path.home() / "Documents/images/agents/avatars"  # adjust
MAP = {"p": "default", "forge": "forge"}  # stem → hermes slug; expand as needed

def make256(src: Path) -> bytes:
    tmpdir = Path(tempfile.mkdtemp())
    tmp = tmpdir / "sq.png"
    out = subprocess.check_output(
        ["sips", "-g", "pixelWidth", "-g", "pixelHeight", str(src)], text=True
    )
    w = h = None
    for line in out.splitlines():
        if "pixelWidth" in line:
            w = int(line.split(":")[-1])
        if "pixelHeight" in line:
            h = int(line.split(":")[-1])
    side = min(w, h)
    subprocess.check_call([
        "sips", "--cropToHeightWidth", str(side), str(side),
        "--cropOffset", str((h - side) // 2), str((w - side) // 2),
        str(src), "--out", str(tmp),
    ], stdout=subprocess.DEVNULL)
    dest = tmpdir / "256.png"
    subprocess.check_call(
        ["sips", "-z", "256", "256", str(tmp), "--out", str(dest)],
        stdout=subprocess.DEVNULL,
    )
    return dest.read_bytes()

for stem, slug in sorted(MAP.items(), key=lambda x: x[1]):
    src = SRC / f"{stem}.png"
    blob = make256(src)
    data = "data:image/png;base64," + base64.b64encode(blob).decode("ascii")
    handle_request({
        "jsonrpc": "2.0", "id": 1, "method": "profiles.set_asset",
        "params": {"name": slug, "asset": "avatar", "data": data},
    })
    handle_request({
        "jsonrpc": "2.0", "id": 2, "method": "profiles.configure",
        "params": {
            "name": slug,
            "ui_meta": {
                "hermes-bots": {
                    "imageKind": "photo", "custom": True, "shape": "blobatar",
                }
            },
        },
    })
    home = Path.home() / ".hermes"
    path = (
        home / "assets" / "avatar.png"
        if slug == "default"
        else home / "profiles" / slug / "assets" / "avatar.png"
    )
    print(f"OK {slug} bytes={path.stat().st_size if path.exists() else 0}")
PY
```

Verify: each target `avatar.png` should be roughly 50–120 KB (256×256 photo),
not a tiny SVG raster.

### 5. Clear Desktop `bot-meta-v2` cache

Desktop must stay quit. Key lives in Chromium Local Storage LevelDB:

`~/Library/Application Support/Hermes/Local Storage/leveldb`

Value format: tag byte `0x01` + UTF-8 JSON object keyed by bot id
(`local::default`, `<slug>`, `local::<slug>`, …). Backup the whole
`Local Storage` folder first.

```bash
# Desktop quit. One-time: npm install classic-level in a throwaway dir.
BACKUP="$HOME/Library/Application Support/Hermes/Local Storage-backup-$(date +%Y%m%d-%H%M%S)"
cp -a "$HOME/Library/Application Support/Hermes/Local Storage" "$BACKUP"

cd /tmp && mkdir -p hermes-ls-edit && cd hermes-ls-edit
npm install classic-level --silent

node <<'NODE'
const { ClassicLevel } = require('classic-level')
const fs = require('fs')
const path = require('path')
const os = require('os')
const dbPath = path.join(
  os.homedir(), 'Library/Application Support/Hermes/Local Storage/leveldb'
)
const db = new ClassicLevel(dbPath, { valueEncoding: 'buffer', keyEncoding: 'buffer' })

;(async () => {
  await db.open()
  const keys = []
  for await (const [k] of db.iterator()) keys.push(k)
  const key = keys.find((k) => {
    const s = k.toString('utf8')
    return s.includes('bot-meta-v2') && !s.includes('migrated')
  })
  const raw = await db.get(key)
  if (raw[0] !== 1) throw new Error('unexpected value tag ' + raw[0])
  const parsed = JSON.parse(raw.slice(1).toString('utf8'))
  let cleared = 0
  for (const meta of Object.values(parsed)) {
    if (!meta || typeof meta !== 'object') continue
    if (typeof meta.image === 'string') {
      delete meta.image
      cleared++
    }
    meta.imageKind = 'photo'
    meta.custom = true
    if (!meta.shape) meta.shape = 'blobatar'
  }
  const body = Buffer.from(JSON.stringify(parsed), 'utf8')
  await db.put(key, Buffer.concat([Buffer.from([1]), body]))
  await db.close()
  console.log('cleared images', cleared)
})().catch((e) => { console.error(e); process.exit(1) })
NODE
```

Do not edit LevelDB while Desktop is running.

## Symptoms → fix

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Roster shows old faces after disk install | `bot-meta` still has `image`; `pullServerAvatars` skips assets | Quit Desktop → clear `bot-meta-v2` images → reopen |
| Disk `avatar.png` shrinks to ~2–4 KB / 160×160 | SVG backfill (`pushLocalAvatars`) | Quit Desktop → `set_asset` again → clear cache |
| New photo never appears | Desktop was open during install | Quit, re-run fleet steps 3–5 |
| `set_asset` / type errors on system Python | Wrong interpreter (needs Hermes 3.14+ stack) | Use `$HERMES_HOME/tools/python-*/bin/python3` |

## Related

- Layout / `ui_meta` shape fields: `profile-map.md`
- Lifecycle pointer: `recipes.md` **5b**
- Presentation fields: `workspace.md`
