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

-- Install plugins with Neovim's built-in plugin manager.
vim.pack.add({
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/lewis6991/gitsigns.nvim",
}, { confirm = false })
require("oil").setup({ columns = {} })
require("fzf-lua").setup({ winopts = { preview = { default = "builtin" } } })
require("gitsigns").setup({
  on_attach = function(bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set("n", "]c", "<cmd>Gitsigns nav_hunk next<CR>",
      vim.tbl_extend("force", opts, { desc = "Next Git change" }))
    vim.keymap.set("n", "[c", "<cmd>Gitsigns nav_hunk prev<CR>",
      vim.tbl_extend("force", opts, { desc = "Previous Git change" }))
    vim.keymap.set("n", "do", "<cmd>Gitsigns preview_hunk_inline<CR>",
      vim.tbl_extend("force", opts, { desc = "Preview Git change inline" }))
    vim.keymap.set("n", "<D-y>", "<cmd>Gitsigns stage_hunk<CR>",
      vim.tbl_extend("force", opts, { desc = "Stage Git hunk" }))
  end,
})

local map = vim.keymap.set
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Browse files" })
map("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory" })
map("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Search text in files" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { desc = "Find open buffers" })
map("n", "<leader>fh", "<cmd>FzfLua helptags<CR>", { desc = "Search help" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Briefly highlight copied text.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
