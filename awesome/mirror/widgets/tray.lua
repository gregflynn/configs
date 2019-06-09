local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local lain = require("lain")

local Dropdown = require("util/dropdown")
local file     = require("util/file")
local Expand   = require("util/expand")
local FontIcon = require("util/fonticon")
local number   = require("util/number")
local Toggle   = require("util/toggle")

local colors = beautiful.colors


--
-- redshift
--
local redshift = FontIcon()
local tooltip  = awful.tooltip {
    objects = {redshift},
    text    = "redshift"
}
lain.widget.contrib.redshift:attach(redshift, function(active)
    if active then
        tooltip.text = "Redshift: Active"
        redshift:update("\u{f800}", colors.background)
    else
        tooltip.text = "Redshift: Inactive"
        redshift:update("\u{f800}", colors.white)
    end
end)


--
-- blinky
--
local blinky_command = "blinky"
local blinky_enabled = file.exists("/usr/bin/blinky")
local blinky         = Toggle {
    font_icon_enabled        = "\u{fbe6}",
    font_icon_enabled_color  = colors.background,
    font_icon_disabled       = "\u{fbe7}",
    font_icon_disabled_color = colors.white,
    default_enabled          = true,
    tooltip_text             = "Toggle LED Backlights",
    on_enable = function()
        awful.spawn({blinky_command, "--on"})
    end,
    on_disable = function()
        awful.spawn({blinky_command, "--off"})
    end
}


--
-- caffeine
--
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
    redshift,
    blinky_enabled and blinky or nil,
    caffeine,
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
