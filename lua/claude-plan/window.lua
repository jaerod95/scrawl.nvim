local M = {}

local buf = nil
local win = nil
local chan = nil

local function create_float(target_buf)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  win = vim.api.nvim_open_win(target_buf, true, {
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

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
end

function M.toggle()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    win = nil
    return
  end

  if buf and vim.api.nvim_buf_is_valid(buf) then
    create_float(buf)
    vim.cmd("startinsert")
    return
  end

  buf = vim.api.nvim_create_buf(false, true)
  create_float(buf)

  chan = vim.fn.termopen("claude", {
    on_exit = function()
      buf, win, chan = nil, nil, nil
    end,
  })

  -- <C-b> exits terminal mode (user's existing binding), then normal-mode
  -- toggle keybinding hides the window. We also add a buffer-local normal-mode
  -- mapping so 'q' closes the window after exiting terminal mode.
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
    callback = M.toggle,
    silent = true,
  })

  vim.cmd("startinsert")
end

function M.stop()
  if chan then
    vim.fn.jobstop(chan)
  end
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  buf, win, chan = nil, nil, nil
end

function M.status()
  if not chan then return nil end
  if vim.fn.jobwait({ chan }, 0)[1] == -1 then return "running" end
  return "stopped"
end

function M.get_chan() return chan end
function M.get_buf() return buf end

return M
