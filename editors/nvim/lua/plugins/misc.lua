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
	require('telescope').extensions.live_grep_args.live_grep_args(opts)
end

local git_hist_path = function(node)
	vim.fn.execute('DiffviewFileHistory ' .. node_relative_path(node))
end

require'nvim-tree'.setup {
	view = {
		adaptive_size = true,
		mappings = {
			list = {
				{ key = "<Escape>", action = "close_node" },
				{ key = "f", action = "find in path", action_cb = find_in_path },
				{ key = "gh", action = "git history in path", action_cb = git_hist_path },
			}
		}
	},
	renderer = {
		symlink_destination = false
	}
}

vim.api.nvim_create_user_command('Locate', ':NvimTreeFindFile', {})

vim.cmd([[
let g:XkbSwitchLib = '/usr/local/lib/libg3kbswitch.so'
let g:XkbSwitchEnabled = 1
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

-- color-picker.nvim
require('color-picker').setup{
}

-- go.nvim
require('go').setup{
	lsp_keymaps = false,
	dap_debug_keymap = false,
	textobjects = false,
}

-- markdown-preview.nvim
vim.g.mkdp_auto_close = 0

-- leap.nvim
require('leap').set_default_keymaps()
require('leap').setup {
	max_aot_targets = nil,
	highlight_unlabeled = false,
}

-- neoscroll.nvim
local neoscroll = require('neoscroll')
neoscroll.setup{
	mappings = {'<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>'}, -- Dont override zz/zt/zb
}
-- Recenter after scroll
local scroll_speed = 150
vim.keymap.set('n', '<C-u>', function()
	neoscroll.scroll(-vim.wo.scroll, true, scroll_speed)
	vim.api.nvim_feedkeys('zz', 'n', false)
end, {})
vim.keymap.set('n', '<C-d>', function()
	neoscroll.scroll(vim.wo.scroll, true, scroll_speed)
	vim.api.nvim_feedkeys('zz', 'n', false)
end, {})
