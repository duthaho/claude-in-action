# Solution — lab-01-install-a-plugin

> Try the steps in the lab's `README.md` first — peek here after. This file explains *why* the marketplace is shaped the way it is, not how to install a plugin.

## Why plugins live inside marketplaces

A plugin is never installed by path. It is installed *from* a marketplace *by name*. The flow is always:

1. Register a marketplace (which is a directory or repo with a `marketplace.json`).
2. Install a plugin *by name* from that marketplace (`/plugin install <plugin>@<marketplace>`).

The indirection matters for three reasons. First, it lets multiple plugins share one distribution channel: one git repo, one manifest, many plugins. Second, it makes updates tractable: `/plugin marketplace update` re-reads the manifest and surfaces new versions. Third, it resolves name collisions — two marketplaces can both ship a plugin called `greeter` and you disambiguate with `@marketplace-name`.

## What each file does

- `.claude-plugin/marketplace.json` — the marketplace's own identity (`name`, `owner`) plus the list of plugins it ships. The `source` field inside each plugin entry tells Claude Code where to find the plugin's files: here we use a **relative path** (`./plugins/greeter`), but it can also be a git URL.
- `.claude-plugin/plugin.json` — the plugin's identity (`name`, `version`, `description`, `author`). This is read when the plugin is installed; the `name` here is what you use in `/plugin install <name>@<marketplace>`.
- `commands/greet.md` — a slash command, same format as any `.claude/commands/` file in a project. When the plugin is installed, this command becomes available as `/greet` in the session.

## Name collisions

If you later register a second marketplace that *also* ships a `greeter` plugin, you can install both, and `/greet` will be ambiguous. Claude Code resolves this by prefixing the command with the plugin name when necessary (e.g. `/greeter:greet`) — the exact fallback depends on the installed plugin set at runtime, but the `@marketplace` suffix at install time guarantees you always know *which* greeter you installed.

## What you cannot do from a plugin

A plugin is loaded at session start. That means it can ship commands, skills, subagents, hooks, and MCP server declarations — static things. It cannot mutate the user's `~/.claude/settings.json`, read arbitrary files at install time, or run code outside of hook/command execution contexts. Treat plugins as declarative bundles, not installers.
