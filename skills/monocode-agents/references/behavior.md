# Mono behavior and verification

The following is documented upstream, not a guarantee for every installed build. Check the installed version and controls. Sources: [README](https://github.com/hardbeat920/monocode), [changelog](https://github.com/hardbeat920/monocode/blob/main/CHANGELOG.md), [provider setup](https://github.com/hardbeat920/monocode/blob/main/docs/providers.md).

- Monos retain conversations across restarts and can be reordered. Details includes provider, model, model settings and project assignments. Soul and memory persist separately from conversation messages. Resetting a conversation retains soul, memory and habits; do not assume deletion has the same effect.
- Memory supports facts, topic notes and an archive. Common credential formats saved through the app CLI are redacted, but this is not a guarantee that all secrets are detected. Preserve existing information and avoid storing secrets.
- Habits support hourly, daily, weekday and weekly schedules in local time while MonoCode is open. They can be paused, resumed or run immediately; the UI shows recent outcomes. Runs use background sessions with tool access and may request approval. Missed schedules over two hours are skipped. Check the installed version for current limits and behavior; running immediately is an actual execution, not a preview.
- Mono sessions can use the local `app` CLI for supported project operations. Upstream also documents `app artifacts.list`, `artifacts.read`, and `artifacts.write` for documents; actual availability and syntax must be discovered in the active environment. Artifact creation and changes are writes. Do not infer Mono lifecycle commands from these capabilities.
- Native preview and production share installed data; development mode uses a separate database. Follow upstream backup guidance before preview testing. Avoid simultaneous edits from both apps.

## Evidence boundary

Upstream changelog entries for 0.8.0–0.13.0 describe these features. In the authoring session, no Mono management CLI or dedicated Mono management tool was exposed; no lifecycle, scheduling, or artifact operation was exercised. The presence of MonoCode's visual tool is not evidence of a Mono management API. Inspect the actual app or session interface before giving operational instructions or claiming success.
