# todo-cli

A tiny Python todo manager used as shared starter material across several labs in this repo. Dependency-free (standard library only), small enough to read in one sitting.

## Usage

```bash
python todo.py add "buy milk"
python todo.py list
python todo.py done 0
```

State lives in `./todos.json` next to the script. Delete that file to start over.

## Why this project exists here

Labs in sections 01 (slash commands), 02 (memory), 04 (skills), 08 (hooks), and 11 (checkpoints) all need "a small realistic project" to operate on. Rather than make up a new toy each time, they reuse this one. That way you only learn one codebase, and each lab can focus on the Claude Code feature it's actually teaching.

When a lab uses this as a starter, it is copied into the lab's `starter/` directory — you are never asked to edit the canonical copy here directly.

## Known missing features (deliberate)

- No timestamps. No priorities. No due dates. No tags.
- No tests. (Lab 01-03 asks you to add them.)
- No error handling beyond "print and exit 2".
- No CLI framework — argv parsing is manual and minimal.

These are intentional gaps so labs have something meaningful to build on top.
