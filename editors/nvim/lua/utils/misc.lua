local M = {}

local api = vim.api

function M.center_screen()
	api.nvim_feedkeys('zz', 'n', false)
end

-- TODO: move map functions to utils/map.lua
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

function M.restart_nvim()
	vim.fn.system('touch /tmp/restart_nvim')
	api.nvim_feedkeys(':wqa\n', 'n', false)
end

local deployedTerminal = nil
function M.reset_deploy()
	deployedTerminal = require('toggleterm.terminal').Terminal:new({ cmd = 'deploy', dir = '%:p:h' })
end

function M.deploy()
	if deployedTerminal == nil then
		M.reset_deploy()
	end
	---@diagnostic disable-next-line: need-check-nil
	deployedTerminal:toggle()
end

return M
