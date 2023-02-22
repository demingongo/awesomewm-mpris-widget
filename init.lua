-- awesomewm-mpris-widget
--
-- Author: demingongo
-- Link: https://github.com/demingongo
-- Availability: https://github.com/demingongo/awesomewm-mpris-widget

-- container scroll ? to see the text in textbox (https://awesomewm.org/doc/api/classes/wibox.container.scroll.html)
-- TODO: preferred player 
-- TODO: Find a way to display artUrl (download it and cache it maybe?)

local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local escape_f = require("awful.util").escape;
local beautiful = require("beautiful")
-- local naughty = require("naughty")

local get_players_metadata_script_path = os.getenv("HOME") .. "/.local/bin/list_players_metadata"

local local_media_icons = {
	default = "/icons/candy-icons/juk.svg",
	firefox = "/icons/candy-icons/firefox.svg",
	rhythmbox = "/icons/hicolor/org.gnome.Rhythmbox3.svg",
	spotify = "/icons/candy-icons/spotify-client.svg",
	totem = "/icons/hicolor/org.gnome.Totem.svg"
}

local media_icons = {
  default = os.getenv("HOME") .. "/.icons/candy-icons/apps/scalable/juk.svg",
  firefox = os.getenv("HOME") .. "/.icons/candy-icons/apps/scalable/firefox.svg",
  spotify = os.getenv("HOME") .. "/.icons/candy-icons/apps/scalable/spotify-client.svg",
  totem = "/usr/share/icons/hicolor/scalable/apps/org.gnome.Totem.svg",
  rhythmbox = "/usr/share/icons/hicolor/scalable/apps/org.gnome.Rhythmbox3.svg"
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

	result.empty_text = type(params.empty_text) == "string"
		and params.empty_text
		or ""

	-- Function
	--

	result.script_path =  type(params.metadata_script_path) == "string" 
		and params.metadata_script_path ~= "" 
		and params.metadata_script_path
		or ( result.widget_dir and result.widget_dir .. "/bin/list_players_metadata" )
		or get_players_metadata_script_path

	result.ignore_player = type(params.ignore_player) == "string" and params.ignore_player or nil

	result.timeout = type(params.timeout) == "number" and params.timeout or 3

	-- Style
	--

	result.font = type(params.font) == "string" 
		and params.font
		or beautiful.font
	
	result.fg = type(params.fg) == "string" 
		and params.fg
		or beautiful.fg_normal
	
	result.bg = type(params.bg) == "string"  
		and params.bg
		or beautiful.bg_normal
	
	result.bgimage = params.bgimage or nil

	result.popup_border_width = type(params.popup_border_width) == "number" 
		and params.popup_border_width or 1

	result.popup_border_color = type(params.popup_border_color) == "string" 
		and params.popup_border_color or beautiful.bg_focus

	result.popup_maximum_width = type(params.popup_maximum_width) == "number" 
		and params.popup_maximum_width or 400

	result.state_playing = type(params.state_playing) == "string" 
		and params.state_playing or "󰝚 " 
	
	result.state_paused = type(params.state_paused) == "string" 
		and params.state_paused or "  "

	result.max_chars = type(params.max_chars) == "number" and params.max_chars or 36

	result.media_icons_default = type(params.media_icons_default) == "string" 
		and params.media_icons_default 
		or ( result.widget_dir and result.widget_dir .. local_media_icons.default )
		or media_icons.default
	
	result.media_icons_spotify = type(params.media_icons_spotify) == "string" 
		and params.media_icons_spotify
		or ( result.widget_dir and result.widget_dir .. local_media_icons.spotify )
		or media_icons.spotify
	
	result.media_icons_firefox = type(params.media_icons_firefox) == "string" 
		and params.media_icons_firefox 
		or ( result.widget_dir and result.widget_dir .. local_media_icons.firefox )
		or media_icons.firefox
	
	result.media_icons_totem = type(params.media_icons_totem) == "string" 
		and params.media_icons_totem 
		or ( result.widget_dir and result.widget_dir .. local_media_icons.totem )
		or media_icons.totem

	result.media_icons_rhythmbox = type(params.media_icons_rhythmbox) == "string" 
		and params.media_icons_rhythmbox 
		or ( result.widget_dir and result.widget_dir .. local_media_icons.rhythmbox )
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
	
	return result
end

--
-- @params {{
-- 	widget_dir = string,
-- 	empty_text = string,
--	metadata_script_path = string,
-- 	ignore_player = string,
-- 	timeout = number,
-- 	font = string,
-- 	fg = string,
-- 	bg = string,
-- 	bgimage = gears.surface,
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
-- 	max_chars = number
-- }} params
--
local function init_mpris_widget(params)

local props = initProps(params)

local main_player = ""

local refreshing = false

local function get_list_metadata_cmd()
	return props.script_path .. ( props.ignore_player and ( " -i " .. props.ignore_player) or "" )
end

local mpris_textbox = wibox.widget.textbox();

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

local function internal_refresh(_, stdout)
	local widget = mpris_textbox

	if refreshing then
		return
	end

        if stdout == '' then
            widget:set_text(props.empty_text)
            if mpris_popup.visible then
                mpris_popup.visible = not mpris_popup.visible
            end
            return
        end

	refreshing = true

	local new_main_player = ""
        local content_text = ""
        local mpris_popup_rows = { layout = wibox.layout.fixed.vertical }
        local players_info = {}
        for v in string.gmatch(stdout, "([^\r\n]+)") 
        do
            table.insert(players_info, v:match "^%s*(.-)%s*$")
        end

        for k, player_metadata in ipairs(players_info) do
                -- Declare/init vars
                local player_icon = props.media_icons_default
                local states = {
                    Playing = props.state_playing,
                    Paused = props.state_paused
                }
                local state_separator = " "
                local mpris_now = {
                    state           = "N/A",
                    artist          = "N/A",
                    title           = "N/A",
                    art_url         = "N/A",
                    album           = "N/A",
                    album_artist    = "N/A",
                    player_name     = "N/A"
                }
                local link = {
                    'state',
                    'artist',
                    'title',
                    'art_url',
                    'album',
                    'album_artist',
                    'player_name'
                } 
    
                -- Fill mpris_now
                local i = 1
                for v in string.gmatch(player_metadata, "([^;]+)") 
                do
                    if link[i] then
                        -- trim value
                        local trimmed_v = v:match "^%s*(.-)%s*$"  
                        -- trimmed value or "N/A"
                        mpris_now[ link[i] ] = trimmed_v ~= "" and trimmed_v or "N/A"
                    end
                    i = i + 1
                end
            
                if states[mpris_now.state] then
                    mpris_now.state = states[mpris_now.state]
                else
                    state_separator = " - "
                end

                -- Display
                if mpris_now.state ~= "N/A" then
                    -- widget's content
                    local content_w = mpris_now.artist .. " - " .. mpris_now.title
                   
		    if props["media_icons_" .. mpris_now.player_name] then
			player_icon = props["media_icons_" .. mpris_now.player_name]
                    	if string.find(mpris_now.player_name, 'firefox') then
                            player_icon = props.media_icons_firefox
                            content_w = mpris_now.title .. " - " .. mpris_now.artist
			end
                    end

                    if mpris_now.artist == "N/A" and  mpris_now.title == "N/A" then
                        content_w = mpris_now.player_name
                    elseif mpris_now.artist == "N/A" then
                        content_w = mpris_now.title
                    elseif mpris_now.title == "N/A" then
                        content_w = mpris_now.artist
                    end
                    if content_text == "" or main_player ~= "" and mpris_now.player_name == main_player then
			new_main_player = mpris_now.player_name
                        content_text = ellipsize(mpris_now.state ..state_separator .. content_w, props.max_chars)
                    end

                    -- popup content   
		    local popup_row = wibox.widget {
                        {
                            {
                                {
                                    image = player_icon,
                                    forced_width = 48,
                                    forced_height = 48,
                                    widget = wibox.widget.imagebox
                                },
                                {
                                    {
                                        markup = "<b>" .. escape_f(mpris_now.title) .. "</b>",
                                        widget = wibox.widget.textbox
                                    },
                                    {
                                        text = mpris_now.artist,
                                        widget = wibox.widget.textbox
                                    },
                                    {
                                        markup = "<i>" .. escape_f(mpris_now.album ~= "N/A" and mpris_now.album or "") .. "</i>",
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
                        -- fg = props.fg,
                        -- bg = props.bg,
                        widget = wibox.container.background
                    }
		    popup_row:connect_signal("button::release", function(self, _, _, button)
			if button == 1 then
			    if main_player ~= mpris_now.player_name then
			    	main_player = mpris_now.player_name
			    	internal_refresh(widget, stdout)
			    end
			end
		    end)
		    -- add row
		    if mpris_now.player_name == new_main_player then
			table.insert(mpris_popup_rows, 1, popup_row)
		    else
			table.insert(mpris_popup_rows, popup_row)
		    end
        	end
        end
	refreshing = false
	main_player = new_main_player
        widget:set_text(content_text ~= "" and content_text or props.empty_text)
        mpris_popup:setup(mpris_popup_rows)
	if #mpris_popup_rows == 0 and mpris_popup.visible then
	    mpris_popup.visible = not mpris_popup.visible
	end
end

local function refresh()
    awful.spawn.easy_async_with_shell(get_list_metadata_cmd(), function(stdout)
	internal_refresh(mpris_textbox, stdout)
    end)
end

local _, mpris_timer = awful.widget.watch(
    -- format 'playerctl metadata' command result
    { awful.util.shell, "-c", get_list_metadata_cmd() },
    props.timeout,
    internal_refresh,
    mpris_textbox
)

mpris_textbox:connect_signal("button::release", function(self, _, _, button, _, find_widgets_result)
    if button == 1 and main_player then
        -- play/pause
	local cmd = "playerctl play-pause"
	if main_player ~= "" then
	    cmd = cmd .. " --player=" .. main_player
	end
        awful.spawn.easy_async_with_shell(cmd, refresh)
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

return mpris_textbox

end

return init_mpris_widget
