# Changelog

All notable changes to `claude-in-action` are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versions use [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.1] — 2026-04-14

Two supplementary labs added to existing sections. No new sections.

### Added

- **`02-memory/lab-04-organizing-rules`** — decompose a bloated `CLAUDE.md` into topic-scoped files under `.claude/rules/`, auto-discovered by Claude. Contrasts the `.claude/rules/` mechanism with the `@import` approach from lab 02.
- **`03-configuration-and-permissions/lab-04-output-styles`** — author a custom `terse` output style, wire it via `.claude/settings.json`, and work through a classification exercise separating "style" rules from "memory" rules.

### Changed

- Section 02 and Section 03 READMEs updated with the new labs and expanded learning objectives.
- Total built labs: 15 → 17 (~455 min of practice).

## [0.2.0] — 2026-04-14

v1.1 content milestone: three new sections built, taking the repo from 6 labs to 15.

### Added

- **Section 03 — Configuration & Permissions** with three labs:
  - `lab-01-settings-tour` — author a `.claude/settings.json` with model, env, permission mode; explore `settings.local.json`.
  - `lab-02-allowlist-denylist` — lock a repo down with a read-only allow list and a `secrets/` deny rule.
  - `lab-03-per-project-vs-user` — debug a precedence conflict between user and project settings, including the empty-object-overrides gotcha.
- **Section 04 — Skills** with three labs:
  - `lab-01-first-skill` — author a `changelog-writer` skill with a tightly-scoped description.
  - `lab-02-skill-with-resources` — bundle two ADR templates as resources referenced from a single skill.
  - `lab-03-skill-evaluation` — write evals for a `slug-generator` skill, including the expected-failure pattern.
- **Section 07 — MCP** with three labs:
  - `lab-01-filesystem-mcp` — author a `.mcp.json` wiring the filesystem server scoped to a docs subdirectory.
  - `lab-02-sqlite-mcp` — wire a SQLite MCP server against a pre-built `library.db` and plan five queries.
  - `lab-03-custom-mcp-stub` — hand-roll a minimal MCP server in Python over stdio with tests for the three core message types.

### Changed

- Section stubs for 03, 04, 07 replaced by full `README.md` and `SECTION.md` marked `status: ready`.
- Top-level `README.md` section table updated so 03/04/07 are marked v1.0 built.
- `INDEX.md` regenerated — now 15 built labs, 8 planned sections.

## [0.1.0] — 2026-04-13

Initial scaffolding release. Proves the lab format end-to-end with two fully-built sections; the remaining eleven are stubbed with "coming in vX.Y" placeholders.

### Added

- Top-level files: `README.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `STYLE-GUIDE.md`, `INDEX.md`, `LEARNING-PATH.md`, `LICENSE`, `.gitignore`, `.editorconfig`, `.gitattributes`.
- Templates: `templates/lab/` and `templates/section/` canonical skeletons.
- Tooling: `scripts/new-lab.sh`, `scripts/verify-lab.sh`, `scripts/list-labs.sh`.
- Shared sandbox project: `sandbox/todo-cli/` (Python CLI with `add`, `list`, `done`).
- **Section 01 — Slash Commands** with three labs:
  - `lab-01-hello-command`
  - `lab-02-commit-command`
  - `lab-03-multi-step-refactor`
- **Section 02 — Memory** with three labs:
  - `lab-01-project-claude-md`
  - `lab-02-imports-and-layers`
  - `lab-03-memory-debug`
- Stub `README.md` + `SECTION.md` for sections 03–13 so `INDEX.md` links don't 404.

### Planned

- **v1.1**: sections 03 (Configuration & Permissions), 04 (Skills), 07 (MCP).
- **v1.2**: sections 05 (Subagents), 06 (Agent Teams), 08 (Hooks).
- **v1.3**: sections 10 (Plugins), 11 (Checkpoints).
- **v2.0**: sections 09 (Channels), 12 (Advanced Features), 13 (CLI); Tier-3 CI verification.

[Unreleased]: https://github.com/duthaho/claude-in-action/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/duthaho/claude-in-action/releases/tag/v0.2.1
[0.2.0]: https://github.com/duthaho/claude-in-action/releases/tag/v0.2.0
[0.1.0]: https://github.com/duthaho/claude-in-action/releases/tag/v0.1.0
