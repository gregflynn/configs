local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local dropdown = require("util/dropdown")

local dpi    = beautiful.xresources.apply_dpi


wallpapers_icon = dropdown {
    folder    = beautiful.dotsan_home.."/private/wallpapers",
    font_icon = "\u{f878}",
    menu_func = function(full_path)
        awful.screen.connect_for_each_screen(function(s)
            gears.wallpaper.maximized(full_path, s)
        end)
    end
}

wallpapers_icon.container = {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(wallpapers_icon, dpi(0), dpi(3)),
}


return wallpapers_icon
