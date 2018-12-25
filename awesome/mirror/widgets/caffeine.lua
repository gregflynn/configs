local awful     = require("awful")
local beautiful = require("beautiful")

local Toggle = require("util/toggle")
local colors = beautiful.colors


local caffeine = Toggle {
    font_icon_enabled        = "\u{fbc8}",
    font_icon_enabled_color  = colors.background,
    font_icon_disabled       = "\u{f675}",
    font_icon_disabled_color = colors.white,
    default_enabled          = true,
    tooltip_text             = "Toggle Screen Locking",
    on_enable = function()
        awful.spawn({"xautolock", "-enable"})
        awful.spawn({"xset", "s", "on"})
    end,
    on_disable = function()
        awful.spawn({"xautolock", "-disable"})
        awful.spawn({"xset", "s", "off"})
    end
}

return caffeine
