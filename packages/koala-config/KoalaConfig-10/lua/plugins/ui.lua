local M = {}

table.insert(M, {
	'folke/which-key.nvim',
	enabled = false,
})

table.insert(M, {
	'ziontee113/icon-picker.nvim',
	cmd = {
		'IconPickerInsert',
		'IconPickerNormal',
		'IconPickerYank',
	},
	config = function()
		require('icon-picker').setup({
			disable_legacy_commands = true,
		})
	end,
})

return M
