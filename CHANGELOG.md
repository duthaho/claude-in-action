# Changelog

All notable changes to `claude-in-action` are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versions use [Semantic Versioning](https://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/duthaho/claude-in-action/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/duthaho/claude-in-action/releases/tag/v0.1.0
