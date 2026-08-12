local function with_notify(opts, fn)
  local notified = {}

  package.loaded["scrawl.window"] = nil
  local window = require("scrawl.window")
  local original_is_focused = window.is_focused
  window.is_focused = function() return opts.focused == true end

  local original_notify = vim.notify
  vim.notify = function(msg, level, o) table.insert(notified, { msg = msg, level = level, opts = o }) end

  local original_readable = vim.fn.filereadable
  local original_readfile = vim.fn.readfile
  vim.fn.filereadable = function() return opts.summary and 1 or 0 end
  vim.fn.readfile = function() return { opts.summary or "" } end

  package.loaded["scrawl.notify"] = nil
  fn(require("scrawl.notify"))

  vim.fn.readfile = original_readfile
  vim.fn.filereadable = original_readable
  vim.notify = original_notify
  window.is_focused = original_is_focused

  return notified
end

describe("notify", function()
  it("notifies with the response summary", function()
    local notified = with_notify({ summary = "Added the Stop hook" }, function(mod) mod.done() end)

    assert.are.equal(1, #notified)
    assert.are.equal("Added the Stop hook", notified[1].msg)
    assert.are.equal("scrawl", notified[1].opts.title)
  end)

  it("falls back to a generic message when there is no summary", function()
    local notified = with_notify({}, function(mod) mod.done() end)

    assert.are.equal(1, #notified)
    assert.are.equal("Claude finished", notified[1].msg)
  end)

  it("falls back when the summary file is empty", function()
    local notified = with_notify({ summary = "   " }, function(mod) mod.done() end)

    assert.are.equal(1, #notified)
    assert.are.equal("Claude finished", notified[1].msg)
  end)

  it("truncates long summaries", function()
    local notified = with_notify({ summary = string.rep("x", 500) }, function(mod) mod.done() end)

    assert.are.equal(120, #notified[1].msg)
    assert.is_truthy(notified[1].msg:find("%.%.%.$"))
  end)

  it("stays quiet when the scrawl window is focused", function()
    local notified = with_notify({ focused = true, summary = "done" }, function(mod) mod.done() end)

    assert.are.equal(0, #notified)
  end)

  it("returns an empty string so --remote-expr has something to print", function()
    local result
    with_notify({ summary = "done" }, function(mod) result = mod.done() end)

    assert.are.equal("", result)
  end)
end)
