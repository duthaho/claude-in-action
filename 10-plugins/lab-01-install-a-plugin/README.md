# Lab 01 — Install a Plugin from a Local Marketplace

> Section: 10-plugins · Difficulty: beginner · Est: 20 min

## Goal

You install a plugin that ships inside this lab's `starter/`. The starter contains a fully-built **marketplace** (a directory with a `marketplace.json` listing plugins) and one plugin inside it called `greeter` (a directory with a `plugin.json` and a single slash command). You register the marketplace with `/plugin marketplace add`, install the plugin with `/plugin install`, then call the `/greet` command it added. By the end you understand the two-level directory shape — plugin inside marketplace — and what each manifest does.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-first-skill](../../04-skills/lab-01-first-skill/) (optional — familiar with command/skill authoring helps)
- Tools: none beyond Claude Code

## What you'll build

- Nothing authored by hand — the marketplace and plugin are pre-built. You install and exercise them.
- `INSTALL-LOG.md` in the lab root recording the two commands you ran and the output of `/greet`.

## Steps

1. Change into the lab's starter:
   ```bash
   cd 10-plugins/lab-01-install-a-plugin/starter
   ls marketplace
   ```
   You should see `.claude-plugin/` and `plugins/`. Look at both manifests:
   ```bash
   cat marketplace/.claude-plugin/marketplace.json
   cat marketplace/plugins/greeter/.claude-plugin/plugin.json
   ```
   The `marketplace.json` names the marketplace and lists which plugins it ships. The `plugin.json` is the plugin's own identity — name, version, description.
2. Launch Claude Code from the `starter/` directory:
   ```bash
   claude
   ```
3. Register the marketplace. Inside Claude Code, run:
   ```
   /plugin marketplace add ./marketplace
   ```
   Claude Code reads `marketplace/.claude-plugin/marketplace.json` and registers it as `lab-marketplace` (the `name` field inside the manifest).
4. Install the `greeter` plugin from that marketplace:
   ```
   /plugin install greeter@lab-marketplace
   ```
5. Call the command the plugin added:
   ```
   /greet
   ```
   The command replies with `Hello from the greeter plugin!` — that's the body of `marketplace/plugins/greeter/commands/greet.md`.
6. Create `INSTALL-LOG.md` in the lab root (next to this README) with three sections:
   - The exact `/plugin marketplace add` command you ran.
   - The exact `/plugin install` command you ran.
   - The full reply you got back from `/greet`.

## Verify

```bash
bash ../../scripts/verify-lab.sh 10-plugins/lab-01-install-a-plugin
```

The script checks that:

- `starter/marketplace/.claude-plugin/marketplace.json` exists, is valid JSON, has a `name` field, and lists at least one plugin.
- `starter/marketplace/plugins/greeter/.claude-plugin/plugin.json` exists, is valid JSON, and has `name: "greeter"`.
- `starter/marketplace/plugins/greeter/commands/greet.md` exists.
- `INSTALL-LOG.md` exists in the lab root (the Tier-2 evidence that you actually ran the install).

The install itself is not verified automatically — plugin install mutates user config under `~/.claude`, not this repo, so `INSTALL-LOG.md` is your attestation.

## Solution

See `solution/`. `solution/README.md` explains why plugins live inside marketplaces (not standalone), what the `source` field in `marketplace.json` does, and how plugin name collisions between marketplaces are resolved (the `@marketplace` suffix disambiguates).

## Going further

- Uninstall with `/plugin uninstall greeter@lab-marketplace`, confirm `/greet` no longer works, then reinstall. What state is Claude Code tracking to make this reversible?
- Add a second plugin to `marketplace/plugins/` (copy `greeter` to `farewell`, change the command to say goodbye). Update `marketplace.json` to list both. Install both and test them.
- Try `/plugin marketplace add https://github.com/<some-user>/<some-repo>` with a public Claude Code plugin repo. How is that different from a local path?

## References

- [Official docs: Plugins](https://docs.claude.com/en/docs/claude-code/plugins) — the `plugin.json` manifest reference
- [Official docs: Plugin marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces) — the `marketplace.json` manifest reference
- [Official docs: Slash commands](https://docs.claude.com/en/docs/claude-code/slash-commands) — the `commands/` directory inside a plugin is the same as the one inside a project
