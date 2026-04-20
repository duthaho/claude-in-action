# Solution — lab-02-researcher-subagent

The finished state is `.claude/agents/researcher.md` plus the pre-existing `docs/` corpus. The researcher is ~25 lines including frontmatter.

## The three layers of "no, don't do that"

The `researcher.md` frontmatter uses three different mechanisms to keep the subagent read-only. Understanding what each one buys you is the main payload of this lab.

### Layer 1 — `tools:` allowlist

```yaml
tools: Read, Grep, Glob
```

This is the primary restriction. The subagent inherits no tools except the ones listed. `Write`, `Edit`, `Bash`, MCP tools — none of them are in scope. When the model tries to call a tool outside the list, the harness rejects the call before it reaches anything.

Allowlists are preferred over denylists because they handle *future* tools correctly. If Claude Code adds a `Patch` tool next quarter, the researcher automatically doesn't get it — you didn't add it to the allowlist.

### Layer 2 — `disallowedTools:` denylist

```yaml
disallowedTools: Bash, Write, Edit
```

This is belt-and-braces. Even if someone later changes the allowlist to be more permissive ("let's add Bash so the researcher can run `wc` on files…"), the denylist still blocks `Write` and `Edit`. The denylist is applied *after* the allowlist, so a tool listed in both ends up blocked.

For a researcher the denylist is somewhat redundant — the allowlist already blocks these. But it's cheap insurance and makes the author's intent explicit to anyone reading the frontmatter.

### Layer 3 — system-prompt rules

```
Never suggest modifying files. You don't have Edit or Write tools…
```

This is the weakest layer but still matters. The model reads the system prompt and shapes its behaviour accordingly; explicitly acknowledging the tool limits in the prompt heads off frustrating loops where the model tries to edit, fails, apologises, and tries again. A clear "you don't have that tool, don't try" keeps the subagent focused on its actual job.

**None of these three layers alone is sufficient.** Prompt rules alone are ignored under adversarial prompts. Allowlists alone can drift when you add tools later. Denylists alone don't scale to new tools. Together they form a cheap, robust restriction that a reasonable reader can see in one glance at the frontmatter.

## Why Haiku

Research is pattern matching. Find the right section, pull the sentence, cite the line. That's a task Haiku handles well at a fraction of the cost and latency of Sonnet. When a subagent's job is narrow enough, downsizing the model is a free win.

## Why `Grep` before `Read`

A researcher that reads every file to find one answer is doing the opposite of what a researcher should do. The procedure in the system prompt (`Grep` first, `Read` the matches, only then compose) is how humans do this — and telling the model the procedure gets better output than letting it invent one each session.

## Citations are load-bearing

Every claim has to have a `path:line` citation. This has two effects:

1. It forces the researcher to ground its output in the docs instead of hallucinating from model priors.
2. It makes the parent session's next step easy — "show me line 7 of architecture.md" is concrete; "tell me more about the SLO" is ambiguous.

Agents that return ungrounded prose are agents you will eventually stop trusting.

## Key decisions

- **Project scope, not user scope.** The researcher is generic enough to live in `~/.claude/agents/` — a reasonable stretch goal is to move it there.
- **`model: haiku`.** Deliberate downsize; reviewers get Sonnet, researchers get Haiku, orchestrators get whatever the parent uses.
- **No `Bash`, not even for `wc`.** The temptation to add Bash "just for grep-like things" is strong. Resist it. `Grep` and `Glob` are structured tools; `Bash` is a foothold.

## "Does removing disallowedTools change anything observable?"

With only an allowlist, the researcher is still read-only — the denylist is redundant. Where the denylist bites is *if the allowlist changes*. Someone later might think "the researcher should also be able to run `git log`" and add `Bash` to the allowlist. The denylist says no. That's the whole point: defence in depth against the codebase drifting over months.

## If you got stuck

- **"The subagent wouldn't dispatch."** Description is probably too narrow. Add more trigger phrasings: "look up", "what does the doc say", "find".
- **"It answered but didn't cite."** System prompt didn't pin citations hard enough. Say "every substantive claim must have a citation" and show the exact output shape.
- **"It hallucinated an answer that isn't in the docs."** The "say so explicitly" rule wasn't enforced. Add an example: `If you can't find it, reply with: "The documents under docs/ don't cover this."`
