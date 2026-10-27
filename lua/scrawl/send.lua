local context = require("scrawl.context")
local window = require("scrawl.window")

local M = {}

-- Claude Code coalesces a single fast stdin write into a paste, so a trailing
-- \r lands as a literal newline instead of submitting. Send the payload as a
-- bracketed paste, then submit with a separate keypress write.
local submit_delay = 120

-- How long to wait for a freshly started session to draw its prompt.
local ready_poll = 100
local ready_timeout = 15000
-- Extra settle time after the prompt appears, before input is accepted.
local ready_settle = 300

local function submit(chan, str)
  vim.api.nvim_chan_send(chan, "\27[200~" .. str .. "\27[201~")
  vim.defer_fn(function()
    vim.api.nvim_chan_send(chan, "\r")
  end, submit_delay)
end

-- Calls fn with the active channel, starting a session first if none is
-- running and waiting until Claude Code is ready for input.
local function with_session(fn)
  local chan = window.get_chan()
  if chan then return fn(chan) end

  chan = window.start()
  local waited = 0
  local function poll()
    if window.get_chan() ~= chan then return end
    if window.is_ready() then
      return vim.defer_fn(function() fn(chan) end, ready_settle)
    end
    if waited >= ready_timeout then
      return print("scrawl: timed out waiting for Claude Code to start")
    end
    waited = waited + ready_poll
    vim.defer_fn(poll, ready_poll)
  end
  poll()
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
  with_session(function(chan) submit(chan, str) end)
end

function M.question()
  local ctx = context.get()

  vim.ui.input({ prompt = "Question: " }, function(input)
    if not input or input == "" then return end

    with_session(function(chan)
      submit(chan, build_prompt(ctx, input))
      window.show()
    end)
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
