# Lab 02 — Author a Plugin

> Section: 10-plugins · Difficulty: intermediate · Est: 35 min

## Goal

You take loose pieces — a slash command and a skill — and bundle them into a **plugin directory** with a `plugin.json` manifest. The plugin is called `quote-of-the-day`: it ships a `/quote` command that picks a motivational quote from a bundled list, and a `wordcount` skill that counts words in a file Claude reads. By the end you understand the plugin directory layout, the required `plugin.json` fields, and how commands and skills are located inside a plugin (they live in `commands/` and `skills/` siblings of `.claude-plugin/`, exactly as they would in a project's own `.claude/`).

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-install-a-plugin](../lab-01-install-a-plugin/) — you need to recognise the plugin directory shape
- Completed: [lab-01-hello-command](../../01-slash-commands/lab-01-hello-command/) and [lab-01-first-skill](../../04-skills/lab-01-first-skill/) — you need to have written a command and a skill before
- Tools: `python --version` ≥ 3.9 (only used by `verify.sh`)

## What you'll build

A directory tree under `starter/quote-of-the-day/`:

```
quote-of-the-day/
  .claude-plugin/
    plugin.json       # you populate this
  commands/
    quote.md          # you write this
  skills/
    wordcount/
      SKILL.md        # you write this
  quotes.txt          # bundled data the /quote command reads
```

## Steps

1. Change into the starter:
   ```bash
   cd 10-plugins/lab-02-author-a-plugin/starter
   ls quote-of-the-day
   ```
   The starter ships an empty `plugin.json` stub, an empty `commands/` directory, an empty `skills/` directory, and a pre-filled `quotes.txt` (ten motivational quotes, one per line — don't edit this).
2. Fill in `quote-of-the-day/.claude-plugin/plugin.json`. The required fields are:
   - `name` — must be `"quote-of-the-day"` (this is what the user types in `/plugin install`)
   - `version` — `"1.0.0"` (semver)
   - `description` — one sentence explaining what the plugin does
   - `author` — an object with at least a `name` field

   Keep it minimal. The manifest is identity, not documentation.
3. Write `quote-of-the-day/commands/quote.md`. It's a normal slash command — YAML frontmatter with a `description`, then the prompt body. The body should instruct Claude to:
   - Read `${CLAUDE_PLUGIN_ROOT}/quotes.txt` (that env var resolves to the plugin's install path).
   - Pick one line at random.
   - Reply with just that line, nothing else.
4. Write `quote-of-the-day/skills/wordcount/SKILL.md`. YAML frontmatter with `name: wordcount` and a `description` whose keywords mention word count / word frequency. The body is the procedure:
   - Read the file path the user mentioned.
   - Count words (split on whitespace).
   - Reply with `<N> words in <path>`.
5. Open a Claude Code session inside `starter/` and sanity-check the plugin directory:
   ```bash
   python -c "import json; print(json.load(open('quote-of-the-day/.claude-plugin/plugin.json'))['name'])"
   ```
   Must print `quote-of-the-day`. If Python can't parse your JSON, Claude Code can't either.

## Verify

```bash
bash ../../scripts/verify-lab.sh 10-plugins/lab-02-author-a-plugin
```

The script checks that:

- `starter/quote-of-the-day/.claude-plugin/plugin.json` exists, is valid JSON, and has all four required fields (`name`, `version`, `description`, `author.name`) populated with non-empty strings.
- `starter/quote-of-the-day/commands/quote.md` exists, has YAML frontmatter with a `description`, and references `quotes.txt` somewhere in its body (so `/quote` actually uses the bundled data).
- `starter/quote-of-the-day/skills/wordcount/SKILL.md` exists, has frontmatter with `name: wordcount`, and mentions "word" in the description (for skill-match keyword coverage).
- `starter/quote-of-the-day/quotes.txt` exists and is non-empty (you didn't delete the bundled data).

`verify.sh` does not install the plugin or run `/quote` — installation is covered in lab-01, and authoring is about the directory shape.

## Solution

See `solution/`. `solution/README.md` covers: why the plugin directory has `commands/` and `skills/` as siblings of `.claude-plugin/` (not *inside* it), the `${CLAUDE_PLUGIN_ROOT}` variable and why you use it instead of relative paths, and what the optional `plugin.json` fields are (`homepage`, `license`, `keywords`, `repository`) and when to bother with them.

## Going further

- Add a subagent under `quote-of-the-day/agents/archivist.md` (read-only) that reads `quotes.txt` and reports the three longest quotes. You've now shipped three kinds of thing in one plugin.
- Add a `PreToolUse` hook under `quote-of-the-day/hooks/settings.json` (same shape as section 08) that denies any tool call trying to edit `quotes.txt` from outside the plugin — preserving plugin state.
- Bump `version` to `1.1.0` and add a `changelog.md` to the plugin root. How would a marketplace surface new versions to users?

## References

- [Official docs: Plugins — manifest reference](https://docs.claude.com/en/docs/claude-code/plugins) — required and optional fields for `plugin.json`
- [Official docs: Slash commands](https://docs.claude.com/en/docs/claude-code/slash-commands) — command frontmatter shape is identical inside a plugin
- [Official docs: Skills](https://docs.claude.com/en/docs/claude-code/skills) — `SKILL.md` frontmatter shape is identical inside a plugin
