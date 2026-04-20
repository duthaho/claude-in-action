# Solution — lab-01-pre-commit-hook

The finished state is three files:

- `.claude/settings.json` — wires the hook with the `PreToolUse` event, `Bash` matcher, and `if: "Bash(git commit *)"` narrowing.
- `.claude/hooks/block-todo-commit.sh` — the shell script that runs, checks staged diff for TODO, and emits the deny JSON.
- `src/app.py` — the starter's TODO-bearing file, left unchanged (the learner resolves it to see the allow path).

## Why `matcher: "Bash"` and `if: "Bash(git commit *)"`

The schema has three layers of filtering: the event name (`PreToolUse`), the matcher (`"Bash"`), and the optional `if` rule (`"Bash(git commit *)"`). Each layer narrows when your hook runs.

You *could* write the hook to check the incoming JSON for `git commit` and short-circuit when it sees anything else. That would work, but the hook still has to start a shell, parse JSON, and exit — per Bash call. With `if` narrowing, the hook doesn't start unless the command already matches `git commit *`. For a `ls` or `python` call, the hook is a no-op at the harness level; no process starts.

The payoff is real: the hook fires in milliseconds only when relevant, not on every Bash call. The cost is trivial — one extra line in settings.json.

## Why JSON on stdout, not just `exit 2`

The hook could do its job by printing the reason to stderr and exiting with code 2. Claude Code would see exit 2, treat it as "blocking error", and feed stderr back as the block reason. That works.

The JSON-on-stdout form (`permissionDecision: "deny"`) is better for three reasons:

1. **Explicit semantics**: you're telling Claude "this is a permission decision, not an error". Exit 2 is ambiguous — was the hook itself broken, or is it blocking the action? JSON removes the ambiguity.
2. **Structured reason**: `permissionDecisionReason` is a documented field. Claude formats it consistently; stderr is free-text.
3. **Future-proof**: the same JSON shape supports `"allow"` and `"ask"`. If you later want the hook to *auto-approve* certain commands, you're already using the right mechanism.

For a hook that only blocks (never allows), either form works. Prefer JSON anyway.

## Why Python for stdin parsing, not `jq`

The official docs use `jq`. That's great on macOS and Linux, but not on Windows without extra installs. Using `python` to parse stdin JSON keeps the lab portable across every platform where Claude Code runs.

The hook's Python block is five lines and does one thing: emit the deny JSON. It isn't a dependency you need to install — it's already there because you have Python to run the rest of the repo's labs.

## When a hook beats a CLAUDE.md rule

The naive alternative to this hook is a CLAUDE.md line that says "never commit code containing TODO markers". That works — until it doesn't:

- **Model drift**: the model might follow the rule 99 times in a row and then forget it on turn 100. Hooks don't forget.
- **Policy vs suggestion**: a CLAUDE.md line is a suggestion weighed against everything else in the session. A hook is a hard gate at the harness level. If your team genuinely doesn't want TODO-laden commits, the hook is the right abstraction.
- **Audit**: when something goes wrong, "the hook denied it" is easy to trace. "The model ignored my CLAUDE.md rule" is not.

That said, hooks are not always the right tool. Use CLAUDE.md when the rule is a preference or a default. Use a hook when it's policy.

## Why `"$CLAUDE_PROJECT_DIR"` in the command

The hook's command field is:

```json
"command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-todo-commit.sh"
```

`CLAUDE_PROJECT_DIR` resolves to the project root regardless of where Claude Code is launched. Without it, a relative path like `./.claude/hooks/...` would break as soon as Claude changes working directory during the session. The env var is the only reliable anchor.

## What the hook does **not** do

- It doesn't `git commit` anything. It only allows or denies the call Claude is about to make.
- It doesn't check unstaged files. Only `git diff --cached` — what's actually about to be committed.
- It doesn't warn for `TODO` in comments-only changes vs code changes. Every match blocks. If that's too aggressive for your workflow, narrow the grep.
- It doesn't block `git commit --amend`. The `if` pattern matches `git commit *`, so amend is also covered; but if you wanted to exempt amends, you'd add another check inside the script.

## Key decisions

- **Project scope, not user scope.** Hook lives in the repo's `.claude/hooks/` and ships with the codebase. A generic "no TODO in commits" hook could live in `~/.claude/hooks/` — this one is deliberately project-local because the lab is about wiring, not policy.
- **Single grep check.** The hook is deliberately tiny. Real-world hooks can be more elaborate (allow `// TODO(username, date):` but block bare `TODO`), but complex logic belongs in a helper script, not inline in the hook entry point.
- **No `once: true`.** The hook runs every time. `once: true` is for hooks that should fire once per session (e.g. environment setup); a commit gate is the opposite.

## If you got stuck

- **"The hook didn't fire."** Restart Claude Code. Hooks are loaded at session start; edits to settings.json only apply on the next session. Also check your JSON for trailing commas — most JSON parsers reject them.
- **"The hook fired but Claude went ahead with the commit anyway."** Your script probably exited non-zero without the JSON payload. Check it outputs JSON to stdout when blocking, and exits 0.
- **"The block reason didn't show up."** Your JSON key is `permissionDecisionReason`, not `reason`. The outer `hookSpecificOutput.hookEventName` must exactly match `PreToolUse` (case-sensitive).
- **"The hook fires on every Bash call, not just commits."** You forgot the `if` filter, or the filter pattern doesn't match. Use `"if": "Bash(git commit *)"` — the wildcard `*` after `commit` covers `-m`, `--amend`, etc.
