local M = {}

function M.setup() end

function M.toggle() return require("claude-plan.window").toggle() end
function M.question() return require("claude-plan.send").question() end
function M.note() return require("claude-plan.note").capture() end
function M.spec() return require("claude-plan.send").text("/spec") end
function M.specs() return require("claude-plan.specs").pick() end
function M.clear() return require("claude-plan.send").clear() end
function M.stop() return require("claude-plan.window").stop() end
function M.status() return require("claude-plan.window").status() end

return M
