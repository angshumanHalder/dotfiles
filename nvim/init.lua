-- Cache compiled Lua modules: about 20ms off every start.
vim.loader.enable()

-- ============================================================================
-- OPTIONS
-- ============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.undofile = true
opt.swapfile = false
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.showmode = false
opt.pumheight = 10
opt.inccommand = "split"
opt.confirm = true
opt.virtualedit = "block"
opt.laststatus = 3
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable = false
opt.foldlevelstart = 99
opt.spelloptions = "camel"

-- Spell check prose, like Emacs jinx in text modes.
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text", "org", "gitcommit" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

require("vim._core.ui2").enable({})

-- ============================================================================
-- KEYMAPS
-- ============================================================================

local map = vim.keymap.set

map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<A-j>", "<cmd>m .+1<CR>==")
map("n", "<A-k>", "<cmd>m .-2<CR>==")
map("v", "<A-j>", "<cmd>m '>+1<CR>gv=gv")
map("v", "<A-k>", "<cmd>m '<-2<CR>gv=gv")

-- Increase/decrease window height with Alt + Up/Down
map("n", "<M-Up>", ":resize +2<CR>", { silent = true })
map("n", "<M-Down>", ":resize -2<CR>", { silent = true })

-- Increase/decrease window width with Alt + Left/Right
map("n", "<M-Right>", ":vertical resize +2<CR>", { silent = true })
map("n", "<M-Left>", ":vertical resize -2<CR>", { silent = true })

map("n", "<S-h>", "<cmd>bprev<CR>")
map("n", "<S-l>", "<cmd>bnext<CR>")

map("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit Neovim" })

map("n", "<leader>ld", function()
	vim.diagnostic.open_float({ focusable = true })
end)

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- ============================================================================
-- PLUGINS
-- vim.pack installs plugins without sourcing plugin scripts during init.lua.
-- Specialist plugins below are configured on first use.
-- Spec fields: src (required), name, version, data.
-- On first launch plugins install; restart nvim if require() errors occur.
-- ============================================================================

vim.pack.add({
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/romus204/tree-sitter-manager.nvim",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/saghen/blink.lib",
	"https://github.com/saghen/blink.cmp",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/folke/lazydev.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/folke/snacks.nvim",
	"https://github.com/numToStr/Comment.nvim",
	"https://github.com/webhooked/kanso.nvim",
	"https://github.com/xheisenbugx/org.nvim",
})

vim.pack.add({
	"https://github.com/nvim-tree/nvim-tree.lua",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/NeogitOrg/neogit",
	"https://github.com/folke/todo-comments.nvim",
	"https://github.com/MagicDuck/grug-far.nvim",
	"https://github.com/s1n7ax/nvim-window-picker",
	"https://github.com/angshumanHalder/agentic.nvim",
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	"https://github.com/sindrets/diffview.nvim",
}, {
	-- Register/install these packages without adding them to 'runtimepath'.
	load = function() end,
})

-- packadd an opt plugin once, running `setup` the first time.
-- Global because lua/editor.lua and lua/lsp.lua both use it.
local loaded = {}
function _G.load_plugin(name, setup)
	if not loaded[name] then
		vim.cmd.packadd(name)
		loaded[name] = true
		if setup then
			setup()
		end
	end
end

require("editor")
require("lsp")
