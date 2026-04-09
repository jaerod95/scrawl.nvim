local send = require("claude-plan.send")

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

    it("sends /clear to terminal and prints confirmation", function()
      local sent = {}
      package.loaded["claude-plan.window"] = nil
      local window = require("claude-plan.window")
      local original_get_chan = window.get_chan
      window.get_chan = function() return 42 end

      local original_chan_send = vim.api.nvim_chan_send
      vim.api.nvim_chan_send = function(chan, str) table.insert(sent, { chan = chan, str = str }) end

      local messages = {}
      local original_print = print
      _G.print = function(msg) table.insert(messages, msg) end

      package.loaded["claude-plan.send"] = nil
      require("claude-plan.send").clear()

      _G.print = original_print
      vim.api.nvim_chan_send = original_chan_send
      window.get_chan = original_get_chan

      assert.are.equal(1, #sent)
      assert.are.equal(42, sent[1].chan)
      assert.are.equal("/clear\r", sent[1].str)
      assert.are.equal(1, #messages)
      assert.is_truthy(messages[1]:find("session cleared"))
    end)
  end)
end)
