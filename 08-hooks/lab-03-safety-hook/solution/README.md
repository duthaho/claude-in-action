# Solution — lab-03-safety-hook

The finished state is five files under `starter/`:

- `.claude/settings.json` — wires the `PreToolUse` hook with `matcher: "Edit|Write"`.
- `.claude/hooks/block-prod-writes.sh` — the safety hook itself.
- `.claude/hooks/test_block_prod_writes.sh` — offline test fixture, runs three canned cases.
- `prod/config.yaml` — the file the hook must defend.
- `dev/config.yaml` — a sibling file the hook must allow.

## Hook vs `permissions.deny` — when each one wins

Section 03 showed you that `settings.json` has a `permissions.deny` array where you can write rules like:

```json
"permissions": {
  "deny": ["Edit(prod/**)", "Write(prod/**)"]
}
```

That's simpler, shorter, and declarative. When should you prefer it over the hook in this lab?

| Capability | `permissions.deny` | Hook |
|---|---|---|
| Block by path glob | Yes | Yes |
| Log every denial to a file | No | Yes |
| Give a custom, contextual reason | No (generic message) | Yes |
| Depend on the environment (time of day, sentinel files) | No | Yes |
| Depend on the *content* of the edit | No | Yes (inspect `tool_input`) |
| Block when the target resolves under a protected path via `..` | Depends on the glob engine | Yes (use `os.path.realpath`) |
| Share across projects | Via `~/.claude/settings.json` | Same, plus share the script via a plugin |

**Rule of thumb**: reach for `permissions.deny` first. It's declarative and can't misbehave. Use a hook when you need something `permissions.deny` can't do — a custom reason, contextual logic, or content inspection.

For the specific case in this lab, *either* would work. The reason we ship the hook version is that the hook teaches you the mechanism; once you know the mechanism, you know when to reach for the declarative form.

## Path normalisation — the `prod/../dev/` case

The hook matches on the *resolved* path, not the raw input string. That matters because:

```
prod/../dev/x.yaml   → resolves to dev/x.yaml → should be allowed
./prod/config.yaml   → resolves to prod/config.yaml → should be blocked
/absolute/.../prod/f → starts with the project-absolute prod/ → should be blocked
```

Without `os.path.realpath`, a naive `startswith("prod/")` check would block `prod/../dev/` (wrong — that's `dev/`, not `prod/`) and miss some absolute forms. `realpath` collapses `..`, resolves symlinks, and gives you a canonical path to compare.

The offline test fixture's third case exists specifically to catch this. When someone later rewrites the hook "for clarity" and drops the realpath call, the test fails — and the safety guarantee is preserved.

## Why the test fixture ships alongside the hook

Hooks are code. Code rots. A hook that was correct six months ago can be broken today because someone edited it without re-reading the whole script. The test fixture is cheap insurance:

- It runs in under a second (three Python invocations).
- It needs no Claude Code — it's pure shell + Python.
- It documents the intended behaviour: the three cases encode what "safety" means here.
- CI can run it.

A hook without a test is a landmine. A hook with a three-case test is a maintained gate.

## Why `PreToolUse` and not `permissions.deny` for this lab's teaching goal

The schema the hook emits — `hookSpecificOutput.permissionDecision: "deny"` with `permissionDecisionReason` — is the same schema `permissions.deny` ultimately flows through. Writing the hook directly makes you see the schema. You'd miss that if you just used the declarative form.

In production, prefer the declarative form. In learning, do the long-form once.

## Defence in depth: combine them

You can layer:

```json
{
  "permissions": {
    "deny": ["Edit(prod/**)", "Write(prod/**)"]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "bash .claude/hooks/block-prod-writes.sh" }]
      }
    ]
  }
}
```

Now `permissions.deny` handles the common case with a generic message, and the hook catches the edge cases (resolved-path sneaks, content-based checks). If either fails, the other still fires. Belt and braces.

## Key decisions

- **Project scope, not user scope.** The hook defends this repo's `prod/`; different repos have different protected paths. User scope is tempting for "no prod writes ever" rules, but "prod" means different things in different projects.
- **Custom reason text.** The `permissionDecisionReason` includes the offending path and a suggested alternative ("edit dev/ instead"). Good error messages save a debugging session.
- **Silent allow, verbose deny.** The hook exits 0 with no output when the path is fine. Noise in the allow path would pollute logs for no gain.
- **Python for the path logic.** Bash path normalisation is a minefield across shells (`realpath` isn't on macOS by default, `dirname`/`basename` behave oddly with empty strings). Python's `os.path` is portable and boring.

## If you got stuck

- **"The hook doesn't fire on `Edit`."** Matcher is probably wrong. `"Edit|Write"` not `"Edit, Write"` or `["Edit", "Write"]`.
- **"The hook fires but the block reason doesn't show."** Your JSON is probably `"decision": "block"` instead of `"hookSpecificOutput": { "permissionDecision": "deny" }`. The former is the generic schema for other events; PreToolUse needs the `hookSpecificOutput` wrapper.
- **"The test fixture fails on case 3."** Your hook isn't normalising the path. Add `os.path.realpath` — or the Python equivalent check — so `prod/../dev/x.yaml` is treated as `dev/x.yaml`.
- **"The hook blocks my legitimate emergency prod edit."** That's the point. If it's *really* an emergency, comment out the hook for the duration of the edit. A safety rule that lets itself be overridden by prompt language isn't a safety rule.
