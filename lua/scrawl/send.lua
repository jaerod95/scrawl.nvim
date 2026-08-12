local context = require("scrawl.context")
local window = require("scrawl.window")

local M = {}

-- Claude Code coalesces a single fast stdin write into a paste, so a trailing
-- \r lands as a literal newline instead of submitting. Send the payload as a
-- bracketed paste, then submit with a separate keypress write.
local submit_delay = 120

local function submit(chan, str)
  vim.api.nvim_chan_send(chan, "\27[200~" .. str .. "\27[201~")
  vim.defer_fn(function()
    vim.api.nvim_chan_send(chan, "\r")
  end, submit_delay)
end

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
  submit(chan, str)
end

function M.question()
  local chan = window.get_chan()
  if not chan then
    return print("scrawl: no active session. Start with toggle() first")
  end

  local ctx = context.get()

  vim.ui.input({ prompt = "Question: " }, function(input)
    if not input or input == "" then return end

    submit(chan, build_prompt(ctx, input))
    window.show()
  end)
end

function M.clear()
  local chan = window.get_chan()
  if not chan then
    return print("scrawl: no active session. Start with toggle() first")
  end
  submit(chan, "/clear")
  print("scrawl: session cleared")
end

return M
