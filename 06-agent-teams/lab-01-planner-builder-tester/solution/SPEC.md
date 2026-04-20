# Feature — `stats` subcommand for todo-cli

Add a `stats` subcommand to the todo CLI that prints summary counts and the oldest open todo.

## Input

```
python todo.py stats
```

No flags. Reads state from `./todos.json` the same way the existing `list` subcommand does.

## Output

Plain text to stdout, exactly four lines:

```
total: <N>
open: <N>
done: <N>
oldest open: <title or "(none)">
```

- `total` — every todo, regardless of status.
- `open` — todos where `done == false`.
- `done` — todos where `done == true`.
- `oldest open` — the title of the open todo with the smallest `created_at` timestamp. If there are no open todos, print `(none)`.

Exit code 0 on success. Exit code 1 if `todos.json` is missing or malformed.

## Constraints

- No new dependencies. Standard library only.
- Existing `add`, `list`, `done` subcommands unchanged.
- `--help` text for `stats` should be one line: "Print summary statistics for the todo list."

## Tests

Add tests under `tests/test_stats.py` covering:

1. Empty todo list → prints zeros and `(none)`.
2. Mix of open and done → counts are correct and `oldest open` is the earliest-created open todo (not the earliest overall).
3. Missing `todos.json` → exit code 1, error message on stderr.
