# Project Memory — todo-cli

## Summary

`todo-cli` is a deliberately tiny Python todo manager used as a learning target in the `claude-in-action` repo. The point of the project is that it is *small* — every added feature should be questioned against "does this serve the lab that needs it, or am I just polishing?".

## Architecture

- Entry point: `todo.py` (a single file, no package).
- Subcommand dispatch is hand-written in `main()`. There is no CLI framework (argparse, click, typer) and there should not be one.
- State lives in `./todos.json` in the current working directory. One JSON array of `{"text": str, "done": bool}` objects. No schema migrations — if the shape changes, delete the file.
- Error handling: print to stderr and exit with code 2. Do not raise.

## Rules

Never:

- Add a dependency. Standard library only.
- Reformat or touch code you were not asked to change. Targeted edits only.
- Add fields to the todo data model (timestamps, priorities, tags, due dates, IDs) unless the user explicitly asks for them. They are intentionally missing.
- Introduce a CLI framework.
- Write docstrings longer than one line.

Prefer:

- Small, reviewable diffs.
- Failing loudly over silent fallbacks.
- Pathlib over `os.path`.

## Testing

There are no tests yet. When asked to add a feature, propose a corresponding pytest test in the same commit, then implement both after approval. Tests use stdlib `unittest` or `pytest` if the user already has pytest installed — do not pull it in as a new dependency yourself.

## When in doubt

Ask before adding. This project is small on purpose.
