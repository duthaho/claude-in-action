# Lab 02 — Imports and Layers

> Section: 02-memory · Difficulty: beginner · Est: 25 min

## Goal

You take a bloated `CLAUDE.md` that mixes user-wide preferences with project-specific rules and split it into three layers: user (in `~/.claude/CLAUDE.md`), project (in `./CLAUDE.md`), and an imported sub-file for a specific submodule. By the end you understand *why* the split matters (the same project rules shouldn't have to repeat your personal Python preferences) and you can use `@import` to keep long project memory readable.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-project-claude-md](../lab-01-project-claude-md/)

## What you'll build

- A slimmer `starter/CLAUDE.md` that contains only project-specific rules
- A user-level file at `starter/fake-home/.claude/CLAUDE.md` (we use a fake home dir so the lab doesn't modify your real one) with your personal Python preferences
- A `starter/docs/memory/api-style.md` with API conventions, imported by the project `CLAUDE.md` using `@import`

## Steps

1. Change into the lab's starter directory:
   ```bash
   cd 02-memory/lab-02-imports-and-layers/starter
   cat CLAUDE.md
   ```
2. Notice `CLAUDE.md` is huge — maybe 60 lines — and mixes three different kinds of guidance:
   - Personal Python preferences ("prefer pathlib over os.path", "always use type hints")
   - Project-specific rules ("todos.json state file", "no dependencies")
   - API style conventions for the `api/` subdirectory ("use trailing slashes", "return 201 on create")
3. Split the file:
   - Move the **personal Python preferences** to `starter/fake-home/.claude/CLAUDE.md`. Create the directory if needed.
   - Move the **API conventions** to `starter/docs/memory/api-style.md`.
   - Leave **project-specific rules** in `starter/CLAUDE.md`, and replace the API section with an `@import docs/memory/api-style.md` line.
4. Read `starter/CLAUDE.md` again. It should be noticeably shorter — probably under 30 lines — and you should see the `@import` line doing the work.
5. (Optional but recommended) Launch Claude Code from inside `starter/` with `HOME` pointed at `fake-home` so the user-level file is loaded:
   ```bash
   HOME="$PWD/fake-home" claude
   ```
   Ask `/memory` and confirm that Claude reports both the user file and the project file as loaded.

## Verify

```bash
bash ../../scripts/verify-lab.sh 02-memory/lab-02-imports-and-layers
```

The script checks that:

- `starter/CLAUDE.md` is under 40 lines and contains an `@import docs/memory/api-style.md` line.
- `starter/fake-home/.claude/CLAUDE.md` exists and mentions Python preferences.
- `starter/docs/memory/api-style.md` exists and mentions trailing slashes.

## Solution

See `solution/` for one acceptable split. `solution/README.md` explains why user-level files should never contain project-specific names and why `@import` is better than copy-paste for shared conventions.

## Going further

- Add a **local** override at `starter/.claude/CLAUDE.local.md` with a one-time rule (e.g., "for this branch only, skip migrations"). Confirm via `/memory` that it loads after the project file and wins conflicts.
- Move the API conventions into a second `@import` — try `@import ./docs/memory/api-style.md` with an explicit relative path. Which works in Claude Code?
- Grep your real user-level `CLAUDE.md` (if you have one) for any project names. Any that appear are probably in the wrong layer.

## References

- [Official docs: Memory — imports and layers](https://docs.claude.com/en/docs/claude-code/memory)
