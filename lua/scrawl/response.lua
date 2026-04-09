local M = {}

local buf = nil
local win = nil

local function max_height()
  return math.floor(vim.o.lines * 0.8)
end

local function win_width()
  return math.floor(vim.o.columns * 0.8)
end

function M.open(question)
  if buf and vim.api.nvim_buf_is_valid(buf) then
    M.close()
  end

  buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"

  local lines = { "## Question", "", question, "", "## Response", "" }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = win_width()
  local height = math.min(#lines + 2, max_height())
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    border = "rounded",
    title = " Claude Response ",
    title_pos = "center",
    style = "minimal",
  })

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].wrap = true

  vim.api.nvim_buf_set_keymap(buf, "n", "q", "", { callback = M.close, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", { callback = M.close, silent = true })
end

function M.append(data)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end

  local lines = {}
  for _, chunk in ipairs(data) do
    if chunk ~= "" then
      for line in chunk:gmatch("[^\n]*") do
        table.insert(lines, line)
      end
    end
  end

  if #lines == 0 then return end

  vim.schedule(function()
    if not buf or not vim.api.nvim_buf_is_valid(buf) then return end

    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)

    if win and vim.api.nvim_win_is_valid(win) then
      local line_count = vim.api.nvim_buf_line_count(buf)
      local desired = math.min(line_count + 2, max_height())
      local current = vim.api.nvim_win_get_height(win)

      if desired > current then
        vim.api.nvim_win_set_height(win, desired)
      end

      vim.api.nvim_win_set_cursor(win, { line_count, 0 })
    end
  end)
end

function M.close()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  win = nil
  buf = nil
end

return M
