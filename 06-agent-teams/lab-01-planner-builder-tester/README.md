# Lab 01 — Planner / Builder / Tester Team

> Section: 06-agent-teams · Difficulty: intermediate · Est: 40 min

## Goal

You set up an agent team of three cooperating teammates — `planner`, `builder`, `tester` — and put them to work on a small feature spec. Unlike a subagent pipeline (section 05), the team lives across a real session: teammates share a task list, claim work, and message each other directly. Your job in this lab is not to build the team runtime (Claude Code does that) — it is to (1) enable the experimental feature, (2) define three reusable **subagent definitions** at `.claude/agents/` that the lead will spawn as teammates, and (3) write a `SPEC.md` + a `TEAM-PROMPT.md` that let any team member pick the work up the same way.

## Prerequisites

- Claude Code v2.1.32 or later (`claude --version`)
- Completed: [lab-03-subagent-handoff](../../05-subagents/lab-03-subagent-handoff/) — you understand subagents first
- This is the single intermediate lab in section 06

## What you'll build

- `.claude/settings.json` with the experimental flag turned on:
  ```json
  { "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
  ```
- Three subagent definitions in `.claude/agents/` — `planner.md`, `builder.md`, `tester.md` — each with its own `tools`, `model`, and role-specific system prompt.
- `SPEC.md` at the starter root: a short feature spec (a `/stats` endpoint for the todo-cli) the team will implement.
- `TEAM-PROMPT.md` at the starter root: the exact instruction the learner will paste to the lead ("spawn three teammates using planner, builder, tester agent types; pre-approve the plan before builder touches code; tester runs last and reports pass/fail").

## Steps

1. Change into the starter and look at what you'll be wiring:
   ```bash
   cd 06-agent-teams/lab-01-planner-builder-tester/starter
   ls -la
   ```
2. Create `.claude/settings.json` and turn on the experimental flag. Without this, the team features are invisible and `/team` commands quietly no-op:
   ```json
   {
     "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" }
   }
   ```
3. Create three subagent files under `.claude/agents/`:
   - `planner.md` — `tools: Read, Grep, Glob` (read-only). Role: read `SPEC.md`, break it into 5–8 tasks of the right size for `builder` to pick up, write them to the shared task list. Plan mode on (via `permissionMode: plan`) so the team lead can approve the plan before any code moves.
   - `builder.md` — `tools: Read, Edit, Write, Glob`. Role: claim a task from the list, implement it, mark done, claim the next. Never runs tests.
   - `tester.md` — `tools: Read, Bash, Glob`. Role: once `builder` marks a task complete, run `python -m unittest` and report pass/fail back. Never edits code.
4. Write `SPEC.md` describing the feature. Keep it concrete: input/output, success criteria, constraints. Vague specs produce vague plans. One example:
   ```markdown
   # Feature — `/stats` for todo-cli

   Add a `stats` subcommand that prints: total todos, open todos, done todos, oldest open todo. Read from `todos.json`. No new flags. Existing `add/list/done` commands unchanged.
   ```
5. Write `TEAM-PROMPT.md` — the exact prompt the learner pastes into Claude Code to start the team. It should reference the three agent types by name, require plan approval, and set sensible guardrails:
   ```markdown
   Create an agent team to implement `SPEC.md`. Spawn three teammates:
   - `planner` (use the planner agent type) — read the spec, write the task list
   - `builder` (use the builder agent type) — implement tasks as planner finishes
   - `tester` (use the tester agent type) — run the test suite after each builder task

   Require plan approval before builder starts. Only approve plans that list concrete file:line changes.
   ```
6. Start Claude Code inside `starter/`, paste the contents of `TEAM-PROMPT.md`, and watch the lead spawn the three teammates. Use Shift+Down to cycle to each teammate and observe what they are doing.
7. Clean up when done — tell the lead: "clean up the team". If you skip this, orphan sessions pile up.

## Verify

```bash
bash ../../scripts/verify-lab.sh 06-agent-teams/lab-01-planner-builder-tester
```

The script checks that:

- `starter/.claude/settings.json` exists and contains `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: 1` under `env`.
- All three agent files exist: `planner.md`, `builder.md`, `tester.md`, each with a `name` matching the filename and a non-empty description.
- `planner.md` has read-only tools (no `Edit`, no `Write`, no `Bash`).
- `builder.md` has `Edit` in its tools list.
- `tester.md` has `Bash` in its tools list and no `Edit`.
- `starter/SPEC.md` and `starter/TEAM-PROMPT.md` both exist. `TEAM-PROMPT.md` references all three agent names (`planner`, `builder`, `tester`).

## Solution

See `solution/`. `solution/README.md` explains why each teammate gets a different tool set, when agent teams are worth the token cost, and how plan-approval interacts with the builder's tool access.

## Going further

- Add a fourth `reviewer` teammate that reviews the PR-shaped diff `builder` produced. What does the review loop cost in coordination overhead? When is it worth it?
- Make the `tester` agent stream test failures back to `builder` directly (teammate messaging) instead of through the lead. Which flow do you prefer and why?
- Convert `SPEC.md` into an ambiguous spec (missing success criteria) and watch `planner` ask the lead for clarification. That's how teams should handle vagueness — surface it, don't paper over it.

## References

- [Official docs: Agent teams](https://docs.claude.com/en/docs/claude-code/agent-teams)
- [Official docs: Subagents](https://docs.claude.com/en/docs/claude-code/sub-agents) (teammate definitions reuse the subagent file format)
