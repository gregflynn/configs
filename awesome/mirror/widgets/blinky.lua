local beautiful = require("beautiful")
local wibox     = require("wibox")

local file   = require("util/file")
local Toggle = require("util/toggle")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


local command = "blinky"

local blinky = Toggle {
    font_icon_enabled        = "\u{fbe6}",
    font_icon_enabled_color  = colors.white,
    font_icon_disabled       = "\u{fbe7}",
    font_icon_disabled_color = colors.background,
    default_enabled          = true,
    command_enable           = {command, "--on"},
    command_disable          = {command, "--off" }
}

if file.exists("/usr/bin/blinky") then
    blinky.container = {
        layout = wibox.layout.fixed.horizontal,
        wibox.container.margin(blinky, dpi(0), dpi(3)),
    }
else
    blinky.container = nil
end

return blinky
