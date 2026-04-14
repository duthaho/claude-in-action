# claude-in-action

Hands-on labs for learning Claude Code by building things. Every lab is a small, self-contained exercise: read the goal, modify the files in `starter/`, run `verify.sh`, then peek at `solution/` to compare. Most labs take 15–45 minutes.

## Who this is for

Beginners who have Claude Code installed and want to learn by doing. You do not need to read anything first — each lab is self-contained and teaches one focused idea.

## How to use this repo

```bash
git clone <repo-url>
cd claude-in-action
cat LEARNING-PATH.md          # suggested order through the 13 sections
cat 01-slash-commands/lab-01-hello-command/README.md
```

A lab has five moving parts:

1. **`README.md`** — the lab instructions (Goal, Prerequisites, Steps, Verify, Solution).
2. **`starter/`** — files you modify. This is your workspace.
3. **`solution/`** — the finished state. Try the lab first, peek after.
4. **`verify.sh`** — a script that checks whether your `starter/` matches what the lab expected. Offline, no Claude call required.
5. **`.lab-meta.yml`** — machine-readable metadata used by `scripts/list-labs.sh`.

To run the verifier from the repo root:

```bash
bash scripts/verify-lab.sh 01-slash-commands/lab-01-hello-command
```

To scaffold a new lab while contributing:

```bash
bash scripts/new-lab.sh 01-slash-commands lab-99-my-experiment
```

## Sections

| # | Section | Status |
|---|---|---|
| 01 | [Slash Commands](01-slash-commands/) | v1.0 — built |
| 02 | [Memory](02-memory/) | v1.0 — built |
| 03 | [Configuration & Permissions](03-configuration-and-permissions/) | v1.1 — built |
| 04 | [Skills](04-skills/) | v1.1 — built |
| 05 | [Subagents](05-subagents/) | coming in v1.2 |
| 06 | [Agent Teams](06-agent-teams/) | coming in v1.2 |
| 07 | [MCP](07-mcp/) | v1.1 — built |
| 08 | [Hooks](08-hooks/) | coming in v1.2 |
| 09 | [Channels](09-channels/) | coming in v2.0 |
| 10 | [Plugins](10-plugins/) | coming in v1.3 |
| 11 | [Checkpoints](11-checkpoints/) | coming in v1.3 |
| 12 | [Advanced Features](12-advanced-features/) | coming in v2.0 |
| 13 | [CLI](13-cli/) | coming in v2.0 |

Full lab inventory: [`INDEX.md`](INDEX.md). Suggested study order: [`LEARNING-PATH.md`](LEARNING-PATH.md).

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the lab authoring rules and [`STYLE-GUIDE.md`](STYLE-GUIDE.md) for voice and formatting conventions.

## License

MIT. See [`LICENSE`](LICENSE).
