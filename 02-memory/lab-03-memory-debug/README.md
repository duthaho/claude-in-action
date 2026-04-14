# Lab 03 — Memory Debug

> Section: 02-memory · Difficulty: intermediate · Est: 30 min

## Goal

You debug a broken memory setup. The starter contains contradictory rules across three layers — user, project, and local — plus a subtle typo that makes one of them silently not load. Claude reports in conversation that it's following one set of rules, but actually acts on another. Your job is to use `/memory`, some grep, and the precedence rules you learned in lab 02 to figure out which rule is winning and why. By the end you know how to read the output of `/memory`, what "local" layer means, and the three most common ways a `CLAUDE.md` setup goes silently wrong.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-project-claude-md](../lab-01-project-claude-md/), [lab-02-imports-and-layers](../lab-02-imports-and-layers/)

## What you'll build

You don't write new rules. You fix the ones that exist. The finished state has:

- A corrected `starter/CLAUDE.md` (one bug fixed)
- A corrected `starter/fake-home/.claude/CLAUDE.md` (another bug fixed)
- A `starter/notes.md` where you record, in your own words, *which rule was winning before each fix and why*

## Steps

1. Change into the starter:
   ```bash
   cd 02-memory/lab-03-memory-debug/starter
   cat CLAUDE.md
   cat fake-home/.claude/CLAUDE.md
   cat .claude/CLAUDE.local.md
   ```
2. Read `notes.md` to see the reported symptom: *"I asked Claude to add a feature and it immediately committed. I thought I had a rule that said never commit without approval."*
3. Launch Claude Code with `HOME` set to the fake home dir and ask `/memory`. Record the output in `notes.md` under a heading `## /memory output (before fix)`. You should see three files — or maybe only two, which is itself a clue.
4. Identify the three bugs (one per file):
   - **Bug A:** A rule file that looks loaded but isn't (a filename typo, wrong extension, or wrong location).
   - **Bug B:** A rule that is weaker than it looks (uses "avoid" where it should use "never", or is buried under a heading Claude deprioritizes).
   - **Bug C:** A layer precedence mistake where a later layer silently overrides an earlier one without the author realizing.
5. Fix the bugs one at a time. For each fix, add a new heading to `notes.md` (`## Bug A — fixed`, etc.) explaining in 2–3 sentences what the bug was and why your fix works.
6. Re-run `/memory` and confirm all three files are loaded. Ask Claude to add a feature and confirm it now proposes the change instead of committing directly.

## Verify

```bash
bash ../../scripts/verify-lab.sh 02-memory/lab-03-memory-debug
```

The script checks that:

- `starter/notes.md` contains headings for all three bugs (A, B, C) with "fixed" somewhere in each.
- `starter/.claude/CLAUDE.local.md` exists (bug A was a filename typo; the original file was misnamed).
- `starter/CLAUDE.md` uses the word "never" in its no-commit rule (bug B).
- `starter/fake-home/.claude/CLAUDE.md` does NOT contain a rule that contradicts the project file's no-commit rule (bug C — the user-level rule was overriding it with "auto-commit ok on my machine").

## Solution

See `solution/` for one pass through the debugging. `solution/README.md` walks through each bug, what `/memory` output revealed, and the general principle you can apply to debug future memory setups.

## Going further

- Break the setup yourself in a new way and see if a friend or another Claude session can diagnose it.
- Run `/memory` in a real project of yours. Are there surprises? Any files listed you didn't expect? Any you expected that aren't listed?
- Add a rule to your user-level `CLAUDE.md` that says "when you encounter contradictory rules, stop and ask". Does Claude actually do it?

## References

- [Official docs: Memory layers and precedence](https://docs.claude.com/en/docs/claude-code/memory)
