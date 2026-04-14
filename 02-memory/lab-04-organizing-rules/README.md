# Lab 04 — Organizing Rules

> Section: 02-memory · Difficulty: beginner · Est: 25 min

## Goal

You take a bloated `CLAUDE.md` organized by topic — architecture, testing, commit hygiene, code style — and decompose it into auto-discovered files under `.claude/rules/`. This is the *structured* alternative to `@import` you met in lab 02: instead of listing imports by hand, you drop topic files into a conventional directory and Claude picks them up automatically. By the end you understand both mechanisms, you can explain the tradeoffs out loud, and you have a repo where each rule lives under a filename that tells you what it's about.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-project-claude-md](../lab-01-project-claude-md/), [lab-02-imports-and-layers](../lab-02-imports-and-layers/)

## What you'll build

- Four new files under `starter/.claude/rules/`:
  - `architecture.md`
  - `testing.md`
  - `commits.md`
  - `style.md`
- A trimmed `starter/CLAUDE.md` containing only a short project summary and a one-line note that detailed rules live under `.claude/rules/`
- Each rules file is 5–20 lines and focused on one topic
- The original bloated content is gone from `CLAUDE.md`; nothing is duplicated between the two locations

## Steps

1. Change into the starter and read the current file:
   ```bash
   cd 02-memory/lab-04-organizing-rules/starter
   wc -l CLAUDE.md
   cat CLAUDE.md
   ```
   It's about 50 lines and mixes four clearly separable topics under `## Architecture`, `## Testing`, `## Commit hygiene`, and `## Style`.
2. Create the rules directory:
   ```bash
   mkdir -p .claude/rules
   ```
3. Move each topic section into its own file. For each:
   - Filename matches the topic (`architecture.md`, `testing.md`, `commits.md`, `style.md`).
   - The body is just the content — no `## Architecture` heading wrapping it, since the filename already says the topic. Use `#`-level headings inside the file if you want substructure.
   - Keep the content unchanged. This lab is about *moving* rules, not rewriting them.
4. Trim `CLAUDE.md` down to three lines: a `# Project` heading, a one-sentence project summary, and a line that says *"Detailed rules live under `.claude/rules/`."*. Nothing else.
5. Launch Claude Code from inside `starter/` and run `/memory`. Claude should report four files loaded from `.claude/rules/` in addition to `CLAUDE.md`. Confirm nothing was silently dropped.
6. Ask Claude *"what commit message format does this project use?"* — the answer should come from `commits.md`, proving the rules file actually reached the model.

## Verify

```bash
bash ../../scripts/verify-lab.sh 02-memory/lab-04-organizing-rules
```

The script checks that:

- `starter/.claude/rules/` contains exactly the four expected files (`architecture.md`, `testing.md`, `commits.md`, `style.md`).
- Each rules file is non-empty.
- `starter/CLAUDE.md` is under 10 lines and mentions `.claude/rules`.
- The trimmed `CLAUDE.md` no longer contains the detailed topic headings (`## Architecture`, `## Testing`, etc.) — no duplication between the two locations.

## Solution

See `solution/` for one acceptable split. `solution/README.md` has the full comparison table between `.claude/rules/` and `@import`, when to reach for each, and why the "one topic per filename" discipline matters more than it looks.

## Going further

- Add a fifth rules file `security.md` covering secrets handling. Does adding a new topic require editing anything else? (It shouldn't — that's the whole point of auto-discovery.)
- Rename `rules/commits.md` to `rules/git.md`. Does anything break? What does this tell you about how Claude discovers the files?
- Take the `.claude/rules/` approach from this lab and re-do lab 02's split using rules files instead of `@import`. Which is easier to read afterwards?

## References

- [Official docs: Memory — organizing rules](https://docs.claude.com/en/docs/claude-code/memory)
