local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")

local file   = require("util/file")
local Toggle = require("util/toggle")

local colors = beautiful.colors

local command = "blinky"

local blinky = Toggle {
    font_icon_enabled        = "\u{fbe6}",
    font_icon_enabled_color  = colors.background,
    font_icon_disabled       = "\u{fbe7}",
    font_icon_disabled_color = colors.white,
    default_enabled          = true,
    on_enable = function()
        awful.spawn({command, "--on"})
    end,
    on_disable = function()
        awful.spawn({command, "--off"})
    end,
    tooltip_text             = "Toggle LED Backlights"
}

if file.exists("/usr/bin/blinky") then
    blinky.container = wibox.widget {
        layout = wibox.layout.fixed.horizontal, blinky
    }
else
    blinky.container = nil
end

return blinky

