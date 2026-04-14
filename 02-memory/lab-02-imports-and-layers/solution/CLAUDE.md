# Project Memory — todo-cli

## Summary

`todo-cli` is a deliberately tiny Python todo manager used as a learning target. Keep it small.

## Architecture

- Entry point: `todo.py` (single file, no package).
- State lives in `./todos.json` in the current working directory.
- Subcommand dispatch is hand-written in `main()`. No CLI framework.

## Project rules

- Never add a dependency — standard library only.
- Do not reformat or touch code you were not asked to change.
- Do not add fields to the todo data model (timestamps, priorities, tags, due dates, IDs) unless asked. They are intentionally missing.
- Error handling: print to stderr and exit with code 2. Do not raise.
- Do not introduce a CLI framework.

## API conventions (apply to files under `api/`)

@import docs/memory/api-style.md

## Testing

When asked to add a feature, propose a pytest test first, implement after approval.
