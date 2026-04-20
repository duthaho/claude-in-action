# Review-and-fix pipeline

Two subagents, one orchestrator (your main conversation). The pipeline takes a file or directory, produces a set of fixes.

## Dispatch flow

### Step A — Dispatch `reviewer`

The main conversation dispatches the `reviewer` subagent with the scope: "review `src/config.py`". The reviewer returns a Markdown report following the shape documented in `.claude/agents/reviewer.md`.

### Step B — Parse the report

The main conversation reads the report. For each finding it decides:

- **Critical and Warning** findings are candidates for patching.
- **Note**-level findings are surfaced to the user in the final summary but not auto-fixed.
- Any finding where the suggested fix is vague ("refactor this") is surfaced to the user — not dispatched to patch-writer. Patch-writer needs a concrete fix to apply.

### Step C — Dispatch `patch-writer` per finding

For each accepted finding, the main conversation dispatches `patch-writer` once with the finding reformatted as:

```
path: <file>
line: <number>
issue: <short description>
suggested_fix: <the fix the reviewer proposed>
```

The patch-writer applies the change and replies with a `patched: ... / change: ...` confirmation.

### Step D — Summarise

The main conversation assembles a final summary listing:

- Findings that were patched (with links to the changed lines).
- Findings that were surfaced but not patched (notes, vague fixes).
- Findings the patch-writer rejected (stale or requiring escalation).

## Why the main conversation is the orchestrator

The main conversation is the only place that can:

- See the reviewer's full report at once.
- Decide which findings to act on based on policy the user set ("only fix Critical").
- Dispatch multiple patch-writers sequentially without each losing context from the previous.

Making another subagent the orchestrator would add a layer that doesn't buy you anything — subagents can't spawn other subagents, and the orchestration logic is exactly the kind of thing the main conversation is good at.

## When this pipeline is wrong

If you need the agents to run *in parallel* and communicate while working, this pipeline is the wrong shape — use an [agent team](../../06-agent-teams/) instead. The pipeline here is strictly sequential and one-shot.
