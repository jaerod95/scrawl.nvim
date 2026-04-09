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
    it("does not error", function()
      assert.has_no.errors(function()
        send.clear()
      end)
    end)

    it("prints confirmation message", function()
      local messages = {}
      local original_print = print
      _G.print = function(msg) table.insert(messages, msg) end

      send.clear()

      _G.print = original_print
      assert.are.equal(1, #messages)
      assert.is_truthy(messages[1]:find("session cleared"))
    end)
  end)
end)
