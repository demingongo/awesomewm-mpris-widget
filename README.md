# awesomewm-mpris-widget

MPRIS widget for AwesomeWM.

## Dependencies

- [playerctl](https://github.com/altdesktop/playerctl#installing)

## Installation

Clone the repo under **~/.config/awesome/**:

```sh
git clone https://github.com/demingongo/awesomewm-mpris-widget.git ~/.config/awesome/awesomewm-mpris-widget
```

## Usage

```lua
local mpris_widget = require("awesomewm-mpris-widget")

local my_mpris_widget = mpris_widget {
    -- parameters
}

mywibar:setup({
    -- Left widgets
    { ... },
    -- Middle widgets
    { ... },
    -- Right widgets
    {
        my_mpris_widget,
        ...
    }
})
```

### Methods

```lua
-- play/pause media
my_mpris_widget:play_pause()

-- play previous media
mpris_widget:previous()

-- play next media
mpris_widget:next()
```

**Left-click** the widget with your mouse to **play/pause** the media player displaying its info.

**Right-click** the widget to **show/hide the popup**. 

The popup show all MPRIS clients that have started. You can select (left-click) a media player to control from the popup.


## Configuration

### Parameters

| Name | Default | Description |
|---|---|---|
| `state_playing` | `"󰝚  "` | Displays when a media is playing |
| `state_paused` | `"  "` | Displays when a media is paused |
| `max_chars`| `34`| Maximum characters. Set it to `-1` to disable this parameter |
| `empty_text` | `""` | Text when no media player is up |
| `separator` | `" - "` | Separator between title and artist |
| `font` | `theme.font` | Font for the widget |
| `fg` | `theme.fg_normal` | Text color for the popup |
| `bg` | `theme.bg_normal` | Background color for the popup |
| `bgimage` | `nil` | Background image for the popup |
| `popup_border_width` | `1` | Border's width for the popup |
| `popup_border_color` | `theme.bg_focus` | Border's color for the popup |
| `popup_maximum_width` | `400` | Maximum width of the popup |
| `media_icons` | `nil` | Table of keys and values. The key is the name of the client (e.g.: `firefox`, `spotify`, ...) and the value is the icon's path |
| `media_icons.default` | `nil` | Path to a default icon if no icon was found for a media player |
| `ignore_player` | `nil` | String of media players to ignore separated by commas (e.g.: `"firefox,musikcube,totem"`) |
| `timeout` | `3` | check interval in seconds |
| `scroll` | `400` | Table of keys and values to configure the scrolling text ability |
| `scroll.enabled` | `false` | Enable/disable scrolling text |
| `scroll.position` | `"horizontal"` | `"horizontal"` or `"vertical"` scroll |
| `scroll.max_size` | `170` | Widget's maximum width |
| `scroll.step_function` | `wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth` | Scrolling function |
| `scroll.speed` | `8` when `scroll.position="vertical"`, otherwise `20` | Scrolling speed |
| `scroll.fps` | `10` | Scrolling fps|
| `scroll.margin_top` | `5` | Scrolling margin top (useful when `scroll.position="vertical"`) |
| `scroll.margin_bottom` | `5` | Scrolling margin bottom (useful when `scroll.position="vertical"`) |
| `all_clients_closed` | `nil` | Function to execute when all media players got closed |
| `clients_running` | `nil` | Function to execute when media players started |