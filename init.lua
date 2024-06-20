-- awesomewm-mpris-widget
--
-- Author: demingongo
-- Link: https://github.com/demingongo
-- Availability: https://github.com/demingongo/awesomewm-mpris-widget

-- URGENT: noticed that text didn't always refresh in horizontal scroll containers. fix that

local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local escape_f = require("gears.string").xml_escape;
local lookup_icon_f = require("menubar.utils").lookup_icon
local beautiful = require("beautiful")
-- local naughty = require("naughty")

local WIDGET_DIR = os.getenv("HOME") .. "/.config/awesome/awesomewm-mpris-widget"

local local_script_path = "/bin/list_players_metadata"

local get_players_metadata_script_path = WIDGET_DIR .. local_script_path

local local_media_icons = {
	default = "/icons/candy-icons/juk.svg",
	firefox = "/icons/candy-icons/firefox.svg",
	rhythmbox = "/icons/hicolor/org.gnome.Rhythmbox3.svg",
	spotify = "/icons/candy-icons/spotify-client.svg",
	totem = "/icons/hicolor/org.gnome.Totem.svg"
}

local media_icons = {
	default = WIDGET_DIR .. local_media_icons.default,
	firefox = WIDGET_DIR .. local_media_icons.firefox,
	rhythmbox = WIDGET_DIR .. local_media_icons.rhythmbox,
	spotify = WIDGET_DIR .. local_media_icons.spotify,
	totem = WIDGET_DIR .. local_media_icons.totem
}

local function ellipsize(text, length)
	return (text:len() > length and length > 0)
		and text:sub(0, length - 3) .. '...'
		or text
end

local function initProps(props)
	local result = {}
	local params = {}
	if type(props) == "table" then
		params = props
	end

	-- Primary
	--

	result.widget_dir = type(params.widget_dir) == "string"
		and params.widget_dir ~= ""
		and params.widget_dir
		or nil

	result.display = (params.display == "icon_text" or params.display == "icon") and params.display
		or "text"

	result.empty_text = type(params.empty_text) == "string"
		and params.empty_text
		or ""

	result.separator = type(params.separator) == "string"
		and params.separator
		or " - "

	-- Function
	--

	result.script_path = type(params.metadata_script_path) == "string"
		and params.metadata_script_path ~= ""
		and params.metadata_script_path
		or (result.widget_dir and result.widget_dir .. local_script_path)
		or get_players_metadata_script_path

	result.ignore_player = type(params.ignore_player) == "string" and params.ignore_player or nil

	result.timeout = type(params.timeout) == "number" and params.timeout or 3

	if type(params.scroll) == "table" then
		result.scroll_enabled = type(params.scroll.enabled) == "boolean"
			and params.scroll.enabled or false

		-- DEPRECATED: keep "scroll.position" for retro-compatibility. Use "scroll.orientation"
		result.scroll_orientation = (params.scroll.position == "vertical")
				and params.scroll.position or "horizontal"

		if params.scroll.orientation then
			result.scroll_orientation = (params.scroll.orientation == "vertical")
				and params.scroll.orientation or "horizontal"
		end

		result.scroll_max_size = type(params.scroll.max_size) == "number"
			and params.scroll.max_size or 170

		result.scroll_step_function = type(params.scroll.step_function) == "function"
			and params.scroll.step_function
			or wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth

		result.scroll_speed = type(params.scroll.speed) == "number"
			and params.scroll.speed or
			(result.scroll_orientation == "vertical" and 8 or 20)

		result.scroll_fps = type(params.scroll.fps) == "number"
			and params.scroll.fps or 10

		result.scroll_margin_top = type(params.scroll.margin_top) == "number"
			and params.scroll.margin_top or 5

		result.scroll_margin_bottom = type(params.scroll.margin_bottom) == "number"
			and params.scroll.margin_bottom or 5
	end

	-- Style
	--

	result.font = type(params.font) == "string"
		and params.font
		or beautiful.font

	result.icon_width = type(params.icon_width) == "number"
		and params.icon_width or nil

	result.icon_height = type(params.icon_height) == "number"
		and params.icon_height or nil

	result.fg = type(params.fg) == "string"
		and params.fg
		or beautiful.fg_normal

	result.bg = type(params.bg) == "string"
		and params.bg
		or beautiful.bg_normal

	result.bgimage = params.bgimage or nil

	result.popup_font = type(params.popup_font) == "string"
		and params.popup_font
		or beautiful.font

	result.popup_border_width = type(params.popup_border_width) == "number"
		and params.popup_border_width or 1

	result.popup_border_color = type(params.popup_border_color) == "string"
		and params.popup_border_color or beautiful.bg_focus

	result.popup_maximum_width = type(params.popup_maximum_width) == "number"
		and params.popup_maximum_width or 400

	result.state_playing = type(params.state_playing) == "string"
		and params.state_playing or "󰝚  "

	result.state_paused = type(params.state_paused) == "string"
		and params.state_paused or "  "

	result.title_first = type(params.title_first) == "boolean"
		and params.title_first or false

	result.max_chars = type(params.max_chars) == "number" and params.max_chars or 34

	result.media_icons_default = type(params.media_icons_default) == "string"
		and params.media_icons_default
		or (result.widget_dir and result.widget_dir .. local_media_icons.default)
		or media_icons.default

	result.media_icons_spotify = type(params.media_icons_spotify) == "string"
		and params.media_icons_spotify
		or (result.widget_dir and result.widget_dir .. local_media_icons.spotify)
		or media_icons.spotify

	result.media_icons_firefox = type(params.media_icons_firefox) == "string"
		and params.media_icons_firefox
		or (result.widget_dir and result.widget_dir .. local_media_icons.firefox)
		or media_icons.firefox

	result.media_icons_totem = type(params.media_icons_totem) == "string"
		and params.media_icons_totem
		or (result.widget_dir and result.widget_dir .. local_media_icons.totem)
		or media_icons.totem

	result.media_icons_rhythmbox = type(params.media_icons_rhythmbox) == "string"
		and params.media_icons_rhythmbox
		or (result.widget_dir and result.widget_dir .. local_media_icons.rhythmbox)
		or media_icons.rhythmbox

	if type(params.media_icons) == "table" then
		-- loop through properties
		for player_name, icon_path in pairs(params.media_icons)
		do
			if type(icon_path) == "string" then
				result["media_icons_" .. player_name] = icon_path
			end
		end
	end

	-- Events
	--

	if type(params.all_clients_closed) == "function" then
		result.all_clients_closed = params.all_clients_closed
	end
	if type(params.clients_running) == "function" then
		result.clients_running = params.clients_running
	end
	if type(params.updated_callback) == "function" then
		result.updated_callback = params.updated_callback
	end
	if type(params.create_popup_row) == "function" then
		result.create_popup_row = params.create_popup_row
	end

	return result
end

--
-- @params {{
-- 	widget_dir = string,
--  display = string,
-- 	empty_text = string,
--  separator = string,
--  title_first = boolean,
--	metadata_script_path = string,
-- 	ignore_player = string,
-- 	timeout = number,
-- 	font = string,
--  icon_height = number,
--  icon_width = number,
-- 	fg = string,
-- 	bg = string,
-- 	bgimage = gears.surface,
--  popup_font = string,
-- 	popup_border_width = number,
-- 	popup_border_color = string,
-- 	popup_maximum_width = number,
-- 	media_icons_default = string,
-- 	media_icons_spotify = string,
-- 	media_icons_firefox = string,
-- 	media_icons_totem = string,
-- 	media_icons = {
-- 		client_name = icon_path
-- 	},
-- 	state_playing = string,
-- 	state_paused = string,
-- 	max_chars = number,
-- 	scroll = {
-- 		enabled = boolean,
-- 		position = "vertical" or "horizontal",
-- 		max_size = number, 170
-- 		step_function = wibox.container.scroll.step_functions,
-- 		speed = number, vertical: 8, horizontal: 20
-- 		fps = number 10
-- 	}
-- }} params
--
local function init_mpris_widget(params)

	-- PRIVATE PROPERTIES
	--

	local props = initProps(params)

	local main_player = ""
	local mdata = nil

	local refreshing = false
	local current_state = "started"

	-- for safety control
	local control_running = false

	-- init textboxes
	local mpris_textbox = wibox.widget.textbox();
	mpris_textbox.font = props.font
	local mpris_textbox_middle = nil;
	local mpris_textbox_bottom = nil;
	local mpris_iconbox = nil;

	local function get_mpris_iconbox()
		if not mpris_iconbox then
			mpris_iconbox = wibox.widget {
				image = props.media_icons_default,
				resize = true,
				widget = wibox.widget.imagebox,
				visible = false
			}

			if props.icon_width then
				mpris_iconbox.forced_width = props.icon_width
			end
			if props.icon_height then
				mpris_iconbox.forced_height = props.icon_height
			end
		end

		return mpris_iconbox
	end

	-- init mpris widget
	local mpris_widget;
	if props.scroll_enabled then
		local scroll_widget;
		if props.scroll_orientation == "vertical" then
			mpris_textbox_middle = wibox.widget {
				text = " ",
				widget = wibox.widget.textbox
			}
			mpris_textbox_middle.font = props.font
			mpris_textbox_bottom = wibox.widget.textbox()
			mpris_textbox_bottom.font = props.font

			local vertical_layout = {
				layout = wibox.layout.fixed.vertical
			}

			if string.find(props.display, 'icon') then
				-- insert icon
				table.insert(vertical_layout, {
					get_mpris_iconbox(),
					widget = wibox.container.place
				})
			end

			-- insert textboxes
			table.insert(vertical_layout, {
				mpris_textbox,
				widget = wibox.container.place
			})
			table.insert(vertical_layout, mpris_textbox_middle)
			table.insert(vertical_layout, {
				mpris_textbox_bottom,
				widget = wibox.container.place
			})

			scroll_widget = wibox.widget {
				layout = wibox.container.scroll.vertical,
				step_function = props.scroll_step_function,
				speed = props.scroll_speed,
				{
					vertical_layout,
					top = props.scroll_margin_top,
					bottom = props.scroll_margin_bottom,
					widget = wibox.container.margin
				}
			}

			mpris_widget = wibox.widget {
				scroll_widget,
				width = props.scroll_max_size,
				widget = wibox.container.constraint
			}
		else
			local scroll_widget_layout = {
				layout = wibox.container.scroll.horizontal,
				max_size = props.scroll_max_size,
				step_function = props.scroll_step_function,
				speed = props.scroll_speed
			}

			if string.find(props.display, 'icon') then
				-- insert icon
				local h_layout = {
					layout = wibox.layout.align.horizontal,
					{
						get_mpris_iconbox(),
						widget = wibox.container.place
					}
				}

				if string.find(props.display, 'text') then
					-- insert textbox
					table.insert(h_layout, mpris_textbox)
				end
				table.insert(scroll_widget_layout, h_layout)
			else
				-- insert textbox
				table.insert(scroll_widget_layout, mpris_textbox)
			end

			--
			scroll_widget = wibox.widget(scroll_widget_layout)

			mpris_widget = scroll_widget
		end
		scroll_widget:set_fps(props.scroll_fps)
	else
		local mpris_widget_layout = {
			layout = wibox.layout.align.horizontal,
		}

		if string.find(props.display, 'icon') then
			-- insert icon
			table.insert(mpris_widget_layout, get_mpris_iconbox())
		end

		if string.find(props.display, 'text') then
			-- insert textbox
			table.insert(mpris_widget_layout, mpris_textbox)
		end

		mpris_widget = wibox.widget(mpris_widget_layout)
	end

	-- init mpris popup
	local mpris_popup = awful.popup {
		ontop = true,
		visible = false, -- should be hidden when created
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, 4)
		end,
		border_width = props.popup_border_width,
		border_color = props.popup_border_color,
		maximum_width = props.popup_maximum_width,
		offset = { y = 5 },
		widget = {},
		fg = props.fg,
		bg = props.bg,
		bgimage = props.bgimage
	}

	local scroll_handler = {
		hide_bottom = function()
			if mpris_textbox_middle and mpris_textbox_middle.visible then
				mpris_textbox_middle.visible = not mpris_textbox_middle.visible
			end
			if mpris_textbox_bottom then
				mpris_textbox_bottom:set_text("")
				if mpris_textbox_bottom.visible then
					mpris_textbox_bottom.visible = not mpris_textbox_bottom.visible
				end
			end
		end,
		show_bottom = function(txt)
			if mpris_textbox_middle and not mpris_textbox_middle.visible then
				mpris_textbox_middle.visible = not mpris_textbox_middle.visible
			end
			if mpris_textbox_bottom then
				mpris_textbox_bottom:set_text(txt)
				if not mpris_textbox_bottom.visible then
					mpris_textbox_bottom.visible = not mpris_textbox_bottom.visible
				end
			end
		end
	}

	local icon_handler = {
		show_icon = function(icon_path)
			if mpris_iconbox then
				mpris_iconbox.image = icon_path or props.media_icons_default
				if not mpris_iconbox.visible then
					mpris_iconbox.visible = not mpris_iconbox.visible
				end
			end
		end,
		hide_icon = function()
			if mpris_iconbox and mpris_iconbox.visible then
				mpris_iconbox.visible = not mpris_iconbox.visible
			end
		end
	}

	-- PRIVATE FUNCTIONS
	--

	local function get_list_metadata_cmd()
		return props.script_path .. (props.ignore_player and (" -i " .. props.ignore_player) or "")
	end

	local function format_content(player_metadata)
		local formatted_content = {
			text = "",
			text_bottom = ""
		}
		local content_full_text = player_metadata.player_name
		local content_top = player_metadata.player_name
		local state_text = player_metadata.state
		local state_separator = " "
		local states = {
			Playing = props.state_playing,
			Paused = props.state_paused
		}

		-- format state text or state separator
		if states[player_metadata.state] then
			state_text = states[player_metadata.state]
		else
			state_separator = " - "
		end

		-- format text (title, artist, ...)

		if string.find(player_metadata.player_name, 'firefox') then
			content_full_text = player_metadata.title .. props.separator .. player_metadata.artist
			content_top = player_metadata.title
			formatted_content.text_bottom = player_metadata.artist ~= "N/A" and player_metadata.artist or ""
		elseif player_metadata.artist ~= "N/A" and player_metadata.title ~= "N/A" then
			if props.title_first then
				content_full_text = player_metadata.title .. props.separator .. player_metadata.artist
			else
				content_full_text = player_metadata.artist .. props.separator .. player_metadata.title
			end
			content_top = player_metadata.title
			formatted_content.text_bottom = player_metadata.artist
		elseif player_metadata.title ~= "N/A" then
			content_full_text = player_metadata.title
			content_top = player_metadata.title
		elseif player_metadata.artist ~= "N/A" then
			content_full_text = player_metadata.artist
			formatted_content.text_bottom = player_metadata.artist
		end

		if mpris_textbox_bottom then
			formatted_content.text = ellipsize(state_text .. state_separator .. escape_f(content_top), props.max_chars)
			formatted_content.text_bottom = ellipsize(formatted_content.text_bottom, props.max_chars)
		else
			formatted_content.text = ellipsize(state_text .. state_separator .. escape_f(content_full_text), props.max_chars)
		end
		-- add space at the end for horizontal scroll
		if props.scroll_enabled and not mpris_textbox_bottom then
			formatted_content.text = formatted_content.text .. " "
		end

		return formatted_content
	end

	local display_handler = {
		display_empty_text = function()
			--mpris_textbox:set_text(props.empty_text)
			mpris_textbox:set_markup_silently(props.empty_text)
			icon_handler.hide_icon()
			scroll_handler.hide_bottom()
		end,
		display_content = function (player_metadata)
			icon_handler.show_icon(player_metadata.icon)
				--else
				-- format text
				local formatted_content = format_content(player_metadata)

				-- set text
				--
				-- naughty.notify({text= "mpris: " .. formatted_content.text ~= "" and formatted_content.text or props.empty_text})
				--mpris_textbox:set_text(formatted_content.text ~= "" and formatted_content.text or props.empty_text)
				mpris_textbox:set_markup_silently(formatted_content.text ~= "" and formatted_content.text or props.empty_text)
				if formatted_content.text_bottom ~= "" then
					scroll_handler.show_bottom(formatted_content.text_bottom)
				else
					scroll_handler.hide_bottom()
				end
			--end
		end
	}

	local function internal_refresh(_, stdout)
		local widget = mpris_textbox

		if refreshing then
			return
		end

		if #stdout < 2 then
			if current_state == "closed" then return end
			display_handler.display_empty_text()
			if mpris_popup.visible then
				mpris_popup.visible = not mpris_popup.visible
			end
			current_state = "closed"

			if props.all_clients_closed then
				props.all_clients_closed()
			end

			mdata = nil
			return
		end

		if current_state ~= "playing" and props.clients_running then
			props.clients_running()
		end

		current_state = "running"

		refreshing = true

		local main_player_metadata = nil
		local new_main_player = ""
		local mpris_popup_rows = { layout = wibox.layout.fixed.vertical }
		local players_info = {}

		-- fill players_info
		for v in string.gmatch(stdout, "([^\r\n]+)")
		do
			table.insert(players_info, v:match "^%s*(.-)%s*$")
		end

		-- loop through players_info
		for k, player_metadata in ipairs(players_info) do
			-- Declare/init vars
			local mpris_now = {
				state          = "N/A",
				artist         = "N/A",
				title          = "N/A",
				art_url        = "N/A",
				album          = "N/A",
				album_artist   = "N/A",
				player_name    = "N/A",
				instance       = "N/A",
				total_length   = "N/A",
				position       = "N/A",
				--remaining_time = "N/A",
				icon           = props.media_icons_default
			}
			local link = {
				'state',
				'artist',
				'title',
				'art_url',
				'album',
				'album_artist',
				'player_name',
				'total_length',
				'position',
				'instance'
			}

			-- Fill mpris_now
			local i = 1
			for v in string.gmatch(player_metadata, "([^;]+)")
			do
				if link[i] then
					-- trim value
					local trimmed_v = v:match "^%s*(.-)%s*$"
					-- trimmed value or "N/A"
					mpris_now[link[i]] = trimmed_v ~= "" and trimmed_v or "N/A"
				end
				i = i + 1
			end
			if mpris_now.instance == "N/A" then
				mpris_now.instance = mpris_now.player_name
			end

			-- Display
			if mpris_now.state ~= "N/A" then
				-- widget's content
				if props["media_icons_" .. mpris_now.player_name] then
					mpris_now.icon = props["media_icons_" .. mpris_now.player_name]
					if string.find(mpris_now.player_name, 'firefox') then
						mpris_now.icon = props.media_icons_firefox
					end
				else
					-- icon in system or the icon set by the widget
					mpris_now.icon = lookup_icon_f(mpris_now.player_name) or mpris_now.icon
				end

				-- the first one in the list or/and the selected one
				if not main_player_metadata or main_player ~= "" and mpris_now.instance == main_player then
					new_main_player = mpris_now.instance
					main_player_metadata = mpris_now
				end

				-- popup content
				local popup_row = nil
				local select_player_f = function()
					if main_player ~= mpris_now.instance then
						main_player = mpris_now.instance
						-- naughty.notify({text= "main player is now ".. main_player})
						internal_refresh(widget, stdout)
					end
				end
				-- if custom popup row creator
				if props.create_popup_row then
					local metadata = gears.table.clone(mpris_now, true)
					metadata.is_selected = mpris_now.instance == main_player
					local function _refresh()
						awful.spawn.easy_async_with_shell(get_list_metadata_cmd(), function(stdout)
							internal_refresh(mpris_textbox, stdout)
						end)
					end
					function metadata:play_pause()
						awful.spawn.easy_async_with_shell("playerctl play-pause --player=" .. mpris_now.instance, _refresh)
					end
					function metadata:previous()
						awful.spawn.easy_async_with_shell("playerctl previous --player=" .. mpris_now.instance, _refresh)
					end
					function metadata:next()
						awful.spawn.easy_async_with_shell("playerctl next --player=" .. mpris_now.instance, _refresh)
					end
					function metadata:seek_position(offset)
						awful.spawn.easy_async_with_shell("playerctl position " .. offset .. " --player=" .. mpris_now.instance, _refresh)
					end
					function metadata:step_forward(step)
						metadata:seek_position(tostring(step) .. "+")
					end
					function metadata:step_backward(step)
						metadata:seek_position(tostring(step) .. "-")
					end
					function metadata:select()
						select_player_f()
					end
					popup_row = props.create_popup_row(metadata)
				end
				-- if popup_row is still nil
				if not popup_row then
					popup_row = wibox.widget {
						{
							{
								{
									image = mpris_now.icon,
									forced_width = 48,
									forced_height = 48,
									widget = wibox.widget.imagebox
								},
								{
									{
										markup = "<b>" .. escape_f(mpris_now.title) .. "</b>",
										font = props.popup_font,
										widget = wibox.widget.textbox
									},
									{
										text = mpris_now.artist,
										font = props.popup_font,
										widget = wibox.widget.textbox
									},
									{
										markup = "<i>" .. escape_f(mpris_now.album ~= "N/A" and mpris_now.album or "") .. "</i>",
										font = props.popup_font,
										widget = wibox.widget.textbox
									},
									layout = wibox.layout.fixed.vertical
								},
								spacing = 12,
								layout = wibox.layout.fixed.horizontal
							},
							margins = 8,
							widget = wibox.container.margin
						},
						widget = wibox.container.background
					}
					popup_row:connect_signal("button::release", function(self, _, _, button)
						if button == 1 then
							select_player_f()
						end
					end)
				end
				-- add row
				if mpris_now.instance == new_main_player then
					table.insert(mpris_popup_rows, 1, popup_row)
				else
					table.insert(mpris_popup_rows, popup_row)
				end
			end
		end

		refreshing = false

		main_player = new_main_player

		if main_player_metadata then
			display_handler.display_content(main_player_metadata)
			if props.updated_callback then
				if not mdata then
					props.updated_callback(gears.table.clone(main_player_metadata, true))
				else
					local changedkey = gears.table.find_first_key(main_player_metadata, function (k, v)
						return mdata[k] ~= v
					end, false)
					if changedkey then
						props.updated_callback(gears.table.clone(main_player_metadata, true))
					end
				end
			end
			mdata = main_player_metadata
		else
			display_handler.display_empty_text()
			if props.updated_callback and mdata then
				props.updated_callback(nil)
			end
			mdata = nil
		end

		mpris_popup:setup(mpris_popup_rows)
		if #mpris_popup_rows == 0 and mpris_popup.visible then
			mpris_popup.visible = not mpris_popup.visible
		end
	end

	local function refresh()
		awful.spawn.easy_async_with_shell(get_list_metadata_cmd(), function(stdout)
			control_running = false
			internal_refresh(mpris_textbox, stdout)
		end)
	end

	local function run_cmd_and_refresh(cmd)
		awful.spawn.easy_async_with_shell(cmd, refresh)
	end

	local function run_control(control_cmd)
		if control_running then
			return
		end
		control_running = true
		local cmd = "playerctl " .. control_cmd
		if main_player ~= "" then
			cmd = cmd .. " --player=" .. main_player
		end
		run_cmd_and_refresh(cmd)
	end

	-- PUBLIC METHODS
	--

	function mpris_widget:play_pause()
		run_control("play-pause")
	end

	function mpris_widget:previous()
		run_control("previous")
	end

	function mpris_widget:next()
		run_control("next")
	end

	---@param offset string
	function mpris_widget:seek_position(offset)
		run_control("position " .. offset)
	end

	---@param step number in seconds
	function mpris_widget:step_forward(step)
		mpris_widget:seek_position(tostring(step) .. "+")
	end

	---@param step number in seconds
	function mpris_widget:step_backward(step)
		--mpris_widget:step_forward(-step)
		mpris_widget:seek_position(tostring(step) .. "-")
	end

	---Select a running player to control
	---@param player_name string
	function mpris_widget:select_player(player_name)
		if type(player_name) == "string" and player_name ~= main_player then
			main_player = player_name
			refresh()
		end
		return self
	end

	-- EVENT LISTENERS
	--

	mpris_widget:connect_signal("button::release", function(self, _, _, button, _, find_widgets_result)
		if button == 1 and main_player then
			-- play/pause
			mpris_widget:play_pause()
		elseif button == 3 then
			-- display details
			if mpris_popup.visible then
				-- hide details
				mpris_popup.visible = not mpris_popup.visible
			elseif main_player ~= "" then
				-- display details next to { x=, y=, width=, height= }
				mpris_popup:move_next_to(
					find_widgets_result
				)
			end
		end
	end)

	-- WATCHERS
	--

	local _, mpris_timer = awful.widget.watch(
		-- format 'playerctl metadata' command result
			{ awful.util.shell, "-c", get_list_metadata_cmd() },
			props.timeout,
			internal_refresh,
			mpris_textbox
		)

	return mpris_widget
end

return setmetatable({}, { __call = function(_, ...) return init_mpris_widget(...) end })
