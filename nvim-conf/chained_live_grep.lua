local conf = require("telescope.config").values
local themes = require("telescope.themes")
local builtin = require("telescope.builtin")
local action_state = require("telescope.actions.state")

local function get_common()
	local entry = action_state.get_selected_entry()
	local filetype = vim.fn.fnamemodify(entry.filename, ":e")
	local prompt_bufnr = vim.api.nvim_get_current_buf()
	local picker = action_state.get_current_picker(prompt_bufnr)
	local prompt_text = vim.api.nvim_buf_get_lines(prompt_bufnr, 0, 1, true)[1]:sub(#picker.prompt_prefix + 1)

	return filetype, prompt_text
end

local function chained_live_grep(opts)
	opts = opts or themes.get_ivy {}
	builtin.live_grep(vim.tbl_deep_extend("force", {
		prompt_title = "Live Grep (Filtered)",
		attach_mappings = function(_, map)
			local fuzzy_filter_results = function()
				local query = action_state.get_current_line()
				if not query then
					print "no matching results"
					return
				end
				opts.search = query
				opts.prompt_title = "Filter"
				opts.prompt_prefix = "/" .. query .. " >> "
				builtin.grep_string(opts)
			end

			local dynamic_filetype = function()
				file_type, prompt_text = get_common()
				opts.vimgrep_arguments = vim.deepcopy(conf.vimgrep_arguments)
				opts.prompt_prefix = opts.prompt_prefix or "*." .. file_type .. " >> "
				opts.prompt_title = "Scoped Results"
				opts.default_text = prompt_text
				vim.list_extend(opts.vimgrep_arguments, { "--type=" .. file_type })
				builtin.live_grep(opts)
			end

			local dynamic_filetype_skip = function()
				file_type, prompt_text = get_common()
				opts.vimgrep_arguments = vim.deepcopy(conf.vimgrep_arguments)
				opts.prompt_prefix = opts.prompt_prefix or "!*." .. file_type .. " >> "
				opts.prompt_title = "Scoped Results"
				opts.default_text = prompt_text
				vim.list_extend(opts.vimgrep_arguments, { "--type-not=" .. file_type })
				builtin.live_grep(opts)
			end

			map("i", "<C-e>", fuzzy_filter_results)
			map("n", "<C-e>", fuzzy_filter_results)
			map("i", "<C-f>", dynamic_filetype)
			map("n", "<C-f>", dynamic_filetype)
			map("i", "<C-g>", dynamic_filetype_skip)
			map("n", "<C-g>", dynamic_filetype_skip)
			return true
		end,
	}, opts))
end

chained_live_grep({})
