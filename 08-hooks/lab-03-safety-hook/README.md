# Lab 03 — Deny Writes Under `prod/`

> Section: 08-hooks · Difficulty: intermediate · Est: 30 min

## Goal

You write a **safety hook** — a `PreToolUse` hook matching `Edit|Write` that inspects the target file path and denies any operation under `prod/`. Unlike lab 01 (which gated a Bash subcommand), this hook gates the file-mutating tools directly. The point is not just the mechanism; it's the *layered defence* story: how a hook compares against the `permissions.deny` setting from section 03, and when you'd reach for each. By the end you can compose hooks with permission rules, test a hook offline using its stdin/stdout contract, and know why a test fixture for a hook is worth shipping.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-02-post-tool-logger](../lab-02-post-tool-logger/) — you know the stdin/stdout contract
- Completed: [lab-02-allowlist-denylist](../../03-configuration-and-permissions/lab-02-allowlist-denylist/) — so the comparison at the end makes sense
- Tools: `python --version` ≥ 3.9

## What you'll build

- `starter/.claude/settings.json` wiring a `PreToolUse` hook with `matcher: "Edit|Write"`
- `starter/.claude/hooks/block-prod-writes.sh` — the hook script; inspects `tool_input.file_path`, denies if the path resolves under `prod/`
- `starter/.claude/hooks/test_block_prod_writes.sh` — an **offline test fixture**: feeds canned envelopes to the hook via stdin and asserts the exit+stdout behaviour. You run this with `bash` — it needs no Claude Code running.
- `starter/prod/config.yaml` and `starter/dev/config.yaml` — a prod file the hook must defend, and a dev file it must allow

## Steps

1. Change into the starter and inspect the layout:
   ```bash
   cd 08-hooks/lab-03-safety-hook/starter
   ls prod/ dev/
   ```
2. Create `.claude/settings.json` with a `PreToolUse` hook matching both `Edit` and `Write`:
   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "Edit|Write",
           "hooks": [
             {
               "type": "command",
               "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-prod-writes.sh"
             }
           ]
         }
       ]
     }
   }
   ```
3. Create `.claude/hooks/block-prod-writes.sh`:
   - Read the JSON envelope from stdin (use Python to parse).
   - Extract `tool_input.file_path`. Normalise it: strip `./`, resolve `..`, compare as an absolute path against the project root's `prod/`.
   - If the target is under `prod/`, emit JSON with `permissionDecision: "deny"` and a clear `permissionDecisionReason`.
   - Otherwise exit 0 silently.
4. Create `.claude/hooks/test_block_prod_writes.sh`. This is the offline test harness:
   - Feeds three canned envelopes to the hook: (a) `prod/config.yaml` — should be denied, (b) `dev/config.yaml` — should be allowed, (c) `prod/../dev/x.yaml` — should be allowed (it resolves to `dev/`).
   - Asserts each case produces the expected output and exit code. Prints `PASS` or `FAIL` per case.
5. Run the test fixture to confirm the hook works:
   ```bash
   bash .claude/hooks/test_block_prod_writes.sh
   ```
   Expected: three `PASS` lines and exit 0.
6. Now exercise the hook live. Launch Claude Code inside `starter/` and ask:
   - *"edit dev/config.yaml and add a comment"* — allowed, the edit should happen
   - *"edit prod/config.yaml and add a comment"* — denied, you should see the block reason surfaced

## Verify

```bash
bash ../../scripts/verify-lab.sh 08-hooks/lab-03-safety-hook
```

The script checks that:

- `starter/.claude/settings.json` has a `PreToolUse` entry matching both `Edit` and `Write`, referencing `block-prod-writes.sh`.
- `block-prod-writes.sh` exists, reads stdin, extracts `file_path`, normalises the path (resolves `..` or uses `realpath`/`os.path.realpath`), and emits the deny JSON when the path lands under `prod/`.
- `test_block_prod_writes.sh` exists and, when executed, prints three `PASS` lines for the three canned cases.
- `starter/prod/config.yaml` and `starter/dev/config.yaml` are still there (the fixtures the live test uses).

## Solution

See `solution/`. `solution/README.md` covers: the comparison between a hook and `permissions.deny`, why path normalisation prevents the `prod/../dev/` sneak, and how to write hook tests that catch regressions when someone edits the hook without thinking.

## Going further

- Lift the protected paths out of the script into a `.claude/hooks/protected-paths.txt` file. How does that change the test fixture?
- Compare your hook with adding `"permissions": { "deny": ["Edit(prod/**)", "Write(prod/**)"] }` to `settings.json`. Try both. Are they equivalent? What does each catch that the other doesn't?
- Extend the hook to allow writes under `prod/` when a magic sentinel file `prod/.unsafe-edit-ok` exists. When is this a footgun?
- Swap the shell hook for a `type: "prompt"` hook that asks Claude to judge "is this edit safe under prod/?". When is that worse than the deterministic shell check?

## References

- [Official docs: Hooks](https://docs.claude.com/en/docs/claude-code/hooks) — `PreToolUse` JSON schema and exit codes
- [Official docs: Permissions](https://docs.claude.com/en/docs/claude-code/settings#permission-settings) — compare with `permissions.deny`
