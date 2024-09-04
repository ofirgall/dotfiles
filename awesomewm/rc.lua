-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

local function p(text, obj)
	naughty.notify({
		preset = naughty.config.presets.critical,
		text = gears.debug.dump_return(obj, text),
		title = "debug",
	})
end

-- Veratil/awesome-retain
local retain = require("retain")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

require("ui")
local top_bar_bg_focus = "#0f3554"
local top_bar_fg_focus = "#ebebeb"
local theme = beautiful.get()
theme.font = "CaskaydiaCove Nerd Font Mono SemiBold 7.5"
theme.wallpaper = awful.util.get_configuration_dir() .. "wallpaper.jpg"
beautiful.init(theme)

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
ALT = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	-- awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.fair,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.floating,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}
-- }}}
local GUI_TAG = "9 GUI"
local MUSIC_TAG = "8 MUSIC"
retain.tags.defaults = {
	names = { "1", "2", "3", "4", "5", "6", "7", MUSIC_TAG, GUI_TAG },
	layouts = awful.layout.suit.tile,
}
retain.tags.load()
retain.connect_signals()

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
	mymainmenu = freedesktop.menu.build({
		before = { menu_awesome },
		after = { menu_terminal },
	})
else
	mymainmenu = awful.menu({
		items = {
			menu_awesome,
			{ "Debian", debian.menu.Debian_menu.Debian },
			menu_terminal,
		},
	})
end

mylauncher = awful.widget.launcher({
	image = beautiful.awesome_icon,
	menu = mymainmenu,
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
-- mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- echuraev/keyboard_layout
local keyboard_layout = require("keyboard_layout")
local kbdcfg = keyboard_layout.kbdcfg({
	type = "tui",
	remember_layout = false,
})

kbdcfg.add_primary_layout("English", "US", "us")
kbdcfg.add_primary_layout("Hebrew", "HE", "il")

kbdcfg.bind()

kbdcfg.widget:buttons(awful.util.table.join(
	awful.button({}, 1, function()
		kbdcfg.switch_next()
	end),
	awful.button({}, 3, function()
		kbdcfg.menu:toggle()
	end)
))

-- END OF echuraev/keyboard_layout
--

local __sep__ = wibox.widget.textbox("|")
local __space__ = wibox.widget.textbox(" ")

-- Widgets from streetturtle/awesome-wm-widgets
local has_battery = io.popen('upower -i `upower -e | grep "BAT"`'):read("*all")

local batteryarc_widget = __space__
if has_battery ~= "" then
	batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")({
		show_current_level = true,
		arc_thickness = 2,
	})
end

local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local spotify_widget = require("awesome-wm-widgets.spotify-widget.spotify")
local spotify_widget_func = spotify_widget({
	-- Swap play and pause icon
	play_icon = "/usr/share/icons/Arc/actions/24/player_pause.png",
	pause_icon = "/usr/share/icons/Arc/actions/24/player_play.png",
})
local volume_widget = require("awesome-wm-widgets.volume-widget.volume")
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
-- local net_widgets = require("net_widgets")
--
-- local wifi_adapter = "wlp0s20f3"
-- net_wireless = net_widgets.wireless({ interface = wifi_adapter })
-- net_wired = net_widgets.indicator({
-- 	ignore_interfaces = {
-- 		wifi_adapter,
-- 		"lo",
-- 		"docker0",
-- 	},
-- 	timeout = 5,
-- })

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag(retain.tags.getnames(s), s, retain.tags.getlayouts(s))

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		style = {
			bg_focus = top_bar_bg_focus,
			fg_focus = top_bar_fg_focus,
		},
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		style = {
			bg_focus = top_bar_bg_focus,
			fg_focus = top_bar_fg_focus,
		},
	})

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s })

	-- Add widgets to the wibox
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			mylauncher,
			s.mytaglist,
			s.mypromptbox,
		},
		s.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			spotify_widget_func,
			-- mykeyboardlayout,
			__sep__,
			cpu_widget(),
			ram_widget({
				widget_show_buf = true,
				color_buf = "#fbcd1d",
			}),
			batteryarc_widget,
			__space__,
			volume_widget({
				widget_type = "arc",
			}),
			__sep__,
			-- net_wireless,
			-- net_wired,
			__sep__,
			wibox.widget.textbox(""),
			kbdcfg.widget,
			wibox.widget.systray(),
			mytextclock,
			s.mylayoutbox,
		},
	})
end)
-- }}}

require("keymaps").setup(kbdcfg, volume_widget, retain)

local function p(text, obj)
	naughty.notify({
		preset = naughty.config.presets.critical,
		text = gears.debug.dump_return(obj, text),
		title = "debug",
	})
end

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			maximized = false,
			maximized_horizontal = false,
			maximized_vertical = false,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				-- "copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
				"Pavucontrol",
				"pavucontrol",
				"nm-connection-editor",
				"Nm-connection-editor",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = true } },

	-- Set GUI applications to always spawn on tag GUI_TAG
	{ rule = { class = "Teams" }, properties = { screen = 1, tag = GUI_TAG } },
	{ rule = { class = "Spotify" }, properties = { screen = 1, tag = MUSIC_TAG } },

	-- clipboard at focuesd screen floating
	{
		rule = {
			instance = "copyq",
		},
		properties = {
			floating = true,
			placement = awful.placement.centered,
			focus = true,
			ontop = true,
			screen = function(c)
				local target_screen = awful.screen.focused()
				-- For some reason returning an index of the focused screen doesn't work here
				-- Moving the client in a delayed call after rules has been applied
				-- gears.timer.delayed_call(function()
				gears.timer.start_new(0.05, function()
					c.width = 600
					c.height = 400
					c:move_to_screen(target_screen.index)
					awful.placement.centered(c)
				end)

				return target_screen.index
			end,
		},
	},
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it /tamaster.
	if not awesome.startup then
		awful.client.setslave(c)
	end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end

	-- Maximize tmux viewer on the other screen
	if c.name ~= nil and string.find(c.name, "TMUX VIEWER") ~= nil then
		c.maximized = true

		local new_screen_index = nil
		_, _, new_screen_index = string.find(c.name, "SCREEN=(%d)")
		-- p(new_screen_index, "new index")
		if new_screen_index then
			c.screen = new_screen_index
		end

		-- Focus viewer client
		client.focus = c
		c:raise()
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

-- }}}

awful.spawn.with_shell("~/.config/awesome/autorun.sh &> /tmp/autorun_output")

-- awful.screen.set_auto_dpi_enabled(true) -- Auto scaling for awful gui
require("plugins")

-- Smarter garbage collection? https://www.reddit.com/r/awesomewm/comments/te49nb/comment/i0qu7bi
collectgarbage("setpause", 160)
collectgarbage("setstepmul", 400)

gears.timer.start_new(10, function()
	collectgarbage("step", 20000)
	return true
end)

-- Auto ran applications on startup
local function run_once(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		findme = cmd
		firstspace = cmd:find(" ")
		if firstspace then
			findme = cmd:sub(0, firstspace - 1)
		end
		awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
	end
end

-- run_once({ 'spotify', 'teams' })
run_once({ "teams" })
run_once({ "blueman-applet" }) -- bluetooth
run_once({ "pasystray" }) -- audio
run_once({ "nm-applet" }) -- network
run_once({ "flameshot" }) -- screenshots
run_once({ "copyq" }) -- clipboard manager
-- Mail & Calendar
-- awful.spawn.single_instance('firefox https://outlook.office365.com/mail/ https://outlook.office.com/calendar/view/week',
--     { tag = GUI_TAG },
--     function (c)
--         return awful.rules.match(c, { class = 'Firefox', tag = GUI_TAG })
--     end)
