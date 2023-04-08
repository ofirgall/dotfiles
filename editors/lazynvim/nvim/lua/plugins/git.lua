local M = {}


local api = vim.api

table.insert(M, {
	'lewis6991/gitsigns.nvim',
	event = { 'BufReadPost', 'BufNewFile' },
	cmd = 'Gitsigns',
	config = function()
		local gs = require('gitsigns')
		gs.setup {
			sign_priority = 9,
			on_attach = function(bufnr)
				local function map(mode, l, r, opts)
					opts = opts or { silent = true }
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map('n', ']c', function()
					if vim.wo.diff then return ']c' end
					vim.schedule(function() gs.next_hunk({ navigation_message = false }) end)
					return '<Ignore>'
				end, { expr = true })

				map('n', '[c', function()
					if vim.wo.diff then return '[c' end
					vim.schedule(function() gs.prev_hunk({ navigation_message = false }) end)
					return '<Ignore>'
				end, { expr = true })
				-- Actions
				map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>')
				map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>')
				map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>')
				map('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<CR>')
				map('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>')
				map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>')
				map('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
				map('n', '<leader>hd', '<cmd>Gitsigns toggle_deleted<CR>')
				-- Text object
				map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
			end,
		}
	end,
})

table.insert(M, {
	'tpope/vim-fugitive',
	keys = {
		{ '<leader>gs', '<cmd>:G<CR>', desc = 'Open fugitive.vim (git status)' },
		{ '<leader>gp', '<cmd>Git push<CR>', desc = 'Git push' },
		{ '<leader>gP', '<cmd>Git push --force<CR>', desc = 'Git push force' },
		{
			'gh',
			':set opfunc=GitHistoryOperator<CR>g@',
			desc = 'show Git History with operator, e.g: gh3<cr> shows the history of the 3 lines below'
		},
		{
			'gh',
			'<Esc><cmd>lua require("utils.git").show_history("n")<cr>',
			mode = 'v',
			desc = 'show Git History with visual mode'
		},
	},
	config = function()
		-- callback for `gh`
		vim.cmd("function! GitHistoryOperator(...) \n lua require('utils.git').show_history('n') \n endfunction")

		-- Jump to first group of files
		api.nvim_create_autocmd('BufWinEnter', {
			callback = function(events)
				local ft = api.nvim_buf_get_option(events.buf, 'filetype')
				if ft ~= 'fugitive' then
					return
				end

				local first_line = api.nvim_buf_get_lines(events.buf, 0, 1, true)[1]
				if first_line:match('Head: ') then
					api.nvim_feedkeys('}j', 'n', false)
				end
			end,
		})
	end,
})


table.insert(M, {
	'sindrets/diffview.nvim',
	cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
	keys = {
		{ '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = 'Git show diff' },
		{ '<leader>gS', '<cmd>DiffviewOpen HEAD^..HEAD<CR>', desc = 'Git Show' },
		{ '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = 'Git History' },
		{ '<leader>gH', '<cmd>DiffviewFileHistory .<CR>', desc = 'Git workspace History' },
	},
	config = function()
		local cb = require 'diffview.config'.diffview_callback
		local actions = require('diffview.actions')
		require('diffview').setup {
			watch_index = false,
			file_history_panel = {
				log_options = {
					git = {
						single_file = {
							follow = true,
						},
					},
				},
			},
			key_bindings = {
				view = {
					['q'] = '<cmd>:DiffviewClose<cr>',
					['<M-n>'] = actions.focus_files,
					['<M-m>'] = actions.toggle_files,
					['<leader>ck'] = actions.conflict_choose('ours'),
					['<leader>cj'] = actions.conflict_choose('theirs'),
					['<tab>'] = function()
						actions.select_next_entry()
						actions.refresh_files()
					end,
					['<s-tab>'] = function()
						actions.select_prev_entry()
						actions.refresh_files()
					end,
				},
				file_panel = {
					['s'] = cb('toggle_stage_entry'),
					['q'] = cb('close'),
					['gf'] = cb('goto_file_edit'),
					['<M-n>'] = cb('focus_files'),
					['<M-m>'] = actions.toggle_files,
				},
				file_history_panel = {
					['q'] = cb('close'),
					['gf'] = cb('goto_file_edit'),
					['<M-n>'] = cb('focus_files'),
					['<M-m>'] = cb('toggle_files'),
				},
			},
			view = {
				default = {
					layout = 'diff2_horizontal',
				},
				merge_tool = {
					layout = 'diff4_mixed',
					disable_diagnostics = true,
				},
				file_history = {
					layout = 'diff2_horizontal',
				},
			},
		}
	end,
})

table.insert(M, {
	'rhysd/git-messenger.vim',
	keys = {
		{ '<leader>hh', '<cmd>GitMessenger<CR>', desc = 'Hunk history' },
	},
	dependencies = {
		'tpope/vim-fugitive'
	},
	config = function()
		vim.g.git_messenger_floating_win_opts = { border = 'single' }
		vim.g.git_messenger_popup_content_margins = false
		vim.g.git_messenger_always_into_popup = true
		vim.g.git_messenger_no_default_mappings = true
		api.nvim_create_autocmd('FileType', {
			pattern = { 'gitmessengerpopup', 'git' },
			callback = function()
				---@diagnostic disable-next-line: param-type-mismatch
				vim.call('fugitive#MapJumps') -- map jumps to hunks/changes like fugitive
				-- remove overlapping maps from fugitive
				vim.keymap.del('n', 'dq', { buffer = 0 })
				vim.keymap.del('n', 'r<Space>', { buffer = 0 })
				vim.keymap.del('n', 'r<CR>', { buffer = 0 })
				vim.keymap.del('n', 'ri', { buffer = 0 })
				vim.keymap.del('n', 'rf', { buffer = 0 })
				vim.keymap.del('n', 'ru', { buffer = 0 })
				vim.keymap.del('n', 'rp', { buffer = 0 })
				vim.keymap.del('n', 'rw', { buffer = 0 })
				vim.keymap.del('n', 'rm', { buffer = 0 })
				vim.keymap.del('n', 'rd', { buffer = 0 })
				vim.keymap.del('n', 'rk', { buffer = 0 })
				vim.keymap.del('n', 'rx', { buffer = 0 })
				vim.keymap.del('n', 'rr', { buffer = 0 })
				vim.keymap.del('n', 'rs', { buffer = 0 })
				vim.keymap.del('n', 're', { buffer = 0 })
				vim.keymap.del('n', 'ra', { buffer = 0 })
				vim.keymap.del('n', 'r?', { buffer = 0 })

				-- add overridden maps
				vim.keymap.set('n', 'o', '<cmd>call b:__gitmessenger_popup.opts.mappings["o"][0]()<CR>', { buffer = 0 })
				vim.keymap.set('n', 'i', '<cmd>call b:__gitmessenger_popup.opts.mappings["O"][0]()<CR>', { buffer = 0 })
			end,
		})
	end,
})

table.insert(M, {
	'ofirgall/commit-prefix.nvim',
	ft = 'gitcommit',
	config = function()
		require('commit-prefix').setup {
		}
	end,
})

table.insert(M, {
	'rbong/vim-flog',
	dependencies = {
		'tpope/vim-fugitive'
	},
	cmd = { 'Flog', 'Flogsplit', 'Floggit' },
	keys = {
		{ '<leader>gt', '<cmd>vert Flogsplit<CR>', desc = 'Git Tree' },
		{ '<leader>got', '<cmd>Flogsplit<CR>', desc = 'Git Tree (split)' },
	},
	config = function()
		vim.g.flog_default_opts = {
			max_count = 512,
			date = 'short',
		}

		local function get_flog_commit(line)
			return vim.call('flog#floggraph#commit#GetAtLine', line)['hash']
		end

		local function flog_current_commit()
			return get_flog_commit('.')
		end

		local function flog_commit_range_visual()
			local start_pos = api.nvim_buf_get_mark(0, '<')
			local end_pos = api.nvim_buf_get_mark(0, '>')

			local start_commit = get_flog_commit(start_pos[1])
			local end_commit = get_flog_commit(end_pos[1])

			return {
				start_commit,
				end_commit,
			}
		end

		local function flog_diff_current()
			vim.cmd('DiffviewOpen ' .. flog_current_commit() .. '^')
		end

		function flog_diff_current_visual()
			local commits = flog_commit_range_visual()
			vim.cmd('DiffviewOpen ' .. commits[2] .. '^..' .. commits[1])
		end

		local function flog_show_current()
			vim.cmd('DiffviewOpen ' .. flog_current_commit() .. '^..' .. flog_current_commit())
		end

		local map_buffer = require('utils.misc').map_buffer

		api.nvim_create_autocmd('FileType', {
			pattern = 'floggraph',
			callback = function(events)
				map_buffer(events.buf, 'n', '<C-d>', flog_diff_current, 'Floggraph: show diff from head to current')
				map_buffer(events.buf, 'x', '<C-d>', '<Esc><cmd>lua flog_diff_current_visual()<cr>',
					'Floggraph: show diff of selection')
				map_buffer(events.buf, 'x', '<C-s>', '<Esc><cmd>lua flog_diff_current_visual()<cr>',
					'Floggraph: show diff of selection')
				map_buffer(events.buf, 'n', '<C-s>', flog_show_current, 'Floggraph: show current in diffview')
			end,
		})
	end,
})

table.insert(M, {
	'pwntester/octo.nvim',
	cmd = 'Octo',
	config = function()
		require('octo').setup {
		}
	end,
})

return M
