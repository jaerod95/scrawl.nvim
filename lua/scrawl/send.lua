local context = require("scrawl.context")
local window = require("scrawl.window")

local M = {}

local function build_prompt(ctx, input)
  local file_ref = string.format("@%s:%d", ctx.file, ctx.line)
  if ctx.selection then
    local lang = context.lang(ctx.file)
    return string.format("%s\n```%s\n%s\n```\n%s", file_ref, lang, ctx.selection, input)
  end
  return string.format("%s %s", file_ref, input)
end

function M.text(str)
  local chan = window.get_chan()
  if not chan then
    return print("scrawl: no active session. Start with toggle() first")
  end
  vim.api.nvim_chan_send(chan, str .. "\r")
end

function M.question()
  local chan = window.get_chan()
  if not chan then
    return print("scrawl: no active session. Start with toggle() first")
  end

  local ctx = context.get()

  vim.ui.input({ prompt = "Question: " }, function(input)
    if not input or input == "" then return end

    local prompt = build_prompt(ctx, input)
    local display = ctx.selection
      and string.format("[%s:%d] (with selection) %s", ctx.file, ctx.line, input)
      or string.format("[%s:%d] %s", ctx.file, ctx.line, input)

    vim.api.nvim_chan_send(chan, prompt .. "\r")
    window.show()
  end)
end

function M.clear()
  local chan = window.get_chan()
  if not chan then
    return print("scrawl: no active session. Start with toggle() first")
  end
  vim.api.nvim_chan_send(chan, "/clear\r")
  print("scrawl: session cleared")
end

return M
