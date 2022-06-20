require('Comment').setup{
}

require('nvim-autopairs').setup{
	check_ts = true,
	-- enable_moveright = false,
}

local autosave = require('autosave')
autosave.setup{
	clean_command_line_interval = 1000,
	on_off_commands = true,
}

autosave.hook_before_actual_saving = function ()
	mode = vim.api.nvim_get_mode()
	if mode.mode ~= 'n' then -- Don't save while we in insert/select mode (triggered with autopair and such)
		vim.g.auto_save_abort = true
	end
end

require'nvim-lastplace'.setup{
}

require'sniprun'.setup{
	display = {
		"Classic"
	}
}

require("revj").setup{
	new_line_before_last_bracket = false,
	add_seperator_for_last_parameter = false,
	enable_default_keymaps = true,
}

require('numb').setup{
}

local node_relative_path = function(node)
	return vim.fn.fnamemodify(node.absolute_path, ":~:.")
end

local find_in_path = function(node)
	opts = {}
	opts.default_text = '-g"'.. node_relative_path(node) .. '/**" "'
	require('telescope').extensions.live_grep_raw.live_grep_raw(opts)
end

local git_hist_path = function(node)
	vim.fn.execute('DiffviewFileHistory ' .. node_relative_path(node))
end

require'nvim-tree'.setup {
	view = {
		mappings = {
			list = {
				{ key = "<Escape>", action = "close_node" },
				{ key = "f", action = "find in path", action_cb = find_in_path },
				{ key = "gh", action = "git history in path", action_cb = git_hist_path },
			}
		}
	}
}

vim.api.nvim_create_autocmd('BufWinEnter', {
	pattern = '*',
	callback = function()
		if vim.bo.filetype == 'NvimTree' then
			require'bufferline.state'.set_offset(31)
		end
	end
})

vim.api.nvim_create_autocmd('BufWinLeave', {
	pattern = '*',
	callback = function()
		if vim.fn.expand('<afile>'):match('NvimTree') then
			require'bufferline.state'.set_offset(0)
		end
	end
})

vim.cmd([[
command! Locate execute 'NvimTreeFindFile'
]])

vim.cmd([[
let g:XkbSwitchLib = '/usr/local/lib/libg3kbswitch.so'
let g:XkbSwitchEnabled = 1
]])

-- venn.nvim: enable or disable keymappings
function _G.Toggle_Draw()
	local venn_enabled = vim.inspect(vim.b.venn_enabled)
	if venn_enabled == "nil" then
		vim.b.venn_enabled = true
		vim.cmd[[setlocal ve=all]]
		-- draw a line on HJKL keystokes
		vim.api.nvim_buf_set_keymap(0, "n", "J", "<C-v>j:VBox<CR>", {noremap = true})
		vim.api.nvim_buf_set_keymap(0, "n", "K", "<C-v>k:VBox<CR>", {noremap = true})
		vim.api.nvim_buf_set_keymap(0, "n", "KJ", "<C-v>k:VBox<CR>", {noremap = true})
		vim.api.nvim_buf_set_keymap(0, "n", "KK", "<C-v>k:VBox<CR>", {noremap = true})
		vim.api.nvim_buf_set_keymap(0, "n", "L", "<C-v>l:VBox<CR>", {noremap = true})
		vim.api.nvim_buf_set_keymap(0, "n", "H", "<C-v>h:VBox<CR>", {noremap = true})
		-- draw a box by pressing "f" with visual selection
		vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", {noremap = true})
		vim.api.nvim_buf_set_keymap(0, "n", "<Escape>", ":lua Toggle_Draw()<CR>", {noremap = true})
		print('Entered Draw Mode')
	else
		vim.cmd[[setlocal ve=]]
		vim.cmd[[mapclear <buffer>]]
		vim.b.venn_enabled = nil
		print('Exited Draw Mode')
	end
end

vim.cmd([[
command! Draw execute 'lua Toggle_Draw()'
]])

if IS_REMOTE then
	-- Enable osc(remote) yank
	vim.cmd([[
	autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '+' | execute 'OSCYankReg +' | endif
	]])
end

vim.g.undotree_WindowLayout = 3 -- undotree at right

-- registers.nvim
vim.g.registers_show = '\"*+-/_=#%.0123456789abcdefghijklmnopqrstuvwxyz:' -- move " register to first
vim.g.registers_paste_in_normal_mode = 2

-- toggleterm.nvim
require("toggleterm").setup {
	open_mapping = [[<C-t>]],
	insert_mappings = false,
	terminal_mappings = true,
	direction = 'horizontal',
}
vim.api.nvim_set_keymap('n', '<leader>t', '<cmd>ToggleTerm<CR>', {noremap = true})

-- guess-indent.nvim
require('guess-indent').setup{}

-- refactoring.nvim
require('refactoring').setup{}

-- vim-maximizer
vim.g.maximizer_default_mapping_key = '<M-Z>'

-- rust.vim
-- vim.g.rustfmt_autosave = 1

-- trld.nvim
require('trld').setup{
	auto_cmds = false,
}
vim.api.nvim_create_autocmd('CursorHold', {
	pattern = '*',
	callback = function() TRLDShow() end
})

vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI', 'InsertEnter'}, {
	pattern = '*',
	callback = function() TRLDHide() end
})

-- tmuxjump.vim
vim.g.tmuxjump_telescope = true
vim.g.tmuxjump_custom_capture = "~/dotfiles_scripts/inner/_tmuxjump_capture.sh"

-- todo-comments.nvim
require('todo-comments').setup{
	signs = false,
	highlight = {
		before = '',
		keyword = 'fg',
		after = ''
	},
	colors = {
		error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
		warning = { "TSDanger", "DiagnosticWarning", "WarningMsg", "#FBBF24" },
		info = { "TSWarning", "DiagnosticInfo", "#2563EB" },
		hint = { "TSFuncBuiltin", "DiagnosticHint", "#10B981" },
		default = { "TSNumber", "Identifier", "#7C3AED" },
	},
}

-- iron.nvim
require("iron.core").setup {
	config = {
		should_map_plug = false,
		scratch_repl = true,
		repl_definition = {
			sh = {
				command = {"zsh"}
			}
		},
		repl_open_cmd = 'belowright 15 split',
	},
	keymaps = {
		send_motion = "<space>sc",
		visual_send = "<space>sc",
		send_file = "<space>sf",
		send_line = "<space>sl",
		cr = "<space>s<cr>",
		interrupt = "<space>s<space>",
		exit = "<space>sq",
		clear = "<space>cl",
	},
	highlight = {
		italic = false,
		bold = false
	}
}

-- nvim-colorizer.lua
require('colorizer').setup{
	'*'
}

-- nvim-pasta
require('pasta').setup{
}
