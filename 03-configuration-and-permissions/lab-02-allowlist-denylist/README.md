# Lab 02 — Allowlist & Denylist

> Section: 03-configuration-and-permissions · Difficulty: beginner · Est: 25 min

## Goal

You lock down a repo so Claude Code can read, grep, and glob freely but cannot write, run arbitrary bash commands, or touch the `secrets/` directory under any circumstances. This is the settings-based equivalent of handing a read-only copy of your repo to a contractor. By the end you can explain the difference between an allowlist (what Claude *may* use) and a denylist (what Claude *must not* touch), and you know which one wins in a conflict.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-settings-tour](../lab-01-settings-tour/)

## What you'll build

- A `starter/.claude/settings.json` that:
  - Allows only `Read`, `Grep`, `Glob`, and `LS` tools (an **allowlist**).
  - Denies any `Read` or `Edit` whose path touches `secrets/**` (a **denylist** layered on top).
- A `secrets/api_key.txt` file with a fake secret that Claude must not be able to read.
- Verification proves the settings file reflects the intent — we don't actually run Claude in verify, we check that the rules are present and shaped correctly.

## Steps

1. Change into the lab:
   ```bash
   cd 03-configuration-and-permissions/lab-02-allowlist-denylist/starter
   ls -la secrets/
   ```
   Note `secrets/api_key.txt` is already there.
2. Create `.claude/settings.json`. It needs two things:
   - A `permissions.allow` array naming only the four read-only tools: `"Read"`, `"Grep"`, `"Glob"`, `"LS"`.
   - A `permissions.deny` array with patterns that block `secrets/**`: `"Read(./secrets/**)"` and `"Edit(./secrets/**)"`.
3. Launch Claude Code from inside `starter/` and ask it to *"summarize every file in this repo"*. It should read the normal files and either skip `secrets/` or refuse to read it, depending on whether it asked permission first.
4. Ask Claude to *"create a file called notes.txt"*. It should refuse — `Write` is not on the allow list.
5. Ask Claude to *"run `ls`"*. It should refuse — `Bash` is not on the allow list either.
6. Ask Claude to *"read secrets/api_key.txt"*. Even though `Read` is allowed, the `deny` rule wins for this specific path — Claude should refuse and explain why.

## Verify

```bash
bash ../../scripts/verify-lab.sh 03-configuration-and-permissions/lab-02-allowlist-denylist
```

The script checks that:

- `starter/secrets/api_key.txt` exists (the target of the deny rule).
- `starter/.claude/settings.json` is valid JSON.
- `permissions.allow` contains exactly the read-only tool set (no `Write`, `Edit`, `Bash`).
- `permissions.deny` contains at least one rule matching `secrets/`.

## Solution

See `solution/` for one acceptable settings file. `solution/README.md` explains why deny rules override allow rules even when the allow rule appears "more specific", and how to test your rules without having to boot Claude every time.

## Going further

- Add `Bash(git status:*)` to the allow list so Claude can check git status but not run other git commands. Test with `/permissions`.
- Replace the deny glob `./secrets/**` with a regex-style path and see which form Claude accepts. Which is easier to read?
- Remove the deny rule entirely and use only a narrow allow list. What breaks?

## References

- [Official docs: Permissions](https://docs.claude.com/en/docs/claude-code/iam)
- [Official docs: Settings](https://docs.claude.com/en/docs/claude-code/settings)
