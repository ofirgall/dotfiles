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

return {}
