-- Development: languages (Treesitter, LSP, completion, formatting, linting), git, diagnostics, compile

local map = vim.keymap.set

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
-- GIT HUNKS: mini.diff (Emacs diff-hl)
-- <leader>]h/<leader>[h  next/prev hunk   <leader>gp  toggle inline diff   <leader>gs  stage
-- <leader>gr  reset        <leader>gb  blame line (Snacks popup)
-- gh{motion}/gH{motion}  stage/reset hunks in a range
-- ============================================================================

local diff = require("mini.diff")
diff.setup({
	view = { style = "sign", signs = { add = "▎", change = "▎", delete = "▁" } },
	mappings = { goto_prev = "<leader>[h", goto_next = "<leader>]h" },
})

-- Whole hunk under the cursor: mini.diff's operator over its hunk text object.
-- (do_hunks with a one-line range would stage only that line.)
map("n", "<leader>gs", "ghgh", { remap = true, desc = "Stage Hunk" })
map("n", "<leader>gr", "gHgh", { remap = true, desc = "Reset Hunk" })
map("n", "<leader>gp", function()
	diff.toggle_overlay(0)
end, { desc = "Toggle Inline Diff" })
map("n", "<leader>gb", function()
	Snacks.git.blame_line()
end, { desc = "Blame Line" })

-- ============================================================================
-- NEOGIT AND DIFFVIEW
-- <leader>gg  Neogit   <leader>gB  git browse   <leader>gc  Diffview   <leader>gx  close Diffview
-- ============================================================================

local function load_diffview()
	load_plugin("diffview.nvim", function()
		require("diffview").setup({})
	end)
end
map("n", "<leader>gg", function()
	load_plugin("neogit", function()
		load_diffview()
		require("neogit").setup({})
	end)
	require("neogit").open()
end, { desc = "Neogit" })
map("n", "<leader>gB", function()
	Snacks.gitbrowse()
end, { desc = "Git Browse" })
map("n", "<leader>gc", function()
	load_diffview()
	vim.cmd.DiffviewOpen()
end, { desc = "Diffview" })

map("n", "<leader>gx", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" })

-- ============================================================================
-- COMPLETION: blink.cmp
-- v2 requires a native library, built per plugin commit: it builds on the
-- first start after an install or update. :BlinkBuild rebuilds by hand.
-- ============================================================================

vim.api.nvim_create_user_command("BlinkBuild", function()
	require("blink.cmp").build():wait(300000)
	vim.notify("blink.cmp: build complete", vim.log.levels.INFO)
end, { desc = "Build blink.cmp native library" })

if not require("blink.cmp").library_available() then
	vim.notify("blink.cmp: building native library...", vim.log.levels.INFO)
	require("blink.cmp").build():wait(300000)
end

require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
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
-- LSP: nvim-lspconfig (provides server definitions only)
-- Configuration via vim.lsp.config / vim.lsp.enable (nvim 0.11+ native API)
-- gd  definition    gD  declaration   gr  references    gi  implementation
-- K   hover         <leader>lr  rename   <leader>la  code action
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
			Snacks.picker.lsp_definitions()
		end, "Go to Definition")
		lmap("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
		lmap("n", "gr", function()
			Snacks.picker.lsp_references()
		end, "References")
		lmap("n", "gi", function()
			Snacks.picker.lsp_implementations()
		end, "Implementation")
		lmap("n", "K", function()
			vim.lsp.buf.hover({ border = "single" })
		end, "Hover")
		lmap("n", "<leader>lr", vim.lsp.buf.rename, "Rename")
		lmap("n", "<leader>la", vim.lsp.buf.code_action, "Code Action")
		lmap("v", "<leader>la", vim.lsp.buf.code_action, "Code Action")
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

-- Servers and tools come from the Brewfile (rust-analyzer from rustup), shared with Emacs.
-- Each server starts only when a buffer of one of its filetypes opens.
vim.lsp.enable({
	"lua_ls",
	"pyright",
	"vtsls",
	"rust_analyzer",
	"gopls",
	"clangd",
	"bashls",
	"jsonls",
	"taplo",
	"marksman",
	"html",
	"cssls",
	"dockerls",
	"yamlls",
	"wgsl_analyzer",
})

vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = false,
	signs = true,
	underline = true,
	update_in_insert = false,
	float = { source = true },
})

-- ============================================================================
-- DIAGNOSTIC LISTS (built-in location/quickfix lists)
-- <leader>fd  document diagnostics   <leader>fD  workspace diagnostics
-- ============================================================================

map("n", "<leader>fd", vim.diagnostic.setloclist, { desc = "Diagnostics" })
map("n", "<leader>fD", vim.diagnostic.setqflist, { desc = "Workspace Diagnostics" })

-- ============================================================================
-- FORMATTING: conform.nvim
-- <leader>lf  format buffer
-- ============================================================================

map("n", "<leader>lf", function()
	require("conform").format({ async = true })
end, { desc = "Format" })

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_format" },
		javascript = { "prettierd" },
		javascriptreact = { "prettierd" },
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
	javascriptreact = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	go = { "golangcilint" },
	dockerfile = { "hadolint" },
}

-- Same markers as Emacs flymake-jsts: outside an eslint project eslint_d only
-- reports a missing config.
local eslint_configs = {
	"eslint.config.js",
	"eslint.config.mjs",
	"eslint.config.cjs",
	".eslintrc",
	".eslintrc.js",
	".eslintrc.cjs",
	".eslintrc.json",
	".eslintrc.yaml",
	".eslintrc.yml",
}

-- Like Emacs flymake: lint on open, save and leaving insert mode. golangci-lint
-- reads the file from disk, so it skips InsertLeave (unsaved edits).
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
	callback = function(args)
		local names = vim.tbl_filter(function(name)
			if name == "eslint_d" then
				return vim.fs.root(args.buf, eslint_configs) ~= nil
			end
			return not (name == "golangcilint" and args.event == "InsertLeave")
		end, lint.linters_by_ft[vim.bo[args.buf].filetype] or {})
		if #names > 0 then
			lint.try_lint(names)
		end
	end,
})

-- ============================================================================
-- COMPILE (Emacs M-x compile): run a command, stream its output into quickfix
-- :Compile [cmd]   <leader>cc  prompt (last command prefilled)   gr in that list  recompile
-- Errors are parsed with the built-in :compiler preset named after the command
-- (cargo, go, tsc, eslint, pytest, ...), else the global 'errorformat'. Like
-- Emacs, all output stays visible; only matching lines become jump targets.
-- ============================================================================

local compile = {}

local function compile_efm(cmd)
	local name = cmd:match("^%s*(%S+)")
	local efm = vim.go.errorformat
	if name and #vim.api.nvim_get_runtime_file("compiler/" .. name .. ".vim", false) > 0 then
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_call(buf, function()
			vim.cmd.compiler(name)
			if vim.bo.errorformat ~= "" then
				efm = vim.bo.errorformat
			end
		end)
		vim.api.nvim_buf_delete(buf, { force = true })
	end
	-- Presets such as go and tsc end with %-G%.%# (drop unmatched lines). Split on
	-- unescaped commas, drop that item, and keep unmatched lines as text instead.
	local items, item, i = {}, "", 1
	while i <= #efm do
		local c = efm:sub(i, i)
		if c == "\\" then
			item = item .. efm:sub(i, i + 1)
			i = i + 1
		elseif c == "," then
			items[#items + 1] = item
			item = ""
		else
			item = item .. c
		end
		i = i + 1
	end
	items[#items + 1] = item
	items = vim.tbl_filter(function(it)
		return it ~= "" and it ~= "%-G%.%#"
	end, items)
	items[#items + 1] = "%+G%.%#"
	return table.concat(items, ",")
end

-- Parse output lines; lines without a location stay as plain text, not jump targets.
local function compile_items(lines, efm)
	local items = vim.fn.getqflist({ lines = lines, efm = efm }).items
	for _, it in ipairs(items) do
		if it.lnum == 0 then
			it.valid, it.bufnr = 0, 0
		end
	end
	return items
end

local function run_compile(cmd)
	if compile.job then
		compile.job:kill(15) -- like Emacs, a new compile replaces the running one
	end
	compile.cmd = cmd
	local efm = compile_efm(cmd)
	local started = vim.uv.hrtime()
	vim.fn.setqflist({}, " ", {
		title = "Compile: " .. cmd,
		items = { { text = "cd " .. vim.fn.getcwd() .. " && " .. cmd, valid = false } },
	})
	local id = vim.fn.getqflist({ id = 0 }).id
	vim.cmd("botright copen")
	vim.cmd.wincmd("p")

	-- Output arrives in a fast context: collect lines there and add them to the
	-- list in scheduled batches of at most BATCH lines, so a burst of output never
	-- blocks the editor for long. The finish line goes in after the last batch.
	local BATCH = 2000
	local pending, head, scheduled, finish = {}, 1, false, nil
	local function flush()
		scheduled = false
		local n = math.min(#pending - head + 1, BATCH)
		if n > 0 then
			local lines = vim.list_slice(pending, head, head + n - 1)
			vim.fn.setqflist({}, "a", { id = id, items = compile_items(lines, efm) })
			head = head + n
			if head > #pending then
				pending, head = {}, 1
			end
		end
		if head <= #pending then
			scheduled = true
			vim.schedule(flush)
		elseif finish then
			vim.fn.setqflist({}, "a", { id = id, items = { { text = finish, valid = false } } })
			finish = nil
		end
	end
	local function reader()
		local partial = ""
		return function(_, data)
			if not data then
				if partial ~= "" then
					pending[#pending + 1] = partial
					partial = ""
				end
				return
			end
			local parts = vim.split(partial .. data, "\n", { plain = true })
			partial = table.remove(parts)
			vim.list_extend(pending, parts)
			if not scheduled then
				scheduled = true
				vim.schedule(flush)
			end
		end
	end

	local job
	job = vim.system({ vim.o.shell, "-c", cmd }, {
		cwd = vim.fn.getcwd(),
		env = { NO_COLOR = "1" },
		stdout = reader(),
		stderr = reader(),
	}, function(out)
		vim.schedule(function()
			local secs = (vim.uv.hrtime() - started) / 1e9
			local status = out.code == 0 and "finished" or ("exited abnormally with code " .. out.code)
			finish = string.format("Compilation %s at %s, duration %.2f s", status, os.date("%H:%M:%S"), secs)
			if not scheduled then
				flush()
			end
			if compile.job == job then
				compile.job = nil
			end
		end)
	end)
	compile.job = job
end

local function prompt_compile()
	vim.ui.input({ prompt = "Compile command: ", default = compile.cmd or "make -k " }, function(cmd)
		if cmd and vim.trim(cmd) ~= "" then
			run_compile(cmd)
		end
	end)
end

vim.api.nvim_create_user_command("Compile", function(opts)
	if opts.args ~= "" then
		run_compile(opts.args)
	else
		prompt_compile()
	end
end, { nargs = "*", complete = "shellcmd", desc = "Run a command, output to quickfix (Emacs compile)" })
map("n", "<leader>cc", prompt_compile, { desc = "Compile" })

-- gr reruns the compile from its quickfix list: evil-collection's recompile key
-- in Emacs. Anywhere else it stays the normal gr. nowait: fire without waiting
-- for the grn/grr LSP defaults.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function(args)
		map("n", "gr", function()
			local title = vim.fn.getqflist({ title = 0 }).title
			local is_qf = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].loclist == 0
			if is_qf and compile.cmd and title == "Compile: " .. compile.cmd then
				vim.schedule(function()
					run_compile(compile.cmd)
				end)
				return ""
			end
			return "gr"
		end, { buffer = args.buf, expr = true, nowait = true, desc = "Recompile" })
	end,
})
