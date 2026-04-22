# Solution — lab-02-author-a-plugin

> Try the steps in the lab's `README.md` first — peek here after.

## Directory shape

```
quote-of-the-day/
  .claude-plugin/
    plugin.json        # identity only
  commands/
    quote.md
  skills/
    wordcount/
      SKILL.md
  quotes.txt           # plugin-owned data, read by /quote at runtime
```

Note the three peers: `.claude-plugin/`, `commands/`, `skills/`. A common early mistake is to nest `commands/` and `skills/` *inside* `.claude-plugin/`. Claude Code does not look for them there — `.claude-plugin/` holds the manifest(s) only, and everything the plugin contributes lives as a sibling.

## Why `${CLAUDE_PLUGIN_ROOT}` instead of a relative path

When the plugin is installed, Claude Code copies the directory to a location under `~/.claude/plugins/` that the learner cannot predict. A command written with `read quotes.txt` would search the *current working directory* of the user's session, not the plugin's install root — the file would be "missing" even though it's bundled.

`${CLAUDE_PLUGIN_ROOT}` resolves at runtime to the plugin's install directory. Always use it when a command or skill references files the plugin bundles.

## Required vs optional manifest fields

Required (verified by `verify.sh`): `name`, `version`, `description`, `author.name`.

Optional but worth considering for real plugins:

- `homepage` — a URL users can visit for docs.
- `license` — SPDX identifier. Plugins without a license are legally ambiguous to redistribute.
- `keywords` — array of strings surfaced by marketplace search.
- `repository` — git URL, surfaced by `/plugin info`.

For this lab the minimum is enough — the plugin is local-only and ephemeral.

## Why a skill and not a second command?

A command is invoked explicitly (`/quote`). A skill activates when Claude notices the user's request matches its description. Bundling both teaches that plugins aren't just "command packs" — they're a distribution mechanism for *any* of Claude Code's extension points.
