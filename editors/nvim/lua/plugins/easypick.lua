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
