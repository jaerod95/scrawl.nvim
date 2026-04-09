local context = require("claude-plan.context")
local response = require("claude-plan.response")
local window = require("claude-plan.window")

local M = {}

local should_continue = false

local function build_prompt(ctx, input)
  if ctx.selection then
    return string.format("[context: %s:%d]\n```\n%s\n```\n%s", ctx.file, ctx.line, ctx.selection, input)
  end
  return string.format("[context: %s:%d] %s", ctx.file, ctx.line, input)
end

function M.text(str)
  local chan = window.get_chan()
  if not chan then
    return print("claude-plan: no active session. Start with toggle() first")
  end
  vim.api.nvim_chan_send(chan, str .. "\n")
end

function M.question()
  local ctx = context.get()

  vim.ui.input({ prompt = "Question: " }, function(input)
    if not input or input == "" then return end

    local prompt = build_prompt(ctx, input)
    local display = ctx.selection
      and string.format("[%s:%d] (with selection) %s", ctx.file, ctx.line, input)
      or string.format("[%s:%d] %s", ctx.file, ctx.line, input)

    response.open(display)

    local cmd = { "claude", "--print" }
    if should_continue then
      table.insert(cmd, "--continue")
    end
    table.insert(cmd, "-p")
    table.insert(cmd, prompt)

    vim.fn.jobstart(cmd, {
      stdout_buffered = false,
      on_stdout = function(_, data)
        if data then
          response.append(data)
        end
      end,
      on_exit = function()
        should_continue = true
      end,
    })
  end)
end

function M.clear()
  should_continue = false
  print("claude-plan: session cleared")
end

return M
