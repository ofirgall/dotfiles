local M = {}

local default_opts = { silent = true }
function M.map(mode, l, r, desc, opts)
	opts = opts or default_opts
	opts.desc = desc
	vim.keymap.set(mode, l, r, opts)
end

function M.map_buffer(bufid, mode, l, r, desc, opts)
	opts = opts or default_opts
	opts.buffer = bufid
	opts.desc = desc
	vim.keymap.set(mode, l, r, opts)
end

return M
