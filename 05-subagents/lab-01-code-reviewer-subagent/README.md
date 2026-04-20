# Lab 01 — Code Reviewer Subagent

> Section: 05-subagents · Difficulty: beginner · Est: 25 min

## Goal

You author your first subagent: a `code-reviewer` that reads code, finds quality and security issues, and returns a written report. You do it the minimum way — one Markdown file at `.claude/agents/code-reviewer.md` with YAML frontmatter and a system prompt. By the end you understand why subagents exist (context isolation), how tool restrictions harden them, and why the `description` field decides whether Claude reaches for your subagent at the right moment.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-first-skill](../../04-skills/lab-01-first-skill/) (the skill/subagent file formats look similar; knowing skills first helps)

## What you'll build

- A project-scoped subagent file at `starter/.claude/agents/code-reviewer.md`
- The frontmatter pins `name`, `description`, `tools` (read-only: `Read, Grep, Glob`), and `model: sonnet`
- The body (the subagent's system prompt) tells Claude to review in a fixed report shape: summary, issues grouped by severity, suggested fix per issue
- A realistic starter file `starter/src/auth.py` with three seeded issues for the reviewer to find when you dispatch it

## Steps

1. Change into the starter and look at what the reviewer will be pointed at:
   ```bash
   cd 05-subagents/lab-01-code-reviewer-subagent/starter
   ls -la src/
   cat src/auth.py
   ```
   The file has three deliberate problems: a hard-coded secret, a SQL-injection-shaped string concatenation, and a bare `except:` swallowing errors. Your subagent should catch all three.
2. Create the agent directory:
   ```bash
   mkdir -p .claude/agents
   ```
3. Author `.claude/agents/code-reviewer.md`. The file starts with YAML frontmatter delimited by `---` lines. Required fields:
   - `name: code-reviewer`
   - `description:` one or two sentences telling Claude *when* to delegate. Include trigger words: "review", "code quality", "security". The description is what Claude matches against when deciding whether to dispatch the subagent — write it for the model, not for humans.
   - `tools: Read, Grep, Glob` — an allowlist. The reviewer never needs to edit; restricting tools makes the subagent's job impossible to botch.
   - `model: sonnet` — reviewers don't need the biggest model. Sonnet is fast and accurate enough.
4. The body (after the second `---`) is the subagent's system prompt. Write instructions that tell Claude to:
   - Read every file under the directory it was pointed at.
   - Look for: hard-coded secrets, injection risks, error swallowing, missing input validation, dead code.
   - Output a report with three sections: `## Summary`, `## Issues` (grouped by severity: Critical / Warning / Note), and `## Suggested Fixes`.
   - Reference file paths with `path:line` so the parent session can jump straight to each issue.
5. Launch Claude Code from inside `starter/` and prompt: *"review the code under src/"*. Claude should recognize the subagent from its description, dispatch to it, and return a report. You stay in your main conversation — the subagent's Read calls and grep output never flood your context.
6. Ask Claude a different question like *"what's in this README?"* — confirm Claude does **not** unnecessarily dispatch the code-reviewer. Descriptions should be tight enough that they only match review requests.

## Verify

```bash
bash ../../scripts/verify-lab.sh 05-subagents/lab-01-code-reviewer-subagent
```

The script checks that:

- `starter/.claude/agents/code-reviewer.md` exists.
- Frontmatter has `name: code-reviewer` and a non-empty `description`.
- The description mentions "review" or "code quality".
- The `tools` field is an allowlist containing `Read`, `Grep`, `Glob` — and **does not** contain `Write` or `Edit`.
- The body references "severity" or one of the level words (`Critical`, `Warning`), so the output shape is actually specified.

## Solution

See `solution/` for one acceptable code-reviewer subagent. `solution/README.md` explains why tool restrictions are load-bearing for reviewer-style subagents and how to write a description that matches review asks without swallowing every code question.

## Going further

- Drop `model: sonnet` and re-run. The subagent now inherits the main conversation's model. Which do you prefer for this job?
- Add `disallowedTools: Bash` and see how the subagent copes when a file requires running tests to evaluate.
- Move the subagent to `~/.claude/agents/code-reviewer.md`. It should now be available in every repo without committing anything.
- Add a second subagent `security-auditor` with a narrower description. Which one does Claude pick when you say "audit this file"?

## References

- [Official docs: Subagents](https://docs.claude.com/en/docs/claude-code/sub-agents)
