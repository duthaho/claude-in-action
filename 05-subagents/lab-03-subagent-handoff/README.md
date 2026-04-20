# Lab 03 — Subagent Handoff

> Section: 05-subagents · Difficulty: intermediate · Est: 40 min

## Goal

You build a **two-subagent pipeline**: a read-only `reviewer` that produces a findings report, and a write-capable `patch-writer` that takes one finding at a time and applies a minimal fix. Your main conversation orchestrates between them — dispatch the reviewer, read the report, decide which findings to act on, dispatch the patch-writer once per actionable finding, then summarise. By the end you understand why the main conversation is the glue (not another subagent), how to keep agent interfaces stable enough to compose, and why splitting review and fix into two agents with different tool sets is safer than one omnipotent agent.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-code-reviewer-subagent](../lab-01-code-reviewer-subagent/) and [lab-02-researcher-subagent](../lab-02-researcher-subagent/)
- Tools: `python --version` ≥ 3.9 (just to sanity-check the sample module syntax)

## What you'll build

- Two subagents in `starter/.claude/agents/`:
  - `reviewer.md` — read-only (`tools: Read, Grep, Glob`), produces a findings report in a fixed shape.
  - `patch-writer.md` — write-capable (`tools: Read, Edit, Glob`), takes a single finding and applies the minimal fix; no `Bash`, no `Write` (we use `Edit` to surgically change lines, not create new files).
- A sample module `starter/src/config.py` with one seeded bug (a bare `except:` swallowing `ValueError`s).
- A one-page `starter/PIPELINE.md` that documents the exact dispatch flow so anyone on the team can run the pipeline the same way.

## Steps

1. Change into the starter and inspect the code that will be flowing through the pipeline:
   ```bash
   cd 05-subagents/lab-03-subagent-handoff/starter
   cat src/config.py
   ```
2. Create both agents in `.claude/agents/`.
   - `reviewer.md` uses the same frontmatter shape as lab 01 but with a description narrower to "one file at a time". A reviewer that insists on walking a whole repo won't compose well with a pipeline.
   - `patch-writer.md` has `tools: Read, Edit, Glob`. Its description makes explicit that it expects to receive *one* finding as input, in the shape the reviewer emits. It writes the minimum change to address the finding and stops.
3. Write `PIPELINE.md` in the starter root. It documents:
   - Step A: dispatch the reviewer with "review `src/config.py`".
   - Step B: parse the report. For each finding of severity Critical or Warning, decide whether to fix.
   - Step C: for each accepted finding, dispatch the patch-writer with the finding text as its input.
   - Step D: summarise what changed.
4. Start Claude Code from inside `starter/` and try the pipeline by prompting: *"run the review-and-fix pipeline on src/config.py"*. Observe that:
   - The reviewer runs first and returns a report.
   - The patch-writer runs once per accepted finding and edits the file.
   - The main conversation stays tidy — you see summaries, not tool-call noise.
5. Inspect `src/config.py` after the pipeline finishes. The bare `except:` should be narrowed to `except ValueError:` (or another specific exception). The rest of the file should be unchanged.

## Verify

```bash
bash ../../scripts/verify-lab.sh 05-subagents/lab-03-subagent-handoff
```

The script checks that:

- Both `starter/.claude/agents/reviewer.md` and `starter/.claude/agents/patch-writer.md` exist with correct frontmatter.
- `reviewer.md` has `tools: Read, Grep, Glob` and does **not** include `Edit` or `Write`.
- `patch-writer.md` has `Edit` in its `tools` list and does **not** include `Bash`.
- `starter/PIPELINE.md` documents all four steps (dispatch reviewer, parse, dispatch patch-writer per finding, summarise).
- The reviewer's body specifies the same `## Issues` report shape that the patch-writer expects as input (so the two interlock).

## Solution

See `solution/`. `solution/README.md` walks through why the main conversation is the orchestrator, how to design agent interfaces that compose, and when a pipeline like this should graduate to a proper [agent team](../../06-agent-teams/) instead.

## Going further

- Add `disallowedTools: Write` to `patch-writer.md` explicitly. Does that matter given `tools:` is already an allowlist?
- Write a third subagent `test-runner` with `tools: Bash` that runs `python -m unittest` and returns pass/fail. Wire it as step D of the pipeline after patch-writer, before summarise.
- Replace the pipeline with an agent team (lab 06). What changes? When is the team the right shape and when is the manual pipeline better?
- Add `maxTurns: 3` to the patch-writer frontmatter. What problem does that solve?

## References

- [Official docs: Subagents](https://docs.claude.com/en/docs/claude-code/sub-agents)
- [Official docs: Agent teams](https://docs.claude.com/en/docs/claude-code/agent-teams)
