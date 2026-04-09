local M = {}

function M.setup(opts)
  opts = opts or {}
  require("claude-plan.window").configure(opts)
end

function M.toggle() return require("claude-plan.window").toggle() end
function M.question() return require("claude-plan.send").question() end
function M.note() return require("claude-plan.note").capture() end
function M.plan()
  local send = require("claude-plan.send")
  local window = require("claude-plan.window")
  -- start terminal if not running
  if not window.get_chan() then window.toggle() end
  vim.ui.input({ prompt = "Jira URL: " }, function(url)
    if not url or url == "" then return end
    send.text("/cp-plan " .. url)
    window.show()
  end)
end
function M.decision() return require("claude-plan.note").decision() end
function M.notes() return require("claude-plan.send").text("/notes") end
function M.spec() return require("claude-plan.send").text("/spec") end
function M.specs() return require("claude-plan.specs").pick() end
function M.clear() return require("claude-plan.send").clear() end
function M.stop() return require("claude-plan.window").stop() end
function M.status() return require("claude-plan.window").status() end

return M
