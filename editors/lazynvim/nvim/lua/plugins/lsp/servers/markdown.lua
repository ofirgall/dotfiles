LSP_SERVERS['marksman'] = {
}

-- Load ignored words
local path = vim.fn.stdpath('config') .. '/spell/en.utf-8.add'
local words = {}

local fd = io.open(path, 'r')
if fd then
	for word in fd:lines() do
		table.insert(words, word)
	end
	fd:close()
end

LSP_SERVERS['ltex'] = {
	filetypes = { 'bib', 'markdown', 'org', 'plaintex', 'rst', 'rnoweb', 'tex' },
	autostart = false,
	settings = {
		ltex = {
			dictionary = {
				['en-US'] = words,
			},
		},
	},
}

return {}
