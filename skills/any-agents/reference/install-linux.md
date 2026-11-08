# Install on Linux (Hetzner)

Host: **Linux server**. Prefer a **dedicated OS user** for agents
(`reference/security.md`).

## Prerequisites

- Git, Go 1.26.2+, `make`, `curl`, `jq`
- For anyrt: nix **or** recent Rust + Python 3.14 + `uv`
- systemd

## 1. Dedicated user

```bash
# Host: Linux — as root
useradd --system --create-home --home-dir /var/lib/any --shell /usr/sbin/nologin anyagent
# or interactive: useradd -m -s /bin/bash anyagent
mkdir -p /var/lib/any /opt/any /opt/anybao
chown -R anyagent:anyagent /var/lib/any /opt/any /opt/anybao
```

## 2. Build `any`

```bash
# Host: Linux — as anyagent
cd /opt/any
git clone https://github.com/anyproto/any .
make build
# Linux local embedder needs libffi.so.8; nix develop helps on NixOS
```

Init once (save mnemonic offline; never in unit files or git):

```bash
# Host: Linux — as anyagent
export ANY_DATA_DIR=/var/lib/any
/opt/any/bin/any init
```

## 3. systemd unit for `any`

`/etc/systemd/system/any.service`:

```ini
[Unit]
Description=any local-first database server
After=network.target

[Service]
Type=simple
User=anyagent
Group=anyagent
Environment=ANY_DATA_DIR=/var/lib/any
Environment=ANY_LISTEN_ADDR=127.0.0.1:2046
# Optional passkey: Environment=ANY_WALLET_PASSKEY=…  (prefer a credential file)
ExecStart=/opt/any/bin/any run --data-dir /var/lib/any --addr 127.0.0.1:2046
Restart=on-failure
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true
# Keep loopback-only; do not publish 2046 on a public interface

[Install]
WantedBy=multi-user.target
```

```bash
# Host: Linux — as root
systemctl daemon-reload
systemctl enable --now any.service
systemctl status any.service
curl -fsS http://127.0.0.1:2046/v1/health | jq
```

## 4. Build anyrt

```bash
# Host: Linux — as anyagent
cd /opt/anybao
git clone https://github.com/anyproto/anybao .
# nix develop  OR  install rustup + uv + python3.14
uv sync
make kernel
make runtime
```

Write `/var/lib/any/anybao.toml` (or checkout-local) with
`addr = "http://127.0.0.1:2046"`. Place `.connectors.env` beside it
(mode `0600`, owner `anyagent`).

## 5. systemd unit for anyrt

`/etc/systemd/system/anyrt.service`:

```ini
[Unit]
Description=anyrt agent runtime
After=any.service
Requires=any.service

[Service]
Type=simple
User=anyagent
Group=anyagent
WorkingDirectory=/opt/anybao
Environment=HOME=/var/lib/any
ExecStart=/opt/anybao/runtime/target/release/anyrt serve --config-file /var/lib/any/anybao.toml
Restart=on-failure
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

```bash
# Host: Linux — as root
systemctl enable --now anyrt.service
journalctl -u anyrt.service -f
# expect: overlays synced — agent ready
```

Check: `scripts/any-health.sh` and `scripts/agent-ready.sh` from an
operator shell that can reach loopback (SSH tunnel if remote).

## Firewall

Do **not** expose `2046` / anyrt `control_port` (default 7010) beyond
loopback. Use SSH tunnels from Mac/iPhone clients, or LAN-only bind
after a deliberate review (`reference/security.md`).

## Self-hosted sync network

For offline/private networks, point `any` at a nodeconf from
[any-sync-dockercompose](https://github.com/anyproto/any-sync-dockercompose)
(`ANY_NETWORK_NODECONF_PATH` / `network.nodeconfPath`). See
`reference/multi-device-and-sync.md`. Production network is embedded by
default for a stock binary.
