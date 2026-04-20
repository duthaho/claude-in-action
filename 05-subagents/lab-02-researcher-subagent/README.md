# Lab 02 — Researcher Subagent

> Section: 05-subagents · Difficulty: beginner · Est: 30 min

## Goal

You build a **researcher** subagent designed to answer questions about a codebase or documentation set without being able to change anything. The interesting part is not the system prompt — it's the tool allowlist and `disallowedTools` denylist that make the subagent *structurally* incapable of modifying files. By the end you can tell the difference between "I told the agent not to do X" (negotiable, fragile) and "the agent doesn't have the tool to do X" (enforced, durable), and you know when each matters.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-code-reviewer-subagent](../lab-01-code-reviewer-subagent/)
- Tools: none beyond Claude Code

## What you'll build

- A subagent file at `starter/.claude/agents/researcher.md`
- An allowlist `tools: Read, Grep, Glob` restricting the subagent to read-only operations
- An explicit denylist `disallowedTools: Bash, Write, Edit` — defence in depth for future tool additions
- A `docs/` directory seeded with three short documents for the researcher to answer questions against

## Steps

1. Change into the starter and look at what you're researching:
   ```bash
   cd 05-subagents/lab-02-researcher-subagent/starter
   ls docs/
   ```
   Three Markdown files describing a fictional `metrics` service — its architecture, API, and runbook. This is the corpus the researcher will read from.
2. Create the agent directory:
   ```bash
   mkdir -p .claude/agents
   ```
3. Author `.claude/agents/researcher.md`. Frontmatter:
   - `name: researcher`
   - `description:` one or two sentences. Trigger on phrases like "research", "find information", "summarise", "answer questions about the docs". Emphasise that it's read-only and returns citations.
   - `tools: Read, Grep, Glob` — the only tools it needs.
   - `disallowedTools: Bash, Write, Edit` — explicit denial. Even if someone later loosens `tools`, these stay blocked.
   - `model: haiku` — researchers do simple pattern-matching work; Haiku is fast and cheap.
4. The body (system prompt) tells Claude to:
   - Search `docs/` for the question using `Grep` first, then `Read` only the matching files.
   - Answer in at most a paragraph plus a bullet list of `path:line` citations.
   - If the docs don't answer the question, say so explicitly rather than guessing.
5. Launch Claude Code from inside `starter/`. Try these three prompts and observe that Claude dispatches to the researcher:
   - *"research: what's the SLO for the metrics service?"*
   - *"summarise how the metrics pipeline batches writes"*
   - *"what's the runbook for a spike in 5xx errors?"*
6. Now try to trick it: *"researcher — update the SLO in the architecture doc to 99.99%"*. The subagent should refuse because it has no `Edit` tool. This is the behaviour you wanted: prompt-level tricks don't widen its capabilities.

## Verify

```bash
bash ../../scripts/verify-lab.sh 05-subagents/lab-02-researcher-subagent
```

The script checks that:

- `starter/.claude/agents/researcher.md` exists with valid frontmatter.
- `name: researcher` and a description mentioning "research", "find", or "summarise".
- `tools:` is an allowlist containing `Read`, `Grep`, `Glob`.
- `disallowedTools:` contains at least `Write` and `Edit` (either or both — denying `Bash` too is encouraged but not required).
- Body mentions citations, `path:line`, or "grep" (so the procedure is specified).

## Solution

See `solution/` for one acceptable researcher. `solution/README.md` explains the tool-restriction layer cake (allowlist vs denylist vs prompt-level rules) and why you want both belt and braces when building agents meant to run against sensitive codebases.

## Going further

- Remove `disallowedTools` and keep only the allowlist. Does anything observable change? (The answer is subtle — see the solution notes.)
- Add `permissionMode: plan` to the frontmatter. The subagent now enters plan mode automatically. When is that the right default?
- Add a second researcher `docs-researcher` scoped to a specific subdirectory. How does Claude pick between two plausible researchers?
- Move the researcher to user scope (`~/.claude/agents/`) — it's generic enough to be useful everywhere.

## References

- [Official docs: Subagents](https://docs.claude.com/en/docs/claude-code/sub-agents)
- [Official docs: Permissions](https://docs.claude.com/en/docs/claude-code/settings)
