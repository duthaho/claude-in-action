# Lab 01 — Project CLAUDE.md

> Section: 02-memory · Difficulty: beginner · Est: 20 min

## Goal

You write a project-level `CLAUDE.md` for the `todo-cli` sandbox project. A good project memory file captures the things a newcomer needs to know to stop making naive mistakes — where state lives, what is intentionally missing, what conventions the code follows. By the end you have a real artifact you could drop into a real repo, and you know the three mistakes most people make when writing their first `CLAUDE.md`.

## Prerequisites

- Claude Code installed and logged in
- You have read `sandbox/todo-cli/README.md` at least once

## What you'll build

- A new file `starter/CLAUDE.md` that describes the todo-cli project's conventions for Claude
- A short "rules" section that tells Claude what *not* to do (add dependencies, reformat the whole file, write timestamps)
- An "architecture" section that explains where state lives and why

## Steps

1. Change into the lab's starter directory. It contains a copy of the sandbox todo-cli project:
   ```bash
   cd 02-memory/lab-01-project-claude-md/starter
   ls
   # CLAUDE.md does not exist yet — you will write it
   ```
2. Read `todo.py` and `README.md` so you know the shape of the project.
3. Launch Claude Code from inside `starter/` and ask it something simple like *"add a `clear` subcommand that deletes all todos"*. Notice that without a `CLAUDE.md`, Claude might reformat the file, add argparse, introduce a dependency, or write a docstring for every function. Some of those are fine; some are not.
4. Exit Claude. Revert any changes with `git checkout .` if you initialized a repo, or re-copy the starter.
5. Write `CLAUDE.md` at the root of `starter/`. Include these sections (your exact wording can differ):
   - **Project summary** — one paragraph on what todo-cli is and its deliberate constraints.
   - **Architecture** — where state lives (`./todos.json`), how subcommands are dispatched, why there is no CLI framework.
   - **Rules** — the three things Claude should *not* do: add dependencies, reformat untouched functions, add timestamps/priorities/tags to the data model without being asked.
   - **Testing** — how to run tests, or, in this case, the fact that there are none and Claude should propose a test when it adds a feature.
6. Launch Claude Code again from inside `starter/` and ask the same question as step 3. This time the response should respect your rules: no new dependencies, targeted edits, and a proposed test.

## Verify

```bash
bash ../../scripts/verify-lab.sh 02-memory/lab-01-project-claude-md
```

The script checks that `starter/CLAUDE.md` exists, has at least 200 words, includes headings for architecture and rules, and mentions the constraint about dependencies.

## Solution

See `solution/CLAUDE.md` for one way to write it. There is no single "right" `CLAUDE.md` for this project — the point is to cover the three categories (summary, architecture, rules). Compare your draft against the solution and notice what you missed.

## Going further

- Add a "when asked to add a feature" protocol to the rules: "propose the change, wait for approval, then implement." Re-run the same prompt and see how the conversation changes.
- Split "rules" into two levels: *never do this* and *prefer this over that*. Claude distinguishes between the two in practice.
- Ask Claude to review your `CLAUDE.md` for gaps — "what would a new contributor still get wrong about this codebase after reading this file?"

## References

- [Official docs: Memory](https://docs.claude.com/en/docs/claude-code/memory)
