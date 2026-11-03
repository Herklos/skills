# Browser and computer use

Docs:
- https://hermes-agent.nousresearch.com/docs/user-guide/features/browser
- https://hermes-agent.nousresearch.com/docs/user-guide/features/computer-use
- https://hermes-agent.nousresearch.com/docs/user-guide/features/bot-screen

Two different toolsets:

| Toolset | What it drives | Typical need |
|---------|----------------|--------------|
| **`browser`** | Web pages via CDP (`browser_exec`, vault, dialogs) | Click/fill/scrape sites; prefer `web_search` / `web_extract` for read-only facts |
| **`computer_use`** | Desktop UI via cua-driver (AX tree, clicks, type) | Native apps, OS dialogs, anything outside a browser tab |

Browser work uses the **browser** toolset, not computer_use. Computer use needs a display (local desktop or Linux Bot Screen). Browser needs the **terminal** toolset as well (`browser_exec` runs local Python).

Enable per profile / platform:

```bash
hermes -p <slug> tools                    # interactive
hermes -p <slug> tools enable browser
hermes -p <slug> tools enable computer_use
hermes -p <slug> tools list
hermes -p <slug> tools --summary
```

## Shared vs dedicated (org language)

Use these labels on Anytype agent pages and map them to Hermes as follows.

### Browser identity

| Org label | Hermes meaning | Config sketch |
|-----------|----------------|---------------|
| **None** | No interactive browser | Leave `browser` toolset disabled |
| **Dedicated throwaway** | Fresh Chromium profile each session; no shared logins | `browser` on; `user_data_dir: ""` (default); `use_real_profile: false` |
| **Dedicated persistent** | This profile alone reuses one Chromium profile dir | `user_data_dir: /path/for/this-profile-only` |
| **Team / shared persistent** | Several agents share one Chromium profile dir (same cookies) | Same absolute `user_data_dir` on each profile; expect contention |
| **Operator real profile** | Snapshot of the human's Chrome/Edge/Brave logins | `use_real_profile: true` (+ optional `real_profile_pin`) |
| **Cloud dedicated** | Managed cloud browser (Browserbase, Browser Use, Firecrawl, Nous, …) | `browser.cloud_provider: …` + provider keys in `.env` |
| **Attach existing** | Drive a running Chrome via CDP | `browser.cdp_url: …` or `/browser connect` |

Default local browsing is **dedicated throwaway** (one browser process per Hermes session name; omit `session` for the shared default session within that chat). Named `session` args give parallel browsers so subagents do not clobber each other.

### Computer / screen

| Org label | Hermes meaning | Config sketch |
|-----------|----------------|---------------|
| **None** | No desktop driving | Leave `computer_use` disabled |
| **Dedicated host desktop** | Drive the gateway/local machine UI (macOS/Windows/Linux with a real display) | Enable `computer_use`; install cua-driver; grant OS permissions |
| **Dedicated Bot Screen** | Per-profile Xfce screen on a **Linux** gateway (own display + browser cookies) | `hermes -p <slug> computer-use screen …` + `bot_desktop.*` |
| **Team / shared host** | Multiple profiles' `computer_use` on the **same** OS user/host (not OS-isolated) | Separate Hermes profiles still share host files/network; document risk |
| **Sandbox desktop** | Screen + computer_use inside docker/ssh sandbox | `bot_desktop.placement: auto` or `terminal`; image `hermes-sandbox:desktop` |
| **Host beside sandbox** | Terminal sandboxed, screen on gateway host | Explicit `bot_desktop.placement: gateway` |

On Linux Bot Screen: **every Hermes profile gets its own screen and its own browser profile**. Screens are work surfaces, not security boundaries (same OS user).

## Browser configuration

```yaml
# <profile>/config.yaml
browser:
  cloud_provider: local          # local | browserbase | browser-use | firecrawl | nous | plugin name
  engine: auto                   # auto (Chromium) | lightpanda (local only)
  headed: false                  # true = visible window; keeps browser across turns
  executable_path: ""            # override Chromium binary
  user_data_dir: ""              # "" = throwaway; set path = persistent dedicated/shared profile
  chromium_args: []
  inactivity_timeout: 120
  command_timeout: 30
  cdp_url: ""                    # attach to existing Chromium
  use_real_profile: false        # consent: snapshot operator's real Chromium profile
  real_profile_pin: ""           # e.g. "Profile 2"; empty = last-used
  real_profile_autoclose: false  # Windows: ask before close-profile to unlock cookies
  auto_local_for_private_urls: true
  dialog_policy: must_respond    # must_respond | auto_dismiss | auto_accept
  dialog_timeout_s: 300
```

```bash
hermes -p <slug> config set browser.cloud_provider local
hermes -p <slug> config set browser.headed false
hermes -p <slug> config set browser.user_data_dir ''
hermes -p <slug> config set browser.use_real_profile false
hermes -p <slug> config set browser.real_profile_pin 'Profile 2'
hermes pm install chromium       # if local Chromium missing
# Destructive — only with explicit user OK (loses unsaved tabs):
# hermes browser close-profile
```

Cloud credentials live in the profile `.env` (never paste values into chat):
`BROWSERBASE_API_KEY` / `BROWSERBASE_PROJECT_ID`, `BROWSER_USE_API_KEY`,
`FIRECRAWL_API_KEY`, … Selection is `browser.cloud_provider` via `hermes tools`
(not autodetection once a selection exists).

Prefer `web_search` / `web_extract` when interaction is not required. Real-profile
browsing is consent-gated: the agent acts with the operator's logins.

## Computer use configuration

```bash
hermes -p <slug> computer-use install
hermes -p <slug> computer-use status
hermes -p <slug> computer-use doctor
# macOS: Accessibility + Screen Recording for the identity doctor names
hermes -p <slug> computer-use permissions
```

```yaml
computer_use:
  cua_telemetry: false
  autostart: false               # Windows: true only if driving over SSH (Session 0)
  permission_mode: standard      # standard | bounded (not unrestricted in config)
  capability_manifest: ""        # path when permission_mode: bounded
  max_image_dimension: 1456
  capture_after_mode: som        # som | ax | vision
  ax_max_elements: 200
  no_overlay: null               # null = auto; true disables cursor overlay
  allow_unsigned_driver: false   # macOS local driver builds only
```

```bash
hermes -p <slug> config set computer_use.permission_mode standard
hermes -p <slug> config set computer_use.capture_after_mode som
```

`computer_use` acts on the machine that hosts the bot's screen (gateway host or
sandbox), never on the Hermes Desktop client machine alone.

### Bot Screen (Linux gateway)

```yaml
bot_desktop:
  geometry: "1440x900"
  auto_start: false
  min_free_memory_mb: 1536
  idle_stop_minutes: 30
  placement: auto               # auto | terminal | gateway
```

```bash
hermes -p <slug> computer-use screen status
hermes -p <slug> computer-use screen install   # TigerVNC + Xfce on host
hermes -p <slug> computer-use screen start
hermes -p <slug> computer-use screen stop
hermes -p <slug> config set bot_desktop.placement auto
hermes -p <slug> config set bot_desktop.auto_start false
```

Human takeover (login / 2FA / CAPTCHA) happens in Hermes Desktop's Screen pane;
hand control back when done. Plan ~1.1–1.5 GB RAM per open screen with a browser.

## Minimal enable sequences

**Local throwaway browser only:**

```bash
hermes -p forge tools enable browser
hermes -p forge config set browser.cloud_provider local
hermes -p forge config set browser.use_real_profile false
hermes pm install chromium
```

**Operator real-profile browser:**

```bash
hermes -p forge tools enable browser
hermes -p forge config set browser.use_real_profile true
# optional: hermes -p forge config set browser.real_profile_pin 'Profile 2'
```

**Computer use on this Mac/PC:**

```bash
hermes -p forge tools enable computer_use
hermes -p forge computer-use install
hermes -p forge computer-use doctor
```

**Linux Bot Screen + computer use:**

```bash
hermes -p forge tools enable computer_use
hermes -p forge tools enable browser
hermes -p forge computer-use install
hermes -p forge computer-use screen install
hermes -p forge computer-use screen start
```

## Safety

1. Confirm before `use_real_profile`, shared `user_data_dir`, `close-profile`, or YOLO/`unrestricted` computer use.
2. Do not put vault/API secrets in Anytype pages; only the capability labels.
3. Shared host / shared Chromium profile is convenience, not multi-tenant isolation.
4. `permission_mode: bounded` needs a reviewed capability manifest path.
