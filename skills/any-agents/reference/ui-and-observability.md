# UI and observability

Ways to **follow** chat and agent work. Host: **Mac / Linux**. All talk to
the same local `any` HTTP API. Prefer loopback.

## Surfaces (pick by need)

| Surface | What you see | How |
|---------|--------------|-----|
| Embedded web UI | Spaces, objects, chat, members, network log | Browser → `$ANY_ADDR/ui` |
| **any-tui** | Live chat list + bao status bar + compose | Terminal client |
| `anyrt trace follow` | Live effect / model / tool stream for a run | Second terminal |
| any-ui (desktop) | Polished app; embeds any + anyrt | Product desktop client |

`any-sync-admin` is for sync-node ops, not agent chat.

## 1. Embedded web UI (`/ui`)

Served by `any` when `webUI.enabled` is true (default). Verified on smoke
`any v0.3.8-nightly`: `GET http://127.0.0.1:2046/ui` → 200 HTML.

```bash
# Host: Mac / Linux
open "http://127.0.0.1:2046/ui"    # or browse ANY_ADDR/ui
```

Docs describe a debug harness (space picker, object tree, chat, members,
network log). Disable with `webUI.enabled: false` in any config. Official
quickstart: send to bao chat here or via `any chat send`.

## 2. any-tui (terminal)

Repo: https://github.com/anyproto/any-tui — IRC-style client over
`any` REST + SSE. Lists every chat (bao heads the list), live messages,
compose/reply, sync badges. Status bar shows bao presence from the same
`bao.status` beats as control `/status` / any-ui.

```bash
# Host: Mac / Linux — build
git clone https://github.com/anyproto/any-tui && cd any-tui
cargo build --release
# or: nix run github:anyproto/any-tui
```

```bash
# Host: Mac / Linux — run (OVERRIDE default :7001)
./target/release/any-tui --api http://127.0.0.1:2046/v1
# optional: --agent-space bao --no-auto-read
```

**Port note:** any-tui README still defaults `--api` to
`http://127.0.0.1:7001/v1`. Match your real `any` listen (usually **2046**).

Keys (vim-flavoured): `j`/`k` move, `i` compose, `?` help, `q` quit.
While bao runs, the bottom bar shows cell / tool-call progress; idle shows
`✦ bao`. Credential-request bubbles appear if no LLM key is configured —
fill `.connectors.env` and restart `anyrt serve` (TUI cannot inject keys).

## 3. Live traces (`anyrt trace follow`)

Full turn internals (effects, HTTP, model spans) as records land:

```bash
# Host: Mac / Linux — from anybao checkout; anyrt --addr is a URL
./runtime/target/release/anyrt trace follow \
  --addr http://127.0.0.1:2046 --program toolcaller
anyrt trace ls --addr http://127.0.0.1:2046 --program toolcaller
anyrt trace show --addr http://127.0.0.1:2046 run_<id> --stats
```

Exits when the followed run completes. More: `reference/debugging.md`.

## 4. Desktop any-ui

Product desktop client that embeds `any` and anyrt in-process (Help →
Import connector keys; Settings → Model). Same agent space as standalone
`anyrt serve` — **do not** run both against one chat or you get double
replies. Install channel / public repo availability can change; prefer
docs.any.org / anyproto release notes over inventing URLs.

## Suggested watch layout

1. Keep `any run` + `anyrt serve` running.
2. Browser `/ui` **or** `any-tui --api …/v1` for chat.
3. Second terminal: `anyrt trace follow --program toolcaller` for depth.
