# Solution — lab-02-parallel-researchers

The finished state is six files in `starter/`:

- `.claude/settings.json` — enables agent teams.
- `.claude/agents/researcher.md` — one reusable role.
- `QUESTIONS.md` — three independent research questions.
- `REPORT-TEMPLATE.md` — the shape each researcher emits and the shape of the synthesised report.
- `TEAM-PROMPT.md` — the exact prompt that spawns three researchers and synthesises.
- `sources/` — three-file corpus about the fictional `paypal-lite` API.

## When fan-out is the right shape

Three researchers in parallel beats one researcher answering three questions sequentially when:

- **The questions are genuinely independent.** Q2's researcher does not read Q1's answer. If you find yourself adding dependencies, you've lost the parallelism benefit.
- **The corpus is large enough that one agent reading everything would pollute its context.** Each researcher reads *only* the sections relevant to its question, so the lead sees three focused answers instead of one bloated context.
- **Latency matters.** Three teammates running concurrently finish in roughly `max(time_per_question)`, not `sum(time_per_question)`.

For three short questions against a three-file corpus, the lab is a simulation — a single agent would easily handle this in one pass. The shape is the lesson, not the cost savings.

## Why a single reusable role, not three different ones

In lab 01, the three teammates had different skills (plan / build / test). Here, the three teammates have the *same* skill applied to three different inputs. Defining one `researcher` and spawning it three times is the right shape — the opposite would be authoring `refund-researcher.md`, `webhook-researcher.md`, `idempotency-researcher.md`, which is silly.

When you find yourself copy-pasting role definitions for teammates that only differ in what they read, you want a single role spawned N times.

## The hard part is synthesis, not research

The researcher definition is maybe 25 lines. The report template is another 20. The agent team prompt is 20. That's 65 lines of setup for three teammates who each produce one paragraph. The reason the setup is worth it is that **the synthesis step is only easy if the inputs are uniform** — and uniformity is what the pinned template and the constrained agent buy you.

If you ship this without `REPORT-TEMPLATE.md`, the lead will spend most of its tokens reformatting researchers' output into a common shape. The template is the load-bearing file; the researchers are almost interchangeable.

## Preventing researchers from re-doing each other's work

Each researcher has its own context. Without coordination, they can all grep the same files and notice the same sections. That's fine — grep is cheap. The failure mode is when a researcher notices a fact relevant to a sibling teammate's question and "helpfully" includes it in its own answer. The constraint "one question per dispatch" is what prevents that.

If you want cross-pollination (e.g. an investigation where teammates challenge each other's findings), use a different prompt — the scientific-debate pattern from the official docs is the canonical example. This lab deliberately does not do that.

## Token cost reality check

Three Haiku teammates each reading ~200 lines of source cost roughly three times a single Haiku agent. The parallelism buys you latency, not tokens. If the corpus were 100,000 lines and each researcher only needed to read the relevant 200, the fan-out would actually save tokens because each context stays small. Scale matters.

## Key decisions

- **`model: haiku` on the researcher.** Research is pattern matching at scale; Haiku is the right size. Sonnet would work too and would cost roughly 4× more.
- **`disallowedTools: Bash, Write, Edit`** even though `tools: Read, Grep, Glob` already excludes them. Defence in depth: if someone later widens the `tools` allowlist, the denylist still blocks the dangerous ones.
- **Report template in its own file.** It could live inside `researcher.md` as "output shape", but pulling it out means both the researchers and the synthesising lead read from the same spec. DRY.

## If you got stuck

- **"Only one researcher spawned."** You asked for "a researcher" (singular) instead of "three researchers". Re-read your `TEAM-PROMPT.md` — it needs a plural.
- **"Researchers answered each other's questions."** Your prompt didn't pin "one question per teammate". Restate it.
- **"Synthesis is a mess."** Your researchers' output didn't match `REPORT-TEMPLATE.md`. The usual cause is that `researcher.md`'s "Output shape" section is too loose. Pin it to exact Markdown with literal headings.
- **"A researcher said it couldn't find the answer, but the answer is in the corpus."** Grep keywords were too narrow. Either broaden them in the researcher's procedure, or rephrase the question to include the terms the corpus actually uses.
