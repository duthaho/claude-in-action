# Solution — lab-03-subagent-handoff

The finished state is four files:

- `.claude/agents/reviewer.md` — read-only, produces findings.
- `.claude/agents/patch-writer.md` — Edit-capable, applies one finding at a time.
- `PIPELINE.md` — documents the four-step dispatch flow.
- `src/config.py` — the bare `except:` narrowed to `except ValueError:`.

## Why two agents instead of one

A single "review and fix" agent would need `Read`, `Grep`, `Glob`, *and* `Edit`. That combination is exactly what the main conversation already has — so the subagent wouldn't save any context and would just add an extra layer of orchestration on top of what Claude Code already does.

Splitting the work buys you three things:

1. **Tool restrictions per stage.** The reviewer has no `Edit` tool, so there is no possible code path where it accidentally rewrites a file while reviewing. The patch-writer has no `Grep` or `Glob`, so it can't wander off and "also" rework unrelated code it noticed while patching.
2. **Composability.** Each agent has a well-defined input and output shape. The reviewer emits a Markdown report with a fixed structure; the patch-writer consumes one finding of that structure. That contract means you can swap either side out — a stricter reviewer, a more cautious patch-writer, a Haiku-powered cheaper reviewer — without rewiring the other half.
3. **Context isolation.** The reviewer can read 50 files to build its report; all that file content stays in the reviewer's context and is summarised into the report that comes back. Same for the patch-writer per call. Your main conversation sees the report and the `patched:` confirmations — nothing more.

## Why the main conversation is the orchestrator, not a third subagent

Subagents cannot spawn subagents. So "the orchestrator" has to be the main conversation — which is good, because orchestration is exactly what the main conversation is for. The main conversation:

- Sees the full review report and can apply policy decisions ("only auto-fix Critical findings", "ask the user before touching tests").
- Dispatches the patch-writer once per finding, sequentially, so each patch-writer call starts fresh and doesn't accumulate state from previous patches.
- Owns the final summary that the user actually reads.

Trying to encode the orchestration in another subagent adds a layer of indirection without adding capability. Keep it in the main loop.

## Why `patch-writer` has `Edit` but not `Write`

`Edit` changes existing files. `Write` creates or overwrites files wholesale. A patch-writer that creates new files is doing something the reviewer didn't ask for — creating a new file is never a minimum change. Restricting to `Edit` forces the subagent to either apply the fix in place or refuse ("needs Write, escalate to parent").

This is the kind of restriction that pays off months later when someone tries to use the patch-writer for a refactor it wasn't designed for. The refusal is informative — "this job needs a different agent" — rather than silently doing the wrong thing.

## Why the reviewer's output shape is pinned so hard

The reviewer's system prompt specifies the *exact* Markdown structure of the report, including the exact heading names. That's because the main conversation parses this report to extract findings. Looser output means fragile parsing; stricter output means the pipeline can be automated.

If you wanted to make the pipeline fully deterministic, you'd go further and have the reviewer emit JSON instead of Markdown. The trade-off is that a JSON-only output is less useful for humans who want to read the report directly. Markdown with pinned structure is a reasonable compromise for a lab; a production pipeline would probably use JSON.

## Why the patch-writer's procedure re-reads the file

Step 1 of the patch-writer procedure says: read the file and confirm the finding is still valid at the cited line. That's defensive — between the reviewer finishing and the patch-writer starting, something else could have changed the file. Catching a stale finding and bailing with a clear message is better than patching the wrong line.

## When to graduate to an agent team

This pipeline is strictly sequential: reviewer finishes, parse, then patch-writer runs N times. If you need the stages to run concurrently (e.g. a reviewer looking at backend and a second reviewer looking at frontend at the same time, sharing findings) or if you need mid-flight communication ("reviewer, I'm patching line 12, can you re-check the surrounding code?"), you've outgrown the subagent pattern and want an [agent team](../../06-agent-teams/). Section 06 covers that shape.

## Key decisions

- **Reviewer and patch-writer share a model (`sonnet`).** Using different models complicates the mental model for no real gain at this scale. Upgrade the reviewer to Opus only if your codebase is complex enough that Sonnet misses issues.
- **Pipeline documented in `PIPELINE.md`, not inside the agents.** Each agent's system prompt describes *itself*, not the pipeline it's part of. That keeps each agent reusable in other contexts.
- **`Note`-level findings aren't auto-patched.** Auto-applying notes is how you get a PR that flips 40 lines of trivial formatting. Surface them; don't act on them without explicit consent.

## If you got stuck

- **"The main conversation dispatched the reviewer but didn't then call the patch-writer."** Your `PIPELINE.md` probably doesn't describe the sequence clearly, or the reviewer's report didn't follow the shape the patch-writer expects. Rewrite `PIPELINE.md` with the exact dispatch steps.
- **"The patch-writer over-edited."** Its constraints weren't tight enough. Re-read the "One finding, one edit" constraint — make sure yours is similarly explicit.
- **"The reviewer included 'Notes' that the pipeline tried to patch."** Your main-conversation instructions didn't distinguish severity. Policy (which severities to auto-fix) belongs in the orchestration, not in the agents.
