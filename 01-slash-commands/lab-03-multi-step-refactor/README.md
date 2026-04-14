# Lab 03 — Multi-Step Refactor Command

> Section: 01-slash-commands · Difficulty: intermediate · Est: 35 min

## Goal

You build a `/refactor` slash command that runs a three-step pipeline on a file you name: lint, auto-fix, test. If any step fails, the command stops and reports the failure — it does not plow through. This is your first command that chains multiple tools in order and has non-trivial failure behavior. By the end you understand how to structure a command body as a checklist, how to make Claude short-circuit on error, and why you should think about what "done" means before writing a command that changes files.

## Prerequisites

- Claude Code installed and logged in
- Python 3 on your PATH (`python --version`)
- Completed: [lab-01-hello-command](../lab-01-hello-command/), [lab-02-commit-command](../lab-02-commit-command/)

## What you'll build

- A slash command `.claude/commands/refactor.md` inside `starter/`
- The command takes one argument: the path to a Python file
- When invoked, it runs `python -m py_compile` (lint), applies a simple auto-fix (adding a missing trailing newline), and runs a stdlib `unittest` file — stopping at the first failure
- Running `/refactor messy.py` on the provided `starter/messy.py` leaves the file syntactically clean and the test green

## Steps

1. Change into the lab directory:
   ```bash
   cd 01-slash-commands/lab-03-multi-step-refactor
   ```
2. Inspect the starter. `starter/messy.py` is missing a trailing newline and has a small bug. `starter/test_messy.py` is a short stdlib `unittest` test that imports `messy` and asserts a value — it will fail until `messy.py` is fixed.
3. Confirm the tests fail today:
   ```bash
   cd starter
   python -m py_compile messy.py          # should surface the bug
   python -m unittest -v test_messy.py    # should fail
   ```
4. Still inside `starter/`, create `.claude/commands/refactor.md`. Its body should:
   - Take `$ARGUMENTS` as the target file path.
   - Step 1: run `python -m py_compile <file>`. If it fails, print the error and stop.
   - Step 2: check whether `<file>` ends with a newline. If not, append one.
   - Step 3: run `python -m unittest -v test_<basename>.py` if that file exists; otherwise run `python -m unittest discover -v`. If it fails, print the error and stop.
   - On success, print a one-line summary: `"refactor ok: <file>"`.
   Use `argument-hint: <file.py>` in the frontmatter.
5. Launch Claude Code from inside `starter/` and run `/refactor messy.py`. Claude should step through the checklist, report the `py_compile` error, ask you to approve the fix or fix it itself depending on how you phrased the instruction, then re-run and finish green.
6. Re-run the manual checks from step 3. Both should now succeed.

## Verify

```bash
bash ../../scripts/verify-lab.sh 01-slash-commands/lab-03-multi-step-refactor
```

The script checks that:

- `starter/.claude/commands/refactor.md` exists and has `argument-hint` frontmatter
- The body references `py_compile`, `unittest`, and `$ARGUMENTS`
- `starter/messy.py` imports cleanly (`python -m py_compile` exits 0)
- `starter/test_messy.py` passes (`python -m unittest` exits 0)

## Solution

See `solution/` for the finished command and the repaired files. `solution/README.md` walks through why we short-circuit on error and why the trailing-newline step belongs between lint and test, not after.

## Going further

- Parametrize the auto-fix step: accept a second argument, e.g. `/refactor messy.py --strip-trailing-whitespace`.
- Make the command idempotent — running it twice in a row on a clean file should be a fast no-op, not re-run the tests.
- Add a rollback: if the test step fails, restore `<file>` from `git stash` so the working tree is clean.

## References

- [Official docs: Slash commands](https://docs.claude.com/en/docs/claude-code/slash-commands)
