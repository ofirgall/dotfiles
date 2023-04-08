LSP_SERVERS['cmake'] = {
}


local clangd_cmd = {
	'clangd',
	'--background-index',
	'--fallback-style=none',
	'--header-insertion=never',
	'--all-scopes-completion',
	'--cross-file-rename',
}

if vim.fn.has('wsl') == 1 then
	table.insert(clangd_cmd, '-j=4') -- Limit resources on wsl
end

LSP_SERVERS['clangd'] = {
	init_options = {
		clangdFileStatus = true,
	},
	cmd = clangd_cmd,
}


local add_r_new_line = 'i\\r\\n<Esc>'
vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'c', 'cpp' },
	callback = function(events)
		local map_buffer = require('utils.misc').map_buffer
		map_buffer(events.buf, 'n', '<leader>e', '<cmd>GoIfErr<cr>', 'Golang: create if err')
		map_buffer(events.buf, 'n', '<leader>fln', '<cmd>s/Println/Printf/<cr>$F"' .. add_new_line,
			'Golang: change println to printf')
	end,
})

return {}
