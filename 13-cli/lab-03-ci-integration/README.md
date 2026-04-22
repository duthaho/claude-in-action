# Lab 03 — CI Integration: Claude Reviews Every PR

> Section: 13-cli · Difficulty: intermediate · Est: 40 min

## Goal

You wire up a GitHub Actions workflow that runs Claude Code on every pull request and posts the review as a PR comment. The starter ships a skeleton `claude-review.yml` with four `TODO` blocks covering the trigger, the Claude install, the `claude -p` invocation (restricted to read-only tools, capped turn count), and the `ANTHROPIC_API_KEY` secret wiring. The lab is verified offline — the grader reads your YAML and checks the critical lines are there. You don't need a live GitHub repo to pass; you do need a live GitHub repo (and an `ANTHROPIC_API_KEY` secret) to *run* the workflow for real, which is the obvious follow-up.

## Prerequisites

- Claude Code installed and logged in (optional; verification is offline)
- Completed: [lab-01-cli-flags-tour](../lab-01-cli-flags-tour/), [lab-02-scripting-with-claude](../lab-02-scripting-with-claude/)
- Tools: none locally; a GitHub repo is only needed for the "Going further" live test

## What you'll build

- `starter/.github/workflows/claude-review.yml` with all four TODOs filled in: a `pull_request` trigger, a `Claude Code` install step, a `claude -p` invocation feeding the PR diff with read-only tools and capped turns, and the `ANTHROPIC_API_KEY` secret referenced via `env:`.

## Steps

1. Read the starter workflow top to bottom:
   ```bash
   cd 13-cli/lab-03-ci-integration/starter
   cat .github/workflows/claude-review.yml
   ```
   Notice the shape: checkout, install Node, install Claude, compute diff, ask Claude, post the comment. Four of those steps are stubs you'll fill in.
2. Fill in **TODO 1** — the trigger. Replace the `workflow_dispatch: {}` placeholder at the top with:
   ```yaml
   pull_request:
     types: [opened, synchronize]
   ```
   `synchronize` is the event fired when someone pushes more commits to a PR branch; you want those re-reviewed.
3. Fill in **TODO 2** — the install. Replace the `echo "TODO 2 ..."` line with:
   ```yaml
   run: npm install -g @anthropic-ai/claude-code
   ```
   This puts the `claude` binary on the runner's `PATH` for the rest of the job.
4. Fill in **TODO 3** — the Claude call. Replace the `echo "TODO 3 ..."` in the "Ask Claude for review" step with:
   ```bash
   claude -p "Review this PR diff. Flag bugs, missed edge cases, and tests you'd want added. Be concise — under 400 words. Format as markdown bullets grouped by severity." \
     --allowedTools "Read,Glob,Grep" \
     --max-turns 4 \
     --output-format text < pr.diff > review.md
   ```
   Three things matter here: `< pr.diff` pipes the diff in on stdin, `--allowedTools "Read,Glob,Grep"` prevents Claude from mutating the runner, `--max-turns 4` stops an unbounded tool loop.
5. Fill in **TODO 4** — the secret. Add an `env:` block to the same step so `ANTHROPIC_API_KEY` is available:
   ```yaml
   env:
     ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
   ```
   This expects a repo secret named `ANTHROPIC_API_KEY` — you'd add it under Settings → Secrets and variables → Actions in a real repo.
6. (Optional, for the "Going further" section) Commit this workflow to a GitHub repo with the `ANTHROPIC_API_KEY` secret configured. Open a small PR and watch Claude comment on it.

## Verify

```bash
bash ../../scripts/verify-lab.sh 13-cli/lab-03-ci-integration
```

The script parses your workflow YAML and confirms the four critical elements are present: the `pull_request` trigger, the `@anthropic-ai/claude-code` install, a `claude -p` invocation using read-only tools and a turn cap, and a reference to `secrets.ANTHROPIC_API_KEY`. Nothing runs against GitHub or Claude — the verification is purely structural.

## Solution

See `solution/.github/workflows/claude-review.yml` for one complete workflow. `solution/README.md` explains why read-only tools are non-negotiable in CI, why feeding the diff (not the whole repo) produces better reviews, and what this workflow still doesn't do (line-anchored comments, merge gating, cost caps).

## Going further

- Add a diff-size guard: if `wc -c < pr.diff` exceeds some threshold (say, 50k bytes), skip the Claude step and post a comment saying "diff too large for automated review".
- Pin a specific Claude model with `--model claude-haiku-4-5-20251001` to make the review cheaper for trivial PRs. Trade off thoroughness vs cost.
- Post Claude's review as **line-anchored** comments via `github.rest.pulls.createReviewComment` instead of a single issue comment. You'll need to prompt Claude to return structured JSON (file path + line + comment), then iterate and create comments per entry.

## References

- [Official docs: Headless mode](https://docs.claude.com/en/docs/claude-code/headless) — the `claude -p` + CI pattern
- [Official docs: CLI reference](https://docs.claude.com/en/docs/claude-code/cli-reference) — `--allowedTools`, `--max-turns`
- [Official docs: Settings](https://docs.claude.com/en/docs/claude-code/settings) — the environment variables Claude Code reads, `ANTHROPIC_API_KEY` among them
