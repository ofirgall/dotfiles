local api = vim.api

vim.g.gitblame_display_virtual_text = 0
vim.g.gitblame_message_template = '<author> • <date>'
vim.g.gitblame_date_format = '%d/%m/%Y'

-- customized modus-vivendi
if not vim.g.started_by_firenvim then
	local gps = require("nvim-gps")
	local lsp_gps = require("nvim-navic")

	local lsp_server_component = {
		function()
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
		end,
		icon = ' LSP:',
	}

	local is_treesitter_gps_available = function()
		return not lsp_gps.is_available() and gps.is_available()
	end

	y_section = {}
	if vim.fn.has('wsl') == 1 then -- don't use git blame in wsl because of performance
		vim.g.gitblame_enabled = 0
	else
		local git_blame = require("gitblame")
		table.insert(y_section, { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available })
	end

	require 'lualine'.setup {
		options = {
			theme = require('ofirkai.statuslines.lualine').theme,
			icons_enabled = true,
			path = 1,
			always_divide_middle = false,
		},
		sections = {
			lualine_b = { 'branch', 'diff', 'diagnostics' },
			lualine_c = {
				{ 'filename', shorting_target = 0 },
				{ lsp_gps.get_location, cond = lsp_gps.is_available },
				{ gps.get_location, cond = is_treesitter_gps_available },
			},
			lualine_x = { lsp_server_component },
			lualine_y = y_section,
			lualine_z = { 'filetype' },
		},
	}

	-- Load lualine late (buggy if not)
	late_lualine_setup_id = vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertEnter' }, {
		pattern = '*',
		callback = function()
			require('lualine').setup()
			vim.opt.laststatus = 3
			vim.api.nvim_del_autocmd(late_lualine_setup_id)
		end
	})
end

require('ofirkai').setup {
}

vim.opt.list = true
vim.opt.listchars:append("space:⋅")
require("indent_blankline").setup {
	use_treesitter = true,
	show_trailing_blankline_indent = false,
	space_char_blankline = " ",
}

require('dressing').setup {
	input = {
		insert_only = false,
		start_in_insert = false,

		max_width = { 140, 0.9 },
		min_width = { 60, 0.2 },

		winblend = 0,

		mappings = {
			n = {
				["q"] = "Close",
				["<Esc>"] = "Close",
				["<CR>"] = "Confirm",
				["<C-p>"] = "HistoryPrev",
				["<C-n>"] = "HistoryNext",
			},
			i = {
				["<M-q>"] = "Close",
				["<C-c>"] = "Close",
				["<CR>"] = "Confirm",
				["<Up>"] = "HistoryPrev",
				["<Down>"] = "HistoryNext",
				["<C-p>"] = "HistoryPrev",
				["<C-n>"] = "HistoryNext",
			},
		}
	},
}

require('treesitter-context').setup {
}

if not vim.g.started_by_firenvim then
	-- bufferline.nvim, must be loaded after color scheme
	require('bufferline').setup {
		options = {
			separator_style = 'slant',
			offsets = { { filetype = 'NvimTree', text = 'File Explorer', text_align = 'center' } },
			show_buffer_icons = true,
			themable = true,
			numbers = 'ordinal',
			max_name_length = 40,
			-- max_prefix_length = 15,
			-- tab_size = 18,
		},
		highlights = require('ofirkai.tablines.bufferline').highlights
	}

	-- WSL 1 is too slow for that
	if vim.fn.has('wsl') == 0 then
		local tint_ft_ignore = {
			'toggleterm',
			'NvimTree',
			'DiffviewFiles',
		}
		require('tint').setup({
			tint = -45,
			saturation = 0.6,
			highlight_ignore_patterns = { 'WinSeparator', 'Status.*', 'IndentBlankline', 'EndOfBuffer' },
			window_ignore_function = function(winid)
				local bufid = api.nvim_win_get_buf(winid)
				local buf_ft = api.nvim_buf_get_option(bufid, 'filetype')

				for _, ft in ipairs(tint_ft_ignore) do
					if buf_ft == ft then
						return true
					end
				end

				local floating = api.nvim_win_get_config(winid).relative ~= ''
				local diff = api.nvim_get_option_value('diff', { buf = bufid })

				if floating or diff then
					return false
				end

				return floating
			end
		})
	end
end
