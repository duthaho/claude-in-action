# Style Guide

How to write labs so they all sound like one repo.

## Voice

- **Second person, present tense, active.** "You create a command that stages your changes." Not "A command will be created" or "We're going to make a command".
- **Direct.** No throat-clearing, no "in this lab we'll explore". The first sentence of the Goal is the concrete thing the learner produces.
- **Beginner-friendly, not condescending.** Assume the reader installed Claude Code yesterday but is a competent programmer. Explain Claude Code concepts. Do not explain what a terminal is.
- **Plain English.** Avoid "simply", "just", "obviously". If something is obvious, the word doesn't help. If it isn't, the word is a lie.

## Headings

Lab README files use exactly these headings, in this order:

```markdown
# Lab NN — <Title>

> Section: <slug> · Difficulty: beginner|intermediate · Est: <N> min

## Goal
## Prerequisites
## What you'll build
## Steps
## Verify
## Solution
## Going further
## References
```

Section README files use:

```markdown
# Section NN — <Title>

<one-paragraph overview>

## Learning objectives
## Labs
## References
```

## The Goal section

One paragraph. Starts with the concrete artifact. Example:

> You build a `/commit` slash command that inspects your staged changes, writes a conventional commit message from them, and runs `git commit`. By the end you'll understand how a command turns a natural-language instruction into a repeatable action.

Not:

> ~~In this lab, we'll explore how slash commands work by creating a command that helps you commit your changes.~~

## The Steps section

- Numbered list.
- Each step is one action. If a step has a sub-action, make it a sub-bullet.
- 3–10 steps. More than 10 means the lab is too big.
- Do not include verification inside `## Steps`. Verification lives in `## Verify`.
- Do not include the full solution. A step can show *a* command but should not dump the whole finished file.

## The Verify section

- Prefer: `bash verify.sh` from the lab directory.
- If manual, use a checklist:
  ```markdown
  - [ ] Running `claude /mycommand` responds with "hello from <repo>"
  - [ ] The command file lives at `.claude/commands/mycommand.md`
  ```

## The Solution section

One paragraph, then a link to `solution/`. Example:

> See `solution/` for the finished state. Try the steps before you peek — the learning happens when your first attempt doesn't work.

Do not paste the solution code into the README.

## Cross-references

- Link to specific pages in the official Claude Code docs, not just the docs root:
  - Good: `[Slash commands](https://docs.claude.com/en/docs/claude-code/slash-commands)`
  - Weak: `[Claude Code docs](https://docs.claude.com/en/docs/claude-code)`
- Do not link to external repos, personal blogs, or tutorial sites. The official docs are the only durable reference.

## Code blocks

- Language-tag every fenced block (` ```bash `, ` ```json `, ` ```markdown `).
- Prefer short blocks. If you need 30 lines, that content probably belongs in `starter/` or `solution/` instead of the README.
- Paths inside prose use backticks: `.claude/commands/commit.md`.

## Difficulty labels

- **beginner**: someone who just installed Claude Code can finish it. Touches one feature.
- **intermediate**: requires comfort with the basics and combines 2+ features (e.g. a hook that triggers a subagent).

No "advanced" tier in v1. If a lab would be advanced, split it.

## Time estimates

- Honest. If you timed yourself and it took 35 minutes with a few hiccups, write 35, not 20.
- Round to the nearest 5 minutes.
- Ranges are fine in prose ("15–25 min") but `.lab-meta.yml` uses a single integer `est_minutes`.
