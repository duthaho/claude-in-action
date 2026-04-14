# Lab 02 — Commit Command

> Section: 01-slash-commands · Difficulty: beginner · Est: 25 min

## Goal

You author a `/commit` slash command that reads the currently staged changes in a git repo, writes a conventional commit message that reflects them, and runs `git commit`. This is a command you will actually use on real projects. By the end you understand how a command body can invoke shell tools via Claude, how to keep the instruction tight enough that Claude does not over-explain, and why a good commit command hands control back to you before the final commit lands.

## Prerequisites

- Claude Code installed and logged in
- `git` on your PATH
- Completed: [lab-01-hello-command](../lab-01-hello-command/)

## What you'll build

- A local git repo inside `starter/` with a couple of dirty tracked files
- A file `.claude/commands/commit.md` at the root of `starter/` that, when invoked, stages-aware-commits the dirty files
- When you run `/commit` inside the starter, a commit appears in the log with a message derived from the diff

## Steps

1. Change into the lab directory and run the bootstrap script that turns `starter/` into a git repo with some staged-but-uncommitted changes:
   ```bash
   cd 01-slash-commands/lab-02-commit-command
   bash starter/bootstrap.sh
   ```
   This initializes a repo inside `starter/` and makes two small edits that are staged but not committed.
2. Confirm the repo is in the expected state:
   ```bash
   cd starter
   git status
   git diff --cached
   ```
   You should see two staged changes: a modified function in `math.py` and a new `CHANGELOG.md`.
3. Still inside `starter/`, create the project commands directory:
   ```bash
   mkdir -p .claude/commands
   ```
4. Author `.claude/commands/commit.md`. Its body should instruct Claude to:
   - Read the staged diff (`git diff --cached`).
   - Write a conventional commit message (type: feat/fix/chore, short subject, optional body).
   - Show the message to the user and wait for confirmation before running `git commit`.
   Use the `description:` frontmatter field so the command shows up in `/help`.
5. Launch Claude Code from inside `starter/` and run `/commit`. Approve the message Claude proposes.
6. Run `git log --oneline -1` and confirm the new commit exists with a reasonable message.

## Verify

```bash
bash ../../scripts/verify-lab.sh 01-slash-commands/lab-02-commit-command
```

The script checks that:

- `starter/.claude/commands/commit.md` exists.
- The body mentions `git diff --cached` and `git commit`.
- The body instructs Claude to wait for user confirmation before committing.

## Solution

See `solution/` for the finished command file. `solution/README.md` explains why we ask Claude to wait for confirmation instead of running `git commit` straight through.

## Going further

- Extend the command to refuse to commit if there are *unstaged* changes the user might have forgotten.
- Add an `argument-hint: [scope]` field and let the caller override the detected scope: `/commit api`.
- Make the command fall back to `--amend` when invoked immediately after another `/commit`.

## References

- [Official docs: Slash commands](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
