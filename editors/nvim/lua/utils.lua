-- TODO: Change it to module
if vim.g.started_by_firenvim then
	do return end
end


local default_opts = { silent = true }
function map(mode, l, r, desc, opts)
	opts = opts or default_opts
	opts.desc = desc
	vim.keymap.set(mode, l, r, opts)
end

function map_buffer(bufid, mode, l, r, desc, opts)
	opts = opts or default_opts
	opts.buffer = bufid
	opts.desc = desc
	vim.keymap.set(mode, l, r, opts)
end

local api = vim.api
local function termcodes(s)
	return api.nvim_replace_termcodes(s, true, true, true)
end

local file_exists = function(name)
	local f = io.open(name, 'r')
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

NO_SUDO = file_exists(os.getenv('HOME') .. '/.no_sudo_indicator')
IS_REMOTE = file_exists(os.getenv('HOME') .. '/.remote_indicator')


smart_split = function(direction)
	local ft = api.nvim_buf_get_option(0, 'filetype')
	if ft == 'toggleterm' then
		open_new_terminal(direction)
	else
		if direction == 'vertical' then
			api.nvim_input('<cmd>vsplit<cr>')
		else
			api.nvim_input('<cmd>split<cr>')
		end
	end
end

close_pane = function()
	local bufnr = api.nvim_get_current_buf()
	if #api.nvim_list_wins() == 1 then -- Sometimes its reports 2 instead of 1
		api.nvim_feedkeys(':q\n', 'n', false)
		return
	end
	api.nvim_win_close(0, true)
	if not buf_is_visible(bufnr) then
		if api.nvim_buf_is_loaded(bufnr) then
			require('bufdelete').bufdelete(bufnr, true)
		end
	end
end


goto_next_diag = function()
	local next = vim.diagnostic.get_next()
	if next == nil then
		return
	end
	api.nvim_win_set_cursor(0, { next.lnum + 1, next.col })
	center_screen()
end

goto_prev_diag = function()
	local prev = vim.diagnostic.get_prev(opts)
	if not prev then
		return
	end
	api.nvim_win_set_cursor(0, { prev.lnum + 1, prev.col })
	center_screen()
end

get_current_lsp_server_name = function()
	local msg = '———'
	local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
	local clients = vim.lsp.get_active_clients()
	if next(clients) == nil then
		return msg
	end
	for _, client in ipairs(clients) do
		local filetypes = client.config.filetypes
		if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
			return client.name
		end
	end
	return msg
end

node_relative_path = function(node)
	return vim.fn.fnamemodify(node.absolute_path, ':~:.')
end

search_in_path = function(node)
	opts = {}
	opts.default_text = '-g"' .. node_relative_path(node) .. '/**" "'
	require('telescope').extensions.live_grep_args.live_grep_args(opts)
end

find_in_path = function(node)
	find_files(nil, node_relative_path(node))
end

git_hist_path = function(node)
	vim.fn.execute('DiffviewFileHistory ' .. node_relative_path(node))
end

yank_line = function(count)
	local cursor = api.nvim_win_get_cursor(0)
	local line_index = cursor[1] + count - 1
	local lines = api.nvim_buf_get_lines(0, line_index, line_index + 1, true)

	api.nvim_buf_set_lines(0, cursor[1] - 1, cursor[1], true, lines)
end

------------------------------
--------- Telescope ---------
------------------------------

local Terminal = require('toggleterm.terminal').Terminal
local deployTerminal = nil
function reset_deploy()
	deployTerminal = Terminal:new({ cmd = 'deploy', dir = '%:p:h' })
end

reset_deploy()

function deploy()
	deployTerminal:toggle()
end

function restart_nvim()
	vim.fn.system('touch /tmp/restart_nvim')
	api.nvim_feedkeys(':wqa\n', 'n', false)
end
