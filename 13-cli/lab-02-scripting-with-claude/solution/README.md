# Solution — lab-02-scripting-with-claude

> Try the steps in the lab's `README.md` first — peek here after.

## What the pipeline actually does

Three discrete stages:

1. **Feed Claude structured input, ask for structured output.** The prompt pins Claude to a rigid JSON shape. If the reply is anything other than the expected JSON — a markdown fence, a preamble, a tweak to the schema — the post-processing step will crash. That's a feature: loud failures beat silent drift.
2. **Strip the envelope.** `--output-format json` wraps Claude's reply in `{"type": "result", "result": "<the actual JSON>", "usage": {...}}`. Your downstream code wants the inner payload, not the envelope. One line of Python (or `jq -r '.result'` if you have it) pulls it out.
3. **Post-process in Python.** Sort, filter, format. This is where `jq` shines if you know it, and Python works fine if you don't. The choice is stylistic — the point is that Claude's output is a data value you can transform, not a terminal artifact.

## Why the canned-response fallback

The `command -v claude` check exists for the same reason it did in the headless-bot lab: **testability without a key**. Without it, running this script in CI requires an API key in every PR runner's secrets, every fork, every contributor's clone. With the fallback, the pipeline is exercised end-to-end against a known-good JSON — the transformation logic is tested even when the LLM isn't.

This is a pattern worth stealing. Any time you integrate an LLM into a pipeline, keep a canned "golden" response file. Your tests hit the golden; a separate integration suite hits the live model. That split is what makes LLM-in-the-loop code maintainable.

## Why ask for JSON instead of text

Three reasons:

- **Deterministic parsing.** "Extract the top 3 error endpoints" in prose could be `"/api/payments had 4 failures"` or `"The payments endpoint failed 4 times"` — same content, incompatible shapes. JSON pins the shape.
- **Composability.** Once the output is JSON, it plugs into whatever downstream — a dashboard, an alerting system, a database. Text is an endpoint; JSON is a pass-through.
- **Cost.** A one-line JSON reply is cheaper than the same information wrapped in polite prose. At scale this matters.

The tradeoff: the model sometimes misses the schema — adds a comment, wraps in ``` ``` ```, or omits a field. That's why the prompt is forceful ("Reply ONLY with JSON") and the post-processing crashes loudly on malformed input.

## When to graduate past a shell script

- When the prompt gets long enough that you want it version-controlled as a separate file, not inline in bash.
- When you're chaining three or more LLM calls (extract → summarise → classify). Bash pipes get ugly; a Python script with a tiny SDK wrapper is cleaner.
- When you need retries, rate-limit handling, or cost accounting. Shell doesn't have a story for those; the SDKs do.

Until then, bash + python + a canned fallback covers a startlingly large fraction of real LLM-in-the-loop work.
