# Multi-device and sync

## Add a second device (mnemonic restore)

Host: **Mac / Linux** on the new machine.

```bash
export ANY_DATA_DIR="${ANY_DATA_DIR:-$HOME/.any}"
any init --mnemonic-stdin    # paste the SAME recovery phrase; prefer stdin over --mnemonic
any run
any auth status
```

- Same phrase → same account id; **device key is always fresh**.
- **Never copy `wallet.key`** between machines. One device key = one
  endpoint; two processes sharing a key evict each other from the relay.
- Derivation index: `any` defaults to index **1** (0 is anytype's).
  Restoring an index-0 account needs `--index 0`.

Check: both devices list the same spaces after sync; chat history in
the bao space appears on both (lean layer). Trace **bodies** stay
device-local (`anyrt` debugging docs / ADR-023).

## LAN sync (mDNS)

Configured under `p2p` in `any` config (`docs/05-config.md`):

```yaml
p2p:
  enabled: true          # opt-out with false
  port: 0                # QUIC; 0 = persisted/ephemeral
  localDiscovery: true   # mDNS; on Linux/server default on; managed macOS may differ
```

Env: `ANY_P2P_LOCAL_DISCOVERY`. Status: `any sync-status`, `any debug p2p`
(CLI surface in `docs/01-cli.md`).

## Internet-wide sync (iroh / global P2P)

SDK layer: [global-p2p.md](https://github.com/anyproto/any-sync-sdk/blob/main/docs/global-p2p.md).
`any` packaging: `docs/30-global-p2p.md`.

```yaml
p2p:
  global:
    enabled: true                    # absent = on when relay URLs known
    relayUrls:
      - https://relay-fr-1.anytype.io
      - https://relay-de-1.anytype.io
    pkarrRelayUrls:                  # account discovery / cold find
      - https://pkarr-fr-1.anytype.io
      - https://pkarr-de-1.anytype.io
    insecureRelay: false             # true only for http:// dev relays
    port: 0
```

Env kill-switch: `ANY_P2P_GLOBAL_ENABLED=false`.

On the **embedded production network** with no custom nodeconf, production
relays are filled in and the layer runs. A config that names a custom
**nodeconf** gets relays **only if you name them** (staging/self-host stay
off Anytype relays by default).

### Self-hosted iroh relay

Set your own `relayUrls` (and usually `pkarrRelayUrls`). Use
`insecureRelay: true` only for `http://` lab relays. **UNVERIFIED** here:
end-to-end run against a self-hosted iroh relay binary — confirm with
`any debug p2p` / `SDK.P2PStatus().Global` after deploy.

Cold restore: a brand-new empty data dir has no space rows to dial.
First restore needs **sync nodes**, **LAN**, or the **pkarr account
layer**. Once spaces exist, global peers reconnect from persisted records.

## Sync nodes (backup / first restore)

Default `any` joins the **production any-sync network** (embedded
nodeconf). Override:

```bash
# Host: Mac / Linux
export ANY_NETWORK_NODECONF_PATH=/etc/any/nodeconf.yaml
# or network.nodeconfPath / inline network.nodeconf in config.yaml
```

Minimal self-hosted stack (from any-sync-dockercompose README):

| Service | Role |
|---------|------|
| `any-sync-coordinator` | Spaces / members |
| `any-sync-node` ×3 | Document sync |
| `any-sync-filenode` | File storage (needs Garage + Redis) |
| `any-sync-consensusnode` | Conflict consensus |
| MongoDB, Redis, Garage | Dependencies |

```bash
# Host: Linux
git clone https://github.com/anyproto/any-sync-dockercompose
cd any-sync-dockercompose
cp .env.example .env
# set EXTERNAL_LISTEN_HOSTS to the server IP
docker compose up -d
# client config generated under ./etc/client.yml → point any nodeconfPath at it
```

Files durability needs nodes typed `fileV2` in the nodeconf; without them
attach still works offline-first (`docs/17-files.md`).

Check: `GET /v1/health` reports `networkId`; `any space sync <id>` forces
a head-sync round.

## Active bao across devices

Multiple `anyrt serve` processes on the **same account** elect one
active chat responder (ADR-015, app slug `bao`). Standby does not
double-answer chat; device-**pinned** triggers still fire on standby.
Switch via devices API / UI ("Use this device"). Do not run two serves
against **one** `any` server (shared device identity → both answer).
