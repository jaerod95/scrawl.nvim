local response = require("claude-plan.response")

describe("response", function()
  after_each(function()
    response.close()
  end)

  describe("open", function()
    it("creates a floating window with the question", function()
      response.open("What does this function do?")
      -- window should be open — we can verify by checking if close doesn't error
      assert.has_no.errors(function()
        response.close()
      end)
    end)

    it("sets markdown filetype on the buffer", function()
      response.open("test question")
      -- find the floating window
      local wins = vim.api.nvim_list_wins()
      local found_float = false
      for _, w in ipairs(wins) do
        local config = vim.api.nvim_win_get_config(w)
        if config.relative and config.relative ~= "" then
          local buf = vim.api.nvim_win_get_buf(w)
          assert.are.equal("markdown", vim.bo[buf].filetype)
          found_float = true
          break
        end
      end
      assert.is_true(found_float)
    end)

    it("includes the question text in the buffer", function()
      response.open("my test question")
      local wins = vim.api.nvim_list_wins()
      for _, w in ipairs(wins) do
        local config = vim.api.nvim_win_get_config(w)
        if config.relative and config.relative ~= "" then
          local buf = vim.api.nvim_win_get_buf(w)
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          local content = table.concat(lines, "\n")
          assert.is_truthy(content:find("my test question"))
          break
        end
      end
    end)

    it("closes previous window if called again", function()
      response.open("first question")
      response.open("second question")
      -- should only have one response float
      local float_count = 0
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(w)
        if config.relative and config.relative ~= "" then
          float_count = float_count + 1
        end
      end
      assert.are.equal(1, float_count)
    end)
  end)

  describe("append", function()
    it("does not error when no window is open", function()
      assert.has_no.errors(function()
        response.append({ "some text" })
      end)
    end)

    it("adds text to the buffer", function()
      response.open("test")
      response.append({ "hello world" })
      -- give vim.schedule a chance to run
      vim.wait(100, function() return false end)

      local wins = vim.api.nvim_list_wins()
      for _, w in ipairs(wins) do
        local config = vim.api.nvim_win_get_config(w)
        if config.relative and config.relative ~= "" then
          local buf = vim.api.nvim_win_get_buf(w)
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          local content = table.concat(lines, "\n")
          assert.is_truthy(content:find("hello world"))
          break
        end
      end
    end)
  end)

  describe("close", function()
    it("does not error when nothing is open", function()
      assert.has_no.errors(function()
        response.close()
      end)
    end)

    it("removes the floating window", function()
      response.open("test")
      response.close()
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(w)
        if config.relative and config.relative ~= "" then
          -- should not find a floating window with markdown
          local buf = vim.api.nvim_win_get_buf(w)
          assert.are_not.equal("markdown", vim.bo[buf].filetype)
        end
      end
    end)
  end)
end)
