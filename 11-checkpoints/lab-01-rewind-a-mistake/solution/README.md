# Solution — lab-01-rewind-a-mistake

> Try the steps in the lab's `README.md` first — peek here after.

## What a checkpoint captures

A Claude Code checkpoint captures two things at the point a turn completes:

1. **The conversation trace up to and including that turn** — the user's message, Claude's reasoning, the tool calls, and their results.
2. **Every file Claude wrote during that turn via Edit, Write, or NotebookEdit.** Both the *before* and *after* contents of each touched file are recorded so the rewind is reversible.

That is why `/rewind` returned `src/calculator.py` to the exact text from the "before" block: the checkpoint stored the pre-change file content and restored it.

## What a checkpoint does *not* capture

- **Changes you made outside Claude's tools.** If you edited `calculator.py` in VS Code during the session, that edit is not in the checkpoint — rewinding will happily overwrite it.
- **Git operations.** A commit Claude asked you to make, or one you made yourself, is in git history, not in the checkpoint. Rewinding does not `git reset`.
- **External side effects.** Files created by scripts Claude ran, network calls made by MCP servers, database writes, deployed artifacts — none of those are snapshotted. Checkpoints are session-local, not environment-wide.
- **MCP server state.** Each MCP server keeps its own state; checkpoints don't roll that back.

The mental model: *a checkpoint undoes what Claude did in the tool-use box — nothing more.*

## `Esc Esc` vs `/rewind`

`Esc Esc` is the quick-undo keybinding for the most recent turn. Good for "I didn't like that last response, let me re-phrase". It's fast and doesn't require you to pick from a list.

`/rewind` is the full-menu variant. Use it when you need to go back more than one turn, or when you're not sure exactly which turn introduced the problem and want to see the list before committing.

Either way, the action is destructive to *forward* history — the turns after the chosen checkpoint are gone, same as `git reset`. If you might want either branch, use `lab-02-branching-explorations` technique instead.

## Why the "asked for a broken thing on purpose" exercise

Real rewind moments are rare if you're not looking for them — most mistakes during Claude Code sessions are recoverable by just asking for a different change. The lab manufactures a clear-cut "I don't want this" scenario (silent divide-by-zero) so you feel the rewind without having to wait for an organic mistake.
