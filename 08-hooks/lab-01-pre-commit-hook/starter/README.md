# starter

You wire a `PreToolUse` hook that blocks `git commit` calls when any staged file contains a `TODO` marker. The hook lives at `.claude/hooks/block-todo-commit.sh`; settings.json wires it up with the right matcher and `if` filter.

See the top-level lab README for the step-by-step.
