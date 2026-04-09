local context = require("claude-plan.context")
local send = require("claude-plan.send")

local M = {}

function M.capture()
  local ctx = context.get()

  if ctx.selection then
    local lines = string.format("%d-%d", ctx.start_line, ctx.end_line)
    local lang = context.lang(ctx.file)
    vim.ui.input({ prompt = "Note: " }, function(input)
      local note = input and input ~= "" and (input .. "\n") or ""
      send.text(string.format("/cp-note [%s:%s]\n%s```%s\n%s\n```", ctx.file, lines, note, lang, ctx.selection))
    end)
    return
  end

  vim.ui.input({ prompt = "Note: " }, function(input)
    if input and input ~= "" then
      send.text(string.format("/cp-note [%s:%d] %s", ctx.file, ctx.line, input))
    else
      send.text(string.format("/cp-note [%s:%d]", ctx.file, ctx.line))
    end
  end)
end

function M.decision()
  local ctx = context.get()

  if ctx.selection then
    local lines = string.format("%d-%d", ctx.start_line, ctx.end_line)
    local lang = context.lang(ctx.file)
    vim.ui.input({ prompt = "Decision: " }, function(input)
      if not input or input == "" then return end
      send.text(string.format("/cp-decision [%s:%s] %s\n```%s\n%s\n```", ctx.file, lines, input, lang, ctx.selection))
    end)
    return
  end

  vim.ui.input({ prompt = "Decision: " }, function(input)
    if not input or input == "" then return end
    send.text(string.format("/cp-decision [%s:%d] %s", ctx.file, ctx.line, input))
  end)
end

return M
