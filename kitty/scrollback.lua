-- kitty scrollback pager: vim motions, search and yank over the scrollback,
-- with kitty's colors. Neovim reads the piped scrollback into the buffer; its
-- ANSI codes are replayed into a terminal buffer, which renders them.
-- Loaded from kitty.conf's scrollback_pager with --clean, so none of your
-- Neovim config or plugins load and it opens instantly.

vim.o.number = false
vim.o.relativenumber = false
vim.o.signcolumn = "no"
vim.o.laststatus = 0
vim.o.showmode = false
vim.o.ruler = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.clipboard = "unnamedplus"

vim.keymap.set("n", "q", "<cmd>qa!<CR>")
-- Visual <CR>: copy the selection and close, like kitty's own copy-and-exit.
vim.keymap.set("x", "<CR>", '"+y<cmd>qa!<CR>')

---@param input_line integer kitty's INPUT_LINE_NUMBER: scrollback line at the top of the screen
---@param cursor_line integer kitty's CURSOR_LINE: cursor row on screen, 1-based
---@param cursor_col integer kitty's CURSOR_COLUMN: cursor column on screen, 1-based
function Scrollback(input_line, cursor_line, cursor_col)
	local stdin_buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(stdin_buf, 0, -1, false)

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].scrollback = 100000 -- terminal default is 10000 lines
	vim.api.nvim_win_set_buf(0, buf)
	vim.api.nvim_buf_delete(stdin_buf, { force = true })

	local chan = vim.api.nvim_open_term(buf, {})
	vim.api.nvim_chan_send(chan, table.concat(lines, "\r\n"))

	-- The terminal renders asynchronously and follows its output to the end;
	-- place the view only once every line has arrived.
	vim.schedule(function()
		vim.wait(1000, function()
			return vim.api.nvim_buf_line_count(buf) >= #lines
		end, 5)
		local last = vim.api.nvim_buf_line_count(buf)
		local top = math.max(1, math.min(input_line, last))
		vim.api.nvim_win_set_cursor(0, { top, 0 })
		vim.cmd("normal! zt")
		-- cursor_line is 0 when there is no cursor (last command output): stay on top.
		local row = math.max(top, math.min(top + cursor_line - 1, last))
		vim.api.nvim_win_set_cursor(0, { row, math.max(cursor_col - 1, 0) })
	end)
end
