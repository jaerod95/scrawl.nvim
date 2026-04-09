local M = {}

function M.get()
  local file = vim.fn.expand("%:~:.")
  local line = vim.fn.line(".")
  local selection = nil

  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd('noautocmd normal! "vy')
    selection = vim.fn.getreg("v")
    vim.fn.setreg("v", "")
  end

  return { file = file, line = line, selection = selection }
end

return M
