local M = {}

local targets_root = vim.fn.expand("~/.scrawl/targets")

function M.repo_name()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if not git_root or git_root == "" then return nil end
  return vim.fn.fnamemodify(git_root, ":t")
end

function M.pointer_path()
  local repo = M.repo_name()
  if not repo then return nil end
  return targets_root .. "/" .. repo
end

function M.get()
  local pointer = M.pointer_path()
  if not pointer or vim.fn.filereadable(pointer) == 0 then return nil end
  local path = vim.fn.readfile(pointer)[1]
  if not path or path == "" then return nil end
  return path
end

function M.set(path)
  local pointer = M.pointer_path()
  if not pointer then
    print("scrawl: not in a git repository")
    return nil
  end
  local full = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
  vim.fn.mkdir(targets_root, "p")
  vim.fn.writefile({ full }, pointer)
  return full
end

function M.unset()
  local pointer = M.pointer_path()
  if not pointer or vim.fn.filereadable(pointer) == 0 then
    return print("scrawl: no target document set")
  end
  vim.fn.delete(pointer)
  print("scrawl: target cleared, back to ~/.scrawl/specs")
end

return M
