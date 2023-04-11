local M = {}
-- Misc editor plugins
local api = vim.api

table.insert(M, {
	'rmagatti/auto-session',
	config = function()
		require('auto-session').setup {
			log_level = 'error',
			auto_session_suppress_dirs = { '~/', '~/workspace', '~/Downloads', '/', '~/logs' },
			auto_session_use_git_branch = true,

			-- Close nvim-tree before saving session
			pre_save_cmds = {
				-- nvim-tree
				function()
					if package.loaded['nvim-tree'] then
						require('nvim-tree.api').tree.close()
					end
				end,

				-- fugitive
				function()
					for _, bufnr in pairs(api.nvim_list_bufs()) do
						local ft = api.nvim_get_option_value('filetype', { buf = bufnr })
						if ft == 'fugitive' then
							api.nvim_buf_delete(bufnr, {})
						end
					end
				end,
			},

			-- Close Lazy window before restoring session
			pre_restore_cmds = { function()
				local buf = api.nvim_get_current_buf()
				local ft = api.nvim_get_option_value('filetype', { buf = buf })
				if ft == 'lazy' then
					api.nvim_buf_delete(buf, {})
				end
			end, },
		}
	end,
})

table.insert(M, {
	'ofirgall/AutoSave.nvim', -- fork
	event = 'VeryLazy',
	config = function()
		local autosave = require('autosave')
		autosave.setup {
			clean_command_line_interval = 1000,
			on_off_commands = true,
			execution_message = '',
		}

		autosave.hook_before_actual_saving = function()
			-- Ignore RaafatTurki/hex.nvim
			if vim.b.hex then
				vim.g.auto_save_abort = true
				return
			end

			mode = vim.api.nvim_get_mode()
			-- Don't save while we in insert/select mode (triggered with autopair and such)
			if mode.mode ~= 'n' then
				vim.g.auto_save_abort = true
				return
			end
		end
	end,
})

table.insert(M, {
	'gennaro-tedesco/nvim-peekup',
	keys = { '""' },
	config = function()
		local peekup_config = require('nvim-peekup.config')
		peekup_config.on_keystroke['delay'] = ''
		peekup_config.on_keystroke['autoclose'] = true
		peekup_config.on_keystroke['paste_reg'] = '"'
	end,
})

table.insert(M, {
	'NMAC427/guess-indent.nvim',
	config = function()
		require('guess-indent').setup {
		}
	end,
})

table.insert(M, {
	'nyngwang/NeoZoom.lua',
	config = function()
		local floating_code_ns = api.nvim_create_namespace('Floating Window for Code')
		api.nvim_set_hl(floating_code_ns, 'NormalFloat', { link = 'Normal' })

		require('neo-zoom').setup {
			callbacks = {
				function()
					api.nvim_set_hl_ns(floating_code_ns)
				end,
			},
		}
	end,
	keys = {
		{
			'<M-Z>',
			function() vim.cmd('NeoZoomToggle') end,
			mode = { 'n', 'v' },
			desc = 'Zoom split',
			nowait = true,
		},
	},
})

table.insert(M, {
	'folke/todo-comments.nvim',
	event = { 'BufReadPost', 'BufNewFile' },
	config = function()
		require('todo-comments').setup {
			signs = false,
			highlight = {
				before = '',
				keyword = 'fg',
				after = ''
			},
			colors = {
				error = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
				warning = { '@text.danger', 'DiagnosticWarning', 'WarningMsg', '#FBBF24' },
				info = { '@text.warning', 'DiagnosticInfo', '#2563EB' },
				hint = { '@text.note', 'DiagnosticHint', '#10B981' },
				default = { '@text.note', '#7C3AED' },
			},
		}
	end,
	keys = {
		{ ']t', function() require('todo-comments').jump_next() end, desc = 'Next todo comment' },
		{ '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous todo comment' },
	},
})

table.insert(M, {
	'Vigemus/iron.nvim',
	cmd = { 'IPython', 'Lua' },
	config = function()
		require('iron.core').setup {
			config = {
				should_map_plug = false,
				scratch_repl = true,
				close_window_on_exit = true,
				repl_definition = {
					sh = {
						command = { 'zsh' },
					},
					python = {
						command = { 'ipython3' },
					},
				},
				repl_open_cmd = 'belowright 15 split',
			},
			highlight = {
				italic = false,
				bold = false,
			},
		}

		api.nvim_create_user_command('IPython', function()
			require('iron.core').repl_for('python')
			require('iron.core').focus_on('python')
			api.nvim_feedkeys('i', 'n', false)
		end, {})

		api.nvim_create_user_command('Lua', function()
			require('iron.core').repl_for('lua')
			require('iron.core').focus_on('lua')
			api.nvim_feedkeys('i', 'n', false)
		end, {})
	end,
})

table.insert(M, {
	'norcalli/nvim-colorizer.lua',
	event = { 'BufReadPost', 'BufNewFile' },
	config = function()
		require('colorizer').setup {
			'*'
		}
	end,
})

table.insert(M, {
	'ziontee113/color-picker.nvim',
	keys = {
		{ '<leader>rgb', '<cmd>PickColor<CR>', desc = 'Pick color' },
	},
	config = function()
		require('color-picker').setup {
		}
	end,
})

table.insert(M, {
	'tiagovla/scope.nvim',
	config = function()
		require('scope').setup {
		}
	end,
})

-- TODO: make it dev
table.insert(M, {
	'ofirgall/title.nvim',
	cmd = 'Title',
	config = function()
		require('title-nvim').setup {
		}
	end,
})

table.insert(M, {
	'AckslD/nvim-FeMaco.lua',
	cmd = 'FeMaco',
	keys = {
		{ '<leader>e', function() require('femaco.edit').edit_code_block() end, 'Edit markdown codeblocks' },
	},
	config = function()
		local femaco_margin = {
			width = 10,
			height = 6,
			top = 2,
		}
		require('femaco').setup {
			post_open_float = function(winnr)
				local ns = api.nvim_create_namespace('FeMaco')
				api.nvim_set_hl(ns, 'NormalFloat', { bg = require('ofirkai').scheme.background })
				api.nvim_win_set_hl_ns(winnr, ns)
			end,
			float_opts = function(code_block)
				_ = code_block
				return {
					relative = 'win',
					width = vim.api.nvim_win_get_width(0) - femaco_margin.width,
					height = vim.api.nvim_win_get_height(0) - femaco_margin.height,
					col = femaco_margin.width / 2,
					row = femaco_margin.height / 2 - femaco_margin.top,
					border = 'rounded',
					zindex = 1,
				}
			end,
			ensure_newline = function(base_filetype)
				_ = base_filetype
				return true
			end,
		}
	end,
})

table.insert(M, {
	'ofirgall/open.nvim',
	keys = {
		{ '<leader>gx', function() require('open').open_cword() end, desc = 'Open current word' },
	},
	config = function()
		require('open').setup {
		}
	end,
	dependencies = {
		{
			'ofirgall/open-jira.nvim',
			config = function()
				require('open-jira').setup {
					url = 'https://volumez.atlassian.net/browse/'
				}
			end,
		},
	},
})

table.insert(M, {
	'zakharykaplan/nvim-retrail',
	event = { 'BufReadPost', 'BufNewFile' },
	cmd = 'TrimWhiteSpace',
	config = function()
		retrail = require('retrail')
		retrail.setup {
			hlgroup = 'NvimInternalError',
			filetype = {
				exclude = {
					'diff',
					'git',
					'gitcommit',
					'unite',
					'qf',
					'help',
					'markdown',
					'fugitive',
					'toggleterm',
					'log',
					'noice',
					'nui',
					'notify',
					'floggraph',
					'chatgpt',
				},
			},
			trim = {
				auto = false,
				whitespace = true, -- Trailing whitespace as highlighted.
				blanklines = true, -- Final blank (i.e. whitespace only) lines.
			},
		}
		api.nvim_create_user_command('TrimWhiteSpace', function() retrail:trim() end, {})
	end,
})

table.insert(M, {
	'numToStr/Navigator.nvim',
	config = function()
		require('Navigator').setup {
			disable_on_zoom = false,
		}
	end,
	keys = {
		{ '<C-h>', '<cmd>NavigatorLeft<cr>', mode = { 'n', 'x', 't' }, desc = 'Navigate left' },
		{ '<C-j>', '<cmd>NavigatorDown<cr>', mode = { 'n', 'x', 't' }, desc = 'Navigate down' },
		{ '<C-k>', '<cmd>NavigatorUp<cr>', mode = { 'n', 'x', 't' }, desc = 'Navigate up' },
		{ '<C-l>', '<cmd>NavigatorRight<cr>', mode = { 'n', 'x', 't' }, desc = 'Navigate right' },
	},
})

table.insert(M, {
	'trmckay/based.nvim',
	config = function()
		require('based').setup {
			highlight = 'Title'
		}
	end,
	keys = {
		{ '<leader>H', function() require('based').convert() end, mode = { 'n', 'v' }, desc = 'Convert hex <=> decimal' },
	},
})

table.insert(M, {
	'riddlew/swap-split.nvim',
	cmd = 'SwapSplit',
	config = function()
		require('swap-split').setup({
			ignore_filetypes = {
				'NvimTree'
			},
		})
	end,
})

table.insert(M, {
	'RaafatTurki/hex.nvim',
	cmd = { 'HexDump', 'HexAssemble', 'HexToggle' },
	config = function()
		require('hex').setup {
		}
	end,
})

table.insert(M, {
	'micarmst/vim-spellsync',
	event = 'VeryLazy',
	init = function()
		vim.g.spellsync_enable_git_union_merge = 0
		vim.g.spellsync_enable_git_ignore = 0
	end,
})

table.insert(M, {
	'ThePrimeagen/harpoon',
	dependencies = {
		'nvim-lua/plenary.nvim'
	},
	keys = {
		{ '<leader>m', function() require('harpoon.mark').add_file() end, desc = 'Add file to harpoon' },
		{ '<leader>A', function() require('telescope').extensions.harpoon.marks() end, desc = 'Jump to harpoon file' },
		{ '<leader>a', function() require('harpoon.ui').toggle_quick_menu() end, desc = 'Jump to harpoon file' },

	},
	config = function()
		require('telescope').load_extension('harpoon')
	end,
})

table.insert(M, {
	'famiu/bufdelete.nvim',
	lazy = true,
})

table.insert(M, {
	'lambdalisue/suda.vim',
	cmd = { 'SudaRead', 'SudaWrite' },
})

table.insert(M, {
	'mizlan/iswap.nvim',
	cmd = 'ISwap'
})

table.insert(M, {
	'rbong/vim-buffest',
	cmd = {
		'Regsplit',
		'Regvsplit',
		'Regtabedit',
		'Regedit',
		'Regpedit',
		'Qflistsplit',
		'Qflistvsplit',
		'Qflisttabedit',
		'Qflistedit',
		'Loclistsplit',
		'Loclistvsplit',
		'Loclisttabedit',
		'Loclistedit',
	},
})

table.insert(M, {
	'ofirgall/vim-log-highlighting',
	ft = 'log'
})

table.insert(M, {
	'chrisgrieser/nvim-genghis',
	cmd = {
		'NewFromSelection',
		'Duplicate',
		'Rename',
		'Trash',
		'Move',
		'CopyFilename',
		'CopyFilepath',
		'Chmodx',
		'New',
	},
})

return M
