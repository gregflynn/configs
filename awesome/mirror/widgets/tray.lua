local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local Expand   = require("util/expand")


--
-- collapsed systray
--
local systray = Expand {
    font_icon = "\u{f013}",
    widget = wibox.widget.systray()
}

--
-- tray container and global keys
--
local container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    systray
}

return wibox.container.margin(container, 0, beautiful.widget_space, 0, 0)
