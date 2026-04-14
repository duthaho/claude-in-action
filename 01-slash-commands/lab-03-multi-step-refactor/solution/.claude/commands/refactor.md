---
description: Lint, auto-fix, and test a Python file — stop on the first failure
argument-hint: <file.py>
---

You are running a three-step refactor pipeline on the file passed as `$ARGUMENTS`. Execute the steps in order and stop at the first failure. Do not continue past a failing step.

1. **Lint.** Run `python -m py_compile $ARGUMENTS`. If it exits non-zero, read the error, fix the source file, and re-run `py_compile` once more. If it still fails, print the error and stop with a one-line summary: `"refactor failed at lint: <file>"`.
2. **Auto-fix trailing newline.** If `$ARGUMENTS` does not end with a newline, append one. This is a one-byte edit; do not touch anything else.
3. **Test.** If a file named `test_<basename>.py` exists next to `$ARGUMENTS`, run `python -m unittest -v test_<basename>.py`. Otherwise run `python -m unittest discover -v`. If the tests exit non-zero, print the failing test output and stop with `"refactor failed at test: <file>"`.

On success, print exactly one line: `refactor ok: <file>`.
