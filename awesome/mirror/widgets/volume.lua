local awful     = require("awful")
local lain      = require("lain")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local FontIcon = require("util/fonticon")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi

local gpmdp = require("widgets/gpmdp")

local tooltip = awful.tooltip {}
local fg_color = colors.blue
local chart = wibox.widget {
    max_value = 100,
    thickness = dpi(4),
    start_angle = (2 * math.pi) * 3 / 4,
    bg = colors.gray,
    colors = {fg_color},
    widget = wibox.container.arcchart
}

local volume = lain.widget.pulsebar {
    width = dpi(60),
    margins = 4,
    paddings = 0,
    notification_preset = {
        position = "bottom_middle",
        title    = "volume",
        font     = "Hack 12"
    },
    colors = {
        background = beautiful.colors.gray,
        mute       = fg_color,
        unmute     = fg_color
    },
    settings = function()
        if volume_now.muted == "yes" then
            tooltip.text = "Muted"
            chart.values = {0}
        else
            local level = tonumber(volume_now.left)
            chart.values = {level}

            tooltip.text = string.format("Speakers: %s%%", level)
        end
    end
}

volume.buttons = awful.util.table.join(
    awful.button({}, 1, function() -- left click
        awful.spawn("pavucontrol")
    end),
    awful.button({}, 3, function() -- right click
        awful.spawn(string.format("pactl set-sink-mute %d toggle", volume.device))
        volume.update()
    end),
    awful.button({}, 4, function() -- scroll up
        awful.spawn(string.format("pactl set-sink-volume %d +1%%", volume.device))
        volume.update()
    end),
    awful.button({}, 5, function() -- scroll down
        awful.spawn(string.format("pactl set-sink-volume %d -1%%", volume.device))
        volume.update()
    end)
)

local container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    gpmdp,
    wibox.container.margin(chart, dpi(3), dpi(8), dpi(5), dpi(5)),
}
chart:buttons(volume.buttons)
tooltip:add_to_object(container)

container.globalkeys = gears.table.join(
    awful.key({ }, "XF86AudioRaiseVolume", function()
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
        volume.notify()
    end),
    awful.key({ }, "XF86AudioLowerVolume", function()
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
        volume.notify()
    end),
    awful.key({ }, "XF86AudioMute", function()
        awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
        volume.notify()
    end)
)

return container
