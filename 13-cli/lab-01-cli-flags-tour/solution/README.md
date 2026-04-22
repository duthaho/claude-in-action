# Solution — lab-01-cli-flags-tour

> Try the steps in the lab's `README.md` first — peek here after.

## Why this lab is flags-only, not CLI-theory

`claude --help` prints every flag and its one-line description. Reading it is five minutes. What the docs don't teach is *which flags you actually reach for*, in what combinations, for what situations. Five flags — `-p`, `--output-format`, `--append-system-prompt`, `--allowedTools`, `--max-turns` — cover the vast majority of headless use. Everything else is variation on those.

## Why these five

- **`-p` / `--print`.** Without it you get the interactive TUI. With it, Claude behaves like a Unix filter: read prompt (and stdin if piped), write reply, exit. This is the flag that makes Claude scriptable.
- **`--output-format json`.** Text output is ambiguous — it can contain `\n`, nested quotes, markdown fences, all of which bite when you try to parse downstream. JSON wraps the reply in a stable envelope (`result`, `usage`, `is_error`) that `jq` can pull apart without regex. Switch to `stream-json` when you want events as they arrive, not in one shot.
- **`--append-system-prompt`.** The built-in system prompt stays useful (tool schemas, safety rails); you're adding on top. This is where persona, domain terminology, output-format constraints live. If you find yourself wanting to *replace* the system prompt, you're usually building something that's no longer Claude Code — consider the raw API.
- **`--allowedTools` / `--disallowedTools`.** In CI, the blast radius of letting Claude `Edit`/`Write` is usually too high. Restrict to read-only tools; have the agent *describe* a diff as text, and apply it yourself. (See the ci-integration lab in this section for an example.)
- **`--max-turns N`.** A runaway prompt can loop through tools forever. N=2 is enough for "look up something then answer"; N=5 for "small refactor"; N=20 if you really know what you're doing. Treat this as a cost-and-safety knob, not a performance one.

## Flags you'll eventually need but don't learn here

- `--model <id>` — pick a specific model (haiku for cheap summaries, opus for hard reasoning). Default is whatever the latest configured default is.
- `--session-id <id>` or `--resume` — continue a prior session rather than starting fresh. Less common headless, very useful in long-running pipelines.
- `--input-format stream-json` — the mirror of `--output-format`. Lets you feed a sequence of user messages, not just one prompt. Required for multi-turn headless agents.
- `--settings <path>` — point at a specific settings file rather than the repo default. Lets you keep `ci/claude-settings.json` separate from the interactive settings.
- `-c` / `--continue` — pick up the most recent session in the current directory. Interactive, not usually useful from scripts.

Learn them when the five above stop covering your case — not preemptively.
