# Lab 01 — Block `git commit` When Code Has `TODO` Markers

> Section: 08-hooks · Difficulty: beginner · Est: 25 min

## Goal

You write a **PreToolUse hook** that runs whenever Claude is about to call `Bash` with a `git commit` command. The hook scans the staged diff for `TODO` markers and, if it finds any, emits a JSON block telling Claude to deny the tool call with a human-readable reason. By the end you understand the exact schema of a `settings.json` hook entry, how hooks receive input (JSON on stdin) and deliver decisions (JSON on stdout, exit code 2 as a fallback), and the difference between a hook you write once and a rule you repeat in CLAUDE.md every time.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-settings-tour](../../03-configuration-and-permissions/lab-01-settings-tour/) — you already know `.claude/settings.json` exists and can edit it
- Tools: `python --version` ≥ 3.9 (the hook script uses `python` to parse stdin JSON cross-platform)

## What you'll build

- `starter/.claude/settings.json` wiring a `PreToolUse` hook with `matcher: "Bash"` and `if: "Bash(git commit *)"`
- `starter/.claude/hooks/block-todo-commit.sh` — the hook script itself, short (~30 lines) and stdlib-only
- A tiny git scenario in `starter/` so you can exercise the hook: a `src/app.py` with a `# TODO: fix me later` comment and a clean `README.md` the hook will not block

## Steps

1. Change into the starter:
   ```bash
   cd 08-hooks/lab-01-pre-commit-hook/starter
   ls -la
   cat src/app.py
   ```
   Two files. One has a `TODO` marker. The other is clean.
2. Create `.claude/settings.json`. Wire a `PreToolUse` hook that matches on the `Bash` tool and narrows further with `if` so the hook only runs for `git commit` invocations:
   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "Bash",
           "hooks": [
             {
               "type": "command",
               "if": "Bash(git commit *)",
               "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-todo-commit.sh"
             }
           ]
         }
       ]
     }
   }
   ```
   The `if` filter matters. Without it the hook would fire for every `Bash` call including `ls`, which is slow and noisy.
3. Create `.claude/hooks/block-todo-commit.sh`. The hook:
   - Reads JSON from stdin. The field you care about is `tool_input.command`.
   - Uses `git diff --cached` to get the staged diff. If the diff contains `TODO`, the hook emits a JSON `permissionDecision: "deny"` block and exits 0.
   - If no `TODO` is found, exits 0 with no output — Claude Code interprets that as "continue".
   - Uses Python (not `jq`) to parse JSON so the lab runs on Windows/macOS/Linux without extra installs.
4. Make the script executable (`chmod +x .claude/hooks/block-todo-commit.sh` — on Windows bash this is a no-op but doesn't hurt).
5. Exercise the hook:
   ```bash
   git init -q
   git add .
   ```
   Ask Claude Code inside this directory: *"commit everything with message 'initial'"*. You should see the commit blocked with the reason from your hook.
6. Fix the `TODO` in `src/app.py` (delete the line or complete it), re-stage, and retry. The commit should now succeed.

## Verify

```bash
bash ../../scripts/verify-lab.sh 08-hooks/lab-01-pre-commit-hook
```

The script checks that:

- `starter/.claude/settings.json` exists and parses as JSON.
- It has a `hooks.PreToolUse` array with at least one entry whose `matcher` is `"Bash"`.
- At least one inner hook has `type: "command"` and its `command` field references `block-todo-commit.sh`.
- The inner hook has `if:` narrowing to `git commit` (so the hook doesn't fire on every Bash call).
- `starter/.claude/hooks/block-todo-commit.sh` exists.
- The script reads from stdin (`sys.stdin` or `< /dev/stdin`), checks staged files for `TODO`, and emits the `permissionDecision: "deny"` JSON when it finds one.

## Solution

See `solution/`. `solution/README.md` covers: why the `if:` filter matters, the difference between "hook exits 2" and "hook prints JSON with permissionDecision: deny", and when a hook is the right tool vs when a CLAUDE.md rule is enough.

## Going further

- Add a second hook on `PostToolUse` that logs every successful commit to `.claude/commits.log`. That's lab 02, but try it yourself first.
- Extend the hook to block commits with `XXX`, `FIXME`, or `HACK` markers too. Keep the exit shape clean.
- Replace the Python JSON parse with a pure-bash implementation. How fragile does that get?
- Move the hook to `~/.claude/settings.json` (user scope). It now fires in every repo on your machine. Is that the right default?

## References

- [Official docs: Hooks](https://docs.claude.com/en/docs/claude-code/hooks) — see the `PreToolUse` section for the JSON output schema
- [Official docs: Settings](https://docs.claude.com/en/docs/claude-code/settings)
