---
name: monocode-agents
description: Create and manage MonoCode Monos as persistent agents, including their identity, projects, model, memory, and habits. Use when asked about MonoCode Monos or applying agent definitions to MonoCode.
license: MIT
metadata:
  version: 1.0.0
  category: agents
  domain: monocode
---

# MonoCode agents

A Mono is an experimental persistent cross-project agent with its own conversation, assigned projects, standing instructions, memory and habits. It runs through an installed, authenticated provider. MonoCode Native is a preview and may differ from the production app; inspect the actual version and available controls before acting. The preview shares the production database: back up with the app closed before testing and avoid concurrent edits from both apps. See the [upstream README](https://github.com/hardbeat920/monocode) and [changelog](https://github.com/hardbeat920/monocode/blob/main/CHANGELOG.md).

For documented behavior and scheduling caveats, read [references/behavior.md](references/behavior.md). For session delegation, app bridge scope and event-trigger research, read [references/coordination.md](references/coordination.md).

For GitHub events, webhooks, SSE and the distinction between automations and Mono habits, read [references/events.md](references/events.md).

## Discover and manage

1. Inspect the Monos rail and existing Mono details before creating or changing one. Enable Monos in Settings if needed. Identify the intended Mono by name and inspect its assigned projects, provider, model and settings.
2. Create a Mono from the rail or floating chat's Mono rail. Set its name and, if requested, mascot, color and background. In Details, choose the provider, model, model settings and assigned projects supported by this installation. Verify the provider is installed and signed in; do not invent a model or substitute a provider without user direction.
3. Use the Soul page for durable Markdown standing instructions (`SOUL.md`), Memory for facts and preferences, and Habits for scheduled tasks. A Mono can also update its soul or memory when asked. Preserve existing material when updating; avoid inserting credentials into prompts or memory. Configure schedules only as requested and verify their timing and enabled state in the app.
4. Reopen Details and the relevant pages to verify the result. Resetting a conversation clears messages but retains soul, memory and habits; it is not equivalent to deleting an agent. Use destructive controls only for the requested target and report their effects.

For the bridge workflow and its Mono creation boundary, see [monocode-operator](../monocode-operator/SKILL.md). Use the app's supported controls for lifecycle changes. `/operator` grants thread-scoped access to the local `app` CLI for documented session, project and note operations; it is not evidence of a Mono lifecycle CLI. Do not edit the database or invent commands when a control is absent. If a feature is unavailable in the installed build, report the limitation.

## Anytype mapping

When explicitly asked to apply an Anytype agent, inspect the agent's role, standing instructions, model intent and project links, then map supported information to one Mono's Soul, provider/model and assigned projects. Editing Anytype alone does not update MonoCode. Do not apply proposed or draft changes as live settings without an explicit request or acceptance. Report any unmapped fields.

Persistent Mono teams or groups are not established by the inspected interfaces. A Mono can delegate to project sessions and receive completion reports; project Automations may provide event triggers. These do not establish event dispatch to another Mono. Explain the distinction and verify the installed interface before relying on it.
