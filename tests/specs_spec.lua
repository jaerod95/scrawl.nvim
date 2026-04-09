local specs = require("claude-plan.specs")

describe("specs", function()
  describe("pick", function()
    it("prints error when not in a git repo", function()
      local original_systemlist = vim.fn.systemlist
      vim.fn.systemlist = function() return { "" } end

      local messages = {}
      local original_print = print
      _G.print = function(msg) table.insert(messages, msg) end

      specs.pick()

      _G.print = original_print
      vim.fn.systemlist = original_systemlist

      assert.are.equal(1, #messages)
      assert.is_truthy(messages[1]:find("not in a git repository"))
    end)

    it("prints error when no specs exist for repo", function()
      local original_systemlist = vim.fn.systemlist
      vim.fn.systemlist = function() return { "/tmp/fake-repo" } end

      local original_isdirectory = vim.fn.isdirectory
      vim.fn.isdirectory = function() return 0 end

      local messages = {}
      local original_print = print
      _G.print = function(msg) table.insert(messages, msg) end

      specs.pick()

      _G.print = original_print
      vim.fn.isdirectory = original_isdirectory
      vim.fn.systemlist = original_systemlist

      assert.are.equal(1, #messages)
      assert.is_truthy(messages[1]:find("no specs found"))
    end)
  end)
end)
