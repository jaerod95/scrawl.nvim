-- Minimal init for demo recording
vim.opt.rtp:prepend(".")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.g.mapleader = " "

local scrawl = require("scrawl")
scrawl.setup()

-- Exit terminal mode with Ctrl+B (matches the normal-mode dismiss binding)
vim.keymap.set("t", "<C-b>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>cc", scrawl.toggle, { desc = "Toggle Claude Code" })
vim.keymap.set("n", "<leader>cq", scrawl.question, { desc = "Ask Claude" })
vim.keymap.set("v", "<leader>cq", scrawl.question, { desc = "Ask Claude with selection" })
vim.keymap.set("n", "<leader>cn", scrawl.note, { desc = "Capture note" })
vim.keymap.set("v", "<leader>cn", scrawl.note, { desc = "Capture note with selection" })
vim.keymap.set("n", "<leader>cd", scrawl.decision, { desc = "Capture decision" })
vim.keymap.set("v", "<leader>cd", scrawl.decision, { desc = "Capture decision with selection" })
