local M = {}

local function get_current_lsp_server_name()
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

function M.setup_lualine(is_half)
	local ofirkai_lualine = require('ofirkai.statuslines.lualine')
	local y_section = {
		{
			function() return require('gitblame').get_current_blame_text() end,
			cond = function() return package.loaded['gitblame'] and require('gitblame').is_blame_text_available() end,
		},
	}

	-- nvim-lualine/lualine.nvim
	if is_half then
		lualine_b = {}
		lualine_y = {}
	else
		lualine_b = { { 'branch', icon = '' }, 'diff', 'diagnostics' }
		lualine_y = y_section
	end

	require('lualine').setup {
		options = {
			theme = ofirkai_lualine.theme,
			icons_enabled = true,
			path = 1,
			always_divide_middle = false,
			disabled_filetypes = {
				winbar = {
					'gitcommit',
					'NvimTree',
					'toggleterm',
					'fugitive',
					'floggraph',
					'git',
					'gitrebase',
					'quickfix',
				},
			},
			globalstatus = true,
		},
		sections = {
			lualine_b = lualine_b,
			lualine_c = {
				{ 'filename', shorting_target = 0, icon = '' },
				{
					function() return require('nvim-navic').get_location() end,
					cond = function() return package.loaded['nvim-navic'] and require('nvim-navic').is_available() end,
				},
				{
					function()
						return require('jsonpath').get()
					end,
					cond = function()
						if not package.loaded['jsonpath'] then
							return false
						end
						local ft = vim.api.nvim_buf_get_option(0, 'filetype')
						return ft == 'json' or ft == 'jsonc'
					end,
				},
			},
			lualine_x = {
				{
					function() return ' RECORDING ' .. vim.fn.reg_recording() end,
					cond = function() return vim.fn.reg_recording() ~= '' end,
					separator = '|',
				},
				{
					'searchcount',
					separator = '|',
					icon = '',
				},
				{ get_current_lsp_server_name, icon = ' LSP:' },
			},
			lualine_y = lualine_y,
			lualine_z = { { 'filetype', separator = '' }, 'progress' },
		},
	}
end

return M
