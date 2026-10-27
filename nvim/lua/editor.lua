-- Editor: theme, UI, navigation, files, projects, pickers, terminal, org, agent chat

local map = vim.keymap.set

-- ============================================================================
-- THEME: Kanso Ink
-- ============================================================================

require("kanso").setup({
	transparent = true,
	overrides = function()
		return {
			WinSeparator = { fg = "#22262D" }, -- Kanso ink line colour
			AgenticDiffDeleteWord = { link = "DiffDelete" },
			AgenticDiffAddWord = { link = "DiffAdd" },
			AgenticStatusPending = { link = "DiagnosticWarn" },
			AgenticStatusCompleted = { link = "DiagnosticOk" },
			AgenticStatusFailed = { link = "DiagnosticError" },
			AgenticPermissionButtonAllow = { link = "DiagnosticOk" },
			AgenticPermissionButtonReject = { link = "DiagnosticError" },
			AgenticPermissionButtonInactive = { link = "Comment" },
			AgenticTitle = { link = "PmenuSel" },
			AgenticSpinnerGenerating = { link = "MoreMsg" },
			AgenticSpinnerThinking = { link = "Special" },
			AgenticSpinnerSearching = { link = "DiagnosticWarn" },
			WindowPickerStatusLine = { link = "NvimTreeWindowPicker" },
			WindowPickerStatusLineNC = { link = "NvimTreeWindowPicker" },
			WindowPickerWinBar = { link = "NvimTreeWindowPicker" },
			WindowPickerWinBarNC = { link = "NvimTreeWindowPicker" },
		}
	end,
})
vim.cmd.colorscheme("kanso-ink")

-- ============================================================================
-- MINI.NVIM
-- Modules: icons, statusline, pairs, surround, ai, clue
-- ============================================================================

require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()
require("mini.statusline").setup({ use_icons = true })

require("mini.pairs").setup()
-- Surround keys are shared with Emacs: sa{motion}{char} add, sd{char} delete, sr{old}{new} change.
require("mini.surround").setup()
require("mini.ai").setup({ n_lines = 500 })
require("Comment").setup()

local clue = require("mini.clue")
clue.setup({
	triggers = {
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
	},
	clues = {
		{ mode = "n", keys = "<Leader>a", desc = "+Agent" },
		{ mode = "x", keys = "<Leader>a", desc = "+Agent" },
		{ mode = "n", keys = "<Leader>b", desc = "+Buffer" },
		{ mode = "n", keys = "<Leader>c", desc = "+Compile" },
		{ mode = "n", keys = "<Leader>f", desc = "+Find" },
		{ mode = "n", keys = "<Leader>g", desc = "+Git" },
		{ mode = "n", keys = "<Leader>l", desc = "+LSP" },
		{ mode = "x", keys = "<Leader>l", desc = "+LSP" },
		{ mode = "n", keys = "<Leader>p", desc = "+Project" },
		{ mode = "n", keys = "<Leader>q", desc = "+Quit" },
		{ mode = "n", keys = "<Leader>s", desc = "+Search/Scratch" },
		{ mode = "x", keys = "<Leader>s", desc = "+Search" },
		{ mode = "n", keys = "<Leader>t", desc = "+Terminal" },
		{ mode = "n", keys = "<Leader>o", desc = "+Org" },
		clue.gen_clues.builtin_completion(),
		clue.gen_clues.marks(),
		clue.gen_clues.registers(),
		clue.gen_clues.windows(),
		clue.gen_clues.z(),
	},
})

-- ============================================================================
-- ORG: org.nvim (agenda, capture, roam, Google calendar via ics)
-- ============================================================================

local calendar_url_file = vim.fn.stdpath("config") .. "/calendar-url"
local calendar_url = vim.fn.filereadable(calendar_url_file) == 1 and vim.fn.readfile(calendar_url_file)[1] or nil

require("org").setup({
	org_directory = "~/Documents/org",
	agenda_files = { "~/Documents/org" },
	extensions = {
		roam = { directory = "~/Documents/org" },
		ics = { calendars = calendar_url and calendar_url ~= "" and { { name = "Google", url = calendar_url } } or {} },
	},
})

-- ============================================================================
-- TODO COMMENTS
-- <leader>st  search todos
-- ============================================================================

load_plugin("todo-comments.nvim", function()
	require("todo-comments").setup()
end)

map("n", "<leader>st", function()
	-- Searches todo-comments' default keywords (TODO, FIX, HACK, WARN, PERF, NOTE, TEST and aliases).
	Snacks.picker.pick(require("todo-comments.snacks").source)
end, { desc = "Todo Comments" })

-- ============================================================================
-- FIND & REPLACE: grug-far
-- <leader>sr  open (current word)   <leader>sR  open (empty)
-- ============================================================================

local function grug_far()
	load_plugin("grug-far.nvim", function()
		require("grug-far").setup()
	end)
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

local function setup_nvim_tree()
	load_plugin("nvim-tree.lua", function()
		load_plugin("nvim-window-picker")

		require("window-picker").setup({
			hint = "statusline-winbar",
			selection_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
			filter_rules = {
				include_current_win = false,
				autoselect_one = true,
				bo = {
					filetype = {
						"NvimTree",
						"snacks_notif",
						"snacks_notif_history",
					},
					buftype = {},
				},
			},
		})

		require("nvim-tree").setup({
			sync_root_with_cwd = true,
			view = { width = 30, preserve_window_proportions = true },
			renderer = {
				group_empty = true,
				icons = { show = { git = true } },
			},
			filters = { dotfiles = false },
			git = { enable = true },
			-- The root follows cwd (project_root autocmd below); update_root would
			-- fall back to the file's own folder for files outside cwd.
			update_focused_file = { enable = true },
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
	end)
end
-- Keep cwd on the current file's Git root, so the tree and pickers show the project.
vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("project_root", { clear = true }),
	nested = true, -- let :cd fire DirChanged, which nvim-tree's sync_root_with_cwd listens to
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end
		local root = vim.fs.root(args.buf, ".git")
		if root and root ~= vim.fn.getcwd() then
			vim.cmd.cd(root)
		end
	end,
})

map("n", "<leader>e", function()
	setup_nvim_tree()
	local equalalways = vim.o.equalalways
	vim.o.equalalways = false
	require("nvim-tree.api").tree.toggle()
	vim.o.equalalways = equalalways
end, { desc = "Toggle file tree" })

-- ============================================================================
-- PROJECTS AND DIRECTORY VIEW
-- <leader>pp  projects   -  directory view
-- ============================================================================

local function open_oil(dir)
	load_plugin("oil.nvim", function()
		require("oil").setup({
			default_file_explorer = false,
			view_options = { show_hidden = true },
			keymaps = {
				["<CR>"] = {
					callback = function()
						require("oil").select({}, function(err)
							if not err and not vim.api.nvim_buf_get_name(0):match("^oil://") then
								vim.wo.number = true
								vim.wo.relativenumber = true
							end
						end)
					end,
					desc = "Open entry",
				},
			},
		})
	end)
	require("oil").open(dir)
end

map("n", "-", function()
	open_oil()
end, { desc = "Browse directory" })
-- Projects are discovered: Git repos under ~/Documents/projects plus recently used ones.
local function pick_project()
	Snacks.picker.projects({
		dev = { "~/Documents/projects" },
		max_depth = 3, -- pomodoro-game/focus-valley sits one level deeper
		patterns = { ".git" }, -- not package.json/Makefile: those match front-end/, A01/ subfolders
		projects = { vim.fn.expand("~/.config") },
		confirm = function(picker, item)
			picker:close()
			if item then
				vim.cmd.cd(item.file)
				Snacks.picker.files({ cwd = item.file })
			end
		end,
	})
end
map("n", "<leader>pp", pick_project, { desc = "Projects" })

-- ============================================================================
-- SNACKS
-- Modules: bigfile, dashboard, indent, notifier, picker, input, image
-- (bufdelete, gitbrowse, scratch and terminal need no setup)
-- <leader>bk  kill buffer   <leader>sc  scratch buffer
-- ============================================================================

-- Project file search. Refuses ~ and /: listing ~ held ~400 MB (766k files).
-- <Tab> inserts the highlighted path into the prompt, like vertico; <S-Tab> multi-selects.
local function project_files()
	local cwd = vim.fs.normalize(vim.fn.getcwd())
	if cwd == vim.fs.normalize("~") or cwd == "/" then
		vim.notify("Not in a project; open one with <leader>fp", vim.log.levels.WARN)
		return
	end
	Snacks.picker.files({
		hidden = true,
		actions = {
			insert_path = function(picker, item)
				if item then
					picker.input:set(vim.fn.fnamemodify(Snacks.picker.util.path(item), ":."))
					picker:find({ refresh = false })
				end
			end,
		},
		win = { input = { keys = { ["<Tab>"] = { "insert_path", mode = { "i", "n" } } } } },
	})
end

require("snacks").setup({
	bigfile = { enabled = true },
	input = { enabled = true, win = { row = 0.5 } },
	picker = { enabled = true, ui_select = true },
	dashboard = {
		enabled = true,
		preset = {
			keys = {
				{ icon = " ", key = "p", desc = "Projects", action = pick_project },
				{
					icon = " ",
					key = "r",
					desc = "Recent Files",
					action = function()
						Snacks.picker.recent()
					end,
				},
				{
					icon = " ",
					key = "g",
					desc = "Live Grep",
					action = function()
						Snacks.picker.grep()
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
	image = { enabled = true, doc = { enabled = false } },
})

-- snacks#2946 (closed, not planned): Image:del() sends the loop index as the
-- kitty placement id, so placements are never deleted and a PNG reopened after
-- another one stays blank. Same function, sending the real id.
function Snacks.image.image:del(pid)
	for _, p in ipairs(pid and { pid } or vim.tbl_keys(self.placements)) do
		if self.placements[p] then
			Snacks.image.terminal.request({ a = "d", d = "i", i = self.id, p = p })
			self.placements[p] = nil
		end
	end
	if not next(self.placements) then
		Snacks.image.terminal.request({ a = "d", d = "i", i = self.id })
	end
end

-- Snacks hides an image buffer's placement when it leaves every window, but
-- only inline images ever call show(): a PNG reopened from another buffer
-- renders blank. Unhide once the buffer is back in a window. placement.new
-- captures update when it is created, so this must run before any image opens.
local update_placement = Snacks.image.placement.update
function Snacks.image.placement:update()
	if self.hidden and #self:wins() > 0 then
		self.hidden = false
	end
	return update_placement(self)
end

map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Kill buffer" })
map("n", "<leader>sc", function()
	Snacks.scratch()
end, { desc = "Scratch Buffer" })

-- Agent chat sidebar (ACP). Keep the plugin unloaded until the pane is opened.
local function agentic()
	load_plugin("agentic.nvim", function()
		-- provider: used only by history restore when no chat is open.
		-- session_scope: each project gets its own chat session.
		require("agentic").setup({ provider = "codex-acp", settings = { session_scope = "project" } })
	end)
	return require("agentic")
end
map("n", "<leader>at", function()
	local chat = agentic()
	if require("agentic.session_registry").current() then
		chat.toggle()
	else
		chat.new_session_with_provider()
	end
end, { desc = "Toggle agent chat (pick provider on first open)" })
map("n", "<leader>ah", function()
	agentic().restore_session()
end, { desc = "Load chat history" })
map("n", "<leader>an", function()
	agentic().new_session()
end, { desc = "New agent chat" })
map("n", "<leader>aN", function()
	agentic().new_session_with_provider()
end, { desc = "New agent chat (pick provider)" })
map({ "n", "x" }, "<leader>ac", function()
	agentic().add_selection_or_file_to_context()
end, { desc = "Send selection to agent chat" })
map("n", "<leader>af", function()
	agentic().add_file()
end, { desc = "Send file to agent chat" })

-- ============================================================================
-- TERMINAL (Snacks; mirrors the Emacs ghostel toggles, one shell per project)
-- <leader>tt  bottom terminal   <leader>tT  full-window terminal   <Esc><Esc>  normal mode
-- ============================================================================

map("n", "<leader>tt", function()
	Snacks.terminal.toggle(nil, { count = 1, win = { position = "bottom", height = 0.3 } })
end, { desc = "Toggle bottom terminal" })

-- Snacks hides a "current"-window terminal by closing the window, so switching
-- back to the previous buffer (Emacs switch-to-prev-buffer) stays here.
local before_full_term
map("n", "<leader>tT", function()
	local opts = { count = 2, win = { position = "current" } }
	local term = Snacks.terminal.get(nil, { count = 2, create = false, win = opts.win })
	if term and vim.api.nvim_get_current_buf() == term.buf then
		if before_full_term and vim.api.nvim_buf_is_valid(before_full_term) then
			vim.api.nvim_win_set_buf(0, before_full_term)
		else
			vim.cmd.bprevious()
		end
		return
	end
	before_full_term = vim.api.nvim_get_current_buf()
	local created
	term, created = Snacks.terminal.get(nil, opts)
	if not created then
		term:show()
		vim.cmd.startinsert()
	end
end, { desc = "Toggle full-window terminal" })

-- ============================================================================
-- FUZZY FINDER: Snacks picker (also serves vim.ui.select, so every prompt looks the same)
-- <leader>ff  project files   <leader>.  find file by path   <leader>fg  grep
-- <leader>fb  buffers   <leader>fh  help   <leader>fr  recent   <leader>fs  symbols
-- Inside a picker: <A-h> toggle hidden, <A-i> toggle ignored
-- ============================================================================

map("n", "<leader>ff", project_files, { desc = "Project files" })

-- Emacs find-file: the query is a path; <Tab> completes it to the selected entry.
map("n", "<leader>.", function()
	Snacks.picker.pick({
		title = "Find file",
		live = true,
		search = vim.fn.getcwd() .. "/",
		finder = function(_, ctx)
			local path = vim.fn.fnamemodify(ctx.filter.search, ":p")
			local dir, prefix = path:match("^(.*/)([^/]*)$")
			local items = {}
			if not dir or vim.fn.isdirectory(dir) == 0 then
				return items
			end
			for name, type in vim.fs.dir(dir) do
				if vim.startswith(name, prefix) then
					items[#items + 1] = { file = dir .. name, text = dir .. name, dir = type == "directory" }
				end
			end
			table.sort(items, function(a, b)
				return a.file < b.file
			end)
			return items
		end,
		format = "file",
		actions = {
			complete = function(picker, item)
				if item then
					picker.input:set(nil, item.file .. (item.dir and "/" or ""))
					picker:find() -- set() alone does not re-run a live finder
				end
			end,
		},
		win = { input = { keys = { ["<Tab>"] = { "complete", mode = { "i", "n" } } } } },
		confirm = function(picker, item)
			-- No match: open the typed path, creating the file like Emacs does.
			local path = item and item.file or vim.fn.fnamemodify(picker.input.filter.search, ":p")
			picker:close()
			if vim.fn.isdirectory(path) == 1 then
				open_oil(path)
			else
				vim.cmd.edit(vim.fn.fnameescape(path))
			end
		end,
	})
end, { desc = "Find file by editable path" })
-- Emacs consult-imenu: LSP symbols, headings in prose, Treesitter otherwise.
local heading_patterns = { markdown = "^#", org = "^*" }
map("n", "<leader>fs", function()
	if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/documentSymbol" }) > 0 then
		Snacks.picker.lsp_symbols()
	elseif heading_patterns[vim.bo.filetype] then
		Snacks.picker.lines({ pattern = heading_patterns[vim.bo.filetype] })
	else
		Snacks.picker.treesitter()
	end
end, { desc = "Symbols" })
map("n", "<leader>fg", Snacks.picker.grep, { desc = "Live Grep" })
map("n", "<leader>fb", Snacks.picker.buffers, { desc = "Buffers" })
map("n", "<leader>fh", Snacks.picker.help, { desc = "Help" })
map("n", "<leader>fr", Snacks.picker.recent, { desc = "Recent Files" })
map("n", "<leader>?", Snacks.picker.keymaps, { desc = "Keymaps" })

-- ============================================================================
-- RENDER-MARKDOWN: modern rendering for markdown files
-- Renders headings, bullets, checkboxes, code blocks, tables inline
-- ============================================================================

-- Config must be set before the plugin loads, so it is loaded here, not via setup().
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	once = true,
	callback = function()
		vim.g.render_markdown_config = {
			latex = { enabled = false },
			heading = { sign = false },
			checkbox = { checked = { icon = "✓ " } },
			code = { sign = false, border = "thin", width = "block", min_width = 40 },
			pipe_table = { enabled = false },
		}
		load_plugin("render-markdown.nvim")
	end,
})
