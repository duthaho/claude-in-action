# Lab 02 — Parallel Researchers

> Section: 06-agent-teams · Difficulty: intermediate · Est: 35 min

## Goal

You author a team of **N parallel researchers** that fan out across independent subtopics, work concurrently in their own context windows, and converge on a single synthesised report. Unlike lab 01 (three differently-skilled teammates), this lab is about *scaling the same role* across independent work. The interesting structure is: one reusable `researcher` subagent definition, a `QUESTIONS.md` that lists N subtopics as independent tasks, and a `TEAM-PROMPT.md` that tells the lead to spawn one researcher per subtopic and synthesise their findings. By the end you know when to scale-out (parallel exploration pays off) vs when to scale-up (a single smarter agent would be cheaper).

## Prerequisites

- Claude Code v2.1.32 or later
- Completed: [lab-01-planner-builder-tester](../lab-01-planner-builder-tester/) — you know how to enable agent teams and reference subagent definitions
- A `sources/` corpus is included in the starter (three short documents about a fictional platform)

## What you'll build

- `.claude/settings.json` with the experimental flag on
- `.claude/agents/researcher.md` — one reusable role with read-only tools, scoped to answering one question against the `sources/` corpus
- `QUESTIONS.md` at starter root — lists 3 independent research questions as tasks (each task is a question, not a document to read)
- `TEAM-PROMPT.md` — the prompt that tells the lead to spawn 3 researchers in parallel, one per question, and synthesise
- `REPORT-TEMPLATE.md` — the shape each researcher's answer will land in, so the lead can stitch them together without surprises

## Steps

1. Change into the starter:
   ```bash
   cd 06-agent-teams/lab-02-parallel-researchers/starter
   ls sources/
   ```
   Three short source documents about a fictional `paypal-lite` payments API. The researchers will read from these.
2. Create `.claude/settings.json` with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` under `env`.
3. Create `.claude/agents/researcher.md`:
   - `name: researcher`
   - `description:` trigger on "research", "find out", "look up" — same as section 05 lab 02, but narrower: emphasise that it answers one specific question and cites `path:line`.
   - `tools: Read, Grep, Glob` (read-only)
   - `disallowedTools: Bash, Write, Edit`
   - `model: haiku` — research work is pattern matching; Haiku is the right size
4. Write `QUESTIONS.md` listing three independent questions:
   ```markdown
   1. What is the SLA for `paypal-lite` refund operations?
   2. How are webhook signatures verified?
   3. What happens if an idempotency key is reused with different request bodies?
   ```
   Keep questions independent — a researcher answering Q2 should not need Q1's answer. Dependency = sequential = wrong shape for this lab.
5. Write `REPORT-TEMPLATE.md` — the exact Markdown shape each researcher emits. Pin it hard. Synthesis only works if outputs are uniform.
6. Write `TEAM-PROMPT.md` telling the lead to: enable agent teams, spawn *three* `researcher` teammates, assign one question per teammate, and synthesise into a single report when all three are done.
7. Launch Claude Code from inside `starter/`, paste `TEAM-PROMPT.md`, and watch the three researchers work concurrently. Use Shift+Down to cycle through them.

## Verify

```bash
bash ../../scripts/verify-lab.sh 06-agent-teams/lab-02-parallel-researchers
```

The script checks that:

- `starter/.claude/settings.json` has `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"`.
- `starter/.claude/agents/researcher.md` exists with `name: researcher`, read-only `tools`, and `disallowedTools` containing at least `Write` and `Edit`.
- `starter/QUESTIONS.md` exists and lists at least 3 enumerated items.
- `starter/REPORT-TEMPLATE.md` exists — the shape is defined, not improvised per researcher.
- `starter/TEAM-PROMPT.md` exists, references `researcher`, and mentions a plurality ("three", "parallel", "N", "each question") so the scale-out is explicit.
- `starter/sources/` corpus is intact (three Markdown files).

## Solution

See `solution/`. `solution/README.md` covers: when parallel exploration actually beats sequential, why the synthesis step is usually the hardest part, and how to keep independent researchers from redoing each other's work.

## Going further

- Add a fourth question that depends on a previous answer. Watch the team get confused. Fix it by breaking the dependency or by marking that task blocked.
- Lower the researcher's `model` to `haiku` (if not already) and raise to `sonnet` for comparison. Measure the token cost difference (see `claude --costs`).
- Add a `synthesiser` subagent with a different role to produce the merged report, instead of leaving synthesis to the lead. When is that better?
- Swap the `sources/` corpus for a real codebase — can the same researcher definition do real code archaeology?

## References

- [Official docs: Agent teams](https://docs.claude.com/en/docs/claude-code/agent-teams) — see "Use case examples" for parallel review patterns
- [Official docs: Subagents](https://docs.claude.com/en/docs/claude-code/sub-agents)
