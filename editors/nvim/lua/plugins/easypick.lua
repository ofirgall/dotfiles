if vim.g.started_by_firenvim then
	do return end
end

-- axkirillov/easypick.nvim
local easypick = require('easypick')

easypick.setup {
	pickers = {
		{
			name = 'dirtyfiles',
			command = 'git status -s | cut -c 4-',
			previewer = easypick.previewers.default()
		},
	}
}
