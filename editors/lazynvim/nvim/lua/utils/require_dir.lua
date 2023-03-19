-- Require all other `.lua` files in the same directory
-- Credit: https://github.com/hallettj/dot-vim

local M = {}

local function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "' .. directory .. '"')
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

local function get_config_files(dir)
    return vim.tbl_filter(function(filename)
        local is_lua_module = string.match(filename, '[.]lua$')
        return is_lua_module
    end, scandir(dir))
end

function M.require(relative_dir)
    local full_dir = M.config_dir .. '/lua/' .. relative_dir .. '/'

    for _, filename in ipairs(get_config_files(full_dir)) do
        local config_module = string.match(filename, '(.+).lua$')
        require(relative_dir .. '.' .. config_module)
    end
end

-- Must be called from init.lua
function M.setup()
    local info = debug.getinfo(2, 'S')
    M.config_dir = string.match(info.source, '^@(.*)/')
end

return M
