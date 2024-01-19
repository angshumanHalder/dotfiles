local status, ts = pcall(require, "nvim-treesitter.configs")
if (not status) then
  print("failed to load nvim-treesitter.configs")
  return
end

ts.setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = { "markdown" },
  },
  indent = {
    enable = true,
    disable = {},
  },
  ensure_installed = "all",
  autotag = {
    enable = true,
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = "o",
      toggle_hl_groups = "i",
      toggle_injected_languages = "t",
      toggle_anonymous_nodes = "a",
      toggle_language_display = "I",
      focus_language = "f",
      unfocus_language = "F",
      update = "R",
      goto_node = "<cr>",
      show_help = "?",
    },
  },
})

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }