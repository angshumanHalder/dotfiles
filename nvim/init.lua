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
opt.hlsearch = true
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

require("vim._core.ui2").enable({})

-- ============================================================================
-- KEYMAPS
-- ============================================================================

local map = vim.keymap.set

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("n", "<Esc>", "<cmd>noh<CR>")
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
-- vim.pack: no lazy loading, no build hooks, no config callbacks.
-- Spec fields: src (required), name, version, data.
-- On first launch plugins install; restart nvim if require() errors occur.
-- ============================================================================

vim.pack.add({
	"https://github.com/rebelot/kanagawa.nvim",
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/nvim-tree/nvim-tree.lua",
	"https://github.com/romus204/tree-sitter-manager.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/saghen/blink.lib",
	"https://github.com/saghen/blink.cmp",
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/creativenull/efmls-configs-nvim",
	"https://github.com/folke/todo-comments.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/MagicDuck/grug-far.nvim",
	"https://github.com/s1n7ax/nvim-window-picker",
	"https://github.com/kdheepak/lazygit.nvim",
	"https://github.com/nvim-orgmode/orgmode",
	"https://github.com/kkharji/sqlite.lua",
	"https://github.com/chipsenkbeil/org-roam.nvim",
	"https://github.com/hamidi-dev/org-super-agenda.nvim",
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	"https://github.com/angshumanhalder/orgcal.nvim",
})

-- ============================================================================
-- THEME: kanagawa-dragon
-- ============================================================================

require("kanagawa").setup({
	theme = "dragon",
	transparent = true,
})
vim.cmd.colorscheme("kanagawa-dragon")

-- ============================================================================
-- MINI.NVIM
-- Modules: icons, statusline, pairs, comment, surround, indentscope, bufremove
-- ============================================================================

require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()
require("mini.statusline").setup({ use_icons = true })

local function apply_kanagawa_statusline()
	local ok, colors = pcall(require, "kanagawa.colors")
	if not ok then
		return
	end
	local p = colors.setup({ theme = "dragon" }).palette
	vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { fg = p.sumiInk0, bg = p.dragonBlue2, bold = true })
	vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { fg = p.sumiInk0, bg = p.dragonGreen2, bold = true })
	vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { fg = p.sumiInk0, bg = p.dragonViolet, bold = true })
	vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { fg = p.sumiInk0, bg = p.dragonRed, bold = true })
	vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { fg = p.sumiInk0, bg = p.dragonOrange, bold = true })
	vim.api.nvim_set_hl(0, "MiniStatuslineModeOther", { fg = p.sumiInk0, bg = p.dragonAsh, bold = true })
	vim.api.nvim_set_hl(0, "MiniStatuslineDevinfo", { fg = p.oldWhite, bg = p.dragonBlack4 })
	vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { fg = p.fujiWhite, bg = p.dragonBlack4 })
	vim.api.nvim_set_hl(0, "MiniStatuslineFileinfo", { fg = p.oldWhite, bg = p.dragonBlack4 })
	vim.api.nvim_set_hl(0, "MiniStatuslineInactive", { fg = p.dragonAsh, bg = p.dragonBlack3 })
end

apply_kanagawa_statusline()
vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_kanagawa_statusline })

require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.indentscope").setup({
	symbol = "│",
	options = { try_as_border = true },
})
require("mini.bufremove").setup()
map("n", "<leader>bd", function()
	require("mini.bufremove").delete()
end, { desc = "Delete buffer" })

-- ============================================================================
-- TODO COMMENTS
-- <leader>ft  search todos
-- ============================================================================

require("todo-comments").setup()
map("n", "<leader>ft", function()
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

require("grug-far").setup()
map("n", "<leader>sr", function()
	require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Find & Replace (word)" })
map("n", "<leader>sR", function()
	require("grug-far").open()
end, { desc = "Find & Replace" })
map("v", "<leader>sr", function()
	require("grug-far").with_visual_selection()
end, { desc = "Find & Replace (selection)" })

-- ============================================================================
-- FILE TREE: nvim-tree
-- <leader>e  toggle
-- ============================================================================

local _ok, _kc = pcall(require, "kanagawa.colors")
local _p = _ok and _kc.setup({ theme = "dragon" }).palette or {}
require("window-picker").setup({
	hint = "statusline-winbar",
	selection_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
	filter_rules = {
		include_current_win = false,
		autoselect_one = true,
		bo = { filetype = { "NvimTree" }, buftype = {} },
	},
	highlights = {
		statusline = {
			focused = { fg = _p.sumiInk0, bg = _p.dragonGreen2, bold = true },
			unfocused = { fg = _p.sumiInk0, bg = _p.dragonGreen2 },
		},
		winbar = {
			focused = { fg = _p.sumiInk0, bg = _p.dragonGreen2, bold = true },
			unfocused = { fg = _p.sumiInk0, bg = _p.dragonGreen2 },
		},
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
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- ============================================================================
-- TREESITTER
-- nvim-treesitter archived Apr 2026.
-- tree-sitter-manager.nvim handles parser installs.
-- nvim 0.12 built-in highlighting via vim.treesitter.start().
-- Run :TSMInstall after first launch to install parsers.
-- Verify setup API against README: github.com/romus204/tree-sitter-manager.nvim
-- ============================================================================

require("tree-sitter-manager").setup({
	parsers = {
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
		"org",
	},
})
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
	end,
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
		local gs = package.loaded.gitsigns
		local gmap = function(mode, l, r, desc)
			vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
		end
		gmap("n", "]h", gs.next_hunk, "Next Hunk")
		gmap("n", "[h", gs.prev_hunk, "Prev Hunk")
		gmap("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
		gmap("n", "<leader>gs", gs.stage_hunk, "Stage Hunk")
		gmap("n", "<leader>gr", gs.reset_hunk, "Reset Hunk")
		gmap("n", "<leader>gb", gs.blame_line, "Blame Line")
	end,
})

-- ============================================================================
-- LAZYGIT
-- <leader>gg  open lazygit
-- ============================================================================

map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

-- ============================================================================
-- FUZZY FINDER: fzf-lua
-- <leader>ff  files   <leader>fg  grep    <leader>fb  buffers
-- <leader>fh  help    <leader>fd  diag    <leader>fr  recent   <leader>fs  symbols
-- ============================================================================

require("fzf-lua").setup({
	winopts = {
		height = 0.85,
		width = 0.85,
		preview = { layout = "horizontal", ratio = 0.5 },
	},
	defaults = {
		header = false,
	},
	files = {
		fd_opts = "--color=never --type f --hidden --follow --exclude .git",
		actions = { ["ctrl-i"] = { require("fzf-lua").actions.toggle_ignore } },
	},
	grep = {
		rg_opts = "--column --line-number --no-heading --color=always --smart-case",
		actions = { ["ctrl-i"] = { require("fzf-lua").actions.toggle_ignore } },
	},
})
map("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Files" })
map("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Live Grep" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>", { desc = "Help" })
map("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Diagnostics" })
map("n", "<leader>fD", "<cmd>FzfLua diagnostics_workspace<cr>", { desc = "Workspace Diagnostics" })
map("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent Files" })
map("n", "<leader>?", "<cmd>FzfLua keymaps<cr>", { desc = "Keymaps" })

-- ============================================================================
-- SNIPPETS: luasnip + friendly-snippets
-- NOTE: run 'make install_jsregexp' in LuaSnip install dir for regex support
-- ============================================================================

require("luasnip.loaders.from_vscode").lazy_load()

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
	sources = { default = { "lsp", "path", "snippets", "buffer" } },
	snippets = { preset = "luasnip" },
	signature = { enabled = true },
})

-- ============================================================================
-- MASON: LSP/tool installer  (:Mason to open UI)
-- Install servers: lua_ls, pyright, vtsls, rust_analyzer, gopls, efm
-- Install tools:   stylua, ruff, prettier, eslint_d
-- ============================================================================

require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

-- ============================================================================
-- LSP: nvim-lspconfig (provides server definitions only)
-- Configuration via vim.lsp.config / vim.lsp.enable (nvim 0.11+ native API)
-- gd  definition    gD  declaration   gr  references    gi  implementation
-- K   hover         <leader>lr  rename   <leader>la  code action
-- <leader>lf  format
-- ============================================================================

vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local buffer = args.buf
		local lmap = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
		end
		lmap("n", "gd", "<cmd>FzfLua lsp_definitions<cr>", "Go to Definition")
		lmap("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
		lmap("n", "gr", "<cmd>FzfLua lsp_references<cr>", "References")
		lmap("n", "gi", "<cmd>FzfLua lsp_implementations<cr>", "Implementation")
		lmap("n", "gO", "<cmd>FzfLua lsp_document_symbols<cr>", "Symbols")
		lmap("n", "K", function()
			vim.lsp.buf.hover({ border = "single" })
		end, "Hover")
		lmap("n", "<leader>lr", vim.lsp.buf.rename, "Rename")
		lmap("n", "<leader>la", vim.lsp.buf.code_action, "Code Action")
		lmap("n", "<leader>lf", function()
			vim.lsp.buf.format({
				async = true,
				filter = function(client)
					return client.name == "efm"
				end,
			})
		end, "Format")
		lmap("n", "<leader>ly", function()
			local diags = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
			if #diags == 0 then
				vim.notify("No diagnostic on this line")
				return
			end
			vim.fn.setreg("+", diags[1].message)
			vim.notify("Copied diagnostic")
		end, "Yank diagnostic")
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		vim.lsp.buf.format({
			async = false,
			timeout_ms = 2000,
			filter = function(client)
				return client.name == "efm"
			end,
		})
	end,
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("", true),
			},
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
vim.lsp.enable({ "lua_ls", "pyright", "vtsls", "rust_analyzer", "gopls", "dockerls", "yamlls" })

vim.diagnostic.config({
	virtual_text = { prefix = "●" },
	signs = true,
	underline = true,
	update_in_insert = false,
	float = { source = true },
})

-- ============================================================================
-- EFM FORMATTERS / LINTERS: efmls-configs-nvim
-- Requires efm-langserver installed via Mason.
-- Add/remove formatters and linters per language as needed.
-- ============================================================================

local languages = {
	lua = { require("efmls-configs.formatters.stylua") },
	python = { require("efmls-configs.formatters.ruff"), require("efmls-configs.linters.ruff") },
	javascript = { require("efmls-configs.formatters.prettier_d"), require("efmls-configs.linters.eslint_d") },
	typescript = { require("efmls-configs.formatters.prettier_d"), require("efmls-configs.linters.eslint_d") },
	typescriptreact = { require("efmls-configs.formatters.prettier_d"), require("efmls-configs.linters.eslint_d") },
	go = { require("efmls-configs.formatters.goimports") },
}

vim.lsp.config("efm", {
	filetypes = vim.tbl_keys(languages),
	settings = {
		rootMarkers = { ".git/" },
		languages = languages,
	},
	init_options = {
		documentFormatting = true,
		documentRangeFormatting = true,
	},
})
vim.lsp.enable("efm")


map("n", "<leader>of", function()
	require("fzf-lua").files({ cwd = "~/org" })
end, { desc = "Browse org files" })

-- ============================================================================
-- ORGMODE
-- <leader>oa  agenda   <leader>oc  capture   <leader>or  refile
-- Org files stored in ~/org/
-- ============================================================================

require("orgmode").setup({
	org_agenda_files = { "~/org/**/*" },
	org_default_notes_file = "~/org/inbox.org",
	org_hide_leading_stars = true,
	org_ellipsis = " ▾",
	org_todo_keywords = { "TODO", "NEXT", "WAITING", "|", "DONE", "CANCELLED" },
	org_agenda_span = "week",
	org_deadline_warning_days = 3,
	org_agenda_start_on_weekday = 1,
	org_capture_templates = {
		t = {
			description = "Task",
			template = "* TODO %?\n  SCHEDULED: %t",
			target = "~/org/inbox.org",
		},
		n = {
			description = "Note",
			template = "* %?\n  :PROPERTIES:\n  :CREATED: %T\n  :END:",
			target = "~/org/notes.org",
		},
		m = {
			description = "Meeting",
			template = "* %? :meeting:\n  %t\n** Attendees\n** Notes\n** Actions",
			target = "~/org/meetings.org",
		},
		j = {
			description = "Journal",
			template = "\n** %<%H:%M> %?\n",
			target = "~/org/journal.org",
			datetree = { active = false },
		},
	},
})


-- ============================================================================
-- ORGCAL: Google Calendar <-> orgmode via orgcal CLI
-- Requires: orgcal binary in PATH, ORGCAL_CLIENT_ID, ORGCAL_CLIENT_SECRET
-- :OrgCalAuth   :OrgCalSync   :OrgCalImport   :OrgCalExport
-- ============================================================================

require("orgcal").setup({ dir = "~/org" })

-- ============================================================================
-- ORG-ROAM: notes with backlinks
-- <leader>nf  find/open note   <leader>ni  insert link   <leader>nc  capture note
-- <leader>nb  backlinks buffer  <leader>nd  today's daily note
-- Notes in ~/org/roam/   Daily notes in ~/org/daily/
-- ============================================================================

require("org-roam").setup({
	directory = "~/org/roam",
	extensions = {
		dailies = {
			directory = "~/org/daily",
		},
	},
})

map("n", "<leader>nf", "<cmd>OrgRoamFindNode<cr>", { desc = "Find Note" })
map("n", "<leader>ni", "<cmd>OrgRoamInsertNode<cr>", { desc = "Insert Link" })
map("n", "<leader>nc", "<cmd>OrgRoamCaptureNode<cr>", { desc = "Capture Note" })
map("n", "<leader>nb", "<cmd>OrgRoamToggleRoamBuffer<cr>", { desc = "Backlinks" })
map("n", "<leader>nd", "<cmd>OrgRoamDailiesGotoToday<cr>", { desc = "Today's Daily Note" })

-- ============================================================================
-- ORG-SUPER-AGENDA
-- <leader>oA  open super agenda
-- ============================================================================

require("org-super-agenda").setup({
	org_directories = { "~/org" },
	todo_states = {
		{ name = "TODO", keymap = "ot", color = "#FF5555", strike_through = false },
		{ name = "NEXT", keymap = "on", color = "#FFAA00", strike_through = false },
		{ name = "WAITING", keymap = "ow", color = "#BD93F9", strike_through = false },
		{ name = "DONE", keymap = "od", color = "#50FA7B", strike_through = true },
		{ name = "CANCELLED", keymap = "oc", color = "#6272A4", strike_through = true },
	},
	groups = {
		{
			name = "Overdue",
			matcher = function(i)
				return i.todo_state ~= "DONE"
					and i.todo_state ~= "CANCELLED"
					and ((i.deadline and i.deadline:is_past()) or (i.scheduled and i.scheduled:is_past()))
			end,
			sort = { by = "date_nearest", order = "asc" },
		},
		{
			name = "Today",
			matcher = function(i)
				return i.scheduled and i.scheduled:is_today()
			end,
			sort = { by = "scheduled_time", order = "asc" },
		},
		{
			name = "Tomorrow",
			matcher = function(i)
				return i.scheduled and i.scheduled:days_from_today() == 1
			end,
			sort = { by = "scheduled_time", order = "asc" },
		},
		{
			name = "Deadlines",
			matcher = function(i)
				return i.deadline and i.todo_state ~= "DONE" and i.todo_state ~= "CANCELLED"
			end,
			sort = { by = "deadline", order = "asc" },
		},
		{
			name = "Next",
			matcher = function(i)
				return i.todo_state == "NEXT"
			end,
		},
		{
			name = "Waiting",
			matcher = function(i)
				return i.todo_state == "WAITING"
			end,
		},
		{
			name = "Upcoming",
			matcher = function(i)
				local d1 = i.deadline and i.deadline:days_from_today()
				local d2 = i.scheduled and i.scheduled:days_from_today()
				return (d1 and d1 >= 0 and d1 <= 14) or (d2 and d2 >= 0 and d2 <= 14)
			end,
			sort = { by = "date_nearest", order = "asc" },
		},
		{
			name = "All TODOs",
			matcher = function(i)
				return i.todo_state ~= "DONE" and i.todo_state ~= "CANCELLED"
			end,
		},
	},
	hide_empty_groups = true,
	allow_duplicates = false,
	show_tags = true,
	show_filename = true,
	window = {
		width = 0.85,
		height = 0.8,
		border = "single",
		title = "Agenda",
		title_pos = "center",
	},
})
map("n", "<leader>oA", "<cmd>OrgSuperAgenda<cr>", { desc = "Super Agenda" })

-- ============================================================================
-- RENDER-MARKDOWN: modern rendering for org and markdown files
-- Renders headings, bullets, checkboxes, code blocks, tables inline
-- ============================================================================

require("render-markdown").setup({
	file_types = { "markdown" },
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
		checked = { icon = "󰱒 " },
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

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "org", "markdown" },
	callback = function()
		vim.b.miniindentscope_disable = true
	end,
})

