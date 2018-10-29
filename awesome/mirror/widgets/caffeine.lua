local beautiful = require("beautiful")
local wibox     = require("wibox")

local Toggle = require("util/toggle")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


local command = "xautolock"

local caffeine = Toggle {
    font_icon_enabled        = "\u{f456}",
    font_icon_enabled_color  = colors.white,
    font_icon_disabled       = "\u{f09c}",
    font_icon_disabled_color = colors.red,
    default_enabled          = true,
    command_enable           = {command, "-enable"},
    command_disable          = {command, "-disable" }
}

caffeine.container = {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(caffeine, dpi(0), dpi(3)),
}


return caffeine
