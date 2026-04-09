local context = require("claude-plan.context")

describe("context", function()
  describe("get", function()
    it("returns a table with file, line, and selection keys", function()
      local result = context.get()
      assert.is_table(result)
      assert.is_not_nil(result.file)
      assert.is_not_nil(result.line)
    end)

    it("returns current file path", function()
      local result = context.get()
      assert.is_string(result.file)
    end)

    it("returns current line number", function()
      local result = context.get()
      assert.is_number(result.line)
      assert.is_true(result.line >= 1)
    end)

    it("returns nil selection in normal mode", function()
      local result = context.get()
      assert.is_nil(result.selection)
    end)

    it("returns nil start_line and end_line in normal mode", function()
      local result = context.get()
      assert.is_nil(result.start_line)
      assert.is_nil(result.end_line)
    end)
  end)

  describe("dedent", function()
    it("removes common leading whitespace", function()
      local input = "    hello\n    world"
      assert.are.equal("hello\nworld", context.dedent(input))
    end)

    it("preserves relative indentation", function()
      local input = "    if true\n      nested\n    end"
      assert.are.equal("if true\n  nested\nend", context.dedent(input))
    end)

    it("returns text unchanged when no common indent", function()
      local input = "hello\n  world"
      assert.are.equal("hello\n  world", context.dedent(input))
    end)

    it("returns single line unchanged when no indent", function()
      assert.are.equal("hello", context.dedent("hello"))
    end)

    it("removes common indent from single indented line", function()
      assert.are.equal("hello", context.dedent("        hello"))
    end)

    it("handles tabs", function()
      local input = "\t\thello\n\t\tworld"
      assert.are.equal("hello\nworld", context.dedent(input))
    end)

    it("handles mixed indent preserving relative depth", function()
      local input = "\t\tfunction()\n\t\t\treturn true\n\t\tend"
      assert.are.equal("function()\n\treturn true\nend", context.dedent(input))
    end)

    it("handles empty string", function()
      assert.are.equal("", context.dedent(""))
    end)
  end)
end)
