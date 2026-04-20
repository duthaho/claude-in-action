# Solution — lab-02-post-tool-logger

The finished state is four files in `starter/`:

- `.claude/settings.json` — one `PostToolUse` hook with `matcher: "Edit|Write"`.
- `.claude/hooks/log-edits.sh` — ~20-line script that reads stdin, extracts tool name and file path, appends a line to the log.
- `.claude/logs/.gitignore` — excludes `*.log` so the log file never gets committed.
- `src/.gitkeep` — placeholder so the empty `src/` directory exists for the learner to edit into.

## `PreToolUse` vs `PostToolUse` — the asymmetry

`PreToolUse` runs *before* the tool call. It can block (exit 2, or JSON `permissionDecision: "deny"`). That's the superpower.

`PostToolUse` runs *after*. The tool already executed — there's nothing to block. What it can do is observe: the tool succeeded, here's the input that went in, here's the output that came out. That's useful for logging, metrics, notifying external systems — anything where you want a record but not a gate.

The asymmetry matters because PostToolUse hooks are usually the safer choice when you're not sure what you want. They can't break anything by accident; the worst case is a missing log line. PreToolUse hooks, by contrast, can make Claude unable to get work done if they misfire.

## Why `matcher: "Edit|Write"` is one entry, not two

The matcher field supports `|`-separated exact names for simple cases and regex for anything more complex. Writing `"Edit|Write"` in one entry is equivalent to two separate entries — but keeping them together means when you later change the hook script path or add a `timeout`, you only change it in one place.

If you'd written:

```json
"PostToolUse": [
  { "matcher": "Edit", "hooks": [...] },
  { "matcher": "Write", "hooks": [...] }
]
```

the two entries are now independent. Adding a `MultiEdit` matcher later means a third entry; adding a `once` flag means remembering to add it three times. Consolidating is the right default.

Regex matchers (`"^Edit"`, `"mcp__.*"`) work too — use them when you need wildcard matching. For named tools, the pipe form is clearer.

## Why the hook exits 0 no matter what

A logger that can fail loudly is worse than no logger. If logging fails (disk full, permission denied, Python missing), the session should continue — the user didn't ask you to block their work because the log is broken.

Exit code 0 with stderr suppressed is the right default for observation-only hooks. The log file not growing is visible to the operator; the session working is visible to the user. Different feedback loops for different audiences.

Compare this to `PreToolUse`: there, the hook failing is a safety issue (a block you meant to enforce didn't fire). Different event, different defaults.

## Why `mkdir -p` inside the hook

The hook could fail if `.claude/logs/` doesn't exist. Creating the directory on every invocation is cheap (no-op when it already exists) and removes a whole class of setup bugs. Same reasoning as `set +e`: the hook should be self-healing.

Alternatively you could commit an empty `.claude/logs/.gitkeep`. Both work. Inline `mkdir -p` means the hook is portable to other projects without carrying a placeholder file.

## The log shape (public) vs the log contents (private)

The log shape — `ISO-8601 | tool | path` — is part of the artifact. Anyone on the team reading `log-edits.sh` knows what each line means. That's why the format is pinned in the script.

The log contents — which files you edited, when — is **private to you**. That's why `.gitignore` excludes `*.log`. If the log gets committed by accident, you've leaked your workflow. Same reason you don't commit shell history.

For audit purposes (e.g. compliance requiring a record of changes), you'd route the log somewhere durable: a syslog-style endpoint, an HTTP POST to a collector, a write to a shared bucket. The settings schema supports HTTP hooks for exactly that — swap `type: "command"` for `type: "http"` and point at your collector.

## When this is the wrong tool

- **For debugging a specific session**: the transcript at `$CLAUDE_TRANSCRIPT` already has everything. A log is redundant.
- **For usage metrics across users**: a hook runs per-session on one machine. You'd need to aggregate log files out-of-band. An HTTP hook pointing at a central collector is a better shape.
- **For enforcing "don't edit this file"**: use `PreToolUse` with `permissionDecision: "deny"` (see lab 03). PostToolUse can't un-do an edit.

## Key decisions

- **`set +e` instead of `set -euo pipefail`**: most of the labs use strict mode. This one deliberately does not — a logger should tolerate partial failures, not abort on them.
- **Python for parsing, not `jq`**: same reason as lab 01. Cross-platform, already installed.
- **`envelope=$(cat < /dev/stdin)` then pipe**: we consume stdin once and reuse. Piping directly to Python inside a heredoc has a subtle bug — the heredoc binds stdin to its own content, which replaces what Claude sent. Easy to miss.
- **`.claude/logs/.gitignore` scoped locally**: a repo-root `.gitignore` works too. Keeping the rule next to the log it covers means future readers see the intent at a glance.

## If you got stuck

- **"The log file is empty but exit code is 0."** The hook probably has the heredoc-stdin bug: if you write `python -c "..." <<'PY'`, Python's stdin is the heredoc, not Claude's JSON. Capture stdin into a variable first, then pipe.
- **"The hook fires on `Read` too."** Your matcher is too loose (`"*"` or omitted). `"Edit|Write"` is the right narrowness.
- **"Nothing logs but I can see Claude editing."** Restart Claude Code after changing settings.json — hooks are loaded at session start.
- **"The log has tool name `unknown`."** Your hook reads `tool_input` but not `tool_name`. Different Claude Code versions have emitted the tool name in slightly different fields; check both `tool_name` and `hook_event_name` as a fallback.
