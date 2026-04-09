local M = {}

local function dedent(text)
  local min_indent = math.huge
  for line in text:gmatch("[^\n]+") do
    local indent = line:match("^(%s*)")
    if #indent < min_indent then
      min_indent = #indent
    end
  end
  if min_indent == 0 or min_indent == math.huge then
    return text
  end
  local pattern = "^" .. string.rep(".", min_indent)
  local lines = {}
  for line in (text .. "\n"):gmatch("(.-)\n") do
    local stripped = line:gsub(pattern, "", 1)
    table.insert(lines, stripped)
  end
  -- remove trailing newline added by gmatch split
  if text:sub(-1) ~= "\n" and lines[#lines] == "" then
    table.remove(lines)
  end
  return table.concat(lines, "\n")
end

M.dedent = dedent

local ext_to_lang = {
  lua = "lua", js = "javascript", ts = "typescript", tsx = "tsx", jsx = "jsx",
  py = "python", rb = "ruby", rs = "rust", go = "go", java = "java",
  c = "c", cpp = "cpp", h = "c", hpp = "cpp", cs = "csharp",
  sh = "bash", bash = "bash", zsh = "zsh", fish = "fish",
  json = "json", yaml = "yaml", yml = "yaml", toml = "toml",
  md = "markdown", html = "html", css = "css", scss = "scss",
  sql = "sql", vim = "vim", ex = "elixir", exs = "elixir",
  swift = "swift", kt = "kotlin", php = "php", r = "r",
}

function M.lang(file)
  local ext = file:match("%.([^%.]+)$")
  return ext and ext_to_lang[ext] or ""
end

function M.get()
  local file = vim.fn.expand("%:~:.")
  local line = vim.fn.line(".")
  local selection = nil
  local start_line = nil
  local end_line = nil

  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd('noautocmd normal! "vy')
    selection = vim.fn.getreg("v")
    vim.fn.setreg("v", "")
    start_line = vim.fn.line("'<")
    end_line = vim.fn.line("'>")
    if selection then
      selection = dedent(selection)
    end
  end

  return { file = file, line = line, selection = selection, start_line = start_line, end_line = end_line }
end

return M
