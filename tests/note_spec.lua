describe("note", function()
  local send

  before_each(function()
    -- clear module cache to get fresh instances
    package.loaded["scrawl.note"] = nil
    package.loaded["scrawl.send"] = nil
    send = require("scrawl.send")
  end)

  describe("capture", function()
    it("sends formatted note to terminal when text provided", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback("this is a test note") end

      require("scrawl.note").capture()

      vim.ui.input = original_input

      assert.are.equal(1, #sent)
      assert.is_truthy(sent[1]:find("/scrawl%-note"))
      assert.is_truthy(sent[1]:find("this is a test note"))
    end)

    it("sends context-only note when empty text provided", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback("") end

      require("scrawl.note").capture()

      vim.ui.input = original_input

      assert.are.equal(1, #sent)
      assert.is_truthy(sent[1]:find("/scrawl%-note"))
      assert.is_truthy(sent[1]:find("%[.*:%d+%]"))
    end)

    it("sends context-only note when nil input (cancelled)", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback(nil) end

      require("scrawl.note").capture()

      vim.ui.input = original_input

      assert.are.equal(1, #sent)
      assert.is_truthy(sent[1]:find("/scrawl%-note"))
    end)

    it("includes file and line context in note", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback("test") end

      require("scrawl.note").capture()

      vim.ui.input = original_input

      assert.are.equal(1, #sent)
      assert.is_truthy(sent[1]:find("%[.*:%d+%]"))
    end)

    it("includes code block with selection when in visual mode", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      -- mock context to simulate visual selection
      package.loaded["scrawl.context"] = nil
      local context = require("scrawl.context")
      local original_get = context.get
      context.get = function()
        return { file = "models/review/index.js", line = 10, selection = "const x = 1;", start_line = 10, end_line = 12 }
      end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback("this needs refactoring") end

      require("scrawl.note").capture()

      vim.ui.input = original_input
      context.get = original_get

      assert.are.equal(1, #sent)
      assert.is_truthy(sent[1]:find("10%-12"))
      assert.is_truthy(sent[1]:find("```javascript"))
      assert.is_truthy(sent[1]:find("const x = 1;"))
      assert.is_truthy(sent[1]:find("this needs refactoring"))
    end)

    it("includes code block without note text when selection and empty input", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      package.loaded["scrawl.context"] = nil
      local context = require("scrawl.context")
      local original_get = context.get
      context.get = function()
        return { file = "index.js", line = 5, selection = "return true;", start_line = 5, end_line = 5 }
      end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback("") end

      require("scrawl.note").capture()

      vim.ui.input = original_input
      context.get = original_get

      assert.are.equal(1, #sent)
      assert.is_truthy(sent[1]:find("```javascript"))
      assert.is_truthy(sent[1]:find("return true;"))
    end)

    it("includes language tag for lua files", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      package.loaded["scrawl.context"] = nil
      local context = require("scrawl.context")
      local original_get = context.get
      context.get = function()
        return { file = "lua/init.lua", line = 1, selection = "local M = {}", start_line = 1, end_line = 1 }
      end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback("") end

      require("scrawl.note").capture()

      vim.ui.input = original_input
      context.get = original_get

      assert.are.equal(1, #sent)
      assert.is_truthy(sent[1]:find("```lua"))
    end)

    it("uses empty language tag for unknown extensions", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      package.loaded["scrawl.context"] = nil
      local context = require("scrawl.context")
      local original_get = context.get
      context.get = function()
        return { file = "data.xyz", line = 1, selection = "stuff", start_line = 1, end_line = 1 }
      end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback("") end

      require("scrawl.note").capture()

      vim.ui.input = original_input
      context.get = original_get

      assert.are.equal(1, #sent)
      -- should have ``` followed by newline (no language)
      assert.is_truthy(sent[1]:find("```\nstuff"))
    end)
  end)

  describe("decision", function()
    it("sends formatted decision to terminal", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback("use boolean field") end

      require("scrawl.note").decision()

      vim.ui.input = original_input

      assert.are.equal(1, #sent)
      assert.is_truthy(sent[1]:find("/scrawl%-decision"))
      assert.is_truthy(sent[1]:find("use boolean field"))
      assert.is_truthy(sent[1]:find("%[.*:%d+%]"))
    end)

    it("does nothing when input is cancelled", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback(nil) end

      require("scrawl.note").decision()

      vim.ui.input = original_input

      assert.are.equal(0, #sent)
    end)

    it("does nothing when input is empty", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback("") end

      require("scrawl.note").decision()

      vim.ui.input = original_input

      assert.are.equal(0, #sent)
    end)

    it("includes code block with selection when in visual mode", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      package.loaded["scrawl.context"] = nil
      local context = require("scrawl.context")
      local original_get = context.get
      context.get = function()
        return { file = "src/auth.ts", line = 20, selection = "if (!token) return;", start_line = 20, end_line = 22 }
      end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback("remove this guard") end

      require("scrawl.note").decision()

      vim.ui.input = original_input
      context.get = original_get

      assert.are.equal(1, #sent)
      assert.is_truthy(sent[1]:find("/scrawl%-decision"))
      assert.is_truthy(sent[1]:find("20%-22"))
      assert.is_truthy(sent[1]:find("```typescript"))
      assert.is_truthy(sent[1]:find("if %(!token%) return;"))
      assert.is_truthy(sent[1]:find("remove this guard"))
    end)

    it("does nothing in visual mode when input is cancelled", function()
      local sent = {}
      send.text = function(str) table.insert(sent, str) end

      package.loaded["scrawl.context"] = nil
      local context = require("scrawl.context")
      local original_get = context.get
      context.get = function()
        return { file = "src/auth.ts", line = 20, selection = "if (!token) return;", start_line = 20, end_line = 22 }
      end

      local original_input = vim.ui.input
      vim.ui.input = function(_, callback) callback(nil) end

      require("scrawl.note").decision()

      vim.ui.input = original_input
      context.get = original_get

      assert.are.equal(0, #sent)
    end)
  end)
end)
