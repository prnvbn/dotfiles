-- Leader shortcuts start with Space.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Editing and navigation.
local opt = vim.opt
opt.number = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.scrolloff = 5
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.undofile = true

-- Basic syntax highlighting and filetype-specific indentation.
vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

local map = vim.keymap.set
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>e", "<cmd>Explore<CR>", { desc = "Browse files" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Briefly highlight copied text.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
