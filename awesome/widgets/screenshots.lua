local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local dpi       = beautiful.xresources.apply_dpi

local screenshots_folder = os.getenv("HOME").."/Pictures/Screenshots"
local icon = "/usr/share/icons/elementary/apps/48/accessories-screenshot.svg"

local previous_menu = nil

local screenshot_icon = wibox.widget {
    image = icon,
    resize = true,
    widget = wibox.widget.imagebox
}

screenshot_icon:buttons(awful.util.table.join(
    awful.button({}, 1, function() -- left click
        if previous_menu then
            previous_menu:hide()
        end
        awful.spawn.easy_async_with_shell(
            string.format("ls -l %s | awk '{print $9}' | tail -n 10 | sort -r", screenshots_folder),
            function(stdout, stderr, reason, exit_code)
                local menu = awful.menu()

                for screenshot in stdout:gmatch("%S+") do
                    local full_path = string.format("%s/%s", screenshots_folder, screenshot)
                    menu:add({
                        screenshot,
                        function()
                            awful.spawn(string.format("xdg-open %s", full_path))
                            awful.spawn(string.format("xclip -selection clipboard -t image/png %s", full_path))
                        end,
                        icon
                    })
                end

                menu:show()
                previous_menu = menu
            end
        )
    end),
    awful.button({}, 3, function() -- right click
        awful.spawn(string.format("xdg-open %s", screenshots_folder))
    end)
))

screenshot_icon.globalkeys = gears.table.join(
    awful.key({ modkey }, "p", function ()
        awful.spawn(string.format(
            "scrot -e 'mv $f %s'", screenshots_folder
        ))
    end),
    awful.key({ modkey }, "o", function ()
        awful.spawn.with_shell(string.format(
            "sleep 0.2 && scrot -s -e 'mv $f %s'", screenshots_folder
        ))
    end)
)

screenshot_icon.container = {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(screenshot_icon,    dpi(0),  dpi(3), dpi(4), dpi(4)),
}

return screenshot_icon
