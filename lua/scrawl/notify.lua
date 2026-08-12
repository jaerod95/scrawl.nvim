local window = require("scrawl.window")

local M = {}

local summary_file = "~/.scrawl/last-response"

local function summary()
  local path = vim.fn.expand(summary_file)
  if vim.fn.filereadable(path) == 0 then return nil end

  local text = vim.trim(table.concat(vim.fn.readfile(path), " "))
  if text == "" then return nil end
  if #text > 120 then text = text:sub(1, 117) .. "..." end
  return text
end

function M.done()
  if window.is_focused() then return "" end

  local text = summary()
  vim.notify(text or "Claude finished", vim.log.levels.INFO, { title = "scrawl" })
  return ""
end

return M
