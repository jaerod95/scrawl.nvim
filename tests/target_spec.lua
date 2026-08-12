describe("target", function()
  local target

  local originals = {}

  local function stub(tbl, key, fn)
    table.insert(originals, { tbl = tbl, key = key, value = tbl[key] })
    tbl[key] = fn
  end

  local function restore()
    for i = #originals, 1, -1 do
      local o = originals[i]
      o.tbl[o.key] = o.value
    end
    originals = {}
  end

  before_each(function()
    package.loaded["scrawl.target"] = nil
    target = require("scrawl.target")
  end)

  after_each(restore)

  describe("repo_name", function()
    it("returns the basename of the git root", function()
      stub(vim.fn, "systemlist", function() return { "/Users/jrod/Documents/work/api-gateway-2" } end)

      assert.are.equal("api-gateway-2", target.repo_name())
    end)

    it("returns nil outside a git repo", function()
      stub(vim.fn, "systemlist", function() return { "" } end)

      assert.is_nil(target.repo_name())
    end)

    it("returns nil when git produces no output at all", function()
      stub(vim.fn, "systemlist", function() return {} end)

      assert.is_nil(target.repo_name())
    end)
  end)

  describe("pointer_path", function()
    it("is scoped per repo", function()
      stub(vim.fn, "systemlist", function() return { "/tmp/repo-a" } end)

      assert.is_truthy(target.pointer_path():find("/%.scrawl/targets/repo%-a$"))
    end)

    it("returns nil outside a git repo", function()
      stub(vim.fn, "systemlist", function() return { "" } end)

      assert.is_nil(target.pointer_path())
    end)
  end)

  describe("get", function()
    it("returns the recorded path", function()
      stub(vim.fn, "systemlist", function() return { "/tmp/repo" } end)
      stub(vim.fn, "filereadable", function() return 1 end)
      stub(vim.fn, "readfile", function() return { "/Users/jrod/Documents/ApplauseNotes/Manual Scorecard Spike.md" } end)

      assert.are.equal("/Users/jrod/Documents/ApplauseNotes/Manual Scorecard Spike.md", target.get())
    end)

    it("returns nil when no pointer file exists", function()
      stub(vim.fn, "systemlist", function() return { "/tmp/repo" } end)
      stub(vim.fn, "filereadable", function() return 0 end)

      assert.is_nil(target.get())
    end)

    it("returns nil when the pointer file is empty", function()
      stub(vim.fn, "systemlist", function() return { "/tmp/repo" } end)
      stub(vim.fn, "filereadable", function() return 1 end)
      stub(vim.fn, "readfile", function() return { "" } end)

      assert.is_nil(target.get())
    end)

    it("returns nil when the pointer file has no lines", function()
      stub(vim.fn, "systemlist", function() return { "/tmp/repo" } end)
      stub(vim.fn, "filereadable", function() return 1 end)
      stub(vim.fn, "readfile", function() return {} end)

      assert.is_nil(target.get())
    end)

    it("returns nil outside a git repo", function()
      stub(vim.fn, "systemlist", function() return { "" } end)

      assert.is_nil(target.get())
    end)
  end)

  describe("set", function()
    it("writes an absolute path to the repo pointer file", function()
      local written
      stub(vim.fn, "systemlist", function() return { "/tmp/my-repo" } end)
      stub(vim.fn, "mkdir", function() return 1 end)
      stub(vim.fn, "writefile", function(lines, path) written = { lines = lines, path = path } end)

      local full = target.set("/Users/jrod/notes.md")

      assert.are.equal("/Users/jrod/notes.md", full)
      assert.are.same({ "/Users/jrod/notes.md" }, written.lines)
      assert.is_truthy(written.path:find("/%.scrawl/targets/my%-repo$"))
    end)

    it("expands ~ before writing", function()
      local written
      stub(vim.fn, "systemlist", function() return { "/tmp/my-repo" } end)
      stub(vim.fn, "mkdir", function() return 1 end)
      stub(vim.fn, "writefile", function(lines) written = lines end)

      local full = target.set("~/notes.md")

      assert.is_nil(full:find("^~"))
      assert.are.equal(full, written[1])
    end)

    it("preserves paths containing spaces", function()
      local written
      stub(vim.fn, "systemlist", function() return { "/tmp/my-repo" } end)
      stub(vim.fn, "mkdir", function() return 1 end)
      stub(vim.fn, "writefile", function(lines) written = lines end)

      target.set("/Users/jrod/Documents/ApplauseNotes/Manual Scorecard Spike.md")

      assert.are.equal("/Users/jrod/Documents/ApplauseNotes/Manual Scorecard Spike.md", written[1])
    end)

    it("creates the targets directory", function()
      local made
      stub(vim.fn, "systemlist", function() return { "/tmp/my-repo" } end)
      stub(vim.fn, "mkdir", function(path, flags) made = { path = path, flags = flags } end)
      stub(vim.fn, "writefile", function() end)

      target.set("/tmp/notes.md")

      assert.are.equal("p", made.flags)
      assert.is_truthy(made.path:find("/%.scrawl/targets$"))
    end)

    it("returns nil and warns outside a git repo", function()
      stub(vim.fn, "systemlist", function() return { "" } end)

      local messages = {}
      local original_print = print
      _G.print = function(msg) table.insert(messages, msg) end

      local full = target.set("/tmp/notes.md")

      _G.print = original_print

      assert.is_nil(full)
      assert.are.equal(1, #messages)
      assert.is_truthy(messages[1]:find("not in a git repository"))
    end)
  end)

  describe("unset", function()
    it("deletes the pointer file", function()
      local deleted
      stub(vim.fn, "systemlist", function() return { "/tmp/my-repo" } end)
      stub(vim.fn, "filereadable", function() return 1 end)
      stub(vim.fn, "delete", function(path) deleted = path end)

      local original_print = print
      _G.print = function() end

      target.unset()

      _G.print = original_print

      assert.is_truthy(deleted:find("/%.scrawl/targets/my%-repo$"))
    end)

    it("warns and deletes nothing when no target is set", function()
      local deleted
      stub(vim.fn, "systemlist", function() return { "/tmp/my-repo" } end)
      stub(vim.fn, "filereadable", function() return 0 end)
      stub(vim.fn, "delete", function(path) deleted = path end)

      local messages = {}
      local original_print = print
      _G.print = function(msg) table.insert(messages, msg) end

      target.unset()

      _G.print = original_print

      assert.is_nil(deleted)
      assert.is_truthy(messages[1]:find("no target document set"))
    end)
  end)
end)
