-- KoalaVim initialization, DO NOT EDIT.
local M = {}

-- bootstraps nvim plugins
local function bootstrap(plugin_author, plugin_name, branch, env_path_override)
	local path = vim.fn.stdpath('data') .. '/lazy/' .. plugin_name
	if not vim.loop.fs_stat(path) then
		-- bootstrap lazy.nvim
		vim.fn.system({
			'git',
			'clone',
			'--filter=blob:none',
			'https://github.com/' .. plugin_author .. '/' .. plugin_name .. '.git',
			'--branch=' .. branch,
			path,
		})
	end
	vim.opt.rtp:prepend(vim.env[env_path_override] or path)
end

function M.load_koala(leader_key)
	vim.g.mapleader = leader_key
	vim.g.maplocalleader = leader_key

	-- Bootstrap KoalaVim
	bootstrap('KoalaVim', 'KoalaVim', 'master', 'KOALA')

	require('KoalaVim').init()
end

function M.load_lazy(opts)
	-- Bootstrap lazy.nvim
	bootstrap('folke', 'lazy.nvim', 'stable', 'LAZY')

	local koala_spec = require('KoalaVim.spec')

	local user_spec = opts.user_spec or {}

	-- Concat user_spec with koala_spec
	local combined_spec = {}
	table.move(user_spec, 1, #user_spec, 1, combined_spec)
	table.move(koala_spec, 1, #koala_spec, #combined_spec + 1, combined_spec)

	local koala_lazy_opts = {
		-- folke/lazy.nvim settings
		defaults = {
			lazy = false, -- Don't lazy load plugins by default
			version = false, -- always use the latest git commit
		},
		checker = {
			-- automatically check for plugin updates
			enabled = false,
		},
		change_detection = {
			-- Don't auto reload config
			enabled = false,
		},
		performance = {
			rtp = {
				-- disable some rtp plugins
				disabled_plugins = {
					'gzip',
					'matchit',
					'matchparen',
					'netrwPlugin',
					'tarPlugin',
					'tohtml',
					'tutor',
					'zipPlugin',
				},
			},
		},
	}

	local lazy_opts = vim.tbl_deep_extend('keep', opts.lazy_opts or {}, koala_lazy_opts)
	-- Force combined spec
	lazy_opts.spec = combined_spec

	require('lazy').setup(lazy_opts)
end

return M
