# Lab 02 — Log Every `Edit` and `Write` Call

> Section: 08-hooks · Difficulty: beginner · Est: 20 min

## Goal

You build a **PostToolUse hook** that runs after every successful `Edit` or `Write` call and appends a one-line record to `.claude/logs/edits.log`. The hook doesn't block anything — its job is observation, not enforcement. By the end you know the difference between `PreToolUse` (can block) and `PostToolUse` (too late to block, but sees the result), how to match multiple tools in one entry with the `|` syntax, and how to write to a file reliably from inside a hook that has no guarantees about working directory.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-pre-commit-hook](../lab-01-pre-commit-hook/) — same file mechanics, different event
- Tools: `python --version` ≥ 3.9

## What you'll build

- `starter/.claude/settings.json` wiring a `PostToolUse` hook with `matcher: "Edit|Write"`
- `starter/.claude/hooks/log-edits.sh` — reads the tool name and file path from the hook envelope, appends a line to `.claude/logs/edits.log`
- A `.gitignore` in `starter/.claude/logs/` so the log file doesn't get committed (observability is private; the log shape is public, the contents aren't)

## Steps

1. Change into the starter:
   ```bash
   cd 08-hooks/lab-02-post-tool-logger/starter
   ls -la
   ```
   The starter has a blank `src/` directory. During the lab you'll ask Claude to create and edit files there, then inspect the log to see each operation recorded.
2. Create `.claude/settings.json` with a `PostToolUse` entry. The matcher should use the `|` syntax to cover both `Edit` and `Write` in one entry:
   ```json
   {
     "hooks": {
       "PostToolUse": [
         {
           "matcher": "Edit|Write",
           "hooks": [
             {
               "type": "command",
               "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/log-edits.sh"
             }
           ]
         }
       ]
     }
   }
   ```
3. Create `.claude/hooks/log-edits.sh`. The script:
   - Reads the JSON envelope from stdin.
   - Extracts `hook_event_name`, `tool_input.file_path`, and (for Edit) the field indicating what changed. Use Python for cross-platform JSON parsing.
   - Appends one line to `"$CLAUDE_PROJECT_DIR"/.claude/logs/edits.log`. Format: `ISO-8601 timestamp · tool · path`.
   - Creates the `logs/` directory if it doesn't exist. A hook that fails because of a missing directory is a brittle hook.
   - **Exits 0 no matter what.** This is `PostToolUse`; you cannot block the action that already happened, and a non-zero exit in this event noisily surfaces errors to the user. If logging fails, swallow the error.
4. Add a `.gitignore` under `.claude/logs/`:
   ```
   # .gitignore
   *.log
   ```
5. Exercise the hook. Ask Claude Code inside `starter/`:
   *"create src/hello.py that prints 'hello world', then edit it to print 'hello claude'"*
   After Claude finishes, `cat .claude/logs/edits.log` — you should see two lines, one per operation.

## Verify

```bash
bash ../../scripts/verify-lab.sh 08-hooks/lab-02-post-tool-logger
```

The script checks that:

- `starter/.claude/settings.json` exists and has a `PostToolUse` entry with `matcher` matching both `Edit` and `Write` (via `"Edit|Write"` or a regex).
- The inner hook is `type: "command"` and references `log-edits.sh`.
- `starter/.claude/hooks/log-edits.sh` exists, reads stdin, references `edits.log`, and includes a `mkdir -p` (or equivalent) so the log directory is auto-created.
- The script does **not** call `exit 2` or emit `permissionDecision: "deny"` — PostToolUse hooks that try to block are a bug.
- `starter/.claude/logs/.gitignore` exists so the log file is excluded from version control.

## Solution

See `solution/`. `solution/README.md` covers: why `PostToolUse` is a strictly weaker event than `PreToolUse`, what `PostToolUseFailure` is for, and the difference between logging-as-debugging and logging-as-audit.

## Going further

- Extend the log line to include the first 80 characters of the diff summary. How do you grab that from the hook's JSON envelope?
- Add a `PostToolUseFailure` hook that logs *failed* edits to a separate `.claude/logs/edit-failures.log`. Which problems does that surface that the success log doesn't?
- Add log rotation: truncate when the file exceeds 10 MB. Where does that logic belong — in the hook, or in a scheduled job?
- Change the matcher to `mcp__.*` (regex). Now you're logging every MCP tool call instead. When is that useful?

## References

- [Official docs: Hooks](https://docs.claude.com/en/docs/claude-code/hooks) — see `PostToolUse` and the matcher syntax table
- [Official docs: Settings](https://docs.claude.com/en/docs/claude-code/settings)
