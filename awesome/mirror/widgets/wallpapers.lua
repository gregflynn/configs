local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local Dropdown = require("util/dropdown")


wallpapers_icon = Dropdown {
    folder    = beautiful.dotsan_home.."/private/wallpapers",
    font_icon = "\u{f878}",
    tooltip_text = "Wallpapers",
    menu_func = function(full_path)
        awful.screen.connect_for_each_screen(function(s)
            gears.wallpaper.maximized(full_path, s)
        end)
    end
}

wallpapers_icon.container = {
    layout = wibox.layout.fixed.horizontal, wallpapers_icon
}


return wallpapers_icon
