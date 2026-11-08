---
name: monocode-operator
description: Use MonoCode's /operator app bridge to inspect and manage project sessions, worktrees and notes, or a calling Mono's soul, memory and habits. Use when asked to automate MonoCode through /operator.
license: MIT
metadata:
  version: 1.0.0
  category: agents
  domain: monocode
---

# MonoCode operator

`/operator` at the start of a composer message enables app access for that thread during an active agent turn. Use the CLI path supplied by the app and run its `app --help` for the installed version's actions and JSON fields. Credentials are session-scoped; do not print or export them. See the [upstream guide](https://github.com/hardbeat920/monocode/blob/main/docs/agent-access.md).

Discover before changing anything: identify the intended project and session, inspect available models and current state using the help-listed read actions, and respect the caller's project scope. `sessions.start` creates a project session, not a persistent Mono. It submits a prompt by default; use a draft when an unsent session is requested. Stop, archive, delete, worktree creation, notes writes and sending prompts have real effects. Retry an uncertain mutation only with the same request ID and identical input.

In a Mono turn, the bridge may additionally expose that Mono's Soul, memory, habits, artifacts and completion notifications. Check help and target scope before using them; Soul updates require the current hash where supported. Habit runs execute real tasks. Do not assume these actions manage another Mono.

## Creating persistent Monos

The installed Native 0.16.0 `app --help` inspected for this skill exposes no Mono roster or creation action. `/operator` therefore cannot be assumed to create Monos. Check the current build's help for a newly supported action; if present, follow its documented schema and verify the resulting Mono. Otherwise use the MonoCode UI to create and configure the requested Mono, if an appropriate GUI automation interface is available. Inspect existing Monos first to avoid duplicates, use the requested model and project assignments, and reopen settings to verify. Do not silently replace a Mono with a project session, manipulate internal endpoints, or edit the app database. If UI automation is unavailable, report the limitation and provide a concrete creation specification.

For Mono lifecycle, identity, Anytype mapping and event limitations, use the repository's [monocode-agents skill](../monocode-agents/SKILL.md). UI automation is version-dependent and has not been tested by this skill's authors.
