# Solution — lab-02-imports-and-layers

The finished starter has four memory-relevant files:

- `CLAUDE.md` — project rules only, with an `@import` pulling in API conventions.
- `fake-home/.claude/CLAUDE.md` — personal Python preferences.
- `docs/memory/api-style.md` — API conventions for files under `api/`.
- `todo.py`, `README.md` — unchanged.

## Why the split matters

The bloated starting file had three kinds of guidance mixed together. Each kind has a different *scope*, and that scope determines which layer it belongs in:

- **Personal preferences** (type hints, f-strings, pathlib) apply to every Python project you touch. If you put them in a project's `CLAUDE.md`, you have to copy them to the next project, and the next. Worse, every time you tweak a preference you have to find all the copies. User-level memory is the right layer.
- **Project rules** (no dependencies, don't touch unrelated code) apply only to *this* project. They would be wrong in another repo — plenty of Python projects have dependencies. Project-level memory is the right layer.
- **Subdirectory conventions** (API style) apply only to files under `api/`. Putting them in the main `CLAUDE.md` makes the file harder to read and mixes scopes. An imported sub-file keeps the project memory readable and gives you a natural place to grow each convention.

## Why `@import`, not copy-paste

`@import` means the sub-file is the source of truth. If you later decide API responses should include a `request_id` field, you edit one place. A pasted copy means the main `CLAUDE.md` and a "remember to update this" comment that someone will miss.

`@import` also keeps the main file scan-friendly. When it's 20 lines instead of 60, you actually re-read it every few weeks. When it's 200 lines nobody reads it at all.

## Key decisions

- **Fake home directory.** Real user-level memory lives at `~/.claude/CLAUDE.md`. Using `$PWD/fake-home` keeps the lab from modifying your real setup, which would affect every other Claude session on your machine.
- **`@import docs/memory/api-style.md` without a leading `./`.** Both work, but the path-relative form is shorter and easier to copy between projects.
- **Rules section stays in the main file, not imported.** Rules change fast and are the reason you open `CLAUDE.md` in the first place. Keep the high-churn content front and center.

## If you got stuck

- **"Claude still lectures me about type hints in a non-Python project."** The type-hint rule is probably still in the project `CLAUDE.md`. Move it to the user layer.
- **"`@import` didn't work."** Check that the path is relative to the `CLAUDE.md` that contains the import, not to the repo root.
- **"/memory only shows the project file."** You launched Claude without setting `HOME` to the fake-home dir. The user file only loads from `~/.claude/`.
