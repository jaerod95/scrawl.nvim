local M = {}

local specs_root = vim.fn.expand("~/.scrawl/specs")

local function get_repo_name()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if not git_root or git_root == "" then return nil end
  return vim.fn.fnamemodify(git_root, ":t")
end

local function open_float(filepath)
  local lines = {}
  local f = io.open(filepath, "r")
  if not f then return end
  for line in f:lines() do
    table.insert(lines, line)
  end
  f:close()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.8))
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    border = "rounded",
    title = " " .. vim.fn.fnamemodify(filepath, ":t:r") .. " ",
    title_pos = "center",
    style = "minimal",
  })

  vim.wo[win].wrap = true

  vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
    callback = function() vim.api.nvim_win_close(win, true) end,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
    callback = function() vim.api.nvim_win_close(win, true) end,
    silent = true,
  })
end

function M.pick()
  local repo = get_repo_name()
  if not repo then
    return print("scrawl: not in a git repository")
  end

  local spec_dir = specs_root .. "/" .. repo
  if vim.fn.isdirectory(spec_dir) == 0 then
    return print("scrawl: no specs found for " .. repo)
  end

  require("telescope.builtin").find_files({
    prompt_title = "Specs (" .. repo .. ")",
    cwd = spec_dir,
    attach_mappings = function(_, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      map("i", "<CR>", function(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry then
          open_float(spec_dir .. "/" .. entry[1])
        end
      end)

      return true
    end,
  })
end

function M.open_notes()
  local repo = get_repo_name()
  if not repo then
    return print("scrawl: not in a git repository")
  end

  local spec_dir = specs_root .. "/" .. repo
  local result = vim.fn.systemlist("find " .. spec_dir .. " -name notes.md -type f -exec ls -t {} + 2>/dev/null")
  if #result == 0 or result[1] == "" then
    return print("scrawl: no notes found for " .. repo)
  end

  vim.cmd("edit " .. result[1])
end

return M
