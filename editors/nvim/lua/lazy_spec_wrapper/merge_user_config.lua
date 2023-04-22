local spec_dirs = {
	'plugins/hydras',
	'plugins',
	'plugins/lsp/servers',
	'plugins/lsp',
}

-- plugin_name -> spec_plugin
local plugin_list = {}

for _, spec_dir in ipairs(spec_dirs) do
	for _, spec_module in ipairs(require('utils.require_dir').require(spec_dir)) do
		for _, spec_plugin in ipairs(spec_module) do
			plugin_list[spec_plugin[1]] = spec_plugin
		end
	end
end

for _, spec_dir in ipairs(spec_dirs) do
	local res = require('utils.require_dir').require(spec_dir .. '/user')
	for _, user_spec_module in ipairs(res) do
		for _, user_spec_plugin in ipairs(user_spec_module) do
			local plugin_name = user_spec_plugin[1]
			if plugin_list[plugin_name] == nil then
				plugin_list[plugin_name] = user_spec_plugin
			else
				plugin_list[plugin_name] = vim.tbl_deep_extend('force', plugin_list[plugin_name], user_spec_plugin)
			end
		end
	end
end

local spec = {}
for _, plugin_spec in pairs(plugin_list) do
	table.insert(spec, plugin_spec)
end

return spec
