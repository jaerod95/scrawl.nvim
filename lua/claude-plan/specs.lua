local M = {}

local specs_root = vim.fn.expand("~/.claude-plan/specs")

local function get_repo_name()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if not git_root or git_root == "" then return nil end
  return vim.fn.fnamemodify(git_root, ":t")
end

function M.pick()
  local repo = get_repo_name()
  if not repo then
    return print("claude-plan: not in a git repository")
  end

  local spec_dir = specs_root .. "/" .. repo
  if vim.fn.isdirectory(spec_dir) == 0 then
    return print("claude-plan: no specs found for " .. repo)
  end

  require("telescope.builtin").find_files({
    prompt_title = "Specs (" .. repo .. ")",
    cwd = spec_dir,
  })
end

return M
