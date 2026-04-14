# Lab 01 — First Skill

> Section: 04-skills · Difficulty: beginner · Est: 25 min

## Goal

You author your first skill: a `changelog-writer` that takes the commits since the last release tag and produces a Keep-a-Changelog-formatted entry. This is a skill real projects actually need. By the end you know the exact file layout of a project-scoped skill, what the YAML frontmatter does, and why a skill's *description* field matters more than its body (the description is what Claude uses to decide when to load it).

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-project-claude-md](../../02-memory/lab-01-project-claude-md/)

## What you'll build

- A project-scoped skill at `starter/.claude/skills/changelog-writer/SKILL.md`
- The skill's frontmatter has a `name` and a `description` written to help Claude match it to "write a changelog entry" or "what changed since v0.2.0" prompts
- The skill's body tells Claude exactly what shape the output should take (Keep-a-Changelog, sorted by category, linked commits)

## Steps

1. Change into the starter:
   ```bash
   cd 04-skills/lab-01-first-skill/starter
   ls -la
   git log --oneline -20
   ```
   The starter is a small git repo with about a dozen commits since the `v0.1.0` tag. These are the commits the skill will summarize.
2. Create the skill directory and file:
   ```bash
   mkdir -p .claude/skills/changelog-writer
   ```
3. Author `.claude/skills/changelog-writer/SKILL.md`. The file must start with YAML frontmatter delimited by `---` lines, containing:
   - `name: changelog-writer`
   - `description:` a sentence or two explaining *when* Claude should reach for this skill. Write it for the model, not for humans — include keywords like "changelog", "release notes", "what changed", "Keep a Changelog".
   The body (after the second `---`) is plain Markdown. It should tell Claude to:
   - Run `git describe --tags --abbrev=0` to find the most recent tag.
   - Run `git log <tag>..HEAD --oneline` to get the commits since.
   - Group commits by conventional-commit type (feat / fix / chore / docs / refactor).
   - Output a Markdown section formatted like Keep a Changelog: `## [Unreleased]`, then `### Added`, `### Changed`, `### Fixed`, etc.
4. Launch Claude Code from inside `starter/` and ask it *"write a changelog entry for the commits since v0.1.0"*. Claude should recognize the skill from the description, load it, and produce a Keep-a-Changelog block.
5. Ask Claude a different question like *"what was the last commit message?"* — confirm Claude does **not** unnecessarily load the changelog-writer skill. Skill descriptions should be narrow enough that they only match when relevant.

## Verify

```bash
bash ../../scripts/verify-lab.sh 04-skills/lab-01-first-skill
```

The script checks that:

- `starter/.claude/skills/changelog-writer/SKILL.md` exists.
- The file has YAML frontmatter with `name: changelog-writer` and a non-empty `description`.
- The description mentions "changelog" or "release notes" (so Claude's skill matcher can find it).
- The body mentions `git log` and "Keep a Changelog" (or a category like `Added`/`Changed`/`Fixed`).

## Solution

See `solution/` for one acceptable skill. `solution/README.md` explains why the description field is the most important single line in a skill and how to write one that matches tightly without being brittle.

## Going further

- Add a second skill `.claude/skills/release-tagger/SKILL.md` that takes the changelog entry and creates a git tag for it. How does Claude decide which one to run first?
- Narrow your description — remove the word "changelog" and add a typo. Does Claude still pick the skill up?
- Move the skill to `~/.claude/skills/changelog-writer/` (user scope). It should now be available in every repo on your machine.

## References

- [Official docs: Skills](https://docs.claude.com/en/docs/claude-code/skills)
