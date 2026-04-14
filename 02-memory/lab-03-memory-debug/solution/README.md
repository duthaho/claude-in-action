# Solution — lab-03-memory-debug

The finished state has three corrected memory files plus a `notes.md` that walks through each bug. Read `solution/notes.md` for the full write-up — that file *is* the solution, more than the corrected rule files are.

## Why each bug is interesting

- **Bug A (silent non-load)** is the bug you won't find by reading. Casing and filename mistakes don't produce errors, and Claude Code doesn't warn about near-miss filenames. `/memory` is the only tool that shows you the truth. The general lesson: when something isn't behaving like you expect, run `/memory` first, before you start editing rules.
- **Bug B (weak word)** is the bug that makes rules feel unreliable. "Avoid" and "prefer" are weaker than new authors expect. The general lesson: memory is natural language, and the words have strength gradients. Pick the strength that matches the consequence.
- **Bug C (layer conflict)** is the bug that makes people blame the wrong file. You see Claude breaking a project rule and you edit the project `CLAUDE.md`, but the real problem is that the user layer is contradicting it. The general lesson: user-level memory should contain nothing that could disagree with a reasonable project rule.

## The debugging loop

1. Run `/memory`. Note which files are loaded.
2. If a file you expected is missing → filename/location bug.
3. If all files are loaded but Claude is breaking a rule → read each file and look for a conflicting rule in a layer you'd forgotten about.
4. If all files are loaded and none contradict but Claude is still breaking the rule → the rule's *wording* is too weak. Promote "avoid" to "never", "prefer" to "always".

## If you got stuck

- **"I can't see the local file output of `/memory`."** Are you running Claude with `HOME` set to the fake home? The local file is found relative to the project dir, so it should still show regardless of HOME — but if the whole `/memory` command looks wrong, check that you launched from inside `starter/`.
- **"I fixed the typo but Claude still commits."** You have two bugs to fix, not one. Keep going.
- **"I don't believe 'avoid' loses to 'always'."** Try it. Write a project rule that says "avoid writing tests" and a user rule that says "always write tests". Which one wins when you ask Claude to add a feature?
