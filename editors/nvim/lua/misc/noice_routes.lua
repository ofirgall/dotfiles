return {
	-- Disable search count virtual text
	{
		filter = {
			event = 'msg_show',
			kind = 'search_count',
		},
		opts = { skip = true },
	},
	-- Disable "written" messages
	{
		filter = {
			event = "msg_show",
			kind = "",
			find = "written",
		},
		opts = { skip = true },
	},
	-- Disable "file_path" AMOUNT_OF_LINESL, AMOUNT_OF_BYTESB message
	{
		filter = {
			event = 'msg_show',
			kind = '',
			find = '"[%w%p]+" %d+L, %d+B'
		},
		opts = { skip = true },
	},
	-- Disable "search messages"
	{
		filter = {
			event = 'msg_show',
			kind = 'wmsg',
			find = 'search hit BOTTOM, continuing at TOP'
		},
		opts = { skip = true },
	},
	{
		filter = {
			event = 'msg_show',
			kind = 'wmsg',
			find = 'search hit TOP, continuing at BOTTOM'
		},
		opts = { skip = true },
	},
	{
		filter = {
			event = 'msg_show',
			kind = 'emsg',
			find = 'Pattern not found:'
		},
		opts = { skip = true },
	},
	-- Disable "redo/undo" messages
	{
		filter = {
			event = "msg_show",
			kind = "lua_error",
			find = "more line",
		},
		opts = { skip = true },
	},
	{
		filter = {
			event = "msg_show",
			kind = "lua_error",
			find = "fewer line",
		},
		opts = { skip = true },
	},
	{
		filter = {
			event = "msg_show",
			kind = "lua_error",
			find = "line less",
		},
		opts = { skip = true },
	},
	{
		filter = {
			event = "msg_show",
			kind = "lua_error",
			find = "change;",
		},
		opts = { skip = true },
	},
	{
		filter = {
			event = "msg_show",
			kind = "",
			find = "more line",
		},
		opts = { skip = true },
	},
	{
		filter = {
			event = "msg_show",
			kind = "",
			find = "fewer line",
		},
		opts = { skip = true },
	},
	{
		filter = {
			event = "msg_show",
			kind = "",
			find = "line less",
		},
		opts = { skip = true },
	},
	{
		filter = {
			event = "msg_show",
			kind = "",
			find = "change;",
		},
		opts = { skip = true },
	},
}
