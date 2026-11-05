# Browser and computer use

Docs:
- https://hermes-agent.nousresearch.com/docs/user-guide/features/browser
- https://hermes-agent.nousresearch.com/docs/user-guide/features/computer-use
- https://hermes-agent.nousresearch.com/docs/user-guide/features/bot-screen
- **Default computer:** https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces

Two different toolsets:

| Toolset | What it drives | Typical need |
|---------|----------------|--------------|
| **`browser`** | Web pages via CDP (`browser_exec`, vault, dialogs) | Click/fill/scrape sites; prefer `web_search` / `web_extract` for read-only facts |
| **`computer_use`** | Desktop UI via cua-driver (AX tree, clicks, type) | Native apps, OS dialogs, anything outside a browser tab |

Browser work uses the **browser** toolset, not computer_use. Computer use needs a display. **Prefer a Cua Space** (plugin `cua-spaces`, `terminal.backend: cua`) so terminal, files, code, and (on Linux Spaces with the desktop stack) browser / `computer_use` / Bot Desktop all run in that isolated machine. Fall back to host desktop or Linux Bot Screen only when the operator needs the real host UI. Browser also needs the **terminal** toolset (`browser_exec` runs local Python unless the Space path is active).

Enable per profile / platform:

```bash
hermes -p <slug> tools                    # interactive
hermes -p <slug> tools enable browser
hermes -p <slug> tools enable computer_use
hermes -p <slug> tools list
hermes -p <slug> tools --summary
```

## Default computer: Cua Spaces

**Default for agents that need a computer (or a sandboxed terminal):** use the **cua-spaces** plugin so Hermes runs terminal, files, and code inside a [Cua Space](https://cua.ai/spaces). Document that choice on the agent page as Surface **Cua Spaces**.

Plugin docs: https://hermes-agent.nousresearch.com/docs/plugins/cua-spaces  
Install source: `https://github.com/trycua/hermes-cua-spaces`

```bash
# Once on the machine (Cua CLI; sign-in only for cloud / account Spaces)
curl -fsSL https://cua.ai/install.sh | sh
cua auth login   # skip for a local-only Space if you stay local

hermes -p <slug> plugins install https://github.com/trycua/hermes-cua-spaces
hermes -p <slug> config set terminal.backend cua
```

Optional plugin settings (`plugins.entries.cua-spaces.settings` via `hermes config set`):

| Setting | Default | Role |
|---------|---------|------|
| `space` | `create` | Fresh Space per run, or name/id of an existing Space |
| `on` | Cua default | `local`, `cloud`, `host:<machine>`, or a named machine |
| `image` | `linux` | `linux` (Ubuntu + desktop image) or `windows` |
| `desktop` | `false` | Set `true` so Linux Spaces get TigerVNC / Playwright / agent-browser / cua-driver for browser + `computer_use` + Bot Desktop |
| `delete_on_exit` | `true` | Delete plugin-created Spaces when Hermes finishes |

```bash
hermes -p <slug> config set plugins.entries.cua-spaces.settings.desktop true
hermes -p <slug> config set plugins.entries.cua-spaces.settings.delete_on_exit false   # keep hermes-default
# hermes -p <slug> config set plugins.entries.cua-spaces.settings.space my-box
```

With `terminal.backend: cua` and a supported Hermes (newer than v0.22.2 / PR #142225), Linux Spaces that have the desktop stack put **terminal, files, code, browser, `computer_use`, and Bot Desktop** in the Space (`bot_desktop.placement: auto`). Windows / macOS Spaces take terminal and files; browser and `computer_use` stay on the host there. Leave `terminal.cwd` unset so the session starts in the Space home.

Watch live with the Cua Spaces app, `cua spaces ls`, or `cua viewer`. Env overrides for one shell: `HERMES_CUA_SPACE`, `HERMES_CUA_ON`, `HERMES_CUA_IMAGE`, `HERMES_CUA_DESKTOP`.

**When not to use Cua Spaces:** the task must drive the operator's real host desktop (Accessibility / Screen Recording on this Mac/PC), or a Linux gateway Bot Screen shared with Hermes Desktop takeover without a Space. Document that exception on the agent page.

## Anytype per-HQ pair → Hermes

Org source of truth (skill `anytype-agents` → `hq-runtime-pair.md`): each HQ owns
one **Computer** (`{HQ} – Cua Spaces`, Docker container/runc by default) and one
**Browser** (`{HQ} – Hermes Chromium`). Org default Browser is **one dedicated
operator Chrome profile per Browser** (`is_real: true`, `browser_engine:
chrome`, unique `real_profile_pin` like `Profile 2`, `browser_source` /
`browser_identity: operator-real-profile`). Anytype create always mints that
Chrome profile on the host first (`anytype-agents` → `hq-runtime-pair.md` →
Create Chrome profile). It is not a separate Cua browser product. Throwaway /
persistent / cloud / CDP remain exception surfaces when `is_real` is false.
Subteams and Agents under that HQ link the same pair. Board and Primary leave
both empty (Primary `computer_surface: none`).

When applying a linked Agent into a Hermes profile, decline as follows (Anytype
does not push configs):

| Anytype | Hermes apply |
|---------|--------------|
| Computer `computer_surface: cua-spaces`, `desktop_enabled: true`, `computer_scope: dedicated` | `plugins install` cua-spaces; `terminal.backend: cua`; `plugins.entries.cua-spaces.settings.desktop: true`; pin `settings.space` to Computer.`cua_space` (full id e.g. `local:engineering-hq`, or short name `engineering-hq`) with `delete_on_exit: false` so the HQ shares one Space instead of minting a throwaway each run |
| Computer.`cua_space` empty | Create the live Space first (`anytype-agents` → `cua-hq-spaces.md`: `--kind container --runtime runc`), then pin; do not invent a Space name that is not on the Computer |
| Browser `is_real: true` (+ `browser_engine: chrome`, dedicated `real_profile_pin`, `browser_source` / `browser_identity: operator-real-profile`) | `tools enable browser`; `browser.cloud_provider: local`; `browser.use_real_profile: true`; `browser.real_profile_pin` = Anytype pin (Chrome directory, e.g. `Profile 2`); `browser.headed: false`. Engine intent is Chrome: use OS default Chromium-family / CDP / `executable_path` when needed; there is no separate `real_profile_browser` key. If the pin directory is missing on the host, create it via `anytype-agents` `hq-runtime-pair.md` before apply |
| Browser `is_real: false` with throwaway / persistent / cloud / CDP | Follow the matching identity row below (`use_real_profile: false`; `user_data_dir` / cloud / `cdp_url` as documented) |
| Agent `computer_surface: none` / empty Computer+Browser (Primary) | Do not enable `computer_use` / Space desktop for that profile unless the user asks; terminal may still use another backend |
| Exception Computer (`host` / `bot-screen`) | Follow Host desktop or Linux Bot Screen sections below; document on the agent page |

Suggested Space naming when pinning `plugins.entries.cua-spaces.settings.space`:
prefer Computer.`cua_space` (full id). Fallback short name `{hq-slug}-hq`
(matches Anytype Computer slug prefix). Create missing Spaces with
`anytype-agents` → `cua-hq-spaces.md`. One Space per HQ keeps Subteams/Agents
under that HQ on the same machine; do not give every agent its own Space unless
the user asks.

Standing redesign rule: do not apply live Hermes profiles until the user says
the Anytype redesign pass is done.

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

Org Anytype default for HQ Browsers is **operator real profile** (`is_real`).
When `is_real` is false, local browsing is **dedicated throwaway** (one browser
process per Hermes session name; omit `session` for the shared default session
within that chat). Named `session` args give parallel browsers so subagents do
not clobber each other. With **Cua Spaces** + desktop stack on Linux (and not
real-profile), the browser runs in the Space (still a dedicated throwaway
profile unless you configure persistence inside that Space).

### Computer / screen

| Org label | Hermes meaning | Config sketch |
|-----------|----------------|---------------|
| **None** | No desktop driving | Leave `computer_use` disabled |
| **Cua Spaces (default)** | Isolated Space for terminal/files/code; Linux + `desktop: true` also hosts browser / `computer_use` / Bot Desktop | Install cua-spaces; `terminal.backend: cua`; prefer `desktop: true` when the agent needs a screen |
| **Dedicated host desktop** | Drive the gateway/local machine UI (macOS/Windows/Linux with a real display) | Enable `computer_use`; install cua-driver; grant OS permissions |
| **Dedicated Bot Screen** | Per-profile Xfce screen on a **Linux** gateway (own display + browser cookies) | `hermes -p <slug> computer-use screen …` + `bot_desktop.*` |
| **Team / shared host** | Multiple profiles' `computer_use` on the **same** OS user/host (not OS-isolated) | Separate Hermes profiles still share host files/network; document risk |
| **Sandbox desktop** | Screen + computer_use inside docker/ssh sandbox (non-Cua) | `bot_desktop.placement: auto` or `terminal`; image `hermes-sandbox:desktop` |
| **Host beside sandbox** | Terminal sandboxed, screen on gateway host | Explicit `bot_desktop.placement: gateway` |

**Prefer Cua Spaces** for new agents. On Linux Bot Screen without Spaces: every Hermes profile gets its own screen and browser profile; screens are work surfaces, not security boundaries (same OS user).
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

## Signing in (passwords, cookies, “browse as me”)

When the linked Browser has `is_real: false`, local browsing is **logged out**
(throwaway Chromium). When `is_real: true` (org default), Hermes snapshots the
operator Chrome profile (consent-gated). Agents that need an authenticated site
must use one of the paths below. **Do not ask the human to paste a password into
chat.** Prefer Hermes vault fills or a configured identity.

Official vault docs:
https://hermes-agent.nousresearch.com/docs/user-guide/features/credential-vault

### Agent playbook (mandatory when a page needs login)

1. Prefer **read-only** tools (`web_search`, `web_extract`, `x_search`, APIs) when
   they can answer without a browser session.
2. If interactive login is required, check Anytype **`vault_grant`** objects for
   this Agent (site / identity label). If none grants the site, escalate to the
   chief / P; do not invent credentials.
3. Use the path that matches the grant / Browser catalog identity:

| Need | Path | How |
|------|------|-----|
| One-off or recurring site login | **Hermes vault** | Say “log into \<site\>”; on first miss Hermes prompts a **masked** password. Later fills via vault tools. CLI: `hermes vault list\|add\|rm`. Passwords never enter model context. |
| Already in 1Password / Bitwarden | **Password manager** | Install + unlock `op` / `bw`; Hermes auto-detects. Unlock once per session (masked). Opt out: `hermes vault sources --disable …`. |
| Stay signed in across sessions (agent-only identity) | **Dedicated persistent** | `browser.user_data_dir: ~/.hermes/profiles/<slug>/browser-profile` + often `browser.headed: true` for the first login / 2FA. Cookies persist in that dir. |
| Browse as the human (existing Chrome/Brave/Edge logins) | **Operator real profile** | `browser.use_real_profile: true` (+ optional `real_profile_pin`). Consent-gated; Hermes snapshots the active profile (does not open the live profile lock). |
| Drive a browser that is already open and signed in | **Attach CDP** | `/browser connect` or `browser.cdp_url`, or chrome-profiles plugin. |
| 2FA / CAPTCHA / passkey | **Human takeover or vault TOTP** | Authenticator seed on the vault item → Hermes enters codes. SMS/email codes → masked prompt. Passkeys / Duo → ask human to complete on device; headed Screen pane for computer_use. |

4. After a successful vault save, continue the task; do not re-ask for the
   password in prose.
5. Headless cron / `-q` cannot answer vault prompts: save/unlock in an
   interactive session first, or use persistent / real-profile cookies.

```bash
# Vault (per profile under ~/.hermes/vault/ or profiles/<slug>/…)
hermes -p <slug> vault list
hermes -p <slug> vault add
# hermes -p <slug> vault sources

# Persistent agent cookies
hermes -p <slug> config set browser.headed true
hermes -p <slug> config set browser.user_data_dir "$HOME/.hermes/profiles/<slug>/browser-profile"

# Browse as the operator (explicit consent)
hermes -p <slug> config set browser.use_real_profile true
# hermes -p <slug> config set browser.real_profile_pin 'Profile 2'
# Destructive unlock of real profile lock — only with explicit user OK:
# hermes browser close-profile
```

**Anytype:** store **capability** only (`vault_grant`: which Agent may use which
site / identity kind / vault handle). Never put passwords, TOTP seeds, or card
numbers in Anytype. Secrets live in Hermes vault, 1Password/Bitwarden, or the
Chromium profile dir.

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

**Default computer: Cua Spaces (terminal + optional desktop stack):**

```bash
hermes -p forge plugins install https://github.com/trycua/hermes-cua-spaces
hermes -p forge config set terminal.backend cua
hermes -p forge config set plugins.entries.cua-spaces.settings.desktop true
hermes -p forge tools enable browser
hermes -p forge tools enable computer_use
```

**Computer use on this Mac/PC (host exception):**

```bash
hermes -p forge tools enable computer_use
hermes -p forge computer-use install
hermes -p forge computer-use doctor
```

**Linux Bot Screen + computer use (non-Space exception):**

```bash
hermes -p forge tools enable computer_use
hermes -p forge tools enable browser
hermes -p forge computer-use install
hermes -p forge computer-use screen install
hermes -p forge computer-use screen start
```
## Safety

1. Confirm before `use_real_profile`, shared `user_data_dir`, `close-profile`, or YOLO/`unrestricted` computer use.
2. Do not put vault/API secrets in Anytype pages; only **`vault_grant`** capability labels (site, identity kind, which agents).
3. Never ask the human to paste passwords into chat; use vault masked prompts or a configured identity path above.
4. Shared host / shared Chromium profile is convenience, not multi-tenant isolation.
5. `permission_mode: bounded` needs a reviewed capability manifest path.
6. Respect `vault_grant` ACLs: no grant for that site → escalate; do not scrape credentials from Memory pages.
