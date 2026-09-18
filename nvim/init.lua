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
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.undofile = true
opt.swapfile = false
opt.backup = false
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
opt.completeopt = "menu,menuone,noselect"
opt.fileencoding = "utf-8"
opt.guifont = "JetBrainsMono Nerd Font Mono:h13"
opt.inccommand = "split"
opt.confirm = true
opt.virtualedit = "block"
opt.laststatus = 3
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable = false
opt.foldlevel = 99
opt.foldlevelstart = 99

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.conceallevel = 1
	end,
})

require("vim._core.ui2").enable({})

-- ============================================================================
-- KEYMAPS
-- ============================================================================

local map = vim.keymap.set

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<A-j>", "<cmd>m .+1<CR>==")
map("n", "<A-k>", "<cmd>m .-2<CR>==")
map("v", "<A-j>", "<cmd>m '>+1<CR>gv=gv")
map("v", "<A-k>", "<cmd>m '<-2<CR>gv=gv")

map("n", "<leader>sv", "<cmd>vsplit<CR>")
map("n", "<leader>sh", "<cmd>split<CR>")

map("n", "<S-h>", "<cmd>bprev<CR>")
map("n", "<S-l>", "<cmd>bnext<CR>")

map("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit Neovim" })

map("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end)
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end)
map("n", "<leader>ld", function()
	vim.diagnostic.open_float({ focusable = true })
end)

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "]q", "<cmd>cnext<CR>", { desc = "Next Quickfix" })
map("n", "[q", "<cmd>cprev<CR>", { desc = "Prev Quickfix" })
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
	"https://github.com/thesimonho/kanagawa-paper.nvim",
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/romus204/tree-sitter-manager.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/saghen/blink.lib",
	"https://github.com/saghen/blink.cmp",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/folke/lazydev.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/folke/snacks.nvim",
})

vim.pack.add({
	"https://github.com/nvim-tree/nvim-tree.lua",
	{ src = "https://github.com/olimorris/codecompanion.nvim", version = "v19.23.0" },
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/folke/todo-comments.nvim",
	"https://github.com/MagicDuck/grug-far.nvim",
	"https://github.com/s1n7ax/nvim-window-picker",
	"https://github.com/jceb/jiejie.nvim",
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	"https://github.com/epwalsh/obsidian.nvim",
	"https://github.com/sindrets/diffview.nvim",
	"https://github.com/folke/trouble.nvim",
}, {
	-- Register/install these packages without adding them to 'runtimepath'.
	load = function() end,
})

local loaded = {}
local function load_plugin(name)
	if not loaded[name] then
		vim.cmd.packadd(name)
		loaded[name] = true
	end
end

-- ============================================================================
-- THEME: kanagawa paper ink
-- ============================================================================

require("kanagawa-paper").setup({ transparent = true })
vim.cmd.colorscheme("kanagawa-paper-ink")

-- ============================================================================
-- MINI.NVIM
-- Modules: icons, statusline, pairs, surround, ai, clue
-- ============================================================================

require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()
require("mini.statusline").setup({ use_icons = true })

require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.ai").setup({ n_lines = 500 })

local clue = require("mini.clue")
clue.setup({
	triggers = {
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
	},
	clues = {
		{ mode = "n", keys = "<Leader>a", desc = "+AI" },
		{ mode = "x", keys = "<Leader>a", desc = "+AI" },
		clue.gen_clues.builtin_completion(),
		clue.gen_clues.marks(),
		clue.gen_clues.registers(),
		clue.gen_clues.windows(),
		clue.gen_clues.z(),
	},
})

-- ============================================================================
-- TODO COMMENTS
-- <leader>ft  search todos
-- ============================================================================

map("n", "<leader>ft", function()
	load_plugin("todo-comments.nvim")
	require("todo-comments").setup()
	require("todo-comments.fzf").todo({
		prompt = "Todo comments> ",
		-- This sets the initial query for ripgrep but keeps it out of the prompt
		search = [[\b(TODO|HACK|WARNING|WARN|XXX|PERF|OPTIM|PERFORMANCE|OPTIMIZE|NOTE|INFO|TEST|TESTING|PASSED|FAILED|FIX|FIXME|BUG|FIXIT|ISSUE)\b]],
		no_esc = true, -- Prevents fzf-lua from escaping the regex syntax
		no_header_i = true,
	})
end, { desc = "Todo Comments" })

-- ============================================================================
-- FIND & REPLACE: grug-far
-- <leader>sr  open (current word)   <leader>sR  open (empty)
-- ============================================================================

local function grug_far()
	load_plugin("grug-far.nvim")
	require("grug-far").setup()
	return require("grug-far")
end
map("n", "<leader>sr", function()
	grug_far().open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Find & Replace (word)" })
map("n", "<leader>sR", function()
	grug_far().open()
end, { desc = "Find & Replace" })
map("v", "<leader>sr", function()
	grug_far().with_visual_selection()
end, { desc = "Find & Replace (selection)" })

-- ============================================================================
-- FILE TREE: nvim-tree
-- <leader>e  toggle
-- ============================================================================

local nvim_tree_loaded = false
local function setup_nvim_tree()
	if nvim_tree_loaded then
		return
	end
	nvim_tree_loaded = true
	load_plugin("nvim-tree.lua")
	load_plugin("nvim-window-picker")

	require("window-picker").setup({
		hint = "statusline-winbar",
		selection_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
		filter_rules = {
			include_current_win = false,
			autoselect_one = true,
			bo = { filetype = { "NvimTree", "snacks_notif", "snacks_notif_history" }, buftype = {} },
		},
	})

	require("nvim-tree").setup({
		view = { width = 30 },
		renderer = {
			group_empty = true,
			icons = { show = { git = true } },
		},
		filters = { dotfiles = false },
		git = { enable = true },
		update_focused_file = {
			enable = true,
		},
		actions = {
			open_file = {
				quit_on_open = false,
				window_picker = {
					enable = true,
					picker = function()
						local cur = vim.api.nvim_get_current_win()
						local has_target = vim.iter(vim.api.nvim_list_wins()):any(function(w)
							if w == cur then
								return false
							end
							local ft = vim.bo[vim.api.nvim_win_get_buf(w)].filetype
							return ft ~= "NvimTree" and vim.api.nvim_win_get_config(w).relative == ""
						end)
						if not has_target then
							vim.cmd("vsplit")
							return vim.api.nvim_get_current_win()
						end
						local picked = require("window-picker").pick_window()
						vim.schedule(function()
							vim.cmd("echo ''")
						end)
						return picked
					end,
				},
			},
		},
		on_attach = function(bufnr)
			local api = require("nvim-tree.api")
			api.map.on_attach.default(bufnr)
			vim.keymap.del("n", "s", { buffer = bufnr })
			vim.keymap.set("n", "s", api.node.open.horizontal, { buffer = bufnr, desc = "Open: Horizontal Split" })
			vim.keymap.set("n", "v", api.node.open.vertical, { buffer = bufnr, desc = "Open: Vertical Split" })
		end,
	})
end
map("n", "<leader>e", function()
	setup_nvim_tree()
	require("nvim-tree.api").tree.toggle()
end, { desc = "Toggle file tree" })

-- ============================================================================
-- TREESITTER
-- nvim-treesitter archived Apr 2026.
-- tree-sitter-manager.nvim handles parser installs.
-- :TSInstall <lang>   install parser
-- :TSManager          TUI browser
-- ============================================================================

require("tree-sitter-manager").setup({
	ensure_installed = {
		"lua",
		"python",
		"javascript",
		"typescript",
		"tsx",
		"rust",
		"go",
		"c",
		"cpp",
		"bash",
		"json",
		"yaml",
		"toml",
		"markdown",
		"html",
		"css",
	},
})

-- ============================================================================
-- GIT SIGNS
-- ]h/[h  next/prev hunk   <leader>gp  preview   <leader>gs  stage
-- <leader>gr  reset        <leader>gb  blame
-- ============================================================================

require("gitsigns").setup({
	preview_config = { border = "single" },
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
	},
	on_attach = function(buffer)
		local gs = require("gitsigns")
		local gmap = function(mode, l, r, desc)
			vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
		end
		gmap("n", "]h", function()
			gs.nav_hunk("next")
		end, "Next Hunk")
		gmap("n", "[h", function()
			gs.nav_hunk("prev")
		end, "Prev Hunk")
		gmap("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
		gmap("n", "<leader>gs", gs.stage_hunk, "Stage Hunk")
		gmap("n", "<leader>gr", gs.reset_hunk, "Reset Hunk")
		gmap("n", "<leader>gb", gs.blame_line, "Blame Line")
	end,
})

-- ============================================================================
-- SNACKS
-- Modules: bigfile, dashboard, indent, notifier, scroll, statuscolumn,
--          gitbrowse, scratch, lazygit, bufdelete
-- <leader>bd  delete buffer   <leader>gg  lazygit   <leader>gB  git browse
-- <leader>gj  Jujutsu status  <leader>sc  scratch buffer
-- ============================================================================

local fzf

require("snacks").setup({
	bigfile = { enabled = true },
	dashboard = {
		enabled = true,
		preset = {
			keys = {
				{
					icon = " ",
					key = "f",
					desc = "Find File",
					action = function()
						fzf("files")
					end,
				},
				{
					icon = " ",
					key = "r",
					desc = "Recent Files",
					action = function()
						fzf("oldfiles")
					end,
				},
				{
					icon = " ",
					key = "g",
					desc = "Live Grep",
					action = function()
						fzf("live_grep")
					end,
				},
				{ icon = " ", key = "n", desc = "New File", action = "<cmd>enew<cr>" },
				{ icon = " ", key = "c", desc = "Config", action = "<cmd>e $MYVIMRC<cr>" },
				{
					icon = "󰒲 ",
					key = "u",
					desc = "Update Plugins",
					action = function()
						vim.pack.update()
					end,
				},
				{ icon = " ", key = "q", desc = "Quit", action = "<cmd>qa<cr>" },
			},
		},
		sections = {
			{ section = "header" },
			{ section = "keys", gap = 1, padding = 1 },
		},
	},
	indent = {
		enabled = true,
		char = "│",
		scope = { char = "│", hl = "SnacksIndentScope" },
		filter = function(buf)
			return vim.bo[buf].filetype ~= "markdown" and vim.bo[buf].buftype == ""
		end,
	},
	notifier = { enabled = true, timeout = 3000 },
	scroll = { enabled = false },
	statuscolumn = { enabled = false },
	lazygit = { enabled = true },
	bufdelete = { enabled = true },
	gitbrowse = { enabled = true },
	scratch = { enabled = true },
})

map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete buffer" })
map("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "LazyGit" })
map("n", "<leader>gj", function()
	load_plugin("jiejie.nvim")
	vim.cmd("J")
end, { desc = "Jujutsu Status" })
map("n", "<leader>gB", function()
	Snacks.gitbrowse()
end, { desc = "Git Browse" })
map("n", "<leader>sc", function()
	Snacks.scratch()
end, { desc = "Scratch Buffer" })

-- ============================================================================
-- DIFFVIEW
-- <leader>gc  open (merge tool auto-activates during an active git conflict)
-- ============================================================================

map("n", "<leader>gc", function()
	load_plugin("diffview.nvim")
	require("diffview").setup({})
	vim.cmd.DiffviewOpen()
end, { desc = "Diffview" })

-- ============================================================================
-- FUZZY FINDER: fzf-lua
-- <leader>ff  files   <leader>fg  grep    <leader>fb  buffers
-- <leader>fh  help    <leader>fr  recent   <leader>fs  symbols
-- ============================================================================

local fzf_loaded = false
fzf = function(picker, opts)
	if not fzf_loaded then
		fzf_loaded = true
		load_plugin("fzf-lua")
		---@diagnostic disable: missing-fields
		require("fzf-lua").setup({
			winopts = {
				height = 0.85,
				width = 0.85,
				preview = { layout = "horizontal", ratio = 0.5 },
			},
			defaults = { header = false },
			files = {
				fd_opts = "--color=never --type f --hidden --follow --exclude .git",
				actions = { ["ctrl-i"] = { require("fzf-lua").actions.toggle_ignore } },
			},
			grep = {
				rg_opts = "--column --line-number --no-heading --color=always --smart-case",
				actions = { ["ctrl-i"] = { require("fzf-lua").actions.toggle_ignore } },
			},
		})
		---@diagnostic enable: missing-fields
	end
	require("fzf-lua")[picker](opts)
end

map("n", "<leader>ff", function()
	fzf("files")
end, { desc = "Files" })
map("n", "<leader>fg", function()
	fzf("live_grep")
end, { desc = "Live Grep" })
map("n", "<leader>fb", function()
	fzf("buffers")
end, { desc = "Buffers" })
map("n", "<leader>fh", function()
	fzf("help_tags")
end, { desc = "Help" })
map("n", "<leader>fr", function()
	fzf("oldfiles")
end, { desc = "Recent Files" })
map("n", "<leader>?", function()
	fzf("keymaps")
end, { desc = "Keymaps" })

-- ============================================================================
-- COMPLETION: blink.cmp
-- v2 requires a native library. Builds automatically if missing.
-- Run :BlinkBuild manually after updates if completion breaks.
-- ============================================================================

vim.api.nvim_create_user_command("BlinkBuild", function()
	require("blink.cmp").build():wait(60000)
	vim.notify("blink.cmp: build complete", vim.log.levels.INFO)
end, { desc = "Build blink.cmp native library" })

if not pcall(require, "blink.lib") then
	vim.notify("blink.cmp: building native library...", vim.log.levels.INFO)
	require("blink.cmp").build():wait(60000)
end

require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = {
		nerd_font_variant = "mono",
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer", "lazydev" },
		providers = {
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				score_offset = 100,
			},
		},
	},
	snippets = { preset = "default" },
	signature = { enabled = true },
})

-- ============================================================================
-- AI: CodeCompanion (ACP agents use their existing CLI login/configuration)
-- <leader>ac  toggle chat   <leader>an  new chat   <leader>aa  actions/chats
-- <leader>as  add selection   <leader>ar  review edits
-- In chat: <leader>ap  agent   <leader>am  model/options   ]a/[a  chats
-- <C-s>  send   q  stop   ?  help   /file, /buffer  attach context
-- ============================================================================

local codecompanion_width = 0.35

vim.api.nvim_create_autocmd("CmdUndefined", {
	pattern = "CodeCompanion*",
	once = true,
	callback = function()
		load_plugin("fzf-lua")
		load_plugin("codecompanion.nvim")
		require("codecompanion").setup({
			adapters = {
				acp = {
					extend = { codex = { defaults = { auth_method = "chat-gpt" } } },
				},
			},
			interactions = {
				chat = {
					adapter = "codex",
					keymaps = {
						change_adapter = { modes = { n = "<leader>ap" } },
						next_chat = { modes = { n = "]a" } },
						previous_chat = { modes = { n = "[a" } },
					},
					slash_commands = {
						acp_session_options = { keymaps = { modes = { n = "<leader>am" } } },
					},
				},
			},
			display = {
				action_palette = { provider = "fzf_lua" },
				chat = {
					window = {
						position = "right",
						width = codecompanion_width,
						opts = { number = false, relativenumber = false, signcolumn = "no", winfixwidth = true },
					},
				},
			},
		})
	end,
})

vim.api.nvim_create_autocmd({ "WinNew", "WinClosed", "VimResized" }, {
	callback = vim.schedule_wrap(function()
		local width = math.floor(vim.o.columns * codecompanion_width)
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if
				vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "codecompanion"
				and vim.api.nvim_win_get_width(win) ~= width
			then
				vim.api.nvim_win_set_width(win, width)
			end
		end
	end),
})

map("n", "<leader>ac", "<cmd>CodeCompanionChat toggle<CR>", { desc = "AI Chat Toggle" })
map({ "n", "x" }, "<leader>an", ":CodeCompanionChat<CR>", { desc = "AI New Chat" })
map({ "n", "x" }, "<leader>aa", ":CodeCompanionActions<CR>", { desc = "AI Actions / Chats" })
map("x", "<leader>as", ":CodeCompanionChat add<CR>", { desc = "AI Add Selection" })
map("n", "<leader>ar", "<cmd>CodeCompanionCodeReview<CR>", { desc = "AI Review Edits" })

-- ============================================================================
-- MASON: LSP/tool installer  (:Mason to open UI)
-- Suggested servers/tools below are installed manually through :Mason.
-- ============================================================================

vim.api.nvim_create_autocmd("CmdUndefined", {
	pattern = "Mason",
	once = true,
	callback = function()
		load_plugin("mason.nvim")
		require("mason").setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})
	end,
})

-- ============================================================================
-- LSP: nvim-lspconfig (provides server definitions only)
-- Configuration via vim.lsp.config / vim.lsp.enable (nvim 0.11+ native API)
-- gd  definition    gD  declaration   gr  references    gi  implementation
-- K   hover         <leader>lr  rename   <leader>la  code action
-- <leader>lf  format   <leader>fs  symbols
-- ============================================================================

-- ============================================================================
-- LAZYDEV: nvim Lua API completion and diagnostics
-- Fixes undefined-global vim warnings; lazy-loads only for nvim config files
-- ============================================================================

require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})

vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local buffer = args.buf
		local lmap = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
		end
		lmap("n", "gd", function()
			fzf("lsp_definitions")
		end, "Go to Definition")
		lmap("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
		lmap("n", "gr", function()
			fzf("lsp_references")
		end, "References (FZF)")
		lmap("n", "gi", function()
			fzf("lsp_implementations")
		end, "Implementation")
		lmap("n", "gO", function()
			fzf("lsp_document_symbols")
		end, "Document Symbols (FZF)")
		lmap("n", "<leader>fs", function()
			fzf("lsp_document_symbols")
		end, "Document Symbols (FZF)")
		lmap("n", "K", function()
			vim.lsp.buf.hover({ border = "single" })
		end, "Hover")
		lmap("n", "<leader>lr", vim.lsp.buf.rename, "Rename")
		lmap("n", "<leader>la", vim.lsp.buf.code_action, "Code Action")
		lmap("v", "<leader>la", vim.lsp.buf.code_action, "Code Action")
		lmap("n", "<leader>lf", function()
			require("conform").format({ async = true })
		end, "Format")
	end,
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("vtsls", {
	init_options = {
		autoUseWorkspaceTsdk = false,
	},
	settings = {
		vtsls = {
			autoUseWorkspaceTsdk = false,
		},
		typescript = {
			tsserver = {
				implicitProjectConfig = {
					jsx = "react-jsx",
				},
			},
		},
		javascript = {
			tsserver = {
				implicitProjectConfig = {
					jsx = "react-jsx",
				},
			},
		},
	},
})

-- Add/remove servers to match what you install via Mason
vim.lsp.enable({ "lua_ls", "pyright", "vtsls", "rust_analyzer", "gopls", "dockerls", "yamlls", "wgsl_analyzer" })

vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = false,
	signs = true,
	underline = true,
	update_in_insert = false,
	float = { source = true },
})

-- ============================================================================
-- TROUBLE: diagnostics/quickfix list
-- <leader>fd  document diagnostics   <leader>fD  workspace diagnostics
-- ============================================================================

local trouble_loaded = false
local function trouble(command)
	load_plugin("trouble.nvim")
	if not trouble_loaded then
		trouble_loaded = true
		require("trouble").setup()
	end
	vim.cmd(command)
end
map("n", "<leader>fd", function()
	trouble("Trouble diagnostics toggle filter.buf=0")
end, { desc = "Diagnostics" })
map("n", "<leader>fD", function()
	trouble("Trouble diagnostics toggle")
end, { desc = "Workspace Diagnostics" })

-- ============================================================================
-- FORMATTING: conform.nvim
-- <leader>lf  format buffer / selection
-- ============================================================================

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_format" },
		javascript = { "prettierd" },
		typescript = { "prettierd" },
		typescriptreact = { "prettierd" },
		json = { "prettierd" },
		yaml = { "prettierd" },
		toml = { "taplo" },
		rust = { "rustfmt" },
		go = { "goimports" },
	},
	-- Run formatters asynchronously after writing so slow or failing formatters
	-- never block saving or editor input. Conform writes successful edits back.
	format_after_save = {
		lsp_format = "never",
	},
})

-- ============================================================================
-- LINTING: nvim-lint
-- ============================================================================

local lint = require("lint")
lint.linters_by_ft = {
	python = { "ruff" },
	javascript = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	go = { "golangcilint" },
	dockerfile = { "hadolint" },
}

vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function()
		lint.try_lint()
	end,
})

-- ============================================================================
-- RENDER-MARKDOWN: modern rendering for markdown files
-- Renders headings, bullets, checkboxes, code blocks, tables inline
-- ============================================================================

-- ============================================================================
-- OBSIDIAN: note-taking with vault integration
-- <leader>on  new note        <leader>oo  open picker   <leader>of  follow link
-- <leader>ob  backlinks       <leader>ot  tags          <leader>os  search
-- <leader>oT  new from template
-- ============================================================================

local obsidian_loaded = false
local function setup_obsidian()
	if obsidian_loaded then
		return
	end
	obsidian_loaded = true
	load_plugin("obsidian.nvim")
	require("obsidian").setup({
		workspaces = {
			{ name = "notes", path = "~/Documents/Notes/" },
		},
		completion = {
			min_chars = 3,
			nvim_cmp = false,
			blink = true,
		},
		ui = { enable = false },
		note_id_func = function(title)
			if title ~= nil and #title > 0 then
				return title
			end
			return tostring(os.time())
		end,
		templates = {
			folder = "Templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
		},
		mappings = {},
	})
end

local function obsidian_command(command)
	setup_obsidian()
	vim.cmd(command)
end
map("n", "<leader>on", function()
	obsidian_command("ObsidianNew")
end, { desc = "New Note" })
map("n", "<leader>oT", function()
	obsidian_command("ObsidianNewFromTemplate")
end, { desc = "New Note from Template" })
map("n", "<leader>oo", function()
	obsidian_command("ObsidianQuickSwitch")
end, { desc = "Open Note" })
map("n", "<leader>of", function()
	obsidian_command("ObsidianFollowLink")
end, { desc = "Follow Link" })
map("n", "<leader>ob", function()
	obsidian_command("ObsidianBacklinks")
end, { desc = "Backlinks" })
map("n", "<leader>ot", function()
	obsidian_command("ObsidianTags")
end, { desc = "Tags" })
map("n", "<leader>os", function()
	obsidian_command("ObsidianSearch")
end, { desc = "Search Notes" })

local render_markdown_loaded = false
local function setup_render_markdown()
	if render_markdown_loaded then
		return
	end
	render_markdown_loaded = true
	load_plugin("render-markdown.nvim")
	require("render-markdown").setup({
		file_types = { "markdown", "codecompanion" },
		latex = { enabled = false },
		heading = {
			enabled = true,
			sign = false,
			icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
			width = "full",
		},
		bullet = {
			enabled = true,
			icons = { "●", "○", "◆", "◇" },
		},
		checkbox = {
			enabled = true,
			unchecked = { icon = "󰄱 " },
			checked = { icon = "✓ " },
		},
		code = {
			enabled = true,
			sign = false,
			style = "full",
			border = "thin",
			width = "block",
			min_width = 40,
		},
		dash = { enabled = true },
		quote = { enabled = true, icon = "▋" },
		pipe_table = { enabled = true },
		link = { enabled = true },
	})
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "codecompanion" },
	callback = function()
		setup_render_markdown()
		local notes = vim.fs.normalize(vim.fn.expand("~/Documents/Notes"))
		local file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
		if file:sub(1, #notes + 1) == notes .. "/" then
			setup_obsidian()
		end
	end,
})
