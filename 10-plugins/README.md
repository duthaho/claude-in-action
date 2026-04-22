# Section 10 — Plugins

> Status: **v1.3 — built**

A **plugin** is a directory containing a `.claude-plugin/plugin.json` manifest plus any of: slash commands, skills, subagents, hooks, MCP server configs. Plugins are installed from a **marketplace** — another directory (or repo) with a `.claude-plugin/marketplace.json` that lists the plugins it ships.

The flow:

1. Point Claude Code at a marketplace: `/plugin marketplace add <path-or-url>`
2. Install a plugin from it: `/plugin install <plugin-name>@<marketplace-name>`
3. Use the plugin's commands/skills/hooks like any other

## Learning objectives

After this section you can:

- Install a plugin from a local marketplace directory.
- Author a plugin that bundles a command and a skill.
- Write a `marketplace.json` that publishes a plugin.

## Labs

- [lab-01-install-a-plugin](lab-01-install-a-plugin/) — beginner, ~20 min — install the bundled `greeter` plugin from a local marketplace.
- [lab-02-author-a-plugin](lab-02-author-a-plugin/) — intermediate, ~35 min — bundle a slash command and a skill into a `quote-of-the-day` plugin.
- [lab-03-publish-to-marketplace](lab-03-publish-to-marketplace/) — intermediate, ~30 min — write the `marketplace.json` that publishes the plugin from lab-02.

## References

- [Official docs: Plugins](https://docs.claude.com/en/docs/claude-code/plugins)
- [Official docs: Plugin marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
