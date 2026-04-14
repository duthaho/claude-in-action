# Lab 02 — Skill with Bundled Resources

> Section: 04-skills · Difficulty: beginner · Est: 30 min

## Goal

You build an `adr-writer` skill — for Architecture Decision Records — that ships with two bundled template files the skill body references. This is the next step beyond a self-contained skill: when the thing you're automating has a rigid file shape, it is better to package the shape as a resource than to ask Claude to reproduce it from a description in prose. By the end you know exactly where resource files live, how the skill body references them, and when you should use a resource file vs. inlining the content in `SKILL.md`.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-first-skill](../lab-01-first-skill/)

## What you'll build

- A skill directory `starter/.claude/skills/adr-writer/` containing:
  - `SKILL.md` — frontmatter + instructions
  - `resources/template-short.md` — a 15-line ADR template for simple decisions
  - `resources/template-long.md` — a fuller ADR template with `Context`, `Decision`, `Consequences`, `Alternatives considered`, and `References` sections
- The skill body tells Claude: pick the short template for small decisions, the long one for significant ones, read the chosen template file, fill it in, write the result to `docs/adr/NNNN-<slug>.md`.

## Steps

1. Change into the starter:
   ```bash
   cd 04-skills/lab-02-skill-with-resources/starter
   ls -la
   ```
   The starter has a `docs/adr/` directory with an example `0001-use-python.md` and nothing else.
2. Create the skill directory layout:
   ```bash
   mkdir -p .claude/skills/adr-writer/resources
   ```
3. Author the two template files under `resources/`. They should both be valid Markdown. The short one has `# ADR NNNN — <Title>`, a `## Decision` section, and a `## Status` line. The long one adds `## Context`, `## Consequences`, `## Alternatives considered`, and `## References`.
4. Author `.claude/skills/adr-writer/SKILL.md`. The frontmatter `description` should trigger on keywords like "ADR", "architecture decision", "decision record". The body should:
   - Take the decision topic from the user's request.
   - Decide short or long. Ask if unclear, but default to short for decisions described in under 15 words.
   - Read the chosen template file from `resources/template-short.md` or `resources/template-long.md`. (Reference the files using relative paths like `resources/template-short.md` — skills are loaded with the skill directory as CWD.)
   - Fill in the headings with content based on the user's request. Never leave a placeholder heading empty.
   - Assign the next ADR number by scanning `docs/adr/` for the highest `NNNN-*.md` and adding 1.
   - Write the result to `docs/adr/NNNN-<kebab-case-slug>.md`.
5. Launch Claude Code from inside `starter/` and ask *"write an ADR for switching the database from SQLite to Postgres — context: we're hitting write contention in production."*. Expect a long-template ADR at `docs/adr/0002-switch-to-postgres.md`.
6. Ask *"write an ADR saying we're going to use 2-space indentation in the frontend."* — expect a short-template ADR at `docs/adr/0003-two-space-frontend-indentation.md`.

## Verify

```bash
bash ../../scripts/verify-lab.sh 04-skills/lab-02-skill-with-resources
```

The script checks:

- `starter/.claude/skills/adr-writer/SKILL.md` exists with frontmatter matching `adr` or `architecture decision`.
- `starter/.claude/skills/adr-writer/resources/template-short.md` and `template-long.md` exist and have the expected headings.
- The skill body references both template files by relative path.
- The skill body mentions the numbering behavior (`NNNN`, `next`, or `highest`) and the output path pattern.

## Solution

See `solution/` for one acceptable version. `solution/README.md` explains why the templates are separate files rather than inline in `SKILL.md`, and when you should prefer resource files over inline content.

## Going further

- Add a third template `resources/template-superseded.md` for ADRs that supersede an earlier decision. How does the skill body decide between three templates?
- Inline the short template directly in `SKILL.md` and delete the file. Does the skill still work? Which version is easier to maintain when you want to change the template shape?
- Move the skill to `~/.claude/skills/adr-writer/` and use it in a different real repo. The bundled templates come with it.

## References

- [Official docs: Skills](https://docs.claude.com/en/docs/claude-code/skills)
