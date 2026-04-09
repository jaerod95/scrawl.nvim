local claude = require("claude-plan")

describe("claude-plan", function()
  describe("API surface", function()
    it("exports setup function", function()
      assert.is_function(claude.setup)
    end)

    it("exports toggle function", function()
      assert.is_function(claude.toggle)
    end)

    it("exports question function", function()
      assert.is_function(claude.question)
    end)

    it("exports note function", function()
      assert.is_function(claude.note)
    end)

    it("exports decision function", function()
      assert.is_function(claude.decision)
    end)

    it("exports notes function", function()
      assert.is_function(claude.notes)
    end)

    it("exports spec function", function()
      assert.is_function(claude.spec)
    end)

    it("exports specs function", function()
      assert.is_function(claude.specs)
    end)

    it("exports clear function", function()
      assert.is_function(claude.clear)
    end)

    it("exports stop function", function()
      assert.is_function(claude.stop)
    end)

    it("exports status function", function()
      assert.is_function(claude.status)
    end)
  end)

  describe("setup", function()
    it("does not error", function()
      assert.has_no.errors(function()
        claude.setup()
      end)
    end)

    it("can be called multiple times", function()
      assert.has_no.errors(function()
        claude.setup()
        claude.setup()
      end)
    end)
  end)
end)
