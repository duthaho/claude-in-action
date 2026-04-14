# User Memory — Python preferences

These preferences apply to every Python project I work on. They are not specific to any one repo.

- Always use type hints on public functions.
- Prefer `pathlib.Path` over `os.path`. Never mix them.
- Use f-strings, never `%` formatting or `.format()`.
- Imports grouped: stdlib, third-party, local. Blank line between groups.
- Double quotes for strings unless the string contains a double quote.
- `from __future__ import annotations` at the top of every module.
- Never use `print` for errors; use `sys.stderr` or `logging`.
- Type-check with mypy strict.
- Two blank lines between top-level functions, one between methods.
