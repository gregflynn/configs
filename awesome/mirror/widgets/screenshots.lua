local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local naughty   = require("naughty")
local dropdown  = require("widgets/dropdown")
local dpi       = beautiful.xresources.apply_dpi


local screenshots_folder = beautiful.home.."/Pictures/Screenshots"

local screenshot_icon = dropdown {
    folder = screenshots_folder,
    reverse = true,
    icon = "/usr/share/icons/elementary/apps/48/accessories-screenshot.svg",
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

screenshot_icon.globalkeys = gears.table.join(
    awful.key(
        { modkey }, "p",
        function ()
            awful.spawn(string.format(
                "scrot -e 'mv $f %s'", screenshots_folder
            ))
        end,
        {description = "take full screen screenshot", group = "screen"}
    ),
    awful.key(
        { modkey }, "o",
        function ()
            awful.spawn.with_shell(string.format(
                "sleep 0.2 && scrot -s -e 'mv $f %s'", screenshots_folder
            ))
        end,
        {description = "take snippet screenshot", group = "screen"}
    )
)

screenshot_icon.container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(screenshot_icon, dpi(0), dpi(3)),
}

return screenshot_icon
