describe("note", function()
  local send

  before_each(function()
    -- clear module cache to get fresh instances
    package.loaded["claude-plan.note"] = nil
    package.loaded["claude-plan.send"] = nil
    send = require("claude-plan.send")
  end)

  describe("capture", function()
    it("sends formatted note to terminal when text provided", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback("this is a test note") end

      require("claude-plan.note").capture()

      vim.ui.input = original_input

      assert.are.equal(1, #sent)
      assert.is_truthy(sent[1]:find("/note"))
      assert.is_truthy(sent[1]:find("this is a test note"))
    end)

    it("sends context-only note when empty text provided", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback("") end

      require("claude-plan.note").capture()

      vim.ui.input = original_input

      assert.are.equal(1, #sent)
      assert.is_truthy(sent[1]:find("/note"))
      assert.is_truthy(sent[1]:find("%[.*:%d+%]"))
    end)

    it("sends context-only note when nil input (cancelled)", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback(nil) end

      require("claude-plan.note").capture()

      vim.ui.input = original_input

      assert.are.equal(1, #sent)
      assert.is_truthy(sent[1]:find("/note"))
    end)

    it("includes file and line context in note", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback("test") end

      require("claude-plan.note").capture()

      vim.ui.input = original_input

      assert.are.equal(1, #sent)
      assert.is_truthy(sent[1]:find("%[.*:%d+%]"))
    end)
  end)
end)
