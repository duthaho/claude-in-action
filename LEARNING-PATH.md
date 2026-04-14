# Learning Path

A suggested order through the 13 sections for someone brand new to Claude Code. The order is not arbitrary — each section builds on ideas from earlier ones.

> Sections marked **v1.0** are ready today. Sections marked **coming** are stubs; the plan at `CHANGELOG.md` lists which release each one ships in.

## Phase 1 — Foundations (do these first)

You need these to get anything else done.

1. **[01 — Slash Commands](01-slash-commands/)** — v1.0
   The simplest way to turn a natural-language instruction into a reusable action. Start here even if you think you already know how slash commands work; the "hello" lab takes ten minutes and catches the usual misconceptions.

2. **[02 — Memory](02-memory/)** — v1.0
   How Claude Code knows things about your project across sessions. After this, you stop re-explaining the same conventions every time.

3. **[03 — Configuration & Permissions](03-configuration-and-permissions/)** — v1.1
   `settings.json`, allowlists, permission modes. This is the safety net for everything that follows.

## Phase 2 — Extending Claude (the power tools)

Each of these gives Claude a new capability.

4. **[04 — Skills](04-skills/)** — v1.1
   Auto-loading bundles of instructions + resources. Skills are how you give Claude durable expertise it can bring to many projects.

5. **[07 — MCP](07-mcp/)** — v1.1
   Model Context Protocol: plug Claude into external tools (databases, APIs, filesystems) with a standard interface.

6. **[08 — Hooks](08-hooks/)** — coming in v1.2
   Shell commands that fire on Claude events. Use these to automate safety checks, formatting, notifications.

## Phase 3 — Orchestration (multi-agent workflows)

Now you can coordinate more than one Claude at a time.

7. **[05 — Subagents](05-subagents/)** — coming in v1.2
   Dispatch a specialized agent (reviewer, researcher, planner) without polluting your main context.

8. **[06 — Agent Teams](06-agent-teams/)** — coming in v1.2
   Long-lived cooperating agents that share tasks and messages. A step beyond ad-hoc subagent dispatch.

## Phase 4 — Packaging & Safety Nets

These exist to make the rest of the repo livable day-to-day.

9. **[10 — Plugins](10-plugins/)** — coming in v1.3
   Bundle commands + skills + hooks into a distributable plugin.

10. **[11 — Checkpoints](11-checkpoints/)** — coming in v1.3
    Rewind and branch your session when an experiment goes sideways.

## Phase 5 — Advanced & Automation

Final 20% that unlocks unusual workflows.

11. **[09 — Channels](09-channels/)** — coming in v2.0
    Event-driven messaging: Telegram, Discord, iMessage → Claude Code sessions.

12. **[12 — Advanced Features](12-advanced-features/)** — coming in v2.0
    Background tasks, image inputs, thinking budgets.

13. **[13 — CLI](13-cli/)** — coming in v2.0
    Running Claude headless from scripts and CI.

## How fast to go

A beginner who already codes comfortably and does one lab per sitting finishes Phase 1 (3 sections, 9 labs once complete) in about a week of evenings. Don't rush Phase 1 — the rest of the repo assumes you internalized memory and permissions.
