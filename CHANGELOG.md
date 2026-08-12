# Changelog

All notable changes to scrawl.nvim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-08-12

### Added

- `target()` / `/scrawl:target` — point a session at any document you're already writing in. Notes, decisions, and the spec all land in that file instead of `~/.scrawl/specs/{repo}/{ticket}/notes.md`
- `untarget()` — clear the target and fall back to `~/.scrawl/specs`
- Per-repo target pointer at `~/.scrawl/targets/{repo-name}`, so different repos keep independent targets and the pointer survives restarts

### Changed

- `plan()` accepts a Jira URL, any other URL, or a plain topic. Non-Jira input starts a free-form session instead of trying to fetch a ticket
- `note`, `decision`, `notes`, and `spec` skills resolve the target pointer before falling back to the newest `notes.md`
- `notes()` opens the target document when one is set, with proper escaping for paths containing spaces
- SessionStart hook reports the target document when one is set
- `/scrawl:spec` organizes in place when working in a target document, and confirms before restructuring anything the user wrote

### Fixed

- `marketplace.json` pointed at a nonexistent `./plugins/scrawl` directory, which made the plugin impossible to install

## [0.2.0] - 2026-04-09

### Changed

- Renamed all skills from `cp-*` to `scrawl-*` namespace
- Genericized Jira integration (org is now configurable via `~/.scrawl/config.json`)
- Enriched plugin.json with full metadata (author, repository, license, keywords)
- Fixed YAML frontmatter in skill files
- Fixed broken markdown rendering in scrawl-note skill

### Added

- SessionStart hook that surfaces active planning session context to Claude
- Cross-platform hook support (Claude Code, Cursor, Copilot CLI)
- Demo gif in README

### Removed

- Legacy `my-claude-agents` plugin directory
- Repo-specific reference files (api-gateway, integration-hub)
- Old spec directory

## [0.1.0] - 2026-04-09

Initial public release.

### Added

- Floating terminal window for Claude Code with toggle, show/hide
- Question command with file context and visual selection support
- Note capture with file context, visual selection, and syntax-highlighted code blocks
- Decision capture with file context and visual selection support
- Planning sessions driven by Jira tickets (`/scrawl-plan`)
- Automatic note capture during planning sessions
- Spec generation from captured notes (`/scrawl-spec`)
- Telescope picker for browsing saved specs
- Notes file viewer (opens in editor)
- Session clear, stop, reload, and status commands
- Dedenting of visual selections to remove common leading whitespace
- Language detection for code fence syntax highlighting
- Claude Code skills for note, decision, notes, spec, and plan commands
- Full test suite with plenary busted
