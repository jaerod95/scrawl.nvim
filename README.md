# scrawl.nvim

A Neovim plugin for collaborative planning sessions with [Claude Code](https://claude.ai/claude-code). Scrawl lets you explore codebases, capture notes, make decisions, and write specs — all from inside your editor with Claude as your pair programmer.

![scrawl.nvim demo](demo/scrawl-demo.gif)

## Features

- **Planning sessions** — Start a Jira-driven exploration session with Claude
- **Notes & decisions** — Capture notes and decisions with file context, including visual selections with syntax-highlighted code blocks
- **Specs** — Generate specs from your planning notes
- **Target any document** — Point a session at a doc you're already writing in and capture straight into it
- **Floating terminal** — Claude Code runs in a floating window you can toggle
- **Visual mode support** — Select code and send it as context with questions, notes, or decisions

## Requirements

- Neovim >= 0.9
- [Claude Code CLI](https://claude.ai/claude-code) installed
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (for spec browsing)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) (for tests)

## Installation

### lazy.nvim

```lua
{
  "jaerod95/scrawl.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("scrawl").setup()
  end,
}
```

### packer.nvim

```lua
use {
  "jaerod95/scrawl.nvim",
  requires = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("scrawl").setup()
  end,
}
```

## Setup

```lua
local scrawl = require("scrawl")

scrawl.setup({
  skip_permissions = true, -- pass --dangerously-skip-permissions to Claude (default: true)
})
```

## Keybindings

scrawl.nvim doesn't set any keybindings by default. Here's a suggested configuration:

```lua
local scrawl = require("scrawl")

vim.keymap.set("n", "<leader>cc", scrawl.toggle, { desc = "Toggle Claude Code" })
vim.keymap.set("n", "<leader>cq", scrawl.question, { desc = "Ask Claude a question" })
vim.keymap.set("v", "<leader>cq", scrawl.question, { desc = "Ask Claude with selection" })
vim.keymap.set("n", "<leader>cn", scrawl.note, { desc = "Capture a note" })
vim.keymap.set("v", "<leader>cn", scrawl.note, { desc = "Capture note with selection" })
vim.keymap.set("n", "<leader>cd", scrawl.decision, { desc = "Capture a decision" })
vim.keymap.set("v", "<leader>cd", scrawl.decision, { desc = "Capture decision with selection" })
vim.keymap.set("n", "<leader>cp", scrawl.plan, { desc = "Start planning from Jira URL, doc URL, or topic" })
vim.keymap.set("n", "<leader>ct", scrawl.target, { desc = "Target a document" })
vim.keymap.set("n", "<leader>ci", scrawl.notes, { desc = "Open notes file" })
vim.keymap.set("n", "<leader>cw", scrawl.spec, { desc = "Write spec from notes" })
vim.keymap.set("n", "<leader>cf", scrawl.specs, { desc = "Browse specs" })
vim.keymap.set("n", "<leader>cx", scrawl.clear, { desc = "Clear Claude session" })
vim.keymap.set("n", "<leader>ck", scrawl.stop, { desc = "Kill Claude process" })
vim.keymap.set("n", "<leader>cr", scrawl.reload, { desc = "Reload plugin and restart" })
```

## API

| Function | Description |
|---|---|
| `setup(opts)` | Initialize the plugin |
| `toggle()` | Toggle the Claude Code floating terminal |
| `question()` | Ask Claude a question (supports visual selection) |
| `note()` | Capture a planning note (supports visual selection) |
| `decision()` | Capture a planning decision (supports visual selection) |
| `plan()` | Start a planning session from a Jira URL, another URL, or a plain topic |
| `target()` | Point the session at a document to write notes into |
| `untarget()` | Clear the target document |
| `notes()` | Open the current session's notes file |
| `spec()` | Tell Claude to write a spec from captured notes |
| `specs()` | Browse specs with Telescope |
| `clear()` | Send /clear to the Claude session |
| `stop()` | Kill the Claude process |
| `reload()` | Update the plugin and restart Claude |
| `status()` | Get the current session status |

## Claude Code Skills

scrawl.nvim includes Claude Code skills that teach Claude how to handle the commands sent from Neovim:

- `/scrawl:plan` — Start a planning session from a Jira ticket
- `/scrawl:note` — Capture a note with file context
- `/scrawl:decision` — Capture a decision
- `/scrawl:notes` — Display captured notes
- `/scrawl:spec` — Write a spec from notes
- `/scrawl:target` — Point the session at a specific document

## Data Storage

Planning data is stored in `~/.scrawl/`:

```
~/.scrawl/
  config.json          # Jira credentials
  targets/
    {repo-name}        # Absolute path of this repo's target document, if set
  specs/
    {repo-name}/
      {ticket-id}/
        notes.md       # Captured notes
        spec.md        # Generated spec
```

## Targeting a document

By default a session writes to `~/.scrawl/specs/{repo}/{ticket}/notes.md`. When you're already
writing in a doc of your own, point the session at it instead:

```
<leader>ct  →  Scrawl document: ~/Documents/Notes/My Spike.md
```

The path is recorded in `~/.scrawl/targets/{repo-name}` and persists until you retarget or run
`untarget()`. While a target is set, `note`, `decision`, `notes`, and `spec` all resolve to that
file — notes append under `### {file}` groupings, and `spec()` organizes in place rather than
writing a sibling `spec.md`. Existing prose in the document is never restructured without
confirmation.

## License

MIT
