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
	if conf.custom_bodies then
		for _, body in ipairs(conf.custom_bodies) do
			table.insert(hydra_keys, body)
		end
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

			-- Setup user cmd if needed
			if conf.cmd then
				vim.api.nvim_create_user_command(conf.cmd, function()
					curr_hydra:activate()
				end, {})
			end

			-- Setup custom bodies if needed
			if conf.custom_bodies then
				for _, body in ipairs(conf.custom_bodies) do
					require('utils.map').map(body.mode, body[1], function() body.callback(curr_hydra) end, body.desc)
				end
			end
		end
	end,
})

return M
