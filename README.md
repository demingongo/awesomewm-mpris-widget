# awesomewm-mpris-widget

MPRIS widget for AwesomeWM.

Play and select the media player you want to control.

Please check the [Wiki!](https://github.com/demingongo/awesomewm-mpris-widget/wiki)

![Image](awesomewm-mpris-widget.gif)

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
    -- configuration
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

**Left-click** the widget with your mouse to **play/pause** the media player displaying its info.

**Right-click** the widget to **show/hide the popup**. 

The popup shows all MPRIS clients that have started. You can select (left-click) a media player to control from the popup.


## Configuration

[wiki/Configuration](https://github.com/demingongo/awesomewm-mpris-widget/wiki/Configuration)

## Events

[wiki/Events](https://github.com/demingongo/awesomewm-mpris-widget/wiki/Events)

## Methods

[wiki/Actions](https://github.com/demingongo/awesomewm-mpris-widget/wiki/Actions)