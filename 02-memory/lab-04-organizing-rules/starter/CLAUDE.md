# Project Memory — todo-cli

## Summary

`todo-cli` is a deliberately tiny Python todo manager used as a learning target. Keep it small.

## Architecture

- Entry point is `todo.py`, a single file with no package structure.
- State lives in `./todos.json` in the current working directory.
- Subcommand dispatch is hand-written in `main()`. No CLI framework (argparse, click, typer) and there should not be one.
- Error handling: print to stderr and exit with code 2. Do not raise.

## Testing

- No tests exist yet. When asked to add a feature, propose a corresponding test in the same commit.
- Tests use stdlib `unittest`. Do not pull in `pytest` as a new dependency.
- Every new subcommand needs at least one happy-path test and one error-path test.
- Run tests with `python -m unittest -v`.

## Commit hygiene

- Conventional Commits only. Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`.
- Subject under 72 characters, imperative mood, no trailing period.
- Body is optional but when present should explain *why*, not *what*.
- One logical change per commit. No "wip" commits on main.
- Never commit secrets, API keys, or `.env` files. `./todos.json` is tracked intentionally for demo purposes only.

## Style

- Two blank lines between top-level functions.
- Type hints on every public function.
- f-strings only; never `.format()` or `%`.
- Prefer `pathlib.Path` over `os.path`. Never mix them.
- Double quotes for strings unless the string contains a double quote.
- `from __future__ import annotations` at the top of every module.
