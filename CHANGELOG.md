# Changelog

All notable changes to `claude-in-action` are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versions use [Semantic Versioning](https://semver.org/).

Cadence: one version per planned milestone (v1.0 → v0.1.0, v1.1 → v0.2.0, v1.2 → v0.3.0, …). Supplementary labs added to existing sections ship under the same milestone — no point-releases per lab. See `INDEX.md` for the canonical per-lab inventory.

## [Unreleased]

## [0.4.0] — 2026-04-22

v1.3 milestone: sections 10 (Plugins), 11 (Checkpoints) built. 5 new labs.

### Added

- **Section 10 — Plugins**: install a bundled `greeter` plugin from a local marketplace, author a `quote-of-the-day` plugin bundling a command and a skill, publish a marketplace listing two plugins.
- **Section 11 — Checkpoints**: `/rewind` a wrong code change, branch one checkpoint into two parallel implementations and compare.

### Changed

- Sections 10, 11 promoted from stubs to `status: ready`.
- Top-level README section table marks 10/11 as v1.3 built.

## [0.3.0] — 2026-04-20

v1.2 milestone: sections 05 (Subagents), 06 (Agent Teams), 08 (Hooks) built. 8 new labs.

### Added

- **Section 05 — Subagents**: `code-reviewer` subagent, read-only `researcher` with three-layer tool restrictions, two-agent `reviewer`+`patch-writer` handoff pipeline.
- **Section 06 — Agent Teams** (experimental feature): role-based `planner`/`builder`/`tester` team, parallel-researcher fan-out with pinned report template.
- **Section 08 — Hooks**: `PreToolUse` commit gate on `TODO` markers, `PostToolUse` edit logger, `PreToolUse` safety hook denying `prod/` writes with offline test fixture.

### Changed

- Sections 05, 06, 08 promoted from stubs to `status: ready`.
- Top-level README section table marks 05/06/08 as v1.2 built.
- All hook scripts use `python` (not `jq`) for cross-platform JSON parsing.

## [0.2.0] — 2026-04-14

v1.1 milestone: sections 03 (Configuration & Permissions), 04 (Skills), 07 (MCP) built, plus supplementary labs on rules organisation and output styles. 11 new labs.

### Added

- **Section 03 — Configuration & Permissions**: settings tour, allowlist/denylist for `secrets/`, per-project vs user precedence debug, custom `terse` output style.
- **Section 04 — Skills**: first `changelog-writer` skill, ADR skill with bundled resources, `slug-generator` with evals.
- **Section 07 — MCP**: filesystem MCP scoped to `./docs`, SQLite MCP over a pre-built `library.db`, hand-rolled Python stdio MCP server with tests.
- **Section 02 — Memory** (supplementary): `.claude/rules/` decomposition of a bloated `CLAUDE.md`.

### Changed

- Sections 03, 04, 07 promoted from stubs to `status: ready`.

## [0.1.0] — 2026-04-13

Initial scaffolding release. Repo framework + the first two sections built; sections 03–13 stubbed.

### Added

- Top-level files (`README.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `STYLE-GUIDE.md`, `INDEX.md`, `LEARNING-PATH.md`, `LICENSE`).
- Templates (`templates/lab/`, `templates/section/`).
- Tooling (`scripts/new-lab.sh`, `scripts/verify-lab.sh`, `scripts/list-labs.sh`).
- Shared `sandbox/todo-cli/` project.
- **Section 01 — Slash Commands** and **Section 02 — Memory**, three labs each.
- Stubs for sections 03–13.

[Unreleased]: https://github.com/duthaho/claude-in-action/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/duthaho/claude-in-action/releases/tag/v0.4.0
[0.3.0]: https://github.com/duthaho/claude-in-action/releases/tag/v0.3.0
[0.2.0]: https://github.com/duthaho/claude-in-action/releases/tag/v0.2.0
[0.1.0]: https://github.com/duthaho/claude-in-action/releases/tag/v0.1.0
