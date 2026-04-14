# Project Memory — todo-cli (needs splitting)

## Summary

`todo-cli` is a deliberately tiny Python todo manager used as a learning target. Keep it small.

## Architecture

- Entry point: `todo.py` (single file, no package).
- State lives in `./todos.json` in the current working directory.
- Subcommand dispatch is hand-written in `main()`. No CLI framework.

## Personal Python preferences

- Always use type hints on public functions.
- Prefer `pathlib.Path` over `os.path`. Never mix them.
- Use f-strings, never `%` formatting or `.format()`.
- Imports grouped: stdlib, third-party, local. Blank line between groups.
- Double quotes for strings unless the string contains a double quote.
- `from __future__ import annotations` at the top of every module.
- Never use `print` for errors; use `sys.stderr` or `logging`.
- Type-check with mypy strict.
- Two blank lines between top-level functions, one between methods.

## Project rules

- Never add a dependency — standard library only.
- Do not reformat or touch code you were not asked to change.
- Do not add fields to the todo data model (timestamps, priorities, tags, due dates, IDs) unless asked. They are intentionally missing.
- Error handling: print to stderr and exit with code 2. Do not raise.
- Do not introduce a CLI framework.

## API conventions (apply to files under `api/`)

- All URL paths end with a trailing slash.
- Return `201 Created` on successful POST, with the created resource in the body.
- Return `204 No Content` on successful DELETE, with an empty body.
- Pagination: `?page=N&per_page=M`, default `page=1&per_page=20`, max `per_page=100`.
- Errors return `{"error": "<code>", "message": "<human readable>"}` with status 4xx/5xx.
- All timestamps are ISO 8601 in UTC with `Z` suffix.
- Authentication: `Authorization: Bearer <token>` header, never query param.

## Testing

When asked to add a feature, propose a pytest test first, implement after approval.
