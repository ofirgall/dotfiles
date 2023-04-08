local M = {}

local file_exists = function(name)
	local f = io.open(name, 'r')
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

M.NO_SUDO = file_exists(os.getenv('HOME') .. '/.no_sudo_indicator')
M.IS_REMOTE = file_exists(os.getenv('HOME') .. '/.remote_indicator')

return M
