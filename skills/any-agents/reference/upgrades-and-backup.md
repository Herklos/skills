# Upgrades and backup

## Pin versions

```bash
# Host: Mac / Linux
cd /opt/any && git rev-parse HEAD && ./bin/any version
cd /opt/anybao && git rev-parse HEAD
./runtime/target/release/anyrt --help | head -1
```

Record SHAs in your runbook. Alpha: **no migrations** — test upgrades
on a **separate account / data dir** before touching production.

```bash
export ANY_DATA_DIR="$HOME/.any-upgrade-test"
any init
# build new binaries; point anyrt at a test port; smoke chat + triggers
```

## Backup

1. **Mnemonic** offline (paper / password manager) — account recovery.
2. **Data dir** (`~/.any` or `/var/lib/any`): stop server, snapshot the
   directory (includes wallet, sdk, index). Encrypt at rest.
3. **Self-hosted nodes**: back up dockercompose `STORAGE_DIR` / Mongo /
   Garage volumes per upstream upgrade guide.
4. **Logical export** of important spaces: `scripts/export-ndjson.sh`.
5. **Traces**: `any local export --space <bao> --names
   trace_runs,trace_records,trace_blobs --out traces.anyenc.gz` when
   you need deep debug off-box.

Never commit mnemonics, `.connectors.env`, or `wallet.key`.

## Upgrade steps (safe order)

1. Snapshot data dir + note git SHAs.
2. Read anybao ADR index + any CHANGELOG/README warnings.
3. Upgrade `any` first; `anyrt drift` against the new OpenAPI.
4. `make kernel && make runtime`; restart serve.
5. Redeploy overlays if program contracts changed.
6. Chat + trigger smoke tests.

If shapes break, restore the snapshot and keep the old pin.
