local send = require("scrawl.send")

-- Captures every nvim_chan_send call and runs deferred callbacks immediately,
-- so the paste write and the submit write are both observable.
local function with_session(fn)
  local sent = {}

  package.loaded["scrawl.window"] = nil
  local window = require("scrawl.window")
  local original_get_chan = window.get_chan
  window.get_chan = function() return 42 end

  local original_chan_send = vim.api.nvim_chan_send
  vim.api.nvim_chan_send = function(chan, str) table.insert(sent, { chan = chan, str = str }) end

  local original_defer = vim.defer_fn
  local delays = {}
  vim.defer_fn = function(cb, delay)
    table.insert(delays, delay)
    cb()
  end

  package.loaded["scrawl.send"] = nil
  fn(require("scrawl.send"))

  vim.defer_fn = original_defer
  vim.api.nvim_chan_send = original_chan_send
  window.get_chan = original_get_chan

  return sent, delays
end

describe("send", function()
  describe("text", function()
    it("prints error when no session is active", function()
      local messages = {}
      local original_print = print
      _G.print = function(msg) table.insert(messages, msg) end

      send.text("hello")

      _G.print = original_print
      assert.are.equal(1, #messages)
      assert.is_truthy(messages[1]:find("no active session"))
    end)

    it("wraps the payload in bracketed paste markers", function()
      local sent = with_session(function(mod) mod.text("hello") end)

      assert.are.equal(42, sent[1].chan)
      assert.are.equal("\27[200~hello\27[201~", sent[1].str)
    end)

    it("submits with a separate deferred carriage return", function()
      local sent, delays = with_session(function(mod) mod.text("hello") end)

      assert.are.equal(2, #sent)
      assert.are.equal("\r", sent[2].str)
      assert.are.equal(42, sent[2].chan)
      assert.are.equal(1, #delays)
      assert.is_true(delays[1] > 0)
    end)

    it("keeps multi-line payloads inside a single paste", function()
      local sent = with_session(function(mod) mod.text("line one\nline two") end)

      assert.are.equal(2, #sent)
      assert.are.equal("\27[200~line one\nline two\27[201~", sent[1].str)
      assert.are.equal("\r", sent[2].str)
    end)
  end)

  describe("clear", function()
    it("prints error when no session is active", function()
      local messages = {}
      local original_print = print
      _G.print = function(msg) table.insert(messages, msg) end

      send.clear()

      _G.print = original_print
      assert.are.equal(1, #messages)
      assert.is_truthy(messages[1]:find("no active session"))
    end)

    it("pastes and submits /clear, then prints confirmation", function()
      local messages = {}
      local original_print = print
      _G.print = function(msg) table.insert(messages, msg) end

      local sent = with_session(function(mod) mod.clear() end)

      _G.print = original_print

      assert.are.equal(2, #sent)
      assert.are.equal("\27[200~/clear\27[201~", sent[1].str)
      assert.are.equal("\r", sent[2].str)
      assert.are.equal(1, #messages)
      assert.is_truthy(messages[1]:find("session cleared"))
    end)
  end)
end)
