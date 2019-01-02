local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local naughty   = require("naughty")

local lain = require("lain")

local Dropdown = require("util/dropdown")
local file     = require("util/file")
local FontIcon = require("util/fonticon")
local Toggle   = require("util/toggle")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


-- Redshift
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


-- blinky
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


-- caffeine
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


-- screenshots
local screenshots_folder = beautiful.home.."/Pictures/Screenshots"
local screenshot_icon    = Dropdown {
    folder    = screenshots_folder,
    reverse   = true,
    font_icon = "\u{f793}",
    tooltip_text = "Screenshots",
    menu_func = function(full_path)
        awful.spawn(string.format(
            "xclip -selection clipboard -t image/png %s",
            full_path
        ))
        naughty.notify({
            preset =  {
                icon_size = dpi(256),
                timeout   = 2
            },
            icon = full_path,
        })
    end
}


-- wallpapers
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


-- arandr
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


local container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    redshift,
    blinky_enabled and blinky or nil,
    caffeine,
    screenshot_icon,
    wallpapers_icon,
    arandr_enabled and arandr or nil,
}
container.globalkeys = gears.table.join(
    awful.key(
        {modkey}, "p",
        function() awful.spawn(string.format(
            "scrot -e 'mv $f %s'", screenshots_folder
        )) end,
        {description = "take full screen screenshot", group = "screen"}
    ),
    awful.key(
        { modkey }, "o",
        function() awful.spawn.with_shell(string.format(
            "sleep 0.2 && scrot -s -e 'mv $f %s'", screenshots_folder
        )) end,
        {description = "take snippet screenshot", group = "screen"}
    )
)

return container
