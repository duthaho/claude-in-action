# Section 06 — Agent Teams

An **agent team** is a set of cooperating Claude Code sessions coordinated by a team lead. Unlike subagents (which are dispatched from a single session and report back), teammates have their own context windows, share a task list, and can message each other directly. The team shape shines when work has genuinely independent pieces that benefit from parallel exploration — or when stages of the work need back-and-forth conversation.

Agent teams are **experimental** and disabled by default. You turn them on by setting `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (via `settings.json` or the environment). Teams are created by asking Claude to make one; the lab settings encode the switch and the teammate roles but leave the team instantiation to the natural-language prompt you paste in.

The labs in this section walk you through setting up a role-based team (`planner` / `builder` / `tester`) and a parallel fan-out team (N researchers on independent subtopics). By the end you can decide when a team beats a subagent pipeline, reuse subagent definitions as teammates, and write a synthesis step that doesn't become the bottleneck.

## Learning objectives

After finishing these labs, you can:

- Enable agent teams via `settings.json`
- Author subagent definitions that work as teammates (tool allowlist, model, role-specific system prompt)
- Decide between role-based teams (each teammate different) and fan-out teams (same role spawned N times)
- Recognise when parallel exploration is worth the token cost and when it isn't
- Synthesise parallel work into a single coherent output

## Labs

| # | Lab | Difficulty | Est. |
|---|---|---|---|
| 01 | [lab-01-planner-builder-tester](lab-01-planner-builder-tester/) | intermediate | 40 min |
| 02 | [lab-02-parallel-researchers](lab-02-parallel-researchers/) | intermediate | 35 min |

## References

- [Official docs: Agent teams](https://docs.claude.com/en/docs/claude-code/agent-teams)
- [Official docs: Subagents](https://docs.claude.com/en/docs/claude-code/sub-agents) — teammate definitions reuse the subagent file format
