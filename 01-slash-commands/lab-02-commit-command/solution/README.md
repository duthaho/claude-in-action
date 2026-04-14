# Solution — lab-02-commit-command

The finished command is `starter/.claude/commands/commit.md`. Its body walks Claude through six steps: read the staged diff, pick a conventional-commit type, compose a message, show it to the user, wait for approval, commit.

## Why this works

Slash commands are natural-language instructions, not shell scripts. The body of `commit.md` tells Claude *what to do* in plain English — Claude then uses its own `Bash` tool to actually run `git diff --cached`, its own reasoning to compose a message, and its own `Bash` tool again to commit. You never write `#!/bin/bash`; you write the checklist you would hand a human teammate.

## Why we wait for user confirmation

This is the single most important decision in the lab. The tempting version of `/commit` is: "read the diff, commit with a generated message." That version is wrong for three reasons:

1. **Commit messages are hard to fix.** Amending a pushed commit requires a force push. Fixing a wrong auto-generated message is worse than writing it yourself.
2. **Claude's read of the diff is usually *good enough* but occasionally wrong.** Wrong on a non-critical file is fine. Wrong on a security patch that claims it's a style change is bad. A confirmation step catches the bad case.
3. **You learn more when you see Claude's proposed message.** Reviewing it for 5 seconds is still faster than writing it, and you stay in the loop.

The rule generalizes: slash commands that touch shared state (git history, remote APIs, production) should *propose* an action and wait for approval. Slash commands that touch only local scratch state can just do the thing.

## Key decisions

- **Conventional commits, not free-form.** Conventional commits are boring on purpose — they normalize the output so Claude doesn't improvise too much. If you use Angular-style scopes or semantic-release, adjust the list.
- **Subject under 72 chars.** Git tools truncate longer subjects. This is easier to put in the instruction than to fix after the fact.
- **Heredoc note in step 5.** If you tell Claude to use `git commit -m "<body>"`, the body tends to get mangled by quote escaping. A heredoc is safer.
- **We explicitly forbid running `git commit` before approval.** Without that sentence, Claude sometimes commits first and shows the message after. The word "not" matters.

## If you got stuck

- **"Claude committed immediately without showing me the message."** Your body skipped the "wait for approval" step or didn't say "do not". Natural-language instructions need the negative explicitly.
- **"The commit message was weird."** Check that the body tells Claude to read `git diff --cached`, not `git diff` (which shows unstaged changes).
- **"The command didn't appear in `/help`."** Missing `description:` frontmatter or wrong location. Project commands must live in `.claude/commands/` at the repo root.
