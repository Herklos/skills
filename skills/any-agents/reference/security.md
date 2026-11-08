# Security checklist

## Trust model

- The local `any` HTTP server binds **loopback** and **does not
  authenticate** local callers. Any process on the machine can act as
  the account.
- Agent guest code runs in Wasmtime **without** sockets/filesystem
  (default build). Side effects go through the broker (checked + traced).
- `make runtime-shell` adds `sh.*` / `fs.*` / `bash` (ADR-024) — **off
  by default**. Enable only on hosts you accept as fully trusted.
- Credentials are injected after the effect is recorded; guest/model
  should not see raw keys. Still: loopback can read `agent_secrets`
  values — project fields and never print `value`.

## Isolation recommendations

1. Dedicated OS user for `any` + `anyrt` (see `install-linux.md`).
2. Keep sensitive spaces off machines that run shell-enabled agents or
   untrusted local software.
3. Do not publish `:2046` or anyrt `control_port` beyond loopback;
   use SSH tunnels for remote ops.
4. Workspace-scoped LLM keys; rotate via `.connectors.env` empty delete
   + new value.
5. Never log, commit, or paste the account **mnemonic**, passkeys,
   `.connectors.env`, or `wallet.key`.
6. Prefer one writer mental model: one serve per any server.
7. Review connector OAuth grants; revoke with provider `disconnect()`
   when removing access.

## Checklist before production-ish use

- [ ] Experiment account only until you accept alpha risk
- [ ] Loopback-only listen confirmed (`any status` / ss/lsof)
- [ ] systemd/launchd runs as non-root dedicated user
- [ ] Secrets file mode `0600`, gitignored
- [ ] Shell runtime variant not installed unless required
- [ ] Backup mnemonic + data-dir snapshot tested
- [ ] Second device uses mnemonic restore (not wallet copy)
