local M = {}

function M.setup(opts)
  opts = opts or {}
  require("scrawl.window").configure(opts)
end

function M.toggle() return require("scrawl.window").toggle() end
function M.question() return require("scrawl.send").question() end
function M.note() return require("scrawl.note").capture() end
function M.plan()
  local send = require("scrawl.send")
  local window = require("scrawl.window")
  -- start terminal if not running
  if not window.get_chan() then window.toggle() end
  vim.ui.input({ prompt = "Jira URL, doc URL, or topic: " }, function(subject)
    if not subject or subject == "" then return end
    send.text("/scrawl:plan " .. subject)
    window.show()
  end)
end
function M.target()
  local send = require("scrawl.send")
  local target = require("scrawl.target")
  local window = require("scrawl.window")
  local current = vim.fn.expand("%:p")
  local default = current:match("%.md$") and current or (target.get() or "")
  vim.ui.input({ prompt = "Scrawl document: ", default = default, completion = "file" }, function(path)
    if not path or path == "" then return end
    local full = target.set(path)
    if not full then return end
    if not window.get_chan() then window.toggle() end
    send.text("/scrawl:target " .. full)
    window.show()
  end)
end
function M.untarget() return require("scrawl.target").unset() end
function M.decision() return require("scrawl.note").decision() end
function M.notes() return require("scrawl.specs").open_notes() end
function M.spec() return require("scrawl.send").text("/scrawl:spec") end
function M.specs() return require("scrawl.specs").pick() end
function M.clear() return require("scrawl.send").clear() end
function M.reload()
  local window = require("scrawl.window")
  window.stop()
  vim.fn.jobstart({ "claude", "plugin", "update", "scrawl.nvim" }, {
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          print("scrawl: plugin updated, starting new session")
        else
          print("scrawl: plugin update failed, starting new session anyway")
        end
        window.toggle()
      end)
    end,
  })
end
function M.stop() return require("scrawl.window").stop() end
function M.status() return require("scrawl.window").status() end

return M
