-- Require all other `.lua` files in the same directory
-- Credit: https://github.com/hallettj/dot-vim

local M = {}

local function scandir(directory, recursive)
	local i, t, popen = 0, {}, io.popen
	local pfile = nil

	if recursive then
		pfile = popen('fd . --base-directory="' .. directory .. '"')
	else
		pfile = popen('ls -a "' .. directory .. '"')
	end

	if pfile == nil then
		return {}
	end

	for filename in pfile:lines() do
		i = i + 1
		t[i] = filename
	end
	pfile:close()
	return t
end

local function get_config_files(dir, recursive)
	return vim.tbl_filter(function(filename)
		local is_lua_module = string.match(filename, '[.]lua$')
		return is_lua_module
	end, scandir(dir, recursive))
end

local function _require(relative_dir, recursive)
	local ret_vals = {}
	local full_dir = M.config_dir .. '/lua/' .. relative_dir .. '/'

	for _, filename in ipairs(get_config_files(full_dir, recursive)) do
		local config_module = string.match(filename, '(.+).lua$')
		table.insert(ret_vals, require(relative_dir .. '.' .. config_module))
	end

	return ret_vals
end

function M.require(relative_dir)
	return _require(relative_dir, false)
end

function M.recursive_require(relative_dir)
	return _require(relative_dir, true)
end

-- Must be called from init.lua
function M.setup()
	local info = debug.getinfo(2, 'S')
	M.config_dir = string.match(info.source, '^@(.*)/')
end

return M
