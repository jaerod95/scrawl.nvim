local M = {}

function M.get()
  local file = vim.fn.expand("%:~:.")
  local line = vim.fn.line(".")
  local selection = nil
  local start_line = nil
  local end_line = nil

  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd('noautocmd normal! "vy')
    selection = vim.fn.getreg("v")
    vim.fn.setreg("v", "")
    start_line = vim.fn.line("'<")
    end_line = vim.fn.line("'>")
  end

  return { file = file, line = line, selection = selection, start_line = start_line, end_line = end_line }
end

return M
