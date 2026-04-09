# Core Tenets

- **SIMPLE SIMPLE SIMPLE.** This is our mantra. Prioritize unbraided, simple code above all else.
- **Avoid unnecessary abstraction like the plague.** If it doesn't need a trait, don't make one. If it doesn't need a wrapper, don't wrap it. Write the obvious thing.
- **Repetition over coupling.** It's OK to repeat yourself. Prefer context files that semantically link similar implementations over coupling different project pieces together. Independent pieces stay independent.
- **No cleverness.** If a junior dev can't read it and understand it in 30 seconds, it's too clever.

# Development Rules

- Always write tests for EVERYTHING. No exceptions.
- Always run tests after making a batch of changes. Never skip this.
- Be comprehensive in testing. Too many tests >> too few tests. Test happy paths, edge cases, error cases, and boundary conditions.
- Run tests with: `nvim --headless -c "PlenaryBustedDirectory tests/"`

# Project Structure

- `lua/scrawl/` — Neovim plugin source (Lua)
- `skills/` — Claude Code skill definitions (Markdown)
- `specs/` — Planning specs written by the `/plan` skill
- `tests/` — Plenary busted tests for the Neovim plugin

# Conventions

- One module per file
- Modules return a table `M` with public functions
- Module-level locals for state
- No global state
- Use native Neovim APIs (`vim.api.*`, `vim.fn.*`) over plenary wrappers where possible
