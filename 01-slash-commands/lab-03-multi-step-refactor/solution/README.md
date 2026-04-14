# Solution — lab-03-multi-step-refactor

The finished state has three files:

- `.claude/commands/refactor.md` — the slash command.
- `messy.py` — typo fixed, trailing newline present.
- `test_messy.py` — unchanged.

## Why this works

The command body is a numbered checklist. Claude reads it top-to-bottom and runs each step as a tool call. The two things that make this more than a sequential script:

- **Short-circuit on failure.** Step 1 says "stop" explicitly if `py_compile` still fails after one retry. Without that sentence, Claude will often try to fix the code repeatedly, drift into unrelated refactoring, or run the test step anyway. Natural-language instructions need the exit condition explicit.
- **One-byte edit on step 2.** The instruction says "do not touch anything else" for the trailing-newline fix. Without that, Claude will sometimes reformat the whole file while it's editing. We do not want a linter; we want exactly this one change.

## Why lint-then-newline-then-test, not lint-then-test-then-newline

The newline fix is between lint and test on purpose. If we tested before fixing the newline, some pytest plugins would flag the missing-newline warning as a failure and confuse the order of problems the learner has to diagnose. Running the fix first gives the test step a file that is already in its intended shape.

## Why `python -m py_compile` and not `ruff check` or `flake8`

`py_compile` ships with Python. A learning repo that requires the learner to `pip install` a linter before a lab works has failed its first job. Real projects should use a real linter — but the lab is about slash command structure, not about picking a linter. Same reason we use stdlib `unittest` instead of `pytest`: the lab must work on a clean Python install.

## Key decisions

- **`argument-hint: <file.py>`.** This appears in `/help` and when the user starts typing the command. It is the difference between `/refactor ?` and `/refactor <file.py>` in the completion UI.
- **`$ARGUMENTS` in the body.** Claude substitutes the text the caller typed after the command name. If the user runs `/refactor messy.py`, `$ARGUMENTS` is `messy.py`.
- **One retry, not infinite.** Step 1 allows exactly one fix-and-retry. If we allowed unbounded retries Claude could loop on a genuinely broken file.

## If you got stuck

- **"Claude refactored everything."** Step 2 didn't say "only the trailing newline". Natural-language instructions need the scope explicit.
- **"Claude ran the test step after lint failed."** Step 1 didn't say "stop". Add the word.
- **"`$ARGUMENTS` came out empty."** You invoked `/refactor` with no argument. The command should probably check for that and bail — a good extension for the "going further" section.
