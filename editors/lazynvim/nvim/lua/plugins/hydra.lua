local M = {}

local hydra_keys = {}
local hydra_cmds = {}
for name, conf in pairs(HYDRAS) do
	if conf.body then
		table.insert(hydra_keys,
			{ conf.body, desc = 'Trigger ' .. name .. ' hydra' })
	end
	if conf.cmd then
		table.insert(hydra_cmds, conf.cmd)
	end
end

table.insert(M, {
	'anuvyklack/hydra.nvim',
	keys = hydra_keys,
	cmd = hydra_cmds,
	config = function()
		-- Registers all hydras
		local Hydra = require('hydra')
		for _, conf in pairs(HYDRAS) do
			local curr_hydra = Hydra(conf)
			if conf.cmd then
				vim.api.nvim_create_user_command(conf.cmd, function()
					curr_hydra:activate()
				end, {})
			end
		end
	end,
})

return M
