# Section 08 — Hooks

A **hook** is a shell command (or HTTP endpoint, prompt, or agent) Claude Code runs automatically at specific points in its lifecycle: before a tool call, after a tool call, when the session starts, and so on. Hooks let you enforce policy (block destructive commits), observe behaviour (log every edit), and harden safety (deny writes under `prod/`) without relying on the model to remember rules in a system prompt.

Hooks live in `settings.json` under the `hooks` key, nested as `hooks.{EventName}[].matcher` + `hooks[]`. The handler reads JSON on stdin and signals decisions via exit code or JSON on stdout. Policy in a hook is *structural* — a CLAUDE.md rule is a suggestion the model weighs; a hook is a gate at the harness level.

The labs in this section walk you through a `PreToolUse` gate that blocks commits with `TODO` markers, a `PostToolUse` observer that logs every `Edit` and `Write` call, and a safety hook that denies writes under a protected directory (with an offline test fixture). By the end you can wire hooks confidently, test them without running Claude Code, and know when a hook is the right abstraction vs when a CLAUDE.md rule or a `permissions.deny` rule is enough.

## Learning objectives

After finishing these labs, you can:

- Wire a `PreToolUse` hook in `settings.json` with correct matcher and `if:` filter
- Read JSON from stdin in a hook and emit `permissionDecision: "deny"` JSON to block
- Write a `PostToolUse` hook for observation that never accidentally blocks the session
- Normalise paths safely so `prod/../dev/` doesn't fool a path-based rule
- Ship an offline test fixture alongside a hook so the safety guarantee doesn't rot
- Choose between a hook, a CLAUDE.md rule, and `permissions.deny`

## Labs

| # | Lab | Difficulty | Est. |
|---|---|---|---|
| 01 | [lab-01-pre-commit-hook](lab-01-pre-commit-hook/) | beginner | 25 min |
| 02 | [lab-02-post-tool-logger](lab-02-post-tool-logger/) | beginner | 20 min |
| 03 | [lab-03-safety-hook](lab-03-safety-hook/) | intermediate | 30 min |

## References

- [Official docs: Hooks](https://docs.claude.com/en/docs/claude-code/hooks)
- [Official docs: Settings](https://docs.claude.com/en/docs/claude-code/settings)
