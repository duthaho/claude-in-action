# Solution — lab-01-planner-builder-tester

The finished state is five files in `starter/`:

- `.claude/settings.json` — enables the experimental agent-teams feature.
- `.claude/agents/planner.md` — read-only plan-mode planner.
- `.claude/agents/builder.md` — Edit/Write but no Bash.
- `.claude/agents/tester.md` — Bash but no Edit.
- `SPEC.md` — the feature the team will implement.
- `TEAM-PROMPT.md` — the exact prompt you paste to spawn the team.

## Why this shape, not "one big agent"

A single-agent approach would give one Claude instance Edit+Write+Bash and say "go implement the spec". That works up to a point. The three-agent team shape earns its keep when:

1. **The three jobs want different tool sets.** A planner that can `Edit` will start coding before the plan is approved. A builder that can `Bash` will run tests — and silently "fix" them when they fail. A tester that can `Edit` will silently patch code to make tests pass. Separating the agents and their tools means each role is structurally incapable of overstepping.
2. **You want a plan-approval checkpoint.** The planner runs in plan mode; the lead approves or rejects. That checkpoint is where policy lives (which changes are in scope, what the success criteria are). Without agents, policy has to live inside a single long prompt that the model weighs against everything else it's trying to do.
3. **The test feedback loop should be tight.** With a tester teammate messaging the builder directly, failures route straight back to the agent who made the change, without the lead having to parse and re-dispatch. That messaging is the feature agent teams have and subagents don't.

## Why teammates reuse subagent definitions

When you write `.claude/agents/planner.md`, the file is a normal subagent definition — readable as a regular subagent in a different session, reusable by multiple teams. Claude Code honours the `tools` allowlist and `model` from the definition when the teammate runs; the body becomes *additional* instructions appended to the teammate's system prompt.

This is a nice reuse story: the planner you use in an agent team is the same planner you'd dispatch as a plain subagent for a smaller task. No duplication.

## Why `permissionMode: plan` on the planner

The planner's frontmatter pins `permissionMode: plan`. That means the planner starts in plan mode regardless of the lead's permission mode. It cannot apply edits even if something goes wrong in the prompt — it has to exit plan mode (which requires approval) first. For a planner, that's exactly right.

## Why `model: haiku` on the tester

The tester runs a deterministic command and reports structured output. That's work Haiku handles as well as Sonnet at a fraction of the cost and latency. The planner and builder get Sonnet because they do reasoning-heavy work (decomposing the spec, making code changes); the tester just runs the script and reports.

## The biggest failure mode: vague specs

The single most common way this team derails is a vague `SPEC.md`. If the spec doesn't have success criteria, the planner invents them, the builder builds to the invented criteria, and the tester has no ground truth to verify against. When you see the team going in circles, check whether the spec actually says what "done" looks like.

The spec in this lab is deliberately explicit — output shape specified to the line, test cases listed, exit codes defined. Real specs should aim for the same.

## When this is the wrong shape

Agent teams are expensive (every teammate is a real Claude instance) and require coordination overhead. For a one-file change, a single session is faster. For a sequential pipeline where stages don't need to talk to each other, a subagent pipeline (section 05 lab 03) is cheaper. The team shape pays off when:

- The work has genuinely independent pieces that can run in parallel, **or**
- The stages need back-and-forth communication (tester → builder → tester), **or**
- You want plan approval as a real checkpoint, not a rule in a system prompt.

If none of those apply, don't reach for a team.

## Key decisions

- **Project scope, not user scope.** The three agents ship with the repo so the team shape is part of the codebase. A reusable `tester` might live in `~/.claude/agents/` — the lab's `tester` is deliberately project-local because it references a project-specific test command.
- **No Bash on the builder.** Tempting to add — "let the builder run quick smoke tests" — but once Bash is on the builder, the tester teammate loses its reason to exist.
- **`TEAM-PROMPT.md` is version-controlled.** The exact natural-language instruction that starts the team is part of the artifact. Anyone on the team can paste it and get the same structure.

## If you got stuck

- **"The lead didn't create a team."** Experimental flag isn't set. Restart Claude Code after adding `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: 1`.
- **"Teammates aren't visible."** You're probably in in-process mode — press Shift+Down to cycle through them.
- **"The builder keeps running tests."** Your `tools:` list includes `Bash`. Remove it — the tester is the only agent that should have Bash.
- **"The tester rewrote a failing test to make it pass."** Your `tester.md` tools list included `Edit` or `Write`. It shouldn't. Remove them and re-read the tester's constraints section.
