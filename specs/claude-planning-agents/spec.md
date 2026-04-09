# Claude Planning Agents

## Overview

A personal toolkit for Jira-driven codebase planning sessions. Combines a Neovim plugin (harpoon-style popup for Claude Code with context-aware quick actions) with a Claude Code `/plan` skill that fetches Jira tickets, guides codebase exploration, captures notes automatically, and writes specs to Obsidian.

## Deliverables

1. **Neovim plugin** (`claude-plan`) — harpoon-style popup, quick action response windows, context-aware commands
2. **`/plan` skill** — planning workflow with Jira fetching, note capture, spec writing
3. **Repo reference files** — api-gateway and integration-hub codebase patterns
4. **Plugin registration** — registered as a Claude Code plugin via `installed_plugins.json`
5. **Obsidian symlink** — specs directory symlinked into Obsidian vault

---

## 1. Neovim Plugin (`claude-plan`)

### Location

```
~/Documents/work/my-claude-agents/lua/claude-plan/
```

Installed via lazy.nvim as a local plugin in `~/.dotfiles/nvim/lua/config/lazy.lua`:

```lua
{ dir = "~/Documents/work/my-claude-agents" },
```

Plugin config loaded in `~/.dotfiles/nvim/lua/plugins/claude-plan.lua`:

```lua
require("claude-plan").setup()
```

### Files

```
lua/claude-plan/
├── init.lua         # setup(), public API surface
├── window.lua       # Harpoon-style floating terminal window
├── response.lua     # Quick action response floating window
├── send.lua         # Send commands to Claude (terminal + --print)
├── note.lua         # Capture note with file:line context
├── context.lua      # Capture current file/line/selection context
└── specs.lua        # Telescope picker for browsing specs
```

### Public API

```lua
local claude = require("claude-plan")

claude.setup()       -- initialize (does NOT start Claude)
claude.toggle()      -- toggle full Claude Code terminal popup
claude.question()    -- quick action: question with file/line/selection context
claude.note()        -- quick action: note with file/line context
claude.spec()        -- tell Claude to write the spec
claude.specs()       -- telescope picker to browse/open specs
claude.clear()       -- reset the quick action session (drop --continue)
claude.stop()        -- kill the Claude terminal process
claude.status()      -- returns "running" | "stopped" | nil
```

`setup()` just initializes state. It does not register keybindings — the user binds these functions in their own keymap config however they want. For example:

```lua
local claude = require("claude-plan")
map("n", "<leader>cc", claude.toggle, "[C]laude [C]ode toggle")
map("n", "<leader>cq", claude.question, "[C]laude [Q]uestion")
-- etc.
```

### Architecture: Two Modes of Interaction

The plugin has two distinct ways to interact with Claude:

**1. Full Terminal (interactive mode)**
- A persistent Claude Code process running in a hidden terminal buffer
- Shown/hidden via `toggle()` in a harpoon-style centered floating window
- User can type directly to Claude, use slash commands, have full conversations
- This is the escape hatch — full power, no guardrails

**2. Quick Actions (one-shot mode)**
- `question()` and `note()` use `claude --print --continue` via `vim.fn.jobstart()`
- Each call continues the same conversation (shared context across quick actions)
- Output streams into a small floating response window (not the terminal)
- `clear()` resets by dropping the `--continue` flag on the next call
- These are fast, contextual, and don't require the full terminal to be open

The two modes are **independent sessions**. The full terminal has its own conversation; quick actions share a separate conversation via `--continue`.

---

### `init.lua` — Setup and API

Exports the public API table. `setup()` initializes module state (no-op if already initialized). Each public function delegates to the appropriate module.

```lua
local M = {}

function M.setup()
  -- Initialize state, nothing else
end

function M.toggle() return require("claude-plan.window").toggle() end
function M.question() return require("claude-plan.send").question() end
function M.note() return require("claude-plan.note").capture() end
function M.spec() return require("claude-plan.send").text("/spec") end
function M.specs() return require("claude-plan.specs").pick() end
function M.clear() return require("claude-plan.send").clear() end
function M.stop() return require("claude-plan.window").stop() end
function M.status() return require("claude-plan.window").status() end

return M
```

---

### `context.lua` — Capture Current Editor Context

Shared utility used by `send.lua` and `note.lua` to capture what the user is looking at.

**`get()`** returns a table:
```lua
{
  file = "procedures/reviews/create-review/index.js",  -- project-relative path
  line = 42,                                             -- cursor line number
  selection = "const review = pipe({...})",              -- visual selection text or nil
}
```

**Implementation:**
- `file` — `vim.fn.expand("%:~:.")` (project-relative path)
- `line` — `vim.fn.line(".")`
- `selection` — if in visual mode, get text between `'<` and `'>` marks via `vim.fn.getline()` and `vim.fn.getpos()`. Returns nil in normal mode.

---

### `window.lua` — Full Terminal Floating Window

Manages a persistent Claude Code terminal session in a centered floating window. The terminal buffer stays alive when hidden — toggling just shows/hides the window.

**Module-level state:**
```lua
local buf = nil    -- terminal buffer number
local win = nil    -- window ID (nil when hidden)
local chan = nil   -- terminal job channel ID
```

**`toggle()`:**
1. If `win` is valid and visible → close the window (`vim.api.nvim_win_close(win, true)`), set `win = nil`. Buffer and process stay alive.
2. If `buf` is valid but `win` is nil → create a new floating window pointing at the existing buffer. Enter terminal mode.
3. If `buf` is nil → create buffer via `vim.api.nvim_create_buf(false, true)`, open floating window, spawn Claude via `chan = vim.fn.termopen("claude")`. Register `TermClose` autocmd for cleanup. Enter terminal mode.

**Floating window config:**
```lua
local width = math.floor(vim.o.columns * 0.8)
local height = math.floor(vim.o.lines * 0.8)
local col = math.floor((vim.o.columns - width) / 2)
local row = math.floor((vim.o.lines - height) / 2)

win = vim.api.nvim_open_win(buf, true, {
  relative = "editor",
  width = width,
  height = height,
  col = col,
  row = row,
  border = "rounded",
  title = " Claude Code ",
  title_pos = "center",
  style = "minimal",
})
```

Window-local options after creation:
```lua
vim.wo[win].number = false
vim.wo[win].relativenumber = false
vim.wo[win].signcolumn = "no"
```

Enter terminal mode: `vim.cmd("startinsert")`

**`stop()`:**
- If `chan` is valid, `vim.fn.jobstop(chan)`
- Close window if open
- Clean up all state (`buf`, `win`, `chan` = nil)

**`status()`:**
- If `chan` and `vim.fn.jobwait({chan}, 0)[1] == -1` → return `"running"`
- If `chan` exists but job finished → return `"stopped"`
- Otherwise → return `nil`

**Cleanup autocmd:**
```lua
vim.api.nvim_create_autocmd("TermClose", {
  buffer = buf,
  callback = function()
    buf, win, chan = nil, nil, nil
  end,
})
```

**Exported:** `toggle()`, `stop()`, `status()`, `get_chan()`, `get_buf()`

---

### `response.lua` — Quick Action Response Window

A floating window that shows the question and Claude's streamed response. Starts small, auto-expands as content arrives, caps at 80% editor height then scrolls.

**Module-level state:**
```lua
local buf = nil
local win = nil
```

**`open(question)`:**
1. Create a scratch buffer: `buf = vim.api.nvim_create_buf(false, true)`
2. Set buffer options: `bufhidden = "wipe"`, `filetype = "markdown"`
3. Write the question to the buffer:
   ```
   ## Question
   {question text}

   ## Response
   ```
4. Calculate initial window size:
   - Width: 80% of editor width
   - Height: number of question lines + 4 (header + padding)
   - Centered horizontally, positioned in upper third vertically
5. Open float: `vim.api.nvim_open_win(buf, true, opts)`
6. Set buffer keymaps: `q` and `<Esc>` to close

**`append(text)`:**
1. Append text to the buffer via `vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)`
2. Recalculate desired height based on total line count
3. If desired height > current height and under 80% cap:
   - Resize window: `vim.api.nvim_win_set_height(win, new_height)`
4. Scroll to bottom: `vim.api.nvim_win_set_cursor(win, {line_count, 0})`

**`close()`:**
- Close window if valid, wipe buffer
- Reset state

**Max height:** `math.floor(vim.o.lines * 0.8)`

**Exported:** `open(question)`, `append(text)`, `close()`

---

### `send.lua` — Send Commands to Claude

Handles both quick action one-shots and sending text to the full terminal.

**Module-level state:**
```lua
local should_continue = false   -- whether to use --continue on next quick action
```

**`text(str)`:**
Sends text to the full terminal session.
1. Get channel from `window.get_chan()`
2. If no channel, print error: `"claude-plan: no active session. Start with toggle() first"`
3. Send: `vim.api.nvim_chan_send(chan, str .. "\n")`

**`question()`:**
Quick action using `claude --print`.
1. Get context via `require("claude-plan.context").get()`
2. Prompt for question: `vim.ui.input({ prompt = "Question: " }, callback)`
3. If no input, return
4. Build the prompt string:
   - With selection: `"[context: {file}:{line}]\n```\n{selection}\n```\n{input}"`
   - Without selection: `"[context: {file}:{line}] {input}"`
5. Open response window: `response.open(display_text)` where `display_text` shows the formatted question
6. Build command:
   ```lua
   local cmd = { "claude", "--print" }
   if should_continue then
     table.insert(cmd, "--continue")
   end
   table.insert(cmd, "-p")
   table.insert(cmd, prompt)
   ```
7. Start job:
   ```lua
   vim.fn.jobstart(cmd, {
     stdout_buffered = false,
     on_stdout = function(_, data)
       if data then
         response.append(data)
       end
     end,
     on_exit = function()
       should_continue = true  -- next call will continue this conversation
     end,
   })
   ```

**`clear()`:**
- Set `should_continue = false`
- Print: `"claude-plan: session cleared"`

**Exported:** `text(str)`, `question()`, `clear()`

---

### `note.lua` — Capture Notes with Context

**`capture()`:**
1. Get context via `require("claude-plan.context").get()`
2. Prompt: `vim.ui.input({ prompt = "Note: " }, callback)`
3. If user provided text → send via `send.text()`:
   - Format: `"/note [{file}:{line}] {user_input}"`
4. If user hit enter with no text → send context-only note:
   - Format: `"/note [{file}:{line}]"`

Note: `note.capture()` sends to the **full terminal** (not `--print`), since notes are part of the planning session managed by the `/plan` skill running in the terminal.

---

### `specs.lua` — Telescope Spec Picker

Opens a Telescope picker over all specs for the current repo.

**`pick()`:**
1. Determine current repo name from `vim.fn.getcwd()` (basename of the git root)
2. Spec directory: `~/.claude-plan/specs/{repo}/`
3. If directory doesn't exist, print message and return
4. Use `telescope.builtin.find_files` scoped to the spec directory:
   ```lua
   require("telescope.builtin").find_files({
     prompt_title = "Specs (" .. repo .. ")",
     cwd = spec_dir,
     find_command = { "find", ".", "-name", "*.md", "-type", "f" },
   })
   ```
5. Selecting a file opens it in a buffer

---

### Terminal Mode Behavior

When the full terminal popup is visible and focused, the user is in Neovim's terminal mode and types directly to Claude Code. `<C-b>` exits terminal mode (user's existing binding), then `toggle()` hides the popup to return to code.

---

## 2. Spec Storage

### Location

```
~/.claude-plan/
└── specs/
    └── {repo-name}/
        └── {ticket-id}/
            ├── notes.md
            └── spec.md
```

**Example:**
```
~/.claude-plan/
└── specs/
    ├── api-gateway/
    │   ├── CLAP-1234/
    │   │   ├── notes.md
    │   │   └── spec.md
    │   └── CLAP-5678/
    │       ├── notes.md
    │       └── spec.md
    └── integration-hub/
        └── CLAP-9012/
            ├── notes.md
            └── spec.md
```

- Keyed by **repo name**, not branch — a ticket might span branches
- Lives in home directory so specs persist across branch changes, checkouts, rebases
- Browsable via `specs()` Telescope picker
- Editable directly in any editor

### Obsidian Symlink

```bash
ln -s ~/.claude-plan/specs ~/Documents/ApplauseNotes/specs
```

All specs appear in Obsidian under `specs/`. Each ticket folder shows up as a nested note structure.

---

## 3. `/plan` Skill

### Location

```
~/Documents/work/my-claude-agents/skills/plan/SKILL.md
```

### Invocation

```
/plan https://applause.atlassian.net/browse/CLAP-1234
```

### Frontmatter

```yaml
---
name: plan
description: Use when starting a planning session for a Jira ticket. Takes a Jira URL, fetches the ticket, guides codebase exploration, captures notes, and writes a spec to Obsidian.
---
```

### Workflow

#### Phase 1 — Setup

1. **Parse the Jira URL** — extract ticket ID (e.g., `CLAP-1234`) from the URL
2. **Fetch the Jira ticket** — use the Atlassian MCP integration to retrieve:
   - Title, description, acceptance criteria
   - Subtasks
   - Comments (for additional context from teammates)
   - Status, assignee, priority
3. **Detect current repo** — determine which repo the user is working in from the current working directory. Read the matching reference file from `skills/plan/references/{repo-name}.md`
4. **Create spec folder** — create `~/.claude-plan/specs/{repo}/{ticket-id}/`
5. **Initialize notes file** — create `notes.md` with a header containing the ticket title, URL, and timestamp
6. **Present ticket summary** — display a concise summary of the ticket and ask: "Where do you want to start exploring?"

#### Phase 2 — Guided Exploration

The agent acts as a navigator and scribe. The user drives exploration; the agent follows.

**Responding to user requests:**
- "Show me the review model" → read the relevant model file, present it with file path and key details
- "How does the bonus pipe work?" → find and read the pipe, explain the flow
- "What calls this function?" → grep for usages, present results
- "Where is X used?" → search the codebase, present findings

**Automatic note capture (implicit):**
The agent watches for statements that sound like decisions, TODOs, or observations:
- "we'll need to add a field here" → captured as a note
- "this validator is wrong" → captured as a note
- "let's refactor this to use the new pattern" → captured as a note
- "I think we should..." → captured as a note

When capturing implicitly, the agent briefly confirms: `"Noted: {summary}"`

**Explicit note capture:**
- `/note {text}` — captures the note verbatim with any file context sent from Neovim
- `/decision {text}` — captures as a decision (prefixed with `DECISION:`)
- `/notes` — displays all captured notes so far, grouped by file

**Note format in `notes.md`:**

```markdown
## Notes

### models/review/index.js
- [10:32] Need to add `isDemo` field to the Review model
- [10:35] DECISION: Use boolean with default false, backfill via migration

### procedures/reviews/create-review/index.js
- [10:40] Validator needs to check demo flag before applying rate limits
- [10:42] The pipe flow: validate → find-location → calculate-rate → create-review
```

Notes are grouped by the file being discussed. Timestamps use HH:MM format. Each note is appended as captured (not batched).

#### Phase 3 — Spec Writing

Triggered by `/spec`, "write it up", "write the spec", "I'm done exploring", or similar.

1. **Read all captured notes** from `notes.md`
2. **Write `spec.md`** — organized into logical sections derived from the notes. Format is intentionally open-ended for now (will be standardized after real usage), but should generally include:
   - Ticket context (title, description, key acceptance criteria)
   - Files to change (with specific changes described)
   - New files to create
   - Migration needs
   - Testing considerations
   - Open questions or risks
3. **Present the spec** to the user for review
4. **Apply edits** if the user requests changes

---

## 4. Repo Reference Files

### Location

```
~/Documents/work/my-claude-agents/skills/plan/references/
├── api-gateway.md
└── integration-hub.md
```

### Purpose

Loaded by the `/plan` skill based on the detected working directory. Provides repo-specific knowledge for navigation and code pattern guidance.

### `api-gateway.md` — Key Patterns

- **File organization**: one function per file, all named `index.js`, organized in directories
- **Import conventions**: `#`-prefix aliases (`#models`, `#procedures`, `#services`, etc.), never relative parent imports
- **Pipe pattern**: `pipe({}).bind("async").flow(fn).runAsync()` — context threading, functional composition
- **Procedure structure**: `queries/`, `actions/`, `validators/`, each one function per file
- **App structure**: separate apps in `apps/` (integration-hub, public, internal, user, mobile, rate-services)
- **Models**: Sequelize-based, associations in `.associate()`, field definitions on single lines
- **Code style**: avoid async/await (except tests/migrations), inline single-use functions, alphabetical sorting, single-line objects
- **Testing**: Jest with `--runInBand`, factories via `#tests/factories`, `*.spec.js` naming
- **Key directories**: `models/`, `procedures/`, `queries/`, `services/`, `middleware/`, `helpers/`, `library/utils/`, `queues-v2/`, `scheduled-jobs/`

### `integration-hub.md` — Key Patterns

- **File organization**: one function per file in `index.js`, similar to api-gateway
- **Integration structure**: each integration has `actions/`, `specs/mocks/`, and an `initialize()` export
- **Build system**: Babel compilation (src → dist), CommonJS modules
- **Job processing**: BullMQ for job scheduling
- **Key directories**: `src/integrations/`, `src/library/packages/`, `src/library/services/`, `src/library/utils/`, `src/apps/`
- **Utility wrappers**: `src/library/packages/` wraps external libraries (bullmq, playwright, redis, undici, etc.)
- **Node version**: 22.x (vs api-gateway's 18.x)

---

## 5. Plugin Registration

### Repo Structure

```
~/Documents/work/my-claude-agents/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── plan/
│       ├── SKILL.md
│       └── references/
│           ├── api-gateway.md
│           └── integration-hub.md
└── lua/
    └── claude-plan/
        ├── init.lua
        ├── window.lua
        ├── response.lua
        ├── send.lua
        ├── note.lua
        ├── context.lua
        └── specs.lua
```

### `plugin.json`

```json
{
  "name": "my-claude-agents",
  "description": "Personal planning and implementation agents",
  "skills": "./skills/"
}
```

### Registration

Add entry to `~/.claude/plugins/installed_plugins.json` pointing to the local plugin directory. This makes the `/plan` skill available globally across all repos.

---

## Implementation Order

1. Create the repo (`my-claude-agents/`) and directory structure
2. Build the Neovim plugin:
   a. `context.lua` — editor context capture
   b. `window.lua` — full terminal floating window
   c. `response.lua` — quick action response window
   d. `send.lua` — terminal sending + `--print` quick actions
   e. `note.lua` — note capture
   f. `specs.lua` — Telescope picker
   g. `init.lua` — public API
3. Add lazy.nvim entry + plugin config in dotfiles
4. Write the repo reference files
5. Write the `/plan` skill (SKILL.md)
6. Register the Claude Code plugin
7. Create `~/.claude-plan/specs/` and Obsidian symlink
8. Test end-to-end with a real Jira ticket
