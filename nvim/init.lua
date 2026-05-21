-- ============================================================================
-- OPTIONS
-- ============================================================================

vim.g.mapleader          = " "
vim.g.maplocalleader     = " "
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt
opt.number         = true
opt.relativenumber = true
opt.tabstop        = 2
opt.shiftwidth     = 2
opt.expandtab      = true
opt.smartindent    = true
opt.wrap           = false
opt.cursorline     = true
opt.termguicolors  = true
opt.signcolumn     = "yes"
opt.updatetime     = 250
opt.timeoutlen     = 300
opt.undofile       = true
opt.swapfile       = false
opt.backup         = false
opt.splitbelow     = true
opt.splitright     = true
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.ignorecase     = true
opt.smartcase      = true
opt.hlsearch       = true
opt.clipboard      = "unnamedplus"
opt.mouse          = "a"
opt.showmode       = false
opt.pumheight      = 10
opt.completeopt    = "menu,menuone,noselect"
opt.fileencoding   = "utf-8"
opt.guifont        = "JetBrainsMono Nerd Font Mono:h13"
opt.winborder      = "single"

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
map("v", "<",     "<gv")
map("v", ">",     ">gv")

map("n", "<A-j>", "<cmd>m .+1<CR>==")
map("n", "<A-k>", "<cmd>m .-2<CR>==")
map("v", "<A-j>", "<cmd>m '>+1<CR>gv=gv")
map("v", "<A-k>", "<cmd>m '<-2<CR>gv=gv")

map("n", "<leader>sv", "<cmd>vsplit<CR>")
map("n", "<leader>sh", "<cmd>split<CR>")

map("n", "<S-h>", "<cmd>bprev<CR>")
map("n", "<S-l>", "<cmd>bnext<CR>")

map("n", "[d",         vim.diagnostic.goto_prev)
map("n", "]d",         vim.diagnostic.goto_next)
map("n", "<leader>ld", vim.diagnostic.open_float)

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
  "https://github.com/sindrets/diffview.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/williamboman/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/creativenull/efmls-configs-nvim",
})

-- ============================================================================
-- THEME: kanagawa
-- ============================================================================

require("kanagawa").setup({
  compile     = false,
  undercurl   = true,
  transparent = true,
  theme       = "dragon",
  overrides = function(colors)
    return {
      BlinkCmpMenu = { bg = colors.palette.dragonBlack3 },
      BlinkCmpLabelDetail = { bg = colors.palette.dragonBlack3 },
      BlinkCmpMenuSelection = { bg = colors.palette.dragonBlue },
    }
  end,
})
vim.cmd.colorscheme("kanagawa")

-- ============================================================================
-- MINI.NVIM
-- Modules: icons, statusline, pairs, comment, surround, indentscope, bufremove
-- ============================================================================

require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()
require("mini.statusline").setup({ use_icons = true })
require("mini.pairs").setup()
require("mini.comment").setup()
require("mini.surround").setup()
require("mini.indentscope").setup({
  symbol  = "│",
  options = { try_as_border = true },
})
require("mini.bufremove").setup()
map("n", "<leader>bd", function()
  require("mini.bufremove").delete()
end, { desc = "Delete buffer" })

-- ============================================================================
-- FILE TREE: nvim-tree
-- <leader>e  toggle
-- ============================================================================

require("nvim-tree").setup({
  view     = { width = 30 },
  renderer = {
    group_empty = true,
    icons       = { show = { git = true } },
  },
  filters  = { dotfiles = false },
  git      = { enable = true },
  actions  = { open_file = { quit_on_open = false } },
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
    "lua", "python", "javascript", "typescript", "tsx",
    "rust", "go", "c", "cpp", "bash",
    "json", "yaml", "toml", "markdown", "html", "css",
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
    add          = { text = "▎" },
    change       = { text = "▎" },
    delete       = { text = "" },
    topdelete    = { text = "" },
    changedelete = { text = "▎" },
  },
  on_attach = function(buffer)
    local gs   = package.loaded.gitsigns
    local gmap = function(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
    end
    gmap("n", "]h",         gs.next_hunk,    "Next Hunk")
    gmap("n", "[h",         gs.prev_hunk,    "Prev Hunk")
    gmap("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
    gmap("n", "<leader>gs", gs.stage_hunk,   "Stage Hunk")
    gmap("n", "<leader>gr", gs.reset_hunk,   "Reset Hunk")
    gmap("n", "<leader>gb", gs.blame_line,   "Blame Line")
  end,
})

-- ============================================================================
-- DIFFVIEW
-- <leader>gd  open diff   <leader>gh  file history   <leader>gc  close
-- ============================================================================

require("diffview").setup()
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>",        { desc = "Diff View" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "File History" })
map("n", "<leader>gc", "<cmd>DiffviewClose<cr>",       { desc = "Close Diff" })

-- ============================================================================
-- FUZZY FINDER: fzf-lua
-- <leader>ff  files   <leader>fg  grep    <leader>fb  buffers
-- <leader>fh  help    <leader>fd  diag    <leader>fr  recent
-- ============================================================================

require("fzf-lua").setup({
  winopts = {
    height  = 0.85,
    width   = 0.85,
    preview = { layout = "horizontal", ratio = 0.5 },
  },
  defaults = {
    header  = false,
  },
})
map("n", "<leader>ff", "<cmd>FzfLua files<cr>",                { desc = "Files" })
map("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>",            { desc = "Live Grep" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<cr>",              { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>",            { desc = "Help" })
map("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Diagnostics" })
map("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>",             { desc = "Recent Files" })

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
  keymap     = {
    preset = "none",
    ["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
  },
  appearance = {
    nerd_font_variant       = "mono",
  },
  sources  = { default = { "lsp", "path", "snippets", "buffer" } },
  snippets = { preset = "luasnip" },
  signature = { enabled = true },
})

-- ============================================================================
-- MASON: LSP/tool installer  (:Mason to open UI)
-- Install servers: lua_ls, pyright, ts_ls, rust_analyzer, gopls, efm
-- Install tools:   stylua, black, flake8, prettier, eslint_d
-- ============================================================================

require("mason").setup({
  ui = {
    icons = {
      package_installed   = "✓",
      package_pending     = "➜",
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
    lmap("n", "gd",         vim.lsp.buf.definition,                             "Go to Definition")
    lmap("n", "gD",         vim.lsp.buf.declaration,                            "Go to Declaration")
    lmap("n", "gr",         vim.lsp.buf.references,                             "References")
    lmap("n", "gi",         vim.lsp.buf.implementation,                         "Implementation")
    lmap("n", "K",          vim.lsp.buf.hover,                                       "Hover")
    lmap("n", "<leader>lr", vim.lsp.buf.rename,                                 "Rename")
    lmap("n", "<leader>la", vim.lsp.buf.code_action,                            "Code Action")
    lmap("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format")
  end,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace   = { checkThirdParty = false },
      telemetry   = { enable = false },
    },
  },
})

-- Add/remove servers to match what you install via Mason
vim.lsp.enable({ "lua_ls", "pyright", "ts_ls", "rust_analyzer", "gopls" })

vim.diagnostic.config({
  virtual_text     = { prefix = "●" },
  signs            = true,
  underline        = true,
  update_in_insert = false,
  float            = { source = "always" },
})

-- ============================================================================
-- EFM FORMATTERS / LINTERS: efmls-configs-nvim
-- Requires efm-langserver installed via Mason.
-- Add/remove formatters and linters per language as needed.
-- ============================================================================

local languages = {
  lua             = { require("efmls-configs.formatters.stylua") },
  python          = { require("efmls-configs.formatters.black"),      require("efmls-configs.linters.flake8") },
  javascript      = { require("efmls-configs.formatters.prettier_d"), require("efmls-configs.linters.eslint_d") },
  typescript      = { require("efmls-configs.formatters.prettier_d"), require("efmls-configs.linters.eslint_d") },
  typescriptreact = { require("efmls-configs.formatters.prettier_d"), require("efmls-configs.linters.eslint_d") },
  go              = { require("efmls-configs.formatters.goimports") },
}

vim.lsp.config("efm", {
  filetypes = vim.tbl_keys(languages),
  settings  = {
    rootMarkers = { ".git/" },
    languages   = languages,
  },
  init_options = {
    documentFormatting      = true,
    documentRangeFormatting = true,
  },
})
vim.lsp.enable("efm")
