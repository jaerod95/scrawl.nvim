local context = require("claude-plan.context")
local send = require("claude-plan.send")

local M = {}

function M.capture()
  local ctx = context.get()

  vim.ui.input({ prompt = "Note: " }, function(input)
    if input and input ~= "" then
      send.text(string.format("/note [%s:%d] %s", ctx.file, ctx.line, input))
    else
      send.text(string.format("/note [%s:%d]", ctx.file, ctx.line))
    end
  end)
end

function M.decision()
  local ctx = context.get()

  vim.ui.input({ prompt = "Decision: " }, function(input)
    if not input or input == "" then return end
    send.text(string.format("/decision [%s:%d] %s", ctx.file, ctx.line, input))
  end)
end

return M
