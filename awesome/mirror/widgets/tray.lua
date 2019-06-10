local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local Dropdown = require("util/dropdown")
local file     = require("util/file")
local Expand   = require("util/expand")
local FontIcon = require("util/fonticon")
local number   = require("util/number")
local Toggle   = require("util/toggle")

local colors = beautiful.colors


--
-- wallpapers
--
local wallpapers_icon = Dropdown {
    folder    = beautiful.dotsan_home.."/private/wallpapers",
    font_icon = "\u{f878}",
    tooltip_text = "Wallpapers",
    menu_func = function(full_path)
        awful.screen.connect_for_each_screen(function(s)
            gears.wallpaper.maximized(full_path, s)
        end)
    end
}


--
-- arandr
--
local arandr_folder  = beautiful.home.."/.screenlayout/"
local arandr_enabled = file.exists(arandr_folder)
local arandr         = Dropdown {
    folder = arandr_folder,
    font_icon = "\u{f879}",
    right_click = "arandr",
    tooltip_text = "Monitor Configs",
    menu_func = function(full_path)
        awful.spawn(string.format("bash %s", full_path))
    end
}

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
    wallpapers_icon,
    arandr_enabled and arandr or nil,
    systray
}

--
-- Screenshot hotkeys
--
container.globalkeys = gears.table.join(
    awful.key(
        {modkey}, "o", function()
            awful.spawn("flameshot gui")
        end,
        {description = "open flameshot", group = "screen"}
    )
)

return container
